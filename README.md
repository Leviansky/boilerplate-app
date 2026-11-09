# Enterprise Flutter Marketplace Boilerplate

Boilerplate aplikasi Marketplace berskala enterprise dengan arsitektur modular GetX 7-layer slice, performa tinggi (60/120 FPS), dan kepatuhan ketat terhadap standar **Zero-Trust OWASP Mobile Application Security Verification Standard (MASVS)**.

---

## 📋 Spesifikasi Lingkungan & Versioning

Boilerplate ini telah dikompilasi, diaudit, dan diverifikasi kompatibel pada lingkungan pengembangan resmi berikut:

| Komponen | Versi | Keterangan |
| :--- | :--- | :--- |
| **Flutter SDK** | `3.47.9` (Channel `stable`) | Framework Engine |
| **Dart SDK** | `3.13.7` | Bahasa Pemrograman Dasar |
| **Android SDK Toolchain** | `API 36.0.0` | Compile SDK / Build Tools |
| **Xcode** | `26.6` | iOS / macOS Toolchain |
| **Host OS** | `macOS 26.5.2` (`darwin-arm64`) | Apple Silicon Ready |
| **Target Platforms** | Android (minSdk 21) & iOS (iOS 14+) | Mobile Target |

---

## 🏛️ Arsitektur Direktori Proyek

```text
lib/
├── app/
│   ├── middleware/                     # Route Guards GetX (Security, Auth, Session)
│   ├── modules/                        # Feature Slices (Auth, Product, Checkout, dll)
│   ├── routes/                         # AppPages & AppRoutes
│   └── shared/                         # Controllers, Models, & Widgets Lintas Modul
├── core/
│   ├── config/                         # EnvConfig (Flavors), SecurityConfig, RemoteConfigService
│   ├── network/                        # ApiClient (Dio), Endpoints, ErrorHandler, 5 Interceptors
│   ├── security/                       # FreeRASP, SafeDevice, Biometrics, AES-GCM 256, HMAC, Session
│   ├── service/                        # DeviceService, SecureStorageService (Encrypted Keystore/Keychain)
│   ├── theme/                          # AppColors, Spacing, Typography, Material 3 AppTheme
│   ├── utils/                          # CurrencyFormatter (Zero-Float), DateFormatter, Validators
│   └── values/                         # AppAssets, AppConstants, StorageKeys
├── main_common.dart                    # Shared Bootstrap Logic & Error Zoning
├── main_development.dart               # Entrypoint Flavor Development
├── main_staging.dart                   # Entrypoint Flavor Staging
├── main_production.dart                # Entrypoint Flavor Production
├── main.dart                           # Fallback Default Entrypoint
└── main_binding.dart                   # Global Dependency Container
```

---

## 🛠️ TUTORIAL 1: CLI GENERATOR MODUL BARU (`tool/create_module.dart`)

Untuk mempercepat penambahan fitur baru tanpa melanggar kontrak arsitektur dan aturan kepatuhan keamanan, telah disediakan generator otomatis berbasis Dart CLI.

### 1. Menjalankan Generator

Jalankan perintah berikut di terminal root proyek:

```bash
dart run tool/create_module.dart <nama_modul>
```

#### Contoh:
```bash
dart run tool/create_module.dart order
```

### 2. Berkas yang Dihasilkan Otomatis
Generator akan membuat struktur 7-layer slice secara instan di bawah direktori `lib/app/modules/<nama_modul>/`:

```text
lib/app/modules/order/
├── data/
│   ├── models/
│   │   └── order_model.dart            # Fail-safe JSON parsing, zero-float int (minor unit)
│   ├── providers/
│   │   └── order_provider.dart         # Integrasi ApiClient (AES/HMAC/Attestation auto-injected)
│   └── repositories/
│       └── order_repository.dart       # Single source of truth modul
├── controllers/
│   └── order_controller.dart          # 5-State contract & otomatis memory disposal
├── bindings/
│   └── order_binding.dart             # Get.lazyPut dependency injection
├── views/
│   └── order_view.dart                # SafeScreenWrapper, AppColors/AppSpacing tokens, granular Obx
└── widgets/
    └── order_card_widget.dart         # Komponen UI lokal zero-hardcoding
```

### 3. Mendaftarkan Rute Modul Baru

Setelah modul ter-generate, daftarkan rutenya ke dalam sistem navigasi GetX:

1. **Buka [`lib/app/routes/app_routes.dart`](lib/app/routes/app_routes.dart)** dan tambahkan konstanta:
   ```dart
   abstract class Routes {
     static const ORDER = _Paths.ORDER;
   }

   abstract class _Paths {
     static const ORDER = '/order';
   }
   ```

2. **Buka [`lib/app/routes/app_pages.dart`](lib/app/routes/app_pages.dart)** dan daftarkan `GetPage`:
   ```dart
   import '../modules/order/bindings/order_binding.dart';
   import '../modules/order/views/order_view.dart';

   // Di dalam List<GetPage> routes:
   GetPage(
     name: _Paths.ORDER,
     page: () => const OrderView(),
     binding: OrderBinding(),
     middlewares: [
       SecurityMiddleware(), // Validasi anti-tamper & hardware integrity
       AuthMiddleware(),     // Validasi token autentikasi
     ],
   ),
   ```

