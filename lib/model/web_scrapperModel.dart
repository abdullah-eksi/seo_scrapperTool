import 'dart:convert';
import 'dart:async';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'package:html/dom.dart';

/// Gelişmiş Web Scraper Sınıfı - Hem HTTP isteği atar hem de DOM ayrıştırır
class AeXpWebScraper {
  final String baseUrl;
  final Duration timeout;
  final int maxRetries;
  final Duration retryDelay;
  final bool enableUserAgentRotation;

  late http.Client _client;
  final Random _random = Random();

  /// Güncel User-Agent listesi
  static const List<String> userAgents = [
    'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
    'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:109.0) Gecko/20100101 Firefox/121.0',
    'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
    'Mozilla/5.0 (iPhone; CPU iPhone OS 17_2 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.2 Mobile/15E148 Safari/604.1',
    'Mozilla/5.0 (iPad; CPU OS 17_2 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.2 Mobile/15E148 Safari/604.1',
  ];

  AeXpWebScraper({
    required this.baseUrl,
    this.timeout = const Duration(seconds: 120),
    this.maxRetries = 3,
    this.retryDelay = const Duration(seconds: 2),
    this.enableUserAgentRotation = true,
  }) {
    _client = http.Client();
  }

  /// URL'yi normalize eder
  static String normalizeUrl(String url) {
    if (url.isEmpty) return url;

    url = url.trim();

    if (url.startsWith('http://') || url.startsWith('https://')) {
      return url;
    }

    return 'https://$url';
  }

  /// Rastgele User-Agent seçer
  String get _randomUserAgent {
    if (!enableUserAgentRotation) {
      return userAgents.first;
    }
    return userAgents[_random.nextInt(userAgents.length)];
  }

  /// Headers oluşturur
  Map<String, String> get _headers {
    return {
      'User-Agent': _randomUserAgent,
      'Accept':
          'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
      'Accept-Language': 'tr-TR,tr;q=0.9,en-US;q=0.8,en;q=0.7',
      'Connection': 'keep-alive',
      'Upgrade-Insecure-Requests': '1',
    };
  }

  /// URL oluşturur
  Uri _buildUri(String path, {Map<String, dynamic>? queryParams}) {
    return Uri.parse('$baseUrl$path').replace(
      queryParameters: queryParams?.map(
        (key, value) => MapEntry(key, value.toString()),
      ),
    );
  }

  /// HTTP GET isteği atarak HTML içeriğini çeker
  Future<String> _fetchHtml(
    String path, {
    Map<String, String>? customHeaders,
    Map<String, dynamic>? queryParams,
    int? retryCount,
  }) async {
    int currentRetry = retryCount ?? 0;

    try {
      final uri = _buildUri(path, queryParams: queryParams);
      final headers = {..._headers, ...?customHeaders};

      final response = await _client
          .get(uri, headers: headers)
          .timeout(timeout);

      if (response.statusCode == 200) {
        return _safeDecodeResponse(response);
      } else if (response.statusCode >= 500 && currentRetry < maxRetries) {
        await Future.delayed(retryDelay);
        return _fetchHtml(
          path,
          customHeaders: customHeaders,
          queryParams: queryParams,
          retryCount: currentRetry + 1,
        );
      } else {
        throw Exception(
          'HTTP ${response.statusCode} - ${response.reasonPhrase}',
        );
      }
    } on TimeoutException catch (e) {
      if (currentRetry < maxRetries) {
        await Future.delayed(retryDelay);
        return _fetchHtml(
          path,
          customHeaders: customHeaders,
          queryParams: queryParams,
          retryCount: currentRetry + 1,
        );
      }
      throw Exception('Request timeout: $e');
    } catch (e) {
      throw Exception('Failed to fetch HTML: $e');
    }
  }

  /// Güvenli response decoding
  String _safeDecodeResponse(http.Response response) {
    final bytes = response.bodyBytes;

    // Önce UTF-8 dene
    try {
      return utf8.decode(bytes);
    } catch (e) {
      // UTF-8 başarısız olursa Latin1 dene
      try {
        return latin1.decode(bytes);
      } catch (e) {
        // Son çare: String.fromCharCodes
        try {
          return String.fromCharCodes(bytes);
        } catch (e) {
          return response.body;
        }
      }
    }
  }

