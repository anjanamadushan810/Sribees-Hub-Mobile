import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/catalog.dart';
import '../../core/installer.dart';
import '../../core/theme.dart';
import '../../l10n/app_localizations.dart';
import 'apps_controller.dart';

final _hubVersionProvider = FutureProvider<String>((ref) async {
  final p = await PackageInfo.fromPlatform();
  return '${p.version}+${p.buildNumber}';
});

class AppsScreen extends ConsumerStatefulWidget {
  const AppsScreen({super.key});

  @override
  ConsumerState<AppsScreen> createState() => _AppsScreenState();
}

class _AppsScreenState extends ConsumerState<AppsScreen> with WidgetsBindingObserver {
  bool _canInstall = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkPermission();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Back from Settings or from an installed app: refresh what is on the phone.
    if (state == AppLifecycleState.resumed) {
      _checkPermission();
      ref.invalidate(appsProvider);
    }
  }

  Future<void> _checkPermission() async {
    if (!Platform.isAndroid) return;
    final ok = await ref.read(installerProvider).canInstall();
    if (mounted) setState(() => _canInstall = ok);
  }

  String _lang(BuildContext context) => Localizations.localeOf(context).languageCode;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final rows = ref.watch(appsProvider);
    final version = ref.watch(_hubVersionProvider).value ?? '';

    return Scaffold(
      backgroundColor: HubColors.surface,
      appBar: AppBar(
        title: Text(t.appTitle),
        actions: [
          PopupMenuButton<String>(
            tooltip: t.language,
            icon: const Icon(Icons.translate),
            onSelected: (v) => ref.read(localeProvider.notifier).choose(v),
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'si', child: Text('සිංහල')),
              PopupMenuItem(value: 'ta', child: Text('தமிழ்')),
              PopupMenuItem(value: 'en', child: Text('English')),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(appsProvider);
          await ref.read(appsProvider.future).catchError((_) => <AppRow>[]);
        },
        child: rows.when(
          loading: () => const _Skeleton(),
          error: (e, _) => _Message(
            icon: Icons.wifi_off,
            text: t.loadError,
            action: FilledButton(
              onPressed: () => ref.invalidate(appsProvider),
              child: Text(t.retry),
            ),
          ),
          data: (list) {
            if (list.isEmpty) {
              return _Message(icon: Icons.apps, text: t.empty);
            }
            final updates = list.where((r) => r.hasUpdate).length;
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (!_canInstall) _PermissionCard(onAllow: () {
                  ref.read(installerProvider).openInstallSettings();
                }),
                if (updates > 0)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      t.updatesCount(updates),
                      style: const TextStyle(
                        color: HubColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                for (final r in list) _AppCard(row: r, lang: _lang(context)),
                const SizedBox(height: 24),
                Center(
                  child: Text(
                    t.hubVersion(version),
                    style: const TextStyle(color: Colors.black54, fontSize: 12),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _AppCard extends ConsumerWidget {
  const _AppCard({required this.row, required this.lang});
  final AppRow row;
  final String lang;

  String _errorText(AppLocalizations t, InstallError e) => switch (e) {
        InstallError.download => t.errDownload,
        InstallError.hashMismatch ||
        InstallError.badApk ||
        InstallError.wrongPackage ||
        InstallError.wrongVersion ||
        InstallError.wrongSigner =>
          t.errTampered,
        InstallError.signedByOtherSource => t.errOtherSource,
        InstallError.userCancelled => t.errCancelled,
        InstallError.blocked => t.errBlocked,
        InstallError.storage => t.errStorage,
        InstallError.incompatible => t.errIncompatible,
        InstallError.failed => t.errFailed,
      };

  Future<void> _install(BuildContext context, WidgetRef ref) async {
    final t = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final installer = ref.read(installerProvider);
    final progress = ref.read(progressProvider.notifier);
    if (!await installer.canInstall()) {
      await installer.openInstallSettings();
      return;
    }
    progress.set(row.app.package, 0);
    try {
      await installer.install(
        row.app,
        onProgress: (p) => progress.set(row.app.package, p >= 1 ? 2 : p),
      );
      progress.set(row.app.package, 2);
      HapticFeedback.lightImpact();
      messenger.showSnackBar(SnackBar(content: Text(t.installDone(row.app.name(lang)))));
    } on InstallException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(_errorText(t, e.error))));
    } catch (_) {
      messenger.showSnackBar(SnackBar(content: Text(t.errFailed)));
    } finally {
      progress.clear(row.app.package);
      ref.invalidate(appsProvider);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final app = row.app;
    final p = ref.watch(progressProvider)[app.package];

    final status = row.isInstalled
        ? t.installed(row.installed!.versionName ?? '${row.installed!.versionCode}')
        : t.notInstalled;
    final latest = app.versionName != null ? t.latest(app.versionName!) : null;

    Widget action;
    if (p != null) {
      action = SizedBox(
        width: 140,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            LinearProgressIndicator(value: p <= 1 ? p : null),
            const SizedBox(height: 4),
            Text(
              p <= 1 ? t.downloading((p * 100).round()) : t.installing,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      );
    } else if (!Platform.isAndroid || app.kind == DeliveryKind.storeLink) {
      final url = Platform.isIOS ? app.iosUrl : app.playUrl;
      final installed = Platform.isAndroid && row.isInstalled;
      action = url == null && !installed
          ? const SizedBox.shrink()
          : OutlinedButton(
              onPressed: () {
                if (installed) {
                  ref.read(installerProvider).launch(app.package);
                } else {
                  launchUrl(Uri.parse(url!), mode: LaunchMode.externalApplication);
                }
              },
              child: Text(installed
                  ? t.open
                  : (Platform.isIOS ? t.getOnAppStore : t.getOnPlay)),
            );
    } else if (row.hasUpdate) {
      action = FilledButton(onPressed: () => _install(context, ref), child: Text(t.update));
    } else if (row.isInstalled) {
      action = OutlinedButton(
        onPressed: () => ref.read(installerProvider).launch(app.package),
        child: Text(t.open),
      );
    } else {
      action = FilledButton(onPressed: () => _install(context, ref), child: Text(t.install));
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CircleAvatar(
              radius: 24,
              backgroundColor: HubColors.primary,
              child: Icon(Icons.hive, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        app.name(lang),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: HubColors.ink,
                        ),
                      ),
                      if (app.audience == 'staff')
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFCE7F0),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(t.staffBadge,
                              style: const TextStyle(fontSize: 11, color: HubColors.primary)),
                        ),
                    ],
                  ),
                  if (app.description(lang).isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(app.description(lang), style: const TextStyle(color: Colors.black87)),
                  ],
                  const SizedBox(height: 6),
                  Text(
                    [status, if (latest != null && app.kind == DeliveryKind.apk) latest]
                        .join(' · '),
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                  const SizedBox(height: 12),
                  Align(alignment: Alignment.centerRight, child: action),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PermissionCard extends StatelessWidget {
  const _PermissionCard({required this.onAllow});
  final VoidCallback onAllow;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(t.permTitle, style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            Text(t.permBody),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton(onPressed: onAllow, child: Text(t.permAllow)),
            ),
          ],
        ),
      ),
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({required this.icon, required this.text, this.action});
  final IconData icon;
  final String text;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    // ListView so pull-to-refresh still works on empty/error states.
    return ListView(
      padding: const EdgeInsets.all(32),
      children: [
        const SizedBox(height: 80),
        Icon(icon, size: 48, color: Colors.black38),
        const SizedBox(height: 12),
        Text(text, textAlign: TextAlign.center),
        if (action != null) ...[const SizedBox(height: 16), Center(child: action)],
      ],
    );
  }
}

class _Skeleton extends StatelessWidget {
  const _Skeleton();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 4,
      itemBuilder: (_, _) => Container(
        height: 110,
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: HubColors.border),
        ),
      ),
    );
  }
}
