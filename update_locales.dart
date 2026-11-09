import 'dart:io';

void main() {
  final Map<String, String> texts = {
    'es': r'Puedes importar los siguientes formatos:\n  - KDBX\n  - 1PUX\n  - Json\n  - XML\n  - CSV',
    'en': r'You can import the following formats:\n  - KDBX\n  - 1PUX\n  - Json\n  - XML\n  - CSV',
    'fr': r'Vous pouvez importer les formats suivants :\n  - KDBX\n  - 1PUX\n  - Json\n  - XML\n  - CSV',
    'it': r'Puoi importare i seguenti formati:\n  - KDBX\n  - 1PUX\n  - Json\n  - XML\n  - CSV',
    'de': r'Sie können folgende Formate importieren:\n  - KDBX\n  - 1PUX\n  - Json\n  - XML\n  - CSV',
    'pt': r'Você pode importar os seguintes formatos:\n  - KDBX\n  - 1PUX\n  - Json\n  - XML\n  - CSV',
    'pl': r'Możesz zaimportować następujące formaty:\n  - KDBX\n  - 1PUX\n  - Json\n  - XML\n  - CSV',
  };

  for (final lang in texts.keys) {
    final file = File('lib/l10n/app_\$lang.arb');
    if (file.existsSync()) {
      var content = file.readAsStringSync();
      // Remove the last brace and any trailing whitespace
      content = content.trim();
      if (content.endsWith('}')) {
        content = content.substring(0, content.length - 1);
        content += ',\n  "importFormatsList": "' + texts[lang]! + '"\n}\n';
        file.writeAsStringSync(content);
        print('Updated \$lang');
      }
    }
  }
}
