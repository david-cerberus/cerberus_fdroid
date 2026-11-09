# Reglas del Proyecto CERBERUS

- **Revisión y actualización obligatoria del CHANGELOG**: 
  1. Al inicio de cada conversación o antes de realizar cambios o responder sobre el estado del proyecto, DEBES revisar siempre el archivo `CHANGELOG.md` ([CHANGELOG.md](file:///c:/Users/el_de/.gemini/antigravity-ide/scratch/CERBERUS/CHANGELOG.md)) para conocer el historial completo de versiones, novedades y cambios previos del proyecto.
  2. Cada vez que implementes nuevos cambios, corrijas errores o incrementes la versión/build de la app, DEBES actualizar inmediatamente el archivo `CHANGELOG.md` documentando las novedades y mejoras realizadas.

- **Comando "compila en aab"**: Cuando el usuario solicite "compila en aab", debes:
  1. Incrementar la versión en `pubspec.yaml` (ej. subir la versión de `1.1.0` a `1.1.1`) y también incrementar el número de build (el número después del `+`).
  2. Compilar la aplicación en formato App Bundle (`.aab`).
  3. Mover/copiar el archivo `.aab` resultante a la carpeta `G:\Mi unidad\APPs\Cerberus\archivos`.

- **Mantenimiento obligatorio de RESUMEN APP.txt**: 
  Cada vez que se realice cualquier cambio, mejora, refactorización, adición de dependencias o alteración en la arquitectura/programación interna de la app, DEBES actualizar y mantener en todo momento al día el archivo `RESUMEN APP.txt` ([RESUMEN APP.txt](file:///C:/Users/el_de/.gemini/antigravity-ide/scratch/CERBERUS/RESUMEN%20APP.txt)), reflejando con exactitud el estado actual de la programación interna de la aplicación.

