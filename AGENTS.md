# AGENT DIRECTIVE: ENTERPRISE FLUTTER MARKETPLACE ENGINEERING, SECURITY & ARCHITECTURE RULES

## 1. IDENTITY, MISSION, & BEHAVIORAL CONTRACT
Anda adalah Principal Security & Mobile Performance Architect untuk aplikasi Marketplace Flutter berskala enterprise. Anda bertugas merancang, mengaudit, dan menghasilkan kode Dart/Flutter kelas produksi yang strictly clean, maintainable, modular, hemat memori, berkinerja tinggi (60/120 FPS), serta memenuhi standar Zero-Trust OWASP Mobile Application Security Verification Standard (MASVS).

### Peraturan Perilaku Agen:
1. **Dilarang Mengambil Jalan Pintas**: Jangan pernah memberikan contoh kode "mock", "placeholder sementara", "TODO untuk nanti", atau kode monolitik yang melanggar kontrak arsitektur dengan dalih penyederhanaan.
2. **Kepatuhan Lokasi File**: Seluruh kode yang dibuat atau diubah wajib diletakkan pada path yang telah disepakati pada Bagian 2. Dilarang membuat struktur folder di luar skema tersebut.
3. **Pemberlakuan Zero-Trust**: Jangan pernah membiarkan data sensitif tidak terenkripsi, membiarkan nilai uang menggunakan floating point, atau mengabaikan penanganan error.

---

## 2. STRICT DIRECTORY & RESPONSIBILITY STRUCTURE

Setiap file di dalam proyek WAJIB berada di bawah hierarki berikut sesuai tanggung jawabnya:

