import json
import os

texts = {
    'es': 'Importa tus credenciales desde KDBX, 1PUX, Json, XML y CSV. Exporta a KDBX, Json, XML y CSV.',
    'en': 'Import your credentials from KDBX, 1PUX, Json, XML and CSV. Export to KDBX, Json, XML and CSV.',
    'fr': 'Importez vos identifiants depuis KDBX, 1PUX, Json, XML et CSV. Exportez vers KDBX, Json, XML et CSV.',
    'it': 'Importa le tue credenziali da KDBX, 1PUX, Json, XML e CSV. Esporta in KDBX, Json, XML e CSV.',
    'de': 'Importieren Sie Ihre Anmeldeinformationen aus KDBX, 1PUX, Json, XML und CSV. Exportieren Sie nach KDBX, Json, XML und CSV.',
    'pt': 'Importe suas credenciais do KDBX, 1PUX, Json, XML e CSV. Exporte para KDBX, Json, XML e CSV.',
    'pl': 'Importuj swoje poświadczenia z KDBX, 1PUX, Json, XML i CSV. Eksportuj do KDBX, Json, XML i CSV.'
}

for lang, text in texts.items():
    path = f'lib/l10n/app_{lang}.arb'
    if os.path.exists(path):
        with open(path, 'r', encoding='utf-8') as f:
            data = json.load(f)
        
        data['premiumFeatureCsvSubtitle'] = text
        
        with open(path, 'w', encoding='utf-8') as f:
            json.dump(data, f, ensure_ascii=False, indent=2)
        print(f'Updated {lang}')
