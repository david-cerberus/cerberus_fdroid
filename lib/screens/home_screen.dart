import 'dart:convert';
import 'dart:io';
import 'package:uuid/uuid.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:local_auth/local_auth.dart';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import '../models/entry_model.dart';
import '../services/password_generator_service.dart';
import '../services/security_health_service.dart';
import 'package:xml/xml.dart';
import 'security_health_screen.dart';
import '../main.dart';
import '../l10n/app_localizations.dart';
import '../widgets/premium_gate.dart';
import '../services/purchase_service.dart';
import '../services/review_service.dart';
import '../services/database_helper.dart';
import '../services/attachment_service.dart';
import '../models/attachment_model.dart';

class HomeScreen extends StatefulWidget {
  final List<EntryModel> entries;
  final GoogleSignInAccount? googleUser;
  final bool isSyncing;
  final String? syncStatusMessage;
  
  final String? lastBackupTime;
  
  final VoidCallback onGoogleSignIn;
  final VoidCallback onGoogleSignOut;
  final VoidCallback onUpload;
  final VoidCallback onDownload;
  final VoidCallback onDeleteDrive;
  final VoidCallback onCsvImport;
  final Future<void> Function(String, {String? password})? onExportUnified;
  final VoidCallback onLogout;
  
  final Future<void> Function(EntryModel) onAddEntry;
  final Future<void> Function(EntryModel) onUpdateEntry;
  final Future<void> Function(String) onDeleteEntry;

  const HomeScreen({
    super.key,
    required this.entries,
    required this.googleUser,
    required this.isSyncing,
    required this.syncStatusMessage,
    this.lastBackupTime,
    required this.onGoogleSignIn,
    required this.onGoogleSignOut,
    required this.onUpload,
    required this.onDownload,
    required this.onDeleteDrive,
    required this.onCsvImport,
    this.onExportUnified,
    required this.onLogout,
    required this.onAddEntry,
    required this.onUpdateEntry,
    required this.onDeleteEntry,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'Todos';

  final List<String> _categories = [
    'Todos',
    'General',
    'Bancos',
    'Cuentas Web',
    'Emails',
    'Foros',
    'Router',
    'Tienda',
    'Otros',
  ];

  PasswordRecipe _activeRecipe = PasswordRecipe.defaultRecipe;
  bool _hadPremiumBefore = false;

  void _onPremiumChanged() {
    if (isPremiumNotifier.value) {
      setState(() {
        _hadPremiumBefore = true;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    
    // One-time cleanup for the user's issue with CATEGORIA in notes or custom fields
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      for (final e in widget.entries) {
        bool changed = false;
        
        // Check main notes field
        String cleanNotes = e.notes;
        if (cleanNotes.toUpperCase().contains('CATEGORIA') || cleanNotes.toUpperCase().contains('CATEGORÍA')) {
           cleanNotes = cleanNotes.replaceAll(RegExp(r'.*Categor[ií]a:.*', caseSensitive: false, multiLine: true), '').trim();
           if (cleanNotes != e.notes) changed = true;
        }

        // Check custom fields
        final newCustomFields = e.customFields.map((field) {
          if (field.value.toUpperCase().contains('CATEGORIA') || field.value.toUpperCase().contains('CATEGORÍA')) {
            final cleanVal = field.value.replaceAll(RegExp(r'.*Categor[ií]a:.*', caseSensitive: false, multiLine: true), '').trim();
            if (cleanVal != field.value) {
              changed = true;
              return CustomField(name: field.name, value: cleanVal, isSecure: field.isSecure);
            }
          }
          return field;
        }).toList();

        if (changed) {
          await widget.onUpdateEntry(e.copyWith(notes: cleanNotes, customFields: newCustomFields));
        }
      }

      // Check and request native store review if eligible
      await ReviewService().checkAndRequestReview(widget.entries.length);
    });

    _loadSettings();
    isPremiumNotifier.addListener(_onPremiumChanged);
  }

  Future<void> _loadSettings() async {
    const storage = FlutterSecureStorage();
    try {
      final categoriesData = await storage.read(key: 'custom_categories');
      if (categoriesData != null) {
        final List<dynamic> decoded = jsonDecode(categoriesData);
        setState(() {
          _categories.clear();
          _categories.add('Todos');
          _categories.addAll(decoded.cast<String>());
        });
      }

      final recipeData = await storage.read(key: 'custom_password_recipe');
      if (recipeData != null) {
        final decoded = jsonDecode(recipeData);
        setState(() {
          _activeRecipe = PasswordRecipe.fromJson(decoded);
        });
      }

      final hadPremium = await storage.read(key: 'had_premium_before') == 'true';
      final hasSync = await storage.read(key: 'google_drive_enabled') == 'true';
      setState(() {
        _hadPremiumBefore = hadPremium || hasSync;
      });
    } catch (_) {}
  }

  Future<void> _saveCategories() async {
    const storage = FlutterSecureStorage();
    final listToSave = _categories.where((c) => c != 'Todos').toList();
    await storage.write(key: 'custom_categories', value: jsonEncode(listToSave));
  }

  Future<void> _saveRecipe(PasswordRecipe recipe) async {
    const storage = FlutterSecureStorage();
    await storage.write(key: 'custom_password_recipe', value: jsonEncode(recipe.toJson()));
    setState(() {
      _activeRecipe = recipe;
    });
  }

  Future<void> _handleRestoreAction() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );
    try {
      await PurchaseService().restorePurchases();
      // Give a tiny delay for billing streams to update and trigger persistence check
      await Future.delayed(const Duration(seconds: 1));
      await PurchaseService().checkPremiumStatus();
      if (mounted) {
        Navigator.pop(context); // Pop the progress indicator
        if (isPremiumNotifier.value) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.premiumSuccessMessage),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Error'),
              content: Text(AppLocalizations.of(context)!.noPreviousPurchases),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Pop the progress indicator
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Error'),
            content: Text(e.toString().replaceAll('Exception: ', '')),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    isPremiumNotifier.removeListener(_onPremiumChanged);
    super.dispose();
  }

  Color _getAvatarColor(String title) {
    if (title.isEmpty) return Colors.grey;
    final code = title.toLowerCase().codeUnitAt(0);
    final colors = [
      const Color(0xFF3B82F6), // Blue
      const Color(0xFF8B5CF6), // Purple
      const Color(0xFFEC4899), // Pink
      const Color(0xFF10B981), // Emerald
      const Color(0xFFF59E0B), // Amber
      const Color(0xFFEF4444), // Red
      const Color(0xFF06B6D4), // Cyan
      const Color(0xFFF97316), // Orange
    ];
    return colors[code % colors.length];
  }

  String? _getDomain(String website) {
    if (website.isEmpty) return null;
    String url = website.trim().toLowerCase();
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      url = 'https://$url';
    }
    try {
      final uri = Uri.parse(url);
      final host = uri.host;
      if (host.startsWith('www.')) {
        return host.substring(4);
      }
      return host.isNotEmpty ? host : null;
    } catch (_) {
      return null;
    }
  }

  Widget _buildAvatar(EntryModel entry) {
    final domain = _getDomain(entry.website);
    final avatarColor = _getAvatarColor(entry.title);
    final initial = entry.title.isNotEmpty ? entry.title[0].toUpperCase() : '?';

    if (domain != null && domain.isNotEmpty) {
      final logoUrl = 'https://www.google.com/s2/favicons?sz=128&domain=$domain';
      return CircleAvatar(
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(6.0),
          child: CachedNetworkImage(
            imageUrl: logoUrl,
            width: 28,
            height: 28,
            fit: BoxFit.contain,
            placeholder: (context, url) => _buildTextAvatar(initial, avatarColor),
            errorWidget: (context, url, error) => _buildTextAvatar(initial, avatarColor),
          ),
        ),
      );
    }
    return _buildTextAvatar(initial, avatarColor);
  }

