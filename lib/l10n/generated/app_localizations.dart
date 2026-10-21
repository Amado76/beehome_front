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

  /// No description provided for @homeNotebook.
  ///
  /// In en, this message translates to:
  /// **'family notebook'**
  String get homeNotebook;

  /// No description provided for @homeToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get homeToday;

  /// No description provided for @homeChooseFamily.
  ///
  /// In en, this message translates to:
  /// **'Choose your family'**
  String get homeChooseFamily;

  /// No description provided for @homeNoFamilies.
  ///
  /// In en, this message translates to:
  /// **'Ready to start your family notebook?'**
  String get homeNoFamilies;

  /// No description provided for @homeCreateFamily.
  ///
  /// In en, this message translates to:
  /// **'Create family'**
  String get homeCreateFamily;

  /// No description provided for @homeFamilySettings.
  ///
  /// In en, this message translates to:
  /// **'Family settings'**
  String get homeFamilySettings;

  /// No description provided for @homeSwitchFamily.
  ///
  /// In en, this message translates to:
  /// **'Switch family'**
  String get homeSwitchFamily;

  /// No description provided for @homeFamilyName.
  ///
  /// In en, this message translates to:
  /// **'Family name'**
  String get homeFamilyName;

  /// No description provided for @homeFamilyNameHint.
  ///
  /// In en, this message translates to:
  /// **'Silva Family'**
  String get homeFamilyNameHint;

  /// No description provided for @homeFieldExample.
  ///
  /// In en, this message translates to:
  /// **'e.g. {example}'**
  String homeFieldExample(String example);

  /// No description provided for @homeTaskTitleHint.
  ///
  /// In en, this message translates to:
  /// **'Tidy up the toys'**
  String get homeTaskTitleHint;

  /// No description provided for @homeSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get homeSave;

  /// No description provided for @homeCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get homeCancel;

  /// No description provided for @homeMore.
  ///
  /// In en, this message translates to:
  /// **'Load more'**
  String get homeMore;

  /// No description provided for @homeError.
  ///
  /// In en, this message translates to:
  /// **'Could not load. Please try again.'**
  String get homeError;

  /// No description provided for @homeDenied.
  ///
  /// In en, this message translates to:
  /// **'You do not have permission to make this change.'**
  String get homeDenied;

  /// No description provided for @homeUncertain.
  ///
  /// In en, this message translates to:
  /// **'We could not confirm the change. Review the reloaded data before trying again.'**
  String get homeUncertain;

  /// No description provided for @homeReviewed.
  ///
  /// In en, this message translates to:
  /// **'I reviewed the data'**
  String get homeReviewed;

  /// No description provided for @homeNoProfiles.
  ///
  /// In en, this message translates to:
  /// **'Add your family members to organize the day.'**
  String get homeNoProfiles;

  /// No description provided for @homeAddProfile.
  ///
  /// In en, this message translates to:
  /// **'Add person'**
  String get homeAddProfile;

  /// No description provided for @homeEditProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit person'**
  String get homeEditProfile;

  /// No description provided for @homeProfileName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get homeProfileName;

  /// No description provided for @homeAdult.
  ///
  /// In en, this message translates to:
  /// **'Adult'**
  String get homeAdult;

  /// No description provided for @homeChild.
  ///
  /// In en, this message translates to:
  /// **'Child'**
  String get homeChild;

  /// No description provided for @homeBirthDate.
  ///
  /// In en, this message translates to:
  /// **'Birth date (YYYY-MM-DD, optional)'**
  String get homeBirthDate;

  /// No description provided for @homeInvalidDate.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid date that is not in the future.'**
  String get homeInvalidDate;

  /// No description provided for @homeProfileColor.
  ///
  /// In en, this message translates to:
  /// **'Profile color'**
  String get homeProfileColor;

  /// No description provided for @homeBoard.
  ///
  /// In en, this message translates to:
  /// **'Free board'**
  String get homeBoard;

  /// No description provided for @homeWrite.
  ///
  /// In en, this message translates to:
  /// **'Write'**
  String get homeWrite;

  /// No description provided for @homeEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get homeEdit;

  /// No description provided for @homeView.
  ///
  /// In en, this message translates to:
  /// **'View board'**
  String get homeView;

  /// No description provided for @homeEmptyBoard.
  ///
  /// In en, this message translates to:
  /// **'A space for handwriting. Tap to begin.'**
  String get homeEmptyBoard;

  /// No description provided for @homeTasks.
  ///
  /// In en, this message translates to:
  /// **'Routine & Tasks'**
  String get homeTasks;

  /// No description provided for @homeNoTasks.
  ///
  /// In en, this message translates to:
  /// **'No tasks for today.'**
  String get homeNoTasks;

  /// No description provided for @homeAddTask.
  ///
  /// In en, this message translates to:
  /// **'Add task'**
  String get homeAddTask;

  /// No description provided for @homeTaskTitle.
  ///
  /// In en, this message translates to:
  /// **'What shall we do?'**
  String get homeTaskTitle;

  /// No description provided for @homeRefreshTasks.
  ///
  /// In en, this message translates to:
  /// **'Refresh planned tasks'**
  String get homeRefreshTasks;

  /// No description provided for @homeFinalized.
  ///
  /// In en, this message translates to:
  /// **'Day finalized. Tasks are available to view.'**
  String get homeFinalized;

  /// No description provided for @homeFooter.
  ///
  /// In en, this message translates to:
  /// **'Digital Family Notebook'**
  String get homeFooter;

  /// No description provided for @drawingPen.
  ///
  /// In en, this message translates to:
  /// **'Pen'**
  String get drawingPen;

  /// No description provided for @drawingErase.
  ///
  /// In en, this message translates to:
  /// **'Erase stroke'**
  String get drawingErase;

  /// No description provided for @drawingUndo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get drawingUndo;

  /// No description provided for @drawingRedo.
  ///
  /// In en, this message translates to:
  /// **'Redo'**
  String get drawingRedo;

  /// No description provided for @drawingClear.
  ///
  /// In en, this message translates to:
  /// **'Clear board'**
  String get drawingClear;

  /// No description provided for @drawingClearConfirm.
  ///
  /// In en, this message translates to:
  /// **'Erase all strokes on this board?'**
  String get drawingClearConfirm;

  /// No description provided for @drawingSaving.
  ///
  /// In en, this message translates to:
  /// **'Saving…'**
  String get drawingSaving;

  /// No description provided for @drawingSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get drawingSaved;

  /// No description provided for @drawingUnsaved.
  ///
  /// In en, this message translates to:
  /// **'Unsaved changes'**
  String get drawingUnsaved;

  /// No description provided for @drawingSaveError.
  ///
  /// In en, this message translates to:
  /// **'Could not save. Your handwriting is still here; try again.'**
  String get drawingSaveError;

  /// No description provided for @drawingConflict.
  ///
  /// In en, this message translates to:
  /// **'The board changed on another device. Choose which version to keep.'**
  String get drawingConflict;

  /// No description provided for @drawingKeepLocal.
  ///
  /// In en, this message translates to:
  /// **'Save my version'**
  String get drawingKeepLocal;

  /// No description provided for @drawingUseRemote.
  ///
  /// In en, this message translates to:
  /// **'Use server version'**
  String get drawingUseRemote;

  /// No description provided for @drawingReplaceConfirm.
  ///
  /// In en, this message translates to:
  /// **'This choice replaces the other version. Continue?'**
  String get drawingReplaceConfirm;

  /// No description provided for @drawingLeaveConfirm.
  ///
  /// In en, this message translates to:
  /// **'There is unsaved handwriting. Save before leaving or discard the changes.'**
  String get drawingLeaveConfirm;

  /// No description provided for @drawingDiscard.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get drawingDiscard;

  /// No description provided for @drawingLimit.
  ///
  /// In en, this message translates to:
  /// **'The board reached its size limit. Erase some strokes before continuing.'**
  String get drawingLimit;

  /// No description provided for @drawingWidth.
  ///
  /// In en, this message translates to:
  /// **'Pen width'**
  String get drawingWidth;

  /// No description provided for @drawingSurface.
  ///
  /// In en, this message translates to:
  /// **'Handwriting area'**
  String get drawingSurface;

  /// No description provided for @homeProgress.
  ///
  /// In en, this message translates to:
  /// **'{completed} of {total} completed'**
  String homeProgress(int completed, int total);

  /// No description provided for @homeCompletionColor.
  ///
  /// In en, this message translates to:
  /// **'Completed task color'**
  String get homeCompletionColor;

  /// No description provided for @homeDefault.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get homeDefault;

  /// No description provided for @familySetupTitle.
  ///
  /// In en, this message translates to:
  /// **'Your family'**
  String get familySetupTitle;

  /// No description provided for @familySetupIntro.
  ///
  /// In en, this message translates to:
  /// **'Name your family and add the people who belong to it.'**
  String get familySetupIntro;

  /// No description provided for @familySetupMembers.
  ///
  /// In en, this message translates to:
  /// **'Family members'**
  String get familySetupMembers;

  /// No description provided for @familySetupNewMember.
  ///
  /// In en, this message translates to:
  /// **'New member'**
  String get familySetupNewMember;

  /// No description provided for @familySetupEditMember.
  ///
  /// In en, this message translates to:
  /// **'Edit member'**
  String get familySetupEditMember;

  /// No description provided for @familySetupCustomColor.
  ///
  /// In en, this message translates to:
  /// **'Choose a pastel color'**
  String get familySetupCustomColor;

  /// No description provided for @familySetupHue.
  ///
  /// In en, this message translates to:
  /// **'Hue'**
  String get familySetupHue;

  /// No description provided for @familySetupSoftness.
  ///
  /// In en, this message translates to:
  /// **'Softness'**
  String get familySetupSoftness;

  /// No description provided for @familySetupDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get familySetupDone;

  /// No description provided for @familySetupProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get familySetupProfile;

  /// No description provided for @familySetupCompletedTask.
  ///
  /// In en, this message translates to:
  /// **'Completed task'**
  String get familySetupCompletedTask;

  /// No description provided for @familySetupFooter.
  ///
  /// In en, this message translates to:
  /// **'BeeHome · Family digital notebook'**
  String get familySetupFooter;

  /// No description provided for @familySetupCreateHint.
  ///
  /// In en, this message translates to:
  /// **'Save the family name to start adding members.'**
  String get familySetupCreateHint;

  /// No description provided for @familySetupRemoveMember.
  ///
  /// In en, this message translates to:
  /// **'Remove member'**
  String get familySetupRemoveMember;

  /// No description provided for @familySetupRemoveHint.
  ///
  /// In en, this message translates to:
  /// **'Remove this family member? The profile will be deactivated; its history will be preserved.'**
  String get familySetupRemoveHint;

  /// No description provided for @familySetupBirthDate.
  ///
  /// In en, this message translates to:
  /// **'Birth date (optional)'**
  String get familySetupBirthDate;

  /// No description provided for @familySetupAge.
  ///
  /// In en, this message translates to:
  /// **'{age, plural, one{1 year} other{{age} years}}'**
  String familySetupAge(int age);

  /// No description provided for @deviceConnectionWifi.
  ///
  /// In en, this message translates to:
  /// **'Wi-Fi connected'**
  String get deviceConnectionWifi;

  /// No description provided for @deviceConnectionMobile.
  ///
  /// In en, this message translates to:
  /// **'Mobile network'**
  String get deviceConnectionMobile;

  /// No description provided for @deviceConnectionEthernet.
  ///
  /// In en, this message translates to:
  /// **'Ethernet connected'**
  String get deviceConnectionEthernet;

  /// No description provided for @deviceConnectionOther.
  ///
  /// In en, this message translates to:
  /// **'Other network connection'**
  String get deviceConnectionOther;

  /// No description provided for @deviceConnectionOffline.
  ///
  /// In en, this message translates to:
  /// **'No network connection'**
  String get deviceConnectionOffline;

  /// No description provided for @deviceConnectionUnknown.
  ///
  /// In en, this message translates to:
  /// **'Connection unavailable'**
  String get deviceConnectionUnknown;

  /// No description provided for @deviceBatteryLevel.
  ///
  /// In en, this message translates to:
  /// **'Battery: {level}%'**
  String deviceBatteryLevel(int level);

  /// No description provided for @deviceBatteryCharging.
  ///
  /// In en, this message translates to:
  /// **'Charging'**
  String get deviceBatteryCharging;

  /// No description provided for @deviceBatteryUnknown.
  ///
  /// In en, this message translates to:
  /// **'Battery unavailable'**
  String get deviceBatteryUnknown;

  /// No description provided for @homeNewNote.
  ///
  /// In en, this message translates to:
  /// **'New note'**
  String get homeNewNote;

  /// No description provided for @homeNoteTitle.
  ///
  /// In en, this message translates to:
  /// **'Note title'**
  String get homeNoteTitle;

  /// No description provided for @homeSwipeNotes.
  ///
  /// In en, this message translates to:
  /// **'Swipe to see notes ›'**
  String get homeSwipeNotes;

  /// No description provided for @homeNoteTitleOptional.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get homeNoteTitleOptional;

  /// No description provided for @noteDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete note'**
  String get noteDelete;

  /// No description provided for @noteDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete this note?'**
  String get noteDeleteConfirm;

  /// No description provided for @noteDeleteError.
  ///
  /// In en, this message translates to:
  /// **'Could not delete this note. Try again.'**
  String get noteDeleteError;

  /// No description provided for @homeActiveNotes.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 active note} other{{count} active notes}}'**
  String homeActiveNotes(int count);

  /// No description provided for @homeTaskRepeatDaily.
  ///
  /// In en, this message translates to:
  /// **'Repeat daily'**
  String get homeTaskRepeatDaily;

  /// No description provided for @homeTaskProfiles.
  ///
  /// In en, this message translates to:
  /// **'Profiles'**
  String get homeTaskProfiles;

  /// No description provided for @homeTaskSelectProfile.
  ///
  /// In en, this message translates to:
  /// **'Select at least one profile.'**
  String get homeTaskSelectProfile;

  /// No description provided for @homeTaskRetryRemaining.
  ///
  /// In en, this message translates to:
  /// **'Some assignments may already have been saved. Save again to continue with the remaining profiles.'**
  String get homeTaskRetryRemaining;

  /// No description provided for @homeTaskUncertain.
  ///
  /// In en, this message translates to:
  /// **'The result of a save could not be confirmed. Review the tasks for all selected profiles before creating any missing assignments. Confirming this review closes the form.'**
  String get homeTaskUncertain;

  /// No description provided for @homeTaskNewLabel.
  ///
  /// In en, this message translates to:
  /// **'New task'**
  String get homeTaskNewLabel;

  /// No description provided for @homeTaskBack.
  ///
  /// In en, this message translates to:
  /// **'Back to home'**
  String get homeTaskBack;

  /// No description provided for @homeTaskAssignees.
  ///
  /// In en, this message translates to:
  /// **'Who will do it?'**
  String get homeTaskAssignees;

  /// No description provided for @homeTaskSave.
  ///
  /// In en, this message translates to:
  /// **'Save task'**
  String get homeTaskSave;

  /// No description provided for @homeTaskSelectionCount.
  ///
  /// In en, this message translates to:
  /// **'{count} selected'**
  String homeTaskSelectionCount(int count);
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
