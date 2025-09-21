import 'package:flutter/material.dart';

class LinkListComponent extends StatelessWidget {
  final List<Map<String, String>> links;
  final Function(Map<String, String>) onLinkTap;
  final String? currentDomain; // Sorgulanan domain bilgisi

  const LinkListComponent({
    super.key,
    required this.links,
    required this.onLinkTap,
    this.currentDomain,
  });

  @override
  Widget build(BuildContext context) {
    if (links.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: links.length,
      itemBuilder: (context, index) {
        final link = links[index];
        return _buildLinkCard(link, index);
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(Icons.link_off, size: 64, color: Colors.grey.shade400),
          ),
          const SizedBox(height: 16),
          Text(
            'Hiç Link Bulunamadı',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Bu sayfada herhangi bir link tespit edilemedi',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLinkCard(Map<String, String> link, int index) {
    final linkText = link['text'] ?? '';
    final linkUrl = link['href'] ?? '';
    final linkTitle = link['title'] ?? '';
    final linkRel = link['rel'] ?? ''; // nofollow kontrolü için

    // URL tipini belirle
    final isEmail = linkUrl.startsWith('mailto:');
    final isTel = linkUrl.startsWith('tel:');
    final isExternal = _isExternalLink(linkUrl);
    final isNoFollow = linkRel.toLowerCase().contains('nofollow');

    // Debug: Sadece title bilgisini yazdır
    if (linkTitle.isNotEmpty) {
      print('📋 Link has title: "$linkTitle"');
    } else {
      print('❌ Link has no title: $linkUrl');
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, Colors.purple.shade50.withOpacity(0.3)],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onLinkTap(link),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: _getLinkColors(isExternal, isEmail, isTel),
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Icon(
                      _getLinkIcon(isExternal, isEmail, isTel),
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (linkText.isNotEmpty)
                        Text(
                          linkText,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade800,
                          ),
                        ),
                      if (linkText.isNotEmpty) const SizedBox(height: 4),
                      Text(
                        linkUrl,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.blue.shade600,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                      if (linkTitle.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          linkTitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          // Link türü badge'i
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _getLinkBadgeColor(
                                isExternal,
                                isEmail,
                                isTel,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              _getLinkTypeText(isExternal, isEmail, isTel),
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          // Follow/NoFollow badge'i - Her zaman göster
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: isNoFollow
                                  ? Colors.red.shade600
                                  : Colors.green.shade600,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              isNoFollow ? 'NOFOLLOW' : 'FOLLOW',
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          // Title badge'i - Her zaman göster
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: linkTitle.isNotEmpty
                                  ? Colors.purple.shade600
                                  : Colors.grey.shade500,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              linkTitle.isNotEmpty ? 'TITLE' : 'NO TITLE',
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.open_in_new,
                    size: 18,
                    color: Colors.blue.shade600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Color> _getLinkColors(bool isExternal, bool isEmail, bool isTel) {
    if (isEmail) {
      return [Colors.orange.shade400, Colors.deepOrange.shade500];
    } else if (isTel) {
      return [Colors.green.shade400, Colors.teal.shade500];
    } else if (isExternal) {
      return [Colors.blue.shade400, Colors.indigo.shade500];
    } else {
      return [Colors.purple.shade400, Colors.deepPurple.shade500];
    }
  }

  IconData _getLinkIcon(bool isExternal, bool isEmail, bool isTel) {
    if (isEmail) {
      return Icons.email;
    } else if (isTel) {
      return Icons.phone;
    } else if (isExternal) {
      return Icons.language;
    } else {
      return Icons.link;
    }
  }

  Color _getLinkBadgeColor(bool isExternal, bool isEmail, bool isTel) {
    if (isEmail) {
      return Colors.orange.shade600;
    } else if (isTel) {
      return Colors.green.shade600;
    } else if (isExternal) {
      return Colors.blue.shade600;
    } else {
      return Colors.purple.shade600;
    }
  }

  String _getLinkTypeText(bool isExternal, bool isEmail, bool isTel) {
    if (isEmail) {
      return 'EMAIL';
    } else if (isTel) {
      return 'TELEFON';
    } else if (isExternal) {
      return 'DIŞ LİNK';
    } else {
      return 'İÇ LİNK';
    }
  }

  // Domain kontrolü için yardımcı metod
  bool _isExternalLink(String url) {
    if (url.isEmpty || currentDomain == null) return false;

    // mailto:, tel: gibi protokoller dış link sayılmaz
    if (url.startsWith('mailto:') || url.startsWith('tel:')) {
      return false;
    }

    // Relative linkler iç link
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      return false;
    }

    try {
      final uri = Uri.parse(url);
      final linkDomain = uri.host.toLowerCase().replaceAll('www.', '');

      // Current domain zaten temiz geliyormuş (sadece uri.host)
      final currentDomainClean = currentDomain!.toLowerCase().replaceAll(
        'www.',
        '',
      );

      // Debug için konsola yazdır
      print('🔗 Link URL: $url');
      print('🔗 Link Domain: $linkDomain');
      print('🔗 Current Domain: $currentDomainClean');
      print('🔗 Is External: ${linkDomain != currentDomainClean}');
      print('---');

      return linkDomain != currentDomainClean;
    } catch (e) {
      print('🚫 Domain parse error: $e');
      return false;
    }
  }
}
