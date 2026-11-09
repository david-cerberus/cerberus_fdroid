import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_it.dart';
import 'app_localizations_pl.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('it'),
    Locale('pl'),
    Locale('pt'),
  ];

  /// No description provided for @sessionClosedInactivity.
  ///
  /// In es, this message translates to:
  /// **'Sesión cerrada por inactividad.'**
  String get sessionClosedInactivity;

  /// No description provided for @sessionClosedInactivityFiveMin.
  ///
  /// In es, this message translates to:
  /// **'Sesión cerrada por inactividad de 5 minutos.'**
  String get sessionClosedInactivityFiveMin;

  /// No description provided for @enableFingerprintTitle.
  ///
  /// In es, this message translates to:
  /// **'¿Activar Huella Dactilar?'**
  String get enableFingerprintTitle;

  /// No description provided for @enableFingerprintContent.
  ///
  /// In es, this message translates to:
  /// **'¿Deseas activar el acceso rápido con huella dactilar para las próximas veces?'**
  String get enableFingerprintContent;

  /// No description provided for @noThanks.
  ///
  /// In es, this message translates to:
  /// **'No, gracias'**
  String get noThanks;

  /// No description provided for @yesEnable.
  ///
  /// In es, this message translates to:
  /// **'Sí, activar'**
  String get yesEnable;

  /// No description provided for @biometricEnabledSuccess.
  ///
  /// In es, this message translates to:
  /// **'Acceso biométrico activado con éxito.'**
  String get biometricEnabledSuccess;

  /// No description provided for @biometricEnabledError.
  ///
  /// In es, this message translates to:
  /// **'No se pudo activar el acceso biométrico: {error}'**
  String biometricEnabledError(String error);

  /// No description provided for @errorLoadingEntries.
  ///
  /// In es, this message translates to:
  /// **'Error al cargar entradas: {error}'**
  String errorLoadingEntries(String error);

  /// No description provided for @csvImportSuccess.
  ///
  /// In es, this message translates to:
  /// **'¡Éxito! Se han importado {count} contraseñas.'**
  String csvImportSuccess(int count);

  /// No description provided for @csvImportError.
  ///
  /// In es, this message translates to:
  /// **'Error al importar CSV: {error}'**
  String csvImportError(String error);

  /// No description provided for @errorAdding.
  ///
  /// In es, this message translates to:
  /// **'Error al añadir: {error}'**
  String errorAdding(String error);

  /// No description provided for @errorUpdating.
  ///
  /// In es, this message translates to:
  /// **'Error al actualizar: {error}'**
  String errorUpdating(String error);

  /// No description provided for @errorDeleting.
  ///
  /// In es, this message translates to:
  /// **'Error al eliminar: {error}'**
  String errorDeleting(String error);

  /// No description provided for @copiedToClipboard.
  ///
  /// In es, this message translates to:
  /// **'¡{label} copiado al portapapeles!'**
  String copiedToClipboard(String label);

  /// No description provided for @addCustomField.
  ///
  /// In es, this message translates to:
  /// **'Añadir campo personalizado'**
  String get addCustomField;

  /// No description provided for @titleRequired.
  ///
  /// In es, this message translates to:
  /// **'El título es obligatorio'**
  String get titleRequired;

  /// No description provided for @deleteCredentialTitle.
  ///
  /// In es, this message translates to:
  /// **'¿Eliminar Credencial?'**
  String get deleteCredentialTitle;

  /// No description provided for @deleteCredentialContent.
  ///
  /// In es, this message translates to:
  /// **'La credencial se moverá a la papelera. Podrás recuperarla cuando quieras.'**
  String get deleteCredentialContent;

  /// No description provided for @cancel.
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In es, this message translates to:
  /// **'Eliminar'**
  String get delete;

  /// No description provided for @manageCategories.
  ///
  /// In es, this message translates to:
  /// **'Gestionar Categorías'**
  String get manageCategories;

  /// No description provided for @categoryExists.
  ///
  /// In es, this message translates to:
  /// **'Esta categoría ya existe.'**
  String get categoryExists;

  /// No description provided for @close.
  ///
  /// In es, this message translates to:
  /// **'Cerrar'**
  String get close;

  /// No description provided for @renameCategory.
  ///
  /// In es, this message translates to:
  /// **'Renombrar Categoría'**
  String get renameCategory;

  /// No description provided for @save.
  ///
  /// In es, this message translates to:
  /// **'Guardar'**
  String get save;

  /// No description provided for @passwordPattern.
  ///
  /// In es, this message translates to:
  /// **'Generador de Contraseñas'**
  String get passwordPattern;

  /// No description provided for @customPatternSaved.
  ///
  /// In es, this message translates to:
  /// **'¡Generador guardado con éxito!'**
  String get customPatternSaved;

  /// No description provided for @biometricRequiredExport.
  ///
  /// In es, this message translates to:
  /// **'La autenticación biométrica es obligatoria para exportar y no está disponible en este dispositivo.'**
  String get biometricRequiredExport;

  /// No description provided for @search.
  ///
  /// In es, this message translates to:
  /// **'Buscar...'**
  String get search;

  /// No description provided for @editCredential.
  ///
  /// In es, this message translates to:
  /// **'Editar Credencial'**
  String get editCredential;

  /// No description provided for @username.
  ///
  /// In es, this message translates to:
  /// **'Usuario'**
  String get username;

  /// No description provided for @password.
  ///
  /// In es, this message translates to:
  /// **'Contraseña'**
  String get password;

  /// No description provided for @websiteUrl.
  ///
  /// In es, this message translates to:
  /// **'Sitio Web / URL'**
  String get websiteUrl;

  /// No description provided for @notes.
  ///
  /// In es, this message translates to:
  /// **'Notas'**
  String get notes;

  /// No description provided for @category.
  ///
  /// In es, this message translates to:
  /// **'Categoría'**
  String get category;

  /// No description provided for @categoryGeneral.
  ///
  /// In es, this message translates to:
  /// **'General'**
  String get categoryGeneral;

  /// No description provided for @globalSecurityScore.
  ///
  /// In es, this message translates to:
  /// **'Puntuación de Seguridad Global'**
  String get globalSecurityScore;

  /// No description provided for @weakPasswordsCount.
  ///
  /// In es, this message translates to:
  /// **'{count} Contraseñas Débiles'**
  String weakPasswordsCount(int count);

  /// No description provided for @weakPasswordsSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Longitud menor a 8 o muy comunes'**
  String get weakPasswordsSubtitle;

  /// No description provided for @noWeakPasswords.
  ///
  /// In es, this message translates to:
  /// **'¡Excelente! No tienes contraseñas débiles.'**
  String get noWeakPasswords;

  /// No description provided for @reusedPasswordsCount.
  ///
  /// In es, this message translates to:
  /// **'{count} Contraseñas Reutilizadas'**
  String reusedPasswordsCount(int count);

  /// No description provided for @reusedPasswordsSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Misma contraseña en múltiples cuentas'**
  String get reusedPasswordsSubtitle;

  /// No description provided for @noReusedPasswords.
  ///
  /// In es, this message translates to:
  /// **'¡Excelente! Cada cuenta tiene una clave única.'**
  String get noReusedPasswords;

  /// No description provided for @accountsUsePassword.
  ///
  /// In es, this message translates to:
  /// **'{count} cuentas usan esta clave'**
  String accountsUsePassword(int count);

  /// No description provided for @securePasswordsCount.
  ///
  /// In es, this message translates to:
  /// **'{count} Contraseñas Ultra Seguras'**
  String securePasswordsCount(int count);

  /// No description provided for @strongPasswordsSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Únicas y robustas'**
  String get strongPasswordsSubtitle;

  /// No description provided for @noStrongPasswords.
  ///
  /// In es, this message translates to:
  /// **'No tienes contraseñas seguras aún.'**
  String get noStrongPasswords;

  /// No description provided for @writeTitleGenerate.
  ///
  /// In es, this message translates to:
  /// **'Por favor, escribe el título primero para generar la contraseña.'**
  String get writeTitleGenerate;

  /// No description provided for @passwordGeneratorTitle.
  ///
  /// In es, this message translates to:
  /// **'Generador de Contraseñas'**
  String get passwordGeneratorTitle;

  /// No description provided for @generatorExplanation.
  ///
  /// In es, this message translates to:
  /// **'Se generará basándose en tu patrón estructural seguro.'**
  String get generatorExplanation;

  /// No description provided for @regenerate.
  ///
  /// In es, this message translates to:
  /// **'Regenerar'**
  String get regenerate;

  /// No description provided for @accept.
  ///
  /// In es, this message translates to:
  /// **'Aceptar'**
  String get accept;

  /// No description provided for @securityHealthTitle.
  ///
  /// In es, this message translates to:
  /// **'Salud de mis Contraseñas'**
  String get securityHealthTitle;

  /// No description provided for @exportCsv.
  ///
  /// In es, this message translates to:
  /// **'Exportar a CSV'**
  String get exportCsv;

  /// No description provided for @exportXml.
  ///
  /// In es, this message translates to:
  /// **'Exportar a XML'**
  String get exportXml;

  /// No description provided for @createMasterPassword.
  ///
  /// In es, this message translates to:
  /// **'Crear Contraseña Maestra'**
  String get createMasterPassword;

  /// No description provided for @enterMasterPassword.
  ///
  /// In es, this message translates to:
  /// **'Introduce la Contraseña Maestra'**
  String get enterMasterPassword;

  /// No description provided for @registerSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Establece una contraseña fuerte para proteger tus datos. No se puede recuperar si la olvidas.'**
  String get registerSubtitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Esta contraseña se utiliza para descifrar tu base de datos local.'**
  String get loginSubtitle;

  /// No description provided for @masterPasswordLabel.
  ///
  /// In es, this message translates to:
  /// **'Contraseña Maestra'**
  String get masterPasswordLabel;

  /// No description provided for @confirmPasswordLabel.
  ///
  /// In es, this message translates to:
  /// **'Confirmar Contraseña'**
  String get confirmPasswordLabel;

  /// No description provided for @registerSave.
  ///
  /// In es, this message translates to:
  /// **'Registrar y Guardar'**
  String get registerSave;

  /// No description provided for @unlock.
  ///
  /// In es, this message translates to:
  /// **'Desbloquear'**
  String get unlock;

  /// No description provided for @unexpectedError.
  ///
  /// In es, this message translates to:
  /// **'Error inesperado: {error}'**
  String unexpectedError(String error);

  /// No description provided for @logoutError.
  ///
  /// In es, this message translates to:
  /// **'Error al cerrar la sesión: {error}'**
  String logoutError(String error);

  /// No description provided for @lightTheme.
  ///
  /// In es, this message translates to:
  /// **'Tema Claro'**
  String get lightTheme;

  /// No description provided for @darkTheme.
  ///
  /// In es, this message translates to:
  /// **'Tema Oscuro'**
  String get darkTheme;

  /// No description provided for @categoryAll.
  ///
  /// In es, this message translates to:
  /// **'Todos'**
  String get categoryAll;

  /// No description provided for @categoryBanks.
  ///
  /// In es, this message translates to:
  /// **'Bancos'**
  String get categoryBanks;

  /// No description provided for @categoryWebAccounts.
  ///
  /// In es, this message translates to:
  /// **'Cuentas Web'**
  String get categoryWebAccounts;

  /// No description provided for @categoryEmails.
  ///
  /// In es, this message translates to:
  /// **'Emails'**
  String get categoryEmails;

  /// No description provided for @categoryForums.
  ///
  /// In es, this message translates to:
  /// **'Foros'**
  String get categoryForums;

  /// No description provided for @categoryRouter.
  ///
  /// In es, this message translates to:
  /// **'Router'**
  String get categoryRouter;

  /// No description provided for @categoryStore.
  ///
  /// In es, this message translates to:
  /// **'Tienda'**
  String get categoryStore;

  /// No description provided for @categoryOthers.
  ///
  /// In es, this message translates to:
  /// **'Otros'**
  String get categoryOthers;

  /// No description provided for @weakPassword.
  ///
  /// In es, this message translates to:
  /// **'Contraseña débil'**
  String get weakPassword;

  /// No description provided for @mediumPassword.
  ///
  /// In es, this message translates to:
  /// **'Contraseña media'**
  String get mediumPassword;

  /// No description provided for @strongPassword.
  ///
  /// In es, this message translates to:
  /// **'Contraseña fuerte'**
  String get strongPassword;

  /// No description provided for @edit.
  ///
  /// In es, this message translates to:
  /// **'Editar'**
  String get edit;

  /// No description provided for @userOrEmail.
  ///
  /// In es, this message translates to:
  /// **'Usuario / Correo'**
  String get userOrEmail;

  /// No description provided for @website.
  ///
  /// In es, this message translates to:
  /// **'Sitio Web'**
  String get website;

  /// No description provided for @field.
  ///
  /// In es, this message translates to:
  /// **'Campo'**
  String get field;

  /// No description provided for @newCategory.
  ///
  /// In es, this message translates to:
  /// **'Nueva categoría'**
  String get newCategory;

  /// No description provided for @language.
  ///
  /// In es, this message translates to:
  /// **'Idioma'**
  String get language;

  /// No description provided for @selectLanguage.
  ///
  /// In es, this message translates to:
  /// **'Seleccionar Idioma'**
  String get selectLanguage;

  /// No description provided for @passwordLength.
  ///
  /// In es, this message translates to:
  /// **'Longitud de la contraseña: {length}'**
  String passwordLength(int length);

  /// No description provided for @passwordLengthHelper.
  ///
  /// In es, this message translates to:
  /// **'Se incluirá siempre al menos una mayúscula, minúscula, número y símbolo.'**
  String get passwordLengthHelper;

  /// No description provided for @newNameLabel.
  ///
  /// In es, this message translates to:
  /// **'Nuevo nombre'**
  String get newNameLabel;

  /// No description provided for @criticalDanger.
  ///
  /// In es, this message translates to:
  /// **'¡PELIGRO CRÍTICO!'**
  String get criticalDanger;

  /// No description provided for @csvExportWarning.
  ///
  /// In es, this message translates to:
  /// **'¡ATENCIÓN! El archivo CSV que vas a generar NO está cifrado. Cualquier persona o aplicación con acceso a tu móvil podrá ver tus contraseñas en texto plano. Se recomienda encarecidamente enviar o copiar este archivo a un lugar seguro (como tu ordenador personal) y borrarlo inmediatamente de la carpeta de Descargas de este teléfono.'**
  String get csvExportWarning;

  /// No description provided for @understandRiskSave.
  ///
  /// In es, this message translates to:
  /// **'Entiendo el riesgo, guardar'**
  String get understandRiskSave;

  /// No description provided for @csvExportSuccessNoCount.
  ///
  /// In es, this message translates to:
  /// **'¡Contraseñas exportadas con éxito!'**
  String get csvExportSuccessNoCount;

  /// No description provided for @csvExportError.
  ///
  /// In es, this message translates to:
  /// **'Error al guardar archivo: {error}'**
  String csvExportError(String error);

  /// No description provided for @biometricReasonExport.
  ///
  /// In es, this message translates to:
  /// **'Confirma tu huella dactilar para autorizar la exportación de tus contraseñas.'**
  String get biometricReasonExport;

  /// No description provided for @authError.
  ///
  /// In es, this message translates to:
  /// **'Error de autenticación: {error}'**
  String authError(String error);

  /// No description provided for @authFailed.
  ///
  /// In es, this message translates to:
  /// **'Autenticación biométrica fallida.'**
  String get authFailed;

  /// No description provided for @emptyKeychain.
  ///
  /// In es, this message translates to:
  /// **'Llavero Vacío'**
  String get emptyKeychain;

  /// No description provided for @emptyKeychainSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Agrega una cuenta usando el botón inferior (+) o importa un archivo CSV desde el menú superior.'**
  String get emptyKeychainSubtitle;

  /// No description provided for @noMatchesFound.
  ///
  /// In es, this message translates to:
  /// **'No se encontraron coincidencias.'**
  String get noMatchesFound;

  /// No description provided for @favoritesHeader.
  ///
  /// In es, this message translates to:
  /// **'Mis Favoritos'**
  String get favoritesHeader;

  /// No description provided for @configureFieldTitle.
  ///
  /// In es, this message translates to:
  /// **'Configurar Campo'**
  String get configureFieldTitle;

  /// No description provided for @fieldNameLabel.
  ///
  /// In es, this message translates to:
  /// **'Nombre'**
  String get fieldNameLabel;

  /// No description provided for @fieldValueLabel.
  ///
  /// In es, this message translates to:
  /// **'Valor'**
  String get fieldValueLabel;

  /// No description provided for @addNewFieldTitle.
  ///
  /// In es, this message translates to:
  /// **'Añadir nuevo campo'**
  String get addNewFieldTitle;

  /// No description provided for @fieldDate.
  ///
  /// In es, this message translates to:
  /// **'Fecha'**
  String get fieldDate;

  /// No description provided for @fieldWebAddress.
  ///
  /// In es, this message translates to:
  /// **'Dirección Web'**
  String get fieldWebAddress;

  /// No description provided for @fieldEmail.
  ///
  /// In es, this message translates to:
  /// **'Email'**
  String get fieldEmail;

  /// No description provided for @fieldPin.
  ///
  /// In es, this message translates to:
  /// **'PIN'**
  String get fieldPin;

  /// No description provided for @logout.
  ///
  /// In es, this message translates to:
  /// **'Cerrar Sesión'**
  String get logout;

  /// No description provided for @additionalNotes.
  ///
  /// In es, this message translates to:
  /// **'Notas adicionales'**
  String get additionalNotes;

  /// No description provided for @copyTooltip.
  ///
  /// In es, this message translates to:
  /// **'Copiar'**
  String get copyTooltip;

  /// No description provided for @deleteFieldTooltip.
  ///
  /// In es, this message translates to:
  /// **'Eliminar campo'**
  String get deleteFieldTooltip;

  /// No description provided for @generatePasswordTooltip.
  ///
  /// In es, this message translates to:
  /// **'Generar contraseña'**
  String get generatePasswordTooltip;

  /// No description provided for @titleOrServiceName.
  ///
  /// In es, this message translates to:
  /// **'Título / Nombre del servicio'**
  String get titleOrServiceName;

  /// No description provided for @newCredential.
  ///
  /// In es, this message translates to:
  /// **'Nueva Credencial'**
  String get newCredential;

  /// No description provided for @checkStorageError.
  ///
  /// In es, this message translates to:
  /// **'Error al comprobar el estado del almacenamiento: {error}'**
  String checkStorageError(String error);

  /// No description provided for @fingerprintScanReason.
  ///
  /// In es, this message translates to:
  /// **'Escanea tu huella para acceder a tu gestor de contraseñas'**
  String get fingerprintScanReason;

  /// No description provided for @biometricAuthError.
  ///
  /// In es, this message translates to:
  /// **'Error en la autenticación biométrica: {error}'**
  String biometricAuthError(String error);

  /// No description provided for @fingerprintSetupReason.
  ///
  /// In es, this message translates to:
  /// **'Confirma tu huella para activar el acceso biométrico'**
  String get fingerprintSetupReason;

  /// No description provided for @passwordEmpty.
  ///
  /// In es, this message translates to:
  /// **'La contraseña no puede estar vacía.'**
  String get passwordEmpty;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In es, this message translates to:
  /// **'Las contraseñas no coinciden.'**
  String get passwordsDoNotMatch;

  /// No description provided for @dbInitError.
  ///
  /// In es, this message translates to:
  /// **'Error al inicializar la base de datos: {error}'**
  String dbInitError(String error);

  /// No description provided for @enterMasterPasswordPrompt.
  ///
  /// In es, this message translates to:
  /// **'Por favor, introduce tu contraseña maestra.'**
  String get enterMasterPasswordPrompt;

  /// No description provided for @incorrectPasswordError.
  ///
  /// In es, this message translates to:
  /// **'Contraseña incorrecta. Inténtalo de nuevo.'**
  String get incorrectPasswordError;

  /// No description provided for @importData.
  ///
  /// In es, this message translates to:
  /// **'Importar'**
  String get importData;

  /// No description provided for @exportData.
  ///
  /// In es, this message translates to:
  /// **'Exportar'**
  String get exportData;

  /// No description provided for @exportToKdbx.
  ///
  /// In es, this message translates to:
  /// **'Exportar a KDBX'**
  String get exportToKdbx;

  /// No description provided for @exportToJson.
  ///
  /// In es, this message translates to:
  /// **'Exportar a JSON'**
  String get exportToJson;

  /// No description provided for @exportJsonRecommended.
  ///
  /// In es, this message translates to:
  /// **'Por seguridad, te recomendamos proteger este archivo con una contraseña.'**
  String get exportJsonRecommended;

  /// No description provided for @exportJsonSecureBtn.
  ///
  /// In es, this message translates to:
  /// **'Exportar Json cifrado (Recomendado)'**
  String get exportJsonSecureBtn;

  /// No description provided for @exportJsonPlainBtn.
  ///
  /// In es, this message translates to:
  /// **'Exportar Json sin cifrar (No recomendado)'**
  String get exportJsonPlainBtn;

  /// No description provided for @exportKdbxDesc.
  ///
  /// In es, this message translates to:
  /// **'Introduce la contraseña maestra para tu nueva base de datos KeePass.\n\nEsta contraseña bloqueará el archivo .kdbx y no tiene que ser la misma que la de Cerberus.'**
  String get exportKdbxDesc;

  /// No description provided for @passwordForFile.
  ///
  /// In es, this message translates to:
  /// **'Contraseña para el archivo'**
  String get passwordForFile;

  /// No description provided for @importFormatsList.
  ///
  /// In es, this message translates to:
  /// **'Puedes importar los siguientes formatos:\n  - KDBX\n  - 1PUX\n  - Json\n  - XML\n  - CSV'**
  String get importFormatsList;

  /// No description provided for @historyTitle.
  ///
  /// In es, this message translates to:
  /// **'Historial de Contraseñas'**
  String get historyTitle;

  /// No description provided for @historyEmpty.
  ///
  /// In es, this message translates to:
  /// **'No hay contraseñas antiguas guardadas.'**
  String get historyEmpty;

  /// No description provided for @historyMainPassword.
  ///
  /// In es, this message translates to:
  /// **'Contraseña Principal'**
  String get historyMainPassword;

  /// No description provided for @historyChangedAt.
  ///
  /// In es, this message translates to:
  /// **'Cambiada el {date}'**
  String historyChangedAt(String date);

  /// No description provided for @historyCloseBtn.
  ///
  /// In es, this message translates to:
  /// **'CERRAR'**
  String get historyCloseBtn;

  /// No description provided for @historyViewBtn.
  ///
  /// In es, this message translates to:
  /// **'Ver historial'**
  String get historyViewBtn;

  /// No description provided for @attachmentsTitle.
  ///
  /// In es, this message translates to:
  /// **'Archivos Adjuntos'**
  String get attachmentsTitle;

  /// No description provided for @localBackupTitle.
  ///
  /// In es, this message translates to:
  /// **'Copia de seguridad local'**
  String get localBackupTitle;

  /// No description provided for @localBackupSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Crea un archivo de copia de seguridad cifrado en la ubicación que elijas, o restaura una desde un archivo.'**
  String get localBackupSubtitle;

  /// No description provided for @createLocalBackup.
  ///
  /// In es, this message translates to:
  /// **'Crear copia cifrada'**
  String get createLocalBackup;

  /// No description provided for @restoreLocalBackup.
  ///
  /// In es, this message translates to:
  /// **'Restaurar copia cifrada'**
  String get restoreLocalBackup;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'de',
    'en',
    'es',
    'fr',
    'it',
    'pl',
    'pt',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'it':
      return AppLocalizationsIt();
    case 'pl':
      return AppLocalizationsPl();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
