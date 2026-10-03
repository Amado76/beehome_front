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
}
