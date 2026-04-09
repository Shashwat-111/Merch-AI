import 'dart:io';

import 'package:flutter/material.dart';
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
        return _optionStep(
          key: 'color',
          title: 'Pick your base color',
          options: p.availableColors,
          selected: p.selectedColor,
          onSelect: p.selectColor,
        );

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
        return _requireSelection(p.selectedColor, 'Please pick a color');
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
}
