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
}