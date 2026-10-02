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
  String get welcome => 'Bienvenido a BeeHome';

  @override
  String get signedOutMessage =>
      'El espacio de tu familia comienza aquí. El inicio de sesión estará disponible en la próxima implementación.';

  @override
  String get workspace => 'Tu espacio';

  @override
  String get signedInMessage =>
      'Tu sesión está disponible. La selección de familia estará disponible en una próxima implementación.';

  @override
  String get signOut => 'Salir en este dispositivo';

  @override
  String get sessionError => 'No se pudo abrir tu sesión';

  @override
  String get sessionErrorMessage =>
      'Comprueba el almacenamiento del dispositivo e inténtalo de nuevo.';

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
}
