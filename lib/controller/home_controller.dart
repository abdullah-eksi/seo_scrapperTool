import 'package:flutter/material.dart';
import 'package:html/dom.dart' as html;
import '../model/web_scrapperModel.dart';

class HomeController extends ChangeNotifier {
  AeXpWebScraper? _scraper;
  html.Document? _document;

  bool _isLoading = false;
  String _errorMessage = '';
  String _pageTitle = '';
  String _currentDomain = '';
  List<String> _texts = [];
  List<Map<String, String>> _links = [];
  List<Map<String, String>> _images = [];
  Map<String, String> _seoInfo = {};
  Map<String, dynamic> _metaTags = {};
  List<Map<String, String>> _headings = [];
  Map<String, dynamic> _schemaData = {};
  List<Map<String, String>> _formElements = [];
  List<Map<String, String>> _paragraphs = [];

  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  String get pageTitle => _pageTitle;
  String get currentDomain => _currentDomain;
  List<String> get texts => _texts;
  List<Map<String, String>> get links => _links;
  List<Map<String, String>> get images => _images;
  Map<String, String> get seoInfo => _seoInfo;
  Map<String, dynamic> get metaTags => _metaTags;
  List<Map<String, String>> get headings => _headings;
  Map<String, dynamic> get schemaData => _schemaData;
  List<Map<String, String>> get formElements => _formElements;
  List<Map<String, String>> get paragraphs => _paragraphs;

  int get realFormCount {
    if (_formElements.isEmpty) return 0;

    final hasInfoMessages = _formElements.any(
      (form) =>
          form['action']?.contains('bulunamadı') == true ||
          form['action']?.contains('analiz edilemedi') == true,
    );

    return hasInfoMessages ? 0 : _formElements.length;
  }

  Future<void> fetchData(String url) async {
    _isLoading = true;
    _errorMessage = '';
    _texts.clear();
    _links.clear();
    _images.clear();
    _seoInfo.clear();
    _metaTags.clear();
    _headings.clear();
    _schemaData.clear();
    _formElements.clear();
    _paragraphs.clear();
    notifyListeners();

    try {
      final normalizedUrl = AeXpWebScraper.normalizeUrl(url);
      print('🔗 Orijinal URL: $url');
      print('🔗 Normalize edilmiş URL: $normalizedUrl');

      final uri = Uri.parse(normalizedUrl);
      final baseUrl = '${uri.scheme}://${uri.host}';
      _currentDomain = uri.host;
      final path = uri.path.isEmpty
          ? '/'
          : '${uri.path}${uri.query.isNotEmpty ? '?${uri.query}' : ''}';

      print('🌐 Base URL: $baseUrl');
      print('🌐 Current Domain: $_currentDomain');
      print('📄 Path: $path');

      _scraper = AeXpWebScraper(baseUrl: baseUrl);

      _document = await _scraper!.fetchAndParseHtml(path);

      _extractPageData(baseUrl);
      _extractSeoData();
      _extractHeadingsData();
      _extractSchemaData();
      _extractContentData();
      _extractLinksAndImages(baseUrl);
      _extractFormData();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = _getErrorMessage(e.toString());
      print('🚫 Hata: $e');
      notifyListeners();
    } finally {
      _scraper?.dispose();
      _scraper = null;
    }
  }

  String _getErrorMessage(String error) {
    if (error.contains('SocketException') || error.contains('Network')) {
      return 'İnternet bağlantısı sorunu yaşanıyor. Lütfen bağlantınızı kontrol edin.';
    }
    if (error.contains('TimeoutException') || error.contains('timeout')) {
      return 'İstek zaman aşımına uğradı. Lütfen daha sonra tekrar deneyin.';
    }
    if (error.contains('FormatException') || error.contains('Invalid')) {
      return 'Geçersiz URL formatı. Lütfen doğru bir web sitesi adresi girin.';
    }
    if (error.contains('ClientException') || error.contains('404')) {
      return 'Web sitesine erişilemiyor. URL\'yi kontrol edin veya site geçici olarak erişilemez olabilir.';
    }
    if (error.contains('500') || error.contains('503')) {
      return 'Web sitesinde teknik bir sorun var. Lütfen daha sonra tekrar deneyin.';
    }
    if (error.contains('403') || error.contains('Forbidden')) {
      return 'Bu web sitesine erişim engellendi. Site, analiz araçlarına izin vermiyor olabilir.';
    }
    if (error.contains('TlsException') || error.contains('CERTIFICATE')) {
      return 'Güvenlik sertifikası sorunu. Bu site güvenli olmayabilir.';
    }

    return 'Bir sorun oluştu. Lütfen URL\'yi kontrol edin ve tekrar deneyin.';
  }

