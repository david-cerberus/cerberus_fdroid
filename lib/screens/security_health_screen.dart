import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/entry_model.dart';
import '../services/security_health_service.dart';
import '../services/password_generator_service.dart';
import '../l10n/app_localizations.dart';

class SecurityHealthScreen extends StatefulWidget {
  final List<EntryModel> entries;
  final Future<void> Function(EntryModel) onUpdateEntry;
  final Future<void> Function(String) onDeleteEntry;

  const SecurityHealthScreen({
    super.key,
    required this.entries,
    required this.onUpdateEntry,
    required this.onDeleteEntry,
  });

  @override
  State<SecurityHealthScreen> createState() => _SecurityHealthScreenState();
}

class _SecurityHealthScreenState extends State<SecurityHealthScreen> {
  late List<EntryModel> _localEntries;
  PasswordRecipe _activeRecipe = PasswordRecipe.defaultRecipe;
  final List<String> _categories = [
    'General',
    'Bancos',
    'Cuentas Web',
    'Emails',
    'Foros',
    'Router',
    'Tienda',
    'Otros',
  ];

  @override
  void initState() {
    super.initState();
    _localEntries = List.from(widget.entries);
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    const storage = FlutterSecureStorage();
    try {
      final categoriesData = await storage.read(key: 'custom_categories');
      if (categoriesData != null) {
        final List<dynamic> decoded = jsonDecode(categoriesData);
        setState(() {
          _categories.clear();
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
    } catch (_) {}
  }

  Color _getScoreColor(double score) {
    if (score < 50.0) return Colors.redAccent;
    if (score < 80.0) return Colors.orangeAccent;
    return const Color(0xFF10B981);
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

  void _showEntryForm(EntryModel entry) {
    final titleController = TextEditingController(text: entry.title);
    final usernameController = TextEditingController(text: entry.username);
    final passwordController = TextEditingController(text: entry.password);
    final websiteController = TextEditingController(text: entry.website);
    final notesController = TextEditingController(text: entry.notes);
    String selectedCategory = entry.category;

    bool obscurePassword = true;

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
            final pwd = passwordController.text;
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
                    bottom: MediaQuery.of(context).viewInsets.bottom + 24,
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
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
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.person_outline_rounded, color: isDark ? Colors.white70 : Colors.black54),
                                  onPressed: () => _copyToClipboard(usernameController.text, AppLocalizations.of(context)!.username),
                                  tooltip: AppLocalizations.of(context)!.copyTooltip,
                                ),
                                IconButton(
                                  icon: Icon(Icons.vpn_key_outlined, color: isDark ? Colors.white70 : Colors.black54),
                                  onPressed: () => _copyToClipboard(passwordController.text, AppLocalizations.of(context)!.password),
                                  tooltip: AppLocalizations.of(context)!.copyTooltip,
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
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: titleController,
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
                          decoration: InputDecoration(
                            labelText: AppLocalizations.of(context)!.websiteUrl,
                            prefixIcon: const Icon(Icons.link_rounded),
                            border: const OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: notesController,
                          maxLines: 3,
                          decoration: InputDecoration(
                            labelText: AppLocalizations.of(context)!.additionalNotes,
                            prefixIcon: const Icon(Icons.notes_rounded),
                            border: const OutlineInputBorder(),
                          ),
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

                                  final updatedEntry = EntryModel(
                                    id: entry.id,
                                    title: titleController.text.trim(),
                                    username: usernameController.text.trim(),
                                    password: passwordController.text,
                                    website: websiteController.text.trim(),
                                    notes: notesController.text.trim(),
                                    isFavorite: entry.isFavorite,
                                    category: selectedCategory,
                                    deleted: false,
                                  );

                                  Navigator.pop(context);
                                  await widget.onUpdateEntry(updatedEntry);
                                  setState(() {
                                    final index = _localEntries.indexWhere((e) => e.id == entry.id);
                                    if (index != -1) {
                                      _localEntries[index] = updatedEntry;
                                    }
                                  });
                                },
                                child: Text(
                                  AppLocalizations.of(context)!.save,
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
              setState(() {
                _localEntries.removeWhere((e) => e.id == id);
              });
            },
            child: Text(AppLocalizations.of(context)!.delete),
          ),
        ],
      ),
    );
  }

  void _openGeneratorDialog(String title, TextEditingController controller) {
    if (title.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.writeTitleGenerate),
          backgroundColor: Colors.orangeAccent,
        ),
      );
      return;
    }

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
    final report = SecurityHealthService.analyze(_localEntries);
    final scoreColor = _getScoreColor(report.score);

    // Sum up the count of reused passwords
    int totalReused = 0;
    for (final group in report.reusedEntriesGroups.values) {
      totalReused += group.length;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.securityHealthTitle),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Circular Progress Score Header
              Center(
                child: Card(
                  elevation: 3,
                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 30.0, horizontal: 24.0),
                    child: Column(
                      children: [
                        SizedBox(
                          width: 150,
                          height: 150,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              SizedBox(
                                width: 140,
                                height: 140,
                                child: CircularProgressIndicator(
                                  value: report.score / 100,
                                  strokeWidth: 12,
                                  backgroundColor: isDark ? Colors.white10 : Colors.black12,
                                  valueColor: AlwaysStoppedAnimation<Color>(scoreColor),
                                ),
                              ),
                              Text(
                                '${report.score.toStringAsFixed(0)}%',
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: scoreColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          AppLocalizations.of(context)!.globalSecurityScore,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        if (report.isCapped) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.redAccent.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.redAccent.withValues(alpha: 0.4)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 16),
                                const SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    report.capReason?.contains('critical_weak') == true
                                        ? 'Puntuación limitada por contraseñas débiles críticas'
                                        : 'Puntuación limitada por alta tasa de reutilización (>30%)',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.redAccent,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
  
              // Red Card (Weak Passwords)
              Card(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                child: ExpansionTile(
                  leading: const Icon(Icons.error_outline_rounded, color: Colors.redAccent),
                  title: Text(
                    AppLocalizations.of(context)!.weakPasswordsCount(report.weakEntries.length),
                    style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87),
                  ),
                  subtitle: Text(AppLocalizations.of(context)!.weakPasswordsSubtitle, style: TextStyle(color: isDark ? Colors.grey : Colors.black54, fontSize: 12)),
                  children: report.weakEntries.isEmpty
                      ? [
                          ListTile(
                            title: Text(AppLocalizations.of(context)!.noWeakPasswords, style: TextStyle(color: isDark ? Colors.grey : Colors.black54)),
                          )
                        ]
                      : report.weakEntries.map((entry) {
                          bool obscure = true;
                          return StatefulBuilder(builder: (context, setStateItem) {
                            return ListTile(
                              title: Text(entry.title, style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
                              subtitle: Row(
                                children: [
                                  Expanded(child: Text(obscure ? '••••••••' : entry.password, style: GoogleFonts.firaCode(color: isDark ? Colors.grey : Colors.black54))),
                                  IconButton(
                                    icon: Icon(obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined, size: 18, color: isDark ? Colors.grey : Colors.black54),
                                    onPressed: () => setStateItem(() => obscure = !obscure),
                                  ),
                                ]
                              ),
                              trailing: IconButton(
                                icon: Icon(Icons.edit_rounded, size: 18, color: isDark ? Colors.white54 : Colors.black54),
                                onPressed: () => _showEntryForm(entry),
                              ),
                            );
                          });
                        }).toList(),
                ),
              ),
              const SizedBox(height: 12),
  
              // Yellow Card (Reused Passwords)
              Card(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                child: ExpansionTile(
                  leading: const Icon(Icons.warning_amber_rounded, color: Colors.orangeAccent),
                  title: Text(
                    AppLocalizations.of(context)!.reusedPasswordsCount(totalReused),
                    style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87),
                  ),
                  subtitle: Text(AppLocalizations.of(context)!.reusedPasswordsSubtitle, style: TextStyle(color: isDark ? Colors.grey : Colors.black54, fontSize: 12)),
                  children: report.reusedEntriesGroups.isEmpty
                      ? [
                          ListTile(
                            title: Text(AppLocalizations.of(context)!.noReusedPasswords, style: TextStyle(color: isDark ? Colors.grey : Colors.black54)),
                          )
                        ]
                      : report.reusedEntriesGroups.entries.map((group) {
                          bool obscure = true;
                          return StatefulBuilder(builder: (context, setStateGroup) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: isDark ? Colors.white.withValues(alpha: 0.03) : Colors.black.withValues(alpha: 0.03),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
                                ),
                                child: ExpansionTile(
                                  title: Text(AppLocalizations.of(context)!.password + ':', style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontWeight: FontWeight.bold, fontSize: 14)),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(child: Text(obscure ? '••••••••' : group.key, style: GoogleFonts.firaCode(fontSize: 14, color: Colors.orangeAccent))),
                                          IconButton(
                                            icon: Icon(obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined, size: 18, color: isDark ? Colors.grey : Colors.black54),
                                            onPressed: () => setStateGroup(() => obscure = !obscure),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(AppLocalizations.of(context)!.accountsUsePassword(group.value.length), style: TextStyle(color: isDark ? Colors.grey : Colors.black54, fontSize: 12)),
                                    ],
                                  ),
                                  children: group.value.map((entry) {
                                    return ListTile(
                                      title: Text(entry.title, style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
                                      trailing: IconButton(
                                        icon: Icon(Icons.edit_rounded, size: 18, color: isDark ? Colors.white54 : Colors.black54),
                                        onPressed: () => _showEntryForm(entry),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                            );
                          });
                        }).toList(),
                ),
              ),
              const SizedBox(height: 12),
  
              // Green Card (Secure Passwords)
              Card(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                child: ExpansionTile(
                  leading: const Icon(Icons.check_circle_outline_rounded, color: Color(0xFF10B981)),
                  title: Text(
                    AppLocalizations.of(context)!.securePasswordsCount(report.secureEntries.length),
                    style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87),
                  ),
                  subtitle: Text(AppLocalizations.of(context)!.strongPasswordsSubtitle, style: TextStyle(color: isDark ? Colors.grey : Colors.black54, fontSize: 12)),
                  children: report.secureEntries.isEmpty
                      ? [
                          ListTile(
                            title: Text(AppLocalizations.of(context)!.noStrongPasswords, style: TextStyle(color: isDark ? Colors.grey : Colors.black54)),
                          )
                        ]
                      : report.secureEntries.map((entry) {
                          bool obscure = true;
                          return StatefulBuilder(builder: (context, setStateItem) {
                            return ListTile(
                              title: Text(entry.title, style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
                              subtitle: Row(
                                children: [
                                  Expanded(child: Text(obscure ? '••••••••' : entry.password, style: GoogleFonts.firaCode(color: isDark ? Colors.grey : Colors.black54))),
                                  IconButton(
                                    icon: Icon(obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined, size: 18, color: isDark ? Colors.grey : Colors.black54),
                                    onPressed: () => setStateItem(() => obscure = !obscure),
                                  ),
                                ]
                              ),
                              trailing: IconButton(
                                icon: Icon(Icons.edit_rounded, size: 18, color: isDark ? Colors.white54 : Colors.black54),
                                onPressed: () => _showEntryForm(entry),
                              ),
                            );
                          });
                        }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
