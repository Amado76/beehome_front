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
  String get workspace => 'Seu espaço';

  @override
  String get signedInMessage => 'Você entrou na sua conta.';

  @override
  String get signOut => 'Sair neste dispositivo';

  @override
  String get sessionError => 'Não foi possível abrir sua sessão';

  @override
  String get sessionErrorMessage =>
      'Não foi possível confirmar sua sessão. Confira sua conexão e o armazenamento do dispositivo e tente novamente.';

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

  @override
  String get language => 'Idioma';

  @override
  String get deviceLanguage => 'Usar idioma do dispositivo';

  @override
  String get languagePortuguese => 'Português (Brasil)';

  @override
  String get languageEnglish => 'Inglês';

  @override
  String get languageSpanish => 'Espanhol';

  @override
  String get languageEstonian => 'Estoniano';

  @override
  String get languageSaveError =>
      'Não foi possível salvar o idioma. Selecione novamente para tentar de novo.';

  @override
  String get authTagline => 'Seu cantinho de estudos e rotina familiar';

  @override
  String get authLogin => 'Entrar';

  @override
  String get authRegister => 'Criar conta';

  @override
  String get authName => 'Seu nome';

  @override
  String get authEmail => 'E-mail';

  @override
  String get authPassword => 'Senha';

  @override
  String get authConfirmPassword => 'Confirmar senha';

  @override
  String get authPasswordMismatch => 'As senhas não coincidem.';

  @override
  String get authCurrentPassword => 'Senha atual';

  @override
  String get authNewPassword => 'Nova senha';

  @override
  String get authEmailHint => 'familia@beehome.app';

  @override
  String get authNameHint => 'Ana Silva';

  @override
  String get authForgot => 'esqueci minha senha';

  @override
  String get authRemember => 'Lembrar acesso neste dispositivo';

  @override
  String get authEnter => 'Entrar';

  @override
  String get authCreate => 'Criar nosso cantinho';

  @override
  String get authRecover => 'Recuperar senha';

  @override
  String get authReset => 'Redefinir senha';

  @override
  String get authChange => 'Alterar senha';

  @override
  String get authBack => 'Voltar para entrar';

  @override
  String get authRecoveryHelp =>
      'Informe seu e-mail para solicitar instruções de recuperação da senha.';

  @override
  String get authResetHelp => 'Escolha uma nova senha para sua conta.';

  @override
  String get authPolicy =>
      'Use de 8 a 128 caracteres, com uma letra maiúscula, um número e um caractere especial.';

  @override
  String get authRequired => 'Preencha este campo.';

  @override
  String get authInvalidEmail =>
      'Informe um e-mail válido (até 254 caracteres).';

  @override
  String get authNameLength => 'Use até 120 caracteres.';

  @override
  String get authPasswordLength => 'Use até 128 caracteres.';

  @override
  String get authInvalidCredentials =>
      'E-mail ou senha incorretos. Tente novamente.';

  @override
  String get authDuplicateEmail =>
      'Este e-mail já está cadastrado. Entre ou recupere sua senha.';

  @override
  String get authInvalidReset =>
      'Este link de recuperação é inválido ou expirou. Solicite um novo link.';

  @override
  String authRateLimit(int seconds) {
    String _temp0 = intl.Intl.pluralLogic(
      seconds,
      locale: localeName,
      other: '$seconds segundos',
      one: '1 segundo',
    );
    return 'Muitas tentativas. Aguarde $_temp0 para tentar novamente.';
  }

  @override
  String get authNetworkError =>
      'Não foi possível conectar. Confira sua conexão e tente novamente.';

  @override
  String get authUnknownError => 'Não foi possível concluir. Tente novamente.';

  @override
  String get authUncertain =>
      'Não foi possível confirmar o resultado. Tente entrar ou recuperar sua senha antes de enviar novamente.';

  @override
  String get authUncertainChange =>
      'Não foi possível confirmar a alteração. Tente entrar com a nova senha ou use a recuperação.';

  @override
  String get authStorageError =>
      'Não foi possível atualizar sua sessão neste dispositivo. Tente novamente.';

  @override
  String get authRegistered => 'Conta criada! Entre com seu e-mail e senha.';

  @override
  String get authRecoverySent =>
      'Se existir uma conta para este e-mail, serão enviadas instruções de recuperação da senha.';

  @override
  String get authPasswordReset => 'Senha redefinida. Entre com sua nova senha.';

  @override
  String get authPasswordChanged =>
      'Senha alterada. Entre novamente com sua nova senha.';

  @override
  String get authSignedOut => 'Você saiu da sua conta.';

  @override
  String get authLocalSignOut =>
      'Você saiu neste dispositivo. Não foi possível confirmar o encerramento da sessão no servidor.';

  @override
  String get authShowPassword => 'Mostrar senha';

  @override
  String get authHidePassword => 'Ocultar senha';

  @override
  String get authDayTip =>
      'Dica do dia: Mantenha a rotina organizada compartilhando as tarefas de estudo com a colmeia da família.';

  @override
  String get authNotebook => 'CADERNO DIGITAL • BEEHOME';

  @override
  String get authWorking => 'Aguarde…';

  @override
  String get authCancel => 'Cancelar';

  @override
  String get authInvalidCurrentPassword =>
      'A senha atual está incorreta. Tente novamente ou recupere sua senha.';

  @override
  String get authForbidden => 'Você não tem permissão para concluir esta ação.';

  @override
  String get authSessionExpired => 'Sua sessão expirou. Entre novamente.';

  @override
  String get authOrContinue => 'ou continue com';

  @override
  String get authProviderSoon =>
      'Login com Google e Apple em breve. Continue com seu e-mail.';
}