  void _extractPageData(String baseUrl) {
    if (_document == null) return;

    try {
      final titleElement = _document!.querySelector('title');
      if (titleElement != null) {
        _pageTitle = titleElement.text.trim();
      } else {
        _pageTitle = 'Başlık bulunamadı';
      }
    } catch (e) {
      _pageTitle = 'Başlık analiz edilemedi';
    }
  }

  void _extractSeoData() {
    if (_document == null || _scraper == null) return;

    try {
      // Meta tag'leri çıkar
      final metaTags = _scraper!.extractMetaTags(_document!);

      // SEO bilgilerini hazırla
      final seoInfo = _scraper!.extractSeoInfo(_document!);

      _metaTags = Map<String, dynamic>.from(metaTags);
      _seoInfo = Map<String, String>.from(seoInfo);

      // Eksik olanları doldur
      if (!_seoInfo.containsKey('title')) {
        _seoInfo['title'] = _pageTitle;
      }
    } catch (e) {
      _seoInfo = {'Bilgi': 'SEO verileri analiz edilemedi'};
      _metaTags = {};
    }
  }

  /// Heading verilerini çıkarır (h1, h2, h3, h4, h5, h6)
  void _extractHeadingsData() {
    if (_document == null || _scraper == null) return;

    try {
      _headings.clear();
      final headingTags = ['h1', 'h2', 'h3', 'h4', 'h5', 'h6'];

      for (final tag in headingTags) {
        final elements = _scraper!.selectTags(_document!, [tag]);
        for (final element in elements) {
          final text = _scraper!.extractText(element).trim();
          if (text.isNotEmpty && text.length > 2) {
            _headings.add({
              'level': tag,
              'text': text,
              'id': _scraper!.extractAttribute(element, 'id') ?? '',
              'class': _scraper!.extractAttribute(element, 'class') ?? '',
            });
          }
        }
      }

      if (_headings.isEmpty) {
        _headings.add({
          'level': 'info',
          'text': 'Bu sayfada başlık (heading) bulunamadı.',
          'id': '',
          'class': '',
        });
      }
    } catch (e) {
      _headings = [
        {
          'level': 'error',
          'text': 'Başlıklar analiz edilemedi.',
          'id': '',
          'class': '',
        },
      ];
    }
  }

