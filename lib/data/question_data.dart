const List<String> categories = [
  'Apparel',
  'Accessories',
  'Drinkware',
  'Stickers & Prints',
];

const Map<String, List<String>> productsByCategory = {
  'Apparel': ['T-Shirts', 'Hoodies', 'Polos', 'Oversized Tees', 'Sweatshirts'],
  'Accessories': ['Caps', 'Tote Bags', 'Phone Cases', 'Laptop Sleeves'],
  'Drinkware': ['Coffee Mugs', 'Travel Mugs', 'Water Bottles'],
  'Stickers & Prints': [
    'Die-cut Stickers',
    'Sticker Sheets',
    'Posters',
    'Art Prints',
  ],
};

const Map<String, List<String>> placementsByProduct = {
  // Apparel
  'T-Shirts': ['Front Center', 'Back Print', 'Pocket Logo', 'Sleeve'],
  'Hoodies': ['Front Center', 'Back Print', 'Pocket Logo', 'Sleeve'],
  'Polos': ['Pocket Logo', 'Back Print', 'Sleeve'],
  'Oversized Tees': ['Front Center', 'Back Print', 'Full Front'],
  'Sweatshirts': ['Front Center', 'Back Print', 'Pocket Logo'],
  // Accessories
  'Caps': ['Front Panel', 'Side Embroidery'],
  'Tote Bags': ['Center', 'All-over Print'],
  'Phone Cases': ['Full Back', 'Center Logo'],
  'Laptop Sleeves': ['Center', 'Corner Logo'],
  // Drinkware
  'Coffee Mugs': ['Wrap-around', 'Front'],
  'Travel Mugs': ['Wrap-around', 'Front'],
  'Water Bottles': ['Wrap-around', 'Front'],
  // Stickers & Prints
  'Die-cut Stickers': ['Full Bleed', 'Centered'],
  'Sticker Sheets': ['Full Bleed', 'Centered'],
  'Posters': ['Full Bleed', 'Centered'],
  'Art Prints': ['Full Bleed', 'Centered'],
};

const Map<String, List<String>> colorsByCategory = {
  'Apparel': ['Black', 'White', 'Navy Blue', 'Heather Grey', 'Olive Green', 'Maroon'],
  'Accessories': ['Black', 'White', 'Khaki', 'Navy'],
  'Drinkware': ['White', 'Black', 'Matte Black'],
  'Stickers & Prints': ['White Background', 'Transparent', 'Custom'],
};

const List<String> designStyles = [
  'Minimal',
  'Streetwear',
  'Bold / Graphic',
  'Clean / Corporate',
  'Retro / Vintage',
];
