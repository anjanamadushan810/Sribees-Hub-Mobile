import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_si.dart';
import 'app_localizations_ta.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('si'),
    Locale('ta'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'SriBees Hub'**
  String get appTitle;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @loadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load the app list. Check your internet.'**
  String get loadError;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @empty.
  ///
  /// In en, this message translates to:
  /// **'No apps to show yet.'**
  String get empty;

  /// No description provided for @install.
  ///
  /// In en, this message translates to:
  /// **'Install'**
  String get install;

  /// No description provided for @update.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update;

  /// No description provided for @open.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get open;

  /// No description provided for @getOnPlay.
  ///
  /// In en, this message translates to:
  /// **'Get on Play'**
  String get getOnPlay;

  /// No description provided for @getOnAppStore.
  ///
  /// In en, this message translates to:
  /// **'Get on App Store'**
  String get getOnAppStore;

  /// No description provided for @installed.
  ///
  /// In en, this message translates to:
  /// **'Installed {version}'**
  String installed(String version);

  /// No description provided for @latest.
  ///
  /// In en, this message translates to:
  /// **'Latest {version}'**
  String latest(String version);

  /// No description provided for @notInstalled.
  ///
  /// In en, this message translates to:
  /// **'Not installed'**
  String get notInstalled;

  /// No description provided for @downloading.
  ///
  /// In en, this message translates to:
  /// **'Downloading {percent}%'**
  String downloading(int percent);

  /// No description provided for @installing.
  ///
  /// In en, this message translates to:
  /// **'Installing…'**
  String get installing;

  /// No description provided for @installDone.
  ///
  /// In en, this message translates to:
  /// **'{app} is ready.'**
  String installDone(String app);

  /// No description provided for @permTitle.
  ///
  /// In en, this message translates to:
  /// **'Allow SriBees Hub to install apps'**
  String get permTitle;

  /// No description provided for @permBody.
  ///
  /// In en, this message translates to:
  /// **'Android asks once. Tap Allow, switch on \"Allow from this source\", then come back.'**
  String get permBody;

  /// No description provided for @permAllow.
  ///
  /// In en, this message translates to:
  /// **'Allow'**
  String get permAllow;

  /// No description provided for @staffBadge.
  ///
  /// In en, this message translates to:
  /// **'Staff'**
  String get staffBadge;

  /// No description provided for @updatesCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 update available} other{{count} updates available}}'**
  String updatesCount(int count);

  /// No description provided for @hubVersion.
  ///
  /// In en, this message translates to:
  /// **'SriBees Hub {version}'**
  String hubVersion(String version);

  /// No description provided for @errDownload.
  ///
  /// In en, this message translates to:
  /// **'Download failed. Check your internet and try again.'**
  String get errDownload;

  /// No description provided for @errTampered.
  ///
  /// In en, this message translates to:
  /// **'This file did not pass the safety check, so it was not installed.'**
  String get errTampered;

  /// No description provided for @errOtherSource.
  ///
  /// In en, this message translates to:
  /// **'This app is already installed from another source (for example Play). Uninstall it once, then install it from SriBees Hub.'**
  String get errOtherSource;

  /// No description provided for @errCancelled.
  ///
  /// In en, this message translates to:
  /// **'Install cancelled.'**
  String get errCancelled;

  /// No description provided for @errBlocked.
  ///
  /// In en, this message translates to:
  /// **'Android blocked this install.'**
  String get errBlocked;

  /// No description provided for @errStorage.
  ///
  /// In en, this message translates to:
  /// **'Not enough free space on the phone.'**
  String get errStorage;

  /// No description provided for @errIncompatible.
  ///
  /// In en, this message translates to:
  /// **'This phone cannot run this version.'**
  String get errIncompatible;

  /// No description provided for @errFailed.
  ///
  /// In en, this message translates to:
  /// **'Install failed. Try again.'**
  String get errFailed;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'si', 'ta'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'si':
      return AppLocalizationsSi();
    case 'ta':
      return AppLocalizationsTa();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
