// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Polish (`pl`).
class AppLocalizationsPl extends AppLocalizations {
  AppLocalizationsPl([String locale = 'pl']) : super(locale);

  @override
  String get sessionClosedInactivity =>
      'Sesja zakończona z powodu braku aktywności.';

  @override
  String get sessionClosedInactivityFiveMin =>
      'Sesja została zamknięta po 5 minutach braku aktywności.';

  @override
  String get enableFingerprintTitle => 'Włączyć logowanie odciskiem palca?';

  @override
  String get enableFingerprintContent =>
      'Czy chcesz włączyć szybki dostęp za pomocą odcisku palca przy następnych logowaniach?';

  @override
  String get noThanks => 'Nie, dziękuję';

  @override
  String get yesEnable => 'Tak, włącz';

  @override
  String get biometricEnabledSuccess =>
      'Dostęp biometryczny został pomyślnie włączony.';

  @override
  String biometricEnabledError(String error) {
    return 'Nie można włączyć dostępu biometrycznego: $error';
  }

  @override
  String errorLoadingEntries(String error) {
    return 'Błąd podczas ładowania wpisów: $error';
  }

  @override
  String csvImportSuccess(int count) {
    return 'Sukces! Zaimportowano $count haseł.';
  }

  @override
  String csvImportError(String error) {
    return 'Błąd podczas importowania pliku CSV: $error';
  }

  @override
  String errorAdding(String error) {
    return 'Błąd podczas dodawania: $error';
  }

  @override
  String errorUpdating(String error) {
    return 'Błąd podczas aktualizacji: $error';
  }

  @override
  String errorDeleting(String error) {
    return 'Błąd podczas usuwania: $error';
  }

  @override
  String copiedToClipboard(String label) {
    return 'Skopiowano $label do schowka!';
  }

  @override
  String get addCustomField => 'Dodaj własne pole';

  @override
  String get titleRequired => 'Tytuł jest wymagany';

  @override
  String get deleteCredentialTitle => 'Usunąć dane uwierzytelniające?';

  @override
  String get deleteCredentialContent =>
      'Dane uwierzytelniające zostaną przeniesione do kosza. Możesz je przywrócić w dowolnym momencie.';

  @override
  String get cancel => 'Anuluj';

  @override
  String get delete => 'Usuń';

  @override
  String get manageCategories => 'Zarządzaj kategoriami';

  @override
  String get categoryExists => 'Ta kategoria już istnieje.';

  @override
  String get close => 'Zamknij';

  @override
  String get renameCategory => 'Zmień nazwę kategorii';

  @override
  String get save => 'Zapisz';

  @override
  String get passwordPattern => 'Generator Haseł';

  @override
  String get customPatternSaved => 'Generator został pomyślnie zapisany!';

  @override
  String get biometricRequiredExport =>
      'Uwierzytelnianie biometryczne jest wymagane do eksportu i nie jest dostępne na tym urządzeniu.';

  @override
  String get search => 'Szukaj...';

  @override
  String get editCredential => 'Edytuj dane logowania';

  @override
  String get username => 'Nazwa użytkownika';

  @override
  String get password => 'Hasło';

  @override
  String get websiteUrl => 'Strona internetowa / URL';

  @override
  String get notes => 'Notatki';

  @override
  String get category => 'Kategoria';

  @override
  String get categoryGeneral => 'Ogólne';

  @override
  String get globalSecurityScore => 'Ogólna ocena bezpieczeństwa';

  @override
  String weakPasswordsCount(int count) {
    return '$count słabych haseł';
  }

  @override
  String get weakPasswordsSubtitle =>
      'Długość poniżej 8 znaków lub bardzo popularne';

  @override
  String get noWeakPasswords => 'Doskonale! Nie masz słabych haseł.';

  @override
  String reusedPasswordsCount(int count) {
    return '$count powtórzonych haseł';
  }

  @override
  String get reusedPasswordsSubtitle => 'To samo hasło na wielu kontach';

  @override
  String get noReusedPasswords => 'Doskonale! Każde konto ma unikalne hasło.';

  @override
  String accountsUsePassword(int count) {
    return '$count kont używa tego hasła';
  }

  @override
  String securePasswordsCount(int count) {
    return '$count ultra bezpiecznych haseł';
  }

  @override
  String get strongPasswordsSubtitle => 'Unikalne i solidne';

