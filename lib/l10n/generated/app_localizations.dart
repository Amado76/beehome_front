import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_et.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
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

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
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
    Locale('es'),
    Locale('et'),
    Locale('pt'),
  ];

  /// No description provided for @tagline.
  ///
  /// In en, this message translates to:
  /// **'A little more calm for your family.'**
  String get tagline;

  /// No description provided for @workspace.
  ///
  /// In en, this message translates to:
  /// **'Your workspace'**
  String get workspace;

  /// No description provided for @signedInMessage.
  ///
  /// In en, this message translates to:
  /// **'You are signed in.'**
  String get signedInMessage;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out on this device'**
  String get signOut;

  /// No description provided for @sessionError.
  ///
  /// In en, this message translates to:
  /// **'Unable to open your session'**
  String get sessionError;

  /// No description provided for @sessionErrorMessage.
  ///
  /// In en, this message translates to:
  /// **'Could not confirm your session. Check your connection and device storage, then try again.'**
  String get sessionErrorMessage;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get retry;

  /// No description provided for @configurationError.
  ///
  /// In en, this message translates to:
  /// **'Configuration required'**
  String get configurationError;

  /// No description provided for @configurationErrorMessage.
  ///
  /// In en, this message translates to:
  /// **'Set API_ORIGIN to a valid HTTPS origin. HTTP is available only in development.'**
  String get configurationErrorMessage;

  /// No description provided for @loadingSession.
  ///
  /// In en, this message translates to:
  /// **'Checking your session'**
  String get loadingSession;

  /// No description provided for @splashNotebook.
  ///
  /// In en, this message translates to:
  /// **'Digital notebook'**
  String get splashNotebook;

  /// No description provided for @splashTagline.
  ///
  /// In en, this message translates to:
  /// **'your family’s digital notebook'**
  String get splashTagline;

  /// No description provided for @splashPreparing.
  ///
  /// In en, this message translates to:
  /// **'Preparing your notebooks...'**
  String get splashPreparing;

  /// No description provided for @splashOrganizing.
  ///
  /// In en, this message translates to:
  /// **'Organizing your family’s day...'**
  String get splashOrganizing;

  /// No description provided for @splashLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading lessons and memories...'**
  String get splashLoading;

  /// No description provided for @splashReady.
  ///
  /// In en, this message translates to:
  /// **'All ready with love!'**
  String get splashReady;

  /// No description provided for @splashHoney.
  ///
  /// In en, this message translates to:
  /// **'Making a little honey...'**
  String get splashHoney;

  /// No description provided for @splashFooter.
  ///
  /// In en, this message translates to:
  /// **'homeschool & routines'**
  String get splashFooter;

  /// No description provided for @splashFooterCaption.
  ///
  /// In en, this message translates to:
  /// **'A home for your memories'**
  String get splashFooterCaption;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @deviceLanguage.
  ///
  /// In en, this message translates to:
  /// **'Use device language'**
  String get deviceLanguage;

  /// No description provided for @languagePortuguese.
  ///
  /// In en, this message translates to:
  /// **'Portuguese (Brazil)'**
  String get languagePortuguese;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageSpanish.
  ///
  /// In en, this message translates to:
  /// **'Spanish'**
  String get languageSpanish;

  /// No description provided for @languageEstonian.
  ///
  /// In en, this message translates to:
  /// **'Estonian'**
  String get languageEstonian;

  /// No description provided for @languageSaveError.
  ///
  /// In en, this message translates to:
  /// **'Could not save your language. Please select it again to retry.'**
  String get languageSaveError;

  /// No description provided for @authTagline.
  ///
  /// In en, this message translates to:
  /// **'Your cozy corner for studies and family routines'**
  String get authTagline;

  /// No description provided for @authLogin.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get authLogin;

  /// No description provided for @authRegister.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get authRegister;

  /// No description provided for @authName.
  ///
  /// In en, this message translates to:
  /// **'Your name'**
  String get authName;

  /// No description provided for @authEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get authEmail;

  /// No description provided for @authPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get authPassword;

  /// No description provided for @authConfirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get authConfirmPassword;

  /// No description provided for @authPasswordMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match.'**
  String get authPasswordMismatch;

  /// No description provided for @authCurrentPassword.
  ///
  /// In en, this message translates to:
  /// **'Current password'**
  String get authCurrentPassword;

  /// No description provided for @authNewPassword.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get authNewPassword;

  /// No description provided for @authEmailHint.
  ///
  /// In en, this message translates to:
  /// **'family@beehome.app'**
  String get authEmailHint;

  /// No description provided for @authNameHint.
  ///
  /// In en, this message translates to:
  /// **'Ana Silva'**
  String get authNameHint;

  /// No description provided for @authForgot.
  ///
  /// In en, this message translates to:
  /// **'forgot my password'**
  String get authForgot;

  /// No description provided for @authRemember.
  ///
  /// In en, this message translates to:
  /// **'Remember me on this device'**
  String get authRemember;

  /// No description provided for @authEnter.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get authEnter;

  /// No description provided for @authCreate.
  ///
  /// In en, this message translates to:
  /// **'Create our family space'**
  String get authCreate;

  /// No description provided for @authRecover.
  ///
  /// In en, this message translates to:
  /// **'Recover password'**
  String get authRecover;

  /// No description provided for @authReset.
  ///
  /// In en, this message translates to:
  /// **'Reset password'**
  String get authReset;

  /// No description provided for @authChange.
  ///
  /// In en, this message translates to:
  /// **'Change password'**
  String get authChange;

  /// No description provided for @authBack.
  ///
  /// In en, this message translates to:
  /// **'Back to sign in'**
  String get authBack;

  /// No description provided for @authRecoveryHelp.
  ///
  /// In en, this message translates to:
  /// **'Enter your email to request password recovery instructions.'**
  String get authRecoveryHelp;

  /// No description provided for @authResetHelp.
  ///
  /// In en, this message translates to:
  /// **'Choose a new password for your account.'**
  String get authResetHelp;

  /// No description provided for @authPolicy.
  ///
  /// In en, this message translates to:
  /// **'Use 8–128 characters, with an uppercase letter, a number and a special character.'**
  String get authPolicy;

  /// No description provided for @authRequired.
  ///
  /// In en, this message translates to:
  /// **'This field is required.'**
  String get authRequired;

  /// No description provided for @authInvalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email (up to 254 characters).'**
  String get authInvalidEmail;

  /// No description provided for @authNameLength.
  ///
  /// In en, this message translates to:
  /// **'Use up to 120 characters.'**
  String get authNameLength;

  /// No description provided for @authPasswordLength.
  ///
  /// In en, this message translates to:
  /// **'Use up to 128 characters.'**
  String get authPasswordLength;

  /// No description provided for @authInvalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'Incorrect email or password. Please try again.'**
  String get authInvalidCredentials;

  /// No description provided for @authDuplicateEmail.
  ///
  /// In en, this message translates to:
  /// **'This email is already registered. Sign in or recover your password.'**
  String get authDuplicateEmail;

  /// No description provided for @authInvalidReset.
  ///
  /// In en, this message translates to:
  /// **'This recovery link is invalid or expired. Request a new link.'**
  String get authInvalidReset;

  /// No description provided for @authRateLimit.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Wait {seconds, plural, one {1 second} other {{seconds} seconds}} before trying again.'**
  String authRateLimit(int seconds);

  /// No description provided for @authNetworkError.
  ///
  /// In en, this message translates to:
  /// **'Could not connect. Check your connection and try again.'**
  String get authNetworkError;

  /// No description provided for @authUnknownError.
  ///
  /// In en, this message translates to:
  /// **'Could not complete the request. Please try again.'**
  String get authUnknownError;

  /// No description provided for @authUncertain.
  ///
  /// In en, this message translates to:
  /// **'We could not confirm the result. Try signing in or use password recovery before submitting again.'**
  String get authUncertain;

  /// No description provided for @authUncertainChange.
  ///
  /// In en, this message translates to:
  /// **'We could not confirm the password change. Sign in with your new password or use recovery.'**
  String get authUncertainChange;

  /// No description provided for @authStorageError.
  ///
  /// In en, this message translates to:
  /// **'Could not update your session on this device. Please try again.'**
  String get authStorageError;

  /// No description provided for @authRegistered.
  ///
  /// In en, this message translates to:
  /// **'Account created! Sign in with your email and password.'**
  String get authRegistered;

  /// No description provided for @authRecoverySent.
  ///
  /// In en, this message translates to:
  /// **'If an account exists for this email, password recovery instructions will be sent.'**
  String get authRecoverySent;

  /// No description provided for @authPasswordReset.
  ///
  /// In en, this message translates to:
  /// **'Password reset. Sign in with your new password.'**
  String get authPasswordReset;

  /// No description provided for @authPasswordChanged.
  ///
  /// In en, this message translates to:
  /// **'Password changed. Sign in again with your new password.'**
  String get authPasswordChanged;

  /// No description provided for @authSignedOut.
  ///
  /// In en, this message translates to:
  /// **'Signed out.'**
  String get authSignedOut;

  /// No description provided for @authLocalSignOut.
  ///
  /// In en, this message translates to:
  /// **'Signed out on this device. Server session revocation could not be confirmed.'**
  String get authLocalSignOut;

  /// No description provided for @authShowPassword.
  ///
  /// In en, this message translates to:
  /// **'Show password'**
  String get authShowPassword;

  /// No description provided for @authHidePassword.
  ///
  /// In en, this message translates to:
  /// **'Hide password'**
  String get authHidePassword;

  /// No description provided for @authDayTip.
  ///
  /// In en, this message translates to:
  /// **'Tip of the day: Keep your routine organized by sharing study tasks with your family hive.'**
  String get authDayTip;

  /// No description provided for @authNotebook.
  ///
  /// In en, this message translates to:
  /// **'DIGITAL NOTEBOOK • BEEHOME'**
  String get authNotebook;

  /// No description provided for @authWorking.
  ///
  /// In en, this message translates to:
  /// **'Please wait…'**
  String get authWorking;

  /// No description provided for @authCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get authCancel;

  /// No description provided for @authInvalidCurrentPassword.
  ///
  /// In en, this message translates to:
  /// **'The current password is incorrect. Try again or recover your password.'**
  String get authInvalidCurrentPassword;

  /// No description provided for @authForbidden.
  ///
  /// In en, this message translates to:
  /// **'You do not have permission to complete this action.'**
  String get authForbidden;

  /// No description provided for @authSessionExpired.
  ///
  /// In en, this message translates to:
  /// **'Your session has expired. Sign in again.'**
  String get authSessionExpired;

  /// No description provided for @authOrContinue.
  ///
  /// In en, this message translates to:
  /// **'or continue with'**
  String get authOrContinue;

  /// No description provided for @authProviderSoon.
  ///
  /// In en, this message translates to:
  /// **'Google and Apple sign-in is coming soon. Continue with your email.'**
  String get authProviderSoon;
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
      <String>['en', 'es', 'et', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'et':
      return AppLocalizationsEt();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
