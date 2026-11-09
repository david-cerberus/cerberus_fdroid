import json
import os

new_strings = {
    'es': {
        'attachmentsTitle': 'Archivos Adjuntos',
        'openingFile': 'Abriendo archivo...',
        'attachmentSaved': 'Adjunto guardado',
        'scanTotpQr': 'Escanear QR TOTP',
        'totpSecretLabel': 'Secreto TOTP (Base32) opcional',
        'pasteFromClipboard': 'Pegar desde portapapeles',
        'scanQrTooltip': 'Escanear QR',
        'processingFile': 'Procesando...',
        'addBtn': 'Añadir',
        'closeBtn': 'Cerrar'
    },
    'en': {
        'attachmentsTitle': 'Attachments',
        'openingFile': 'Opening file...',
        'attachmentSaved': 'Attachment saved',
        'scanTotpQr': 'Scan TOTP QR',
        'totpSecretLabel': 'TOTP Secret (Base32) optional',
        'pasteFromClipboard': 'Paste from clipboard',
        'scanQrTooltip': 'Scan QR',
        'processingFile': 'Processing...',
        'addBtn': 'Add',
        'closeBtn': 'Close'
    },
    'fr': {
        'attachmentsTitle': 'Pièces jointes',
        'openingFile': 'Ouverture du fichier...',
        'attachmentSaved': 'Pièce jointe enregistrée',
        'scanTotpQr': 'Scanner le QR TOTP',
        'totpSecretLabel': 'Secret TOTP (Base32) optionnel',
        'pasteFromClipboard': 'Coller depuis le presse-papiers',
        'scanQrTooltip': 'Scanner le QR',
        'processingFile': 'Traitement...',
        'addBtn': 'Ajouter',
        'closeBtn': 'Fermer'
    },
    'it': {
        'attachmentsTitle': 'Allegati',
        'openingFile': 'Apertura file...',
        'attachmentSaved': 'Allegato salvato',
        'scanTotpQr': 'Scansiona QR TOTP',
        'totpSecretLabel': 'Segreto TOTP (Base32) opzionale',
        'pasteFromClipboard': 'Incolla dagli appunti',
        'scanQrTooltip': 'Scansiona QR',
        'processingFile': 'Elaborazione...',
        'addBtn': 'Aggiungi',
        'closeBtn': 'Chiudi'
    },
    'de': {
        'attachmentsTitle': 'Anhänge',
        'openingFile': 'Datei wird geöffnet...',
        'attachmentSaved': 'Anhang gespeichert',
        'scanTotpQr': 'TOTP QR scannen',
        'totpSecretLabel': 'TOTP-Geheimnis (Base32) optional',
        'pasteFromClipboard': 'Aus Zwischenablage einfügen',
        'scanQrTooltip': 'QR scannen',
        'processingFile': 'Verarbeitung...',
        'addBtn': 'Hinzufügen',
        'closeBtn': 'Schließen'
    },
    'pt': {
        'attachmentsTitle': 'Anexos',
        'openingFile': 'Abrindo arquivo...',
        'attachmentSaved': 'Anexo salvo',
        'scanTotpQr': 'Escanear QR TOTP',
        'totpSecretLabel': 'Segredo TOTP (Base32) opcional',
        'pasteFromClipboard': 'Colar da área de transferência',
        'scanQrTooltip': 'Escanear QR',
        'processingFile': 'Processando...',
        'addBtn': 'Adicionar',
        'closeBtn': 'Fechar'
    },
    'pl': {
        'attachmentsTitle': 'Załączniki',
        'openingFile': 'Otwieranie pliku...',
        'attachmentSaved': 'Załącznik zapisany',
        'scanTotpQr': 'Skanuj kod QR TOTP',
        'totpSecretLabel': 'Sekret TOTP (Base32) opcjonalnie',
        'pasteFromClipboard': 'Wklej ze schowka',
        'scanQrTooltip': 'Skanuj kod QR',
        'processingFile': 'Przetwarzanie...',
        'addBtn': 'Dodaj',
        'closeBtn': 'Zamknij'
    }
}

for lang, strings in new_strings.items():
    path = f'lib/l10n/app_{lang}.arb'
    if os.path.exists(path):
        with open(path, 'r', encoding='utf-8') as f:
            data = json.load(f)
        
        for key, text in strings.items():
            data[key] = text
            
        with open(path, 'w', encoding='utf-8') as f:
            json.dump(data, f, ensure_ascii=False, indent=2)
        print(f'Updated {lang}')
