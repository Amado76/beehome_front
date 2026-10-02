// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Estonian (`et`).
class AppLocalizationsEt extends AppLocalizations {
  AppLocalizationsEt([String locale = 'et']) : super(locale);

  @override
  String get tagline => 'Rohkem rahu sinu perele.';

  @override
  String get welcome => 'Tere tulemast BeeHome’i';

  @override
  String get signedOutMessage =>
      'Sinu pere keskkond algab siit. Sisselogimine lisandub järgmises teostuses.';

  @override
  String get workspace => 'Sinu keskkond';

  @override
  String get signedInMessage =>
      'Sinu seanss on saadaval. Pere valimine lisandub tulevases teostuses.';

  @override
  String get signOut => 'Logi selles seadmes välja';

  @override
  String get sessionError => 'Seanssi ei saanud avada';

  @override
  String get sessionErrorMessage =>
      'Kontrolli seadme salvestusruumi ja proovi uuesti.';

  @override
  String get retry => 'Proovi uuesti';

  @override
  String get configurationError => 'Seadistus on vajalik';

  @override
  String get configurationErrorMessage =>
      'Määra API_ORIGIN kehtiva HTTPS-aadressiga. HTTP on saadaval ainult arenduses.';

  @override
  String get loadingSession => 'Seansi kontrollimine';

  @override
  String get splashNotebook => 'Digitaalne märkmik';

  @override
  String get splashTagline => 'pere digitaalne märkmik';

  @override
  String get splashPreparing => 'Valmistame sinu märkmikke ette...';

  @override
  String get splashOrganizing => 'Korraldame sinu pere päeva...';

  @override
  String get splashLoading => 'Laadime õppetunde ja mälestusi...';

  @override
  String get splashReady => 'Kõik on armastusega valmis!';

  @override
  String get splashHoney => 'Valmistame veidi mett...';

  @override
  String get splashFooter => 'koduõpe ja päevakava';

  @override
  String get splashFooterCaption => 'Kodu sinu mälestustele';
}