  Widget _buildTextAvatar(String initial, Color avatarColor) {
    return CircleAvatar(
      backgroundColor: avatarColor,
      foregroundColor: Colors.white,
      child: Text(
        initial,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  void _copyToClipboard(String text, String label) {
    if (text.isEmpty) return;
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981)),
            const SizedBox(width: 8),
            Text(AppLocalizations.of(context)!.copiedToClipboard(label)),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(bottom: MediaQuery.of(context).size.height * 0.8, left: 16, right: 16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Color _getPasswordStrength(String password, List<EntryModel> allEntries, String? currentEntryId) {
    if (password.isEmpty) return Colors.transparent;
    final isReused = allEntries.any((e) => e.password == password && e.id != currentEntryId);
    final score = SecurityHealthService.calculatePasswordScore(password, isReused: isReused);
    if (score <= 40.0) return Colors.redAccent;
    if (score <= 70.0) return Colors.orangeAccent;
    return const Color(0xFF10B981);
  }

  String _getPasswordStrengthLabel(String password, List<EntryModel> allEntries, String? currentEntryId) {
    if (password.isEmpty) return '';
    final color = _getPasswordStrength(password, allEntries, currentEntryId);
    if (color == Colors.redAccent) return AppLocalizations.of(context)!.weakPassword;
    if (color == Colors.orangeAccent) return AppLocalizations.of(context)!.mediumPassword;
    if (color == const Color(0xFF10B981)) return AppLocalizations.of(context)!.strongPassword;
    return '';
  }

  String _getLocalizedCategoryName(String cat) {
    switch (cat) {
      case 'Todos':
        return AppLocalizations.of(context)!.categoryAll;
      case 'General':
        return AppLocalizations.of(context)!.categoryGeneral;
      case 'Bancos':
        return AppLocalizations.of(context)!.categoryBanks;
      case 'Cuentas Web':
        return AppLocalizations.of(context)!.categoryWebAccounts;
      case 'Emails':
        return AppLocalizations.of(context)!.categoryEmails;
      case 'Foros':
        return AppLocalizations.of(context)!.categoryForums;
      case 'Router':
        return AppLocalizations.of(context)!.categoryRouter;
      case 'Tienda':
        return AppLocalizations.of(context)!.categoryStore;
      case 'Otros':
        return AppLocalizations.of(context)!.categoryOthers;
      default:
        return cat;
    }
  }

  void _showEntryDetailsBottomSheet(EntryModel initialEntry) {
    EntryModel entry = initialEntry;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final isDark = Theme.of(context).brightness == Brightness.dark;
            final pwd = entry.password;
            final strengthColor = _getPasswordStrength(pwd, widget.entries, entry.id);
            final strengthLabel = _getPasswordStrengthLabel(pwd, widget.entries, entry.id);

            return Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                gradient: pwd.isNotEmpty
                    ? LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          strengthColor.withValues(alpha: 0.75),
                          Colors.transparent,
                        ],
                      )
                    : null,
              ),
              padding: const EdgeInsets.all(2.0),
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(19)),
                ),
                child: Padding(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom + MediaQuery.of(context).padding.bottom + 24,
                    top: 16,
                    left: 16,
                    right: 16,
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Header with Title and Actions
                        Row(
                          children: [
                            _buildAvatar(entry),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    entry.title,
                                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  if (strengthLabel.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Text(
                                        strengthLabel,
                                        style: TextStyle(
                                          color: strengthColor,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit_rounded, color: Colors.blueAccent),
                              tooltip: AppLocalizations.of(context)!.edit,
                              onPressed: () {
                                Navigator.pop(context);
                                _showEntryForm(entry: entry);
                              },
                            ),
                          ],
                        ),
                        const Divider(height: 24),
                        // Fields

                        if (entry.username.isNotEmpty)
                          _DetailTile(
                            icon: Icons.person_outline_rounded,
                            title: AppLocalizations.of(context)!.userOrEmail,
                            value: entry.username,
                            isSecure: false,
                            onCopy: () => _copyToClipboard(entry.username, AppLocalizations.of(context)!.userOrEmail),
                          ),
                        if (entry.password.isNotEmpty) ...[
                          _DetailTile(
                            icon: Icons.vpn_key_outlined,
                            title: AppLocalizations.of(context)!.password,
                            value: entry.password,
                            isSecure: true,
                            onCopy: () => _copyToClipboard(entry.password, AppLocalizations.of(context)!.password),
                          ),
                        ],
                        if (entry.website.isNotEmpty)
                          _DetailTile(
                            icon: Icons.link_rounded,
                            title: AppLocalizations.of(context)!.website,
                            value: entry.website,
                            isSecure: false,
                            onCopy: () => _copyToClipboard(entry.website, AppLocalizations.of(context)!.website),
                          ),
                        if (entry.notes.isNotEmpty)
                          _DetailTile(
                            icon: Icons.notes_rounded,
                            title: AppLocalizations.of(context)!.notes,
                            value: entry.notes,
                            isSecure: false,
                            onCopy: () => _copyToClipboard(entry.notes, AppLocalizations.of(context)!.notes),
                          ),
                      // Custom Fields
                      for (final field in entry.customFields)
                        _DetailTile(
                          icon: Icons.label_outline_rounded,
                          title: field.name.isNotEmpty ? field.name : AppLocalizations.of(context)!.field,
                          value: field.value,
                          isSecure: field.isSecure,
                          onCopy: () => _copyToClipboard(field.value, field.name.isNotEmpty ? field.name : AppLocalizations.of(context)!.field),
                        ),
                      
                      // Attachments removed from here, moving to the bottom

                        // Categoria Tile
                        Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(Icons.category_rounded, color: isDark ? Colors.white70 : Colors.black87, size: 24),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        AppLocalizations.of(context)!.category,
                                        style: TextStyle(
                                          color: isDark ? Colors.white54 : Colors.black54,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      DropdownButtonHideUnderline(
                                        child: DropdownButton<String>(
                                          value: _categories.contains(entry.category) ? entry.category : _categories.firstWhere((c) => c != 'Todos', orElse: () => _categories.last),
                                          isDense: true,
                                          isExpanded: true,
                                          icon: Icon(Icons.arrow_drop_down, color: isDark ? Colors.white54 : Colors.black54),
                                          style: TextStyle(
                                            color: isDark ? Colors.white : Colors.black87,
                                            fontSize: 16,
                                          ),
                                          dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                                          items: _categories.where((c) => c != 'Todos').map((cat) {
                                            return DropdownMenuItem(
                                              value: cat,
                                              child: Text(_getLocalizedCategoryName(cat)),
                                            );
                                          }).toList(),
                                          onChanged: (newCat) async {
                                            if (newCat != null && newCat != entry.category) {
                                              final updated = entry.copyWith(category: newCat);
                                              await widget.onUpdateEntry(updated);
                                              setModalState(() {
                                                entry = updated;
                                              });
                                            }
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        
                        _buildAttachmentsGallery(entry.id, isDark),
                        
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showEntryForm({EntryModel? entry}) {
    final isEdit = entry != null;
    final String currentEntryId = entry?.id ?? const Uuid().v4();
    final titleController = TextEditingController(text: entry?.title ?? '');
    final usernameController = TextEditingController(text: entry?.username ?? '');
    final passwordController = TextEditingController(text: entry?.password ?? '');
    final websiteController = TextEditingController(text: entry?.website ?? '');
    final notesController = TextEditingController(text: entry?.notes ?? '');
    String selectedCategory = entry?.category ?? _categories.firstWhere((c) => c != 'Todos', orElse: () => _categories.last);
    final websiteFocusNode = FocusNode();

    bool obscurePassword = true;

    List<Map<String, dynamic>> dynamicFields = entry?.customFields.map<Map<String, dynamic>>((f) => {
      'nameController': TextEditingController(text: f.name),
      'valueController': TextEditingController(text: f.value),
      'isSecure': f.isSecure,
      'obscure': f.isSecure,
    }).toList() ?? [];

    bool _websiteListenerAdded = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            if (!_websiteListenerAdded) {
              websiteFocusNode.addListener(() {
                if (!websiteFocusNode.hasFocus) {
                  setModalState(() {});
                }
              });
              _websiteListenerAdded = true;
            }
            final isDark = Theme.of(context).brightness == Brightness.dark;
            final pwd = passwordController.text;
            final strengthColor = _getPasswordStrength(pwd, widget.entries, entry?.id);
            final strengthLabel = _getPasswordStrengthLabel(pwd, widget.entries, entry?.id);

            return Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                gradient: pwd.isNotEmpty
                    ? LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          strengthColor.withValues(alpha: 0.75),
                          Colors.transparent,
                        ],
                      )
                    : null,
              ),
              padding: const EdgeInsets.all(2.0),
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(19)),
                ),
                child: Padding(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom + MediaQuery.of(context).padding.bottom + 24,
                    top: 16,
                    left: 24,
                    right: 24,
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (pwd.isNotEmpty)
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Text(
                                strengthLabel,
                                style: TextStyle(
                                  color: strengthColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        if (isEdit)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  _buildAvatar(EntryModel(
                                    title: titleController.text, 
                                    website: websiteController.text,
                                    username: '', password: '', notes: '', category: ''
                                  )),
                                  const SizedBox(width: 12),
                                  Text(
                                    AppLocalizations.of(context)!.editCredential,
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: isDark ? Colors.white : Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  if (entry.passwordHistory.isNotEmpty)
                                    IconButton(
                                      icon: const Icon(Icons.history_rounded, color: Colors.blueAccent),
                                      onPressed: () {
                                        _showHistoryDialog(context, entry.passwordHistory);
                                      },
                                      tooltip: AppLocalizations.of(context)!.historyViewBtn,
                                    ),
                                  IconButton(
                                      icon: const Icon(Icons.delete_forever_rounded, color: Colors.redAccent),
                                      onPressed: () {
                                        _confirmDelete(entry.id);
                                      },
                                      tooltip: AppLocalizations.of(context)!.delete,
                                  ),
                                ],
                              ),
                            ],
                          )
                        else
                          Row(
                            children: [
                              _buildAvatar(EntryModel(
                                title: titleController.text, 
                                website: websiteController.text,
                                username: '', password: '', notes: '', category: ''
                              )),
                              const SizedBox(width: 12),
                              Text(
                                AppLocalizations.of(context)!.newCredential,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: titleController,
                          textCapitalization: TextCapitalization.sentences,
                          decoration: InputDecoration(
                            labelText: AppLocalizations.of(context)!.titleOrServiceName,
                            prefixIcon: const Icon(Icons.label_outline_rounded),
                            border: const OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: usernameController,
                          decoration: InputDecoration(
                            labelText: AppLocalizations.of(context)!.userOrEmail,
                            prefixIcon: const Icon(Icons.person_outline_rounded),
                            border: const OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: passwordController,
                          obscureText: obscurePassword,
                          style: GoogleFonts.firaCode(),
                          onChanged: (val) {
                            setModalState(() {});
                          },
                          decoration: InputDecoration(
                            labelText: AppLocalizations.of(context)!.password,
                            prefixIcon: const Icon(Icons.lock_outline_rounded),
                            border: const OutlineInputBorder(),
                            suffixIcon: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.auto_awesome_rounded, color: Colors.purpleAccent),
                                  onPressed: () => _openGeneratorDialog(titleController.text, passwordController),
                                  tooltip: AppLocalizations.of(context)!.generatePasswordTooltip,
                                ),
                                IconButton(
                                  icon: Icon(
                                    obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                  ),
                                  onPressed: () {
                                    setModalState(() {
                                      obscurePassword = !obscurePassword;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: websiteController,
                          textCapitalization: TextCapitalization.none,
                          focusNode: websiteFocusNode,
                          onEditingComplete: () => setModalState(() {}),
                          decoration: InputDecoration(
                            labelText: AppLocalizations.of(context)!.websiteUrl,
                            prefixIcon: const Icon(Icons.link_rounded),
                            border: const OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: notesController,
                          textCapitalization: TextCapitalization.sentences,
                          maxLines: 3,
                          decoration: InputDecoration(
                            labelText: AppLocalizations.of(context)!.additionalNotes,
                            prefixIcon: const Icon(Icons.notes_rounded),
                            border: const OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...dynamicFields.asMap().entries.map((e) {
                          final int index = e.key;
                          final Map<String, dynamic> field = e.value;
                          final nameController = field['nameController'] as TextEditingController;
                          final valueController = field['valueController'] as TextEditingController;
                          
                          final String fieldName = nameController.text.isNotEmpty ? nameController.text : AppLocalizations.of(context)!.field;
                          final String lName = fieldName.toLowerCase();
                          IconData fieldIcon = Icons.label_outline_rounded;
                          if (lName.contains('usuario') || lName.contains('email') || lName.contains('correo')) fieldIcon = Icons.person_outline_rounded;
                          else if (lName.contains('web') || lName.contains('url')) fieldIcon = Icons.language_rounded;
                          else if (lName.contains('fecha')) fieldIcon = Icons.calendar_today_rounded;
                          else if (lName.contains('número') || lName.contains('numero')) fieldIcon = Icons.numbers_rounded;
                          else if (field['isSecure']) fieldIcon = Icons.lock_outline_rounded;

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: TextField(
                              controller: valueController,
                              obscureText: field['obscure'],
                              textCapitalization: (lName.contains('usuario') || lName.contains('email') || lName.contains('correo') || lName.contains('web') || lName.contains('url') || lName.contains('sitio') || field['isSecure']) ? TextCapitalization.none : TextCapitalization.sentences,
                              decoration: InputDecoration(
                                labelText: fieldName,
                                prefixIcon: Icon(fieldIcon),
                                border: const OutlineInputBorder(),
                                suffixIcon: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (field['isSecure'])
                                      IconButton(
                                        icon: Icon(field['obscure'] ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 20),
                                        onPressed: () {
                                          setModalState(() {
                                            field['obscure'] = !field['obscure'];
                                          });
                                        },
                                      ),
                                    IconButton(
                                      icon: const Icon(Icons.copy_rounded, size: 20),
                                      tooltip: AppLocalizations.of(context)!.copyTooltip,
                                      onPressed: () => _copyToClipboard(valueController.text, fieldName),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent, size: 20),
                                      tooltip: AppLocalizations.of(context)!.deleteFieldTooltip,
                                      onPressed: () {
                                        setModalState(() {
                                          dynamicFields.removeAt(index);
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () {
                                      _showAddFieldSelectionDialog(setModalState, dynamicFields);
                                    },
                                    icon: const Icon(Icons.add),
                                    label: Text(AppLocalizations.of(context)!.addCustomField),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () {
                                      _showAttachmentsDialog(context, currentEntryId);
                                    },
                                    icon: const Icon(Icons.attach_file),
                                    label: const Text('Adjuntos'),
                                  ),
                                ),
                              ],
                            ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          initialValue: _categories.contains(selectedCategory)
                              ? selectedCategory
                              : _categories.firstWhere((c) => c != 'Todos', orElse: () => _categories.last),
                          decoration: InputDecoration(
                            labelText: AppLocalizations.of(context)!.category,
                            prefixIcon: const Icon(Icons.category_rounded),
                            border: const OutlineInputBorder(),
                          ),
                          dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                          items: _categories
                              .where((c) => c != 'Todos')
                              .map((c) => DropdownMenuItem(
                                    value: c,
                                    child: Text(_getLocalizedCategoryName(c), style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            setModalState(() {
                              selectedCategory = value ?? _categories.firstWhere((c) => c != 'Todos', orElse: () => _categories.last);
                            });
                          },
                        ),
                        
                        _buildAttachmentsGallery(currentEntryId, isDark),
                        
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  foregroundColor: isDark ? Colors.white70 : Colors.black87,
                                  side: BorderSide(color: isDark ? Colors.white24 : Colors.black26),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                onPressed: () => Navigator.pop(context),
                                child: Text(
                                  AppLocalizations.of(context)!.cancel,
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  backgroundColor: const Color(0xFF6750A4),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                onPressed: () async {
                                  if (titleController.text.trim().isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(AppLocalizations.of(context)!.titleRequired),
                                        backgroundColor: Colors.redAccent,
                                      ),
                                    );
                                    return;
                                  }

                                  final newCustomFields = dynamicFields.map((f) => CustomField(
                                    name: (f['nameController'] as TextEditingController).text.trim(),
                                    value: (f['valueController'] as TextEditingController).text.trim(),
                                    isSecure: f['isSecure'],
                                  )).where((f) => f.name.isNotEmpty || f.value.isNotEmpty).toList();

                                  List<PasswordHistoryItem> updatedHistory = List.from(entry?.passwordHistory ?? []);
                                  if (isEdit && entry != null) {
                                    if (entry.password.isNotEmpty && entry.password != passwordController.text) {
                                      updatedHistory.insert(0, PasswordHistoryItem(
                                        value: entry.password,
                                        fieldName: AppLocalizations.of(context)!.historyMainPassword,
                                        changedAt: DateTime.now(),
                                      ));
                                    }
                                    
                                    for (var oldField in entry.customFields.where((f) => f.isSecure && f.value.isNotEmpty)) {
                                      final newField = newCustomFields.where((f) => f.name == oldField.name).firstOrNull;
                                      if (newField == null || newField.value != oldField.value) {
                                        updatedHistory.insert(0, PasswordHistoryItem(
                                          value: oldField.value,
                                          fieldName: oldField.name,
                                          changedAt: DateTime.now(),
                                        ));
                                      }
                                    }
                                  }

                                  final newEntry = EntryModel(
                                    id: currentEntryId,
                                    title: titleController.text.trim(),
                                    username: usernameController.text.trim(),
                                    password: passwordController.text,
                                    website: websiteController.text.trim(),
                                    notes: notesController.text.trim(),
                                    isFavorite: entry?.isFavorite ?? false,
                                    category: selectedCategory,
                                    deleted: false,
                                    customFields: newCustomFields,
                                    passwordHistory: updatedHistory,
                                    totpSecret: entry?.totpSecret, // Keep existing if present, but no UI to edit
                                  );

                                  Navigator.pop(context);
                                  if (isEdit) {
                                    await widget.onUpdateEntry(newEntry);
                                  } else {
                                    await widget.onAddEntry(newEntry);
                                  }
                                },
                                child: Text(
                                  isEdit ? 'Guardar' : 'Añadir',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _confirmDelete(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.deleteCredentialTitle),
        content: Text(AppLocalizations.of(context)!.deleteCredentialContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
            onPressed: () async {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Close bottom sheet
              await widget.onDeleteEntry(id);
            },
            child: Text(AppLocalizations.of(context)!.delete),
          ),
        ],
      ),
    );
  }

  void _showHistoryDialog(BuildContext context, List<PasswordHistoryItem> history) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.historyTitle),
          content: SizedBox(
            width: double.maxFinite,
            child: history.isEmpty 
              ? Text(AppLocalizations.of(context)!.historyEmpty)
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: history.length,
                  itemBuilder: (context, index) {
                    final item = history[index];
                    final dateStr = "${item.changedAt.day.toString().padLeft(2, '0')}/${item.changedAt.month.toString().padLeft(2, '0')}/${item.changedAt.year} ${item.changedAt.hour.toString().padLeft(2, '0')}:${item.changedAt.minute.toString().padLeft(2, '0')}";
                    bool obscure = true;
                    return StatefulBuilder(
                      builder: (context, setItemState) {
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            AppLocalizations.of(context)!.historyChangedAt(dateStr),
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.fieldName,
                                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        obscure ? '••••••••' : item.value,
                                        style: GoogleFonts.firaCode(fontSize: 14),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined, size: 20),
                                  onPressed: () {
                                    setItemState(() {
                                      obscure = !obscure;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppLocalizations.of(context)!.historyCloseBtn),
            ),
          ],
        );
      },
    );
  }

  void _showAttachmentsDialog(BuildContext context, String entryId) {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Archivos Adjuntos'),
              content: SizedBox(
                width: double.maxFinite,
                child: FutureBuilder<List<AttachmentModel>>(
                  future: DatabaseHelper().getAttachmentsForEntry(entryId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final attachments = snapshot.data ?? [];
                    if (attachments.isEmpty) {
                      return const Text('No hay archivos adjuntos.', textAlign: TextAlign.center);
                    }
                    return ListView.builder(
                      shrinkWrap: true,
                      itemCount: attachments.length,
                      itemBuilder: (context, index) {
                        final att = attachments[index];
                        return ListTile(
                          leading: const Icon(Icons.insert_drive_file),
                          title: Text(att.fileName, maxLines: 1, overflow: TextOverflow.ellipsis),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () async {
                                  await DatabaseHelper().deleteAttachment(att.id!);
                                  setDialogState(() {});
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cerrar'),
                ),
                ElevatedButton.icon(
                  onPressed: () async {
                    FilePickerResult? result = await FilePicker.platform.pickFiles();
                    if (result != null && result.files.single.path != null) {
                      File file = File(result.files.single.path!);
                      try {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Procesando...')));
                        final att = await AttachmentService.processFile(entryId, file);
                        await DatabaseHelper().insertAttachment(att);
                        if (context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Adjunto guardado')));
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                        }
                      }
                    }
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Añadir'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _confirmDisconnectDrive() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.disconnectDriveTitle),
        content: Text(AppLocalizations.of(context)!.disconnectDriveContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
            onPressed: () {
              Navigator.pop(context);
              widget.onGoogleSignOut();
            },
            child: Text(AppLocalizations.of(context)!.disconnect),
          ),
        ],
      ),
    );
  }
  
  void _confirmDeleteDrive() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.deleteDriveTitle),
        content: Text(AppLocalizations.of(context)!.deleteDriveWarning),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
            onPressed: () {
              Navigator.pop(context);
              widget.onDeleteDrive();
            },
            child: Text(AppLocalizations.of(context)!.deleteFromDrive),
          ),
        ],
      ),
    );
  }
  
  void _showManageCategoriesDialog() {
    final addController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            final list = _categories.where((c) => c != 'Todos').toList();
            return AlertDialog(
              title: Text(AppLocalizations.of(context)!.manageCategories),
              content: SizedBox(
                width: double.maxFinite,
                height: 350,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Expanded(
                      child: ReorderableListView.builder(
                        shrinkWrap: true,
                        buildDefaultDragHandles: false,
                        itemCount: list.length,
                        onReorder: (int oldIndex, int newIndex) async {
                          if (oldIndex < newIndex) {
                            newIndex -= 1;
                          }
                          setState(() {
                            final String item = list.removeAt(oldIndex);
                            list.insert(newIndex, item);
                            _categories.clear();
                            _categories.add('Todos');
                            _categories.addAll(list);
                          });
                          await _saveCategories();
                          setStateDialog(() {});
                        },
                        itemBuilder: (context, index) {
                          final cat = list[index];
                          return ReorderableDelayedDragStartListener(
                            key: ValueKey(cat),
                            index: index,
                            child: ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text(_getLocalizedCategoryName(cat), style: const TextStyle(fontSize: 15)),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit_rounded, color: Colors.blueAccent, size: 20),
                                    onPressed: () {
                                      _showRenameCategoryDialog(cat, setStateDialog);
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_rounded, color: Colors.redAccent, size: 20),
                                    onPressed: () async {
                                      if (list.length <= 1) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text('Debe haber al menos una categoría.'),
                                            backgroundColor: Colors.orangeAccent,
                                          ),
                                        );
                                        return;
                                      }
                                      setState(() {
                                        _categories.remove(cat);
                                      });
                                      await _saveCategories();
                                      setStateDialog(() {});
                                    },
                                  ),
                                  const Icon(Icons.drag_handle, color: Colors.grey, size: 20),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const Divider(),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: addController,
                            decoration: InputDecoration(
                              hintText: AppLocalizations.of(context)!.newCategory,
                              isDense: true,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add_circle_rounded, color: Color(0xFF10B981)),
                          onPressed: () async {
                            final name = addController.text.trim();
                            if (name.isEmpty) return;
                            if (_categories.contains(name)) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(AppLocalizations.of(context)!.categoryExists),
                                  backgroundColor: Colors.orangeAccent,
                                ),
                              );
                              return;
                            }
                            setState(() {
                              _categories.add(name);
                            });
                            await _saveCategories();
                            addController.clear();
                            setStateDialog(() {});
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(AppLocalizations.of(context)!.close),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showRenameCategoryDialog(String oldName, StateSetter parentSetState) {
    final renameController = TextEditingController(text: oldName);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.renameCategory),
          content: TextField(
            controller: renameController,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context)!.newNameLabel,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
            TextButton(
              onPressed: () async {
                final newName = renameController.text.trim();
                if (newName.isEmpty || newName == oldName) {
                  Navigator.pop(context);
                  return;
                }
                if (_categories.contains(newName)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(AppLocalizations.of(context)!.categoryExists),
                      backgroundColor: Colors.orangeAccent,
                    ),
                  );
                  return;
                }
                setState(() {
                  final idx = _categories.indexOf(oldName);
                  if (idx != -1) {
                    _categories[idx] = newName;
                  }
                  if (_selectedCategory == oldName) {
                    _selectedCategory = newName;
                  }
                  // Update matching categories
                  for (int i = 0; i < widget.entries.length; i++) {
                    if (widget.entries[i].category == oldName) {
                      widget.onUpdateEntry(widget.entries[i].copyWith(category: newName));
                    }
                  }
                });
                await _saveCategories();
                parentSetState(() {});
                Navigator.pop(context);
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  void _showImportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.importData),
        content: Text(AppLocalizations.of(context)!.importFormatsList),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.close),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              widget.onCsvImport();
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6750A4), foregroundColor: Colors.white),
            child: Text(AppLocalizations.of(context)!.importData),
          ),
        ],
      ),
    );
  }

  void _showExportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.exportData),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.data_object_rounded, color: Colors.purpleAccent),
                title: Text(AppLocalizations.of(context)!.exportToKdbx),
                onTap: () { 
                  Navigator.pop(context); 
                  _showKdbxPasswordDialog();
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.code_rounded, color: Colors.orange),
                title: Text(AppLocalizations.of(context)!.exportToJson),
                onTap: () { 
                  Navigator.pop(context); 
                  _showJsonExportDialog();
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.description_rounded, color: Colors.red),
                title: Text(AppLocalizations.of(context)!.exportXml),
                onTap: () { Navigator.pop(context); _handleExportXml(); },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.table_chart_rounded, color: Colors.green),
                title: Text(AppLocalizations.of(context)!.exportCsv),
                onTap: () { Navigator.pop(context); _handleExportCsv(); },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.close),
          ),
        ],
      ),
    );
  }

  void _showJsonExportDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.exportToJson),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppLocalizations.of(context)!.exportJsonRecommended),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              obscureText: true,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.passwordForFile,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    if (widget.onExportUnified != null) {
                      widget.onExportUnified!('json', password: null);
                    }
                  },
                  icon: const Icon(Icons.lock_open_rounded),
                  label: Text(AppLocalizations.of(context)!.exportJsonPlainBtn, maxLines: 2, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w600)),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: () {
                    if (controller.text.isEmpty) return;
                    Navigator.pop(context);
                    if (widget.onExportUnified != null) {
                      widget.onExportUnified!('cjson', password: controller.text);
                    }
                  },
                  icon: const Icon(Icons.lock_rounded),
                  label: Text(AppLocalizations.of(context)!.exportJsonSecureBtn, maxLines: 2, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.close),
          ),
        ],
      ),
    );
  }

  void _showKdbxPasswordDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.exportToKdbx),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppLocalizations.of(context)!.exportKdbxDesc),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              obscureText: true,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.passwordForFile,
                border: const OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.close),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isEmpty) return;
              Navigator.pop(context);
              if (widget.onExportUnified != null) {
                widget.onExportUnified!('kdbx', password: controller.text);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6750A4), foregroundColor: Colors.white),
            child: Text(AppLocalizations.of(context)!.exportToKdbx),
          ),
        ],
      ),
    );
  }

  void _showPasswordRecipeDialog() {
    double length = _activeRecipe.length.toDouble();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: Text(AppLocalizations.of(context)!.passwordPattern),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    AppLocalizations.of(context)!.passwordLength(length.toInt()),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Slider(
                    value: length,
                    min: 8,
                    max: 64,
                    divisions: 56,
                    label: length.toInt().toString(),
                    activeColor: const Color(0xFF6750A4),
                    onChanged: (val) {
                      setStateDialog(() {
                        length = val;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  Text(
                    AppLocalizations.of(context)!.passwordLengthHelper,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(AppLocalizations.of(context)!.cancel),
                ),
                TextButton(
                  onPressed: () async {
                    final newRecipe = PasswordRecipe(
                      length: length.toInt(),
                    );

                    await _saveRecipe(newRecipe);
                    Navigator.pop(context);

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(AppLocalizations.of(context)!.customPatternSaved),
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                  child: Text(AppLocalizations.of(context)!.save),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.selectLanguage),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('Español'),
                onTap: () async {
                  localeNotifier.value = const Locale('es');
                  const storage = FlutterSecureStorage();
                  await storage.write(key: 'app_language_code', value: 'es');
                  if (context.mounted) Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('English'),
                onTap: () async {
                  localeNotifier.value = const Locale('en');
                  const storage = FlutterSecureStorage();
                  await storage.write(key: 'app_language_code', value: 'en');
                  if (context.mounted) Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('Deutsch'),
                onTap: () async {
                  localeNotifier.value = const Locale('de');
                  const storage = FlutterSecureStorage();
                  await storage.write(key: 'app_language_code', value: 'de');
                  if (context.mounted) Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('Português'),
                onTap: () async {
                  localeNotifier.value = const Locale('pt');
                  const storage = FlutterSecureStorage();
                  await storage.write(key: 'app_language_code', value: 'pt');
                  if (context.mounted) Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('Français'),
                onTap: () async {
                  localeNotifier.value = const Locale('fr');
                  const storage = FlutterSecureStorage();
                  await storage.write(key: 'app_language_code', value: 'fr');
                  if (context.mounted) Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('Italiano'),
                onTap: () async {
                  localeNotifier.value = const Locale('it');
                  const storage = FlutterSecureStorage();
                  await storage.write(key: 'app_language_code', value: 'it');
                  if (context.mounted) Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('Polski'),
                onTap: () async {
                  localeNotifier.value = const Locale('pl');
                  const storage = FlutterSecureStorage();
                  await storage.write(key: 'app_language_code', value: 'pl');
                  if (context.mounted) Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _handleExportCsv() async {
    final auth = LocalAuthentication();
    bool authenticated = false;
    try {
      final canAuthenticate = await auth.canCheckBiometrics || await auth.isDeviceSupported();
      if (!canAuthenticate) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.biometricRequiredExport),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      authenticated = await auth.authenticate(
        localizedReason: AppLocalizations.of(context)!.biometricReasonExport,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.authError(e.toString())),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (!authenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.authFailed),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E293B),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Colors.redAccent, width: 1.5),
          ),
          title: Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 28),
              const SizedBox(width: 8),
              Text(
                AppLocalizations.of(dialogContext)!.criticalDanger,
                style: const TextStyle(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          content: Text(
            AppLocalizations.of(dialogContext)!.csvExportWarning,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              height: 1.5,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                AppLocalizations.of(dialogContext)!.cancel,
                style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                Navigator.pop(dialogContext);
                _performSaveCsv();
              },
              child: Text(
                AppLocalizations.of(dialogContext)!.understandRiskSave,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _performSaveCsv() async {
    try {
      final List<List<dynamic>> rows = [
        ['Categoría', 'Título', 'Usuario', 'Contraseña', 'URL', 'Notas', 'Campos Personalizados'],
      ];
      for (final entry in widget.entries) {
        rows.add([
          entry.category,
          entry.title,
          entry.username,
          entry.password,
          entry.website,
          entry.notes,
          jsonEncode(entry.customFields.map((f) => f.toMap()).toList()),
        ]);
      }
      final csvString = const ListToCsvConverter().convert(rows);
      final bytes = Uint8List.fromList(utf8.encode(csvString));

      final String? path = await FilePicker.platform.saveFile(
        dialogTitle: AppLocalizations.of(context)!.exportCsv,
        fileName: 'aurapass_export.csv',
        bytes: bytes,
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );

      if (path != null) {
        if (!Platform.isAndroid && !Platform.isIOS) {
          final file = File(path);
          await file.writeAsBytes(bytes);
        }
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.csvExportSuccessNoCount),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.csvExportError(e.toString())),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _handleExportXml() async {
    final auth = LocalAuthentication();
    bool authenticated = false;
    try {
      final canAuthenticate = await auth.canCheckBiometrics || await auth.isDeviceSupported();
      if (!canAuthenticate) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.biometricRequiredExport),
              backgroundColor: Colors.redAccent,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        return;
      }

      authenticated = await auth.authenticate(
        localizedReason: AppLocalizations.of(context)!.biometricReasonExport,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.authError(e.toString())),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }

    if (!authenticated) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.authFailed),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }

    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E293B),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Colors.redAccent, width: 1.5),
          ),
          title: Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 28),
              const SizedBox(width: 8),
              Text(
                AppLocalizations.of(dialogContext)!.criticalDanger,
                style: const TextStyle(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          content: Text(
            AppLocalizations.of(dialogContext)!.csvExportWarning,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              height: 1.5,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                AppLocalizations.of(dialogContext)!.cancel,
                style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                Navigator.pop(dialogContext);
                _performSaveXml();
              },
              child: Text(
                AppLocalizations.of(dialogContext)!.understandRiskSave,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _performSaveXml() async {
    try {
      final builder = XmlBuilder();
      builder.processing('xml', 'version="1.0" encoding="utf-8"');
      builder.element('database', nest: () {
        for (final entry in widget.entries) {
          builder.element('card', nest: () {
            builder.attribute('title', entry.title);
            if (entry.notes.isNotEmpty) {
              builder.attribute('notes', entry.notes);
            }
            if (entry.username.isNotEmpty) {
              builder.element('field', nest: () {
                builder.attribute('name', 'Login');
                builder.attribute('type', 'login');
                builder.text(entry.username);
              });
            }
            if (entry.password.isNotEmpty) {
              builder.element('field', nest: () {
                builder.attribute('name', 'Password');
                builder.attribute('type', 'password');
                builder.text(entry.password);
              });
            }
            if (entry.website.isNotEmpty) {
              builder.element('field', nest: () {
                builder.attribute('name', 'Website');
                builder.attribute('type', 'website');
                builder.text(entry.website);
              });
            }
            for (final field in entry.customFields) {
              builder.element('field', nest: () {
                builder.attribute('name', field.name);
                builder.attribute('type', field.isSecure ? 'password' : 'text');
                builder.text(field.value);
              });
            }
          });
        }
      });

      final document = builder.buildDocument();
      final xmlString = document.toXmlString(pretty: true);
      final bytes = Uint8List.fromList(utf8.encode(xmlString));

      final String? path = await FilePicker.platform.saveFile(
        dialogTitle: AppLocalizations.of(context)!.exportXml,
        fileName: 'aurapass_export.xml',
        bytes: bytes,
        type: FileType.custom,
        allowedExtensions: ['xml'],
      );

      if (path != null) {
        if (!Platform.isAndroid && !Platform.isIOS) {
          final file = File(path);
          await file.writeAsBytes(bytes);
        }
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.csvExportSuccessNoCount),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.csvExportError(e.toString())),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _openGeneratorDialog(String title, TextEditingController controller) {
    String generated = PasswordGeneratorService.generate(title, recipe: _activeRecipe);


    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: Text(AppLocalizations.of(context)!.passwordGeneratorTitle),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white10,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: SelectableText(
                        generated,
                        style: GoogleFonts.firaCode(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF10B981),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    AppLocalizations.of(context)!.generatorExplanation,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(AppLocalizations.of(context)!.cancel),
                ),
                TextButton(
                  onPressed: () {
                    setStateDialog(() {
                      generated = PasswordGeneratorService.generate(title, recipe: _activeRecipe);
                    });
                  },
                  child: Text(AppLocalizations.of(context)!.regenerate),
                ),
                TextButton(
                  onPressed: () {
                    controller.text = generated;
                    Navigator.pop(context);
                  },
                  child: Text(AppLocalizations.of(context)!.accept),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final report = SecurityHealthService.analyze(widget.entries);
    final query = _searchQuery.toLowerCase();
    final filteredEntries = widget.entries.where((entry) {
      final matchesSearch = entry.title.toLowerCase().contains(query) ||
             entry.username.toLowerCase().contains(query) ||
             entry.website.toLowerCase().contains(query);
      final matchesCategory = _selectedCategory == 'Todos' ||
             entry.category == _selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();

    final favoriteEntries = filteredEntries.where((e) => e.isFavorite).toList();
    final nonFavoriteEntries = filteredEntries.where((e) => !e.isFavorite).toList();

    final List<dynamic> listItems = [];
    if (favoriteEntries.isNotEmpty) {
      listItems.add('header_favorites');
      listItems.addAll(favoriteEntries);
      if (nonFavoriteEntries.isNotEmpty) {
        listItems.add('divider');
      }
    }
    listItems.addAll(nonFavoriteEntries);

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showEntryForm(),
        backgroundColor: const Color(0xFF6750A4),
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Custom Google-style Search Bar Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Row(
                children: [
                  // Left Logo Icon
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.asset(
                      'assets/icon/icon.png',
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Icon(Icons.person, color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Search Input (Pill style)
                  Expanded(
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: TextField(
                        controller: _searchController,
                        textAlignVertical: TextAlignVertical.center,
                        onChanged: (val) {
                          setState(() {
                            _searchQuery = val;
                          });
                        },
                        style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                        decoration: InputDecoration(
                          hintText: AppLocalizations.of(context)!.search,
                          hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.black38),
                          prefixIcon: Icon(Icons.search_rounded, color: isDark ? Colors.white54 : Colors.black54),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  icon: Icon(Icons.clear_rounded, color: isDark ? Colors.white54 : Colors.black54),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() {
                                      _searchQuery = '';
                                    });
                                  },
                                )
                              : null,
                          isDense: true,
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Settings / Config Button (3 vertical dots)
                  PopupMenuButton<String>(
                    icon: Icon(Icons.more_vert, color: isDark ? Colors.white70 : Colors.grey[800]),
                    onSelected: (value) async {
                      if (value == 'import_actions') {
                        if (!isPremiumNotifier.value) {
                          showDialog(context: context, builder: (context) => const PremiumPurchaseDialog());
                          return;
                        }
                        _showImportDialog();
                      } else if (value == 'export_actions') {
                        if (!isPremiumNotifier.value) {
                          showDialog(context: context, builder: (context) => const PremiumPurchaseDialog());
                          return;
                        }
                        _showExportDialog();
                      } else if (value == 'cloud_sync') {
                        final hasAccess = isPremiumNotifier.value || widget.googleUser != null;
                        if (!hasAccess) {
                          showDialog(
                            context: context,
                            builder: (context) => const PremiumPurchaseDialog(),
                          );
                          return;
                        }
                        _showSyncModal();
                      } else if (value == 'buy_premium') {
                        showDialog(
                          context: context,
                          builder: (context) => const PremiumPurchaseDialog(),
                        );
                      } else if (value == 'premium_info') {
                        _showPremiumInfoDialog();
                      } else if (value == 'restore_premium') {
                        _handleRestoreAction();
                      } else if (value == 'manage_categories') {
                        _showManageCategoriesDialog();
                      } else if (value == 'password_recipe') {
                        _showPasswordRecipeDialog();
                      } else if (value == 'health') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SecurityHealthScreen(
                              entries: widget.entries,
                              onUpdateEntry: widget.onUpdateEntry,
                              onDeleteEntry: widget.onDeleteEntry,
                            ),
                          ),
                        );
                      } else if (value == 'theme_toggle') {
                        FocusScope.of(context).unfocus();
                        final newMode = themeNotifier.value == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
                        themeNotifier.value = newMode;
                        const storage = FlutterSecureStorage();
                        await storage.write(key: 'app_theme_mode', value: newMode == ThemeMode.light ? 'light' : 'dark');
                      } else if (value == 'language_toggle') {
                        FocusScope.of(context).unfocus();
                        _showLanguageDialog();
                      } else if (value == 'logout') {
                        widget.onLogout();
                      }
                    },
                    itemBuilder: (context) {
                      final isDark = Theme.of(context).brightness == Brightness.dark;
                      // In-app products currently disabled in Google Play (App 100% free).
                      // To restore paid options in the future:
                      // Re-enable if (isPremium) ... else ... [buy_premium, restore_premium]
                      return [
                        /*
                        if (isPremium)
                          PopupMenuItem<String>(
                            enabled: true,
                            value: 'premium_info',
                            child: Row(
                              children: [
                                Image.asset(
                                  'assets/icon/premium_shield.png',
                                  width: 20,
                                  height: 20,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    AppLocalizations.of(context)!.menuCuentaPremium,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blueAccent,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        else ...[
                          PopupMenuItem<String>(
                            value: 'buy_premium',
                            child: Row(
                              children: [
                                Image.asset(
                                  'assets/icon/premium_shield.png',
                                  width: 20,
                                  height: 20,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    AppLocalizations.of(context)!.menuHaztePremium,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (_hadPremiumBefore)
                            PopupMenuItem<String>(
                              value: 'restore_premium',
                              child: Row(
                                children: [
                                  const Icon(Icons.restore_rounded, size: 20, color: Colors.blueAccent),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      AppLocalizations.of(context)!.menuRecuperarPremium,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                        const PopupMenuDivider(),
                        */
                        PopupMenuItem(
                          value: 'health',
                          child: Row(
                            children: [
                              const Icon(Icons.health_and_safety_outlined, size: 20, color: Color(0xFF10B981)),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(AppLocalizations.of(context)!.securityHealthTitle),
                              ),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'manage_categories',
                          child: Row(
                            children: [
                              const Icon(Icons.category_rounded, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(AppLocalizations.of(context)!.manageCategories),
                              ),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'password_recipe',
                          child: Row(
                            children: [
                              const Icon(Icons.password_rounded, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(AppLocalizations.of(context)!.passwordPattern),
                              ),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'theme_toggle',
                          child: Row(
                            children: [
                              Icon(isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(isDark ? AppLocalizations.of(context)!.lightTheme : AppLocalizations.of(context)!.darkTheme),
                              ),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'language_toggle',
                          child: Row(
                            children: [
                              const Icon(Icons.language_rounded, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(AppLocalizations.of(context)!.language),
                              ),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'cloud_sync',
                          child: Row(
                            children: [
                              const Icon(Icons.cloud_sync_rounded, size: 20, color: Colors.blueAccent),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(AppLocalizations.of(context)!.cloudSyncTitle),
                              ),
                              const SizedBox(width: 6),
                              ValueListenableBuilder<bool>(
                                valueListenable: isPremiumNotifier,
                                builder: (context, isPremium, child) {
                                  if (isPremium) return const SizedBox.shrink();
                                  return Image.asset(
                                    'assets/icon/premium_shield.png',
                                    width: 18,
                                    height: 18,
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'import_actions',
                          child: Row(
                            children: [
                              const Icon(Icons.file_download_rounded, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(AppLocalizations.of(context)!.importData),
                              ),
                              const SizedBox(width: 6),
                              ValueListenableBuilder<bool>(
                                valueListenable: isPremiumNotifier,
                                builder: (context, isPremium, child) {
                                  if (isPremium) return const SizedBox.shrink();
                                  return Image.asset(
                                    'assets/icon/premium_shield.png',
                                    width: 18,
                                    height: 18,
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'export_actions',
                          child: Row(
                            children: [
                              const Icon(Icons.file_upload_rounded, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(AppLocalizations.of(context)!.exportData),
                              ),
                              const SizedBox(width: 6),
                              ValueListenableBuilder<bool>(
                                valueListenable: isPremiumNotifier,
                                builder: (context, isPremium, child) {
                                  if (isPremium) return const SizedBox.shrink();
                                  return Image.asset(
                                    'assets/icon/premium_shield.png',
                                    width: 18,
                                    height: 18,
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'logout',
                          child: Row(
                            children: [
                              const Icon(Icons.logout, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(AppLocalizations.of(context)!.logout),
                              ),
                            ],
                          ),
                        ),
                      ];
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),

          // Category chips filter
          SizedBox(
            height: 48,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final categoryName = _categories[index];
                final isSelected = _selectedCategory == categoryName;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: FilterChip(
                    label: Text(_getLocalizedCategoryName(categoryName)),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = categoryName;
                      });
                    },
                    selectedColor: const Color(0xFF6750A4),
                    checkmarkColor: Colors.white,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    backgroundColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),

          // Main Content Area
          Expanded(
            child: widget.entries.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.lock_person_outlined,
                            size: 80,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            AppLocalizations.of(context)!.emptyKeychain,
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            AppLocalizations.of(context)!.emptyKeychainSubtitle,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  )
                : filteredEntries.isEmpty
                    ? Center(
                        child: Text(
                          AppLocalizations.of(context)!.noMatchesFound,
                          style: const TextStyle(color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        padding: EdgeInsets.only(left: 16, right: 16, top: 8, bottom: MediaQuery.of(context).padding.bottom + 90),
                        itemCount: listItems.length,
                        itemBuilder: (context, index) {
                          final item = listItems[index];

                          if (item == 'header_favorites') {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8, bottom: 8, left: 4),
                              child: Text(
                                AppLocalizations.of(context)!.favoritesHeader,
                                style: TextStyle(
                                  color: isDark ? Colors.amberAccent : Colors.grey[800],
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            );
                          }

                          if (item == 'divider') {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12.0),
                              child: Divider(
                                color: isDark ? Colors.white10 : Colors.black12,
                                thickness: 1,
                              ),
                            );
                          }

                          final entry = item as EntryModel;
                          Color strengthColor;
                          if (entry.password.isEmpty) {
                            strengthColor = Colors.grey;
                          } else if (report.weakEntries.contains(entry)) {
                            strengthColor = Colors.redAccent;
                          } else if (report.reusedEntriesGroups.values.any((group) => group.contains(entry))) {
                            strengthColor = Colors.orangeAccent;
                          } else {
                            strengthColor = const Color(0xFF10B981);
                          }

                          return Container(
                            margin: const EdgeInsets.symmetric(vertical: 2),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              gradient: LinearGradient(
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                                colors: [
                                  strengthColor.withValues(alpha: 0.75),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                            padding: const EdgeInsets.all(2.0),
                            child: Card(
                              margin: EdgeInsets.zero,
                              color: isDark ? const Color(0xFF1E293B) : Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(11),
                              ),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(11),
                                onTap: () => _showEntryDetailsBottomSheet(entry),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 4.0),
                                  child: ListTile(
                                    leading: _buildAvatar(entry),
                                    title: Text(
                                      entry.title,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: isDark ? Colors.white : Colors.grey[850],
                                        fontSize: 18,
                                      ),
                                    ),
                                    trailing: IconButton(
                                      icon: Icon(
                                        entry.isFavorite
                                            ? Icons.star_rounded
                                            : Icons.star_border_rounded,
                                        color: entry.isFavorite
                                            ? Colors.amber
                                            : (isDark ? Colors.white38 : Colors.black38),
                                      ),
                                      onPressed: () async {
                                        final updated = entry.copyWith(
                                          isFavorite: !entry.isFavorite,
                                        );
                                        await widget.onUpdateEntry(updated);
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    ),
  );
  }

  void _showPremiumInfoDialog() {
    showDialog(
      context: context,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final l10n = AppLocalizations.of(context)!;
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
          title: Row(
            children: [
              Image.asset(
                'assets/icon/premium_shield.png',
                width: 28,
                height: 28,
              ),
              const SizedBox(width: 8),
              Text(
                l10n.menuCuentaPremium,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.premiumActiveMessage,
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),
              _buildInfoRow(context, Icons.cloud_done_rounded, l10n.premiumFeatureDriveTitle, l10n.premiumFeatureDriveSubtitle),
              _buildInfoRow(context, Icons.import_export_rounded, l10n.premiumFeatureCsvTitle, l10n.premiumFeatureCsvSubtitle),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.close),
            ),
          ],
        );
      },
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String title, String subtitle) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white60 : Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAddFieldSelectionDialog(StateSetter parentSetState, List<Map<String, dynamic>> dynamicFields) {
    final List<Map<String, dynamic>> predefinedFields = [
      {'title': 'Usuario', 'icon': Icons.person_outline_rounded, 'isSecure': false},
      {'title': 'Contraseña', 'icon': Icons.lock_outline_rounded, 'isSecure': true},
      {'title': 'Fecha', 'icon': Icons.calendar_today_rounded, 'isSecure': false},
      {'title': 'Dirección Web', 'icon': Icons.language_rounded, 'isSecure': false},
      {'title': 'Email', 'icon': Icons.email_outlined, 'isSecure': false},
      {'title': 'PIN', 'icon': Icons.pin_rounded, 'isSecure': true},
    ];

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(AppLocalizations.of(context)!.addNewFieldTitle, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: predefinedFields.length,
                  itemBuilder: (context, index) {
                    final fieldInfo = predefinedFields[index];
                    final title = fieldInfo['title'] as String;
                    String localizedTitle = title;
                    if (title == 'Usuario') localizedTitle = AppLocalizations.of(context)!.username;
                    else if (title == 'Contraseña') localizedTitle = AppLocalizations.of(context)!.password;
                    else if (title == 'Fecha') localizedTitle = AppLocalizations.of(context)!.fieldDate;
                    else if (title == 'Dirección Web') localizedTitle = AppLocalizations.of(context)!.fieldWebAddress;
                    else if (title == 'Email') localizedTitle = AppLocalizations.of(context)!.fieldEmail;
                    else if (title == 'PIN') localizedTitle = AppLocalizations.of(context)!.fieldPin;

                    return ListTile(
                      leading: Icon(fieldInfo['icon'] as IconData),
                      title: Text(localizedTitle),
                      onTap: () {
                        Navigator.pop(context);
                        _showFieldEditorDialog(
                          parentSetState, 
                          dynamicFields, 
                          localizedTitle, 
                          fieldInfo['isSecure'] as bool,
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showFieldEditorDialog(StateSetter parentSetState, List<Map<String, dynamic>> dynamicFields, String defaultName, bool defaultIsSecure) {
    final nameController = TextEditingController(text: defaultName);
    final valueController = TextEditingController();
    bool isSecure = defaultIsSecure;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(AppLocalizations.of(context)!.configureFieldTitle),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(labelText: AppLocalizations.of(context)!.fieldNameLabel),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: valueController,
                    obscureText: isSecure,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.fieldValueLabel,
                      suffixIcon: IconButton(
                        icon: Icon(isSecure ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                        onPressed: () {
                          setDialogState(() {
                            isSecure = !isSecure;
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                TextButton(
                  onPressed: () {
                    parentSetState(() {
                      dynamicFields.add({
                        'nameController': TextEditingController(text: nameController.text),
                        'valueController': TextEditingController(text: valueController.text),
                        'isSecure': defaultIsSecure,
                        'obscure': defaultIsSecure,
                      });
                    });
                    Navigator.pop(context);
                  },
                  child: const Text('Guardar'),
                ),
              ],
            );
          }
        );
      },
    );
  }

  void _showSyncModal() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + MediaQuery.of(context).padding.bottom + 24,
                top: 24,
                left: 24,
                right: 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.cloud_sync_rounded, color: Colors.blueAccent),
                        const SizedBox(width: 12),
                        Text(
                          AppLocalizations.of(context)!.cloudSyncTitle,
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    if (widget.googleUser == null) ...[
                      Text(
                        AppLocalizations.of(context)!.cloudSyncSubtitle,
                        style: const TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: widget.isSyncing
                            ? null
                            : () {
                                Navigator.pop(context);
                                widget.onGoogleSignIn();
                              },
                        icon: const Icon(Icons.login),
                        label: Text(AppLocalizations.of(context)!.connectGoogleDrive),
                      ),
                    ] else ...[
                      Text(
                        AppLocalizations.of(context)!.linkedAccount(widget.googleUser!.email),
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: isDark ? Colors.white : Colors.black87),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.lastBackupTime != null 
                            ? AppLocalizations.of(context)!.lastBackup(widget.lastBackupTime!) 
                            : AppLocalizations.of(context)!.noBackupsOnAccount,
                        style: const TextStyle(color: Colors.blueAccent, fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 20),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          ElevatedButton.icon(
                            onPressed: widget.isSyncing
                                ? null
                                : () {
                                    Navigator.pop(context);
                                    widget.onUpload();
                                  },
                            icon: const Icon(Icons.cloud_upload_rounded),
                            label: Text(AppLocalizations.of(context)!.uploadToDrive, maxLines: 1, overflow: TextOverflow.ellipsis),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton.icon(
                            onPressed: widget.isSyncing
                                ? null
                                : () {
                                    Navigator.pop(context);
                                    widget.onDownload();
                                  },
                            icon: const Icon(Icons.cloud_download_rounded),
                            label: Text(AppLocalizations.of(context)!.downloadFromDrive, maxLines: 1, overflow: TextOverflow.ellipsis),
                          ),
                          const SizedBox(height: 8),
                          OutlinedButton.icon(
                            onPressed: widget.isSyncing
                                ? null
                                : () {
                                    Navigator.pop(context);
                                    _confirmDeleteDrive();
                                  },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.redAccent,
                              side: const BorderSide(color: Colors.redAccent),
                            ),
                            icon: const Icon(Icons.delete_forever),
                            label: Text(AppLocalizations.of(context)!.deleteFromDrive, maxLines: 1, overflow: TextOverflow.ellipsis),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: widget.isSyncing
                            ? null
                            : () {
                                Navigator.pop(context);
                                _confirmDisconnectDrive();
                              },
                        style: OutlinedButton.styleFrom(foregroundColor: Colors.redAccent),
                        icon: const Icon(Icons.logout),
                        label: Text(AppLocalizations.of(context)!.disconnectGoogleDrive),
                      ),
                    ],
                    if (widget.syncStatusMessage != null) ...[
                      const SizedBox(height: 16),
                      Text(
                        widget.syncStatusMessage!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.blueAccent, fontSize: 13),
                      ),
                    ],
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildAttachmentsGallery(String entryId, bool isDark) {
    return _AttachmentsGalleryWidget(entryId: entryId, isDark: isDark);
  }
}

class _AttachmentsGalleryWidget extends StatefulWidget {
  final String entryId;
  final bool isDark;

  const _AttachmentsGalleryWidget({Key? key, required this.entryId, required this.isDark}) : super(key: key);

  @override
  State<_AttachmentsGalleryWidget> createState() => _AttachmentsGalleryWidgetState();
}

class _AttachmentsGalleryWidgetState extends State<_AttachmentsGalleryWidget> {
  late Future<List<AttachmentModel>> _future;

  @override
  void initState() {
    super.initState();
    _future = DatabaseHelper().getAttachmentsForEntry(widget.entryId);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<AttachmentModel>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(24.0),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: const Text('Error loading attachments'),
          );
        }
        final attachments = snapshot.data;
        if (attachments == null || attachments.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text(
                AppLocalizations.of(context)!.attachmentsTitle,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: attachments.map((att) {
                  final isImage = att.mimeType.startsWith('image/');
                  return Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 10.0),
                    child: Card(
                      color: widget.isDark ? const Color(0xFF1E293B) : Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        onTap: () async {
                          if (isImage) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => _FullScreenImageViewer(attachment: att),
                              ),
                            );
                          } else {
                            try {
                              await AttachmentService.viewAttachment(att);
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Error al abrir archivo: $e')),
                                );
                              }
                            }
                          }
                        },
                        child: isImage
                            ? _CardImageAttachmentWidget(attachment: att)
                            : Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.insert_drive_file_rounded,
                                      size: 32,
                                      color: widget.isDark ? Colors.white70 : Colors.black87,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        att.fileName,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                          color: widget.isDark ? Colors.white : Colors.black87,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Icon(
                                      Icons.open_in_new_rounded,
                                      size: 20,
                                      color: widget.isDark ? Colors.white38 : Colors.black38,
                                    ),
                                  ],
                                ),
                              ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _DetailTile extends StatefulWidget {
  final IconData icon;
  final String title;
  final String value;
  final bool isSecure;
  final VoidCallback onCopy;

  const _DetailTile({
    Key? key,
    required this.icon,
    required this.title,
    required this.value,
    required this.isSecure,
    required this.onCopy,
  }) : super(key: key);

  @override
  _DetailTileState createState() => _DetailTileState();
}

class _DetailTileState extends State<_DetailTile> {
  bool _obscure = true;

  @override
  void initState() {
    super.initState();
    _obscure = widget.isSecure;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: widget.onCopy,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(widget.icon, color: isDark ? Colors.white70 : Colors.black87, size: 24),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: TextStyle(
                          color: isDark ? Colors.white54 : Colors.black54,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _obscure ? '•' * widget.value.length : widget.value,
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black87,
                          fontSize: 16,
                          letterSpacing: _obscure ? 2.0 : 0.0,
                        ),
                      ),
                    ],
                  ),
                ),
                if (widget.isSecure)
                  IconButton(
                    icon: Icon(_obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                    color: isDark ? Colors.white54 : Colors.black54,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () {
                      setState(() {
                        _obscure = !_obscure;
                      });
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CardImageAttachmentWidget extends StatefulWidget {
  final AttachmentModel attachment;
  const _CardImageAttachmentWidget({Key? key, required this.attachment}) : super(key: key);

  @override
  State<_CardImageAttachmentWidget> createState() => _CardImageAttachmentWidgetState();
}

class _CardImageAttachmentWidgetState extends State<_CardImageAttachmentWidget> {
  late Future<AttachmentModel?> _future;

  @override
  void initState() {
    super.initState();
    _future = DatabaseHelper().getAttachmentData(widget.attachment.id!);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AttachmentModel?>(
      future: _future,
      builder: (ctx, imgSnapshot) {
        if (!imgSnapshot.hasData || imgSnapshot.data!.fileBytes == null) {
          return Container(
            height: 160,
            width: double.infinity,
            color: Colors.black12,
            child: const Center(child: CircularProgressIndicator()),
          );
        }
        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.memory(
            imgSnapshot.data!.fileBytes!,
            fit: BoxFit.cover,
            width: double.infinity,
          ),
        );
      },
    );
  }
}

class _FullScreenImageViewer extends StatefulWidget {
  final AttachmentModel attachment;
  const _FullScreenImageViewer({Key? key, required this.attachment}) : super(key: key);

  @override
  State<_FullScreenImageViewer> createState() => _FullScreenImageViewerState();
}

class _FullScreenImageViewerState extends State<_FullScreenImageViewer> {
  late Future<AttachmentModel?> _future;

  @override
  void initState() {
    super.initState();
    _future = DatabaseHelper().getAttachmentData(widget.attachment.id!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          widget.attachment.fileName,
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),
      body: FutureBuilder<AttachmentModel?>(
        future: _future,
        builder: (ctx, snapshot) {
          if (!snapshot.hasData || snapshot.data!.fileBytes == null) {
            return const Center(child: CircularProgressIndicator(color: Colors.white));
          }
          final bytes = snapshot.data!.fileBytes!;
          return SizedBox.expand(
            child: InteractiveViewer(
              minScale: 0.5,
              maxScale: 5.0,
              clipBehavior: Clip.none,
              child: Center(
                child: Image.memory(
                  bytes,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
