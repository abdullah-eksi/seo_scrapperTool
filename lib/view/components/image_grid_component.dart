import 'package:flutter/material.dart';

class ImageGridComponent extends StatelessWidget {
  final List<Map<String, String>> images;

  const ImageGridComponent({super.key, required this.images});

  @override
  Widget build(BuildContext context) {
    if (images.isEmpty) {
      return _buildEmptyState();
    }

    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, // Her satırda 3 resim
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 0.6, // Daha uzun kartlar için detay bilgileri
      ),
      itemCount: images.length,
      itemBuilder: (context, index) {
        return _buildImageCard(images[index], index, context);
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.image_not_supported,
              size: 64,
              color: Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Hiç Resim Bulunamadı',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Bu sayfada resim içeriği tespit edilemedi',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildImageCard(
    Map<String, String> image,
    int index,
    BuildContext ctx,
  ) {
    final imageSrc = image['src'] ?? '';
    final imageAlt = image['alt'] ?? 'Resim ${index + 1}';
    final imageTitle = image['title'] ?? '';
    final imageWidth = image['width'] ?? '';
    final imageHeight = image['height'] ?? '';
    final imageType = image['type'] ?? '';
    final imageSrcset = image['srcset'] ?? '';

    // Dosya bilgilerini hesapla
    final fileExtension = _getFileExtension(imageSrc);
    final fileSize = _estimateFileSize(imageWidth, imageHeight, fileExtension);

    // Debug: konsola yazdır
    print(
      '🖼️ Image $index: width=$imageWidth, height=$imageHeight, fileSize=$fileSize',
    );

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              child: imageSrc.isNotEmpty
                  ? Image.network(
                      imageSrc,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      headers: {
                        'User-Agent':
                            'Mozilla/5.0 (Windows NT 10.0; Win64; x64)',
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) =>
                          _buildErrorPlaceholder(),
                    )
                  : _buildErrorPlaceholder(),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade50, Colors.indigo.shade50],
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Üst satır: Index ve fullscreen butonu
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade100,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: Icon(
                        Icons.fullscreen,
                        size: 14,
                        color: Colors.blue.shade600,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () =>
                          _showImageDialog(ctx, imageSrc, imageAlt),
                    ),
                  ],
                ),
                const SizedBox(height: 4),

                // Alt text
                if (imageAlt.isNotEmpty && imageAlt != 'Resim ${index + 1}')
                  _buildInfoRow(
                    'Alt:',
                    imageAlt,
                    Icons.description_outlined,
                    Colors.green.shade600,
                  ),

                // Title text
                if (imageTitle.isNotEmpty)
                  _buildInfoRow(
                    'Title:',
                    imageTitle,
                    Icons.title_outlined,
                    Colors.orange.shade600,
                  ),

                // Boyut bilgisi
                if (imageWidth.isNotEmpty || imageHeight.isNotEmpty)
                  _buildInfoRow(
                    'Boyut:',
                    '${imageWidth}x${imageHeight}',
                    Icons.aspect_ratio_outlined,
                    Colors.purple.shade600,
                  ),

                // Tip bilgisi (dosya uzantısı ile)
                if (imageType.isNotEmpty || fileExtension.isNotEmpty)
                  _buildInfoRow(
                    'Tip:',
                    imageType.isNotEmpty
                        ? '$imageType ($fileExtension)'
                        : fileExtension,
                    Icons.category_outlined,
                    Colors.red.shade600,
                  ),

                // Dosya boyutu (her zaman göster)
                _buildInfoRow(
                  'Boyut:',
                  fileSize,
                  Icons.data_usage_outlined,
                  Colors.orange.shade600,
                ),

                // Srcset bilgisi (varsa)
                if (imageSrcset.isNotEmpty)
                  _buildInfoRow(
                    'Srcset:',
                    'Var',
                    Icons.photo_size_select_actual_outlined,
                    Colors.indigo.shade600,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorPlaceholder() {
    return Container(
      color: Colors.grey.shade200,
      child: const Center(
        child: Icon(Icons.broken_image, color: Colors.grey, size: 32),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        children: [
          Icon(icon, size: 10, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(width: 2),
          Expanded(
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showImageDialog(BuildContext context, String src, String alt) {
    if (src.isEmpty) return;
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
              child: Image.network(src, fit: BoxFit.contain),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                alt,
                style: const TextStyle(fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// URL'den dosya uzantısını çıkarır
  String _getFileExtension(String url) {
    if (url.isEmpty) return '';

    try {
      // Query parametrelerini temizle
      final cleanUrl = url.split('?').first.split('#').first;
      final parts = cleanUrl.split('/').last.split('.');

      if (parts.length > 1) {
        final extension = parts.last.toLowerCase();
        // Yaygın resim uzantıları
        const validExtensions = [
          'jpg',
          'jpeg',
          'png',
          'gif',
          'webp',
          'svg',
          'bmp',
          'tiff',
          'avif',
        ];
        if (validExtensions.contains(extension)) {
          return extension.toUpperCase();
        }
      }
    } catch (e) {
      // Hata durumunda boş döndür
    }

    return 'IMG';
  }

  /// Tahmini dosya boyutunu hesaplar
  String _estimateFileSize(
    String imageWidth,
    String imageHeight,
    String extension,
  ) {
    try {
      final width = int.tryParse(imageWidth) ?? 0;
      final height = int.tryParse(imageHeight) ?? 0;

      if (width > 0 && height > 0) {
        final pixels = width * height;
        double estimatedBytes = 0;

        switch (extension.toLowerCase()) {
          case 'jpg':
          case 'jpeg':
            estimatedBytes = pixels * 0.3; // JPEG sıkıştırma
            break;
          case 'png':
            estimatedBytes = pixels * 1.5; // PNG sıkıştırma
            break;
          case 'webp':
            estimatedBytes = pixels * 0.2; // WebP sıkıştırma
            break;
          case 'gif':
            estimatedBytes = pixels * 0.5; // GIF sıkıştırma
            break;
          default:
            estimatedBytes = pixels * 0.5; // Varsayılan
        }

        return _formatFileSize(estimatedBytes);
      } else {
        // Boyut bilgisi yoksa varsayılan tahminler
        switch (extension.toLowerCase()) {
          case 'jpg':
          case 'jpeg':
            return '~150KB'; // Ortalama JPEG
          case 'png':
            return '~300KB'; // Ortalama PNG
          case 'webp':
            return '~100KB'; // Ortalama WebP
          case 'gif':
            return '~200KB'; // Ortalama GIF
          case 'svg':
            return '~50KB'; // Ortalama SVG
          default:
            return '~200KB'; // Varsayılan
        }
      }
    } catch (e) {
      // Hata durumunda varsayılan
      return '~200KB';
    }
  }

  /// Byte'ları okunabilir formata çevirir
  String _formatFileSize(double bytes) {
    if (bytes < 1024) return '${bytes.round()}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
  }
}
