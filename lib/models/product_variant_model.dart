// models/product_variant_model.dart
class LocalProductVariant {
  final String? cjVariantId;
  final String? sku;
  final Map<String, dynamic> attributes;
  final double wholesalePrice;
  final int weightG;
  final int stock;

  LocalProductVariant({
    this.cjVariantId,
    this.sku,
    required this.attributes,
    this.wholesalePrice = 0.0,
    this.weightG = 0,
    this.stock = 0,
  });

  // 1. Added factory constructor for deserialization
  factory LocalProductVariant.fromJson(Map<String, dynamic> json) {
    return LocalProductVariant(
      cjVariantId: json['cj_variant_id'],
      sku: json['sku'],
      attributes: json['attributes'] is Map<String, dynamic> 
          ? json['attributes'] 
          : {},
      wholesalePrice: double.tryParse(json['wholesale_price'].toString()) ?? 0.0,
      weightG: json['weight_g'] ?? 0,
      stock: json['stock'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (cjVariantId != null) 'cj_variant_id': cjVariantId,
      if (sku != null) 'sku': sku,
      'attributes': attributes,
      'wholesale_price': wholesalePrice,
      'weight_g': weightG,
      'stock': stock,
    };
  }

  // 2. Added convenience helper for UI text labels
  String get formattedAttributes {
    if (attributes.isEmpty) return "Standard Option";
    return attributes.entries.map((e) => "${e.key}: ${e.value}").join(", ");
  }
}