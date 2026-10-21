// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get tagline => 'Más tranquilidad para tu familia.';

  @override
  String get workspace => 'Tu espacio';

  @override
  String get signedInMessage => 'Has iniciado sesión.';

  @override
  String get signOut => 'Salir en este dispositivo';

  @override
  String get sessionError => 'No se pudo abrir tu sesión';

  @override
  String get sessionErrorMessage =>
      'No se pudo confirmar tu sesión. Revisa la conexión y el almacenamiento del dispositivo e inténtalo de nuevo.';

  @override
  String get retry => 'Intentar de nuevo';

  @override
  String get configurationError => 'Configuración necesaria';

  @override
  String get configurationErrorMessage =>
      'Configura API_ORIGIN con un origen HTTPS válido. HTTP solo está disponible en desarrollo.';

  @override
  String get loadingSession => 'Comprobando tu sesión';

  @override
  String get splashNotebook => 'Cuaderno digital';

  @override
  String get splashTagline => 'el cuaderno digital de la familia';

  @override
  String get splashPreparing => 'Preparando tus cuadernos...';

  @override
  String get splashOrganizing => 'Organizando el día de tu familia...';

  @override
  String get splashLoading => 'Cargando lecciones y recuerdos...';

  @override
  String get splashReady => '¡Todo listo con amor!';

  @override
  String get splashHoney => 'Produciendo un poquito de miel...';

  @override
  String get splashFooter => 'educación en casa y rutinas';

  @override
  String get splashFooterCaption => 'Un hogar para tus recuerdos';

  @override
  String get language => 'Idioma';

  @override
  String get deviceLanguage => 'Usar idioma del dispositivo';

  @override
  String get languagePortuguese => 'Portugués (Brasil)';

  @override
  String get languageEnglish => 'Inglés';

  @override
  String get languageSpanish => 'Español';

  @override
  String get languageEstonian => 'Estonio';

  @override
  String get languageSaveError =>
      'No se pudo guardar el idioma. Selecciónalo de nuevo para reintentar.';

  @override
  String get authTagline => 'Tu rincón de estudios y rutina familiar';

  @override
  String get authLogin => 'Entrar';

  @override
  String get authRegister => 'Crear cuenta';

  @override
  String get authName => 'Tu nombre';

  @override
  String get authEmail => 'Correo electrónico';

  @override
  String get authPassword => 'Contraseña';

  @override
  String get authConfirmPassword => 'Confirmar contraseña';

  @override
  String get authPasswordMismatch => 'Las contraseñas no coinciden.';

  @override
  String get authCurrentPassword => 'Contraseña actual';

  @override
  String get authNewPassword => 'Nueva contraseña';

  @override
  String get authEmailHint => 'familia@beehome.app';

  @override
  String get authNameHint => 'Ana Silva';

  @override
  String get authForgot => 'olvidé mi contraseña';

  @override
  String get authRemember => 'Recordar acceso en este dispositivo';

  @override
  String get authEnter => 'Entrar';

  @override
  String get authCreate => 'Crear nuestro rincón';

  @override
  String get authRecover => 'Recuperar contraseña';

  @override
  String get authReset => 'Restablecer contraseña';

  @override
  String get authChange => 'Cambiar contraseña';

  @override
  String get authBack => 'Volver a entrar';

  @override
  String get authRecoveryHelp =>
      'Introduce tu correo para solicitar instrucciones de recuperación.';

  @override
  String get authResetHelp => 'Elige una nueva contraseña para tu cuenta.';

  @override
  String get authPolicy =>
      'Usa entre 8 y 128 caracteres, con una mayúscula, un número y un carácter especial.';

  @override
  String get authRequired => 'Completa este campo.';

  @override
  String get authInvalidEmail =>
      'Introduce un correo válido (hasta 254 caracteres).';

  @override
  String get authNameLength => 'Usa hasta 120 caracteres.';

  @override
  String get authPasswordLength => 'Usa hasta 128 caracteres.';

  @override
  String get authInvalidCredentials =>
      'Correo o contraseña incorrectos. Inténtalo de nuevo.';

  @override
  String get authDuplicateEmail =>
      'Este correo ya está registrado. Entra o recupera tu contraseña.';

  @override
  String get authInvalidReset =>
      'Este enlace es inválido o ha caducado. Solicita otro.';

  @override
  String authRateLimit(int seconds) {
    String _temp0 = intl.Intl.pluralLogic(
      seconds,
      locale: localeName,
      other: '$seconds segundos',
      one: '1 segundo',
    );
    return 'Demasiados intentos. Espera $_temp0 antes de intentarlo de nuevo.';
  }

  @override
  String get authNetworkError =>
      'No se pudo conectar. Revisa tu conexión e inténtalo de nuevo.';

  @override
  String get authUnknownError => 'No se pudo completar. Inténtalo de nuevo.';

  @override
  String get authUncertain =>
      'No se pudo confirmar el resultado. Intenta entrar o recuperar tu contraseña antes de volver a enviar.';

  @override
  String get authUncertainChange =>
      'No se pudo confirmar el cambio. Entra con la nueva contraseña o usa la recuperación.';

  @override
  String get authStorageError =>
      'No se pudo actualizar la sesión en este dispositivo. Inténtalo de nuevo.';

  @override
  String get authRegistered =>
      '¡Cuenta creada! Entra con tu correo y contraseña.';

  @override
  String get authRecoverySent =>
      'Si existe una cuenta para este correo, se enviarán instrucciones de recuperación.';

  @override
  String get authPasswordReset =>
      'Contraseña restablecida. Entra con tu nueva contraseña.';

  @override
  String get authPasswordChanged =>
      'Contraseña cambiada. Entra de nuevo con tu nueva contraseña.';

  @override
  String get authSignedOut => 'Has cerrado sesión.';

  @override
  String get authLocalSignOut =>
      'Sesión cerrada en este dispositivo. No se pudo confirmar el cierre en el servidor.';

  @override
  String get authShowPassword => 'Mostrar contraseña';

  @override
  String get authHidePassword => 'Ocultar contraseña';

  @override
  String get authDayTip =>
      'Consejo del día: Organiza la rutina compartiendo las tareas de estudio con la colmena familiar.';

  @override
  String get authNotebook => 'CUADERNO DIGITAL • BEEHOME';

  @override
  String get authWorking => 'Espera…';

  @override
  String get authCancel => 'Cancelar';

  @override
  String get authInvalidCurrentPassword =>
      'La contraseña actual es incorrecta. Inténtalo de nuevo o recupera tu contraseña.';

  @override
  String get authForbidden => 'No tienes permiso para completar esta acción.';

  @override
  String get authSessionExpired => 'Tu sesión ha caducado. Entra de nuevo.';

  @override
  String get authOrContinue => 'o continúa con';

  @override
  String get authProviderSoon =>
      'El acceso con Google y Apple estará disponible pronto. Continúa con tu correo.';

  @override
  String get homeNotebook => 'cuaderno familiar';

  @override
  String get homeToday => 'Hoy';

  @override
  String get homeChooseFamily => 'Elige tu familia';

  @override
  String get homeNoFamilies => '¿Empezamos tu cuaderno familiar?';

  @override
  String get homeCreateFamily => 'Crear familia';

  @override
  String get homeFamilySettings => 'Configurar familia';

  @override
  String get homeSwitchFamily => 'Cambiar familia';

  @override
  String get homeFamilyName => 'Nombre de la familia';

  @override
  String get homeFamilyNameHint => 'Familia Silva';

  @override
  String homeFieldExample(String example) {
    return 'Ej.: $example';
  }

  @override
  String get homeTaskTitleHint => 'Ordenar los juguetes';

  @override
  String get homeSave => 'Guardar';

  @override
  String get homeCancel => 'Cancelar';

  @override
  String get homeMore => 'Cargar más';

  @override
  String get homeError => 'No se pudo cargar. Inténtalo de nuevo.';

  @override
  String get homeDenied => 'No tienes permiso para este cambio.';

  @override
  String get homeUncertain =>
      'No pudimos confirmar el cambio. Revisa los datos recargados antes de volver a intentarlo.';

  @override
  String get homeReviewed => 'Revisé los datos';

  @override
  String get homeNoProfiles =>
      'Añade a las personas de tu familia para organizar el día.';

  @override
  String get homeAddProfile => 'Añadir persona';

  @override
  String get homeEditProfile => 'Editar persona';

  @override
  String get homeProfileName => 'Nombre';

  @override
  String get homeAdult => 'Adulto';

  @override
  String get homeChild => 'Niño/a';

  @override
  String get homeBirthDate => 'Nacimiento (AAAA-MM-DD, opcional)';

  @override
  String get homeInvalidDate => 'Introduce una fecha válida que no sea futura.';

  @override
  String get homeProfileColor => 'Color del perfil';

  @override
  String get homeBoard => 'Pizarra libre';

  @override
  String get homeWrite => 'Escribir';

  @override
  String get homeEdit => 'Editar';

  @override
  String get homeView => 'Ver pizarra';

  @override
  String get homeEmptyBoard =>
      'Un espacio para escribir a mano. Toca para empezar.';

  @override
  String get homeTasks => 'Rutina y tareas';

  @override
  String get homeNoTasks => 'No hay tareas para hoy.';

  @override
  String get homeAddTask => 'Añadir tarea';

  @override
  String get homeTaskTitle => '¿Qué vamos a hacer?';

  @override
  String get homeRefreshTasks => 'Actualizar tareas del plan';

  @override
  String get homeFinalized =>
      'Día finalizado. Las tareas están disponibles para consultar.';

  @override
  String get homeFooter => 'Cuaderno Digital Familiar';

  @override
  String get drawingPen => 'Lápiz';

  @override
  String get drawingErase => 'Borrar trazo';

  @override
  String get drawingUndo => 'Deshacer';

  @override
  String get drawingRedo => 'Rehacer';

  @override
  String get drawingClear => 'Limpiar pizarra';

  @override
  String get drawingClearConfirm => '¿Borrar todos los trazos de esta pizarra?';

  @override
  String get drawingSaving => 'Guardando…';

  @override
  String get drawingSaved => 'Guardado';

  @override
  String get drawingUnsaved => 'Cambios sin guardar';

  @override
  String get drawingSaveError =>
      'No se pudo guardar. Tu escritura sigue aquí; inténtalo de nuevo.';

  @override
  String get drawingConflict =>
      'La pizarra cambió en otro dispositivo. Elige qué versión conservar.';

  @override
  String get drawingKeepLocal => 'Guardar mi versión';

  @override
  String get drawingUseRemote => 'Usar versión del servidor';

  @override
  String get drawingReplaceConfirm =>
      'Esta opción reemplaza la otra versión. ¿Continuar?';

  @override
  String get drawingLeaveConfirm =>
      'Hay escritura sin guardar. Guarda antes de salir o descarta los cambios.';

  @override
  String get drawingDiscard => 'Descartar';

  @override
  String get drawingLimit =>
      'La pizarra alcanzó su límite de tamaño. Borra algunos trazos para continuar.';

  @override
  String get drawingWidth => 'Grosor';

  @override
  String get drawingSurface => 'Área de escritura a mano';

  @override
  String homeProgress(int completed, int total) {
    return '$completed de $total completadas';
  }

  @override
  String get homeCompletionColor => 'Color de tareas completadas';

  @override
  String get homeDefault => 'Predeterminado';

  @override
  String get familySetupTitle => 'Tu familia';

  @override
  String get familySetupIntro =>
      'Ponle un nombre a tu familia y añade a sus integrantes.';

  @override
  String get familySetupMembers => 'Miembros de la familia';

  @override
  String get familySetupNewMember => 'Nuevo miembro';

  @override
  String get familySetupEditMember => 'Editar miembro';

  @override
  String get familySetupCustomColor => 'Elegir color pastel';

  @override
  String get familySetupHue => 'Tono';

  @override
  String get familySetupSoftness => 'Suavidad';

  @override
  String get familySetupDone => 'Finalizar';

  @override
  String get familySetupProfile => 'Perfil';

  @override
  String get familySetupCompletedTask => 'Tarea completada';

  @override
  String get familySetupFooter => 'BeeHome · Cuaderno digital familiar';

  @override
  String get familySetupCreateHint =>
      'El nombre de la familia se guardará al añadir el primer miembro.';

  @override
  String get familySetupRemoveMember => 'Eliminar miembro';

  @override
  String get familySetupRemoveHint =>
      '¿Eliminar este miembro de la familia? El perfil se desactivará y se conservará su historial.';

  @override
  String get familySetupBirthDate => 'Nacimiento (opcional)';

  @override
  String familySetupAge(int age) {
    String _temp0 = intl.Intl.pluralLogic(
      age,
      locale: localeName,
      other: '$age años',
      one: '1 año',
    );
    return '$_temp0';
  }

  @override
  String get deviceConnectionWifi => 'Wi-Fi conectado';

  @override
  String get deviceConnectionMobile => 'Red móvil';

  @override
  String get deviceConnectionEthernet => 'Ethernet conectada';

  @override
  String get deviceConnectionOther => 'Otra conexión de red';

  @override
  String get deviceConnectionOffline => 'Sin conexión de red';

  @override
  String get deviceConnectionUnknown => 'Conexión no disponible';

  @override
  String deviceBatteryLevel(int level) {
    return 'Batería: $level%';
  }

  @override
  String get deviceBatteryCharging => 'Cargando';

  @override
  String get deviceBatteryUnknown => 'Batería no disponible';

  @override
  String get homeNewNote => 'Nueva nota';

  @override
  String get homeNoteTitle => 'Título de la nota';

  @override
  String get homeSwipeNotes => 'Desliza para ver notas ›';

  @override
  String get homeNoteTitleOptional => 'Título';

  @override
  String get noteDelete => 'Eliminar nota';

  @override
  String get noteDeleteConfirm => '¿Eliminar esta nota?';

  @override
  String get noteDeleteError =>
      'No se pudo eliminar la nota. Inténtalo de nuevo.';

  @override
  String homeActiveNotes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count notas activas',
      one: '1 nota activa',
    );
    return '$_temp0';
  }

  @override
  String get homeTaskRepeatDaily => 'Repetir diariamente';

  @override
  String get homeTaskProfiles => 'Perfiles';

  @override
  String get homeTaskSelectProfile => 'Selecciona al menos un perfil.';

  @override
  String get homeTaskRetryRemaining =>
      'Es posible que algunas asignaciones ya se hayan guardado. Guarda de nuevo para continuar con los perfiles restantes.';

  @override
  String get homeTaskUncertain =>
      'No se pudo confirmar el resultado de una operación. Revisa las tareas de todos los perfiles seleccionados antes de crear las asignaciones que falten. Confirmar esta revisión cierra el formulario.';

  @override
  String get homeTaskNewLabel => 'Nueva tarea';

  @override
  String get homeTaskBack => 'Volver al inicio';

  @override
  String get homeTaskAssignees => '¿Quién lo hará?';

  @override
  String get homeTaskSave => 'Guardar tarea';

  @override
  String homeTaskSelectionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count seleccionados',
      one: '1 seleccionado',
    );
    return '$_temp0';
  }
}
