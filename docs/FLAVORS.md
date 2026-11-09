# PANDUAN KONFIGURASI FLUTTER FLAVOR (3 ENVIRONMENT)

Dokumentasi ini menjelaskan konfigurasi, struktur berkas, dan instruksi eksekusi untuk 3 environment flavor: **Development**, **Staging**, dan **Production**.

---

## 1. MATRIX ENVIRONMENT & IDENTIFIER

| Konfigurasi | Development (`dev`) | Staging (`stg`) | Production (`prod`) |
| :--- | :--- | :--- | :--- |
| **Dart Entrypoint** | `lib/main_development.dart` | `lib/main_staging.dart` | `lib/main_production.dart` |
| **Flavor Name** | `development` | `staging` | `production` |
| **App Name** | `Marketplace Dev` | `Marketplace Staging` | `Marketplace Enterprise` |
| **Android Application ID** | `com.example.testing_boilerplate.dev` | `com.example.testing_boilerplate.stg` | `com.example.testing_boilerplate` |
| **Base URL** | `https://dev-api.marketplace.enterprise.com` | `https://stg-api.marketplace.enterprise.com` | `https://api.marketplace.enterprise.com` |
| **Detailed Logging** | Enabled | Enabled | Disabled (Sanitized) |
| **Debug Banner** | Enabled | Enabled | Disabled |

---

## 2. ARSITEKTUR KODE DART

### A. Shared Bootstrap (`lib/main_common.dart`)
Seluruh inisialisasi core security (FreeRASP, SafeDevice, Biometrics, SecureStorage, ApiClient, SessionTracker) dikonsolidasikan pada fungsi `bootstrapApp(Environment environment)`.

### B. Entrypoint Spesifik
Tiap flavor memiliki entrypoint mandiri yang memanggil `bootstrapApp` dengan enum `Environment` terkait:
```dart
// lib/main_development.dart
import 'core/config/env_config.dart';
import 'main_common.dart';

Future<void> main() async {
  await bootstrapApp(Environment.development);
}
```

### C. Fallback / Unified Entrypoint (`lib/main.dart`)
`lib/main.dart` tetap tersedia untuk default execution dan membaca argumen `--dart-define=APP_ENV=...` jika tidak menggunakan target spesifik.

---

## 3. KONFIGURASI NATIVE PLATFORM

### A. Android (`android/app/build.gradle.kts`)
Mengonfigurasi `flavorDimensions` dan `productFlavors`:
```kotlin
flavorDimensions += "default"

productFlavors {
    create("development") {
        dimension = "default"
        applicationIdSuffix = ".dev"
        resValue("string", "app_name", "Marketplace Dev")
    }
    create("staging") {
        dimension = "default"
        applicationIdSuffix = ".stg"
        resValue("string", "app_name", "Marketplace Staging")
    }
    create("production") {
        dimension = "default"
        resValue("string", "app_name", "Marketplace Enterprise")
    }
}
```
Label aplikasi pada `AndroidManifest.xml` merujuk ke `@string/app_name`.

### B. iOS (`ios/Runner.xcodeproj/xcshareddata/xcschemes/`)
Telah disediakan 3 shared Xcode scheme:
- `development.xcscheme`
- `staging.xcscheme`
- `production.xcscheme`

---

## 4. PERINTAH CLI EKSEKUSI & BUILD

### A. Menjalankan Aplikasi (Debug)
```bash
# Development
flutter run --flavor development -t lib/main_development.dart

# Staging
flutter run --flavor staging -t lib/main_staging.dart

# Production
flutter run --flavor production -t lib/main_production.dart
```

### B. Build Android (APK / App Bundle)
```bash
# Build APK Development
flutter build apk --flavor development -t lib/main_development.dart

# Build APK Staging
flutter build apk --flavor staging -t lib/main_staging.dart

# Build Release AppBundle (AAB) Production
flutter build appbundle --flavor production -t lib/main_production.dart
```

### C. Build iOS (IPA)
```bash
# Build IPA Staging
flutter build ipa --flavor staging -t lib/main_staging.dart

# Build Release IPA Production
flutter build ipa --flavor production -t lib/main_production.dart
```

---

## 5. IDE RUN / DEBUG PRESETS (VS CODE)
Konfigurasi 1-click debugging telah disiapkan di `.vscode/launch.json`. Anda cukup memilih salah satu profil pada tab **Run & Debug**:
1. `Marketplace (Development)`
2. `Marketplace (Staging)`
3. `Marketplace (Production)`

---

## 6. BUILD CONFIGURATION MATRIX (`build.json`)
Matriks spesifikasi build untuk seluruh platform dan environment didefinisikan secara deklaratif di `build.json`.

Untuk melihat seluruh opsi build atau mengeksekusi build melalui CLI otomatis:
```bash
# Daftar seluruh kombinasi build
dart run tool/build.dart --list

# Simulasi (Dry Run) sebelum eksekusi build
dart run tool/build.dart --env=production --platform=android --target=appbundle --dry-run
dart run tool/build.dart --env=staging --platform=ios --dry-run

# Eksekusi langsung
dart run tool/build.dart --env=development --platform=android --target=apk_debug
```
