import json
import os

texts = {
    'es': {
        'historyTitle': 'Historial de Contraseñas',
        'historyEmpty': 'No hay contraseñas antiguas guardadas.',
        'historyCopied': 'Copiada al portapapeles',
        'historyMainPassword': 'Contraseña Principal',
        'historyChangedAt': 'Cambiada el {date}',
        'historyCloseBtn': 'CERRAR',
        'historyViewBtn': 'Ver historial'
    },
    'en': {
        'historyTitle': 'Password History',
        'historyEmpty': 'No old passwords saved.',
        'historyCopied': 'Copied to clipboard',
        'historyMainPassword': 'Main Password',
        'historyChangedAt': 'Changed on {date}',
        'historyCloseBtn': 'CLOSE',
        'historyViewBtn': 'View history'
    },
    'fr': {
        'historyTitle': 'Historique des mots de passe',
        'historyEmpty': 'Aucun ancien mot de passe enregistré.',
        'historyCopied': 'Copié dans le presse-papiers',
        'historyMainPassword': 'Mot de passe principal',
        'historyChangedAt': 'Modifié le {date}',
        'historyCloseBtn': 'FERMER',
        'historyViewBtn': 'Voir l\'historique'
    },
    'de': {
        'historyTitle': 'Passwort-Verlauf',
        'historyEmpty': 'Keine alten Passwörter gespeichert.',
        'historyCopied': 'In die Zwischenablage kopiert',
        'historyMainPassword': 'Hauptpasswort',
        'historyChangedAt': 'Geändert am {date}',
        'historyCloseBtn': 'SCHLIESSEN',
        'historyViewBtn': 'Verlauf ansehen'
    },
    'it': {
        'historyTitle': 'Cronologia password',
        'historyEmpty': 'Nessuna vecchia password salvata.',
        'historyCopied': 'Copiato negli appunti',
        'historyMainPassword': 'Password principale',
        'historyChangedAt': 'Modificata il {date}',
        'historyCloseBtn': 'CHIUDI',
        'historyViewBtn': 'Vedi cronologia'
    },
    'pt': {
        'historyTitle': 'Histórico de Senhas',
        'historyEmpty': 'Nenhuma senha antiga salva.',
        'historyCopied': 'Copiado para a área de transferência',
        'historyMainPassword': 'Senha Principal',
        'historyChangedAt': 'Alterada em {date}',
        'historyCloseBtn': 'FECHAR',
        'historyViewBtn': 'Ver histórico'
    },
    'pl': {
        'historyTitle': 'Historia haseł',
        'historyEmpty': 'Brak zapisanych starych haseł.',
        'historyCopied': 'Skopiowano do schowka',
        'historyMainPassword': 'Hasło główne',
        'historyChangedAt': 'Zmieniono {date}',
        'historyCloseBtn': 'ZAMKNIJ',
        'historyViewBtn': 'Zobacz historię'
    }
}

l10n_dir = os.path.join('lib', 'l10n')

for lang, new_keys in texts.items():
    file_path = os.path.join(l10n_dir, f'app_{lang}.arb')
    if os.path.exists(file_path):
        with open(file_path, 'r', encoding='utf-8') as f:
            data = json.load(f)
        
        for key, val in new_keys.items():
            data[key] = val
            
        with open(file_path, 'w', encoding='utf-8') as f:
            json.dump(data, f, ensure_ascii=False, indent=2)
        print(f"Updated app_{lang}.arb")

# Update english placeholders for historyChangedAt
en_file = os.path.join(l10n_dir, 'app_en.arb')
with open(en_file, 'r', encoding='utf-8') as f:
    data = json.load(f)

if '@historyChangedAt' not in data:
    data['@historyChangedAt'] = {
        'placeholders': {
            'date': {
                'type': 'String'
            }
        }
    }
    with open(en_file, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=2)
    print("Updated app_en.arb with placeholders")
