// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'SriBees Hub';

  @override
  String get language => 'Language';

  @override
  String get loadError => 'Could not load the app list. Check your internet.';

  @override
  String get retry => 'Retry';

  @override
  String get empty => 'No apps to show yet.';

  @override
  String get install => 'Install';

  @override
  String get update => 'Update';

  @override
  String get open => 'Open';

  @override
  String get getOnPlay => 'Get on Play';

  @override
  String get getOnAppStore => 'Get on App Store';

  @override
  String installed(String version) {
    return 'Installed $version';
  }

  @override
  String latest(String version) {
    return 'Latest $version';
  }

  @override
  String get notInstalled => 'Not installed';

  @override
  String downloading(int percent) {
    return 'Downloading $percent%';
  }

  @override
  String get installing => 'Installing…';

  @override
  String installDone(String app) {
    return '$app is ready.';
  }

  @override
  String get permTitle => 'Allow SriBees Hub to install apps';

  @override
  String get permBody =>
      'Android asks once. Tap Allow, switch on \"Allow from this source\", then come back.';

  @override
  String get permAllow => 'Allow';

  @override
  String get staffBadge => 'Staff';

  @override
  String updatesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count updates available',
      one: '1 update available',
    );
    return '$_temp0';
  }

  @override
  String hubVersion(String version) {
    return 'SriBees Hub $version';
  }

  @override
  String get errDownload =>
      'Download failed. Check your internet and try again.';

  @override
  String get errTampered =>
      'This file did not pass the safety check, so it was not installed.';

  @override
  String get errOtherSource =>
      'This app is already installed from another source (for example Play). Uninstall it once, then install it from SriBees Hub.';

  @override
  String get errCancelled => 'Install cancelled.';

  @override
  String get errBlocked => 'Android blocked this install.';

  @override
  String get errStorage => 'Not enough free space on the phone.';

  @override
  String get errIncompatible => 'This phone cannot run this version.';

  @override
  String get errFailed => 'Install failed. Try again.';
}
