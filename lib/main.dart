import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';
import 'models/entry_model.dart';
import 'screens/home_screen.dart';
import 'services/database_helper.dart';
import 'models/credential_entry.dart' as ce;
import 'services/import_export_service.dart';
import 'services/import_export/json_format_adapter.dart';
import 'services/import_export/encrypted_json_format_adapter.dart';
import 'services/import_export/kdbx_format_adapter.dart';
import 'services/import_export/onepux_format_adapter.dart';
import 'services/autofill_handler_service.dart';

final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.dark);
final ValueNotifier<Locale?> localeNotifier = ValueNotifier(null);
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  const storage = FlutterSecureStorage();

  // Initialize Android Autofill MethodChannel Listener
  AutofillHandlerService.initialize();

  final savedTheme = await storage.read(key: 'app_theme_mode');
  if (savedTheme == 'light') {
    themeNotifier.value = ThemeMode.light;
  } else {
    themeNotifier.value = ThemeMode.dark;
  }

  final savedLanguage = await storage.read(key: 'app_language_code');
  if (savedLanguage != null) {
    localeNotifier.value = Locale(savedLanguage);
  }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, mode, __) {
        return ValueListenableBuilder<Locale?>(
          valueListenable: localeNotifier,
          builder: (_, locale, __) {
            // Corporate Purple Palette
            final ColorScheme lightScheme = ColorScheme.fromSeed(
              seedColor: const Color(0xFF6750A4),
              brightness: Brightness.light,
            );

            final ColorScheme darkScheme = ColorScheme.fromSeed(
              seedColor: const Color(0xFF6750A4),
              brightness: Brightness.dark,
            );

            return MaterialApp(
              navigatorKey: navigatorKey,
              title: 'Cerberus',
              debugShowCheckedModeBanner: false,
              themeMode: mode,
              locale: locale,
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: AppLocalizations.supportedLocales,
              localeResolutionCallback: (locale, supportedLocales) {
                if (locale == null) return supportedLocales.first;
                for (var supportedLocale in supportedLocales) {
                  if (supportedLocale.languageCode == locale.languageCode) {
                    return supportedLocale;
                  }
                }
                return supportedLocales.first;
              },
              theme: ThemeData(
                useMaterial3: true,
                brightness: Brightness.light,
                scaffoldBackgroundColor: const Color(0xFFF8FAFC),
                colorScheme: lightScheme,
              ),
              darkTheme: ThemeData(
                useMaterial3: true,
                brightness: Brightness.dark,
                colorScheme: darkScheme,
              ),
              home: const AuthWrapper(),
            );
          },
        );
      },
    );
  }
}

