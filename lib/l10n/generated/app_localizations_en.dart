// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get tagline => 'A little more calm for your family.';

  @override
  String get workspace => 'Your workspace';

  @override
  String get signedInMessage => 'You are signed in.';

  @override
  String get signOut => 'Sign out on this device';

  @override
  String get sessionError => 'Unable to open your session';

  @override
  String get sessionErrorMessage =>
      'Could not confirm your session. Check your connection and device storage, then try again.';

  @override
  String get retry => 'Try again';

  @override
  String get configurationError => 'Configuration required';

  @override
  String get configurationErrorMessage =>
      'Set API_ORIGIN to a valid HTTPS origin. HTTP is available only in development.';

  @override
  String get loadingSession => 'Checking your session';

  @override
  String get splashNotebook => 'Digital notebook';

  @override
  String get splashTagline => 'your family’s digital notebook';

  @override
  String get splashPreparing => 'Preparing your notebooks...';

  @override
  String get splashOrganizing => 'Organizing your family’s day...';

  @override
  String get splashLoading => 'Loading lessons and memories...';

  @override
  String get splashReady => 'All ready with love!';

  @override
  String get splashHoney => 'Making a little honey...';

  @override
  String get splashFooter => 'homeschool & routines';

  @override
  String get splashFooterCaption => 'A home for your memories';

  @override
  String get language => 'Language';

  @override
  String get deviceLanguage => 'Use device language';

  @override
  String get languagePortuguese => 'Portuguese (Brazil)';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageSpanish => 'Spanish';

  @override
  String get languageEstonian => 'Estonian';

  @override
  String get languageSaveError =>
      'Could not save your language. Please select it again to retry.';

  @override
  String get authTagline => 'Your cozy corner for studies and family routines';

  @override
  String get authLogin => 'Sign in';

  @override
  String get authRegister => 'Create account';

  @override
  String get authName => 'Your name';

  @override
  String get authEmail => 'Email';

  @override
  String get authPassword => 'Password';

  @override
  String get authConfirmPassword => 'Confirm password';

  @override
  String get authPasswordMismatch => 'Passwords do not match.';

  @override
  String get authCurrentPassword => 'Current password';

  @override
  String get authNewPassword => 'New password';

  @override
  String get authEmailHint => 'family@beehome.app';

  @override
  String get authNameHint => 'Ana Silva';

  @override
  String get authForgot => 'forgot my password';

  @override
  String get authRemember => 'Remember me on this device';

  @override
  String get authEnter => 'Sign In';

  @override
  String get authCreate => 'Create our family space';

  @override
  String get authRecover => 'Recover password';

  @override
  String get authReset => 'Reset password';

  @override
  String get authChange => 'Change password';

  @override
  String get authBack => 'Back to sign in';

  @override
  String get authRecoveryHelp =>
      'Enter your email to request password recovery instructions.';

  @override
  String get authResetHelp => 'Choose a new password for your account.';

  @override
  String get authPolicy =>
      'Use 8–128 characters, with an uppercase letter, a number and a special character.';

  @override
  String get authRequired => 'This field is required.';

  @override
  String get authInvalidEmail => 'Enter a valid email (up to 254 characters).';

  @override
  String get authNameLength => 'Use up to 120 characters.';

  @override
  String get authPasswordLength => 'Use up to 128 characters.';

  @override
  String get authInvalidCredentials =>
      'Incorrect email or password. Please try again.';

  @override
  String get authDuplicateEmail =>
      'This email is already registered. Sign in or recover your password.';

  @override
  String get authInvalidReset =>
      'This recovery link is invalid or expired. Request a new link.';

  @override
  String authRateLimit(int seconds) {
    String _temp0 = intl.Intl.pluralLogic(
      seconds,
      locale: localeName,
      other: '$seconds seconds',
      one: '1 second',
    );
    return 'Too many attempts. Wait $_temp0 before trying again.';
  }

  @override
  String get authNetworkError =>
      'Could not connect. Check your connection and try again.';

  @override
  String get authUnknownError =>
      'Could not complete the request. Please try again.';

  @override
  String get authUncertain =>
      'We could not confirm the result. Try signing in or use password recovery before submitting again.';

  @override
  String get authUncertainChange =>
      'We could not confirm the password change. Sign in with your new password or use recovery.';

  @override
  String get authStorageError =>
      'Could not update your session on this device. Please try again.';

  @override
  String get authRegistered =>
      'Account created! Sign in with your email and password.';

  @override
  String get authRecoverySent =>
      'If an account exists for this email, password recovery instructions will be sent.';

  @override
  String get authPasswordReset =>
      'Password reset. Sign in with your new password.';

  @override
  String get authPasswordChanged =>
      'Password changed. Sign in again with your new password.';

  @override
  String get authSignedOut => 'Signed out.';

  @override
  String get authLocalSignOut =>
      'Signed out on this device. Server session revocation could not be confirmed.';

  @override
  String get authShowPassword => 'Show password';

  @override
  String get authHidePassword => 'Hide password';

  @override
  String get authDayTip =>
      'Tip of the day: Keep your routine organized by sharing study tasks with your family hive.';

  @override
  String get authNotebook => 'DIGITAL NOTEBOOK • BEEHOME';

  @override
  String get authWorking => 'Please wait…';

  @override
  String get authCancel => 'Cancel';

  @override
  String get authInvalidCurrentPassword =>
      'The current password is incorrect. Try again or recover your password.';

  @override
  String get authForbidden =>
      'You do not have permission to complete this action.';

  @override
  String get authSessionExpired => 'Your session has expired. Sign in again.';

  @override
  String get authOrContinue => 'or continue with';

  @override
  String get authProviderSoon =>
      'Google and Apple sign-in is coming soon. Continue with your email.';
}