  @override
  String get noStrongPasswords => 'Nie masz jeszcze silnych haseł.';

  @override
  String get writeTitleGenerate =>
      'Najpierw wpisz tytuł, aby wygenerować hasło.';

  @override
  String get passwordGeneratorTitle => 'Generator Haseł';

  @override
  String get generatorExplanation =>
      'Zostanie wygenerowane na podstawie Twojej bezpiecznej struktury.';

  @override
  String get regenerate => 'Wygeneruj ponownie';

  @override
  String get accept => 'Akceptuj';

  @override
  String get securityHealthTitle => 'Stan bezpieczeństwa moich haseł';

  @override
  String get exportCsv => 'Eksportuj do CSV';

  @override
  String get exportXml => 'Eksportuj do XML';

  @override
  String get createMasterPassword => 'Utwórz hasło główne';

  @override
  String get enterMasterPassword => 'Wprowadź hasło główne';

  @override
  String get registerSubtitle =>
      'Ustaw silne hasło główne, aby chronić swoje dane. Nie można go odzyskać, jeśli je zapomnisz.';

  @override
  String get loginSubtitle =>
      'To hasło służy do odszyfrowania lokalnej bazy danych.';

  @override
  String get masterPasswordLabel => 'Hasło główne';

  @override
  String get confirmPasswordLabel => 'Potwierdź hasło';

  @override
  String get registerSave => 'Zarejestruj i zapisz';

  @override
  String get unlock => 'Odblokuj';

  @override
  String unexpectedError(String error) {
    return 'Nieoczekiwany błąd: $error';
  }

  @override
  String logoutError(String error) {
    return 'Błąd podczas wylogowywania: $error';
  }

  @override
  String get lightTheme => 'Jasny motyw';

  @override
  String get darkTheme => 'Ciemny motyw';

  @override
  String get categoryAll => 'Wszystkie';

  @override
  String get categoryBanks => 'Banki';

  @override
  String get categoryWebAccounts => 'Konta internetowe';

  @override
  String get categoryEmails => 'E-maile';

  @override
  String get categoryForums => 'Fora';

  @override
  String get categoryRouter => 'Router';

  @override
  String get categoryStore => 'Sklep';

  @override
  String get categoryOthers => 'Inne';

  @override
  String get weakPassword => 'Słabe hasło';

  @override
  String get mediumPassword => 'Średnie hasło';

  @override
  String get strongPassword => 'Silne hasło';

  @override
  String get edit => 'Edytuj';

  @override
  String get userOrEmail => 'Użytkownik / E-mail';

  @override
  String get website => 'Strona internetowa';

  @override
  String get field => 'Pole';

  @override
  String get newCategory => 'Nowa kategoria';

  @override
  String get language => 'Język';

  @override
  String get selectLanguage => 'Wybierz język';

  @override
  String passwordLength(int length) {
    return 'Długość hasła: $length';
  }

  @override
  String get passwordLengthHelper =>
      'Zawsze będzie zawierać co najmniej jedną wielką literę, małą literę, cyfrę i symbol.';

  @override
  String get newNameLabel => 'Nowa nazwa';

  @override
  String get criticalDanger => 'KRYTYCZNE ZAGROŻENIE!';

  @override
  String get csvExportWarning =>
      'UWAGA! Generowany plik CSV NIE jest szyfrowany. Każda osoba lub aplikacja z dostępem do Twojego telefonu będzie mogła zobaczyć Twoje hasła w postaci zwykłego tekstu. Zdecydowanie zaleca się przesłanie lub skopiowanie tego pliku w bezpieczne miejsce (np. na komputer osobisty) i natychmiastowe usunięcie go z folderu Pobrane w tym telefonie.';

  @override
  String get understandRiskSave => 'Rozumiem ryzyko, zapisz';

  @override
  String get csvExportSuccessNoCount =>
      'Hasła zostały pomyślnie wyeksportowane!';

  @override
  String csvExportError(String error) {
    return 'Błąd podczas zapisywania pliku: $error';
  }

  @override
  String get biometricReasonExport =>
      'Potwierdź swój odcisk palca, aby autoryzować eksport haseł.';

  @override
  String authError(String error) {
    return 'Błąd uwierzytelniania: $error';
  }

  @override
  String get authFailed => 'Uwierzytelnianie biometryczne nie powiodło się.';

