// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get sessionClosedInactivity => 'Sessão encerrada por inatividade.';

  @override
  String get sessionClosedInactivityFiveMin =>
      'Sessão encerrada por inatividade de 5 minutos.';

  @override
  String get enableFingerprintTitle => 'Ativar Impressão Digital?';

  @override
  String get enableFingerprintContent =>
      'Deseja ativar o acesso rápido por impressão digital para as próximas vezes?';

  @override
  String get noThanks => 'Não, obrigado';

  @override
  String get yesEnable => 'Sim, ativar';

  @override
  String get biometricEnabledSuccess =>
      'Acesso biométrico ativado com sucesso.';

  @override
  String biometricEnabledError(String error) {
    return 'Não foi possível ativar o acesso biométrico: $error';
  }

  @override
  String errorLoadingEntries(String error) {
    return 'Erro ao carregar entradas: $error';
  }

  @override
  String csvImportSuccess(int count) {
    return 'Sucesso! $count senhas foram importadas.';
  }

  @override
  String csvImportError(String error) {
    return 'Erro ao importar CSV: $error';
  }

  @override
  String errorAdding(String error) {
    return 'Erro ao adicionar: $error';
  }

  @override
  String errorUpdating(String error) {
    return 'Erro ao atualizar: $error';
  }

  @override
  String errorDeleting(String error) {
    return 'Erro ao excluir: $error';
  }

  @override
  String copiedToClipboard(String label) {
    return '$label copiado para a área de transferência!';
  }

  @override
  String get addCustomField => 'Adicionar campo personalizado';

  @override
  String get titleRequired => 'O título é obrigatório';

  @override
  String get deleteCredentialTitle => 'Excluir Credencial?';

  @override
  String get deleteCredentialContent =>
      'A credencial será movida para a lixeira. Pode restaurá-la quando quiser.';

  @override
  String get cancel => 'Cancelar';

  @override
  String get delete => 'Excluir';

  @override
  String get manageCategories => 'Gerenciar Categorias';

  @override
  String get categoryExists => 'Esta categoria já existe.';

  @override
  String get close => 'Fechar';

  @override
  String get renameCategory => 'Renomear Categoria';

  @override
  String get save => 'Salvar';

  @override
  String get passwordPattern => 'Gerador de Senhas';

  @override
  String get customPatternSaved => 'Gerador salvo com sucesso!';

  @override
  String get biometricRequiredExport =>
      'A autenticação biométrica é obrigatória para exportar e não está disponível neste dispositivo.';

  @override
  String get search => 'Buscar...';

  @override
  String get editCredential => 'Editar Credencial';

  @override
  String get username => 'Usuário';

  @override
  String get password => 'Senha';

  @override
  String get websiteUrl => 'Site / URL';

  @override
  String get notes => 'Notas';

  @override
  String get category => 'Categoria';

  @override
  String get categoryGeneral => 'Geral';

  @override
  String get globalSecurityScore => 'Pontuação de Segurança Global';

  @override
  String weakPasswordsCount(int count) {
    return '$count Senhas Fracas';
  }

  @override
  String get weakPasswordsSubtitle =>
      'Comprimento inferior a 8 ou muito comuns';

  @override
  String get noWeakPasswords => 'Excelente! Você não tem senhas fracas.';

  @override
  String reusedPasswordsCount(int count) {
    return '$count Senhas Reutilizadas';
  }

  @override
  String get reusedPasswordsSubtitle => 'Mesma senha em várias contas';

  @override
  String get noReusedPasswords =>
      'Excelente! Cada conta possui uma senha única.';

  @override
  String accountsUsePassword(int count) {
    return '$count contas usam esta senha';
  }

  @override
  String securePasswordsCount(int count) {
    return '$count Senhas Super Seguras';
  }

  @override
  String get strongPasswordsSubtitle => 'Únicas e robustas';

  @override
  String get noStrongPasswords => 'Você ainda não tem senhas fortes.';

  @override
  String get writeTitleGenerate =>
      'Por favor, insira o título primeiro para gerar a senha.';

  @override
  String get passwordGeneratorTitle => 'Gerador de Senhas';

  @override
  String get generatorExplanation =>
      'Será gerada com base no seu padrão estrutural seguro.';

  @override
  String get regenerate => 'Regerar';

  @override
  String get accept => 'Aceitar';

  @override
  String get securityHealthTitle => 'Saúde das Minhas Senhas';

  @override
  String get exportCsv => 'Exportar para CSV';

  @override
  String get exportXml => 'Exportar para XML';

  @override
  String get createMasterPassword => 'Criar Senha Mestra';

  @override
  String get enterMasterPassword => 'Digitar Senha Mestra';

  @override
  String get registerSubtitle =>
      'Defina uma senha forte para proteger seus dados. Ela não poderá ser recuperada se for esquecida.';

  @override
  String get loginSubtitle =>
      'Esta senha é usada para descriptografar seu banco de dados local.';

  @override
  String get masterPasswordLabel => 'Senha Mestra';

  @override
  String get confirmPasswordLabel => 'Confirmar Senha';

  @override
  String get registerSave => 'Registrar e Salvar';

  @override
  String get unlock => 'Desbloquear';

  @override
  String unexpectedError(String error) {
    return 'Erro inesperado: $error';
  }

  @override
  String logoutError(String error) {
    return 'Erro ao sair: $error';
  }

  @override
  String get lightTheme => 'Tema Claro';

  @override
  String get darkTheme => 'Tema Escuro';

  @override
  String get categoryAll => 'Todos';

  @override
  String get categoryBanks => 'Bancos';

  @override
  String get categoryWebAccounts => 'Contas Web';

  @override
  String get categoryEmails => 'E-mails';

  @override
  String get categoryForums => 'Fóruns';

  @override
  String get categoryRouter => 'Roteador';

  @override
  String get categoryStore => 'Loja';

  @override
  String get categoryOthers => 'Outros';

  @override
  String get weakPassword => 'Senha fraca';

  @override
  String get mediumPassword => 'Senha média';

  @override
  String get strongPassword => 'Senha forte';

  @override
  String get edit => 'Editar';

  @override
  String get userOrEmail => 'Usuário / E-mail';

  @override
  String get website => 'Site';

  @override
  String get field => 'Campo';

  @override
  String get newCategory => 'Nova categoria';

  @override
  String get language => 'Idioma';

  @override
  String get selectLanguage => 'Selecionar Idioma';

  @override
  String passwordLength(int length) {
    return 'Comprimento da senha: $length';
  }

  @override
  String get passwordLengthHelper =>
      'Sempre incluirá pelo menos uma letra maiúscula, uma minúscula, um número e um símbolo.';

  @override
  String get newNameLabel => 'Novo nome';

  @override
  String get criticalDanger => 'PERIGO CRÍTICO!';

  @override
  String get csvExportWarning =>
      'ATENÇÃO! O arquivo CSV que você vai gerar NÃO está criptografado. Qualquer pessoa ou aplicativo com acesso ao seu celular poderá ver suas senhas em texto limpo. Recomenda-se fortemente transferir ou copiar este arquivo para um local seguro (como seu computador pessoal) e apagá-lo imediatamente da pasta de Downloads deste celular.';

  @override
  String get understandRiskSave => 'Entendo o risco, salvar';

  @override
  String get csvExportSuccessNoCount => 'Senhas exportadas com sucesso!';

  @override
  String csvExportError(String error) {
    return 'Erro ao salvar o arquivo: $error';
  }

  @override
  String get biometricReasonExport =>
      'Confirme sua impressão digital para autorizar a exportação das suas senhas.';

  @override
  String authError(String error) {
    return 'Erro de autenticação: $error';
  }

  @override
  String get authFailed => 'Autenticação biométrica falhou.';

  @override
  String get emptyKeychain => 'Chaveiro Vazio';

  @override
  String get emptyKeychainSubtitle =>
      'Adicione uma conta usando o botão inferior (+) ou importe um arquivo CSV no menu superior.';

  @override
  String get noMatchesFound => 'Nenhuma correspondência encontrada.';

  @override
  String get favoritesHeader => 'Meus Favoritos';

  @override
  String get configureFieldTitle => 'Configurar Campo';

  @override
  String get fieldNameLabel => 'Nome';

  @override
  String get fieldValueLabel => 'Valor';

  @override
  String get addNewFieldTitle => 'Adicionar novo campo';

  @override
  String get fieldDate => 'Data';

  @override
  String get fieldWebAddress => 'Endereço Web';

  @override
  String get fieldEmail => 'E-mail';

  @override
  String get fieldPin => 'PIN';

  @override
  String get logout => 'Sair';

  @override
  String get additionalNotes => 'Notas adicionais';

  @override
  String get copyTooltip => 'Copiar';

  @override
  String get deleteFieldTooltip => 'Excluir campo';

  @override
  String get generatePasswordTooltip => 'Gerar senha';

  @override
  String get titleOrServiceName => 'Título / Nome do serviço';

  @override
  String get newCredential => 'Nova Credencial';

  @override
  String checkStorageError(String error) {
    return 'Erro ao verificar o estado do armazenamento: $error';
  }

  @override
  String get fingerprintScanReason =>
      'Escaneie sua digital para acessar seu gerenciador de senhas';

  @override
  String biometricAuthError(String error) {
    return 'Erro na autenticação biométrica: $error';
  }

  @override
  String get fingerprintSetupReason =>
      'Confirme sua digital para ativar o acesso biométrico';

  @override
  String get passwordEmpty => 'A senha não pode estar vazia.';

  @override
  String get passwordsDoNotMatch => 'As senhas não coincidem.';

  @override
  String dbInitError(String error) {
    return 'Erro ao inicializar o banco de dados: $error';
  }

  @override
  String get enterMasterPasswordPrompt => 'Por favor, insira sua senha mestra.';

  @override
  String get incorrectPasswordError => 'Senha incorreta. Tente novamente.';

  @override
  String get importData => 'Importar';

  @override
  String get exportData => 'Exportar';

  @override
  String get exportToKdbx => 'Exportar para KDBX';

  @override
  String get exportToJson => 'Export to JSON';

  @override
  String get exportJsonRecommended =>
      'For security, we recommend protecting this file with a password.';

  @override
  String get exportJsonSecureBtn => 'Exportar Json criptografado (Recomendado)';

  @override
  String get exportJsonPlainBtn =>
      'Exportar Json sem criptografia (Não recomendado)';

  @override
  String get exportKdbxDesc =>
      'Enter the master password for your new KeePass database.\n\nThis password will lock the .kdbx file and doesn\'t need to be the same as Cerberus\'.';

  @override
  String get passwordForFile => 'Password for file';

  @override
  String get importFormatsList =>
      'Você pode importar os seguintes formatos:\n  - KDBX\n  - 1PUX\n  - Json\n  - XML\n  - CSV';

  @override
  String get historyTitle => 'Histórico de Senhas';

  @override
  String get historyEmpty => 'Nenhuma senha antiga salva.';

  @override
  String get historyMainPassword => 'Senha Principal';

  @override
  String historyChangedAt(String date) {
    return 'Alterada em $date';
  }

  @override
  String get historyCloseBtn => 'FECHAR';

  @override
  String get historyViewBtn => 'Ver histórico';

  @override
  String get attachmentsTitle => 'Anexos';

  @override
  String get localBackupTitle => 'Cópia de segurança local';

  @override
  String get localBackupSubtitle =>
      'Crie um ficheiro de cópia de segurança cifrado na localização que escolher ou restaure uma a partir de um ficheiro.';

  @override
  String get createLocalBackup => 'Criar cópia cifrada';

  @override
  String get restoreLocalBackup => 'Restaurar cópia cifrada';
}
