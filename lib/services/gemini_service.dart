import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../models/merch_order.dart';

class GeminiService {
  static const _model = 'gemini-2.5-flash-image';
  final String _apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
  Uri get _endpoint => Uri.parse(
    'https://generativelanguage.googleapis.com/v1beta/models/$_model:generateContent?key=$_apiKey',
  );

  GeminiService() {
    if (_apiKey.isEmpty) {
      throw StateError(
        'GEMINI_API_KEY not set. '
        'Set GEMINI_API_KEY in your .env file.',
      );
    }
  }

  /// Serialise the user selections into a structured JSON block so the model
  /// has every detail in an unambiguous format.
  String _orderSpecJson(MerchOrder order) {
    final spec = {
      'category': order.category,
      'product': order.product,
      'designPlacement': order.placement,
      'baseColor': order.color,
      'designStyle': order.style,
      if (order.tagline != null && order.tagline!.trim().isNotEmpty)
        'taglineText': order.tagline!.trim(),
      'hasUploadedLogo': order.logoFile != null,
    };
    return const JsonEncoder.withIndent('  ').convert(spec);
  }

  String _buildPrompt(MerchOrder order, _ShotType shot) {
    final spec = _orderSpecJson(order);

    final shotInstruction = switch (shot) {
      _ShotType.front =>
        'FRONT VIEW: Show exactly ONE ${order.product.toLowerCase()} from the front. '
            'No duplicates and no extra products. '
            'No mannequin, no person, no hanger. '
            'Pure white background, centered product, straight-on camera, symmetrical framing.',
      _ShotType.back =>
        'BACK VIEW: Show exactly ONE ${order.product.toLowerCase()} from the back. '
            'It must be the exact same item as the front shot (same color, fabric, fit, and design). '
            'This is a back-only camera angle: do not show the front panel of the garment. '
            'Do not mirror, reuse, or clone the front image composition. '
            'No duplicates and no extra products. '
            'No mannequin, no person, no hanger. '
            'Pure white background, centered product, straight-on camera, symmetrical framing.',
      _ShotType.lifestyle =>
        'LIFESTYLE SHOT: Show exactly ONE person wearing/using the exact same '
            '${order.product.toLowerCase()} from the front/back images. '
            'No second model and no extra garments of the same product in frame. '
            'Simple, minimal background (or softly blurred neutral background). '
            'The ${order.product.toLowerCase()} must occupy most of the frame and remain the focus. '
            'Design details must match the spec exactly.',
    };

    final logoLine = order.logoFile != null
        ? 'Use the uploaded logo image as an immutable reference asset. '
            'Reproduce the logo exactly as uploaded (same shapes, proportions, spacing, orientation, and all colors). '
            'Do not redraw, restyle, simplify, recolor, distort, blur, or reinterpret the logo. '
            'Place that exact logo at the specified placement area.'
        : '';

    final taglineLine = (order.tagline != null && order.tagline!.trim().isNotEmpty)
        ? 'Render the tagline text exactly as: "${order.tagline!.trim()}". '
            'Keep spelling, capitalization, punctuation, and spacing exactly identical. '
            'Do not paraphrase, replace, or edit any character.'
        : '';

    return '''
Generate a single photorealistic product image.

PRODUCT SPECIFICATION (follow exactly):
$spec

$shotInstruction

Design requirements:
- Base color of the product: ${order.color}.
- Design style: ${order.style}.
- Design placement: ${order.placement}.
- Color fidelity is strict: preserve the exact colors from provided references with no hue shift, tint, saturation change, or tone remapping.
- Ensure all generated views (front, back, lifestyle) use the exact same product/base color and the same design color palette.
$logoLine
$taglineLine

Image requirements:
- Aspect ratio MUST be 3:4 (portrait).
- High resolution, photorealistic, studio-quality lighting.
- The product must be the clear focal point of the image.\n- Show exactly ONE product instance in the image (never multiple).\n- Do not create collages, grids, triptychs, or side-by-side comparisons.\n- Keep background minimal and non-distracting so the product fills most of the frame.
''';
  }

  /// Generate 3 images: front, back, and lifestyle.
  Future<List<Uint8List>> generateDesigns(MerchOrder order) async {
    final shots = _ShotType.values;
    final futures = shots.map((shot) => _generateSingle(order, shot));
    final results = await Future.wait(futures);
    return results.whereType<Uint8List>().toList();
  }

  Future<Uint8List?> _generateSingle(MerchOrder order, _ShotType shot) async {
    final prompt = _buildPrompt(order, shot);

    print('--- MERCH_AI PROMPT [${shot.name.toUpperCase()}] ---');
    print(prompt);
    print('--- END PROMPT ---');

    try {
      final parts = <Map<String, Object>>[];

      if (order.logoFile != null) {
        final bytes = await order.logoFile!.readAsBytes();
        final mime = _mimeFromPath(order.logoFile!.path);
        parts.add({
          'inlineData': {
            'mimeType': mime,
            'data': base64Encode(bytes),
          },
        });
      }

      parts.add({'text': prompt});

      final body = jsonEncode({
        'contents': [
          {'parts': parts},
        ],
        'generationConfig': {
          'responseModalities': ['TEXT', 'IMAGE'],
          'imageConfig': {
            'aspectRatio': '3:4',
            'imageSize': '2K',
          },
        },
      });

      print('--- MERCH_AI REQUEST BODY [${shot.name.toUpperCase()}] ---');
      print(body);
      print('--- END REQUEST BODY ---');

      debugPrint('MERCH_AI: Sending ${shot.name} request to Gemini...');

      final response = await http.post(
        _endpoint,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode != 200) {
        debugPrint('MERCH_AI: HTTP ${response.statusCode} - ${response.body}');
        return null;
      }

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final candidates = json['candidates'] as List<dynamic>?;
      if (candidates == null || candidates.isEmpty) {
        debugPrint('MERCH_AI: No candidates in response');
        return null;
      }

      final content = candidates[0]['content'] as Map<String, dynamic>?;
      final resParts = content?['parts'] as List<dynamic>?;
      if (resParts == null) {
        debugPrint('MERCH_AI: No parts in response');
        return null;
      }

      for (final part in resParts) {
        if (part is Map && part.containsKey('inlineData')) {
          final inlineData = part['inlineData'] as Map<String, dynamic>;
          final b64 = inlineData['data'] as String;
          final bytes = base64Decode(b64);
          debugPrint('MERCH_AI: Got ${shot.name} image (${bytes.length} bytes)');
          return Uint8List.fromList(bytes);
        }
      }

      debugPrint('MERCH_AI: No image data in response parts');
      return null;
    } catch (e, stack) {
      debugPrint('MERCH_AI ERROR [${shot.name}]: $e');
      debugPrint('$stack');
      return null;
    }
  }

  String _mimeFromPath(String path) {
    final lower = path.toLowerCase();
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.webp')) return 'image/webp';
    if (lower.endsWith('.heic')) return 'image/heic';
    return 'image/jpeg';
  }
}

enum _ShotType { front, back, lifestyle }
