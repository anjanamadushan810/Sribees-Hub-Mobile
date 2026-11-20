package com.sribees.hub

import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.content.pm.PackageInfo
import android.content.pm.PackageInstaller
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileInputStream
import java.security.MessageDigest

/**
 * Native installer bridge for SriBees Hub.
 *
 * Channel "sribees.hub/installer":
 *  - canInstall()                      -> Boolean ("Install unknown apps" granted)
 *  - openInstallSettings()             -> opens the per-app settings page
 *  - installedVersion(package)         -> {versionCode, versionName, installer} or null
 *  - inspectApk(path)                  -> {package, versionCode, versionName, certSha256[]}
 *  - install(path, package)            -> starts a PackageInstaller session; result is
 *                                         reported later via "onInstallStatus" callback
 *  - launch(package)                   -> opens the app
 *
 * The Dart side checks sha256 + cert digest + package + versionCode BEFORE install().
 */
class MainActivity : FlutterActivity() {
    private val channelName = "sribees.hub/installer"
    private val statusAction = "com.sribees.hub.INSTALL_STATUS"
    private var channel: MethodChannel? = null
    private var receiverRegistered = false

    private val statusReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context, intent: Intent) {
            val status = intent.getIntExtra(PackageInstaller.EXTRA_STATUS, PackageInstaller.STATUS_FAILURE)
            val pkg = intent.getStringExtra("hub_package") ?: ""
            if (status == PackageInstaller.STATUS_PENDING_USER_ACTION) {
                @Suppress("DEPRECATION")
                val confirm: Intent? = if (Build.VERSION.SDK_INT >= 33) {
                    intent.getParcelableExtra(Intent.EXTRA_INTENT, Intent::class.java)
                } else {
                    intent.getParcelableExtra(Intent.EXTRA_INTENT)
                }
                if (confirm != null) {
                    confirm.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                    startActivity(confirm)
                }
                channel?.invokeMethod("onInstallStatus", mapOf("package" to pkg, "status" to "pending_user"))
                return
            }
            val name = when (status) {
                PackageInstaller.STATUS_SUCCESS -> "success"
                PackageInstaller.STATUS_FAILURE_ABORTED -> "aborted"
                PackageInstaller.STATUS_FAILURE_BLOCKED -> "blocked"
                PackageInstaller.STATUS_FAILURE_CONFLICT -> "conflict"
                PackageInstaller.STATUS_FAILURE_INCOMPATIBLE -> "incompatible"
                PackageInstaller.STATUS_FAILURE_INVALID -> "invalid"
                PackageInstaller.STATUS_FAILURE_STORAGE -> "storage"
                else -> "failure"
            }
            channel?.invokeMethod(
                "onInstallStatus",
                mapOf(
                    "package" to pkg,
                    "status" to name,
                    "message" to (intent.getStringExtra(PackageInstaller.EXTRA_STATUS_MESSAGE) ?: ""),
                ),
            )
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        registerStatusReceiver()
        val ch = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
        channel = ch
        ch.setMethodCallHandler { call, result ->
            try {
                when (call.method) {
                    "canInstall" -> result.success(
                        Build.VERSION.SDK_INT < 26 || packageManager.canRequestPackageInstalls(),
                    )
                    "openInstallSettings" -> {
                        if (Build.VERSION.SDK_INT >= 26) {
                            val i = Intent(
                                Settings.ACTION_MANAGE_UNKNOWN_APP_SOURCES,
                                Uri.parse("package:$packageName"),
                            )
                            startActivity(i)
                        }
                        result.success(null)
                    }
                    "installedVersion" -> result.success(installedVersion(call.argument<String>("package")!!))
                    "inspectApk" -> result.success(inspectApk(call.argument<String>("path")!!))
                    "install" -> {
                        install(call.argument<String>("path")!!, call.argument<String>("package")!!)
                        result.success(null)
                    }
                    "launch" -> {
                        val i = packageManager.getLaunchIntentForPackage(call.argument<String>("package")!!)
                        if (i != null) startActivity(i)
                        result.success(i != null)
                    }
                    else -> result.notImplemented()
                }
            } catch (e: Exception) {
                result.error("installer_error", e.message, null)
            }
        }
    }

    private fun registerStatusReceiver() {
        if (receiverRegistered) return
        val filter = IntentFilter(statusAction)
        if (Build.VERSION.SDK_INT >= 33) {
            registerReceiver(statusReceiver, filter, Context.RECEIVER_NOT_EXPORTED)
        } else {
            @Suppress("UnspecifiedRegisterReceiverFlag")
            registerReceiver(statusReceiver, filter)
        }
        receiverRegistered = true
    }

    override fun onDestroy() {
        if (receiverRegistered) {
            unregisterReceiver(statusReceiver)
            receiverRegistered = false
        }
        super.onDestroy()
    }

    private fun installedVersion(pkg: String): Map<String, Any?>? {
        // Signing certs are read too, so the Hub can say "installed from another
        // source" (e.g. a Play copy) before Android refuses the update.
        val info: PackageInfo = try {
            if (Build.VERSION.SDK_INT >= 33) {
                packageManager.getPackageInfo(pkg, PackageManager.PackageInfoFlags.of(certFlags().toLong()))
            } else {
                @Suppress("DEPRECATION")
                packageManager.getPackageInfo(pkg, certFlags())
            }
        } catch (e: PackageManager.NameNotFoundException) {
            return null
        }
        val installer: String? = try {
            if (Build.VERSION.SDK_INT >= 30) {
                packageManager.getInstallSourceInfo(pkg).installingPackageName
            } else {
                @Suppress("DEPRECATION")
                packageManager.getInstallerPackageName(pkg)
            }
        } catch (e: Exception) {
            null
        }
        return mapOf(
            "versionCode" to versionCodeOf(info),
            "versionName" to info.versionName,
            "installer" to installer,
            "certSha256" to certDigests(info),
        )
    }

    private fun inspectApk(path: String): Map<String, Any?>? {
        val flags = certFlags()
        val info = if (Build.VERSION.SDK_INT >= 33) {
            packageManager.getPackageArchiveInfo(path, PackageManager.PackageInfoFlags.of(flags.toLong()))
        } else {
            @Suppress("DEPRECATION")
            packageManager.getPackageArchiveInfo(path, flags)
        } ?: return null
        return mapOf(
            "package" to info.packageName,
            "versionCode" to versionCodeOf(info),
            "versionName" to info.versionName,
            "certSha256" to certDigests(info),
        )
    }

    private fun certFlags(): Int =
        if (Build.VERSION.SDK_INT >= 28) {
            PackageManager.GET_SIGNING_CERTIFICATES
        } else {
            @Suppress("DEPRECATION")
            PackageManager.GET_SIGNATURES
        }

    private fun versionCodeOf(info: PackageInfo): Long =
        if (Build.VERSION.SDK_INT >= 28) {
            info.longVersionCode
        } else {
            @Suppress("DEPRECATION")
            info.versionCode.toLong()
        }

    private fun certDigests(info: PackageInfo): List<String> {
        @Suppress("DEPRECATION")
        val sigs = if (Build.VERSION.SDK_INT >= 28) {
            val si = info.signingInfo ?: return emptyList()
            if (si.hasMultipleSigners()) si.apkContentsSigners else si.signingCertificateHistory
        } else {
            info.signatures
        } ?: return emptyList()
        val md = MessageDigest.getInstance("SHA-256")
        return sigs.map { s -> md.digest(s.toByteArray()).joinToString("") { "%02x".format(it) } }
    }

    private fun install(path: String, pkg: String) {
        val installer = packageManager.packageInstaller
        val params = PackageInstaller.SessionParams(PackageInstaller.SessionParams.MODE_FULL_INSTALL)
        params.setAppPackageName(pkg)
        if (Build.VERSION.SDK_INT >= 31) {
            // Silent update when Hub is the installer of record (first install still asks once).
            params.setRequireUserAction(PackageInstaller.SessionParams.USER_ACTION_NOT_REQUIRED)
        }
        if (Build.VERSION.SDK_INT >= 34) {
            params.setRequestUpdateOwnership(true)
        }
        val file = File(path)
        params.setSize(file.length())
        val sessionId = installer.createSession(params)
        installer.openSession(sessionId).use { session ->
            FileInputStream(file).use { input ->
                session.openWrite("base.apk", 0, file.length()).use { out ->
                    input.copyTo(out)
                    session.fsync(out)
                }
            }
            val intent = Intent(statusAction).setPackage(packageName).putExtra("hub_package", pkg)
            val flags = if (Build.VERSION.SDK_INT >= 31) {
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_MUTABLE
            } else {
                PendingIntent.FLAG_UPDATE_CURRENT
            }
            val pi = PendingIntent.getBroadcast(this, sessionId, intent, flags)
            session.commit(pi.intentSender)
        }
    }
}