  /// HTML'i parse ederek Document döndürür
  Document _parseHtml(String html) {
    return parser.parse(html);
  }

  /// HTML çek ve parse et
  Future<Document> fetchAndParseHtml(
    String path, {
    Map<String, String>? customHeaders,
    Map<String, dynamic>? queryParams,
  }) async {
    final html = await _fetchHtml(
      path,
      customHeaders: customHeaders,
      queryParams: queryParams,
    );
    return _parseHtml(html);
  }

  // ========== DOM AYRIŞTIRMA METOTLARI ==========

  /// Belirli tag'lere göre elementleri bulur
  List<Element> selectTags(
    Document document,
    List<String> tags, {
    String? className,
    String? id,
    String? name,
    Map<String, String>? attributes,
    String? containingText,
    bool caseSensitive = true,
  }) {
    final selectedElements = <Element>[];

    for (final tag in tags) {
      final elements = document.getElementsByTagName(tag);

      for (final element in elements) {
        if (_matchesFilters(
          element,
          className: className,
          id: id,
          name: name,
          attributes: attributes,
          containingText: containingText,
          caseSensitive: caseSensitive,
        )) {
          selectedElements.add(element);
        }
      }
    }

    return selectedElements;
  }

  /// CSS selektörüne göre elementleri bulur
  List<Element> selectByCss(
    Document document,
    String selector, {
    String? containingText,
    bool caseSensitive = true,
  }) {
    final elements = document.querySelectorAll(selector);

    if (containingText == null) {
      return elements;
    }

    return elements.where((element) {
      final text = element.text.trim();
      if (caseSensitive) {
        return text.contains(containingText);
      } else {
        return text.toLowerCase().contains(containingText.toLowerCase());
      }
    }).toList();
  }

  /// Class adına göre elementleri bulur
  List<Element> selectByClass(
    Document document,
    String className, {
    String? tag,
    String? containingText,
    bool caseSensitive = true,
  }) {
    final elements = document.getElementsByClassName(className);

    var filteredElements = elements;

    if (tag != null) {
      filteredElements = filteredElements
          .where((element) => element.localName == tag)
          .toList();
    }

    if (containingText != null) {
      filteredElements = filteredElements.where((element) {
        final text = element.text.trim();
        if (caseSensitive) {
          return text.contains(containingText);
        } else {
          return text.toLowerCase().contains(containingText.toLowerCase());
        }
      }).toList();
    }

    return filteredElements;
  }

  /// ID'ye göre element bulur
  Element? selectById(Document document, String id) {
    return document.getElementById(id);
  }

  /// Metin içeriğine göre elementleri bulur
  List<Element> selectByText(
    Document document,
    String text, {
    String? tag,
    bool exactMatch = false,
    bool caseSensitive = false,
  }) {
    final allElements = document.querySelectorAll(tag ?? '*');

    return allElements.where((element) {
      final elementText = element.text.trim();

      if (exactMatch) {
        return caseSensitive
            ? elementText == text
            : elementText.toLowerCase() == text.toLowerCase();
      } else {
        return caseSensitive
            ? elementText.contains(text)
            : elementText.toLowerCase().contains(text.toLowerCase());
      }
    }).toList();
  }

  /// Element'ten metin içeriğini çıkarır
  String extractText(Element element, {bool trim = true}) {
    return trim ? element.text.trim() : element.text;
  }

  /// Element'ten attribute değerini çıkarır
  String? extractAttribute(Element element, String attribute) {
    return element.attributes[attribute];
  }

  /// Tüm linkleri çıkarır
  List<Map<String, String>> extractAllLinks(
    Document document, {
    String? baseUrl,
  }) {
    final links = <Map<String, String>>[];
    final aElements = document.querySelectorAll('a');

    for (final element in aElements) {
      final href = element.attributes['href'];
      final text = element.text.trim();

      if (href != null && href.isNotEmpty) {
        String fullUrl = href;

        if (baseUrl != null && !href.startsWith('http')) {
          if (href.startsWith('/')) {
            fullUrl = '$baseUrl$href';
          } else {
            fullUrl = '$baseUrl/$href';
          }
        }

        links.add({
          'href': fullUrl,
          'text': text,
          'title': element.attributes['title'] ?? '',
          'rel': element.attributes['rel'] ?? '', // nofollow kontrolü için
        });
      }
    }

    return links;
  }

