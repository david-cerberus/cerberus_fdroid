// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get sessionClosedInactivity => 'Session closed due to inactivity.';

  @override
  String get sessionClosedInactivityFiveMin =>
      'Session closed after 5 minutes of inactivity.';

  @override
  String get enableFingerprintTitle => 'Enable Fingerprint?';

  @override
  String get enableFingerprintContent =>
      'Would you like to enable quick access with your fingerprint for future sessions?';

  @override
  String get noThanks => 'No, thank you';

  @override
  String get yesEnable => 'Yes, enable';

  @override
  String get biometricEnabledSuccess =>
      'Biometric access successfully enabled.';

  @override
  String biometricEnabledError(String error) {
    return 'Unable to enable biometric access: $error';
  }

  @override
  String errorLoadingEntries(String error) {
    return 'Error loading entries: $error';
  }

  @override
  String csvImportSuccess(int count) {
    return 'Success! $count passwords imported.';
  }

  @override
  String csvImportError(String error) {
    return 'Error importing CSV: $error';
  }

  @override
  String errorAdding(String error) {
    return 'Error adding: $error';
  }

  @override
  String errorUpdating(String error) {
    return 'Error updating: $error';
  }

  @override
  String errorDeleting(String error) {
    return 'Error deleting: $error';
  }

  @override
  String copiedToClipboard(String label) {
    return '$label copied to the clipboard!';
  }

  @override
  String get addCustomField => 'Add custom field';

  @override
  String get titleRequired => 'Title is required';

  @override
  String get deleteCredentialTitle => 'Delete Credential?';

  @override
  String get deleteCredentialContent =>
      'The credential will be moved to the trash. You can restore it whenever you want.';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get manageCategories => 'Manage Categories';

  @override
  String get categoryExists => 'This category already exists.';

  @override
  String get close => 'Close';

  @override
  String get renameCategory => 'Rename Category';

  @override
  String get save => 'Save';

  @override
  String get passwordPattern => 'Password Pattern';

  @override
  String get customPatternSaved => 'Custom password pattern saved.';

  @override
  String get biometricRequiredExport =>
      'Biometric authentication is required for exporting and is not available on this device.';

  @override
  String get search => 'Search...';

  @override
  String get editCredential => 'Edit Credential';

  @override
  String get username => 'Username';

  @override
  String get password => 'Password';

  @override
  String get websiteUrl => 'Website / URL';

  @override
  String get notes => 'Notes';

  @override
  String get category => 'Category';

  @override
  String get categoryGeneral => 'General';

  @override
  String get globalSecurityScore => 'Global Security Score';

  @override
  String weakPasswordsCount(int count) {
    return '$count Weak Passwords';
  }

  @override
  String get weakPasswordsSubtitle =>
      'Length under 8 characters or very common';

  @override
  String get noWeakPasswords => 'Excellent! You have no weak passwords.';

  @override
  String reusedPasswordsCount(int count) {
    return '$count Reused Passwords';
  }

  @override
  String get reusedPasswordsSubtitle =>
      'Same password used across multiple accounts';

  @override
  String get noReusedPasswords =>
      'Excellent! Each account has a unique password.';

  @override
  String accountsUsePassword(int count) {
    return '$count accounts use this password';
  }

  @override
  String securePasswordsCount(int count) {
    return '$count Ultra-Secure Passwords';
  }

  @override
  String get strongPasswordsSubtitle => 'Unique and robust';

  @override
  String get noStrongPasswords => 'You don\'t have secure passwords yet.';

  @override
  String get writeTitleGenerate =>
      'Please write a title first to generate the password.';

  @override
  String get passwordGeneratorTitle => 'Password Generator';

  @override
  String get generatorExplanation =>
      'Generated based on your secure structural pattern.';

  @override
  String get regenerate => 'Regenerate';

  @override
  String get accept => 'Accept';

  @override
  String get securityHealthTitle => 'My Password Health';

  @override
  String get exportCsv => 'Export to CSV';

  @override
  String get exportXml => 'Export to XML';

  @override
  String get createMasterPassword => 'Create Master Password';

  @override
  String get enterMasterPassword => 'Enter Master Password';

  @override
  String get registerSubtitle =>
      'Set a strong password to protect your data. It cannot be recovered if you forget it.';

  @override
  String get loginSubtitle =>
      'This password is used to decrypt your local database.';

  @override
  String get masterPasswordLabel => 'Master Password';

  @override
  String get confirmPasswordLabel => 'Confirm Password';

  @override
  String get registerSave => 'Register and Save';

  @override
  String get unlock => 'Unlock';

  @override
  String unexpectedError(String error) {
    return 'Unexpected error: $error';
  }

  @override
  String logoutError(String error) {
    return 'Error closing session: $error';
  }

  @override
  String get lightTheme => 'Light Theme';

  @override
  String get darkTheme => 'Dark Theme';

  @override
  String get categoryAll => 'All';

  @override
  String get categoryBanks => 'Banks';

  @override
  String get categoryWebAccounts => 'Web Accounts';

  @override
  String get categoryEmails => 'Emails';

  @override
  String get categoryForums => 'Forums';

  @override
  String get categoryRouter => 'Router';

  @override
  String get categoryStore => 'Store';

  @override
  String get categoryOthers => 'Others';

  @override
  String get weakPassword => 'Weak password';

  @override
  String get mediumPassword => 'Medium password';

  @override
  String get strongPassword => 'Strong password';

  @override
  String get edit => 'Edit';

  @override
  String get userOrEmail => 'Username / Email';

  @override
  String get website => 'Website';

  @override
  String get field => 'Field';

  @override
  String get newCategory => 'New Category';

  @override
  String get language => 'Language';

  @override
  String get selectLanguage => 'Select Language';

  @override
  String passwordLength(int length) {
    return 'Password Length: $length';
  }

  @override
  String get passwordLengthHelper =>
      'At least one uppercase, lowercase, number, and symbol will be included.';

  @override
  String get newNameLabel => 'New name';

  @override
  String get criticalDanger => 'CRITICAL DANGER!';

  @override
  String get csvExportWarning =>
      'WARNING! The CSV file you are about to generate is NOT encrypted. Anyone or any application with access to your phone will be able to see your passwords in plain text. It is strongly recommended to send or copy this file to a secure place (like your personal computer) and delete it immediately from the Downloads folder of this phone.';

  @override
  String get understandRiskSave => 'I understand the risk, save';

  @override
  String get csvExportSuccessNoCount => 'Passwords exported successfully!';

  @override
  String csvExportError(String error) {
    return 'Error saving file: $error';
  }

  @override
  String get biometricReasonExport =>
      'Confirm your fingerprint to authorize the export of your passwords.';

  @override
  String authError(String error) {
    return 'Authentication error: $error';
  }

  @override
  String get authFailed => 'Biometric authentication failed.';

  @override
  String get emptyKeychain => 'Empty Keychain';

  @override
  String get emptyKeychainSubtitle =>
      'Add an account using the bottom (+) button or import a CSV file from the top menu.';

  @override
  String get noMatchesFound => 'No matches found.';

  @override
  String get favoritesHeader => 'My Favorites';

  @override
  String get configureFieldTitle => 'Configure Field';

  @override
  String get fieldNameLabel => 'Name';

  @override
  String get fieldValueLabel => 'Value';

  @override
  String get addNewFieldTitle => 'Add new field';

  @override
  String get fieldDate => 'Date';

  @override
  String get fieldWebAddress => 'Web Address';

  @override
  String get fieldEmail => 'Email';

  @override
  String get fieldPin => 'PIN';

  @override
  String get logout => 'Log Out';

  @override
  String get additionalNotes => 'Additional notes';

  @override
  String get copyTooltip => 'Copy';

  @override
  String get deleteFieldTooltip => 'Delete field';

  @override
  String get generatePasswordTooltip => 'Generate password';

  @override
  String get titleOrServiceName => 'Title / Service Name';

  @override
  String get newCredential => 'New Credential';

  @override
  String checkStorageError(String error) {
    return 'Error checking storage status: $error';
  }

  @override
  String get fingerprintScanReason =>
      'Scan your fingerprint to access your password manager';

  @override
  String biometricAuthError(String error) {
    return 'Biometric authentication error: $error';
  }

  @override
  String get fingerprintSetupReason =>
      'Confirm your fingerprint to activate biometric access';

  @override
  String get passwordEmpty => 'Password cannot be empty.';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match.';

  @override
  String dbInitError(String error) {
    return 'Error initializing the database: $error';
  }

  @override
  String get enterMasterPasswordPrompt => 'Please enter your master password.';

  @override
  String get incorrectPasswordError => 'Incorrect password. Please try again.';

  @override
  String get importData => 'Import';

  @override
  String get exportData => 'Export';

  @override
  String get exportToKdbx => 'Export to KDBX';

  @override
  String get exportToJson => 'Export to JSON';

  @override
  String get exportJsonRecommended =>
      'For security, we recommend protecting this file with a password.';

  @override
  String get exportJsonSecureBtn => 'Export encrypted Json (Recommended)';

  @override
  String get exportJsonPlainBtn => 'Export unencrypted Json (Not recommended)';

  @override
  String get exportKdbxDesc =>
      'Enter the master password for your new KeePass database.\n\nThis password will lock the .kdbx file and doesn\'t need to be the same as Cerberus\'.';

  @override
  String get passwordForFile => 'Password for file';

  @override
  String get importFormatsList =>
      'You can import the following formats:\n  - KDBX\n  - 1PUX\n  - Json\n  - XML\n  - CSV';

  @override
  String get historyTitle => 'Password History';

  @override
  String get historyEmpty => 'No old passwords saved.';

  @override
  String get historyMainPassword => 'Main Password';

  @override
  String historyChangedAt(String date) {
    return 'Changed on $date';
  }

  @override
  String get historyCloseBtn => 'CLOSE';

  @override
  String get historyViewBtn => 'View history';

  @override
  String get attachmentsTitle => 'Attachments';

  @override
  String get localBackupTitle => 'Local Backup';

  @override
  String get localBackupSubtitle =>
      'Create an encrypted backup file in the location you choose, or restore one from a file.';

  @override
  String get createLocalBackup => 'Create encrypted backup';

  @override
  String get restoreLocalBackup => 'Restore encrypted backup';
}
