import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../data/question_data.dart';
import '../models/merch_order.dart';
import '../services/gemini_service.dart';

class MerchProvider extends ChangeNotifier {
  static const int totalSteps = 8; // 0-category through 7-review

  final GeminiService _gemini = GeminiService();

  // --- Step state ---
  int _stepIndex = 0;
  int get stepIndex => _stepIndex;

  // --- Selections ---
  String? _selectedCategory;
  String? get selectedCategory => _selectedCategory;

  String? _selectedProduct;
  String? get selectedProduct => _selectedProduct;

  String? _selectedPlacement;
  String? get selectedPlacement => _selectedPlacement;

  String? _selectedColor = '#FFFFFF';
  String? get selectedColor => _selectedColor;
  Color _baseColor = Colors.white;
  Color get baseColor => _baseColor;

  String? _selectedStyle;
  String? get selectedStyle => _selectedStyle;

  String tagline = '';

  XFile? _logoFile;
  XFile? get logoFile => _logoFile;
  String? get logoName =>
      _logoFile == null ? null : _logoFile!.name.isNotEmpty ? _logoFile!.name : _logoFile!.path.split('/').last;

  // --- Generation ---
  bool _isGenerating = false;
  bool get isGenerating => _isGenerating;

  String? _error;
  String? get error => _error;

  List<Uint8List> _generatedImages = [];
  List<Uint8List> get generatedImages => _generatedImages;

  // --- Conditional option getters ---

  List<String> get availableProducts {
    if (_selectedCategory == null) return [];
    return productsByCategory[_selectedCategory] ?? [];
  }

  List<String> get availablePlacements {
    if (_selectedProduct == null) return [];
    return placementsByProduct[_selectedProduct] ?? [];
  }

  List<String> get availableColors {
    if (_selectedCategory == null) return [];
    return colorsByCategory[_selectedCategory] ?? [];
  }

  // --- Progress (0..1) ---
  double get progress {
    if (_generatedImages.isNotEmpty) return 1.0;
    if (_isGenerating) return 0.95;
    return ((_stepIndex + 1) / totalSteps).clamp(0.0, 1.0);
  }

  // --- Selection methods (reset dependents on upstream change) ---

  void selectCategory(String value) {
    _selectedCategory = value;
    _selectedProduct = null;
    _selectedPlacement = null;
    _selectedColor = null;
    notifyListeners();
  }

  void selectProduct(String value) {
    _selectedProduct = value;
    _selectedPlacement = null;
    notifyListeners();
  }

  void selectPlacement(String value) {
    _selectedPlacement = value;
    notifyListeners();
  }

  void selectColor(String value) {
    _selectedColor = value;
    final mapped = _namedColorValue(value);
    if (mapped != null) _baseColor = mapped;
    notifyListeners();
  }

  void setBaseColor(Color color) {
    _baseColor = color;
    _selectedColor = _toHex(color);
    notifyListeners();
  }

  void selectStyle(String value) {
    _selectedStyle = value;
    notifyListeners();
  }

  void setLogo(XFile? file) {
    _logoFile = file;
    notifyListeners();
  }

  // --- Navigation ---

  void nextStep() {
    if (_stepIndex < totalSteps - 1) {
      _stepIndex++;
      notifyListeners();
    }
  }

  void prevStep() {
    if (_stepIndex > 0) {
      _stepIndex--;
      notifyListeners();
    }
  }

  // --- Generation ---

  MerchOrder _buildOrder() {
    return MerchOrder(
      category: _selectedCategory ?? '',
      product: _selectedProduct ?? '',
      placement: _selectedPlacement ?? '',
      color: _selectedColor ?? '',
      style: _selectedStyle ?? '',
      tagline: tagline.trim().isEmpty ? null : tagline.trim(),
      logoFile: _logoFile,
    );
  }

  Future<void> generate() async {
    _isGenerating = true;
    _error = null;
    _generatedImages = [];
    notifyListeners();

    try {
      final order = _buildOrder();
      debugPrint('MERCH_AI: Starting generation for $order');
      final images = await _gemini.generateDesigns(order);

      if (images.isEmpty) {
        _error = 'No images were generated. Please try again.';
      } else {
        _generatedImages = images;
      }
    } catch (e) {
      debugPrint('MERCH_AI: Generation failed: $e');
      _error = 'Generation failed: $e';
    } finally {
      _isGenerating = false;
      notifyListeners();
    }
  }

  // --- Reset ---

  void reset() {
    _stepIndex = 0;
    _selectedCategory = null;
    _selectedProduct = null;
    _selectedPlacement = null;
    _selectedColor = '#FFFFFF';
    _baseColor = Colors.white;
    _selectedStyle = null;
    tagline = '';
    _logoFile = null;
    _isGenerating = false;
    _error = null;
    _generatedImages = [];
    notifyListeners();
  }

  Color? _namedColorValue(String name) {
    switch (name.toLowerCase()) {
      case 'black':
      case 'matte black':
        return const Color(0xFF111111);
      case 'white':
      case 'white background':
      case 'transparent':
        return Colors.white;
      case 'navy':
      case 'navy blue':
        return const Color(0xFF1D3557);
      case 'heather grey':
        return const Color(0xFF9FA3AA);
      case 'olive green':
        return const Color(0xFF556B2F);
      case 'maroon':
        return const Color(0xFF7A1F2A);
      case 'khaki':
        return const Color(0xFFC3B091);
      case 'custom':
        return _baseColor;
      default:
        return null;
    }
  }

  String _toHex(Color color) {
    final r = color.red.toRadixString(16).padLeft(2, '0');
    final g = color.green.toRadixString(16).padLeft(2, '0');
    final b = color.blue.toRadixString(16).padLeft(2, '0');
    return '#${(r + g + b).toUpperCase()}';
  }
}