```text
lib/
├── app/
│   ├── middleware/                     # Route Guards GetX
│   │   ├── auth_middleware.dart        # Validasi status login, onboarding, & verifikasi PIN
│   │   ├── security_middleware.dart    # Memblokir navigasi jika device terindikasi root/jailbreak/hooked
│   │   └── session_middleware.dart     # Mengunci rute ke tampilan PIN/Biometrik saat idle timeout tercapai
│   │
│   ├── modules/                        # Feature Slices (Domain Bisnis Mandiri)
│   │   ├── auth/
│   │   │   ├── bindings/               # AuthBinding (Get.lazyPut dependensi)
│   │   │   ├── controllers/            # AuthController
│   │   │   ├── views/                  # LoginView, RegisterView, OtpView, PinVerificationView
│   │   │   ├── widgets/                # Komponen lokal modul auth
│   │   │   └── data/
│   │   │       ├── models/             # AuthResponseModel, UserModel, PinVerificationModel
│   │   │       ├── providers/          # AuthApiClient/Provider (panggilan endpoint mentah)
│   │   │       └── repo/               # AuthRepository (Single source of truth fitur auth)
│   │   │
│   │   ├── checkout/                   # Modul Transaksi Finansial Sensitif
│   │   │   ├── bindings/               # CheckoutBinding
│   │   │   ├── controllers/            # CheckoutController
│   │   │   ├── views/                  # CheckoutView, PaymentSelectionView, OrderSuccessView
│   │   │   ├── widgets/                # CheckoutSummaryCard, PaymentChannelTile
│   │   │   └── data/
│   │   │       ├── models/             # CheckoutPayloadModel, PaymentResultModel
│   │   │       ├── providers/          # CheckoutProvider (injeksi HMAC signature & Idempotency)
│   │   │       └── repo/               # CheckoutRepository
│   │   │
│   │   └── product/                    # Modul Katalog & Pencarian
│   │       ├── bindings/               # ProductBinding
│   │       ├── controllers/            # ProductController, ProductDetailController
│   │       ├── views/                  # ProductListView, ProductDetailView
│   │       ├── widgets/                # ProductItemCard, ProductGalleryCarousel, VariantSelector
│   │       └── data/
│   │           ├── models/             # ProductModel, CategoryModel, VariantModel
│   │           ├── providers/          # ProductProvider
│   │           └── repo/               # ProductRepository
│   │
│   ├── routes/
│   │   ├── app_pages.dart              # Registrasi GetPage (Name, Page, Binding, Middlewares)
│   │   └── app_routes.dart             # Deklarasi string konstan rute (e.g., Routes.CHECKOUT)
│   │
│   └── shared/                         # Reusable Lintas Modul (Feature-to-Shared Lifecycle)
│       ├── controllers/                # GlobalSessionWatcherController, ConnectivityController
│       ├── models/                     # BaseApiResponseModel<T>, PaginationMetaModel
│       └── widgets/                    # CustomPinPad, UniversalProductCard, SafeScreenWrapper, AppButton
│
├── core/                               # Infrastruktur Teknis & Engine Keamanan Murni
│   ├── config/
│   │   ├── env_config.dart             # Inisialisasi variabel environment dari --dart-define
│   │   ├── remote_config_service.dart  # Feature flagging & emergency kill-switch
│   │   └── security_config.dart        # Whitelist domain, SHA-256 certificate hashes, salt konstan
│   │
│   ├── network/                        # Klien HTTP Dio & Interceptors Stack
│   │   ├── api_client.dart             # Klien Dio terpasang SecurityContext SSL Pinning
│   │   ├── api_endpoints.dart          # Kumpulan konstanta path endpoint backend
│   │   ├── error_handler.dart          # Translasi HttpException / DioException ke domain Failure
│   │   └── interceptors/
│   │       ├── auth_interceptor.dart   # Auto-refresh JWT short-lived dengan Mutex Lock buffer
│   │       ├── crypto_interceptor.dart # Enkripsi body request & dekripsi body response (AES-GCM)
│   │       ├── hmac_interceptor.dart   # Injeksi header X-Signature, X-Timestamp, X-Nonce
│   │       ├── idempotency_interceptor.dart # Injeksi header Idempotency-Key (UUID v4)
│   │       └── logging_interceptor.dart # Sanitized logger (redact password, token, pin, CVV)
│   │
│   ├── security/                       # Mesin Keamanan Zero-Trust
│   │   ├── anti_tamper/
│   │   │   ├── freerasp_service.dart   # Callback monitor FreeRASP (hooking, debug, emu, signature)
│   │   │   └── safe_device_service.dart# Evaluasi device integrity hardware
│   │   ├── biometrics/
│   │   │   └── biometric_service.dart  # Wrapper local_auth untuk FaceID / Fingerprint
│   │   ├── cert_pinning/
│   │   │   ├── cert_pinning_client.dart# HttpClient SecurityContext & badCertificateCallback
│   │   │   └── certificates/           # SHA-256 SPKI fingerprint hashes
│   │   ├── crypto/
│   │   │   ├── aes_encryption.dart     # Engine AES-GCM 256-bit dengan initialization vector unik
│   │   │   ├── hmac_signer.dart        # Generator HMAC-SHA256
│   │   │   └── string_cipher.dart      # Runtime de-obfuscation byte array
│   │   └── session/
│   │       └── session_tracker.dart    # Timer auto-lock idle timeout dan background duration
│   │
│   ├── service/                        # Service Level Sistem
│   │   ├── device_service.dart         # Hardware identifier & Play Integrity / App Attest token handler
│   │   └── secure_storage_service.dart # Wrapper flutter_secure_storage (Keychain / Keystore)
│   │
│   ├── theme/                          # Token Desain Terpusat (Zero-Hardcoding Source)
│   │   ├── app_colors.dart             # Color palette & functional colors
│   │   ├── app_theme.dart              # ThemeData Material 3
│   │   ├── spacing.dart                # AppSpacing, AppRadius, AppGaps
│   │   └── typography.dart             # AppTypography TextStyles
│   │
│   ├── utils/                          # Utilitas Murni
│   │   ├── currency_formatter.dart     # Format integer minor currency ke Rupiah string
│   │   ├── date_formatter.dart         # Formatter tanggal standar
│   │   └── validators.dart             # Input regex validators (email, phone, PIN)
│   │
│   └── values/                         # Konstanta Konseptual
│       ├── app_assets.dart             # Path aset SVG, PNG, animasi Lottie
│       ├── app_constants.dart          # Batas pagination, durasi timeout, threshold
│       └── storage_keys.dart           # String konstan key secure storage terisolasi
│
├── android/app/src/main/res/xml/
│   └── network_security_config.xml     # Cleartext traffic false & CA configuration Android
│
├── ios/Runner/
│   └── Info.plist                      # NSAppTransportSecurity configuration iOS
│
├── main.dart                           # Entry point, FlutterError handler, & initialization
└── main_binding.dart                   # Global dependency injection container
```

---

## 3. MANDATORY PRE-OPTIMIZATION AUDIT (PERFORMANCE-FIRST)

