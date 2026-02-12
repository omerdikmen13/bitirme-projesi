# 📸 Akıllı Galeri (Smart Gallery)

> **Google ML Kit ile yapay zeka destekli akıllı fotoğraf galerisi uygulaması**

![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart)
![ML Kit](https://img.shields.io/badge/Google_ML_Kit-Offline_AI-4285F4?logo=google)
![SQLite](https://img.shields.io/badge/SQLite-Database-003B57?logo=sqlite)
![License](https://img.shields.io/badge/License-MIT-green)

---

## 📋 İçindekiler

- [Proje Hakkında](#-proje-hakkında)
- [Özellikler](#-özellikler)
- [Mimari Yapı](#-mimari-yapı)
- [Proje Yapısı](#-proje-yapısı)
- [Kullanılan Teknolojiler ve Kütüphaneler](#-kullanılan-teknolojiler-ve-kütüphaneler)
- [Gereksinimler](#-gereksinimler)
- [Kurulum](#-kurulum)
- [Çalıştırma](#-çalıştırma)
- [APK Oluşturma](#-apk-oluşturma)
- [Veritabanı Yapısı](#-veritabanı-yapısı)
- [Servis Katmanı Detayları](#-servis-katmanı-detayları)
- [Ekranlar ve Özellik Detayları](#-ekranlar-ve-özellik-detayları)
- [Sorun Giderme](#-sorun-giderme)
- [Katkıda Bulunma](#-katkıda-bulunma)

---

## 🎯 Proje Hakkında

**Akıllı Galeri (Smart Gallery)**, kullanıcıların cihazlarındaki fotoğrafları **yapay zeka** ile otomatik olarak etiketleyip kategorize etmesini sağlayan bir Flutter mobil uygulamasıdır. Google ML Kit kütüphanesi kullanılarak fotoğraflardaki nesneler, sahneler ve yüzler **tamamen çevrimdışı (offline)** olarak algılanır. Uygulama internet bağlantısı gerektirmez; tüm AI işlemleri cihaz üzerinde gerçekleşir.

### Temel Amaçlar
- 🧠 **Yapay Zeka ile Otomatik Etiketleme**: Fotoğrafları nesne ve sahne tanıma ile otomatik etiketleme
- 👤 **Yüz Algılama**: Fotoğraflardaki yüzleri tespit etme ve gruplandırma
- 🔍 **Akıllı Arama**: Etiketler üzerinden doğal dilde arama yapabilme (ör: "cat", "dog", "smile")
- 📁 **Albüm Yönetimi**: Fotoğrafları albümler halinde organize etme
- ❤️ **Favori ve Çöp Kutusu**: Gelişmiş fotoğraf yönetim sistemi

---

## ✨ Özellikler

| Özellik | Açıklama |
|---|---|
| 🏷️ **Otomatik Etiketleme** | Google ML Kit Image Labeling ile fotoğrafları otomatik etiketleme (%60 güven eşiği) |
| 👤 **Yüz Algılama** | Google ML Kit Face Detection ile yüz tespiti, gülümseme/göz analizi |
| 🔍 **Akıllı Arama** | Etiketler ve kişiler üzerinden arama (İngilizce ve Türkçe destekli) |
| 📁 **Albüm Yönetimi** | Sınırsız albüm oluşturma, fotoğraf ekleme/çıkarma |
| ❤️ **Favoriler** | Fotoğrafları favori olarak işaretleme ve filtreleme |
| 🗑️ **Çöp Kutusu** | Güvenli silme, geri yükleme ve kalıcı silme |
| 📅 **Tarih Gruplandırma** | Fotoğrafları çekilme tarihine göre otomatik gruplandırma |
| 🖼️ **Fotoğraf Görüntüleyici** | Tam ekran görüntüleme, yakınlaştırma, kaydırma |
| 🌙 **Karanlık Tema** | Modern ve göz yormayan koyu tema tasarımı |
| 📱 **Offline Çalışma** | İnternet bağlantısı gerektirmeden tüm AI özellikleri |

---

## 🏗️ Mimari Yapı

Uygulama **Katmanlı Mimari (Layered Architecture)** prensibiyle geliştirilmiştir:

```
┌─────────────────────────────────────────────┐
│              Presentation Layer              │
│     (Screens, Widgets, UI Components)        │
├─────────────────────────────────────────────┤
│               Service Layer                  │
│  (LabelingService, FaceDetectionService)     │
├─────────────────────────────────────────────┤
│                Data Layer                    │
│   (DatabaseHelper, Models, Repositories)     │
├─────────────────────────────────────────────┤
│                Core Layer                    │
│   (Constants, Colors, Strings, Dimensions)   │
└─────────────────────────────────────────────┘
```

### Katman Sorumlulukları

| Katman | Sorumluluk |
|---|---|
| **Core** | Uygulama genelinde kullanılan sabitler (renkler, metinler, boyutlar) |
| **Data** | Veritabanı işlemleri (SQLite CRUD), veri modelleri (Photo, Album, Label) |
| **Service** | Yapay zeka servisleri (Etiketleme, Yüz Algılama) — iş mantığı katmanı |
| **Presentation** | Kullanıcı arayüzü ekranları ve yeniden kullanılabilir widget'lar |

---

## 📂 Proje Yapısı

```
lib/
├── main.dart                                  # Uygulama giriş noktası, tema ve routing
│
├── core/                                      # Çekirdek sabitler ve konfigürasyon
│   └── constants/
│       ├── constants.dart                     # Barrel export dosyası
│       ├── app_colors.dart                    # Renk paleti (dark theme tonları)
│       ├── app_strings.dart                   # Uygulama metinleri (Türkçe)
│       └── app_dimensions.dart                # Boyutlar, padding, radius sabitleri
│
├── data/                                      # Veri katmanı
│   ├── models/
│   │   ├── models.dart                        # Barrel export dosyası
│   │   ├── photo_model.dart                   # Fotoğraf veri modeli
│   │   ├── album_model.dart                   # Albüm veri modeli
│   │   └── label_model.dart                   # Etiket veri modeli
│   │
│   └── database/
│       └── database_helper.dart               # SQLite veritabanı yöneticisi (42 metod)
│
├── services/                                  # İş mantığı - yapay zeka servisleri
│   ├── services.dart                          # Barrel export dosyası
│   ├── labeling_service.dart                  # Google ML Kit Image Labeling servisi
│   └── face_detection_service.dart            # Google ML Kit Face Detection servisi
│
└── presentation/                              # Sunum katmanı - UI
    ├── screens/
    │   ├── home/
    │   │   └── home_screen.dart               # Ana sayfa (fotoğraf grid + etiketleme)
    │   ├── albums/
    │   │   └── albums_screen.dart             # Albüm listesi ve yönetimi
    │   ├── favorites/
    │   │   └── favorites_screen.dart          # Favori fotoğraflar
    │   ├── persons/
    │   │   └── persons_screen.dart            # Kişiler (yüz grupları)
    │   ├── photo_viewer/
    │   │   └── photo_viewer_screen.dart       # Tam ekran fotoğraf görüntüleyici
    │   └── trash/
    │       └── trash_screen.dart              # Çöp kutusu
    │
    └── widgets/
        ├── widgets.dart                       # Barrel export dosyası
        ├── bottom_nav_bar.dart                # Alt navigasyon çubuğu
        ├── search_bar_widget.dart             # Arama çubuğu widget'ı
        └── common_widgets.dart                # Ortak kullanılan widget'lar
```

---

## 📦 Kullanılan Teknolojiler ve Kütüphaneler

### Temel Framework
| Kütüphane | Versiyon | Açıklama |
|---|---|---|
| **Flutter SDK** | ^3.9.2 | Cross-platform mobil uygulama geliştirme framework'ü |
| **Dart SDK** | ^3.9.2 | Flutter'ın programlama dili |

### Uygulama Bağımlılıkları (dependencies)

| Kütüphane | Versiyon | Açıklama | Kullanım Amacı |
|---|---|---|---|
| `cupertino_icons` | ^1.0.8 | iOS tarzı ikonlar | UI ikonları |
| `photo_manager` | ^3.0.0 | Cihaz galerisi erişimi | Fotoğraf okuma, metadata alma |
| `permission_handler` | ^11.3.0 | İzin yönetimi | Galeri, kamera, depolama izinleri |
| `file_picker` | ^8.0.0 | Dosya seçici | Cihazdan fotoğraf seçme |
| `image_picker` | ^1.1.2 | Kamera/galeri seçici | Kameradan fotoğraf çekme |
| `path_provider` | ^2.1.2 | Dosya yolu sağlayıcı | Uygulama dizini erişimi |
| `path` | ^1.9.0 | Path işlemleri | Dosya yolu manipülasyonu |
| `intl` | ^0.20.2 | Uluslararasılaştırma | Tarih/saat formatlama |
| `image` | ^4.1.7 | Görüntü işleme | Fotoğraf küçültme, thumbnail oluşturma |
| `sqflite` | ^2.3.0 | SQLite veritabanı | Yerel veri depolama (fotoğraf, etiket, albüm) |
| `google_mlkit_image_labeling` | ^0.14.1 | ML Kit Görsel Etiketleme | **Yapay zeka ile otomatik nesne/sahne tanıma** |
| `google_mlkit_face_detection` | ^0.13.1 | ML Kit Yüz Algılama | **Yapay zeka ile yüz tespiti ve analizi** |

### Geliştirme Bağımlılıkları (dev_dependencies)

| Kütüphane | Versiyon | Açıklama |
|---|---|---|
| `flutter_test` | SDK | Birim test framework'ü |
| `flutter_lints` | ^5.0.0 | Kod kalite ve stil kuralları |

---

## ⚙️ Gereksinimler

### Sistem Gereksinimleri

| Gereksinim | Minimum | Önerilen |
|---|---|---|
| **İşletim Sistemi** | Windows 10 / macOS 11 / Linux | Windows 11 / macOS 13+ |
| **RAM** | 8 GB | 16 GB |
| **Disk Alanı** | 5 GB boş alan | 10 GB boş alan |
| **Flutter SDK** | 3.9.2+ | 3.9.x (en güncel) |
| **Dart SDK** | 3.9.2+ | 3.9.x (en güncel) |
| **Android SDK** | API 21+ (Android 5.0) | API 33+ (Android 13) |
| **Java JDK** | 11 | 17 |

### Geliştirme Araçları

- **Flutter SDK** (zorunlu)
- **Android Studio** veya **VS Code** (önerilen IDE)
- **Android SDK** ve **Android Emulator** veya fiziksel cihaz
- **Git** (versiyon kontrol)

---

## 🚀 Kurulum

### 1. Flutter SDK Kurulumu

Flutter henüz kurulu değilse, aşağıdaki adımları takip edin:

#### Windows
```powershell
# 1. Flutter SDK'yı indirin
# https://docs.flutter.dev/get-started/install/windows adresinden indirin

# 2. İndirilen zip dosyasını C:\flutter dizinine çıkarın

# 3. PATH'e ekleyin (Sistem Ortam Değişkenleri)
# C:\flutter\bin dizinini PATH'e ekleyin

# 4. Kurulumu doğrulayın
flutter doctor
```

#### macOS
```bash
# Homebrew ile kurulum
brew install flutter

# Kurulumu doğrulayın
flutter doctor
```

#### Linux
```bash
# Snap ile kurulum
sudo snap install flutter --classic

# Kurulumu doğrulayın
flutter doctor
```

### 2. Flutter Doctor Kontrolü

Tüm gereksinimlerin karşılandığından emin olun:

```bash
flutter doctor -v
```

Beklenen çıktı (tüm öğelerin ✓ olması gerekir):

```
[✓] Flutter (Channel stable, 3.x.x)
[✓] Android toolchain - develop for Android devices
[✓] Android Studio
[✓] VS Code (veya kullandığınız IDE)
[✓] Connected device
```

> ⚠️ **Önemli**: Herhangi bir ✗ veya ! işareti varsa, `flutter doctor` komutunun önerdiği çözümleri uygulayın.

### 3. Projeyi Klonlama

```bash
# Projeyi GitHub'dan klonlayın
git clone https://github.com/omerdikmen13/bitirme-projesi.git

# Proje dizinine girin
cd bitirme-projesi
```

### 4. Bağımlılıkları Yükleme

```bash
# Tüm Flutter paketlerini indirin ve kurun
flutter pub get
```

Bu komut `pubspec.yaml` dosyasındaki tüm bağımlılıkları (12 paket) otomatik olarak indirir.

### 5. Android SDK Yapılandırması

Eğer Android SDK ile ilgili sorun yaşıyorsanız:

```bash
# Android SDK lisanslarını kabul edin
flutter doctor --android-licenses

# Her soru için 'y' yazıp Enter'a basın
```

---

## ▶️ Çalıştırma

### Emülatör ile Çalıştırma

```bash
# 1. Mevcut cihazları listeleyin
flutter devices

# 2. Android Emülatörü başlatın (Android Studio'dan veya komut satırından)
flutter emulators --launch <emulator_id>

# 3. Uygulamayı çalıştırın
flutter run
```

### Fiziksel Cihaz ile Çalıştırma

1. Android cihazınızda **Geliştirici Seçenekleri**'ni açın:
   - `Ayarlar > Telefon Hakkında > Yapı Numarası` üzerine 7 kez dokunun
2. **USB Hata Ayıklama**'yı etkinleştirin:
   - `Ayarlar > Geliştirici Seçenekleri > USB Hata Ayıklama`
3. Cihazı USB ile bilgisayara bağlayın
4. Aşağıdaki komutu çalıştırın:

```bash
flutter run
```

### Debug Modu ile Çalıştırma

```bash
# Verbose (detaylı) debug modunda çalıştırma
flutter run --verbose

# Belirli bir cihazda çalıştırma
flutter run -d <device_id>
```

---

## 📱 APK Oluşturma

### Debug APK

```bash
# Debug APK oluşturma (test amaçlı)
flutter build apk --debug
```

Çıktı dosyası: `build/app/outputs/flutter-apk/app-debug.apk`

### Release APK

```bash
# Release APK oluşturma (yayınlama için)
flutter build apk --release
```

Çıktı dosyası: `build/app/outputs/flutter-apk/app-release.apk`

### APK Boyutunu Küçültme

```bash
# ABI bazında ayrı APK oluşturma (daha küçük boyut)
flutter build apk --split-per-abi
```

Bu komut 3 ayrı APK oluşturur:
- `app-armeabi-v7a-release.apk` (32-bit ARM)
- `app-arm64-v8a-release.apk` (64-bit ARM — çoğu modern cihaz)
- `app-x86_64-release.apk` (x86 emülatörler)

---

## 🗄️ Veritabanı Yapısı

Uygulama **SQLite** veritabanı kullanır. Veritabanı dosyası: `smart_gallery.db`

### Tablolar

#### `photos` — Fotoğraf Bilgileri
| Kolon | Tip | Açıklama |
|---|---|---|
| `id` | INTEGER (PK) | Otomatik artan birincil anahtar |
| `file_path` | TEXT (UNIQUE) | Fotoğrafın tam dosya yolu |
| `file_name` | TEXT | Dosya adı |
| `width` | INTEGER | Genişlik (piksel) |
| `height` | INTEGER | Yükseklik (piksel) |
| `size_bytes` | INTEGER | Dosya boyutu (byte) |
| `date_taken` | TEXT | Çekilme tarihi |
| `is_favorite` | INTEGER | Favori durumu (0/1) |
| `is_deleted` | INTEGER | Silinme durumu (0/1) |
| `deleted_at` | TEXT | Silinme tarihi |
| `created_at` | TEXT | Kayıt oluşturma tarihi |
| `updated_at` | TEXT | Son güncelleme tarihi |

#### `labels` — Etiket Tanımları
| Kolon | Tip | Açıklama |
|---|---|---|
| `id` | INTEGER (PK) | Otomatik artan birincil anahtar |
| `name` | TEXT (UNIQUE) | Etiket adı (İngilizce) |
| `name_tr` | TEXT | Etiket adı (Türkçe) |
| `category` | TEXT | Etiket kategorisi |

#### `photo_labels` — Fotoğraf-Etiket İlişkisi
| Kolon | Tip | Açıklama |
|---|---|---|
| `id` | INTEGER (PK) | Otomatik artan birincil anahtar |
| `photo_id` | INTEGER (FK) | Fotoğraf referansı |
| `label_id` | INTEGER (FK) | Etiket referansı |
| `confidence` | REAL | Güven skoru (0.0 — 1.0) |

#### `albums` — Albümler
| Kolon | Tip | Açıklama |
|---|---|---|
| `id` | INTEGER (PK) | Otomatik artan birincil anahtar |
| `name` | TEXT | Albüm adı |
| `description` | TEXT | Albüm açıklaması |
| `cover_photo_id` | INTEGER | Kapak fotoğrafı ID |
| `created_at` | TEXT | Oluşturma tarihi |

#### `album_photos` — Albüm-Fotoğraf İlişkisi
| Kolon | Tip | Açıklama |
|---|---|---|
| `id` | INTEGER (PK) | Otomatik artan birincil anahtar |
| `album_id` | INTEGER (FK) | Albüm referansı |
| `photo_id` | INTEGER (FK) | Fotoğraf referansı |
| `added_at` | TEXT | Eklenme tarihi |

#### `faces` — Algılanan Yüzler
| Kolon | Tip | Açıklama |
|---|---|---|
| `id` | INTEGER (PK) | Otomatik artan birincil anahtar |
| `file_path` | TEXT | Fotoğraf dosya yolu |
| `bounding_box` | TEXT (JSON) | Yüz konum bilgisi (left, top, width, height) |
| `face_data` | TEXT (JSON) | Yüz analiz verileri (gülümseme, göz durumu, baş açısı) |
| `person_id` | INTEGER | Kişi grubu ID |

#### `face_scan_status` — Yüz Tarama Durumu
| Kolon | Tip | Açıklama |
|---|---|---|
| `file_path` | TEXT (PK) | Fotoğraf dosya yolu |
| `scanned` | INTEGER | Taranma durumu (0/1) |
| `scanned_at` | TEXT | Taranma tarihi |

---

## 🤖 Servis Katmanı Detayları

### LabelingService — Görsel Etiketleme Servisi

Google ML Kit Image Labeling API kullanarak fotoğraflardaki nesne ve sahneleri otomatik algılar.

**Çalışma Prensibi:**
1. Fotoğraf dosya yolu alınır
2. `InputImage.fromFilePath()` ile ML Kit giriş formatına dönüştürülür
3. `ImageLabeler.processImage()` ile yapay zeka analizi yapılır
4. Güven skoru ≥ %60 olan etiketler filtrelenir
5. Sonuçlar güven skoruna göre sıralanır
6. En yüksek skorlu 10 etiket döndürülür
7. Etiketler SQLite veritabanına kaydedilir

**Singleton Pattern** ile tek bir instance kullanılır: `LabelingService.instance`

### FaceDetectionService — Yüz Algılama Servisi

Google ML Kit Face Detection API kullanarak fotoğraflardaki yüzleri tespit eder.

**Algılanan Yüz Verileri:**
| Veri | Açıklama |
|---|---|
| `boundingBox` | Yüzün konumu (left, top, width, height) |
| `smilingProbability` | Gülümseme olasılığı (0.0 — 1.0) |
| `leftEyeOpenProbability` | Sol göz açıklığı olasılığı |
| `rightEyeOpenProbability` | Sağ göz açıklığı olasılığı |
| `headEulerAngleY` | Baş yatay dönüş açısı |
| `headEulerAngleZ` | Baş eğim açısı |

**Konfigürasyon:**
- `performanceMode`: `FaceDetectorMode.accurate` (yüksek doğruluk)
- `minFaceSize`: 0.1 (minimum yüz boyutu oranı)
- `enableLandmarks`: Yüz işaret noktaları aktif
- `enableClassification`: Gülümseme/göz sınıflandırması aktif

---

## 📱 Ekranlar ve Özellik Detayları

### 🏠 Ana Sayfa (HomeScreen)
- Cihazdan yüklenen tüm fotoğrafları grid görünümünde listeler
- Fotoğrafları tarihe göre gruplandırarak gösterir
- Otomatik etiketleme işlemini arka planda başlatır
- Arama çubuğu ile etiketlere göre arama yapma

### 📁 Albümler (AlbumsScreen)
- Yeni albüm oluşturma (ad + açıklama)
- Albüme fotoğraf ekleme/çıkarma
- Albüm kapak fotoğrafı ayarlama
- Albüm silme

### ❤️ Favoriler (FavoritesScreen)
- Favori olarak işaretlenen fotoğrafları listeler
- Favoriye ekleme/çıkarma işlemleri

### 👤 Kişiler (PersonsScreen)
- Yüz algılama sonuçlarını gruplandırarak gösterir
- Algılanan yüz sayısı bilgisi

### 🖼️ Fotoğraf Görüntüleyici (PhotoViewerScreen)
- Tam ekran fotoğraf görüntüleme
- Pinch-to-zoom (parmakla yakınlaştırma)
- Kaydırma ile fotoğraflar arası geçiş
- Fotoğraf detay bilgileri (boyut, tarih, çözünürlük)
- Favoriye ekleme, silme, albüme ekleme aksiyonları

### 🗑️ Çöp Kutusu (TrashScreen)
- Silinen fotoğrafları listeler
- Tek tek veya toplu geri yükleme
- Kalıcı silme (geri dönüşsüz)
- Çöp kutusunu tamamen boşaltma

---

## 🔧 Sorun Giderme

### Sık Karşılaşılan Sorunlar

#### ❌ `flutter pub get` başarısız oluyor
```bash
# Flutter cache'i temizleyin
flutter clean

# Pub cache'i temizleyin
flutter pub cache repair

# Tekrar deneyin
flutter pub get
```

#### ❌ Android Build hatası
```bash
# Gradle cache'i temizleyin
cd android
./gradlew clean
cd ..

# Projeyi temizleyip tekrar derleyin
flutter clean
flutter pub get
flutter run
```

#### ❌ ML Kit modeli bulunamıyor hatası
Google ML Kit modelleri ilk çalıştırmada otomatik indirilir. Cihazın internete bağlı olduğundan emin olun. Model indirildikten sonra offline çalışır.

#### ❌ İzin hataları (Permission Denied)
Uygulama ilk çalıştığında galeri ve depolama izinleri isteyecektir. İzinleri verin. Eğer izinler reddedildiyse:
- `Ayarlar > Uygulamalar > Akıllı Galeri > İzinler` bölümünden manuel olarak verin

#### ❌ Kotlin/Gradle versiyon uyumsuzluğu
`android/build.gradle.kts` dosyasında Kotlin ve Gradle versiyonlarını güncelleyin:
```bash
flutter pub upgrade
```

### Yararlı Komutlar

```bash
# Proje durumunu kontrol etme
flutter doctor -v

# Bağımlılıkları güncelleme
flutter pub upgrade

# Projeyi tamamen temizleme
flutter clean && flutter pub get

# Tüm cihazları listeleme
flutter devices

# Detaylı log ile çalıştırma
flutter run --verbose
```

---

## 🤝 Katkıda Bulunma

1. Bu repoyu fork edin
2. Feature branch oluşturun (`git checkout -b feature/yeni-ozellik`)
3. Değişiklerinizi commit edin (`git commit -m 'Yeni özellik eklendi'`)
4. Branch'inizi push edin (`git push origin feature/yeni-ozellik`)
5. Pull Request oluşturun

---

## 👤 Geliştirici

| | |
|---|---|
| **Ad** | Ömer Dikmen |
| **GitHub** | [@omerdikmen13](https://github.com/omerdikmen13) |

---

## 📄 Lisans

Bu proje **MIT Lisansı** ile lisanslanmıştır. Detaylar için [LICENSE](LICENSE) dosyasına bakın.

---

<p align="center">
  <b>⭐ Bu projeyi beğendiyseniz yıldız vermeyi unutmayın! ⭐</b>
</p>