  /// Tüm resimleri çıkarır (lazy loading, data-src, srcset desteği ile)
  List<Map<String, String>> extractAllImages(
    Document document, {
    String? baseUrl,
  }) {
    final images = <Map<String, String>>[];
    final seenUrls = <String>{};

    // 1. Normal img tag'leri
    final imgElements = document.querySelectorAll('img');
    for (final element in imgElements) {
      _processImageElement(element, baseUrl, images, seenUrls);
    }

    // 2. Picture ve source elementleri
    final pictureElements = document.querySelectorAll('picture source, source');
    for (final element in pictureElements) {
      _processSourceElement(element, baseUrl, images, seenUrls);
    }

    // 3. Lazy loading img'ler (data-src, data-original, etc.)
    final lazyImages = document.querySelectorAll(
      '[data-src], [data-original], [data-lazy], [data-image], [data-url]',
    );
    for (final element in lazyImages) {
      _processImageElement(element, baseUrl, images, seenUrls);
    }

    // 3. Background image'ları
    final elementsWithBg = document.querySelectorAll(
      '[style*="background-image"]',
    );
    for (final element in elementsWithBg) {
      final style = element.attributes['style'] ?? '';
      final bgMatch = RegExp(
        r'background-image:\s*url\(([^)]*)\)',
      ).firstMatch(style);

      if (bgMatch != null) {
        String bgUrl = bgMatch.group(1) ?? '';
        bgUrl = bgUrl.replaceAll('"', '').replaceAll("'", '');

        if (bgUrl.isNotEmpty && !seenUrls.contains(bgUrl)) {
          final fullUrl = _makeAbsoluteUrl(bgUrl, baseUrl);
          seenUrls.add(fullUrl);

          images.add({
            'src': fullUrl,
            'alt': 'Background Image',
            'title': 'Background Image',
            'width': '',
            'height': '',
            'loading': '',
            'srcset': '',
            'class': element.attributes['class'] ?? '',
            'id': element.attributes['id'] ?? '',
            'type': 'background',
          });
        }
      }
    }

    // 4. Tüm linklerde resim uzantılarını ara
    final allLinks = document.querySelectorAll('a[href]');
    for (final link in allLinks) {
      final href = link.attributes['href'] ?? '';
      if (_isImageUrl(href) && !seenUrls.contains(href)) {
        final fullUrl = _makeAbsoluteUrl(href, baseUrl);
        seenUrls.add(fullUrl);

        images.add({
          'src': fullUrl,
          'alt': link.text.trim().isNotEmpty
              ? link.text.trim()
              : 'Linked Image',
          'title': link.attributes['title'] ?? '',
          'width': '',
          'height': '',
          'loading': '',
          'srcset': '',
          'class': link.attributes['class'] ?? '',
          'id': link.attributes['id'] ?? '',
          'type': 'linked',
        });
      }
    }

    return images;
  }