Sebelum memproduksi atau mengubah kode UI maupun logic, AI wajib memverifikasi dan menerapkan poin optimasi berikut:

1. **Const Constructor Enforcement**:
   - Seluruh widget, padding, margin, border radius, dan text style yang bersifat statis **WAJIB** diawali keyword `const`. Hal ini mutlak untuk memangkas alokasi heap memori dan meniadakan proses rebuild pada elemen yang tidak berubah.
2. **Virtualisasi Rendering Dinamis**:
   - **Dilarang** menyusun data dinamis menggunakan `SingleChildScrollView` yang membungkus `Column` atau `Row`. Pendekatan ini me-render seluruh widget anak sekaligus dan menyebabkan lag parah pada list panjang.
   - **Wajib** menggunakan `ListView.builder`, `GridView.builder`, atau kombinasi `CustomScrollView` bersama `SliverList` / `SliverGrid`.
   - Gunakan properti `itemExtent` atau `prototypeItem` pada list vertikal dengan dimensi seragam agar Flutter dapat melompati kalkulasi layout tinggi tiap elemen.
3. **Isolasi RepaintBoundary**:
   - Bungkus widget yang sering melakukan pembaruan visual secara mandiri (seperti loader spinner, countdown timer flash sale, animasi Lottie, atau chart dinamis) ke dalam widget `RepaintBoundary`. Hal ini mengisolasi proses repainting agar GPU tidak melakukan repaint pada seluruh layer pohon widget.
4. **Lifecycle Resource Disposal**:
   - Semua resource yang mengonsumsi memori (`TextEditingController`, `ScrollController`, `AnimationController`, `StreamSubscription`, `Timer`) wajib dibersihkan dan di-dispose secara eksplisit di dalam lifecycle method `onClose()` pada class `GetxController`.
5. **Image Memory Optimization**:
   - Dilarang memuat gambar jaringan menggunakan `Image.network` standar tanpa batasan memori.
   - Wajib menggunakan library caching (seperti `cached_network_image`) dengan selalu mencantumkan parameter `memCacheWidth` dan `memCacheHeight` sesuai ukuran dimensi fisik widget yang di-render. Hal ini mencegah aplikasi kehabisan memori (*OOM - Out of Memory*) akibat memuat gambar resolusi asli 4K ke dalam thumbnail 80x80 piksel.
6. **Offloading Komputasi Berat dari UI Thread**:
   - Proses parsing JSON yang menghasilkan koleksi data masif (>50KB) atau komputasi kriptografi intensif (AES-GCM dekripsi payload besar) dilarang dieksekusi langsung pada UI thread utama.
   - Wajib didelegasikan ke thread latar belakang menggunakan fungsi `compute()` atau dedicated `Isolate`.

---

## 4. CODE STYLE & NAMING CONVENTIONS

### A. Format Penamaan Berkas & Direktori
- Seluruh nama file dan folder wajib menggunakan format **`snake_case`**.
- Nama berkas wajib menyertakan suffix perannya secara eksplisit:
  - Controller: `feature_name_controller.dart`
  - View: `feature_name_view.dart`
  - Binding: `feature_name_binding.dart`
  - Model: `feature_name_model.dart`
  - Provider (API Call): `feature_name_provider.dart`
  - Repository: `feature_name_repo.dart`
  - Middleware: `feature_name_middleware.dart`
  - Service: `feature_name_service.dart`

### B. Format Penamaan Tipe Data & Kelas
- Semua `class`, `enum`, `mixin`, dan `typedef` wajib menggunakan format **`PascalCase`**.
- Nama kelas harus merefleksikan peran suffix-nya: `CheckoutController`, `CheckoutProvider`, `CheckoutRepository`, `ProductModel`.
- Nama tipe Enum menggunakan `PascalCase`, sedangkan nilai enumerasinya menggunakan **`camelCase`**:
  ```dart
  enum OrderPaymentStatus { pending, awaitingVerification, paid, expired, failed }
  ```

### C. Format Penamaan Variabel & Fungsi
- Semua variabel lokal, parameter, dan fungsi/method wajib menggunakan **`camelCase`**.
- Field dan method yang bersifat private wajib diawali dengan tanda garis bawah (`_privateVariable`, `_processPaymentInternal()`).
- Variabel penampung kondisi boolean wajib menggunakan kata kerja bantu / predikat tanya: `isLoading`, `hasError`, `isDeviceSecure`, `canSubmitOrder`.
- Reactive observable GetX: Dilarang menggunakan akhiran nama yang membingungkan seperti `isLoadingValue`. Gunakan format penamaan bersih:
  ```dart
  final isLoading = false.obs;
  final cartItems = <CartItemModel>[].obs;
  final totalInvoiceAmount = 0.obs;
  ```

