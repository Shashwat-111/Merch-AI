import 'package:image_picker/image_picker.dart';

class MerchOrder {
  final String category;
  final String product;
  final String placement;
  final String color;
  final String style;
  final String? tagline;
  final XFile? logoFile;

  const MerchOrder({
    required this.category,
    required this.product,
    required this.placement,
    required this.color,
    required this.style,
    this.tagline,
    this.logoFile,
  });

  @override
  String toString() =>
      'MerchOrder(category: $category, product: $product, placement: $placement, '
      'color: $color, style: $style, tagline: $tagline, hasLogo: ${logoFile != null})';
}