  /// Schema.org verilerini çıkarır (JSON-LD script tag'lerinden)
  void _extractSchemaData() {
    if (_document == null) return;

    try {
      _schemaData.clear();
      final schemaResults = <String, dynamic>{};

      // JSON-LD script tag'lerini bul
      final scriptElements = _document!.querySelectorAll(
        'script[type="application/ld+json"]',
      );

      print('📋 Found ${scriptElements.length} JSON-LD scripts');

      for (var i = 0; i < scriptElements.length; i++) {
        try {
          final scriptContent = scriptElements[i].text.trim();
          if (scriptContent.isNotEmpty) {
            print(
              '📋 Processing JSON-LD $i: ${scriptContent.substring(0, scriptContent.length > 100 ? 100 : scriptContent.length)}...',
            );

            // JSON içeriğini düzenle ve kaydet
            schemaResults['json_ld_$i'] = {
              'type': 'JSON-LD',
              'content': scriptContent,
              'length': scriptContent.length,
            };
          }
        } catch (e) {
          print('📋 JSON-LD $i parse error: $e');
          schemaResults['json_ld_error_$i'] = {
            'type': 'JSON-LD Error',
            'content': 'Parse hatası: $e',
            'length': 0,
          };
        }
      }

      // Microdata'ları da kontrol et
      final itemScopeElements = _document!.querySelectorAll('[itemscope]');
      print('📋 Found ${itemScopeElements.length} microdata elements');

      for (var i = 0; i < itemScopeElements.length; i++) {
        final element = itemScopeElements[i];
        final itemType = element.attributes['itemtype'] ?? '';
        final itemProp = element.attributes['itemprop'] ?? '';
        final textContent = element.text.trim();

        if (itemType.isNotEmpty || itemProp.isNotEmpty) {
          schemaResults['microdata_$i'] = {
            'type': 'Microdata',
            'itemtype': itemType,
            'itemprop': itemProp,
            'content': textContent.length > 200
                ? '${textContent.substring(0, 200)}...'
                : textContent,
            'length': textContent.length,
          };
        }
      }

      // Open Graph meta tag'lerini kontrol et
      final ogElements = _document!.querySelectorAll('meta[property^="og:"]');
      if (ogElements.isNotEmpty) {
        final ogData = <String, String>{};
        for (final meta in ogElements) {
          final property = meta.attributes['property'] ?? '';
          final content = meta.attributes['content'] ?? '';
          if (property.isNotEmpty && content.isNotEmpty) {
            ogData[property] = content;
          }
        }

        if (ogData.isNotEmpty) {
          schemaResults['open_graph'] = {
            'type': 'Open Graph',
            'content': ogData.toString(),
            'count': ogData.length,
          };
        }
      }

      // Twitter Card meta tag'lerini kontrol et
      final twitterElements = _document!.querySelectorAll(
        'meta[name^="twitter:"]',
      );
      if (twitterElements.isNotEmpty) {
        final twitterData = <String, String>{};
        for (final meta in twitterElements) {
          final name = meta.attributes['name'] ?? '';
          final content = meta.attributes['content'] ?? '';
          if (name.isNotEmpty && content.isNotEmpty) {
            twitterData[name] = content;
          }
        }

        if (twitterData.isNotEmpty) {
          schemaResults['twitter_card'] = {
            'type': 'Twitter Card',
            'content': twitterData.toString(),
            'count': twitterData.length,
          };
        }
      }

      _schemaData = schemaResults;

      if (_schemaData.isEmpty) {
        _schemaData['info'] = {
          'type': 'Bilgi',
          'content':
              'Bu sayfada Schema.org, microdata, Open Graph veya Twitter Card bulunamadı.',
          'length': 0,
        };
      }

      print('📋 Total schema data items: ${_schemaData.length}');
    } catch (e) {
      print('📋 Schema extraction error: $e');
      _schemaData = {
        'error': {
          'type': 'Hata',
          'content': 'Schema verileri analiz edilemedi: $e',
          'length': 0,
        },
      };
    }
  }

  void _extractContentData() {
    if (_document == null || _scraper == null) return;

    try {
      // Gereksiz elementleri kaldır (script, style, noscript, etc.)
      final elementsToRemove = _document!.querySelectorAll(
        'script, style, noscript, nav, header, footer, aside, .ad, .advertisement, .social-share, .cookie-banner',
      );
      for (final element in elementsToRemove) {
        element.remove();
      }

      // Ana içerik bölümlerini bul
      final contentSelectors = [
        'main',
        'article',
        '[role="main"]',
        '.content',
        '.post-content',
        '.entry-content',
        '.article-content',
        '#content',
        '.main-content',
      ];

      List<html.Element> contentElements = [];

      for (final selector in contentSelectors) {
        final elements = _document!.querySelectorAll(selector);
        if (elements.isNotEmpty) {
          contentElements.addAll(elements);
          break; // İlk bulunan content alanını kullan
        }
      }

      // Eğer belirli content alanı bulunamazsa, body içindeki p tag'lerini al
      if (contentElements.isEmpty) {
        contentElements = _document!.querySelectorAll('body p, body div');
      }

      // Metinleri çıkar ve filtrele
      List<String> extractedTexts = [];

      for (final element in contentElements) {
        final text = element.text.trim();

        // Filtreleme kuralları
        if (text.isNotEmpty &&
            text.length > 15 &&
            text.length < 2000 && // Çok uzun metinleri engelle
            !text.contains('cookie') &&
            !text.contains('advertisement') &&
            !text.contains('©') &&
            !_isNavigationText(text)) {
          // Paragrafları satırlara böl
          final lines = text.split('\n');
          for (final line in lines) {
            final cleanLine = line.trim();
            if (cleanLine.length > 20 && !extractedTexts.contains(cleanLine)) {
              extractedTexts.add(cleanLine);
            }
          }
        }
      }

      _texts = extractedTexts.take(50).toList(); // Maximum 50 paragraf

      if (_texts.isEmpty) {
        _texts = ['Bu sayfada analiz edilebilir metin içeriği bulunamadı.'];
      }
    } catch (e) {
      _texts = [
        'İçerik analiz edilemedi. Sayfa yapısı desteklenmiyor olabilir.',
      ];
    }
  }

