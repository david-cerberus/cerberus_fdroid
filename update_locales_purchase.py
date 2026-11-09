import json
import os

new_strings = {
    'es': {'noPreviousPurchases': 'No se encontraron compras anteriores en esta cuenta de Google.'},
    'en': {'noPreviousPurchases': 'No previous purchases found on this Google account.'},
    'fr': {'noPreviousPurchases': "Aucun achat précédent n'a été trouvé sur ce compte Google."},
    'it': {'noPreviousPurchases': 'Nessun acquisto precedente trovato su questo account Google.'},
    'de': {'noPreviousPurchases': 'Es wurden keine vorherigen Käufe in diesem Google-Konto gefunden.'},
    'pt': {'noPreviousPurchases': 'Nenhuma compra anterior encontrada nesta conta do Google.'},
    'pl': {'noPreviousPurchases': 'Nie znaleziono wcześniejszych zakupów na tym koncie Google.'}
}

l10n_dir = 'lib/l10n'
for lang, strings in new_strings.items():
    file_path = os.path.join(l10n_dir, f'app_{lang}.arb')
    if os.path.exists(file_path):
        with open(file_path, 'r', encoding='utf-8') as f:
            data = json.load(f)
        for key, value in strings.items():
            data[key] = value
        with open(file_path, 'w', encoding='utf-8') as f:
            json.dump(data, f, ensure_ascii=False, indent=2)

print('Locales updated!')

for filepath in ['lib/screens/home_screen.dart', 'lib/widgets/premium_gate.dart']:
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
    
    target = '''content: const Text('No se encontraron compras anteriores en esta cuenta de Google.')'''
    replace = '''content: Text(AppLocalizations.of(context)!.noPreviousPurchases)'''
    if target in content:
        content = content.replace(target, replace)
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(content)
        print(f'Updated {filepath}')
