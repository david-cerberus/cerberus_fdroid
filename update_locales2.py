import json
import os

btn_texts = {
    'es': {
        'exportJsonPlainBtn': 'Exportar Json sin cifrar (No recomendado)',
        'exportJsonSecureBtn': 'Exportar Json cifrado (Recomendado)'
    },
    'en': {
        'exportJsonPlainBtn': 'Export unencrypted Json (Not recommended)',
        'exportJsonSecureBtn': 'Export encrypted Json (Recommended)'
    },
    'fr': {
        'exportJsonPlainBtn': 'Exporter le Json non chiffré (Non recommandé)',
        'exportJsonSecureBtn': 'Exporter le Json chiffré (Recommandé)'
    },
    'it': {
        'exportJsonPlainBtn': 'Esporta Json non crittografato (Non consigliato)',
        'exportJsonSecureBtn': 'Esporta Json crittografato (Consigliato)'
    },
    'de': {
        'exportJsonPlainBtn': 'Unverschlüsseltes Json exportieren (Nicht empfohlen)',
        'exportJsonSecureBtn': 'Verschlüsseltes Json exportieren (Empfohlen)'
    },
    'pt': {
        'exportJsonPlainBtn': 'Exportar Json sem criptografia (Não recomendado)',
        'exportJsonSecureBtn': 'Exportar Json criptografado (Recomendado)'
    },
    'pl': {
        'exportJsonPlainBtn': 'Eksportuj niezaszyfrowany Json (Nie zalecane)',
        'exportJsonSecureBtn': 'Eksportuj zaszyfrowany Json (Zalecane)'
    }
}

for lang, texts in btn_texts.items():
    path = f'lib/l10n/app_{lang}.arb'
    if os.path.exists(path):
        with open(path, 'r', encoding='utf-8') as f:
            data = json.load(f)
        
        # update the buttons
        data['exportJsonPlainBtn'] = texts['exportJsonPlainBtn']
        data['exportJsonSecureBtn'] = texts['exportJsonSecureBtn']
        
        # fix the \n\n in exportKdbxDesc
        if 'exportKdbxDesc' in data:
            data['exportKdbxDesc'] = data['exportKdbxDesc'].replace('\\n\\n', '\n\n')
            
        with open(path, 'w', encoding='utf-8') as f:
            json.dump(data, f, ensure_ascii=False, indent=2)
        print(f'Updated {lang}')