  @override
  String get emptyKeychain => 'Pusty Sejf';

  @override
  String get emptyKeychainSubtitle =>
      'Dodaj konto za pomocą przycisku na dole (+) lub zaimportuj plik CSV z górnego menu.';

  @override
  String get noMatchesFound => 'Nie znaleziono pasujących wpisów.';

  @override
  String get favoritesHeader => 'Moje Ulubione';

  @override
  String get configureFieldTitle => 'Konfiguruj pole';

  @override
  String get fieldNameLabel => 'Nazwa';

  @override
  String get fieldValueLabel => 'Wartość';

  @override
  String get addNewFieldTitle => 'Dodaj nowe pole';

  @override
  String get fieldDate => 'Data';

  @override
  String get fieldWebAddress => 'Adres strony';

  @override
  String get fieldEmail => 'E-mail';

  @override
  String get fieldPin => 'PIN';

  @override
  String get logout => 'Wyloguj się';

  @override
  String get additionalNotes => 'Dodatkowe notatki';

  @override
  String get copyTooltip => 'Kopiuj';

  @override
  String get deleteFieldTooltip => 'Usuń pole';

  @override
  String get generatePasswordTooltip => 'Wygeneruj hasło';

  @override
  String get titleOrServiceName => 'Tytuł / Nazwa usługi';

  @override
  String get newCredential => 'Nowe dane logowania';

  @override
  String checkStorageError(String error) {
    return 'Błąd podczas sprawdzania stanu pamięci: $error';
  }

  @override
  String get fingerprintScanReason =>
      'Zeskanuj odcisk palca, aby uzyskać dostęp do menedżera haseł';

  @override
  String biometricAuthError(String error) {
    return 'Błąd uwierzytelniania biometrycznego: $error';
  }

  @override
  String get fingerprintSetupReason =>
      'Potwierdź odcisk palca, aby aktywować dostęp biometryczny';

  @override
  String get passwordEmpty => 'Hasło nie może być puste.';

  @override
  String get passwordsDoNotMatch => 'Hasła nie pasują do siebie.';

  @override
  String dbInitError(String error) {
    return 'Błąd podczas inicjowania bazy danych: $error';
  }

  @override
  String get enterMasterPasswordPrompt => 'Wprowadź hasło główne.';

  @override
  String get incorrectPasswordError => 'Nieprawidłowe hasło. Spróbuj ponownie.';

  @override
  String get importData => 'Importuj';

  @override
  String get exportData => 'Eksportuj';

  @override
  String get exportToKdbx => 'Eksportuj do KDBX';

  @override
  String get exportToJson => 'Export to JSON';

  @override
  String get exportJsonRecommended =>
      'For security, we recommend protecting this file with a password.';

  @override
  String get exportJsonSecureBtn => 'Eksportuj zaszyfrowany Json (Zalecane)';

  @override
  String get exportJsonPlainBtn =>
      'Eksportuj niezaszyfrowany Json (Nie zalecane)';

  @override
  String get exportKdbxDesc =>
      'Enter the master password for your new KeePass database.\n\nThis password will lock the .kdbx file and doesn\'t need to be the same as Cerberus\'.';

  @override
  String get passwordForFile => 'Password for file';

  @override
  String get importFormatsList =>
      'Możesz zaimportować następujące formaty:\n  - KDBX\n  - 1PUX\n  - Json\n  - XML\n  - CSV';

  @override
  String get historyTitle => 'Historia haseł';

  @override
  String get historyEmpty => 'Brak zapisanych starych haseł.';

  @override
  String get historyMainPassword => 'Hasło główne';

  @override
  String historyChangedAt(String date) {
    return 'Zmieniono $date';
  }

  @override
  String get historyCloseBtn => 'ZAMKNIJ';

  @override
  String get historyViewBtn => 'Zobacz historię';

  @override
  String get attachmentsTitle => 'Załączniki';

  @override
  String get localBackupTitle => 'Kopia zapasowa lokalna';

  @override
  String get localBackupSubtitle =>
      'Utwórz zaszyfrowany plik kopii zapasowej w wybranej lokalizacji lub przywróć kopię z pliku.';

  @override
  String get createLocalBackup => 'Utwórz zaszyfrowaną kopię';

  @override
  String get restoreLocalBackup => 'Przywróć zaszyfrowaną kopię';
}
