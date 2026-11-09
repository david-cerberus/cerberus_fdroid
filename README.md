# Cerberus

Gestor de contraseñas Flutter para la edición F-Droid.

## Características

- Funciona completamente sin conexión: no realiza peticiones de red ni descarga recursos en ejecución.
- Almacenamiento local cifrado con SQLCipher y derivación de clave PBKDF2.
- Autenticación biométrica y bloqueo por inactividad.
- Copia de seguridad local cifrada: exportación e importación de archivos `.cjson`.
- Importación y exportación en varios formatos (KDBX, 1PUX, JSON, XML y CSV).
- Todas las funciones están desbloqueadas; no hay restricciones ni bloqueos.

## Desarrollo

Requiere el SDK de Flutter instalado globalmente. Para preparar las dependencias y ejecutar las comprobaciones:

```sh
flutter pub get
flutter analyze
flutter test
```

Para compilar el APK de publicación:

```sh
flutter build apk --release
```
