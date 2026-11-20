// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Sinhala Sinhalese (`si`).
class AppLocalizationsSi extends AppLocalizations {
  AppLocalizationsSi([String locale = 'si']) : super(locale);

  @override
  String get appTitle => 'SriBees Hub';

  @override
  String get language => 'භාෂාව';

  @override
  String get loadError => 'App ලැයිස්තුව ගන්න බැරි වුණා. Internet එක බලන්න.';

  @override
  String get retry => 'ආයෙත් උත්සාහ කරන්න';

  @override
  String get empty => 'තවම පෙන්වන්න app නැහැ.';

  @override
  String get install => 'Install කරන්න';

  @override
  String get update => 'Update කරන්න';

  @override
  String get open => 'විවෘත කරන්න';

  @override
  String get getOnPlay => 'Play එකෙන් ගන්න';

  @override
  String get getOnAppStore => 'App Store එකෙන් ගන්න';

  @override
  String installed(String version) {
    return 'තියෙන්නේ $version';
  }

  @override
  String latest(String version) {
    return 'අලුත්ම $version';
  }

  @override
  String get notInstalled => 'Install කරලා නැහැ';

  @override
  String downloading(int percent) {
    return 'Download වෙනවා $percent%';
  }

  @override
  String get installing => 'Install වෙනවා…';

  @override
  String installDone(String app) {
    return '$app ලෑස්තියි.';
  }

  @override
  String get permTitle => 'Apps install කරන්න SriBees Hub ට ඉඩ දෙන්න';

  @override
  String get permBody =>
      'Android එක එක පාරක් විතරක් අහනවා. \"ඉඩ දෙන්න\" ඔබලා,\"Allow from this source\" on කරලා ආපහු එන්න.';

  @override
  String get permAllow => 'ඉඩ දෙන්න';

  @override
  String get staffBadge => 'Staff';

  @override
  String updatesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'update $countක් තියෙනවා',
      one: 'update 1ක් තියෙනවා',
    );
    return '$_temp0';
  }

  @override
  String hubVersion(String version) {
    return 'SriBees Hub $version';
  }

  @override
  String get errDownload =>
      'Download වුණේ නැහැ. Internet එක බලලා ආයෙත් උත්සාහ කරන්න.';

  @override
  String get errTampered =>
      'මේ file එක ආරක්ෂක පරීක්ෂාව පාස් වුණේ නැහැ. ඒ නිසා install කළේ නැහැ.';

  @override
  String get errOtherSource =>
      'මේ app එක දැනටමත් වෙන තැනකින් (උදා: Play) install කරලා තියෙන්නේ. එක පාරක් uninstall කරලා SriBees Hub එකෙන් install කරන්න.';

  @override
  String get errCancelled => 'Install එක නැවැත්තුවා.';

  @override
  String get errBlocked => 'Android මේ install එක නැවැත්තුවා.';

  @override
  String get errStorage => 'Phone එකේ ඉඩ මදි.';

  @override
  String get errIncompatible => 'මේ phone එකේ මේ version එක වැඩ කරන්නේ නැහැ.';

  @override
  String get errFailed => 'Install වුණේ නැහැ. ආයෙත් උත්සාහ කරන්න.';
}
