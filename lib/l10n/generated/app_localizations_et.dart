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

  @override
  String get homeNotebook => 'pere märkmik';

  @override
  String get homeToday => 'Täna';

  @override
  String get homeChooseFamily => 'Vali oma pere';

  @override
  String get homeNoFamilies => 'Alustame pere märkmikku?';

  @override
  String get homeCreateFamily => 'Loo pere';

  @override
  String get homeFamilySettings => 'Pere seaded';

  @override
  String get homeSwitchFamily => 'Vaheta pere';

  @override
  String get homeFamilyName => 'Pere nimi';

  @override
  String get homeFamilyNameHint => 'Tamme pere';

  @override
  String homeFieldExample(String example) {
    return 'Nt $example';
  }

  @override
  String get homeTaskTitleHint => 'Mänguasjade koristamine';

  @override
  String get homeSave => 'Salvesta';

  @override
  String get homeCancel => 'Tühista';

  @override
  String get homeMore => 'Laadi veel';

  @override
  String get homeError => 'Laadimine ebaõnnestus. Proovi uuesti.';

  @override
  String get homeDenied => 'Sul pole selle muudatuse jaoks õigust.';

  @override
  String get homeUncertain =>
      'Muudatust ei saanud kinnitada. Vaata uuesti laaditud andmed üle enne uut katset.';

  @override
  String get homeReviewed => 'Vaatasin andmed üle';

  @override
  String get homeNoProfiles => 'Lisa pereliikmed, et päeva korraldada.';

  @override
  String get homeAddProfile => 'Lisa inimene';

  @override
  String get homeEditProfile => 'Muuda inimest';

  @override
  String get homeProfileName => 'Nimi';

  @override
  String get homeAdult => 'Täiskasvanu';

  @override
  String get homeChild => 'Laps';

  @override
  String get homeBirthDate => 'Sünnikuupäev (AAAA-KK-PP, valikuline)';

  @override
  String get homeInvalidDate => 'Sisesta kehtiv kuupäev, mis pole tulevikus.';

  @override
  String get homeProfileColor => 'Profiili värv';

  @override
  String get homeBoard => 'Vaba tahvel';

  @override
  String get homeWrite => 'Kirjuta';

  @override
  String get homeEdit => 'Muuda';

  @override
  String get homeView => 'Vaata tahvlit';

  @override
  String get homeEmptyBoard =>
      'Koht käsitsi kirjutamiseks. Alustamiseks puuduta.';

  @override
  String get homeTasks => 'Rutiin ja ülesanded';

  @override
  String get homeNoTasks => 'Tänaseks ülesandeid pole.';

  @override
  String get homeAddTask => 'Lisa ülesanne';

  @override
  String get homeTaskTitle => 'Mida me teeme?';

  @override
  String get homeRefreshTasks => 'Värskenda plaani ülesandeid';

  @override
  String get homeFinalized => 'Päev on lõpetatud. Ülesandeid saab vaadata.';

  @override
  String get homeFooter => 'Digitaalne pere märkmik';

  @override
  String get drawingPen => 'Pliiats';

  @override
  String get drawingErase => 'Kustuta joon';

  @override
  String get drawingUndo => 'Võta tagasi';

  @override
  String get drawingRedo => 'Tee uuesti';

  @override
  String get drawingClear => 'Tühjenda tahvel';

  @override
  String get drawingClearConfirm => 'Kas kustutada selle tahvli kõik jooned?';

  @override
  String get drawingSaving => 'Salvestamine…';

  @override
  String get drawingSaved => 'Salvestatud';

  @override
  String get drawingUnsaved => 'Salvestamata muudatused';

  @override
  String get drawingSaveError =>
      'Salvestamine ebaõnnestus. Kirjutatu on alles; proovi uuesti.';

  @override
  String get drawingConflict =>
      'Tahvel muutus teises seadmes. Vali, milline versioon säilitada.';

  @override
  String get drawingKeepLocal => 'Salvesta minu versioon';

  @override
  String get drawingUseRemote => 'Kasuta serveri versiooni';

  @override
  String get drawingReplaceConfirm =>
      'See valik asendab teise versiooni. Kas jätkata?';

  @override
  String get drawingLeaveConfirm =>
      'Osa kirjutatust on salvestamata. Salvesta enne lahkumist või loobu muudatustest.';

  @override
  String get drawingDiscard => 'Loobu';

  @override
  String get drawingLimit =>
      'Tahvel jõudis suuruse piirini. Jätkamiseks kustuta mõned jooned.';

  @override
  String get drawingWidth => 'Joone paksus';

  @override
  String get drawingSurface => 'Käsitsi kirjutamise ala';

  @override
  String homeProgress(int completed, int total) {
    return '$total ülesandest $completed tehtud';
  }

  @override
  String get homeCompletionColor => 'Tehtud ülesannete värv';

  @override
  String get homeDefault => 'Vaikimisi';

  @override
  String get familySetupTitle => 'Sinu pere';

  @override
  String get familySetupIntro => 'Anna perele nimi ja lisa pereliikmed.';

  @override
  String get familySetupMembers => 'Pereliikmed';

  @override
  String get familySetupNewMember => 'Uus pereliige';

  @override
  String get familySetupEditMember => 'Muuda pereliiget';

  @override
  String get familySetupCustomColor => 'Vali pastellvärv';

  @override
  String get familySetupHue => 'Toon';

  @override
  String get familySetupSoftness => 'Pehmus';

  @override
  String get familySetupDone => 'Valmis';

  @override
  String get familySetupProfile => 'Profiil';

  @override
  String get familySetupCompletedTask => 'Tehtud ülesanne';

  @override
  String get familySetupFooter => 'BeeHome · Pere digitaalne märkmik';

  @override
  String get familySetupCreateHint =>
      'Pere nimi salvestatakse esimese liikme lisamisel.';

  @override
  String get familySetupRemoveMember => 'Eemalda pereliige';

  @override
  String get familySetupRemoveHint =>
      'Kas eemaldada see pereliige? Profiil muutub mitteaktiivseks ja ajalugu säilib.';

  @override
  String get familySetupBirthDate => 'Sünnikuupäev (valikuline)';

  @override
  String familySetupAge(int age) {
    String _temp0 = intl.Intl.pluralLogic(
      age,
      locale: localeName,
      other: '$age aastat',
      one: '1 aasta',
    );
    return '$_temp0';
  }

  @override
  String get deviceConnectionWifi => 'Wi-Fi ühendatud';

  @override
  String get deviceConnectionMobile => 'Mobiilivõrk';

  @override
  String get deviceConnectionEthernet => 'Ethernet ühendatud';

  @override
  String get deviceConnectionOther => 'Muu võrguühendus';

  @override
  String get deviceConnectionOffline => 'Võrguühendus puudub';

  @override
  String get deviceConnectionUnknown => 'Ühendus pole saadaval';

  @override
  String deviceBatteryLevel(int level) {
    return 'Aku: $level%';
  }

  @override
  String get deviceBatteryCharging => 'Laadimine';

  @override
  String get deviceBatteryUnknown => 'Aku pole saadaval';

  @override
  String get homeNewNote => 'Uus märge';

  @override
  String get homeNoteTitle => 'Märkme pealkiri';

  @override
  String get homeSwipeNotes => 'Märkmete nägemiseks libista ›';

  @override
  String get homeNoteTitleOptional => 'Pealkiri';

  @override
  String get noteDelete => 'Kustuta märge';

  @override
  String get noteDeleteConfirm => 'Kas kustutada see märge?';

  @override
  String get noteDeleteError =>
      'Märkme kustutamine ebaõnnestus. Proovi uuesti.';

  @override
  String homeActiveNotes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count aktiivset märget',
      one: '1 aktiivne märge',
    );
    return '$_temp0';
  }

  @override
  String get homeTaskRepeatDaily => 'Korda iga päev';

  @override
  String get homeTaskProfiles => 'Profiilid';

  @override
  String get homeTaskSelectProfile => 'Vali vähemalt üks profiil.';

  @override
  String get homeTaskRetryRemaining =>
      'Mõned määramised võivad olla juba salvestatud. Ülejäänud profiilidega jätkamiseks salvesta uuesti.';

  @override
  String get homeTaskUncertain =>
      'Salvestamise tulemust ei saanud kinnitada. Enne puuduvate määramiste loomist kontrolli kõigi valitud profiilide ülesandeid. Ülevaatuse kinnitamine sulgeb vormi.';

  @override
  String get homeTaskNewLabel => 'Uus ülesanne';

  @override
  String get homeTaskBack => 'Tagasi avalehele';

  @override
  String get homeTaskAssignees => 'Kes seda teeb?';

  @override
  String get homeTaskSave => 'Salvesta ülesanne';

  @override
  String homeTaskSelectionCount(int count) {
    return '$count valitud';
  }
}