  /// Navigasyon metni olup olmadığını kontrol eder
  bool _isNavigationText(String text) {
    final navKeywords = [
      'home',
      'about',
      'contact',
      'menu',
      'login',
      'register',
      'search',
      'cart',
      'account',
      'profile',
      'settings',
      'next',
      'previous',
      'page',
      'more',
      'load more',
    ];

    final lowerText = text.toLowerCase();
    return navKeywords.any((keyword) => lowerText.contains(keyword)) &&
        text.length < 50;
  }

  /// Form verilerini çıkarır
  void _extractFormData() {
    if (_document == null) return;

    try {
      _formElements.clear();
      final forms = _document!.querySelectorAll('form');

      for (var i = 0; i < forms.length; i++) {
        final form = forms[i];
        final action = form.attributes['action'] ?? '';
        final method = form.attributes['method'] ?? 'GET';
        final name = form.attributes['name'] ?? 'form_$i';

        // Form içindeki input elementlerini say
        final inputs = form.querySelectorAll('input, textarea, select, button');
        final inputTypes = <String>[];

        for (final input in inputs) {
          final type = input.attributes['type'] ?? input.localName ?? '';
          final name = input.attributes['name'] ?? '';
          final placeholder = input.attributes['placeholder'] ?? '';

          if (type.isNotEmpty) {
            inputTypes.add(
              '$type${name.isNotEmpty ? " ($name)" : ""}${placeholder.isNotEmpty ? " - $placeholder" : ""}',
            );
          }
        }

        _formElements.add({
          'name': name,
          'action': action.isNotEmpty ? action : 'Belirtilmemiş',
          'method': method.toUpperCase(),
          'inputs': inputTypes.join(', '),
          'input_count': inputs.length.toString(),
        });
      }

      if (_formElements.isEmpty) {
        _formElements.add({
          'name': 'Bilgi',
          'action': 'Bu sayfada form bulunamadı.',
          'method': '',
          'inputs': '',
          'input_count': '0',
        });
      }
    } catch (e) {
      _formElements = [
        {
          'name': 'Hata',
          'action': 'Form verileri analiz edilemedi.',
          'method': '',
          'inputs': '',
          'input_count': '0',
        },
      ];
    }
  }

