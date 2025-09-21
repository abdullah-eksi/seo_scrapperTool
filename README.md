# 🔍 SEO Analiz Aracı - Flutter Web Scraper

![Flutter](https://img.shields.io/badge/Flutter-3.9.2-02569B?style=for-the-badge&logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.9.2-0175C2?style=for-the-badge&logo=dart)
![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)

**SEO Analiz Aracı**, web sitelerinin SEO performansını analiz etmek için geliştirilmiş kapsamlı bir Flutter uygulamasıdır. Bu araç, web sitelerinin teknik SEO durumunu, içerik yapısını ve genel optimizasyonunu değerlendirmek için gelişmiş web scraping teknolojileri kullanır.

## 🚀 Özellikler

### 📊 Kapsamlı SEO Analizi
- **Meta Tag Analizi**: Title, description, keywords ve diğer meta etiketlerin detaylı incelenmesi
- **Başlık Yapısı Analizi**: H1-H6 başlık etiketlerinin hiyerarşik analizi
- **Schema Markup Kontrolü**: Yapılandırılmış veri analizi ve JSON-LD desteği
- **Link Profili**: İç ve dış bağlantıların detaylı analizi
- **Görsel Optimizasyonu**: Alt text, dosya boyutu ve format analizi

### 🛠️ Teknik Özellikler
- **Gelişmiş Web Scraping**: HTTP istekleri ve DOM ayrıştırma
- **User-Agent Rotasyonu**: Bot algılamasını önlemek için dinamik user-agent değişimi
- **Retry Mekanizması**: Başarısız istekler için otomatik yeniden deneme
- **Error Handling**: Kapsamlı hata yönetimi ve kullanıcı dostu mesajlar

### 🎨 Kullanıcı Arayüzü
- **Modern Material Design**: Material 3 tasarım prensiplerine uygun arayüz
- **Animasyonlu Splash Screen**: Etkileyici açılış animasyonları
- **Tab Yapısı**: Organize edilmiş veri görüntüleme

## 🛠️ Kurulum

### Gereksinimler
- **Flutter SDK**: 3.9.2 veya üzeri
- **Dart SDK**: 3.9.2 veya üzeri
- **Android Studio / VS Code**: IDE desteği için
- **Git**: Versiyon kontrolü için

### Adım Adım Kurulum

1. **Projeyi klonlayın:**
```bash
git clone https://github.com/kullanici/flutter_scrapper.git
cd flutter_scrapper
```

2. **Bağımlılıkları yükleyin:**
```bash
flutter pub get
```

3. **Flutter kurulumunu kontrol edin:**
```bash
flutter doctor
```

4. **Uygulamayı çalıştırın:**
```bash
flutter run
```


## 📱 Kullanım

### 1. Temel Analiz
1. Uygulamayı başlatın
2. Ana ekranda URL giriş alanına analiz etmek istediğiniz web sitesinin adresini girin
3. "Analiz Et" butonuna tıklayın
4. Analiz tamamlandığında sonuçları farklı sekmeler halinde görüntüleyin

### 2. Detaylı İnceleme

#### 📈 Genel Bilgiler Sekmesi
- Sayfa başlığı ve açıklaması
- Meta tag bilgileri
- Sayfa istatistikleri (link, görsel, form sayıları)

#### 🔗 Linkler Sekmesi
- İç ve dış bağlantıların listesi
- Anchor text analizi
- Broken link kontrolü

#### 🖼️ Görseller Sekmesi
- Sayfa içindeki tüm görseller
- Alt text kontrolü
- Görsel boyut ve format bilgileri

#### 📝 İçerik Sekmesi
- Paragraf analizi
- Metin yoğunluğu
- İçerik yapısı

#### 🏷️ Schema Sekmesi
- JSON-LD yapılandırılmış veriler
- Mikrodata analizi
- Rich snippet uyumluluğu

## 📁 Proje Yapısı

```
flutter_scrapper/

├── 📚 lib/                 # Ana uygulama kodu
│   ├── 🎮 controller/       # Business logic
│   │   └── home_controller.dart
│   ├── 📦 model/           # Veri modelleri
│   │   └── web_scrapperModel.dart
│   ├── 🎨 view/            # UI bileşenleri
│   │   ├── 📄 pages/       # Sayfa widgetları
│   │   │   ├── home_view.dart
│   │   │   └── splash_view.dart
│   │   ├── 🧩 components/  # Yeniden kullanılabilir bileşenler
│   │   │   ├── custom_tab_bar_component.dart
│   │   │   ├── seo_info_component.dart
│   │   │   ├── statistics_section_component.dart
│   │   │   ├── url_input_component.dart
│   │   │   └── [diğer bileşenler...]
│   │   ├── components.dart # Bileşen export dosyası
│   │   └── page.dart      # Sayfa export dosyası
│   ├── 🛣️ routes.dart      # Uygulama rotaları
│   └── 🚀 main.dart       # Ana giriş noktası
├── 📋 pubspec.yaml        # Proje konfigürasyonu
└── 📖 README.md           # Bu dosya
```

## 🔧 Teknik Detaylar

### Kullanılan Paketler

| Paket | Versiyon | Açıklama |
|-------|----------|----------|
| `flutter` | SDK | Flutter framework |
| `cupertino_icons` | ^1.0.8 | iOS stil ikonlar |
| `flutter_dotenv` | ^6.0.0 | Ortam değişkenleri yönetimi |
| `http` | ^1.5.0 | HTTP istekleri için |
| `html` | ^0.15.6 | HTML parsing ve DOM manipülasyonu |

### Mimari Yapı

#### MVC (Model-View-Controller) Pattern
- **Model**: `AeXpWebScraper` - Web scraping ve veri işleme
- **View**: Widget bileşenleri - Kullanıcı arayüzü
- **Controller**: `HomeController` - İş mantığı ve state yönetimi

#### State Management
- **ChangeNotifier**: Reaktif state yönetimi
- **Provider Pattern**: Dependency injection
- **Real-time Updates**: Canlı veri güncellemeleri

### Güvenlik Özellikleri
- ✅ **HTTPS Zorlaması**: Güvenli bağlantı kontrolü
- ✅ **User-Agent Rotasyonu**: Bot algılamasını önleme
- ✅ **Request Timeout**: İstek zaman aşımı koruması
- ✅ **Error Boundary**: Hata sınırlama mekanizması

## 📊 Analiz Özellikleri

### 1. Meta Tag Analizi
```dart
// Desteklenen meta tag türleri:
- title
- description
- keywords
- author
- viewport
- robots
- canonical
- og:tags (Open Graph)
- twitter:tags
```

### 2. SEO 
- **Title Optimizasyonu**: Uzunluk ve keyword analizi
- **Meta Description**: Karakter sayısı ve relevance kontrolü
- **Heading Structure**: H1-H6 hiyerarşi analizi
- **Internal/External Links**: Link profili değerlendirmesi
- **Image Optimization**: Alt text ve dosya boyutu kontrolü

### 3. Teknik SEO
- **Schema Markup**: JSON-LD ve mikrodata desteği
- **URL Structure**: URL analizi ve optimizasyon önerileri
- **Page Speed**: Performans değerlendirmesi
- **Mobile Friendliness**: Responsive tasarım kontrolü


## 🎨 Tema ve Tasarım

### Renk Paleti
```dart
Primary Color: #FFEB3B (Sarı)
Secondary Color: #FFC107 (Amber)
Background: #FFFDE7 (Açık Sarı)
Surface: #F3F7FF (Açık Mavi)
Text: #2E2E2E (Koyu Gri)
```

### Tipografi
- **Font Family**: System default (Roboto/SF Pro)
- **Heading Size**: 20px (Bold)
- **Body Text**: 16px (Regular)
- **Caption**: 14px (Medium)


### 🚀 Splash Screen
Animasyonlu logo ve yükleme ekranı

### 🏠 Ana Ekran
URL giriş alanı ve analiz butonu

### 📊 Analiz Sonuçları
Tab yapısında organize edilmiş SEO verileri







## 📄 Lisans

Bu proje MIT lisansı altında lisanslanmıştır. Detaylar için [LICENSE](LICENSE) dosyasına bakın.



<div align="center">

**⭐ Bu projeyi beğendiyseniz yıldız vermeyi unutmayın! ⭐**

Made with ❤️ and Flutter

</div>