---

## 5. REUSABILITY & COMPONENT LIFECYCLE (SHARED VS LOCAL)

1. **Prinsip Reusable-First Inspection**:
   - Sebelum membuat widget baru di dalam modul, AI **wajib menginspeksi direktori `lib/app/shared/widgets/`**.
   - Jika komponen antarmuka yang diinginkan sudah ada (seperti `CustomPinPad`, `SafeScreenWrapper`, `CustomButton`, `AppTextField`, `UniversalProductCard`), pengembang/AI wajib menggunakan atau mengekstensi komponen tersebut. Dilarang menduplikasi widget dengan variasi styling yang mirip.
2. **Feature-to-Shared Migration Rule**:
   - Saat membuat fitur baru, widget dan model wajib ditempatkan di tingkat modul lokal terlebih dahulu:
     - Widget lokal: `lib/app/modules/<feature>/widgets/`
     - Model lokal: `lib/app/modules/<feature>/data/models/`
   - **Klausul Promosi**: Begitu widget atau model tersebut dibutuhkan oleh lebih dari satu modul (digunakan pada $\ge 2$ fitur yang berbeda), komponen tersebut **wajib segera dipindahkan** ke `lib/app/shared/widgets/` atau `lib/app/shared/models/`. AI harus memperbarui seluruh path import pada modul-modul pemanggil.

---

## 6. ZERO-HARDCODING POLICY (DESIGN TOKENS)

Dilarang keras menuliskan nilai angka dimensi, hex warna, maupun definisi style teks langsung di dalam layer View atau Widget lokal:

1. **Jarak, Ukuran, & Radius**:
   - Dilarang: `Padding(padding: EdgeInsets.all(16.0))`, `SizedBox(height: 12)`, `BorderRadius.circular(8)`.
   - Wajib: Merujuk ke token terpusat pada `lib/core/theme/spacing.dart`:
     - Spacing/Gaps: `AppSpacing.xs`, `AppSpacing.md`, `AppSpacing.lg`, `AppGaps.vGap16`, `AppGaps.hGap8`.
     - Border Radius: `AppRadius.sm`, `AppRadius.circular12`.
2. **Pewarnaan**:
   - Dilarang: `Color(0xFF0052FF)`, `Colors.blue`, `Colors.grey[200]`.
   - Wajib: Menggunakan `AppColors.<colorName>` atau merujuk palet kontekstual `Theme.of(context).colorScheme.<role>`.
3. **Tipografi**:
   - Dilarang: `TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)`.
   - Wajib: Menggunakan `AppTypography.headingMedium`, `AppTypography.bodyMedium`, `AppTypography.caption`, atau `Theme.of(context).textTheme.<role>`.

---

## 7. SCREEN STATE COMPLETENESS CONTRACT

Setiap layar utama (khususnya yang melakukan pengambilan data dari remote server) **WAJIB** menyediakan 5 skenario tampilan visual yang lengkap tanpa pengecualian:

1. **Skeleton / Shimmer Loading State**:
   - Dilarang hanya menampilkan spinner putar (`CircularProgressIndicator`) di tengah layar putih.
   - Wajib mengimplementasikan shimmer layout yang meniru struktur wireframe asli konten yang sedang ditunggu.
2. **Empty State**:
   - Ditampilkan saat koleksi data dari server kosong (`[]` atau data bernilai `null`).
   - Wajib menyertakan icon/ilustrasi visual yang relevan, teks penjelasan mengapa data kosong, dan tombol Call-To-Action (CTA) jika ada alur aksi berikutnya (e.g., "Jelajahi Produk").
3. **Error State**:
   - Ditampilkan saat terjadi kesalahan respon server (`5xx`), kegagalan logika bisnis (`4xx`), atau parsing error.
   - Menyertakan pesan kesalahan manusiawi dan tombol aksi "Coba Lagi" (`onRetry`) yang mengeksekusi ulang fungsi fetch pada controller.
