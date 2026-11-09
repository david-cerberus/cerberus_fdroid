// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get sessionClosedInactivity => 'Session fermée pour inactivité.';

  @override
  String get sessionClosedInactivityFiveMin =>
      'Session fermée après 5 minutes d\'inactivité.';

  @override
  String get enableFingerprintTitle => 'Activer l\'empreinte digitale ?';

  @override
  String get enableFingerprintContent =>
      'Souhaitez-vous activer l\'accès rapide avec l\'empreinte digitale pour les prochaines fois ?';

  @override
  String get noThanks => 'Non, merci';

  @override
  String get yesEnable => 'Oui, activer';

  @override
  String get biometricEnabledSuccess => 'Accès biométrique activé avec succès.';

  @override
  String biometricEnabledError(String error) {
    return 'Impossible d\'activer l\'accès biométrique : $error';
  }

  @override
  String errorLoadingEntries(String error) {
    return 'Erreur lors du chargement des entrées : $error';
  }

  @override
  String csvImportSuccess(int count) {
    return 'Succès ! $count mots de passe ont été importés.';
  }

  @override
  String csvImportError(String error) {
    return 'Erreur lors de l\'importation du CSV : $error';
  }

  @override
  String errorAdding(String error) {
    return 'Erreur lors de l\'ajout : $error';
  }

  @override
  String errorUpdating(String error) {
    return 'Erreur lors de la mise à jour : $error';
  }

  @override
  String errorDeleting(String error) {
    return 'Erreur lors de la suppression : $error';
  }

  @override
  String copiedToClipboard(String label) {
    return '$label copié dans le presse-papiers !';
  }

  @override
  String get addCustomField => 'Ajouter un champ personnalisé';

  @override
  String get titleRequired => 'Le titre est obligatoire';

  @override
  String get deleteCredentialTitle => 'Supprimer l\'identifiant ?';

  @override
  String get deleteCredentialContent =>
      'L\'identifiant sera déplacé vers la corbeille. Vous pourrez le restaurer à tout moment.';

  @override
  String get cancel => 'Annuler';

  @override
  String get delete => 'Supprimer';

  @override
  String get manageCategories => 'Gérer les catégories';

  @override
  String get categoryExists => 'Cette catégorie existe déjà.';

  @override
  String get close => 'Fermer';

  @override
  String get renameCategory => 'Renommer la catégorie';

  @override
  String get save => 'Enregistrer';

  @override
  String get passwordPattern => 'Générateur de Mots de Passe';

  @override
  String get customPatternSaved => 'Générateur enregistré avec succès !';

  @override
  String get biometricRequiredExport =>
      'L\'authentification biométrique est obligatoire pour l\'exportation et n\'est pas disponible sur cet appareil.';

  @override
  String get search => 'Rechercher...';

  @override
  String get editCredential => 'Modifier l\'identifiant';

  @override
  String get username => 'Nom d\'utilisateur';

  @override
  String get password => 'Mot de passe';

  @override
  String get websiteUrl => 'Site Web / URL';

  @override
  String get notes => 'Notes';

  @override
  String get category => 'Catégorie';

  @override
  String get categoryGeneral => 'Général';

  @override
  String get globalSecurityScore => 'Score de sécurité global';

  @override
  String weakPasswordsCount(int count) {
    return '$count mots de passe faibles';
  }

  @override
  String get weakPasswordsSubtitle =>
      'Longueur inférieure à 8 caractères ou très communs';

  @override
  String get noWeakPasswords => 'Excellent ! Aucun mot de passe faible.';

  @override
  String reusedPasswordsCount(int count) {
    return '$count mots de passe réutilisés';
  }

  @override
  String get reusedPasswordsSubtitle =>
      'Même mot de passe sur plusieurs comptes';

  @override
  String get noReusedPasswords =>
      'Excellent ! Chaque compte a un mot de passe unique.';

  @override
  String accountsUsePassword(int count) {
    return '$count comptes utilisent ce mot de passe';
  }

  @override
  String securePasswordsCount(int count) {
    return '$count mots de passe ultra sécurisés';
  }

  @override
  String get strongPasswordsSubtitle => 'Uniques et robustes';

  @override
  String get noStrongPasswords =>
      'Vous n\'avez pas encore de mots de passe forts.';

  @override
  String get writeTitleGenerate =>
      'Veuillez d\'abord saisir le titre pour générer le mot de passe.';

  @override
  String get passwordGeneratorTitle => 'Générateur de Mots de Passe';

  @override
  String get generatorExplanation =>
      'Sera généré en fonction de votre structure sécurisée.';

  @override
  String get regenerate => 'Régénérer';

  @override
  String get accept => 'Accepter';

  @override
  String get securityHealthTitle => 'Bilan de sécurité de mes mots de passe';

  @override
  String get exportCsv => 'Exporter en CSV';

  @override
  String get exportXml => 'Exporter en XML';

  @override
  String get createMasterPassword => 'Créer un mot de passe principal';

  @override
  String get enterMasterPassword => 'Saisir le mot de passe principal';

  @override
  String get registerSubtitle =>
      'Définissez un mot de passe principal fort pour protéger vos données. Il ne pourra pas être récupéré si vous l\'oubliez.';

  @override
  String get loginSubtitle =>
      'Ce mot de passe est utilisé pour déchiffrer votre base de données locale.';

  @override
  String get masterPasswordLabel => 'Mot de passe principal';

  @override
  String get confirmPasswordLabel => 'Confirmer le mot de passe';

  @override
  String get registerSave => 'S\'enregistrer et sauvegarder';

  @override
  String get unlock => 'Déverrouiller';

  @override
  String unexpectedError(String error) {
    return 'Erreur inattendue : $error';
  }

  @override
  String logoutError(String error) {
    return 'Erreur lors de la déconnexion : $error';
  }

  @override
  String get lightTheme => 'Thème Clair';

  @override
  String get darkTheme => 'Thème Sombre';

  @override
  String get categoryAll => 'Tous';

  @override
  String get categoryBanks => 'Banques';

  @override
  String get categoryWebAccounts => 'Comptes Web';

  @override
  String get categoryEmails => 'E-mails';

  @override
  String get categoryForums => 'Forums';

  @override
  String get categoryRouter => 'Routeur';

  @override
  String get categoryStore => 'Boutique';

  @override
  String get categoryOthers => 'Autres';

  @override
  String get weakPassword => 'Mot de passe faible';

  @override
  String get mediumPassword => 'Mot de passe moyen';

  @override
  String get strongPassword => 'Mot de passe fort';

  @override
  String get edit => 'Modifier';

  @override
  String get userOrEmail => 'Utilisateur / E-mail';

  @override
  String get website => 'Site Web';

  @override
  String get field => 'Champ';

  @override
  String get newCategory => 'Nouvelle catégorie';

  @override
  String get language => 'Langue';

  @override
  String get selectLanguage => 'Sélectionner la langue';

  @override
  String passwordLength(int length) {
    return 'Longueur du mot de passe : $length';
  }

  @override
  String get passwordLengthHelper =>
      'Un mot de passe contient toujours au moins une majuscule, une minuscule, un chiffre et un symbole.';

  @override
  String get newNameLabel => 'Nouveau nom';

  @override
  String get criticalDanger => 'DANGER CRITIQUE !';

  @override
  String get csvExportWarning =>
      'ATTENTION ! Le fichier CSV que vous allez générer n\'est PAS chiffré. Toute personne ou application ayant accès à votre téléphone pourra voir vos mots de passe en texte clair. Il est fortement recommandé d\'envoyer ou de copier ce fichier vers un emplacement sécurisé (comme votre ordinateur personnel) et de le supprimer immédiatement du dossier Téléchargements de ce téléphone.';

  @override
  String get understandRiskSave => 'Je comprends le risque, enregistrer';

  @override
  String get csvExportSuccessNoCount => 'Mots de passe exportés avec succès !';

  @override
  String csvExportError(String error) {
    return 'Erreur lors de l\'enregistrement du fichier : $error';
  }

  @override
  String get biometricReasonExport =>
      'Confirmez votre empreinte digitale pour autoriser l\'exportation de vos mots de passe.';

  @override
  String authError(String error) {
    return 'Erreur d\'authentification : $error';
  }

  @override
  String get authFailed => 'L\'authentification biométrique a échoué.';

  @override
  String get emptyKeychain => 'Coffre-fort Vide';

  @override
  String get emptyKeychainSubtitle =>
      'Ajoutez un compte en utilisant le bouton du bas (+) ou importez un fichier CSV depuis le menu supérieur.';

  @override
  String get noMatchesFound => 'Aucune correspondance trouvée.';

  @override
  String get favoritesHeader => 'Mes Favoris';

  @override
  String get configureFieldTitle => 'Configurer le champ';

  @override
  String get fieldNameLabel => 'Nom';

  @override
  String get fieldValueLabel => 'Valeur';

  @override
  String get addNewFieldTitle => 'Ajouter un nouveau champ';

  @override
  String get fieldDate => 'Date';

  @override
  String get fieldWebAddress => 'Adresse Web';

  @override
  String get fieldEmail => 'E-mail';

  @override
  String get fieldPin => 'Code PIN';

  @override
  String get logout => 'Se déconnecter';

  @override
  String get additionalNotes => 'Notes additionnelles';

  @override
  String get copyTooltip => 'Copier';

  @override
  String get deleteFieldTooltip => 'Supprimer le champ';

  @override
  String get generatePasswordTooltip => 'Générer un mot de passe';

  @override
  String get titleOrServiceName => 'Titre / Nom du service';

  @override
  String get newCredential => 'Nouvel identifiant';

  @override
  String checkStorageError(String error) {
    return 'Erreur lors de la vérification de l\'état du stockage : $error';
  }

  @override
  String get fingerprintScanReason =>
      'Scannez votre empreinte digitale pour accéder à votre gestionnaire de mots de passe';

  @override
  String biometricAuthError(String error) {
    return 'Erreur d\'authentification biométrique : $error';
  }

  @override
  String get fingerprintSetupReason =>
      'Confirmez votre empreinte digitale pour activer l\'accès biométrique';

  @override
  String get passwordEmpty => 'Le mot de passe ne peut pas être vide.';

  @override
  String get passwordsDoNotMatch => 'Les mots de passe ne correspondent pas.';

  @override
  String dbInitError(String error) {
    return 'Erreur lors de l\'initialisation de la base de données : $error';
  }

  @override
  String get enterMasterPasswordPrompt =>
      'Veuillez saisir votre mot de passe principal.';

  @override
  String get incorrectPasswordError =>
      'Mot de passe incorrect. Veuillez réessayer.';

  @override
  String get importData => 'Importer';

  @override
  String get exportData => 'Exporter';

  @override
  String get exportToKdbx => 'Exporter vers KDBX';

  @override
  String get exportToJson => 'Export to JSON';

  @override
  String get exportJsonRecommended =>
      'For security, we recommend protecting this file with a password.';

  @override
  String get exportJsonSecureBtn => 'Exporter le Json chiffré (Recommandé)';

  @override
  String get exportJsonPlainBtn =>
      'Exporter le Json non chiffré (Non recommandé)';

  @override
  String get exportKdbxDesc =>
      'Enter the master password for your new KeePass database.\n\nThis password will lock the .kdbx file and doesn\'t need to be the same as Cerberus\'.';

  @override
  String get passwordForFile => 'Password for file';

  @override
  String get importFormatsList =>
      'Vous pouvez importer les formats suivants :\n  - KDBX\n  - 1PUX\n  - Json\n  - XML\n  - CSV';

  @override
  String get historyTitle => 'Historique des mots de passe';

  @override
  String get historyEmpty => 'Aucun ancien mot de passe enregistré.';

  @override
  String get historyMainPassword => 'Mot de passe principal';

  @override
  String historyChangedAt(String date) {
    return 'Modifié le $date';
  }

  @override
  String get historyCloseBtn => 'FERMER';

  @override
  String get historyViewBtn => 'Voir l\'historique';

  @override
  String get attachmentsTitle => 'Pièces jointes';

  @override
  String get localBackupTitle => 'Sauvegarde locale';

  @override
  String get localBackupSubtitle =>
      'Créez un fichier de sauvegarde chiffré à l\'emplacement de votre choix ou restaurez-en un depuis un fichier.';

  @override
  String get createLocalBackup => 'Créer une sauvegarde chiffrée';

  @override
  String get restoreLocalBackup => 'Restaurer une sauvegarde chiffrée';
}
