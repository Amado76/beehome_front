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
  String get welcome => 'Welcome to BeeHome';

  @override
  String get signedOutMessage =>
      'Your family workspace starts here. Sign-in will be available in the next implementation.';

  @override
  String get workspace => 'Your workspace';

  @override
  String get signedInMessage =>
      'Your session is available. Family selection will be available in a future implementation.';

  @override
  String get signOut => 'Sign out on this device';

  @override
  String get sessionError => 'Unable to open your session';

  @override
  String get sessionErrorMessage => 'Check your device storage and try again.';

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
}
