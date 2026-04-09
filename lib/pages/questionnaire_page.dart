import 'dart:io';

import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../data/question_data.dart';
import '../providers/merch_provider.dart';
import '../widgets/option_tile.dart';
import '../widgets/progress_bar.dart';
import '../widgets/review_row.dart';
import '../widgets/step_wrap.dart';
import '../widgets/upload_box.dart';
import 'results_page.dart';

class QuestionnairePage extends StatefulWidget {
  const QuestionnairePage({super.key});

  @override
  State<QuestionnairePage> createState() => _QuestionnairePageState();
}

class _QuestionnairePageState extends State<QuestionnairePage> {
  final TextEditingController _taglineController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();
  String? _tshirtSvgTemplate;

  static const String _whiteFillToken = 'fill="rgb(100%, 100%, 100%)"';

  static const _paletteColors = <Color>[
    Color(0xFFFFFFFF), // White
    Color(0xFF111111), // Black
    Color(0xFF1D3557), // Navy
    Color(0xFF9FA3AA), // Grey
    Color(0xFF556B2F), // Olive
    Color(0xFF7A1F2A), // Maroon
    Color(0xFFC3B091), // Khaki
    Color(0xFFE63946), // Red
    Color(0xFF2A9D8F), // Teal
    Color(0xFF264653), // Slate
  ];

  @override
  void initState() {
    super.initState();
    _loadTshirtSvg();
  }

