import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SeoInfoComponent extends StatelessWidget {
  final Map<String, String> seoInfo;

  const SeoInfoComponent({super.key, required this.seoInfo});

  @override
  Widget build(BuildContext context) {
    if (seoInfo.isEmpty) {
      return _buildEmptyState();
    }

    final entries = seoInfo.entries.toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 600;
        
        return ListView.builder(
          padding: EdgeInsets.all(isWide ? 24 : 16),
          itemCount: entries.length,
          itemBuilder: (context, index) {
            final entry = entries[index];
            return _buildSeoCard(entry.key, entry.value, index, isWide);
          },
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.teal.shade100, Colors.teal.shade200],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.search_rounded,
                size: 64,
                color: Colors.teal.shade600,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'SEO Bilgisi Bulunamadı',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Bu sayfada SEO meta bilgileri tespit edilemedi',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSeoCard(String key, String value, int index, bool isWide) {
    final seoType = _getSeoType(key);

    return Container(
      margin: EdgeInsets.only(bottom: isWide ? 20 : 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            seoType.backgroundColor.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(isWide ? 16 : 12),
        border: Border.all(color: seoType.borderColor, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: seoType.iconColor.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(isWide ? 24 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(isWide ? 16 : 12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        seoType.iconColor,
                        seoType.iconColor.withOpacity(0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: seoType.iconColor.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    seoType.icon, 
                    color: Colors.white, 
                    size: isWide ? 28 : 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _formatSeoKey(key),
                        style: TextStyle(
                          fontSize: isWide ? 18 : 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade800,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: seoType.badgeColor,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: seoType.badgeColor.withOpacity(0.3),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          seoType.category,
                          style: TextStyle(
                            fontSize: isWide ? 12 : 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => _copyToClipboard(value),
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.copy_rounded,
                      size: 20,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(isWide ? 20 : 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: seoType.iconColor.withOpacity(0.3),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: seoType.iconColor.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: SelectableText(
                value,
                style: TextStyle(
                  fontSize: isWide ? 15 : 14,
                  color: Colors.grey.shade800,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
  }

  SeoTypeInfo _getSeoType(String key) {
    final lowerKey = key.toLowerCase();

    if (lowerKey.contains('title')) {
      return SeoTypeInfo(
        icon: Icons.title_rounded,
        iconColor: Colors.blue.shade600,
        backgroundColor: Colors.blue.shade50,
        borderColor: Colors.blue.shade200,
        badgeColor: Colors.blue.shade600,
        category: 'TITLE',
      );
    } else if (lowerKey.contains('description')) {
      return SeoTypeInfo(
        icon: Icons.description_rounded,
        iconColor: Colors.green.shade600,
        backgroundColor: Colors.green.shade50,
        borderColor: Colors.green.shade200,
        badgeColor: Colors.green.shade600,
        category: 'DESC',
      );
    } else if (lowerKey.contains('keyword')) {
      return SeoTypeInfo(
        icon: Icons.tag_rounded,
        iconColor: Colors.purple.shade600,
        backgroundColor: Colors.purple.shade50,
        borderColor: Colors.purple.shade200,
        badgeColor: Colors.purple.shade600,
        category: 'KEYWORD',
      );
    } else if (lowerKey.contains('author')) {
      return SeoTypeInfo(
        icon: Icons.person_rounded,
        iconColor: Colors.orange.shade600,
        backgroundColor: Colors.orange.shade50,
        borderColor: Colors.orange.shade200,
        badgeColor: Colors.orange.shade600,
        category: 'AUTHOR',
      );
    } else {
      return SeoTypeInfo(
        icon: Icons.info_rounded,
        iconColor: Colors.grey.shade600,
        backgroundColor: Colors.grey.shade50,
        borderColor: Colors.grey.shade200,
        badgeColor: Colors.grey.shade600,
        category: 'META',
      );
    }
  }

  String _formatSeoKey(String key) {
    return key
        .split('_')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }
}

class SeoTypeInfo {
  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;
  final Color borderColor;
  final Color badgeColor;
  final String category;

  SeoTypeInfo({
    required this.icon,
    required this.iconColor,
    required this.backgroundColor,
    required this.borderColor,
    required this.badgeColor,
    required this.category,
  });
}