  /// Resim elementi işle
  void _processImageElement(
    Element element,
    String? baseUrl,
    List<Map<String, String>> images,
    Set<String> seenUrls,
  ) {
    // Farklı src türlerini kontrol et (daha kapsamlı lazy loading desteği)
    String? src = element.attributes['src'];
    String? dataSrc = element.attributes['data-src'];
    String? dataSrcset = element.attributes['data-srcset'];
    String? srcset = element.attributes['srcset'];
    String? dataOriginal = element.attributes['data-original'];
    String? dataLazy = element.attributes['data-lazy'];
    String? dataActual = element.attributes['data-actual'];
    String? dataImage = element.attributes['data-image'];
    String? dataUrl = element.attributes['data-url'];
    String? dataHiResSrc = element.attributes['data-hi-res-src'];
    String? dataLazySrc = element.attributes['data-lazy-src'];
    String? dataFullSrc = element.attributes['data-full-src'];
    String? dataImageSrc = element.attributes['data-image-src'];

    // En uygun src'yi seç (öncelik sırasına göre)
    String? finalSrc =
        src ??
        dataSrc ??
        dataOriginal ??
        dataImage ??
        dataUrl ??
        dataActual ??
        dataLazy ??
        dataHiResSrc ??
        dataLazySrc ??
        dataFullSrc ??
        dataImageSrc;

    if (finalSrc != null &&
        finalSrc.isNotEmpty &&
        !seenUrls.contains(finalSrc)) {
      final fullUrl = _makeAbsoluteUrl(finalSrc, baseUrl);
      seenUrls.add(fullUrl);

      images.add({
        'src': fullUrl,
        'alt': element.attributes['alt'] ?? '',
        'title': element.attributes['title'] ?? '',
        'width': element.attributes['width'] ?? '',
        'height': element.attributes['height'] ?? '',
        'loading': element.attributes['loading'] ?? '',
        'srcset': srcset ?? dataSrcset ?? '',
        'class': element.attributes['class'] ?? '',
        'id': element.attributes['id'] ?? '',
        'type': 'img',
      });
    }

    // Srcset'ten ek resim URL'lerini çıkar
    _processSrcsetUrls(
      srcset ?? dataSrcset ?? '',
      baseUrl,
      images,
      seenUrls,
      element,
    );
  }

  /// Srcset string'ini parse edip ek resim URL'leri çıkarır
  void _processSrcsetUrls(
    String srcsetValue,
    String? baseUrl,
    List<Map<String, String>> images,
    Set<String> seenUrls,
    Element element,
  ) {
    if (srcsetValue.isEmpty) return;

    // Srcset formatı: "url1 1x, url2 2x, url3 480w, url4 800w"
    final srcsetEntries = srcsetValue.split(',');

    for (final entry in srcsetEntries) {
      final trimmed = entry.trim();
      if (trimmed.isEmpty) continue;

      // URL'yi çıkar (boşluktan önceki kısım)
      final parts = trimmed.split(' ');
      if (parts.isNotEmpty) {
        final url = parts.first.trim();
        if (url.isNotEmpty && !seenUrls.contains(url)) {
          final fullUrl = _makeAbsoluteUrl(url, baseUrl);
          seenUrls.add(fullUrl);

          final descriptor = parts.length > 1 ? parts[1] : '';

          images.add({
            'src': fullUrl,
            'alt': element.attributes['alt'] ?? '',
            'title': element.attributes['title'] ?? '',
            'width': element.attributes['width'] ?? '',
            'height': element.attributes['height'] ?? '',
            'loading': element.attributes['loading'] ?? '',
            'srcset': srcsetValue,
            'descriptor': descriptor, // 1x, 2x, 480w gibi
            'class': element.attributes['class'] ?? '',
            'id': element.attributes['id'] ?? '',
            'type': 'img-srcset',
          });
        }
      }
    }
  }

  /// Source elementi işle (picture > source)
  void _processSourceElement(
    Element element,
    String? baseUrl,
    List<Map<String, String>> images,
    Set<String> seenUrls,
  ) {
    String? src = element.attributes['src'];
    String? srcset = element.attributes['srcset'];
    String? dataSrc = element.attributes['data-src'];
    String? dataSrcset = element.attributes['data-srcset'];

    // Source'tan URL çıkar
    String? finalSrc = src ?? dataSrc;
    if (finalSrc != null &&
        finalSrc.isNotEmpty &&
        !seenUrls.contains(finalSrc)) {
      final fullUrl = _makeAbsoluteUrl(finalSrc, baseUrl);
      seenUrls.add(fullUrl);

      images.add({
        'src': fullUrl,
        'alt': 'Source Image',
        'title': element.attributes['title'] ?? '',
        'width': element.attributes['width'] ?? '',
        'height': element.attributes['height'] ?? '',
        'loading': '',
        'srcset': srcset ?? dataSrcset ?? '',
        'media': element.attributes['media'] ?? '', // Media query
        'type': 'source',
        'class': element.attributes['class'] ?? '',
        'id': element.attributes['id'] ?? '',
      });
    }

    // Srcset'i de işle
    _processSrcsetUrls(
      srcset ?? dataSrcset ?? '',
      baseUrl,
      images,
      seenUrls,
      element,
    );
  }