  void _extractLinksAndImages(String baseUrl) {
    if (_document == null || _scraper == null) return;

    try {
      // Linkleri çıkar
      _links = _scraper!.extractAllLinks(_document!, baseUrl: baseUrl);

      // Görselleri çıkar
      final allImages = _scraper!.extractAllImages(
        _document!,
        baseUrl: baseUrl,
      );

      // Gelişmiş filtre ile duplikasyonları temizle
      final uniqueImages = <String, Map<String, String>>{};
      final seenUrls = <String>{};

      for (final image in allImages) {
        final src = image['src'] ?? '';

        // Boş, data: URL'leri ve çok küçük base64'leri filtrele
        if (src.isEmpty ||
            src == 'data:' ||
            src.startsWith('data:image/svg') ||
            (src.startsWith('data:') && src.length < 100)) {
          continue;
        }

        // Çok yaygın placeholder/icon resimleri filtrele (daha az agresif)
        final lowerSrc = src.toLowerCase();
        if (lowerSrc.contains('placeholder.') ||
            lowerSrc.contains('loading.') ||
            lowerSrc.contains('spinner.') ||
            lowerSrc.contains('1x1.') ||
            lowerSrc.contains('pixel.') ||
            (lowerSrc.endsWith('.gif') && lowerSrc.contains('1x1'))) {
          continue;
        }

        // Sadece tamamen aynı URL'leri filtrele (dosya adı bazında değil)
        final cleanUrl = src.split('#').first; // Fragment'ı temizle

        if (seenUrls.contains(cleanUrl)) {
          continue;
        }

        uniqueImages[src] = image;
        seenUrls.add(cleanUrl);
      }

      _images = uniqueImages.values.toList();

      // Debug: konsola yazdır
      print('🖼️ Total images found: ${allImages.length}');
      print('🖼️ Unique images after filtering: ${_images.length}');

      // Resim türlerini say
      final imageTypes = <String, int>{};
      for (final image in _images) {
        final type = image['type'] ?? 'unknown';
        imageTypes[type] = (imageTypes[type] ?? 0) + 1;
      }

      print('🖼️ Image types breakdown:');
      imageTypes.forEach((type, count) {
        print('   - $type: $count');
      });

      print('🖼️ Showing first 10 image URLs:');
      for (var i = 0; i < _images.length && i < 10; i++) {
        final type = _images[i]['type'] ?? 'unknown';
        print('🖼️ Image ${i + 1} [$type]: ${_images[i]['src']}');
      }
      if (_images.length > 10) {
        print('🖼️ ... and ${_images.length - 10} more images');
      }

      // Paragrafları çıkar
      _paragraphs = _scraper!.extractAllParagraphs(_document!);

      // Eğer link bulunamazsa bilgilendirici mesaj
      if (_links.isEmpty) {
        _links = [
          {'href': '', 'text': 'Bu sayfada bağlantı bulunamadı.', 'title': ''},
        ];
      }

      // Eğer görsel bulunamazsa bilgilendirici mesaj
      if (_images.isEmpty) {
        _images = [
          {'src': '', 'alt': 'Bu sayfada görsel bulunamadı.', 'title': ''},
        ];
      }
    } catch (e) {
      print('🚫 Image extraction error: $e');
      _links = [
        {'href': '', 'text': 'Bağlantılar analiz edilemedi.', 'title': ''},
      ];
      _images = [
        {'src': '', 'alt': 'Görseller analiz edilemedi.', 'title': ''},
      ];
    }
  }

  // Gelişmiş DOM analizi için ek metodlar
  List<html.Element> analyzeDomStructure({
    List<String> tags = const ['div', 'section', 'article'],
  }) {
    if (_document == null || _scraper == null) return [];
    return _scraper!.selectTags(_document!, tags);
  }

  Map<String, int> getTagStatistics() {
    if (_document == null || _scraper == null) return {};

    final tags = [
      'div',
      'p',
      'a',
      'img',
      'h1',
      'h2',
      'h3',
      'h4',
      'h5',
      'h6',
      'span',
    ];
    final statistics = <String, int>{};

    for (final tag in tags) {
      final elements = _scraper!.selectTags(_document!, [tag]);
      statistics[tag] = elements.length;
    }

    return statistics;
  }

  List<Map<String, String>> getFormElements() {
    // Bu fonksiyon artık _extractFormData() tarafından yapılıyor
    // Direkt formElements getter'ını kullan
    return _formElements;
  }

  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }

  void clearData() {
    _texts.clear();
    _links.clear();
    _images.clear();
    _seoInfo.clear();
    _metaTags.clear();
    _headings.clear();
    _schemaData.clear();
    _formElements.clear();
    _pageTitle = '';
    _errorMessage = '';
    notifyListeners();
  }
}