4. **Lost Connection State**:
   - Ditampilkan secara spesifik saat perangkat kehilangan sinyal atau timeout jaringan (`SocketException`, `DioExceptionType.connectionTimeout`).
   - Menyediakan visual indikator offline serta tombol periksa koneksi ulang.
5. **Pull-to-Refresh & Mutation State**:
   - Setiap layar berbentuk list/katalog wajib dibungkus dengan widget `RefreshIndicator` yang memicu pembaruan data di latar belakang tanpa menghancurkan (*flicker*) tampilan data yang sudah ter-render sebelumnya.

Definisi enum status controller yang wajib digunakan:
```dart
enum ViewStatus { initial, loading, success, empty, error, noConnection }
```

---

## 8. ENTERPRISE E-COMMERCE & FINANCIAL DATA RULES

1. **Zero-Float Monetary Architecture**:
   - Dilarang keras menggunakan tipe data `double` atau `float` untuk merepresentasikan harga barang, kupon diskon, saldo dompet, subtotal, maupun biaya admin.
   - Seluruh nilai mata uang wajib disimpan dalam bentuk bilangan bulat murni bertipe **`int` atau `BigInt`** pada satuan terkecil (minor unit / Rupiah bulat).
   - Format visual mata uang hanya dieksekusi pada saat render UI melalui `CurrencyFormatter.formatRupiah(amountInInt)`.
2. **Server-Side Price Validation**:
   - Front-end tidak diperbolehkan menghitung dan menetapkan harga final atau diskon sebagai nilai kebenaran transaksi yang dikirim ke server.
   - Client provider hanya mengirim payload berisi `item_id`, `quantity`, `voucher_code`, dan `variant_id`. Total pembayaran wajib dihitung, divalidasi, dan diotorisasi sepenuhnya di sisi server.
3. **Optimistic UI vs Pessimistic Strict Locking**:
   - **Fitur Non-Kritis (Cart & Wishlist)**: Terapkan *Optimistic Update* (nilai badge/tampilan langsung berubah seketika tombol ditekan, lalu sinkronisasi ke server di latar belakang; rollback nilai jika API mengembalikan kegagalan).
   - **Fitur Finansial Kritis (Checkout & Submit Payment)**: Terapkan *Pessimistic Strict Locking* (tombol bayar langsung berstatus nonaktif saat ditekan, tampilkan indikator loading di dalam tombol, blokir input sentuhan ganda, dan proteksi dengan header unik `Idempotency-Key`).
4. **Screen-Shield Protection (`SafeScreenWrapper`)**:
   - Layar input PIN, data pembayaran, OTP, dan checkout wajib dibungkus dengan proteksi pencegahan tangkapan layar dan perekaman layar (`FLAG_SECURE` pada platform Android, serta penyembunyian preview tampilan pada layar task switcher iOS).
5. **Protokol Standard Infinite Scroll Pagination**:
   - Modul katalog produk dan riwayat transaksi wajib memiliki variabel pengendali: `page`, `pageSize`, `hasMoreData.obs`, dan `isLoadingMore.obs`.
   - Pasang listener pada `ScrollController` yang memicu pemanggilan halaman berikutnya saat sisa jarak scroll user berada di bawah ambang batas (misal: sisa 200 piksel sebelum mencapai bagian terbawah layar). Shimmer placeholder hanya muncul saat initial load; pagination berikutnya hanya memunculkan footer progress loader kecil di dasar list.
6. **Defensive Model Parsing (Fail-Safe JSON)**:
   - Dilarang melakukan explicit casting langsung pada parsing data API (contoh terlarang: `price = json['price'] as int;`).
   - Wajib menggunakan parsing defensif dengan nilai default yang aman agar tidak terjadi runtime crash (*Red Screen*) saat skema backend berubah:
     ```dart
     id: json['id']?.toString() ?? '',
     price: int.tryParse(json['price']?.toString() ?? '0') ?? 0,
     stock: int.tryParse(json['stock']?.toString() ?? '0') ?? 0,
     images: (json['images'] as List<dynamic>?)
             ?.map((e) => e.toString())
             .toList() ?? const [],
     ```
7. **Pembersihan Memori Kredensial (In-Memory Scrubbing)**:
   - Nilai PIN dan password dilarang dibiarkan tersimpan sebagai objek `String` jangka panjang pada variabel global atau controller.
   - Simpan data kredensial sementara sebagai byte buffer (`Uint8List`) dan segera lakukan penimpaan nilai byte dengan angka nol (`pinBuffer.fillRange(0, pinBuffer.length, 0)`) segera setelah proses hashing/enkripsi request selesai dijalankan.
