import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/catalog.dart';
import '../../core/installer.dart';

final installerProvider = Provider<Installer>((ref) => Installer());
final catalogRepoProvider = Provider<CatalogRepository>((ref) => CatalogRepository());

/// One row on the Hub screen: catalog entry + what is on this phone.
class AppRow {
  AppRow(this.app, this.installed);
  final HubApp app;
  final InstalledInfo? installed;

  bool get isInstalled => installed != null;
  bool get hasUpdate =>
      app.kind == DeliveryKind.apk &&
      installed != null &&
      app.versionCode != null &&
      installed!.versionCode < app.versionCode!;
}

/// The Hub lists itself in the catalog so it can update itself.
const hubPackage = 'com.sribees.hub';

/// Catalog + what is on this phone -> rows to show (pure, unit-tested).
/// The Hub's own row appears only when an update for it is waiting, and then first.
List<AppRow> buildRows(List<HubApp> apps, Map<String, InstalledInfo?> installed) {
  final rows = <AppRow>[];
  for (final a in apps) {
    final row = AppRow(a, installed[a.package]);
    if (a.package == hubPackage) {
      if (row.hasUpdate) rows.insert(0, row);
      continue;
    }
    rows.add(row);
  }
  return rows;
}

final appsProvider = FutureProvider<List<AppRow>>((ref) async {
  final apps = await ref.watch(catalogRepoProvider).fetch();
  final installer = ref.watch(installerProvider);
  final installed = <String, InstalledInfo?>{};
  // iPhone: no installs, only App Store links.
  if (Platform.isAndroid) {
    for (final a in apps) {
      installed[a.package] = await installer.installed(a.package);
    }
  }
  return buildRows(apps, installed);
});

/// Per-package progress: null = idle, 0..1 = downloading, 2 = installing.
class ProgressNotifier extends Notifier<Map<String, double>> {
  @override
  Map<String, double> build() => const {};

  void set(String package, double value) => state = {...state, package: value};

  void clear(String package) => state = {...state}..remove(package);
}

final progressProvider =
    NotifierProvider<ProgressNotifier, Map<String, double>>(ProgressNotifier.new);

/// Language picked in the Hub (null = follow the phone).
class LocaleNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void choose(String? lang) => state = lang;
}

final localeProvider = NotifierProvider<LocaleNotifier, String?>(LocaleNotifier.new);