  @override
  void dispose() {
    _taglineController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MerchProvider>();

    return Material(
      color: const Color(0xFFEEE8F7),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 44),
                      child: ProgressBar(progress: provider.progress),
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        onPressed: provider.stepIndex > 0 && !provider.isGenerating
                            ? provider.prevStep
                            : null,
                        icon: const Icon(Icons.arrow_back_rounded),
                        color: const Color(0xFF11111C),
                        disabledColor: const Color(0xFF9896A2),
                        tooltip: 'Back',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 260),
                    layoutBuilder: (currentChild, previousChildren) {
                      return Align(
                        alignment: Alignment.topCenter,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Stack(
                            alignment: Alignment.topCenter,
                            children: [
                              ...previousChildren,
                              if (currentChild != null) currentChild,
                            ],
                          ),
                        ),
                      );
                    },
                    child: provider.isGenerating
                        ? _buildGenerating()
                        : _buildStep(provider),
                  ),
                ),
                const SizedBox(height: 16),
                _buildBottomButtons(provider),
                const SizedBox(height: 26),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Step bodies
  // ---------------------------------------------------------------------------

  Widget _buildStep(MerchProvider p) {
    switch (p.stepIndex) {
      case 0:
        return _optionStep(
          key: 'category',
          title: 'What are you creating?',
          options: categories,
          selected: p.selectedCategory,
          onSelect: p.selectCategory,
        );

      case 1:
        return _optionStep(
          key: 'product',
          title: 'Which product?',
          options: p.availableProducts,
          selected: p.selectedProduct,
          onSelect: p.selectProduct,
        );

      case 2:
        return _buildLogoStep(p);

      case 3:
        return _buildTaglineStep();

      case 4:
        return _optionStep(
          key: 'placement',
          title: 'Where should we place your design?',
          options: p.availablePlacements,
          selected: p.selectedPlacement,
          onSelect: p.selectPlacement,
        );

      case 5:
        return _buildBaseColorStep(p);

      case 6:
        return _optionStep(
          key: 'style',
          title: 'Choose your style',
          options: designStyles,
          selected: p.selectedStyle,
          onSelect: p.selectStyle,
        );

      case 7:
      default:
        return _buildReview(p);
    }
  }

  Widget _optionStep({
    required String key,
    required String title,
    required List<String> options,
    required String? selected,
    required ValueChanged<String> onSelect,
  }) {
    return StepWrap(
      key: ValueKey(key),
      title: title,
      children: [
        for (int i = 0; i < options.length; i++) ...[
          OptionTile(
            title: options[i],
            selected: selected == options[i],
            onTap: () => onSelect(options[i]),
          ),
          if (i < options.length - 1) const SizedBox(height: 14),
        ],
      ],
    );
  }

  Widget _buildLogoStep(MerchProvider p) {
    final hasLogo = p.logoFile != null;

    return StepWrap(
      key: const ValueKey('logo'),
      title: 'Upload your logo',
      subtitle: 'Add your brand logo or design file (optional)',
      children: [
        const SizedBox(height: 8),
        if (!hasLogo) ...[
          UploadBox(onTap: () => _pickLogo(p), boxHeight: 140),
          const SizedBox(height: 10),
          const Text(
            'Supports PNG, JPG, WEBP, HEIC',
            style: TextStyle(fontSize: 14, color: Color(0xFF5D5C63)),
          ),
        ] else ...[
          Container(
            width: double.infinity,
            constraints: const BoxConstraints(minHeight: 180, maxHeight: 300),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.55),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Image.file(
                        File(p.logoFile!.path),
                        fit: BoxFit.contain,
                        errorBuilder: (_, _, _) => Container(
                          color: const Color(0xFFE7E1F2),
                          alignment: Alignment.center,
                          child: const Icon(Icons.image_not_supported_outlined),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Material(
                    color: Colors.black.withValues(alpha: 0.45),
                    shape: const CircleBorder(),
                    child: IconButton(
                      onPressed: () => p.setLogo(null),
                      icon: const Icon(Icons.close_rounded, color: Colors.white),
                      tooltip: 'Remove image',
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTaglineStep() {
    return StepWrap(
      key: const ValueKey('tagline'),
      title: 'Add a tagline',
      children: [
        TextField(
          controller: _taglineController,
          onChanged: (val) => context.read<MerchProvider>().tagline = val,
          decoration: InputDecoration(
            hintText: 'try: "Stay Rooted" or "Built Different"',
            fillColor: Colors.white.withValues(alpha: 0.8),
            filled: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBaseColorStep(MerchProvider p) {
    final svgData = _buildColoredSvg(p.baseColor);

    // SizedBox.expand so it fills the AnimatedSwitcher's Stack fully.
    return SizedBox.expand(
      key: const ValueKey('color'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Pick your base color',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: Color(0xFF121218),
            ),
          ),
          const SizedBox(height: 20),

          // --- T-shirt preview (fills remaining space) ---
          Flexible(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.55),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: svgData == null
                          ? const CircularProgressIndicator(strokeWidth: 2.5)
                          : SvgPicture.string(svgData, fit: BoxFit.contain),
                    ),
                  ),
                  // Hex badge
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFF121218),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        _toHex(p.baseColor),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // --- Color palette row ---
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                for (final color in _paletteColors)
                  _ColorSwatch(
                    color: color,
                    isSelected: _isSameColor(p.baseColor, color),
                    onTap: () => p.setBaseColor(color),
                  ),
                // Custom color button
                _CustomColorSwatch(
                  currentColor: p.baseColor,
                  isSelected: !_paletteColors.any((c) => _isSameColor(p.baseColor, c)),
                  onTap: () => _openColorPicker(p),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  bool _isSameColor(Color a, Color b) {
    return a.red == b.red && a.green == b.green && a.blue == b.blue;
  }

  void _openColorPicker(MerchProvider p) {
    Color tempColor = p.baseColor;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          decoration: const BoxDecoration(
            color: Color(0xFFF5F0FC),
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFCBC4D6),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Text(
              'Custom Color',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF121218),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 340,
              child: ColorPicker(
                pickerColor: tempColor,
                onColorChanged: (c) => tempColor = c,
                enableAlpha: false,
                portraitOnly: true,
                pickerAreaHeightPercent: 0.55,
                labelTypes: const [],
                pickerAreaBorderRadius: const BorderRadius.all(Radius.circular(14)),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  p.setBaseColor(tempColor);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: const Color(0xFF11111C),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
                child: const Text(
                  'Apply Color',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }

  Widget _buildReview(MerchProvider p) {
    return StepWrap(
      key: const ValueKey('review'),
      title: 'Review your design',
      children: [
        ReviewRow(label: 'Category', value: p.selectedCategory ?? '-'),
        ReviewRow(label: 'Product', value: p.selectedProduct ?? '-'),
        ReviewRow(label: 'Placement', value: p.selectedPlacement ?? '-'),
        ReviewRow(label: 'Color', value: p.selectedColor ?? '-'),
        ReviewRow(label: 'Style', value: p.selectedStyle ?? '-'),
        ReviewRow(
          label: 'Tagline',
          value: p.tagline.trim().isEmpty ? '-' : p.tagline.trim(),
        ),
        ReviewRow(label: 'Logo', value: p.logoFile != null ? p.logoName! : 'None'),
      ],
    );
  }

  Widget _buildGenerating() {
    return const Center(
      key: ValueKey('generating'),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 40,
            height: 40,
            child: CircularProgressIndicator(strokeWidth: 3),
          ),
          SizedBox(height: 20),
          Text(
            'Creating your designs...',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w800,
              color: Color(0xFF121218),
            ),
          ),
          SizedBox(height: 10),
          Text(
            'Generating mockups and style variations.\nThis may take a minute.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 15, height: 1.4, color: Color(0xFF4E4D56)),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Bottom buttons
  // ---------------------------------------------------------------------------

  Widget _buildBottomButtons(MerchProvider p) {
    final String label;
    if (p.isGenerating) {
      label = 'Generating...';
    } else if (p.stepIndex == 7) {
      label = 'Generate Design';
    } else {
      label = 'Continue';
    }

    return Column(
      children: [
        SizedBox(
          height: 62,
          width: double.infinity,
          child: ElevatedButton(
            onPressed: p.isGenerating ? null : () => _onPrimary(p),
            style: ElevatedButton.styleFrom(
              elevation: 0,
              backgroundColor: const Color(0xFF11111C),
              foregroundColor: Colors.white,
              disabledBackgroundColor: const Color(0xFF3A3944),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(100),
              ),
            ),
            child: Text(
              label,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Actions
  // ---------------------------------------------------------------------------

  Future<void> _onPrimary(MerchProvider p) async {
    if (p.stepIndex < 7) {
      if (!_validateCurrentStep(p)) return;
      p.nextStep();
      return;
    }

    await p.generate();
    if (!mounted) return;

    if (p.generatedImages.isNotEmpty) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const ResultsPage()),
      );
    } else if (p.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(p.error!)),
      );
    }
  }

  bool _validateCurrentStep(MerchProvider p) {
    switch (p.stepIndex) {
      case 0:
        return _requireSelection(p.selectedCategory, 'Please select a category');
      case 1:
        return _requireSelection(p.selectedProduct, 'Please select a product');
      case 4:
        return _requireSelection(p.selectedPlacement, 'Please select a placement');
      case 5:
        return true;
      case 6:
        return _requireSelection(p.selectedStyle, 'Please choose a style');
      default:
        return true;
    }
  }

  bool _requireSelection(String? value, String message) {
    if (value != null) return true;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    return false;
  }

  Future<void> _pickLogo(MerchProvider p) async {
    final picked = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 95,
    );
    if (picked == null || !mounted) return;
    p.setLogo(picked);
  }

  Future<void> _loadTshirtSvg() async {
    try {
      final svg = await rootBundle.loadString('assets/Tshirt.svg');
      if (!mounted) return;
      setState(() => _tshirtSvgTemplate = svg);
    } catch (_) {
      if (!mounted) return;
      setState(() => _tshirtSvgTemplate = null);
    }
  }

  String? _buildColoredSvg(Color color) {
    final template = _tshirtSvgTemplate;
    if (template == null) return null;
    final replacement = 'fill="${_toHex(color)}"';
    return template.replaceAll(_whiteFillToken, replacement);
  }

  String _toHex(Color color) {
    final r = color.red.toRadixString(16).padLeft(2, '0');
    final g = color.green.toRadixString(16).padLeft(2, '0');
    final b = color.blue.toRadixString(16).padLeft(2, '0');
    return '#${(r + g + b).toUpperCase()}';
  }
}

// ---------------------------------------------------------------------------
// Swatch widgets
// ---------------------------------------------------------------------------

class _ColorSwatch extends StatelessWidget {
  const _ColorSwatch({
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  bool get _isWhite =>
      color.red > 240 && color.green > 240 && color.blue > 240;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected
                ? const Color(0xFF6C3FC5)
                : _isWhite
                    ? const Color(0xFFD0CDD8)
                    : Colors.transparent,
            width: isSelected ? 2.5 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.45),
                    blurRadius: 8,
                    spreadRadius: 1,
                  )
                ]
              : null,
        ),
      ),
    );
  }
}

class _CustomColorSwatch extends StatelessWidget {
  const _CustomColorSwatch({
    required this.currentColor,
    required this.isSelected,
    required this.onTap,
  });

  final Color currentColor;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const SweepGradient(
            colors: [
              Color(0xFFFF0000),
              Color(0xFFFFFF00),
              Color(0xFF00FF00),
              Color(0xFF00FFFF),
              Color(0xFF0000FF),
              Color(0xFFFF00FF),
              Color(0xFFFF0000),
            ],
          ),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF6C3FC5)
                : Colors.transparent,
            width: isSelected ? 2.5 : 1,
          ),
        ),
      ),
    );
  }
}
