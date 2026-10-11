import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants.dart';
import '../../core/theme.dart';
import '../../data/models.dart';
import '../../services/settings_storage.dart';
import 'widgets/time_slider.dart';

class ConfigurationScreen extends ConsumerStatefulWidget {
  final String category;
  final String? initialOperation;

  const ConfigurationScreen({
    Key? key,
    required this.category,
    this.initialOperation,
  }) : super(key: key);

  @override
  ConsumerState<ConfigurationScreen> createState() => _ConfigurationScreenState();
}

class _ConfigurationScreenState extends ConsumerState<ConfigurationScreen> {
  // General
  String _difficulty = 'Medium';
  int _timerSeconds = 60;
  int _questionCount = 20;

  // Arithmetic
  late String _selectedOperation;
  int _digits = 2; // 1, 2, 3
  int _operandsCount = 2; // 2, 3

  // Random Calculations
  List<String> _enabledOperations = ['Addition', 'Subtraction', 'Multiplication', 'Squares'];

  // BODMAS
  String _bracketComplexity = 'Simple (a + b) × c';

  // Number Series
  String _seriesPattern = 'Mixed Patterns';

  // Inequalities
  String _inequalityType = 'Expression Comparison';

  // Mental Maths
  int _mentalValuesCount = 4;
  int _mentalDigitLength = 1; // 1 = Single, 2 = Double
  double _mentalDisplayInterval = 1.4; // 1.0, 1.4, 1.8, 2.2
  String _mentalOperationMode = 'Add & Subtract (+/-)';

  // Missing Number
  String _missingType = 'Missing Operand (a + ? = c)';

  // Number Puzzles
  String _puzzleType = 'Mixed Puzzles';

  // Mixed Practice
  List<String> _mixedCategories = [
    'Arithmetic',
    'Random Calculations',
    'BODMAS Challenge',
    'Number Series',
  ];

  // Custom Practice Preset
  String _presetName = 'Default Practice';
  List<String> _savedPresetNames = [];

  bool _isNavigating = false;

  String get _storageKey {
    if (widget.category == 'Arithmetic' || widget.category == 'Basic Arithmetic') {
      return 'Arithmetic_${_selectedOperation}';
    }
    return widget.category;
  }

  @override
  void initState() {
    super.initState();
    _selectedOperation = widget.initialOperation ?? 'Multiplication';
    _loadPersistedSettings();
  }

  Future<void> _loadPersistedSettings() async {
    final settings = await SettingsStorage.loadSettings(_storageKey);
    final presets = await SettingsStorage.loadCustomPresets();

    if (mounted) {
      setState(() {
        if (settings != null) {
          if (settings.containsKey('difficulty')) _difficulty = settings['difficulty'];
          if (settings.containsKey('timerSeconds')) _timerSeconds = settings['timerSeconds'];
          if (settings.containsKey('questionCount')) _questionCount = settings['questionCount'];
          if (settings.containsKey('digits')) _digits = settings['digits'];
          if (settings.containsKey('operandsCount')) _operandsCount = settings['operandsCount'];
          if (settings.containsKey('bracketComplexity')) _bracketComplexity = settings['bracketComplexity'];
          if (settings.containsKey('seriesPattern')) _seriesPattern = settings['seriesPattern'];
          if (settings.containsKey('inequalityType')) _inequalityType = settings['inequalityType'];
          if (settings.containsKey('mentalValuesCount')) _mentalValuesCount = settings['mentalValuesCount'];
          if (settings.containsKey('mentalDigitLength')) _mentalDigitLength = settings['mentalDigitLength'];
          if (settings.containsKey('mentalDisplayInterval')) {
            _mentalDisplayInterval = (settings['mentalDisplayInterval'] as num).toDouble();
          }
          if (settings.containsKey('mentalOperationMode')) _mentalOperationMode = settings['mentalOperationMode'];
          if (settings.containsKey('missingType')) _missingType = settings['missingType'];
          if (settings.containsKey('puzzleType')) _puzzleType = settings['puzzleType'];
          if (settings.containsKey('enabledOperations')) {
            _enabledOperations = List<String>.from(settings['enabledOperations']);
          }
          if (settings.containsKey('mixedCategories')) {
            _mixedCategories = List<String>.from(settings['mixedCategories']);
          }
        }
        _savedPresetNames = presets.keys.toList();
      });
    }
  }

