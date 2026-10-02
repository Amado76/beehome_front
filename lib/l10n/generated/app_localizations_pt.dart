// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get tagline => 'Mais tranquilidade para sua família.';

  @override
  String get welcome => 'Boas-vindas ao BeeHome';

  @override
  String get signedOutMessage =>
      'O espaço da sua família começa aqui. O acesso estará disponível na próxima implementação.';

  @override
  String get workspace => 'Seu espaço';

  @override
  String get signedInMessage =>
      'Sua sessão está disponível. A seleção de família estará disponível em uma próxima implementação.';

  @override
  String get signOut => 'Sair neste dispositivo';

  @override
  String get sessionError => 'Não foi possível abrir sua sessão';

  @override
  String get sessionErrorMessage =>
      'Confira o armazenamento do dispositivo e tente novamente.';

  @override
  String get retry => 'Tentar novamente';

  @override
  String get configurationError => 'Configuração necessária';

  @override
  String get configurationErrorMessage =>
      'Configure API_ORIGIN com uma origem HTTPS válida. HTTP está disponível apenas em desenvolvimento.';

  @override
  String get loadingSession => 'Verificando sua sessão';

  @override
  String get splashNotebook => 'Caderno digital';

  @override
  String get splashTagline => 'caderno digital da família';

  @override
  String get splashPreparing => 'Preparando seus cadernos...';

  @override
  String get splashOrganizing => 'Organizando o dia da sua família...';

  @override
  String get splashLoading => 'Carregando lições e memórias...';

  @override
  String get splashReady => 'Tudo pronto com amor!';

  @override
  String get splashHoney => 'Produzindo um pouco de mel...';

  @override
  String get splashFooter => 'homeschool & rotina';

  @override
  String get splashFooterCaption => 'Um lar para suas memórias';
}
