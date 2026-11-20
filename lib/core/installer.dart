import 'dart:async';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

import 'catalog.dart';

class InstalledInfo {
  InstalledInfo(this.versionCode, this.versionName, this.installer, this.certSha256);
  final int versionCode;
  final String? versionName;
  final String? installer;
  final List<String> certSha256;

  bool get installedByHub => installer == 'com.sribees.hub';
}

/// Why an install did not happen. The UI maps each to en/si/ta text.
enum InstallError {
  download,
  hashMismatch,
  badApk,
  wrongPackage,
  wrongVersion,
  wrongSigner,
  signedByOtherSource,
  userCancelled,
  blocked,
  storage,
  incompatible,
  failed,
}

class InstallException implements Exception {
  InstallException(this.error, [this.detail = '']);
  final InstallError error;
  final String detail;
  @override
  String toString() => 'InstallException($error, $detail)';
}

/// Native bridge (see MainActivity.kt) + the verified install pipeline.
class Installer {
  Installer() {
    _ch.setMethodCallHandler(_onNative);
  }

  static const _ch = MethodChannel('sribees.hub/installer');
  final _pending = <String, Completer<void>>{};
  final _dio = Dio();

  Future<dynamic> _onNative(MethodCall call) async {
    if (call.method != 'onInstallStatus') return;
    final m = Map<String, dynamic>.from(call.arguments as Map);
    final pkg = m['package'] as String;
    final status = m['status'] as String;
    final c = _pending[pkg];
    if (c == null || c.isCompleted || status == 'pending_user') return;
    _pending.remove(pkg);
    switch (status) {
      case 'success':
        c.complete();
      case 'aborted':
        c.completeError(InstallException(InstallError.userCancelled));
      case 'blocked':
        c.completeError(InstallException(InstallError.blocked, '${m['message']}'));
      case 'conflict':
        c.completeError(InstallException(InstallError.signedByOtherSource, '${m['message']}'));
      case 'storage':
        c.completeError(InstallException(InstallError.storage));
      case 'incompatible':
        c.completeError(InstallException(InstallError.incompatible, '${m['message']}'));
      default:
        c.completeError(InstallException(InstallError.failed, '${m['message']}'));
    }
  }

  Future<bool> canInstall() async => (await _ch.invokeMethod<bool>('canInstall')) ?? false;

  Future<void> openInstallSettings() => _ch.invokeMethod('openInstallSettings');

  Future<bool> launch(String package) async =>
      (await _ch.invokeMethod<bool>('launch', {'package': package})) ?? false;

  Future<InstalledInfo?> installed(String package) async {
    final m = await _ch.invokeMapMethod<String, dynamic>('installedVersion', {'package': package});
    if (m == null) return null;
    return InstalledInfo(
      (m['versionCode'] as num).toInt(),
      m['versionName'] as String?,
      m['installer'] as String?,
      ((m['certSha256'] as List?) ?? const []).map((e) => '$e').toList(),
    );
  }

  /// Download -> sha256 -> package/version/signer checks -> PackageInstaller.
  /// [onProgress] gets 0..1 while downloading.
  Future<void> install(HubApp app, {void Function(double)? onProgress}) async {
    final dir = Directory('${(await getTemporaryDirectory()).path}/hub');
    await dir.create(recursive: true);
    final file = File('${dir.path}/${app.package}-${app.versionCode}.apk');
    try {
      try {
        await _dio.download(
          app.apkUrl!,
          file.path,
          onReceiveProgress: (r, t) {
            if (t > 0) onProgress?.call(r / t);
          },
        );
      } on DioException catch (e) {
        throw InstallException(InstallError.download, '${e.type}');
      }

      final digest = (await sha256.bind(file.openRead()).first).toString();
      if (digest != app.sha256) {
        throw InstallException(InstallError.hashMismatch);
      }

      final info = await _ch.invokeMapMethod<String, dynamic>('inspectApk', {'path': file.path});
      if (info == null) throw InstallException(InstallError.badApk);
      if (info['package'] != app.package) {
        throw InstallException(InstallError.wrongPackage, '${info['package']}');
      }
      if ((info['versionCode'] as num).toInt() != app.versionCode) {
        throw InstallException(InstallError.wrongVersion, '${info['versionCode']}');
      }
      final certs = ((info['certSha256'] as List?) ?? const []).map((e) => '$e').toSet();
      if (!app.certSha256.any(certs.contains)) {
        throw InstallException(InstallError.wrongSigner);
      }

      // An existing copy signed by another key (e.g. the Play copy) cannot be
      // updated by us; say so instead of letting Android fail with a vague error.
      final current = await installed(app.package);
      if (current != null &&
          current.certSha256.isNotEmpty &&
          !current.certSha256.any(certs.contains)) {
        throw InstallException(InstallError.signedByOtherSource);
      }

      final done = Completer<void>();
      _pending[app.package] = done;
      await _ch.invokeMethod('install', {'path': file.path, 'package': app.package});
      await done.future;
    } finally {
      _pending.remove(app.package);
      if (await file.exists()) await file.delete();
    }
  }
}