enum AuthState { checking, register, login, authenticated }

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> with WidgetsBindingObserver {
  AuthState _authState = AuthState.checking;
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final LocalAuthentication _localAuth = LocalAuthentication();
  final _secureStorage = const FlutterSecureStorage();
  final ImportExportService _importExportService = ImportExportService()
    ..registerAdapter(JsonFormatAdapter())
    ..registerAdapter(EncryptedJsonFormatAdapter())
    ..registerAdapter(KdbxFormatAdapter())
    ..registerAdapter(OnePuxFormatAdapter());

  String? _errorMessage;
  bool _isLoading = false;

  List<EntryModel> _entries = [];

  // Biometrics State
  bool _canCheckBiometrics = false;
  bool _isBiometricSet = false;

  // Inactivity & Background Security
  Timer? _inactivityTimer;
  DateTime? _backgroundTime;

  // Controllers
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  
  bool _obscureMasterPassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkStatus();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _inactivityTimer?.cancel();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _backgroundTime = DateTime.now();
    } else if (state == AppLifecycleState.resumed) {
      if (_authState == AuthState.authenticated && _backgroundTime != null) {
        final elapsed = DateTime.now().difference(_backgroundTime!);
        if (elapsed.inMinutes >= 5) {
          _handleLogout();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.sessionClosedInactivity),
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else {
          _startInactivityTimer();
        }
      }
      _backgroundTime = null;
    }
  }

  void _startInactivityTimer() {
    _inactivityTimer?.cancel();
    if (_authState == AuthState.authenticated) {
      _inactivityTimer = Timer(const Duration(minutes: 5), () {
        _handleLogout();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.sessionClosedInactivityFiveMin),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      });
    }
  }

  Future<void> _checkStatus() async {
    setState(() {
      _authState = AuthState.checking;
      _errorMessage = null;
    });

    try {
      final hasPassword = await _dbHelper.hasMasterPassword();
      setState(() {
        _authState = hasPassword ? AuthState.login : AuthState.register;
      });
      
      await _checkBiometricsSupport();
    } catch (e) {
      setState(() {
        _errorMessage = '__checkStorageError__:$e';
        _authState = AuthState.login;
      });
    }
  }

  Future<void> _checkBiometricsSupport() async {
    try {
      final isAvailable = await _localAuth.canCheckBiometrics || await _localAuth.isDeviceSupported();
      final isBiometricSet = await _secureStorage.containsKey(key: 'master_password');
      setState(() {
        _canCheckBiometrics = isAvailable;
        _isBiometricSet = isBiometricSet;
      });

      if (isAvailable && isBiometricSet && _authState == AuthState.login) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _authenticateWithBiometrics();
        });
      }
    } catch (_) {
      // Ignore
    }
  }

  Future<void> _authenticateWithBiometrics() async {
    try {
      final hasEnrolledBiometrics = (await _localAuth.getAvailableBiometrics()).isNotEmpty;
      if (!hasEnrolledBiometrics) return;
      final authenticated = await _localAuth.authenticate(
        localizedReason: AppLocalizations.of(context)!.fingerprintScanReason,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );

      if (authenticated) {
        final savedPassword = await _secureStorage.read(key: 'master_password');
        if (savedPassword != null) {
          setState(() {
            _isLoading = true;
            _errorMessage = null;
          });
          
          await _dbHelper.initDatabase(savedPassword);
          
          setState(() {
            _authState = AuthState.authenticated;
          });
          await _loadEntries();
          _startInactivityTimer();
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = '__biometricAuthError__:$e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _askToEnableBiometrics(String password) async {
    final isAvailable = await _localAuth.canCheckBiometrics || await _localAuth.isDeviceSupported();
    if (!isAvailable) return;

    final hasEnrolledBiometrics = (await _localAuth.getAvailableBiometrics()).isNotEmpty;
    if (!hasEnrolledBiometrics) return;

    if (!mounted) return;

    final enable = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.enableFingerprintTitle),
        content: Text(AppLocalizations.of(context)!.enableFingerprintContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppLocalizations.of(context)!.noThanks),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(AppLocalizations.of(context)!.yesEnable),
          ),
        ],
      ),
    );

    if (enable == true) {
      try {
        final authenticated = await _localAuth.authenticate(
          localizedReason: AppLocalizations.of(context)!.fingerprintSetupReason,
          options: const AuthenticationOptions(
            stickyAuth: true,
            biometricOnly: true,
          ),
        );

        if (authenticated) {
          await _secureStorage.write(key: 'master_password', value: password);
          setState(() {
            _isBiometricSet = true;
          });
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(AppLocalizations.of(context)!.biometricEnabledSuccess),
                backgroundColor: Colors.green,
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.biometricEnabledError(e.toString())),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      }
    }
  }

  Future<void> _loadEntries() async {
    try {
      final entries = await _dbHelper.getEntries();
      setState(() {
        _entries = entries;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.errorLoadingEntries(e.toString())), backgroundColor: Colors.redAccent),
        );
      }
    }
  }

  Future<void> _handleExportUnified(String format, {String? password}) async {
    final auth = LocalAuthentication();
    bool authenticated = false;
    try {
      final canAuthenticate = await auth.canCheckBiometrics || await auth.isDeviceSupported();
      if (!canAuthenticate) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(context)!.biometricRequiredExport), backgroundColor: Colors.redAccent),
          );
        }
        return;
      }
      final hasEnrolledBiometrics = (await auth.getAvailableBiometrics()).isNotEmpty;
      authenticated = await auth.authenticate(
        localizedReason: AppLocalizations.of(context)!.biometricReasonExport,
        options: AuthenticationOptions(stickyAuth: true, biometricOnly: hasEnrolledBiometrics),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.authError(e.toString())), backgroundColor: Colors.redAccent),
        );
      }
      return;
    }

    if (!authenticated) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.authFailed), backgroundColor: Colors.redAccent),
        );
      }
      return;
    }

    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Exportando...'),
        content: const Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 20),
            Text('Generando archivo...'),
          ],
        ),
      ),
    );

    try {
      final entries = await _dbHelper.getEntries();
      final credEntries = entries.map((e) => ce.CredentialEntry(
        id: e.id?.toString(),
        title: e.title,
        username: e.username,
        password: e.password.isNotEmpty ? Uint8List.fromList(utf8.encode(e.password)) : null,
        urls: e.website.isNotEmpty ? [e.website] : [],
        notes: e.notes,
        categories: e.category.isNotEmpty ? [e.category] : [],
        customFields: e.customFields.map((cf) {
          return ce.CustomField(name: cf.name, value: cf.value, isProtected: cf.isSecure);
        }).toList(),
        modifiedAt: DateTime.tryParse(e.updatedAt),
      )).toList();

      final tempDir = await getTemporaryDirectory();
      final tempPath = '${tempDir.path}/export_temp.$format';
      
      final File exportedFile = await _importExportService.exportFile(credEntries, tempPath, password: password);
      final bytes = await exportedFile.readAsBytes();

      if (mounted) Navigator.pop(context); // close waiting dialog

      final String? path = await FilePicker.platform.saveFile(
        dialogTitle: 'Exportar a $format',
        fileName: 'cerberus_export.$format',
        bytes: bytes,
        type: FileType.custom,
        allowedExtensions: [format],
      );

      if (path != null) {
        if (!Platform.isAndroid && !Platform.isIOS) {
          final destFile = File(path);
          await destFile.writeAsBytes(bytes);
        }
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Exportación completada con éxito'), backgroundColor: Colors.green),
          );
        }
      }
      
      if (await exportedFile.exists()) {
        await exportedFile.delete();
      }

    } catch (e) {
      if (mounted) Navigator.pop(context); // close waiting dialog
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al exportar: $e'), backgroundColor: Colors.redAccent),
        );
      }
    }
  }

  Future<void> _handleCsvImport() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.any,
      );

      if (result == null || result.files.isEmpty) {
        return;
      }

      final file = File(result.files.first.path!);
      final extension = result.files.first.extension?.toLowerCase() ?? '';
      
      String? password;
      if (['kdbx', 'cjson', 'json.enc'].contains(extension)) {
        password = await _askForImportPassword();
        if (password == null) return;
      }

      int count = 0;
      if (extension == 'xml') {
        final content = utf8.decode(await file.readAsBytes());
        count = await _dbHelper.importSafeInCloudXml(content);
      } else if (extension == 'csv') {
        final content = utf8.decode(await file.readAsBytes());
        count = await _dbHelper.importSafeInCloudCsv(content);
      } else {
        count = await _importExportService.importFile(file, password: password);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.csvImportSuccess(count)),
            backgroundColor: Colors.green,
          ),
        );
      }

      await _loadEntries();
      _startInactivityTimer();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.csvImportError(e.toString())),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  Future<String?> _askForImportPassword() async {
    String? pass;
    await showDialog(
      context: context,
      builder: (context) {
        final controller = TextEditingController();
        return AlertDialog(
          title: const Text('Contraseña requerida'),
          content: TextField(
            controller: controller,
            obscureText: true,
            decoration: const InputDecoration(labelText: 'Contraseña del archivo'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                pass = controller.text;
                Navigator.pop(context);
              },
              child: const Text('Aceptar'),
            ),
          ],
        );
      }
    );
    return pass;
  }

  Future<void> _handleRegister() async {
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (password.isEmpty) {
      setState(() {
        _errorMessage = AppLocalizations.of(context)!.passwordEmpty;
      });
      return;
    }

    if (password != confirmPassword) {
      setState(() {
        _errorMessage = AppLocalizations.of(context)!.passwordsDoNotMatch;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _dbHelper.initDatabase(password);
      setState(() {
        _authState = AuthState.authenticated;
        _passwordController.clear();
        _confirmPasswordController.clear();
      });
      await _loadEntries();
      _startInactivityTimer();
      await _askToEnableBiometrics(password);
    } catch (e) {
      setState(() {
        _errorMessage = AppLocalizations.of(context)!.dbInitError(e.toString());
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _handleLogin() async {
    final password = _passwordController.text;

    if (password.isEmpty) {
      setState(() {
        _errorMessage = AppLocalizations.of(context)!.enterMasterPasswordPrompt;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _dbHelper.initDatabase(password);
      setState(() {
        _authState = AuthState.authenticated;
        _passwordController.clear();
      });
      await _loadEntries();
      _startInactivityTimer();

      final isBiometricSet = await _secureStorage.containsKey(key: 'master_password');
      if (!isBiometricSet) {
        await _askToEnableBiometrics(password);
      }
    } on SecureDatabaseException catch (_) {
      setState(() {
        _errorMessage = AppLocalizations.of(context)!.incorrectPasswordError;
      });
    } catch (e) {
      setState(() {
        _errorMessage = AppLocalizations.of(context)!.unexpectedError(e.toString());
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _handleLogout() async {
    navigatorKey.currentState?.popUntil((route) => route.isFirst);
    _inactivityTimer?.cancel();
    setState(() {
      _isLoading = true;
    });
    try {
      await _dbHelper.closeDatabase();
      _entries.clear();
      await _checkStatus();
    } catch (e) {
      setState(() {
        _errorMessage = AppLocalizations.of(context)!.logoutError(e.toString());
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_authState == AuthState.checking) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    Widget currentScreen;

    if (_authState == AuthState.authenticated) {
      currentScreen = HomeScreen(
        entries: _entries,
        onCsvImport: _handleCsvImport,
        onExportUnified: _handleExportUnified,
        onLogout: _handleLogout,
        onAddEntry: (entry) async {
          try {
            await _dbHelper.insertEntry(entry);
            await _loadEntries();
            _startInactivityTimer();
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.errorAdding(e.toString()))));
            }
          }
        },
        onUpdateEntry: (entry) async {
          try {
            await _dbHelper.updateEntry(entry);
            await _loadEntries();
            _startInactivityTimer();
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.errorUpdating(e.toString()))));
            }
          }
        },
        onDeleteEntry: (id) async {
          try {
            await _dbHelper.deleteEntry(id);
            await _loadEntries();
            _startInactivityTimer();
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.errorDeleting(e.toString()))));
            }
          }
        },
      );
    } else {
      final isRegister = _authState == AuthState.register;

      currentScreen = Scaffold(
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32.0, horizontal: 24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Icon(
                        isRegister ? Icons.shield_outlined : Icons.lock_outline_rounded,
                        size: 60,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        isRegister
                            ? AppLocalizations.of(context)!.createMasterPassword
                            : AppLocalizations.of(context)!.enterMasterPassword,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        isRegister
                            ? AppLocalizations.of(context)!.registerSubtitle
                            : AppLocalizations.of(context)!.loginSubtitle,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 24),
                      if (_errorMessage != null) ...[
                        Builder(
                          builder: (context) {
                            String displayError = _errorMessage!;
                            if (displayError.startsWith('__checkStorageErrorUI__:')) {
                              // wait, did we use __checkStorageError__ or __checkStorageErrorUI__?
                              // let's support both
                            }
                            if (displayError.startsWith('__checkStorageError__:')) {
                              final err = displayError.substring('__checkStorageError__:'.length);
                              displayError = AppLocalizations.of(context)!.checkStorageError(err);
                            } else if (displayError.startsWith('__biometricAuthError__:')) {
                              final err = displayError.substring('__biometricAuthError__:'.length);
                              displayError = AppLocalizations.of(context)!.biometricAuthError(err);
                            }
                            return Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.redAccent.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.redAccent.withValues(alpha: 0.3)),
                              ),
                              child: Text(
                                displayError,
                                style: const TextStyle(color: Colors.redAccent, fontSize: 13),
                                textAlign: TextAlign.center,
                              ),
                            );
                          }
                        ),
                        const SizedBox(height: 16),
                      ],
                      TextField(
                        controller: _passwordController,
                        obscureText: _obscureMasterPassword,
                        style: const TextStyle(fontFamily: 'monospace'),
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(context)!.masterPasswordLabel,
                          prefixIcon: const Icon(Icons.lock_rounded),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureMasterPassword ? Icons.visibility_off : Icons.visibility,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureMasterPassword = !_obscureMasterPassword;
                              });
                            },
                          ),
                          border: const OutlineInputBorder(),
                        ),
                      ),
                      if (isRegister) ...[
                        const SizedBox(height: 16),
                        TextField(
                          controller: _confirmPasswordController,
                          obscureText: _obscureConfirmPassword,
                          style: const TextStyle(fontFamily: 'monospace'),
                          decoration: InputDecoration(
                            labelText: AppLocalizations.of(context)!.confirmPasswordLabel,
                            prefixIcon: const Icon(Icons.lock_rounded),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscureConfirmPassword = !_obscureConfirmPassword;
                                });
                              },
                            ),
                            border: const OutlineInputBorder(),
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _isLoading
                            ? null
                            : (isRegister ? _handleRegister : _handleLogin),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          foregroundColor: Theme.of(context).colorScheme.onPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                isRegister
                                    ? AppLocalizations.of(context)!.registerSave
                                    : AppLocalizations.of(context)!.unlock,
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                      ),
                      if (!isRegister && _canCheckBiometrics && _isBiometricSet) ...[
                        const SizedBox(height: 20),
                        Center(
                          child: InkWell(
                            onTap: _authenticateWithBiometrics,
                            borderRadius: BorderRadius.circular(30),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Icon(
                                Icons.fingerprint,
                                size: 54,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) => _startInactivityTimer(),
      onPointerMove: (_) => _startInactivityTimer(),
      child: currentScreen,
    );
  }
}
