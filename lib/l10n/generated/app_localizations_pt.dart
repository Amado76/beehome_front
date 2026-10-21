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

  @override
  String get homeNotebook => 'caderno da família';

  @override
  String get homeToday => 'Hoje';

  @override
  String get homeChooseFamily => 'Escolha sua família';

  @override
  String get homeNoFamilies => 'Vamos começar seu caderno familiar?';

  @override
  String get homeCreateFamily => 'Criar família';

  @override
  String get homeFamilySettings => 'Configurar família';

  @override
  String get homeSwitchFamily => 'Trocar família';

  @override
  String get homeFamilyName => 'Nome da família';

  @override
  String get homeFamilyNameHint => 'Família Silva';

  @override
  String homeFieldExample(String example) {
    return 'Ex.: $example';
  }

  @override
  String get homeTaskTitleHint => 'Arrumar os brinquedos';

  @override
  String get homeSave => 'Salvar';

  @override
  String get homeCancel => 'Cancelar';

  @override
  String get homeMore => 'Carregar mais';

  @override
  String get homeError => 'Não foi possível carregar. Tente novamente.';

  @override
  String get homeDenied => 'Você não tem permissão para esta alteração.';

  @override
  String get homeUncertain =>
      'Não conseguimos confirmar a alteração. Confira os dados recarregados antes de tentar novamente.';

  @override
  String get homeReviewed => 'Conferi os dados';

  @override
  String get homeNoProfiles =>
      'Adicione as pessoas da família para organizar o dia.';

  @override
  String get homeAddProfile => 'Adicionar pessoa';

  @override
  String get homeEditProfile => 'Editar pessoa';

  @override
  String get homeProfileName => 'Nome';

  @override
  String get homeAdult => 'Adulto';

  @override
  String get homeChild => 'Criança';

  @override
  String get homeBirthDate => 'Nascimento (AAAA-MM-DD, opcional)';

  @override
  String get homeInvalidDate => 'Use uma data válida que não esteja no futuro.';

  @override
  String get homeProfileColor => 'Cor do perfil';

  @override
  String get homeBoard => 'Lousa Livre';

  @override
  String get homeWrite => 'Escrever';

  @override
  String get homeEdit => 'Editar';

  @override
  String get homeView => 'Ver lousa';

  @override
  String get homeEmptyBoard =>
      'Um espaço para escrever à mão. Toque para começar.';

  @override
  String get homeTasks => 'Rotina & Tarefas';

  @override
  String get homeNoTasks => 'Nenhuma tarefa para hoje.';

  @override
  String get homeAddTask => 'Adicionar tarefa';

  @override
  String get homeTaskTitle => 'O que vamos fazer?';

  @override
  String get homeRefreshTasks => 'Atualizar tarefas do plano';

  @override
  String get homeFinalized =>
      'Dia finalizado. As tarefas estão disponíveis para consulta.';

  @override
  String get homeFooter => 'Caderno Digital Familiar';

  @override
  String get drawingPen => 'Caneta';

  @override
  String get drawingErase => 'Apagar traço';

  @override
  String get drawingUndo => 'Desfazer';

  @override
  String get drawingRedo => 'Refazer';

  @override
  String get drawingClear => 'Limpar lousa';

  @override
  String get drawingClearConfirm => 'Apagar todos os traços desta lousa?';

  @override
  String get drawingSaving => 'Salvando…';

  @override
  String get drawingSaved => 'Salvo';

  @override
  String get drawingUnsaved => 'Alterações não salvas';

  @override
  String get drawingSaveError =>
      'Não foi possível salvar. Sua escrita continua aqui; tente novamente.';

  @override
  String get drawingConflict =>
      'A lousa mudou em outro dispositivo. Escolha qual versão manter.';

  @override
  String get drawingKeepLocal => 'Salvar minha versão';

  @override
  String get drawingUseRemote => 'Usar versão do servidor';

  @override
  String get drawingReplaceConfirm =>
      'Esta escolha substitui a outra versão. Continuar?';

  @override
  String get drawingLeaveConfirm =>
      'Há escrita não salva. Salve antes de sair ou descarte as alterações.';

  @override
  String get drawingDiscard => 'Descartar';

  @override
  String get drawingLimit =>
      'A lousa atingiu o limite de tamanho. Apague alguns traços antes de continuar.';

  @override
  String get drawingWidth => 'Espessura';

  @override
  String get drawingSurface => 'Área de escrita à mão';

  @override
  String homeProgress(int completed, int total) {
    return '$completed de $total concluídas';
  }

  @override
  String get homeCompletionColor => 'Cor da tarefa feita';

  @override
  String get homeDefault => 'Padrão';

  @override
  String get familySetupTitle => 'Sua família';

  @override
  String get familySetupIntro =>
      'Dê um nome à família e adicione quem faz parte dela.';

  @override
  String get familySetupMembers => 'Membros da família';

  @override
  String get familySetupNewMember => 'Novo membro';

  @override
  String get familySetupEditMember => 'Editar membro';

  @override
  String get familySetupCustomColor => 'Escolher Cor';

  @override
  String get familySetupHue => 'Tom';

  @override
  String get familySetupSoftness => 'Suavidade';

  @override
  String get familySetupDone => 'Concluir';

  @override
  String get familySetupProfile => 'Perfil';

  @override
  String get familySetupCompletedTask => 'Tarefa feita';

  @override
  String get familySetupFooter => 'BeeHome · Caderno Digital Familiar';

  @override
  String get familySetupCreateHint =>
      'O nome da família será salvo ao adicionar o primeiro membro.';

  @override
  String get familySetupRemoveMember => 'Remover membro';

  @override
  String get familySetupRemoveHint =>
      'Remover este membro da família? O perfil será desativado; o histórico será preservado.';

  @override
  String get familySetupBirthDate => 'Nascimento (opcional)';

  @override
  String familySetupAge(int age) {
    String _temp0 = intl.Intl.pluralLogic(
      age,
      locale: localeName,
      other: '$age anos',
      one: '1 ano',
    );
    return '$_temp0';
  }

  @override
  String get deviceConnectionWifi => 'Wi-Fi conectado';

  @override
  String get deviceConnectionMobile => 'Rede móvel';

  @override
  String get deviceConnectionEthernet => 'Ethernet conectada';

  @override
  String get deviceConnectionOther => 'Outra conexão de rede';

  @override
  String get deviceConnectionOffline => 'Sem conexão de rede';

  @override
  String get deviceConnectionUnknown => 'Conexão indisponível';

  @override
  String deviceBatteryLevel(int level) {
    return 'Bateria: $level%';
  }

  @override
  String get deviceBatteryCharging => 'Carregando';

  @override
  String get deviceBatteryUnknown => 'Bateria indisponível';

  @override
  String get homeNewNote => 'Novo recado';

  @override
  String get homeNoteTitle => 'Título do recado';

  @override
  String get homeSwipeNotes => 'Deslize para ver recados ›';

  @override
  String get homeNoteTitleOptional => 'Título';

  @override
  String get noteDelete => 'Apagar recado';

  @override
  String get noteDeleteConfirm => 'Apagar este recado?';

  @override
  String get noteDeleteError =>
      'Não foi possível apagar o recado. Tente novamente.';

  @override
  String homeActiveNotes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count notas ativas',
      one: '1 nota ativa',
    );
    return '$_temp0';
  }

  @override
  String get homeTaskRepeatDaily => 'Repetir diariamente';

  @override
  String get homeTaskProfiles => 'Perfis';

  @override
  String get homeTaskSelectProfile => 'Selecione pelo menos um perfil.';

  @override
  String get homeTaskRetryRemaining =>
      'Algumas atribuições podem já ter sido salvas. Salve novamente para continuar com os perfis restantes.';

  @override
  String get homeTaskUncertain =>
      'Não foi possível confirmar o resultado de uma gravação. Confira as tarefas de todos os perfis selecionados antes de cadastrar as atribuições que faltarem. Confirmar esta revisão fecha o formulário.';

  @override
  String get homeTaskNewLabel => 'Nova tarefa';

  @override
  String get homeTaskBack => 'Voltar ao início';

  @override
  String get homeTaskAssignees => 'Quem vai fazer?';

  @override
  String get homeTaskSave => 'Salvar tarefa';

  @override
  String homeTaskSelectionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count selecionados',
      one: '1 selecionado',
    );
    return '$_temp0';
  }
}