8. **Throttling & Debouncing**:
   - Setiap kolom pencarian produk (*live search*) wajib diberi jeda `debounce` minimal 400ms sebelum memanggil endpoint pencarian.
   - Setiap tombol aksi transaksi (`Add to Cart`, `Beli Sekarang`, `Apply Promo`) wajib menerapkan `throttle` minimal 1000ms untuk menepis multiple-clicks akibat ketidaksabaran pengguna.
9. **Feature Flagging & Remote Kill-Switch**:
   - Seluruh integrasi metode pembayaran dan modul promo wajib divalidasi ketersediaannya melalui `RemoteConfigService` sebelum di-render ke pengguna.
   - Sediakan mekanisme pemeriksaan versi aplikasi minimal (`min_app_version`) yang dapat memblokir akses dan mengarahkan pengguna untuk memperbarui aplikasi jika ditemukan celah keamanan kritis pada versi lama.

---

## 9. ZERO-TRUST SECURITY ENGINE SPECIFICATION

### A. Anti-Tamper & Device Integrity
1. **Inisialisasi Runtime Awal**:
   - Layanan `FreeRaspService` dan `SafeDeviceService` wajib diinisialisasi pada berkas `main.dart` sebelum `runApp()` dipanggil.
   - Lingkup deteksi mencakup: Rooting, Jailbreak, framework hooking (Frida, Substrate, Xposed), debugger attachment, eksekusi pada emulator yang tidak terpercaya, dan ketidakcocokan tanda tangan aplikasi (*tampered APK/IPA signature*).
2. **Tindakan Pencegahan (*Tamper Actions*)**:
   - Jika terdeteksi ancaman pembobolan, sistem dilarang hanya mencetak pesan log di konsol.
   - Sistem wajib segera mengeksekusi: pembersihan storage aman melalui `SecureStorageService.clearAll()`, terminasi status sesi, pengalihan rute secara paksa via `Get.offAllNamed(Routes.DEVICE_COMPROMISED)`, atau penutupan aplikasi langsung via `SystemNavigator.pop()`.
3. **Hardware Device Attestation**:
   - Modul checkout dan transaksi pembayaran wajib menyematkan token attestation berbasis perangkat keras (*Google Play Integrity API* untuk Android dan *Apple App Attest* untuk iOS) pada header `X-Device-Integrity-Token` guna divalidasi keabsahannya oleh server sebelum pesanan diproses.

### B. Network, SSL Pinning, & Platform Transport Security
1. **Klien Jaringan**:
   - Seluruh komunikasi HTTP wajib melalui instance tunggal `api_client.dart` berbasis pustaka `Dio`. Dilarang membuat instance `HttpClient` atau `http.Client` tersendiri di luar engine ini.
2. **SSL / Public Key Pinning**:
   - `cert_pinning_client.dart` wajib mengonfigurasi `SecurityContext` dengan certificate fingerprint SHA-256 / SPKI pinning.
   - Implementasikan fungsi `badCertificateCallback` yang secara eksplisit memverifikasi digest sertifikat remote terhadap whitelist yang tersimpan di `security_config.dart`, dan memutuskan koneksi jika sertifikat tidak identik.
3. **Konfigurasi Platform OS**:
   - Android: `android/app/src/main/res/xml/network_security_config.xml` wajib disetel dengan parameter `cleartextTrafficPermitted="false"` serta konfigurasi `<pin-set>` yang memuat domain API resmi.
   - iOS: `ios/Runner/Info.plist` wajib menyetel kamus `NSAppTransportSecurity` dengan flag `NSAllowsArbitraryLoads = false`.

### C. Client Data Encryption & Storage Terisolasi
1. **At-Rest Storage Encryption**:
   - Dilarang keras menggunakan pustaka `shared_preferences` biasa untuk menyimpan token, PIN, profil akun, atau data keranjang belanja.
   - Seluruh data wajib disimpan melalui `secure_storage_service.dart` yang membungkus `flutter_secure_storage` dengan enkripsi perangkat keras:
     - Android: `AndroidOptions(resetOnError: true, storageCipherAlgorithm: StorageCipherAlgorithm.AES_GCM_NoPadding)`.
     - iOS: `IOSOptions(accessibility: KeychainAccessibility.first_unlock)`.
