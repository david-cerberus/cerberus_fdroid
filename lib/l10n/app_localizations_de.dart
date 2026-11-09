// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get sessionClosedInactivity =>
      'Sitzung wegen Inaktivität geschlossen.';

  @override
  String get sessionClosedInactivityFiveMin =>
      'Sitzung wegen 5 Minuten Inaktivität geschlossen.';

  @override
  String get enableFingerprintTitle => 'Fingerabdruck aktivieren?';

  @override
  String get enableFingerprintContent =>
      'Möchtest du den schnellen Zugriff mit Fingerabdruck für die Zukunft aktivieren?';

  @override
  String get noThanks => 'Nein, danke';

  @override
  String get yesEnable => 'Ja, aktivieren';

  @override
  String get biometricEnabledSuccess =>
      'Biometrischer Zugriff erfolgreich aktiviert.';

  @override
  String biometricEnabledError(String error) {
    return 'Biometrischer Zugriff konnte nicht aktiviert werden: $error';
  }

  @override
  String errorLoadingEntries(String error) {
    return 'Fehler beim Laden der Einträge: $error';
  }

  @override
  String csvImportSuccess(int count) {
    return 'Erfolg! $count Passwörter wurden importiert.';
  }

  @override
  String csvImportError(String error) {
    return 'Fehler beim Importieren von CSV: $error';
  }

  @override
  String errorAdding(String error) {
    return 'Fehler beim Hinzufügen: $error';
  }

  @override
  String errorUpdating(String error) {
    return 'Fehler beim Aktualisieren: $error';
  }

  @override
  String errorDeleting(String error) {
    return 'Fehler beim Löschen: $error';
  }

  @override
  String copiedToClipboard(String label) {
    return '$label in die Zwischenablage kopiert!';
  }

  @override
  String get addCustomField => 'Benutzerdefiniertes Feld hinzufügen';

  @override
  String get titleRequired => 'Titel ist erforderlich';

  @override
  String get deleteCredentialTitle => 'Anmeldedaten löschen?';

  @override
  String get deleteCredentialContent =>
      'Die Anmeldedaten werden in den Papierkorb verschoben. Sie können sie jederzeit wiederherstellen.';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get delete => 'Löschen';

  @override
  String get manageCategories => 'Kategorien verwalten';

  @override
  String get categoryExists => 'Diese Kategorie existiert bereits.';

  @override
  String get close => 'Schließen';

  @override
  String get renameCategory => 'Kategorie umbenennen';

  @override
  String get save => 'Speichern';

  @override
  String get passwordPattern => 'Passwortgenerator';

  @override
  String get customPatternSaved => '¡Generador guardado con éxito!';

  @override
  String get biometricRequiredExport =>
      'Biometrische Authentifizierung ist für den Export erforderlich und auf diesem Gerät nicht verfügbar.';

  @override
  String get search => 'Suchen...';

  @override
  String get editCredential => 'Anmeldedaten bearbeiten';

  @override
  String get username => 'Benutzername';

  @override
  String get password => 'Passwort';

  @override
  String get websiteUrl => 'Website / URL';

  @override
  String get notes => 'Notizen';

  @override
  String get category => 'Kategorie';

  @override
  String get categoryGeneral => 'Allgemein';

  @override
  String get globalSecurityScore => 'Globaler Sicherheitsscore';

  @override
  String weakPasswordsCount(int count) {
    return '$count schwache Passwörter';
  }

  @override
  String get weakPasswordsSubtitle => 'Länge unter 8 Zeichen oder sehr häufig';

  @override
  String get noWeakPasswords =>
      'Hervorragend! Du hast keine schwachen Passwörter.';

  @override
  String reusedPasswordsCount(int count) {
    return '$count wiederverwendete Passwörter';
  }

  @override
  String get reusedPasswordsSubtitle => 'Gleiches Passwort bei mehreren Konten';

  @override
  String get noReusedPasswords =>
      'Hervorragend! Jedes Konto hat ein einzigartiges Passwort.';

  @override
  String accountsUsePassword(int count) {
    return '$count Konten verwenden dieses Passwort';
  }

  @override
  String securePasswordsCount(int count) {
    return '$count extrem sichere Passwörter';
  }

  @override
  String get strongPasswordsSubtitle => 'Einzigartig und robust';

  @override
  String get noStrongPasswords => 'Du hast noch keine starken Passwörter.';

  @override
  String get writeTitleGenerate =>
      'Bitte geben Sie zuerst einen Titel ein, um das Passwort zu generieren.';

  @override
  String get passwordGeneratorTitle => 'Passwortgenerator';

  @override
  String get generatorExplanation =>
      'Wird basierend auf deiner sicheren Struktur generiert.';

  @override
  String get regenerate => 'Neu generieren';

  @override
  String get accept => 'Akzeptieren';

  @override
  String get securityHealthTitle => 'Sicherheitsstatus meiner Passwörter';

  @override
  String get exportCsv => 'In CSV exportieren';

  @override
  String get exportXml => 'In XML exportieren';

  @override
  String get createMasterPassword => 'Master-Passwort erstellen';

  @override
  String get enterMasterPassword => 'Master-Passwort eingeben';

  @override
  String get registerSubtitle =>
      'Lege ein starkes Passwort fest, um deine Daten zu schützen. Es kann nicht wiederhergestellt werden, wenn du es vergisst.';

  @override
  String get loginSubtitle =>
      'Dieses Passwort wird verwendet, um deine lokale Datenbank zu entschlüsseln.';

  @override
  String get masterPasswordLabel => 'Master-Passwort';

  @override
  String get confirmPasswordLabel => 'Passwort bestätigen';

  @override
  String get registerSave => 'Registrieren & Speichern';

  @override
  String get unlock => 'Entsperren';

  @override
  String unexpectedError(String error) {
    return 'Unerwarteter Fehler: $error';
  }

  @override
  String logoutError(String error) {
    return 'Fehler beim Abmelden: $error';
  }

  @override
  String get lightTheme => 'Helles Design';

  @override
  String get darkTheme => 'Dunkles Design';

  @override
  String get categoryAll => 'Alle';

  @override
  String get categoryBanks => 'Banken';

  @override
  String get categoryWebAccounts => 'Webkonten';

  @override
  String get categoryEmails => 'E-Mails';

  @override
  String get categoryForums => 'Foren';

  @override
  String get categoryRouter => 'Router';

  @override
  String get categoryStore => 'Shop';

  @override
  String get categoryOthers => 'Andere';

  @override
  String get weakPassword => 'Schwaches Passwort';

  @override
  String get mediumPassword => 'Mittleres Passwort';

  @override
  String get strongPassword => 'Starkes Passwort';

  @override
  String get edit => 'Bearbeiten';

  @override
  String get userOrEmail => 'Benutzername / E-Mail';

  @override
  String get website => 'Website';

  @override
  String get field => 'Feld';

  @override
  String get newCategory => 'Neue Kategorie';

  @override
  String get language => 'Sprache';

  @override
  String get selectLanguage => 'Sprache auswählen';

  @override
  String passwordLength(int length) {
    return 'Passwortlänge: $length';
  }

  @override
  String get passwordLengthHelper =>
      'Es wird immer mindestens ein Großbuchstabe, ein Kleinbuchstabe, eine Zahl und ein Symbol enthalten sein.';

  @override
  String get newNameLabel => 'Neuer Name';

  @override
  String get criticalDanger => 'KRITISCHE GEFAHR!';

  @override
  String get csvExportWarning =>
      'ACHTUNG! Die zu erstellende CSV-Datei ist NICHT verschlüsselt. Jeder mit Zugriff auf dein Gerät kann deine Passwörter im Klartext sehen. Es wird dringend empfohlen, diese Datei an einen sicheren Ort (z. B. deinen PC) zu übertragen und sofort aus dem Downloads-Ordner dieses Telefons zu löschen.';

  @override
  String get understandRiskSave => 'Ich verstehe das Risiko, speichern';

  @override
  String get csvExportSuccessNoCount => 'Passwörter erfolgreich exportiert!';

  @override
  String csvExportError(String error) {
    return 'Fehler beim Speichern der Datei: $error';
  }

  @override
  String get biometricReasonExport =>
      'Bestätige deinen Fingerabdruck, um den Export deiner Passwörter zu autorisieren.';

  @override
  String authError(String error) {
    return 'Authentifizierungsfehler: $error';
  }

  @override
  String get authFailed => 'Biometrische Authentifizierung fehlgeschlagen.';

  @override
  String get emptyKeychain => 'Leerer Schlüsselbund';

  @override
  String get emptyKeychainSubtitle =>
      'Füge ein Konto über die Schaltfläche unten (+) hinzu oder importiere eine CSV-Datei aus dem oberen Menü.';

  @override
  String get noMatchesFound => 'Keine Treffer gefunden.';

  @override
  String get favoritesHeader => 'Meine Favoriten';

  @override
  String get configureFieldTitle => 'Feld konfigurieren';

  @override
  String get fieldNameLabel => 'Name';

  @override
  String get fieldValueLabel => 'Wert';

  @override
  String get addNewFieldTitle => 'Neues Feld hinzufügen';

  @override
  String get fieldDate => 'Datum';

  @override
  String get fieldWebAddress => 'Webadresse';

  @override
  String get fieldEmail => 'E-Mail';

  @override
  String get fieldPin => 'PIN';

  @override
  String get logout => 'Abmelden';

  @override
  String get additionalNotes => 'Zusätzliche Notizen';

  @override
  String get copyTooltip => 'Kopieren';

  @override
  String get deleteFieldTooltip => 'Feld löschen';

  @override
  String get generatePasswordTooltip => 'Passwort generieren';

  @override
  String get titleOrServiceName => 'Titel / Dienstname';

  @override
  String get newCredential => 'Neue Anmeldedaten';

  @override
  String checkStorageError(String error) {
    return 'Fehler beim Überprüfen des Speicherstatus: $error';
  }

  @override
  String get fingerprintScanReason =>
      'Scanne deinen Fingerabdruck, um auf deinen Passwort-Manager zuzugreifen';

  @override
  String biometricAuthError(String error) {
    return 'Fehler bei biometrischer Authentifizierung: $error';
  }

  @override
  String get fingerprintSetupReason =>
      'Bestätige deinen Fingerabdruck, um den biometrischen Zugriff zu aktivieren';

  @override
  String get passwordEmpty => 'Das Passwort darf nicht leer sein.';

  @override
  String get passwordsDoNotMatch => 'Die Passwörter stimmen nicht überein.';

  @override
  String dbInitError(String error) {
    return 'Fehler beim Initialisieren der Datenbank: $error';
  }

  @override
  String get enterMasterPasswordPrompt => 'Bitte gib dein Master-Passwort ein.';

  @override
  String get incorrectPasswordError =>
      'Falsches Passwort. Bitte versuche es erneut.';

  @override
  String get importData => 'Importieren';

  @override
  String get exportData => 'Exportieren';

  @override
  String get exportToKdbx => 'Nach KDBX exportieren';

  @override
  String get exportToJson => 'Export to JSON';

  @override
  String get exportJsonRecommended =>
      'For security, we recommend protecting this file with a password.';

  @override
  String get exportJsonSecureBtn =>
      'Verschlüsseltes Json exportieren (Empfohlen)';

  @override
  String get exportJsonPlainBtn =>
      'Unverschlüsseltes Json exportieren (Nicht empfohlen)';

  @override
  String get exportKdbxDesc =>
      'Enter the master password for your new KeePass database.\n\nThis password will lock the .kdbx file and doesn\'t need to be the same as Cerberus\'.';

  @override
  String get passwordForFile => 'Password for file';

  @override
  String get importFormatsList =>
      'Sie können folgende Formate importieren:\n  - KDBX\n  - 1PUX\n  - Json\n  - XML\n  - CSV';

  @override
  String get historyTitle => 'Passwort-Verlauf';

  @override
  String get historyEmpty => 'Keine alten Passwörter gespeichert.';

  @override
  String get historyMainPassword => 'Hauptpasswort';

  @override
  String historyChangedAt(String date) {
    return 'Geändert am $date';
  }

  @override
  String get historyCloseBtn => 'SCHLIESSEN';

  @override
  String get historyViewBtn => 'Verlauf ansehen';

  @override
  String get attachmentsTitle => 'Anhänge';

  @override
  String get localBackupTitle => 'Lokale Sicherung';

  @override
  String get localBackupSubtitle =>
      'Erstelle eine verschlüsselte Sicherungsdatei an einem Ort deiner Wahl oder stelle eine aus einer Datei wieder her.';

  @override
  String get createLocalBackup => 'Verschlüsselte Sicherung erstellen';

  @override
  String get restoreLocalBackup => 'Verschlüsselte Sicherung wiederherstellen';
}
