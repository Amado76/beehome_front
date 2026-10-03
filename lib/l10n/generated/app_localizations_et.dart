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
  String get workspace => 'Sinu keskkond';

  @override
  String get signedInMessage => 'Oled sisse logitud.';

  @override
  String get signOut => 'Logi selles seadmes välja';

  @override
  String get sessionError => 'Seanssi ei saanud avada';

  @override
  String get sessionErrorMessage =>
      'Seanssi ei saanud kinnitada. Kontrolli ühendust ja seadme salvestusruumi ning proovi uuesti.';

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

  @override
  String get language => 'Keel';

  @override
  String get deviceLanguage => 'Kasuta seadme keelt';

  @override
  String get languagePortuguese => 'Portugali (Brasiilia)';

  @override
  String get languageEnglish => 'Inglise';

  @override
  String get languageSpanish => 'Hispaania';

  @override
  String get languageEstonian => 'Eesti';

  @override
  String get languageSaveError =>
      'Keele salvestamine ebaõnnestus. Uuesti proovimiseks vali keel uuesti.';

  @override
  String get authTagline => 'Sinu hubane õpingute ja pere argipäeva paik';

  @override
  String get authLogin => 'Logi sisse';

  @override
  String get authRegister => 'Loo konto';

  @override
  String get authName => 'Sinu nimi';

  @override
  String get authEmail => 'E-posti aadress';

  @override
  String get authPassword => 'Parool';

  @override
  String get authConfirmPassword => 'Kinnita parool';

  @override
  String get authPasswordMismatch => 'Paroolid ei ühti.';

  @override
  String get authCurrentPassword => 'Praegune parool';

  @override
  String get authNewPassword => 'Uus parool';

  @override
  String get authEmailHint => 'pere@beehome.app';

  @override
  String get authNameHint => 'Anna Tamm';

  @override
  String get authForgot => 'unustasin parooli';

  @override
  String get authRemember => 'Jäta sisselogimine selles seadmes meelde';

  @override
  String get authEnter => 'Logi sisse';

  @override
  String get authCreate => 'Loo meie kodunurk';

  @override
  String get authRecover => 'Taasta parool';

  @override
  String get authReset => 'Määra uus parool';

  @override
  String get authChange => 'Muuda parooli';

  @override
  String get authBack => 'Tagasi sisselogimise juurde';

  @override
  String get authRecoveryHelp =>
      'Sisesta oma e-posti aadress, et saada parooli taastamise juhised.';

  @override
  String get authResetHelp => 'Vali oma kontole uus parool.';

  @override
  String get authPolicy =>
      'Kasuta 8–128 märki, sealhulgas suurtähte, numbrit ja erimärki.';

  @override
  String get authRequired => 'Täida see väli.';

  @override
  String get authInvalidEmail =>
      'Sisesta kehtiv e-posti aadress (kuni 254 märki).';

  @override
  String get authNameLength => 'Kasuta kuni 120 märki.';

  @override
  String get authPasswordLength => 'Kasuta kuni 128 märki.';

  @override
  String get authInvalidCredentials =>
      'Vale e-posti aadress või parool. Proovi uuesti.';

  @override
  String get authDuplicateEmail =>
      'See e-posti aadress on juba registreeritud. Logi sisse või taasta parool.';

  @override
  String get authInvalidReset =>
      'Taastamislink on vigane või aegunud. Taotle uut linki.';

  @override
  String authRateLimit(int seconds) {
    return 'Liiga palju katseid. Oota $seconds sekundit ja proovi uuesti.';
  }

  @override
  String get authNetworkError =>
      'Ühendamine ebaõnnestus. Kontrolli ühendust ja proovi uuesti.';

  @override
  String get authUnknownError => 'Toiming ebaõnnestus. Proovi uuesti.';

  @override
  String get authUncertain =>
      'Tulemust ei saanud kinnitada. Proovi sisse logida või parooli taastada enne uuesti saatmist.';

  @override
  String get authUncertainChange =>
      'Paroolimuudatust ei saanud kinnitada. Logi sisse uue parooliga või taasta parool.';

  @override
  String get authStorageError =>
      'Seadme seanssi ei saanud uuendada. Proovi uuesti.';

  @override
  String get authRegistered =>
      'Konto loodud! Logi sisse oma e-posti aadressi ja parooliga.';

  @override
  String get authRecoverySent =>
      'Kui selle e-posti aadressiga konto on olemas, saadetakse parooli taastamise juhised.';

  @override
  String get authPasswordReset =>
      'Uus parool määratud. Logi sisse uue parooliga.';

  @override
  String get authPasswordChanged =>
      'Parool muudetud. Logi uuesti sisse uue parooliga.';

  @override
  String get authSignedOut => 'Oled välja logitud.';

  @override
  String get authLocalSignOut =>
      'Oled selles seadmes välja logitud. Serveri seansi lõpetamist ei saanud kinnitada.';

  @override
  String get authShowPassword => 'Näita parooli';

  @override
  String get authHidePassword => 'Peida parool';

  @override
  String get authDayTip =>
      'Päeva nõuanne: Hoia päevakava korras, jagades õppeülesandeid oma perega.';

  @override
  String get authNotebook => 'DIGITAALNE MÄRKMIK • BEEHOME';

  @override
  String get authWorking => 'Palun oota…';

  @override
  String get authCancel => 'Tühista';

  @override
  String get authInvalidCurrentPassword =>
      'Praegune parool on vale. Proovi uuesti või taasta parool.';

  @override
  String get authForbidden => 'Sul pole selle toimingu jaoks õigusi.';

  @override
  String get authSessionExpired => 'Seanss on aegunud. Logi uuesti sisse.';

  @override
  String get authOrContinue => 'või jätka kontoga';

  @override
  String get authProviderSoon =>
      'Google’i ja Apple’i sisselogimine lisandub peagi. Jätka e-postiga.';
}