  /// URL'nin resim olup olmadığını kontrol et
  bool _isImageUrl(String url) {
    if (url.isEmpty) return false;

    final lowerUrl = url.toLowerCase();
    final imageExtensions = [
      '.jpg',
      '.jpeg',
      '.png',
      '.gif',
      '.webp',
      '.svg',
      '.bmp',
      '.ico',
      '.tiff',
      '.tif',
      '.avif',
      '.heic',
      '.heif',
    ];

    return imageExtensions.any((ext) => lowerUrl.contains(ext));
  }

  /// Relative URL'yi absolute yapar
  String _makeAbsoluteUrl(String url, String? baseUrl) {
    if (url.isEmpty || baseUrl == null) return url;

    if (url.startsWith('http://') || url.startsWith('https://')) {
      return url;
    }

    if (url.startsWith('//')) {
      return 'https:$url';
    }

    if (url.startsWith('/')) {
      return '$baseUrl$url';
    }

    return '$baseUrl/$url';
  }

  /// Meta tag'lerini çıkarır
  Map<String, String> extractMetaTags(Document document) {
    final metaTags = <String, String>{};
    final metaElements = document.querySelectorAll('meta');

    for (final meta in metaElements) {
      final name = meta.attributes['name'] ?? meta.attributes['property'] ?? '';
      final content = meta.attributes['content'] ?? '';

      if (name.isNotEmpty && content.isNotEmpty) {
        metaTags[name] = content;
      }
    }

    return metaTags;
  }

  /// Tüm metinleri çıkarır (script ve style tag'leri hariç)
  String extractAllText(Document document) {
    document.querySelectorAll('script, style, noscript').forEach((element) {
      element.remove();
    });

    return document.body?.text.trim() ?? '';
  }

  /// SEO bilgilerini çıkarır
  Map<String, String> extractSeoInfo(Document document) {
    final metaTags = extractMetaTags(document);
    final seoInfo = <String, String>{};

    // Başlık
    final titleElement = document.querySelector('title');
    if (titleElement != null) {
      seoInfo['title'] = titleElement.text;
    }

    // Meta açıklama
    if (metaTags.containsKey('description')) {
      seoInfo['description'] = metaTags['description']!;
    }

    // Anahtar kelimeler
    if (metaTags.containsKey('keywords')) {
      seoInfo['keywords'] = metaTags['keywords']!;
    }

    // Open Graph
    final ogTags = metaTags.entries.where(
      (entry) => entry.key.startsWith('og:'),
    );
    for (final tag in ogTags) {
      seoInfo[tag.key] = tag.value;
    }

    return seoInfo;
  }

  /// Tüm paragrafları (p tag'lerini) çıkarır
  List<Map<String, String>> extractAllParagraphs(Document document) {
    final paragraphs = <Map<String, String>>[];
    final pElements = document.querySelectorAll('p');

    for (final element in pElements) {
      final text = element.text.trim();
      if (text.isNotEmpty) {
        paragraphs.add({
          'text': text,
          'html': element.innerHtml,
          'class': element.attributes['class'] ?? '',
          'id': element.attributes['id'] ?? '',
        });
      }
    }

    return paragraphs;
  }

  // Private helper methods
  bool _matchesFilters(
    Element element, {
    String? className,
    String? id,
    String? name,
    Map<String, String>? attributes,
    String? containingText,
    bool caseSensitive = true,
  }) {
    if (className != null && !element.classes.contains(className)) {
      return false;
    }

    if (id != null && element.id != id) {
      return false;
    }

    if (name != null && element.attributes['name'] != name) {
      return false;
    }

    if (attributes != null) {
      for (final attr in attributes.entries) {
        if (element.attributes[attr.key] != attr.value) {
          return false;
        }
      }
    }

    if (containingText != null) {
      final text = element.text.trim();
      if (caseSensitive) {
        if (!text.contains(containingText)) {
          return false;
        }
      } else {
        if (!text.toLowerCase().contains(containingText.toLowerCase())) {
          return false;
        }
      }
    }

    return true;
  }

  /// Dispose method
  void dispose() {
    _client.close();
  }
}
