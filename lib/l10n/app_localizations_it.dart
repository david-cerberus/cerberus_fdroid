// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get sessionClosedInactivity => 'Sessione chiusa per inattività.';

  @override
  String get sessionClosedInactivityFiveMin =>
      'Sessione chiusa dopo 5 minuti di inattività.';

  @override
  String get enableFingerprintTitle => 'Attivare l\'impronta digitale?';

  @override
  String get enableFingerprintContent =>
      'Vuoi attivare l\'accesso rapido con impronta digitale per le prossime volte?';

  @override
  String get noThanks => 'No, grazie';

  @override
  String get yesEnable => 'Sì, attiva';

  @override
  String get biometricEnabledSuccess =>
      'Accesso biometrico attivato con successo.';

  @override
  String biometricEnabledError(String error) {
    return 'Impossibile attivare l\'accesso biometrico: $error';
  }

  @override
  String errorLoadingEntries(String error) {
    return 'Errore nel caricamento delle voci: $error';
  }

  @override
  String csvImportSuccess(int count) {
    return 'Successo! Sono state importate $count password.';
  }

  @override
  String csvImportError(String error) {
    return 'Errore durante l\'importazione del CSV: $error';
  }

  @override
  String errorAdding(String error) {
    return 'Errore durante l\'aggiunta: $error';
  }

  @override
  String errorUpdating(String error) {
    return 'Errore durante l\'aggiornamento: $error';
  }

  @override
  String errorDeleting(String error) {
    return 'Errore durante l\'eliminazione: $error';
  }

  @override
  String copiedToClipboard(String label) {
    return '$label copiato negli appunti!';
  }

  @override
  String get addCustomField => 'Aggiungi campo personalizzato';

  @override
  String get titleRequired => 'Il titolo è obbligatorio';

  @override
  String get deleteCredentialTitle => 'Eliminare le credenziali?';

  @override
  String get deleteCredentialContent =>
      'Le credenziali verranno spostate nel cestino. Potrai ripristinarle quando vuoi.';

  @override
  String get cancel => 'Annulla';

  @override
  String get delete => 'Elimina';

  @override
  String get manageCategories => 'Gestisci categorie';

  @override
  String get categoryExists => 'Questa categoria esiste già.';

  @override
  String get close => 'Chiudi';

  @override
  String get renameCategory => 'Rinomina categoria';

  @override
  String get save => 'Salva';

  @override
  String get passwordPattern => 'Generatore di Password';

  @override
  String get customPatternSaved => 'Generatore salvato con successo!';

  @override
  String get biometricRequiredExport =>
      'L\'autenticazione biometrica è obbligatoria per l\'esportazione e non è disponibile su questo dispositivo.';

  @override
  String get search => 'Cerca...';

  @override
  String get editCredential => 'Modifica credenziali';

  @override
  String get username => 'Nome utente';

  @override
  String get password => 'Password';

  @override
  String get websiteUrl => 'Sito Web / URL';

  @override
  String get notes => 'Note';

  @override
  String get category => 'Categoria';

  @override
  String get categoryGeneral => 'Generale';

  @override
  String get globalSecurityScore => 'Punteggio di sicurezza globale';

  @override
  String weakPasswordsCount(int count) {
    return '$count password deboli';
  }

  @override
  String get weakPasswordsSubtitle =>
      'Lunghezza inferiore a 8 caratteri o molto comuni';

  @override
  String get noWeakPasswords => 'Eccellente! Non hai password deboli.';

  @override
  String reusedPasswordsCount(int count) {
    return '$count password riutilizzate';
  }

  @override
  String get reusedPasswordsSubtitle => 'Stessa password su più account';

  @override
  String get noReusedPasswords =>
      'Eccellente! Ogni account ha una password unica.';

  @override
  String accountsUsePassword(int count) {
    return '$count account utilizzano questa password';
  }

  @override
  String securePasswordsCount(int count) {
    return '$count password ultra sicure';
  }

  @override
  String get strongPasswordsSubtitle => 'Uniche e robuste';

  @override
  String get noStrongPasswords => 'Non hai ancora password forti.';

  @override
  String get writeTitleGenerate =>
      'Per favore, inserisci prima il titolo per generare la password.';

  @override
  String get passwordGeneratorTitle => 'Generatore di Password';

  @override
  String get generatorExplanation =>
      'Verrà generata in base alla tua struttura sicura.';

  @override
  String get regenerate => 'Rigenera';

  @override
  String get accept => 'Accetta';

  @override
  String get securityHealthTitle => 'Stato delle mie password';

  @override
  String get exportCsv => 'Esporta in CSV';

  @override
  String get exportXml => 'Esporta in XML';

  @override
  String get createMasterPassword => 'Crea password master';

  @override
  String get enterMasterPassword => 'Inserisci password master';

  @override
  String get registerSubtitle =>
      'Imposta una password master complessa per proteggere i tuoi dati. Non potrà essere recuperata se la dimentichi.';

  @override
  String get loginSubtitle =>
      'Questa password viene utilizzata per decifrare il database locale.';

  @override
  String get masterPasswordLabel => 'Password master';

  @override
  String get confirmPasswordLabel => 'Conferma password';

  @override
  String get registerSave => 'Registra e salva';

  @override
  String get unlock => 'Sblocca';

  @override
  String unexpectedError(String error) {
    return 'Errore imprevisto: $error';
  }

  @override
  String logoutError(String error) {
    return 'Errore durante la disconnessione: $error';
  }

  @override
  String get lightTheme => 'Tema Chiaro';

  @override
  String get darkTheme => 'Tema Scuro';

  @override
  String get categoryAll => 'Tutti';

  @override
  String get categoryBanks => 'Banche';

  @override
  String get categoryWebAccounts => 'Account Web';

  @override
  String get categoryEmails => 'E-mail';

  @override
  String get categoryForums => 'Forum';

  @override
  String get categoryRouter => 'Router';

  @override
  String get categoryStore => 'Negozio';

  @override
  String get categoryOthers => 'Altri';

  @override
  String get weakPassword => 'Password debole';

  @override
  String get mediumPassword => 'Password media';

  @override
  String get strongPassword => 'Password forte';

  @override
  String get edit => 'Modifica';

  @override
  String get userOrEmail => 'Utente / E-mail';

  @override
  String get website => 'Sito Web';

  @override
  String get field => 'Campo';

  @override
  String get newCategory => 'Nuova categoria';

  @override
  String get language => 'Lingua';

  @override
  String get selectLanguage => 'Seleziona lingua';

  @override
  String passwordLength(int length) {
    return 'Lunghezza password: $length';
  }

  @override
  String get passwordLengthHelper =>
      'Sarà sempre inclusa almeno una lettera maiuscola, una minuscola, un numero e un simbolo.';

  @override
  String get newNameLabel => 'Nuovo nome';

  @override
  String get criticalDanger => 'PERICOLO CRITICO!';

  @override
  String get csvExportWarning =>
      'ATTENZIONE! Il file CSV che stai per generare NON è crittografato. Chiunque o qualsiasi applicazione con accesso al tuo telefono potrà vedere le tue password in testo chiaro. Si consiglia vivamente di inviare o copiare questo file in un luogo sicuro (come il computer personale) e di eliminarlo immediatamente dalla cartella Download di questo telefono.';

  @override
  String get understandRiskSave => 'Comprendo il rischio, salva';

  @override
  String get csvExportSuccessNoCount => 'Password esportate con successo!';

  @override
  String csvExportError(String error) {
    return 'Errore durante il salvataggio del file: $error';
  }

  @override
  String get biometricReasonExport =>
      'Conferma la tua impronta digitale per autorizzare l\'esportazione delle tue password.';

  @override
  String authError(String error) {
    return 'Errore di autentizzazione: $error';
  }

  @override
  String get authFailed => 'Autenticazione biometrica fallita.';

  @override
  String get emptyKeychain => 'Cassaforte Vuota';

  @override
  String get emptyKeychainSubtitle =>
      'Aggiungi un account utilizzando il pulsante in basso (+) o importa un file CSV dal menu in alto.';

  @override
  String get noMatchesFound => 'Nessuna corrispondenza trovata.';

  @override
  String get favoritesHeader => 'I Miei Preferiti';

  @override
  String get configureFieldTitle => 'Configura campo';

  @override
  String get fieldNameLabel => 'Nome';

  @override
  String get fieldValueLabel => 'Valore';

  @override
  String get addNewFieldTitle => 'Aggiungi nuovo campo';

  @override
  String get fieldDate => 'Data';

  @override
  String get fieldWebAddress => 'Indirizzo Web';

  @override
  String get fieldEmail => 'E-mail';

  @override
  String get fieldPin => 'PIN';

  @override
  String get logout => 'Disconnetti';

  @override
  String get additionalNotes => 'Note aggiuntive';

  @override
  String get copyTooltip => 'Copia';

  @override
  String get deleteFieldTooltip => 'Elimina campo';

  @override
  String get generatePasswordTooltip => 'Genera password';

  @override
  String get titleOrServiceName => 'Titolo / Nome del servizio';

  @override
  String get newCredential => 'Nuove credenziali';

  @override
  String checkStorageError(String error) {
    return 'Errore durante la verifica dello stato di archiviazione: $error';
  }

  @override
  String get fingerprintScanReason =>
      'Scansiona la tua impronta digitale per accedere al tuo gestore delle password';

  @override
  String biometricAuthError(String error) {
    return 'Errore di autenticazione biometrica: $error';
  }

  @override
  String get fingerprintSetupReason =>
      'Conferma la tua impronta digitale per attivare l\'accesso biometrico';

  @override
  String get passwordEmpty => 'La password non può essere vuota.';

  @override
  String get passwordsDoNotMatch => 'Le password non corrispondono.';

  @override
  String dbInitError(String error) {
    return 'Errore durante l\'inizializzazione del database: $error';
  }

  @override
  String get enterMasterPasswordPrompt =>
      'Per favore, inserisci la tua password master.';

  @override
  String get incorrectPasswordError => 'Password errata. Riprova.';

  @override
  String get importData => 'Importare';

  @override
  String get exportData => 'Esportare';

  @override
  String get exportToKdbx => 'Esporta in KDBX';

  @override
  String get exportToJson => 'Export to JSON';

  @override
  String get exportJsonRecommended =>
      'For security, we recommend protecting this file with a password.';

  @override
  String get exportJsonSecureBtn => 'Esporta Json crittografato (Consigliato)';

  @override
  String get exportJsonPlainBtn =>
      'Esporta Json non crittografato (Non consigliato)';

  @override
  String get exportKdbxDesc =>
      'Enter the master password for your new KeePass database.\n\nThis password will lock the .kdbx file and doesn\'t need to be the same as Cerberus\'.';

  @override
  String get passwordForFile => 'Password for file';

  @override
  String get importFormatsList =>
      'Puoi importare i seguenti formati:\n  - KDBX\n  - 1PUX\n  - Json\n  - XML\n  - CSV';

  @override
  String get historyTitle => 'Cronologia password';

  @override
  String get historyEmpty => 'Nessuna vecchia password salvata.';

  @override
  String get historyMainPassword => 'Password principale';

  @override
  String historyChangedAt(String date) {
    return 'Modificata il $date';
  }

  @override
  String get historyCloseBtn => 'CHIUDI';

  @override
  String get historyViewBtn => 'Vedi cronologia';

  @override
  String get attachmentsTitle => 'Allegati';

  @override
  String get localBackupTitle => 'Backup locale';

  @override
  String get localBackupSubtitle =>
      'Crea un file di backup cifrato nella posizione che preferisci o ripristinane uno da un file.';

  @override
  String get createLocalBackup => 'Crea backup cifrato';

  @override
  String get restoreLocalBackup => 'Ripristina backup cifrato';
}