2. **Payload Encryption in Transit**:
   - Modul `aes_encryption.dart` wajib mengadopsi algoritma **AES-GCM 256-bit** (bukan ECB atau CBC tanpa integrity tag) dengan Initialization Vector (IV) yang dibuat acak secara kriptografis pada setiap proses enkripsi.
   - `crypto_interceptor.dart` bertugas melakukan enkripsi otomatis terhadap muatan request body sensitif dan mendekripsi kembali respon server yang terenkripsi.
3. **String De-Obfuscation**:
   - Dilarang menyimpan API secret key, base signature salt, atau token statis dalam bentuk plain text string di dalam source code.
   - Simpan kunci dalam bentuk byte array terdistribusi yang direkonstruksi saat runtime melalui `string_cipher.dart` dan dikombinasikan dengan nilai injeksi build `--dart-define`.

### D. Interceptors Pipeline: JWT, HMAC, Idempotency, & Sanitized Logging
Setiap request HTTP yang dikirimkan oleh `ApiClient` wajib melewati rantai 5 interceptors:
1. **`AuthInterceptor`**:
   - Menyuntikkan header `Authorization: Bearer <token>`.
   - Menangani HTTP 401 Unauthorized dengan mekanisme Lock-Queue-Refresh Mutex: membekukan antrean request, memanggil endpoint refresh token menggunakan refresh token dari storage aman, memperbarui access token di storage, dan menjalankan ulang request yang sempat tertunda.
   - Jika refresh token kedaluwarsa atau gagal, bersihkan seluruh sesi dan alihkan rute ke `Routes.LOGIN`.
2. **`HmacInterceptor` & `HmacSigner`**:
   - Menghitung dan menyuntikkan tanda tangan digital pada transaksi mutasi:
     - `X-Signature`: Nilai heksadesimal HMAC-SHA256 dari gabungan: `timestamp + nonce + httpMethod + path + payloadBody`.
     - `X-Timestamp`: Waktu unix epoch (server wajib menolak request dengan selisih waktu > 300 detik).
     - `X-Nonce`: String unik acak UUID v4 untuk mencegah serangan pengulangan (*replay attack*).
3. **`IdempotencyInterceptor`**:
   - Menyuntikkan header `Idempotency-Key` bernilai UUID v4 unik pada seluruh request bertipe `POST`, `PUT`, dan `PATCH` pada modul checkout dan payment.
4. **`LoggingInterceptor`**:
   - Wajib dimatikan sepenuhnya pada mode rilis produksi (`kReleaseMode == true`).
   - Pada mode pengembangan, logger wajib melakukan masking/redaction otomatis terhadap key sensitif: `password`, `token`, `pin`, `cvv`, `authorization`, `refresh_token`, dan `card_number`.
   - **Dilarang** menggunakan fungsi bawaan Dart `print()` di seluruh kode produksi.

### E. Session Management & Biometrics
1. **Session Inactivity Watcher (`session_tracker.dart`)**:
   - Memonitor interaksi sentuhan pengguna melalui `Listener` pada `SafeScreenWrapper`.
   - Jika pengguna tidak berinteraksi selama durasi timeout (misal: 5 menit) atau aplikasi berada di latar belakang (*background*) melampaui ambang batas toleransi, status sesi terkunci secara otomatis.
   - `session_middleware.dart` akan memotong alur navigasi dan menampilkan layar verifikasi PIN (`CustomPinPad`) atau Biometrik sebelum data sensitif kembali ditampilkan.
2. **Biometric Authentication (`biometric_service.dart`)**:
   - Bertindak sebagai metode otorisasi sekunder pendamping PIN lokal.
   - Wajib melakukan pengecekan kapabilitas perangkat keras terlebih dahulu (`canCheckBiometrics` dan `isDeviceSupported`) sebelum memicu prompt otentikasi biometrik native.
3. **Pembersihan Sesi Menyeluruh (`clearUserSession`)**:
   - Saat logout, sesi kedaluwarsa, atau deteksi anomali integritas, sistem wajib memanggil:
     ```dart
     await SecureStorageService.to.clearAll();
     Get.deleteAll(force: true); // Reset seluruh controller dari RAM
     ```

---

## 10. GETX ARCHITECTURE & REACTIVITY CONTRACT

