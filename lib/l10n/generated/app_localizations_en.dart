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

  @override
  String get homeNotebook => 'family notebook';

  @override
  String get homeToday => 'Today';

  @override
  String get homeChooseFamily => 'Choose your family';

  @override
  String get homeNoFamilies => 'Ready to start your family notebook?';

  @override
  String get homeCreateFamily => 'Create family';

  @override
  String get homeFamilySettings => 'Family settings';

  @override
  String get homeSwitchFamily => 'Switch family';

  @override
  String get homeFamilyName => 'Family name';

  @override
  String get homeFamilyNameHint => 'Silva Family';

  @override
  String homeFieldExample(String example) {
    return 'e.g. $example';
  }

  @override
  String get homeTaskTitleHint => 'Tidy up the toys';

  @override
  String get homeSave => 'Save';

  @override
  String get homeCancel => 'Cancel';

  @override
  String get homeMore => 'Load more';

  @override
  String get homeError => 'Could not load. Please try again.';

  @override
  String get homeDenied => 'You do not have permission to make this change.';

  @override
  String get homeUncertain =>
      'We could not confirm the change. Review the reloaded data before trying again.';

  @override
  String get homeReviewed => 'I reviewed the data';

  @override
  String get homeNoProfiles => 'Add your family members to organize the day.';

  @override
  String get homeAddProfile => 'Add person';

  @override
  String get homeEditProfile => 'Edit person';

  @override
  String get homeProfileName => 'Name';

  @override
  String get homeAdult => 'Adult';

  @override
  String get homeChild => 'Child';

  @override
  String get homeBirthDate => 'Birth date (YYYY-MM-DD, optional)';

  @override
  String get homeInvalidDate => 'Enter a valid date that is not in the future.';

  @override
  String get homeProfileColor => 'Profile color';

  @override
  String get homeBoard => 'Free board';

  @override
  String get homeWrite => 'Write';

  @override
  String get homeEdit => 'Edit';

  @override
  String get homeView => 'View board';

  @override
  String get homeEmptyBoard => 'A space for handwriting. Tap to begin.';

  @override
  String get homeTasks => 'Routine & Tasks';

  @override
  String get homeNoTasks => 'No tasks for today.';

  @override
  String get homeAddTask => 'Add task';

  @override
  String get homeTaskTitle => 'What shall we do?';

  @override
  String get homeRefreshTasks => 'Refresh planned tasks';

  @override
  String get homeFinalized => 'Day finalized. Tasks are available to view.';

  @override
  String get homeFooter => 'Digital Family Notebook';

  @override
  String get drawingPen => 'Pen';

  @override
  String get drawingErase => 'Erase stroke';

  @override
  String get drawingUndo => 'Undo';

  @override
  String get drawingRedo => 'Redo';

  @override
  String get drawingClear => 'Clear board';

  @override
  String get drawingClearConfirm => 'Erase all strokes on this board?';

  @override
  String get drawingSaving => 'Saving…';

  @override
  String get drawingSaved => 'Saved';

  @override
  String get drawingUnsaved => 'Unsaved changes';

  @override
  String get drawingSaveError =>
      'Could not save. Your handwriting is still here; try again.';

  @override
  String get drawingConflict =>
      'The board changed on another device. Choose which version to keep.';

  @override
  String get drawingKeepLocal => 'Save my version';

  @override
  String get drawingUseRemote => 'Use server version';

  @override
  String get drawingReplaceConfirm =>
      'This choice replaces the other version. Continue?';

  @override
  String get drawingLeaveConfirm =>
      'There is unsaved handwriting. Save before leaving or discard the changes.';

  @override
  String get drawingDiscard => 'Discard';

  @override
  String get drawingLimit =>
      'The board reached its size limit. Erase some strokes before continuing.';

  @override
  String get drawingWidth => 'Pen width';

  @override
  String get drawingSurface => 'Handwriting area';

  @override
  String homeProgress(int completed, int total) {
    return '$completed of $total completed';
  }

  @override
  String get homeCompletionColor => 'Completed task color';

  @override
  String get homeDefault => 'Default';

  @override
  String get familySetupTitle => 'Your family';

  @override
  String get familySetupIntro =>
      'Name your family and add the people who belong to it.';

  @override
  String get familySetupMembers => 'Family members';

  @override
  String get familySetupNewMember => 'New member';

  @override
  String get familySetupEditMember => 'Edit member';

  @override
  String get familySetupCustomColor => 'Choose a pastel color';

  @override
  String get familySetupHue => 'Hue';

  @override
  String get familySetupSoftness => 'Softness';

  @override
  String get familySetupDone => 'Done';

  @override
  String get familySetupProfile => 'Profile';

  @override
  String get familySetupCompletedTask => 'Completed task';

  @override
  String get familySetupFooter => 'BeeHome · Family digital notebook';

  @override
  String get familySetupCreateHint =>
      'Save the family name to start adding members.';

  @override
  String get familySetupRemoveMember => 'Remove member';

  @override
  String get familySetupRemoveHint =>
      'Remove this family member? The profile will be deactivated; its history will be preserved.';

  @override
  String get familySetupBirthDate => 'Birth date (optional)';

  @override
  String familySetupAge(int age) {
    String _temp0 = intl.Intl.pluralLogic(
      age,
      locale: localeName,
      other: '$age years',
      one: '1 year',
    );
    return '$_temp0';
  }

  @override
  String get deviceConnectionWifi => 'Wi-Fi connected';

  @override
  String get deviceConnectionMobile => 'Mobile network';

  @override
  String get deviceConnectionEthernet => 'Ethernet connected';

  @override
  String get deviceConnectionOther => 'Other network connection';

  @override
  String get deviceConnectionOffline => 'No network connection';

  @override
  String get deviceConnectionUnknown => 'Connection unavailable';

  @override
  String deviceBatteryLevel(int level) {
    return 'Battery: $level%';
  }

  @override
  String get deviceBatteryCharging => 'Charging';

  @override
  String get deviceBatteryUnknown => 'Battery unavailable';

  @override
  String get homeNewNote => 'New note';

  @override
  String get homeNoteTitle => 'Note title';

  @override
  String get homeSwipeNotes => 'Swipe to see notes ›';

  @override
  String get homeNoteTitleOptional => 'Title';

  @override
  String get noteDelete => 'Delete note';

  @override
  String get noteDeleteConfirm => 'Delete this note?';

  @override
  String get noteDeleteError => 'Could not delete this note. Try again.';

  @override
  String homeActiveNotes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count active notes',
      one: '1 active note',
    );
    return '$_temp0';
  }

  @override
  String get homeTaskRepeatDaily => 'Repeat daily';

  @override
  String get homeTaskProfiles => 'Profiles';

  @override
  String get homeTaskSelectProfile => 'Select at least one profile.';

  @override
  String get homeTaskRetryRemaining =>
      'Some assignments may already have been saved. Save again to continue with the remaining profiles.';

  @override
  String get homeTaskUncertain =>
      'The result of a save could not be confirmed. Review the tasks for all selected profiles before creating any missing assignments. Confirming this review closes the form.';

  @override
  String get homeTaskNewLabel => 'New task';

  @override
  String get homeTaskBack => 'Back to home';

  @override
  String get homeTaskAssignees => 'Who will do it?';

  @override
  String get homeTaskSave => 'Save task';

  @override
  String homeTaskSelectionCount(int count) {
    return '$count selected';
  }
}
