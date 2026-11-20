// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Tamil (`ta`).
class AppLocalizationsTa extends AppLocalizations {
  AppLocalizationsTa([String locale = 'ta']) : super(locale);

  @override
  String get appTitle => 'SriBees Hub';

  @override
  String get language => 'மொழி';

  @override
  String get loadError =>
      'செயலிகளின் பட்டியலை ஏற்ற முடியவில்லை. இணையத்தைச் சரிபார்க்கவும்.';

  @override
  String get retry => 'மீண்டும் முயற்சிக்கவும்';

  @override
  String get empty => 'இன்னும் காட்ட செயலிகள் இல்லை.';

  @override
  String get install => 'நிறுவு';

  @override
  String get update => 'புதுப்பி';

  @override
  String get open => 'திற';

  @override
  String get getOnPlay => 'Play இல் பெறுக';

  @override
  String get getOnAppStore => 'App Store இல் பெறுக';

  @override
  String installed(String version) {
    return 'நிறுவப்பட்டது $version';
  }

  @override
  String latest(String version) {
    return 'சமீபத்தியது $version';
  }

  @override
  String get notInstalled => 'நிறுவப்படவில்லை';

  @override
  String downloading(int percent) {
    return 'பதிவிறக்குகிறது $percent%';
  }

  @override
  String get installing => 'நிறுவுகிறது…';

  @override
  String installDone(String app) {
    return '$app தயார்.';
  }

  @override
  String get permTitle => 'செயலிகளை நிறுவ SriBees Hub க்கு அனுமதி கொடுங்கள்';

  @override
  String get permBody =>
      'Android ஒருமுறை மட்டுமே கேட்கும். அனுமதி என்பதைத் தட்டி, \"Allow from this source\" ஐ இயக்கி, திரும்பி வாருங்கள்.';

  @override
  String get permAllow => 'அனுமதி';

  @override
  String get staffBadge => 'ஊழியர்';

  @override
  String updatesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count புதுப்பிப்புகள் உள்ளன',
      one: '1 புதுப்பிப்பு உள்ளது',
    );
    return '$_temp0';
  }

  @override
  String hubVersion(String version) {
    return 'SriBees Hub $version';
  }

  @override
  String get errDownload =>
      'பதிவிறக்கம் தோல்வி. இணையத்தைச் சரிபார்த்து மீண்டும் முயற்சிக்கவும்.';

  @override
  String get errTampered =>
      'இந்தக் கோப்பு பாதுகாப்புச் சோதனையில் தேறவில்லை, எனவே நிறுவப்படவில்லை.';

  @override
  String get errOtherSource =>
      'இந்தச் செயலி ஏற்கனவே வேறு இடத்திலிருந்து (எ.கா. Play) நிறுவப்பட்டுள்ளது. ஒருமுறை நீக்கிவிட்டு SriBees Hub இலிருந்து நிறுவவும்.';

  @override
  String get errCancelled => 'நிறுவல் ரத்து செய்யப்பட்டது.';

  @override
  String get errBlocked => 'Android இந்த நிறுவலைத் தடுத்தது.';

  @override
  String get errStorage => 'தொலைபேசியில் போதுமான இடம் இல்லை.';

  @override
  String get errIncompatible => 'இந்தத் தொலைபேசியில் இந்தப் பதிப்பு இயங்காது.';

  @override
  String get errFailed => 'நிறுவல் தோல்வி. மீண்டும் முயற்சிக்கவும்.';
}