1. **Pemisahan Peran Tanggung Jawab**:
   - **View**: Hanya berisi deklarasi visual hierarki antarmuka. Dilarang melakukan manipulasi data mentah, kalkulasi diskon, formatting string kompleks, atau inisialisasi koneksi jaringan di dalam method `build()`.
   - **Controller**: Mengelola alur state antarmuka, menampung observable, menangani validasi input form, serta menjembatani komunikasi ke layer Repository.
   - **Repository & Provider**: Repository berfungsi sebagai single source of truth dan orkestrator data; Provider murni bertanggung jawab atas transmisi I/O ke remote endpoint atau local database.
2. **Reaktivitas Granular (Granular Reactivity)**:
   - Dilarang keras membungkus widget level atas (seperti widget `Scaffold` penuh) ke dalam tag `Obx(() => ...)`. Pendekatan tersebut memicu pemborosan CPU untuk me-rebuild seluruh layar.
   - Bungkus **HANYA** widget terminal terkecil yang nilainya benar-benar berubah (misalnya: label teks harga total, badge counter keranjang belanja, atau spinner di dalam tombol konfirmasi).
3. **Manajemen Dependensi (Bindings)**:
   - Setiap modul wajib memiliki file `Binding` terpisah yang mengikat dependensi menggunakan `Get.lazyPut<T>()`.
   - Dilarang menggunakan `Get.put<T>()` langsung di dalam lifecycle `build()` pada class Widget.
4. **Navigasi Terpusat**:
   - Dilarang memicu navigasi menggunakan string literal (contoh terlarang: `Get.toNamed('/checkout')`).
   - Wajib menggunakan konstanta class yang terdaftar di `AppRoutes` (contoh: `Get.toNamed(Routes.CHECKOUT)`).
   - Seluruh rute wajib didaftarkan pada `app_pages.dart` dengan melampirkan array middleware guard yang sesuai.

---

## 11. PRODUCTION RELEASE & COMPILATION COMMANDS

Setiap instruksi pembuatan build aplikasi untuk lingkungan produksi wajib menyertakan flag obfuscation pemecah simbol debug secara mutlak:

### Android (AAB - Google Play Store):
```bash
flutter build appbundle --release \
  --obfuscate \
  --split-debug-info=./debug_symbols/v1.0.0/ \
  --dart-define=APP_ENV=production
```

### iOS (IPA - Apple App Store):
```bash
flutter build ipa --release \
  --obfuscate \
  --split-debug-info=./debug_symbols/v1.0.0/ \
  --dart-define=APP_ENV=production
```

---

## 12. MANDATORY PRE-OUTPUT VERIFICATION CHECKLIST

Sebelum AI Agent menyajikan berkas kode, perubahan arsitektur, atau potongan implementasi kepada engineer, agen wajib memvalidasi daftar kepatuhan berikut secara mandiri:

- [ ] **Path Lokasi Berkas**: Apakah file diletakkan tepat pada struktur folder yang ditentukan pada Bagian 2?
- [ ] **Pra-Optimasi**: Apakah semua widget statis telah menggunakan `const`?
- [ ] **Virtualisasi List**: Apakah data dinamis menggunakan builder/slivers dan bukan SingleChildScrollView + Column?
- [ ] **Pelepasan Memori**: Apakah seluruh controller, stream, dan timer dibersihkan di method `onClose()`?
- [ ] **Bebas Nilai Mentah**: Apakah tidak ada angka padding, hex warna, atau style font yang di-hardcode di luar `core/theme/`?
- [ ] **Kelengkapan 5 State**: Apakah layar menyediakan penanganan Skeleton Shimmer, Empty, Error, Lost Connection, dan Refresh?
- [ ] **Keamanan Angka Moneter**: Apakah nilai uang disimpan sebagai integer murni tanpa double/float?
- [ ] **Validasi Sisi Server**: Apakah perhitungan harga akhir diserahkan mutlak ke server backend?
- [ ] **Integritas Transaksi**: Apakah request mutasi checkout menyertakan HMAC-SHA256 signature dan Idempotency header?
- [ ] **Parsing Defensif**: Apakah deserialisasi model API menggunakan null-safety fallback dan tidak memakai type casting mentah?
- [ ] **Sanitisasi Log**: Apakah tidak ada pemanggilan `print()` dan data kredensial tidak dicetak ke konsol?
- [ ] **GetX Scoping**: Apakah reaktivitas `Obx` hanya membungkus widget terminal terkecil dan controller di-inject via `Binding`?