  Future<void> _saveCurrentSettings() async {
    final data = {
      'difficulty': _difficulty,
      'timerSeconds': _timerSeconds,
      'questionCount': _questionCount,
      'digits': _digits,
      'operandsCount': _operandsCount,
      'bracketComplexity': _bracketComplexity,
      'seriesPattern': _seriesPattern,
      'inequalityType': _inequalityType,
      'mentalValuesCount': _mentalValuesCount,
      'mentalDigitLength': _mentalDigitLength,
      'mentalDisplayInterval': _mentalDisplayInterval,
      'mentalOperationMode': _mentalOperationMode,
      'missingType': _missingType,
      'puzzleType': _puzzleType,
      'enabledOperations': _enabledOperations,
      'mixedCategories': _mixedCategories,
    };
    await SettingsStorage.saveSettings(_storageKey, data);
  }

  void _startPractice() async {
    if (_isNavigating) return;
    setState(() => _isNavigating = true);
    HapticFeedback.mediumImpact();

    await _saveCurrentSettings();

    final config = PracticeConfiguration(
      category: widget.category,
      difficulty: _difficulty,
      timerSeconds: _timerSeconds,
      questionCount: _questionCount,
      operation: _selectedOperation,
      digits: _digits,
      operandsCount: _operandsCount,
      subType: _getSubTypeForCategory(),
      enabledOperations: _enabledOperations,
      enabledCategories: _mixedCategories,
      stepDurationSeconds: _mentalDisplayInterval,
    );

    if (!mounted) return;

    if (widget.category == 'Mental Maths' || widget.category == 'Mental Calculation') {
      context.push('/mental-session', extra: config).then((_) {
        if (mounted) setState(() => _isNavigating = false);
      });
    } else {
      context.push('/session', extra: config).then((_) {
        if (mounted) setState(() => _isNavigating = false);
      });
    }
  }

  String _getSubTypeForCategory() {
    switch (widget.category) {
      case 'BODMAS Challenge':
        return _bracketComplexity;
      case 'Number Series':
        return _seriesPattern;
      case 'Inequalities':
        return _inequalityType;
      case 'Mental Maths':
      case 'Mental Calculation':
        return _mentalOperationMode;
      case 'Missing Number':
        return _missingType;
      case 'Number Puzzles':
        return _puzzleType;
      default:
        return _selectedOperation;
    }
  }