---

## 🚀 TUTORIAL 2: FLAVORS & CLI BUILD MATRIX (`tool/build.dart`)

Boilerplate ini mendukung 3 environment terisolasi: **Development**, **Staging**, dan **Production** untuk platform **Android** dan **iOS**. Seluruh spesifikasi build dideklarasikan di [`build.json`](build.json).

### 1. Matrix Konfigurasi Environment

| Konfigurasi | Development (`development`) | Staging (`staging`) | Production (`production`) |
| :--- | :--- | :--- | :--- |
| **Dart Entrypoint** | `lib/main_development.dart` | `lib/main_staging.dart` | `lib/main_production.dart` |
| **App Name** | `Marketplace Dev` | `Marketplace Staging` | `Marketplace Enterprise` |
| **Package / Bundle ID** | `com.example.testing_boilerplate.dev` | `com.example.testing_boilerplate.stg` | `com.example.testing_boilerplate` |
| **Base URL** | `https://dev-api.marketplace.enterprise.com` | `https://stg-api.marketplace.enterprise.com` | `https://api.marketplace.enterprise.com` |
| **Detailed Logging** | Aktif | Aktif | Dinonaktifkan (Masked) |
| **Debug Banner** | Aktif | Aktif | Dinonaktifkan |

---

### 2. Menjalankan Aplikasi Secara Lokal (Debug)

Gunakan perintah `flutter run` dengan flag `--flavor` dan target entrypoint:

```bash
# Development (Emulator / Device)
flutter run --flavor development -t lib/main_development.dart

# Staging
flutter run --flavor staging -t lib/main_staging.dart

# Production
flutter run --flavor production -t lib/main_production.dart
```

> **Tips VS Code**: Anda juga dapat memilih profil **Marketplace (Development)**, **Marketplace (Staging)**, atau **Marketplace (Production)** pada menu **Run & Debug** (F5) yang telah dikonfigurasi pada `.vscode/launch.json`.

---

### 3. Menggunakan CLI Build Runner (`tool/build.dart`)

CLI `tool/build.dart` membaca spesifikasi dari [`build.json`](build.json) untuk memastikan perintah build dieksekusi secara konsisten tanpa kesalahan pengetikan flag.

#### A. Melihat Seluruh Opsi Target Build
```bash
dart run tool/build.dart --list
```

#### B. Simulasi Perintah (Dry Run)
Gunakan `--dry-run` untuk melihat perintah yang akan dieksekusi sebelum menjalankan proses kompilasi:
```bash
# Cek build Android AppBundle Production
dart run tool/build.dart --env=production --platform=android --target=appbundle --dry-run

# Cek build iOS IPA Staging
dart run tool/build.dart --env=staging --platform=ios --target=ipa --dry-run
```

#### C. Mengeksekusi Kompilasi Build

##### 1. Android Builds:
```bash
# Build APK Debug (Development)
dart run tool/build.dart --env=development --platform=android --target=apk_debug

# Build APK Release (Development)
dart run tool/build.dart --env=development --platform=android --target=apk_release

# Build APK Release (Staging)
dart run tool/build.dart --env=staging --platform=android --target=apk

# Build AppBundle AAB untuk Google Play Store (Production - Termasuk Obfuscation)
dart run tool/build.dart --env=production --platform=android --target=appbundle
```

##### 2. iOS Builds:
```bash
# Build Simulator .app (Development)
dart run tool/build.dart --env=development --platform=ios --target=simulator

# Build IPA Release (Staging)
dart run tool/build.dart --env=staging --platform=ios --target=ipa

# Build IPA Release untuk App Store (Production - Termasuk Obfuscation)
dart run tool/build.dart --env=production --platform=ios --target=ipa
```

---

## 🔒 Standar Keamanan OWASP MASVS & Performance

1. **Code Obfuscation**: Build production secara otomatis menyertakan `--obfuscate` dan `--split-debug-info` untuk memproteksi source code dari reverse engineering.
2. **Zero-Float Currency**: Nilai moneter wajib bertipe `int` (sen/minor unit) dan dirender menggunakan `CurrencyFormatter.formatRupiah()`.
3. **5-State Contract**: Setiap layar katalog/data wajib menangani visual `initial`, `loading` (shimmer), `success`, `empty`, dan `error` (retry).
4. **Hardware Screen Shield**: Seluruh layar sensitif dibungkus oleh `SafeScreenWrapper` untuk mencegah perekaman dan screenshot.
5. **Memory Disposal**: Seluruh controller GetX membersihkan `ScrollController`, `TextEditingController`, dan timer pada lifecycle `onClose()`.

---

## 🧪 Pengujian & Audit Statis

Jalankan audit kode dan unit test secara berkala:

```bash
# Menjalankan static analysis ketat (0 issues policy)
dart analyze --fatal-infos

# Menjalankan seluruh unit test suite
flutter test
```
