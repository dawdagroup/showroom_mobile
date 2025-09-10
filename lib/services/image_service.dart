class ImageService {
  /// Base URL for product images on S3
  static const String _baseImageUrl = 'https://s3.azone.co.ke/azoneimgs';
  
  /// Generate the S3 URL for a product image using the item code
  /// 
  /// [itemCode] - The product item code (e.g., "HAE00001")
  /// Returns the complete S3 URL for the product image
  static String getProductImageUrl(String itemCode) {
    if (itemCode.isEmpty) {
      return '';
    }
    return '$_baseImageUrl/$itemCode.jpg';
  }
  
  /// Check if the item code is valid for generating image URL
  /// 
  /// [itemCode] - The product item code to validate
  /// Returns true if the item code is not null or empty
  static bool isValidItemCode(String? itemCode) {
    return itemCode != null && itemCode.isNotEmpty;
  }
}