  @override
  Widget build(BuildContext context) {
    final metadata = AppConstants.categoryDetails[widget.category] ??
        CategoryMetadata(
          title: widget.category,
          description: 'Customize practice settings',
          icon: Icons.calculate,
          color: AppColors.pastelBlue,
        );

    final isArithmetic = widget.category == 'Arithmetic' || widget.category == 'Basic Arithmetic';

    return Scaffold(
      backgroundColor: AppColors.backgroundCream,
      appBar: AppBar(
        title: Text(
          isArithmetic ? '$_selectedOperation Config' : '${metadata.title} Config',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Category Header Banner
              _buildCategoryHeader(metadata, isArithmetic),

              const SizedBox(height: 16),

              // Category-Specific Options
              _buildCategorySpecificSettings(),

              const SizedBox(height: 16),

              // Difficulty Selector (if applicable)
              _buildDifficultyCard(),

              const SizedBox(height: 16),

              // Established Smooth Draggable Time Slider with MM:SS & Presets
              CalcupTimeSlider(
                selectedSeconds: _timerSeconds,
                onTimeChanged: (newSecs) {
                  setState(() => _timerSeconds = newSecs);
                  _saveCurrentSettings();
                },
              ),

              const SizedBox(height: 24),

              // Start Practice Button
              SizedBox(
                height: 56,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.play_arrow_rounded, size: 26),
                  label: const Text(
                    "Start Practice",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryOrange,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    elevation: 3,
                  ),
                  onPressed: _startPractice,
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryHeader(CategoryMetadata metadata, bool isArithmetic) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: metadata.color.withOpacity(0.35),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: metadata.color.withOpacity(0.8), width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.8),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(metadata.icon, color: AppColors.textPrimary, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isArithmetic ? '${metadata.title} • $_selectedOperation' : metadata.title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 18),
                ),
                const SizedBox(height: 2),
                Text(
                  metadata.description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textPrimary.withOpacity(0.8),
                        fontSize: 12,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySpecificSettings() {
    switch (widget.category) {
      case 'Arithmetic':
      case 'Basic Arithmetic':
        return _buildArithmeticSettings();
      case 'Random Calculations':
        return _buildRandomCalculationsSettings();
      case 'BODMAS Challenge':
        return _buildBodmasSettings();
      case 'Number Series':
        return _buildNumberSeriesSettings();
      case 'Inequalities':
        return _buildInequalitiesSettings();
      case 'Mental Maths':
      case 'Mental Calculation':
        return _buildMentalMathsSettings();
      case 'Missing Number':
        return _buildMissingNumberSettings();
      case 'Number Puzzles':
        return _buildNumberPuzzlesSettings();
      case 'Mixed Practice':
        return _buildMixedPracticeSettings();
      case 'Custom Practice':
        return _buildCustomPracticeSettings();
      default:
        return _buildArithmeticSettings();
    }
  }

  // 1. Arithmetic Settings
  Widget _buildArithmeticSettings() {
    return _buildConfigSection(
      title: "Operation Parameters",
      icon: Icons.tune_rounded,
      children: [
        _buildSectionSubtitle("Number of Digits:"),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildChoiceChip(
              label: "1-Digit (1-9)",
              isSelected: _digits == 1,
              onTap: () => setState(() => _digits = 1),
            ),
            const SizedBox(width: 8),
            _buildChoiceChip(
              label: "2-Digit (10-99)",
              isSelected: _digits == 2,
              onTap: () => setState(() => _digits = 2),
            ),
            const SizedBox(width: 8),
            _buildChoiceChip(
              label: "3-Digit",
              isSelected: _digits == 3,
              onTap: () => setState(() => _digits = 3),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildSectionSubtitle("Numbers Per Question:"),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildChoiceChip(
              label: "2 Numbers (a ${_getOpSymbol()} b)",
              isSelected: _operandsCount == 2,
              onTap: () => setState(() => _operandsCount = 2),
            ),
            const SizedBox(width: 8),
            _buildChoiceChip(
              label: "3 Numbers (a ${_getOpSymbol()} b ${_getOpSymbol()} c)",
              isSelected: _operandsCount == 3,
              onTap: () => setState(() => _operandsCount = 3),
            ),
          ],
        ),
      ],
    );
  }

  String _getOpSymbol() {
    switch (_selectedOperation) {
      case 'Addition':
        return '+';
      case 'Subtraction':
        return '-';
      case 'Multiplication':
        return '×';
      case 'Division':
        return '÷';
      default:
        return '±';
    }
  }

  // 2. Random Calculations Settings
  Widget _buildRandomCalculationsSettings() {
    final allOps = ['Addition', 'Subtraction', 'Multiplication', 'Division', 'Squares', 'Percentages'];

    return _buildConfigSection(
      title: "Random Calculations Options",
      icon: Icons.shuffle_rounded,
      children: [
        _buildSectionSubtitle("Enabled Arithmetic Operations:"),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: allOps.map((op) {
            final isEnabled = _enabledOperations.contains(op);
            return FilterChip(
              label: Text(op),
              selected: isEnabled,
              selectedColor: AppColors.pastelGreen,
              backgroundColor: AppColors.backgroundCream,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _enabledOperations.add(op);
                  } else if (_enabledOperations.length > 1) {
                    _enabledOperations.remove(op);
                  }
                });
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        _buildSectionSubtitle("Number of Digits:"),
        const SizedBox(height: 8),
        Row(
          children: [1, 2, 3].map((d) {
            return Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: _buildChoiceChip(
                label: "$d-Digit",
                isSelected: _digits == d,
                onTap: () => setState(() => _digits = d),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        _buildSectionSubtitle("Numbers Per Question:"),
        const SizedBox(height: 8),
        Row(
          children: [2, 3, 4].map((cnt) {
            return Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: _buildChoiceChip(
                label: "$cnt Operands",
                isSelected: _operandsCount == cnt,
                onTap: () => setState(() => _operandsCount = cnt),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // 3. BODMAS Challenge Settings
  Widget _buildBodmasSettings() {
    final complexities = [
      'Simple (a + b) × c',
      'Nested [a + (b × c)]',
      'Advanced (a × b) - (c ÷ d)',
    ];

    return _buildConfigSection(
      title: "BODMAS Structure",
      icon: Icons.functions_rounded,
      children: [
        _buildSectionSubtitle("Bracket Complexity:"),
        const SizedBox(height: 8),
        Column(
          children: complexities.map((c) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: _buildFullWidthRadioTile(
                title: c,
                isSelected: _bracketComplexity == c,
                onTap: () => setState(() => _bracketComplexity = c),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 10),
        _buildSectionSubtitle("Number of Digits:"),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildChoiceChip(
              label: "1-Digit (Fast pace)",
              isSelected: _digits == 1,
              onTap: () => setState(() => _digits = 1),
            ),
            const SizedBox(width: 8),
            _buildChoiceChip(
              label: "2-Digit (Complex)",
              isSelected: _digits == 2,
              onTap: () => setState(() => _digits = 2),
            ),
          ],
        ),
      ],
    );
  }

  // 4. Number Series Settings
  Widget _buildNumberSeriesSettings() {
    final patterns = [
      'Mixed Patterns',
      'Arithmetic (+step)',
      'Increasing Diff (+2, +4, +6)',
      'Geometric (×2, ×4)',
      'Squares & Cubes (n², n³)',
    ];

    return _buildConfigSection(
      title: "Series Pattern Rules",
      icon: Icons.format_list_numbered_rounded,
      children: [
        _buildSectionSubtitle("Select Pattern Types:"),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: patterns.map((p) {
            return _buildChoiceChip(
              label: p,
              isSelected: _seriesPattern == p,
              onTap: () => setState(() => _seriesPattern = p),
            );
          }).toList(),
        ),
      ],
    );
  }

  // 5. Inequalities Settings
  Widget _buildInequalitiesSettings() {
    final types = [
      'Number Comparison',
      'Expression Comparison',
      'Variable Inequalities',
    ];

    return _buildConfigSection(
      title: "Comparison Type",
      icon: Icons.compare_arrows_rounded,
      children: [
        _buildSectionSubtitle("Choose Inequality Mode:"),
        const SizedBox(height: 8),
        Column(
          children: types.map((t) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: _buildFullWidthRadioTile(
                title: t,
                isSelected: _inequalityType == t,
                onTap: () => setState(() => _inequalityType = t),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // 6. Mental Maths Settings
  Widget _buildMentalMathsSettings() {
    final modes = [
      'Addition only (+)',
      'Add & Subtract (+/-)',
      'Mixed Operations',
    ];

    final speeds = [
      {'label': '1.0s (Fast)', 'val': 1.0},
      {'label': '1.4s (Standard)', 'val': 1.4},
      {'label': '1.8s (Relaxed)', 'val': 1.8},
      {'label': '2.2s (Learning)', 'val': 2.2},
    ];

    return _buildConfigSection(
      title: "Mental Flash Settings",
      icon: Icons.psychology_rounded,
      children: [
        _buildSectionSubtitle("Number of Values Shown:"),
        const SizedBox(height: 8),
        Row(
          children: [3, 4, 5, 6].map((cnt) {
            return Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: _buildChoiceChip(
                label: "$cnt Values",
                isSelected: _mentalValuesCount == cnt,
                onTap: () => setState(() => _mentalValuesCount = cnt),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        _buildSectionSubtitle("Digit Length:"),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildChoiceChip(
              label: "Single Digit (1-9)",
              isSelected: _mentalDigitLength == 1,
              onTap: () => setState(() => _mentalDigitLength = 1),
            ),
            const SizedBox(width: 8),
            _buildChoiceChip(
              label: "Double Digit (10-99)",
              isSelected: _mentalDigitLength == 2,
              onTap: () => setState(() => _mentalDigitLength = 2),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildSectionSubtitle("Display Interval (Flash Speed):"),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: speeds.map((s) {
            final val = s['val'] as double;
            return _buildChoiceChip(
              label: s['label'] as String,
              isSelected: (_mentalDisplayInterval - val).abs() < 0.05,
              onTap: () => setState(() => _mentalDisplayInterval = val),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        _buildSectionSubtitle("Operation Mode:"),
        const SizedBox(height: 8),
        Column(
          children: modes.map((m) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: _buildFullWidthRadioTile(
                title: m,
                isSelected: _mentalOperationMode == m,
                onTap: () => setState(() => _mentalOperationMode = m),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // 7. Missing Number Settings
  Widget _buildMissingNumberSettings() {
    final targets = [
      'Missing Operand (a + ? = c)',
      'Missing Equation Value (? × b = c)',
      'Missing Sequence Term (a, b, ?, d)',
    ];

    return _buildConfigSection(
      title: "Missing Element Type",
      icon: Icons.help_outline_rounded,
      children: [
        _buildSectionSubtitle("Select Question Target:"),
        const SizedBox(height: 8),
        Column(
          children: targets.map((t) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: _buildFullWidthRadioTile(
                title: t,
                isSelected: _missingType == t,
                onTap: () => setState(() => _missingType = t),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // 8. Number Puzzles Settings
  Widget _buildNumberPuzzlesSettings() {
    final puzzleTypes = [
      'Mixed Puzzles',
      'Square & Cube Patterns (x → x²±k)',
      'Consecutive Products (x → x(x+1))',
      'Custom Operators (a ⊕ b)',
      'Digit Multiplication (d1 × d2)',
    ];

    return _buildConfigSection(
      title: "Supported Puzzle Types",
      icon: Icons.extension_rounded,
      children: [
        _buildSectionSubtitle("Select Logic Pattern:"),
        const SizedBox(height: 8),
        Column(
          children: puzzleTypes.map((pt) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: _buildFullWidthRadioTile(
                title: pt,
                isSelected: _puzzleType == pt,
                onTap: () => setState(() => _puzzleType = pt),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // 9. Mixed Practice Settings
  Widget _buildMixedPracticeSettings() {
    final allCats = [
      'Arithmetic',
      'Random Calculations',
      'BODMAS Challenge',
      'Number Series',
      'Inequalities',
      'Missing Number',
      'Number Puzzles',
    ];

    return _buildConfigSection(
      title: "Mixed Practice Composition",
      icon: Icons.category_rounded,
      children: [
        _buildSectionSubtitle("Included Categories:"),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: allCats.map((cat) {
            final isIncluded = _mixedCategories.contains(cat);
            return FilterChip(
              label: Text(cat),
              selected: isIncluded,
              selectedColor: AppColors.pastelPurple,
              backgroundColor: AppColors.backgroundCream,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              onSelected: (sel) {
                setState(() {
                  if (sel) {
                    _mixedCategories.add(cat);
                  } else if (_mixedCategories.length > 1) {
                    _mixedCategories.remove(cat);
                  }
                });
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        _buildSectionSubtitle("Question Count:"),
        const SizedBox(height: 8),
        Row(
          children: [10, 20, 30, 50].map((qCount) {
            return Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: _buildChoiceChip(
                label: "$qCount Qs",
                isSelected: _questionCount == qCount,
                onTap: () => setState(() => _questionCount = qCount),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // 10. Custom Practice Settings & Presets
  Widget _buildCustomPracticeSettings() {
    return _buildConfigSection(
      title: "Custom Practice Presets",
      icon: Icons.tune_rounded,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildSectionSubtitle("Saved Presets:"),
            TextButton.icon(
              icon: const Icon(Icons.bookmark_add, size: 16),
              label: const Text("Save Current", style: TextStyle(fontSize: 13)),
              onPressed: _showSavePresetDialog,
            ),
          ],
        ),
        if (_savedPresetNames.isNotEmpty) ...[
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _savedPresetNames.map((name) {
              final isSelected = _presetName == name;
              return ActionChip(
                label: Text(name),
                backgroundColor: isSelected ? AppColors.highlightYellow : AppColors.backgroundCream,
                onPressed: () => _loadPreset(name),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
        ],
        _buildSectionSubtitle("Operations & Modules:"),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: ['Arithmetic', 'Random Calculations', 'BODMAS Challenge', 'Number Series'].map((cat) {
            final isIncluded = _mixedCategories.contains(cat);
            return FilterChip(
              label: Text(cat),
              selected: isIncluded,
              selectedColor: AppColors.pastelGreen,
              backgroundColor: AppColors.backgroundCream,
              onSelected: (sel) {
                setState(() {
                  if (sel) {
                    _mixedCategories.add(cat);
                  } else if (_mixedCategories.length > 1) {
                    _mixedCategories.remove(cat);
                  }
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  void _showSavePresetDialog() {
    final controller = TextEditingController(text: "My Drill");
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Save Custom Preset"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: "Preset Name"),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                await SettingsStorage.saveCustomPreset(name, {
                  'difficulty': _difficulty,
                  'timerSeconds': _timerSeconds,
                  'questionCount': _questionCount,
                  'mixedCategories': _mixedCategories,
                });
                Navigator.pop(ctx);
                _loadPersistedSettings();
              }
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  void _loadPreset(String name) async {
    final presets = await SettingsStorage.loadCustomPresets();
    if (presets.containsKey(name)) {
      final config = presets[name] as Map<String, dynamic>;
      setState(() {
        _presetName = name;
        if (config.containsKey('difficulty')) _difficulty = config['difficulty'];
        if (config.containsKey('timerSeconds')) _timerSeconds = config['timerSeconds'];
        if (config.containsKey('questionCount')) _questionCount = config['questionCount'];
        if (config.containsKey('mixedCategories')) {
          _mixedCategories = List<String>.from(config['mixedCategories']);
        }
      });
    }
  }

  // Difficulty Card (Reusable)
  Widget _buildDifficultyCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfacePrimary,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.black.withOpacity(0.04), width: 1),
      ),
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.pastelGreen.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.speed_rounded, color: AppColors.textPrimary, size: 20),
              ),
              const SizedBox(width: 10),
              Text("Difficulty", style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 18)),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: ['Easy', 'Medium', 'Hard'].map((d) {
              final isSelected = _difficulty == d;
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: _buildChoiceChip(
                  label: d,
                  isSelected: isSelected,
                  onTap: () {
                    setState(() => _difficulty = d);
                    _saveCurrentSettings();
                  },
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // Helper Card Framework
  Widget _buildConfigSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfacePrimary,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.black.withOpacity(0.04), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.pastelPurple.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: AppColors.textPrimary, size: 20),
              ),
              const SizedBox(width: 10),
              Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 18)),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSectionSubtitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.bold,
        color: AppColors.textSecondary,
      ),
    );
  }

  Widget _buildChoiceChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: AppColors.pastelGreen,
      backgroundColor: AppColors.backgroundCream,
      labelStyle: TextStyle(
        fontSize: 13,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
        color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: isSelected ? AppColors.successGreen : Colors.transparent,
          width: 1.2,
        ),
      ),
      onSelected: (_) {
        HapticFeedback.selectionClick();
        onTap();
        _saveCurrentSettings();
      },
    );
  }

  Widget _buildFullWidthRadioTile({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
        _saveCurrentSettings();
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.pastelBlue.withOpacity(0.25) : AppColors.backgroundCream,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.pastelBlue : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              size: 20,
              color: isSelected ? AppColors.primaryOrange : AppColors.textSecondary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
