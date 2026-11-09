// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get sessionClosedInactivity => 'Sesión cerrada por inactividad.';

  @override
  String get sessionClosedInactivityFiveMin =>
      'Sesión cerrada por inactividad de 5 minutos.';

  @override
  String get enableFingerprintTitle => '¿Activar Huella Dactilar?';

  @override
  String get enableFingerprintContent =>
      '¿Deseas activar el acceso rápido con huella dactilar para las próximas veces?';

  @override
  String get noThanks => 'No, gracias';

  @override
  String get yesEnable => 'Sí, activar';

  @override
  String get biometricEnabledSuccess => 'Acceso biométrico activado con éxito.';

  @override
  String biometricEnabledError(String error) {
    return 'No se pudo activar el acceso biométrico: $error';
  }

  @override
  String errorLoadingEntries(String error) {
    return 'Error al cargar entradas: $error';
  }

  @override
  String csvImportSuccess(int count) {
    return '¡Éxito! Se han importado $count contraseñas.';
  }

  @override
  String csvImportError(String error) {
    return 'Error al importar CSV: $error';
  }

  @override
  String errorAdding(String error) {
    return 'Error al añadir: $error';
  }

  @override
  String errorUpdating(String error) {
    return 'Error al actualizar: $error';
  }

  @override
  String errorDeleting(String error) {
    return 'Error al eliminar: $error';
  }

  @override
  String copiedToClipboard(String label) {
    return '¡$label copiado al portapapeles!';
  }

  @override
  String get addCustomField => 'Añadir campo personalizado';

  @override
  String get titleRequired => 'El título es obligatorio';

  @override
  String get deleteCredentialTitle => '¿Eliminar Credencial?';

  @override
  String get deleteCredentialContent =>
      'La credencial se moverá a la papelera. Podrás recuperarla cuando quieras.';

  @override
  String get cancel => 'Cancelar';

  @override
  String get delete => 'Eliminar';

  @override
  String get manageCategories => 'Gestionar Categorías';

  @override
  String get categoryExists => 'Esta categoría ya existe.';

  @override
  String get close => 'Cerrar';

  @override
  String get renameCategory => 'Renombrar Categoría';

  @override
  String get save => 'Guardar';

  @override
  String get passwordPattern => 'Generador de Contraseñas';

  @override
  String get customPatternSaved => '¡Generador guardado con éxito!';

  @override
  String get biometricRequiredExport =>
      'La autenticación biométrica es obligatoria para exportar y no está disponible en este dispositivo.';

  @override
  String get search => 'Buscar...';

  @override
  String get editCredential => 'Editar Credencial';

  @override
  String get username => 'Usuario';

  @override
  String get password => 'Contraseña';

  @override
  String get websiteUrl => 'Sitio Web / URL';

  @override
  String get notes => 'Notas';

  @override
  String get category => 'Categoría';

  @override
  String get categoryGeneral => 'General';

  @override
  String get globalSecurityScore => 'Puntuación de Seguridad Global';

  @override
  String weakPasswordsCount(int count) {
    return '$count Contraseñas Débiles';
  }

  @override
  String get weakPasswordsSubtitle => 'Longitud menor a 8 o muy comunes';

  @override
  String get noWeakPasswords => '¡Excelente! No tienes contraseñas débiles.';

  @override
  String reusedPasswordsCount(int count) {
    return '$count Contraseñas Reutilizadas';
  }

  @override
  String get reusedPasswordsSubtitle => 'Misma contraseña en múltiples cuentas';

  @override
  String get noReusedPasswords =>
      '¡Excelente! Cada cuenta tiene una clave única.';

  @override
  String accountsUsePassword(int count) {
    return '$count cuentas usan esta clave';
  }

  @override
  String securePasswordsCount(int count) {
    return '$count Contraseñas Ultra Seguras';
  }

  @override
  String get strongPasswordsSubtitle => 'Únicas y robustas';

  @override
  String get noStrongPasswords => 'No tienes contraseñas seguras aún.';

  @override
  String get writeTitleGenerate =>
      'Por favor, escribe el título primero para generar la contraseña.';

  @override
  String get passwordGeneratorTitle => 'Generador de Contraseñas';

  @override
  String get generatorExplanation =>
      'Se generará basándose en tu patrón estructural seguro.';

  @override
  String get regenerate => 'Regenerar';

  @override
  String get accept => 'Aceptar';

  @override
  String get securityHealthTitle => 'Salud de mis Contraseñas';

  @override
  String get exportCsv => 'Exportar a CSV';

  @override
  String get exportXml => 'Exportar a XML';

  @override
  String get createMasterPassword => 'Crear Contraseña Maestra';

  @override
  String get enterMasterPassword => 'Introduce la Contraseña Maestra';

  @override
  String get registerSubtitle =>
      'Establece una contraseña fuerte para proteger tus datos. No se puede recuperar si la olvidas.';

  @override
  String get loginSubtitle =>
      'Esta contraseña se utiliza para descifrar tu base de datos local.';

  @override
  String get masterPasswordLabel => 'Contraseña Maestra';

  @override
  String get confirmPasswordLabel => 'Confirmar Contraseña';

  @override
  String get registerSave => 'Registrar y Guardar';

  @override
  String get unlock => 'Desbloquear';

  @override
  String unexpectedError(String error) {
    return 'Error inesperado: $error';
  }

  @override
  String logoutError(String error) {
    return 'Error al cerrar la sesión: $error';
  }

  @override
  String get lightTheme => 'Tema Claro';

  @override
  String get darkTheme => 'Tema Oscuro';

  @override
  String get categoryAll => 'Todos';

  @override
  String get categoryBanks => 'Bancos';

  @override
  String get categoryWebAccounts => 'Cuentas Web';

  @override
  String get categoryEmails => 'Emails';

  @override
  String get categoryForums => 'Foros';

  @override
  String get categoryRouter => 'Router';

  @override
  String get categoryStore => 'Tienda';

  @override
  String get categoryOthers => 'Otros';

  @override
  String get weakPassword => 'Contraseña débil';

  @override
  String get mediumPassword => 'Contraseña media';

  @override
  String get strongPassword => 'Contraseña fuerte';

  @override
  String get edit => 'Editar';

  @override
  String get userOrEmail => 'Usuario / Correo';

  @override
  String get website => 'Sitio Web';

  @override
  String get field => 'Campo';

  @override
  String get newCategory => 'Nueva categoría';

  @override
  String get language => 'Idioma';

  @override
  String get selectLanguage => 'Seleccionar Idioma';

  @override
  String passwordLength(int length) {
    return 'Longitud de la contraseña: $length';
  }

  @override
  String get passwordLengthHelper =>
      'Se incluirá siempre al menos una mayúscula, minúscula, número y símbolo.';

  @override
  String get newNameLabel => 'Nuevo nombre';

  @override
  String get criticalDanger => '¡PELIGRO CRÍTICO!';

  @override
  String get csvExportWarning =>
      '¡ATENCIÓN! El archivo CSV que vas a generar NO está cifrado. Cualquier persona o aplicación con acceso a tu móvil podrá ver tus contraseñas en texto plano. Se recomienda encarecidamente enviar o copiar este archivo a un lugar seguro (como tu ordenador personal) y borrarlo inmediatamente de la carpeta de Descargas de este teléfono.';

  @override
  String get understandRiskSave => 'Entiendo el riesgo, guardar';

  @override
  String get csvExportSuccessNoCount => '¡Contraseñas exportadas con éxito!';

  @override
  String csvExportError(String error) {
    return 'Error al guardar archivo: $error';
  }

  @override
  String get biometricReasonExport =>
      'Confirma tu huella dactilar para autorizar la exportación de tus contraseñas.';

  @override
  String authError(String error) {
    return 'Error de autenticación: $error';
  }

  @override
  String get authFailed => 'Autenticación biométrica fallida.';

  @override
  String get emptyKeychain => 'Llavero Vacío';

  @override
  String get emptyKeychainSubtitle =>
      'Agrega una cuenta usando el botón inferior (+) o importa un archivo CSV desde el menú superior.';

  @override
  String get noMatchesFound => 'No se encontraron coincidencias.';

  @override
  String get favoritesHeader => 'Mis Favoritos';

  @override
  String get configureFieldTitle => 'Configurar Campo';

  @override
  String get fieldNameLabel => 'Nombre';

  @override
  String get fieldValueLabel => 'Valor';

  @override
  String get addNewFieldTitle => 'Añadir nuevo campo';

  @override
  String get fieldDate => 'Fecha';

  @override
  String get fieldWebAddress => 'Dirección Web';

  @override
  String get fieldEmail => 'Email';

  @override
  String get fieldPin => 'PIN';

  @override
  String get logout => 'Cerrar Sesión';

  @override
  String get additionalNotes => 'Notas adicionales';

  @override
  String get copyTooltip => 'Copiar';

  @override
  String get deleteFieldTooltip => 'Eliminar campo';

  @override
  String get generatePasswordTooltip => 'Generar contraseña';

  @override
  String get titleOrServiceName => 'Título / Nombre del servicio';

  @override
  String get newCredential => 'Nueva Credencial';

  @override
  String checkStorageError(String error) {
    return 'Error al comprobar el estado del almacenamiento: $error';
  }

  @override
  String get fingerprintScanReason =>
      'Escanea tu huella para acceder a tu gestor de contraseñas';

  @override
  String biometricAuthError(String error) {
    return 'Error en la autenticación biométrica: $error';
  }

  @override
  String get fingerprintSetupReason =>
      'Confirma tu huella para activar el acceso biométrico';

  @override
  String get passwordEmpty => 'La contraseña no puede estar vacía.';

  @override
  String get passwordsDoNotMatch => 'Las contraseñas no coinciden.';

  @override
  String dbInitError(String error) {
    return 'Error al inicializar la base de datos: $error';
  }

  @override
  String get enterMasterPasswordPrompt =>
      'Por favor, introduce tu contraseña maestra.';

  @override
  String get incorrectPasswordError =>
      'Contraseña incorrecta. Inténtalo de nuevo.';

  @override
  String get importData => 'Importar';

  @override
  String get exportData => 'Exportar';

  @override
  String get exportToKdbx => 'Exportar a KDBX';

  @override
  String get exportToJson => 'Exportar a JSON';

  @override
  String get exportJsonRecommended =>
      'Por seguridad, te recomendamos proteger este archivo con una contraseña.';

  @override
  String get exportJsonSecureBtn => 'Exportar Json cifrado (Recomendado)';

  @override
  String get exportJsonPlainBtn => 'Exportar Json sin cifrar (No recomendado)';

  @override
  String get exportKdbxDesc =>
      'Introduce la contraseña maestra para tu nueva base de datos KeePass.\n\nEsta contraseña bloqueará el archivo .kdbx y no tiene que ser la misma que la de Cerberus.';

  @override
  String get passwordForFile => 'Contraseña para el archivo';

  @override
  String get importFormatsList =>
      'Puedes importar los siguientes formatos:\n  - KDBX\n  - 1PUX\n  - Json\n  - XML\n  - CSV';

  @override
  String get historyTitle => 'Historial de Contraseñas';

  @override
  String get historyEmpty => 'No hay contraseñas antiguas guardadas.';

  @override
  String get historyMainPassword => 'Contraseña Principal';

  @override
  String historyChangedAt(String date) {
    return 'Cambiada el $date';
  }

  @override
  String get historyCloseBtn => 'CERRAR';

  @override
  String get historyViewBtn => 'Ver historial';

  @override
  String get attachmentsTitle => 'Archivos Adjuntos';

  @override
  String get localBackupTitle => 'Copia de seguridad local';

  @override
  String get localBackupSubtitle =>
      'Crea un archivo de copia de seguridad cifrado en la ubicación que elijas, o restaura una desde un archivo.';

  @override
  String get createLocalBackup => 'Crear copia cifrada';

  @override
  String get restoreLocalBackup => 'Restaurar copia cifrada';
}
