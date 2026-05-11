# 🤖 AI Agent Prompt — Flutter UI & Architecture Plan
# Sistem Informasi Manajemen Gym (Mobile Apps)

---

## 🎯 CONTEXT & DESIGN SYSTEM

Kamu adalah seorang Senior Flutter Developer, Software Architect, dan Mobile UX Designer. Tugasmu adalah mendesain dan mengimplementasikan UI serta arsitektur lengkap aplikasi **Gym Management Mobile App** menggunakan Flutter dengan **GetX** dan **Get CLI**.

### Design Direction
- **Tema**: Dark luxury fitness — dominan warna gelap (`#0A0F1C`, `#131B2F`) dengan aksen kombinasi biru modern (Electric Blue `#3B82F6` dan Light Blue `#60A5FA`) serta putih bersih.
- **Typografi**: Gunakan `Google Fonts` — `Bebas Neue` untuk heading besar, `DM Sans` untuk body text.
- **Style**: Modern, high-energy, premium gym aesthetic — antarmuka responsif dan dinamis.
- **Corner radius**: Konsisten `16px` untuk card, `12px` untuk input field, `50px` untuk tombol utama (pill shape).
- **Bottom navigation**: 5 tab — Home, Workout, Check-in, Trainer, Profile.

### Color Palette (wajib konsisten di semua halaman)
```dart
// Definisikan di core/theme/app_colors.dart
const Color kBackground    = Color(0xFF0A0F1C); // Deep dark blue background
const Color kSurface       = Color(0xFF131B2F); // Surface color
const Color kSurface2      = Color(0xFF1C2742); // Lighter surface
const Color kAccent        = Color(0xFF3B82F6); // Electric Blue
const Color kAccentDim     = Color(0xFF60A5FA); // Light Blue
const Color kTextPrimary   = Color(0xFFFFFFFF);
const Color kTextSecondary = Color(0xFF94A3B8); // Slate blue-ish gray
const Color kError         = Color(0xFFEF4444);
const Color kSuccess       = Color(0xFF10B981);
const Color kDivider       = Color(0xFF2C3E5D);
```

### Arsitektur & Project Structure (Get CLI Standard)
Aplikasi harus di-generate dan distrukturkan menggunakan **Get CLI** (`get create project`, `get create page:[name]`).
```
lib/
├── app/
│   ├── data/
│   │   ├── models/               // Data models (dummy data)
│   │   └── providers/            // API/Local data providers
│   ├── modules/
│   │   ├── splash/               // Binding, Controller, View
│   │   ├── onboarding/
│   │   ├── auth/                 // Login, Register, Forgot Password
│   │   ├── home/
│   │   ├── membership/
│   │   ├── checkin/
│   │   ├── trainer/
│   │   ├── progress/
│   │   ├── notification/
│   │   ├── support/
│   │   └── profile/
│   └── routes/
│       ├── app_pages.dart        // Daftar GetPage
│       └── app_routes.dart       // Konstanta routing
├── core/
│   ├── theme/
│   │   ├── app_colors.dart
│   │   ├── app_text_styles.dart
│   │   └── app_theme.dart
│   ├── utils/                    // Helper functions
│   └── widgets/                  // Reusable widgets
│       ├── gym_button.dart       // Reusable CTA button
│       ├── gym_card.dart         // Reusable card container
│       ├── gym_text_field.dart   // Custom input field
│       ├── bottom_nav_bar.dart   // Custom bottom navigation
│       └── section_header.dart   // Section title + "Lihat Semua"
└── main.dart
```

---

## 📱 INSTRUKSI DETAIL PER MODUL & HALAMAN

Setiap halaman di bawah ini direpresentasikan sebagai Modul dalam GetX (memiliki `View`, `Controller`, dan `Binding`).

---

### 1. SPLASH SCREEN
**Get CLI**: `get create page:splash`
**View File**: `app/modules/splash/views/splash_view.dart`

**Layout & Logic**:
- Background: `kBackground` penuh.
- Center: Logo gym (icon `FitnessCenter` ukuran 80px, warna `kAccent`) + nama app "GYMFLOW" dalam font `Bebas Neue` ukuran 48px warna putih.
- Tagline: "Train Smarter. Track Better." dalam `DM Sans` 14px warna `kTextSecondary`.
- Loading indicator: LinearProgressIndicator tipis warna `kAccent` di bottom 10% layar.
- Animasi: FadeTransition + ScaleTransition saat masuk (durasi 800ms).
- **Controller**: Setup `Future.delayed` selama 2.5 detik, lalu `Get.offNamed(Routes.ONBOARDING)`.

---

### 2. ONBOARDING SCREEN
**Get CLI**: `get create page:onboarding`
**View File**: `app/modules/onboarding/views/onboarding_view.dart`

**Layout & Logic** (3 halaman PageView):
- **Controller**: Kelola `currentPage` menggunakan `.obs` dan metode untuk pindah halaman.
- Slide 1: Ilustrasi SVG/icon dumbbell + judul "Kelola Membership Mudah" + deskripsi singkat.
- Slide 2: Ilustrasi icon QR/face scan + judul "Check-in Tanpa Antri" + deskripsi.
- Slide 3: Ilustrasi grafik + judul "Pantau Progres Harianmu" + deskripsi.
- Indikator dot di bawah, reaktif terhadap `currentPage`.
- Tombol "Mulai Sekarang" (full-width, pill shape, warna `kAccent`, teks putih/hitam bold) muncul di slide terakhir (routing ke `Routes.LOGIN`).
- Skip button (teks, pojok kanan atas) di slide 1 & 2.

---

### 3. REGISTRASI AKUN (REQ-001)
**Get CLI**: `get create page:register` dalam module auth
**View File**: `app/modules/auth/views/register_view.dart`

**Layout & Logic**:
- **Controller**: Form validation, state visibility password (`.obs`), fungsi register.
- AppBar: Tanpa judul, icon back panah putih, background transparan.
- Heading: "Buat Akun Baru" (`Bebas Neue` 36px) + subtext.
- Form fields (menggunakan `GymTextField`):
  - Nama Lengkap (icon `person_outline`)
  - Email (icon `email_outlined`)
  - Nomor HP (icon `phone_outlined`)
  - Password (icon `lock_outlined`, toggle visibility bind ke controller)
  - Konfirmasi Password
- Tombol "Daftar Sekarang" memanggil fungsi controller dengan indikator loading (`.obs`).
- Footer: "Sudah punya akun? **Masuk**" (`Get.back()` atau `Get.offNamed(Routes.LOGIN)`).

---

### 4. LOGIN SCREEN (REQ-002)
**Get CLI**: `get create page:login`
**View File**: `app/modules/auth/views/login_view.dart`

**Layout & Logic**:
- **Controller**: Handle input, validasi, dan routing ke `Routes.HOME`.
- Background: `kBackground` + subtle diagonal line pattern.
- Heading: "Selamat Datang Kembali 👊" (`Bebas Neue` 32px).
- Form:
  - Email / Nomor HP
  - Password (toggle visibility via controller)
  - Checkbox "Ingat Saya" (reactive boolean) + link "Lupa Password?" ke `Routes.FORGOT_PASSWORD`.
- Tombol "Masuk" (full-width, `kAccent`).
- Divider + Tombol Google Sign-In.
- Footer: "Belum punya akun? **Daftar**".

---

### 5. LUPA PASSWORD (REQ-003)
**View File**: `app/modules/auth/views/forgot_password_view.dart`

**Layout & Logic** (Stepper dikelola di controller dengan `currentStep.obs`):
- **Step 1**: Input email/HP -> Tombol "Kirim Kode OTP".
- **Step 2**: Input OTP (6 kotak, auto-focus next) -> Timer reactive di controller -> Tombol "Verifikasi".
- **Step 3**: Input Password Baru + Konfirmasi -> Tombol "Simpan Password".

---

### 6. HOME / DASHBOARD MEMBER
**Get CLI**: `get create page:home`
**View File**: `app/modules/home/views/home_view.dart`

**Layout & Logic** (ScrollView dengan state reaktif):
- **Controller**: Fetch data dummy user, membership, aktivitas terbaru, dan menu bottom nav.
- **Header**: Avatar member, "Halo, [Nama]", Badge Notifikasi reaktif.
- **Membership Card**: Gradient `kSurface` ke `kSurface2`, border `kAccent`. Progress sisa hari, tombol "Perpanjang".
- **Quick Actions**: Row 4 ikon (Check-in, Trainer, Progress, Chat) yang me-routing ke modul masing-masing.
- **Section "Workout Hari Ini"**: Data dari controller (nama latihan, durasi, set). Empty state ("Booking Trainer").
- **Section "Aktivitas Terbaru"**: List item horizontal dengan GetX `Obx()` list.
- **Bottom Navigation**: Dikelola oleh `MainController` atau `HomeController` untuk pindah tab.

---

### 7. INFORMASI MEMBERSHIP AKTIF (REQ-005)
**Get CLI**: `get create page:membership`
**View File**: `app/modules/membership/views/membership_status_view.dart`

**Layout**:
- AppBar: "Membership Saya".
- **Card Status Utama**: Status badge (Aktif/Tidak Aktif), Progress bar horizontal masa aktif (warna `kAccent`), sisa hari (`Bebas Neue`).
- **Detail Benefit**: List benefit dari data model.
- **Tombol Perpanjang**: Sticky bottom, navigasi ke `Routes.PACKAGES`.

---

### 8. DAFTAR PAKET MEMBERSHIP (REQ-006)
**View File**: `app/modules/membership/views/packages_view.dart`

**Layout**:
- Toggle chip (Harian | Bulanan | Tahunan) dikelola dengan state GetX.
- List card vertikal per paket (render reaktif berdasarkan tipe terpilih).
- Highlight paket "TERPOPULER" dengan border `kAccent`.

---

### 9. PERPANJANGAN MEMBERSHIP (REQ-007)
**View File**: `app/modules/membership/views/renewal_view.dart`

**Layout & Logic**:
- Step-based form menggunakan `Obx()` untuk mengatur view step aktif.
- **Step 1**: Pilih/Konfirmasi paket.
- **Step 2**: Pilih metode pembayaran (Radio list dengan state).
- **Step 3**: Lottie animasi sukses (bounce in), tombol "Kembali ke Home".

---

### 10. FACE RECOGNITION CHECK-IN (REQ-009)
**Get CLI**: `get create page:checkin`
**View File**: `app/modules/checkin/views/face_checkin_view.dart`

**Layout & Logic**:
- Kamera View / Container placeholder abu gelap.
- Overlay UI: Oval guide di tengah layar dengan animasi garis scanning `kAccent`.
- **Controller**: Simulasi delay proses scanning, mengubah state menjadi `success` atau `failed`.
- Feedback UI: Overlay hijau/merah berdasarkan state hasil scanning.

---

### 11. DAFTAR PERSONAL TRAINER (REQ-011)
**Get CLI**: `get create page:trainer`
**View File**: `app/modules/trainer/views/trainer_list_view.dart`

**Layout & Logic**:
- Search bar reaktif (filter list trainer di controller saat mengetik).
- Filter chip row: Semua | Strength | Cardio, dll. (update state di controller).
- Grid view card trainer (Avatar, Nama, Rating, Status ketersediaan).
- Navigasi ke `Routes.TRAINER_DETAIL` dengan membawa parameter ID trainer.

---

### 12. DETAIL TRAINER & BOOKING (REQ-012)
**View File**: `app/modules/trainer/views/trainer_detail_view.dart`

**Layout & Logic**:
- Hero section dengan gambar trainer.
- Info trainer (rating, member, pengalaman), deskripsi (collapsible text widget).
- **Pemilihan Jadwal**: Kalender dan Grid waktu. State pilihan tanggal & waktu disimpan di controller.
- **Bottom Sheet Konfirmasi**: Ditampilkan via `Get.bottomSheet()` sebelum final booking.

---

### 13. PROGRAM & TRACKING LATIHAN (REQ-013 & REQ-014)
**View Files**: `workout_plan_view.dart` dan `workout_tracking_view.dart`

**Layout**:
- **Plan**: Accordion list latihan harian. State checkmark dikelola controller.
- **Tracking**: Timer menggunakan `Stream` di GetxController. Swipe to delete list set, form input rep & beban. Animasi confetti (Lottie) saat selesai via `Get.dialog()` atau overlay.

---

### 14. TRACKING BERAT BADAN & GRAFIK (REQ-015 & REQ-016)
**Get CLI**: `get create page:progress`
**View Files**: `weight_tracking_view.dart`, `progress_chart_view.dart`

**Layout & Logic**:
- **Tracking**: Input berat terbaru, list riwayat dengan indikator tren naik/turun (hitung perbandingan di controller).
- **Grafik**: Menggunakan `fl_chart`. Filter waktu (1W, 1M, 3M) mem-trigger pembaruan list data poin grafik di controller, sehingga UI ter-update reaktif. Garis grafik warna `kAccent`.

---

### 15. NOTIFIKASI MEMBERSHIP (REQ-017)
**Get CLI**: `get create page:notification`
**View File**: `app/modules/notification/views/notifications_view.dart`

**Layout & Logic**:
- Filter notifikasi menggunakan chip (state management).
- Swipe-to-dismiss notifikasi menghapus item dari `.obs` list.
- Aksi "Tandai Semua Dibaca" mem-perbarui status list notifikasi.

---

### 16. CHAT DENGAN ADMIN (REQ-020)
**Get CLI**: `get create page:support`
**View File**: `app/modules/support/views/chat_view.dart`

**Layout & Logic**:
- **Controller**: Mengelola `.obs` list chat messages. ScrollController auto-scroll ke bawah saat ada pesan baru.
- Bubble chat membedakan sender (user vs admin) dengan warna `kAccent` untuk user dan `kSurface2` untuk admin.
- Input bar lengket di bottom layar.

---

### 17. PROFIL MEMBER & EDIT PROFIL (REQ-004)
**Get CLI**: `get create page:profile`
**View Files**: `profile_view.dart`, `edit_profile_view.dart`

**Layout & Logic**:
- Data diri diambil secara reaktif dari `ProfileController`.
- Edit mode memodifikasi field di controller dan melakukan validasi form sebelum simulasi update data.
- Tombol logout memanggil fungsi clear data (misal `GetStorage`) dan redirect `Get.offAllNamed(Routes.LOGIN)`.

---

## ⚙️ INSTRUKSI TEKNIS WAJIB (GETX & GET CLI)

### Dependencies (pubspec.yaml)
```yaml
dependencies:
  flutter:
    sdk: flutter
  get: ^4.6.6             # Wajib untuk State, Route, & Dependency Injection
  google_fonts: ^6.1.0    # Tipografi
  fl_chart: ^0.68.0       # Grafik progres
  table_calendar: ^3.1.0  # Kalender
  cached_network_image: ^3.3.1
  shimmer: ^3.0.0         # Loading animation
  lottie: ^3.1.0          # Animasi sukses/confetti
  intl: ^0.19.0           # Format tanggal/mata uang
```

### Pembuatan Project & Module
Kamu **HARUS** menggunakan struktur folder standar Get CLI. Jika belum ada, asumsikan perintah ini dijalankan:
```bash
get create project:gym_mobile_flutter
get create page:home
get create page:login
# ... dan seterusnya untuk setiap halaman utama
```

### Widget Reusable Wajib Dibuat (`core/widgets/`)

#### `GymButton` (`core/widgets/gym_button.dart`)
```dart
// Menerima parameter `isLoading` (RxBool/bool) untuk menampilkan CircularProgressIndicator
// Primary: filled kAccent, teks putih/hitam
// Secondary: outlined kAccent, teks kAccent
```

#### `GymCard` (`core/widgets/gym_card.dart`)
```dart
// Container dengan background kSurface, borderRadius 16, padding 16
```

#### `GymTextField` (`core/widgets/gym_text_field.dart`)
```dart
// Background kSurface2, border kDivider (focused: kAccent)
```

#### `BottomNavBar` (`core/widgets/bottom_nav_bar.dart`)
```dart
// Custom navigation menggunakan state dari GetX controller utama (misal: MainController)
// Tab Check-in memiliki styling menonjol (FAB style) warna kAccent
```

### State Management & Dependency Injection
- Jangan menggunakan `StatefulWidget` kecuali sangat diperlukan untuk animasi kompleks. Gunakan `GetView` atau `StatelessWidget` dengan `GetBuilder` / `Obx`.
- Variabel reaktif menggunakan `.obs` (misal: `var isLoading = false.obs;`).
- Akses dependency menggunakan `Get.find<ControllerName>()`.
- Setiap view harus sesederhana mungkin, pindahkan semua logika bisnis, validasi, dan fetch data ke `GetxController` di dalam folder `controllers`.

### Aksesibilitas & Responsivitas
- Manfaatkan `Get.width` dan `Get.height` atau fitur responsif bawaan GetX (seperti `context.isPhone`) untuk mengatur ukuran secara proporsional.
- Contrast ratio teks memadai.

---

## 📋 URUTAN IMPLEMENTASI & EXECUTION PLAN

1. **Setup Project (Get CLI)**: Inisialisasi struktur `app/` dan `core/`. Setup theme, warna (Kombinasi Biru), font, dan main routing.
2. **Core Widgets**: Buat `GymButton`, `GymCard`, `GymTextField`, `BottomNavBar`.
3. **Module Auth**: Implementasikan Splash, Onboarding, Login, Register, Forgot Password beserta controllernya.
4. **Module Main/Home**: Setup shell bottom navigation controller dan dashboard Home.
5. **Module Trainer & Progress**: Implementasikan pencarian trainer, kalender booking, dan fl_chart tracking.
6. **Module Membership & Check-in**: Tampilan paket, UI simulasi scan wajah.
7. **Module Support & Profile**: Chat UI, form edit profil reaktif.

---

## ✅ CHECKLIST KUALITAS PER HALAMAN

Sebelum finalisasi setiap halaman, pastikan:
- [ ] Warna sesuai design system baru (Warna dasar gelap + Aksen Biru).
- [ ] Struktur folder strictly mengikuti pola **Get CLI** (`app/modules`, `app/routes`).
- [ ] Tidak ada logic berat di UI, semuanya didelegasikan ke `GetxController`.
- [ ] Penggunaan `Obx()` / `GetBuilder()` sudah tepat dan optimal.
- [ ] Routing menggunakan `Get.toNamed()`, `Get.offNamed()`, dll.
- [ ] Semua dummy data dikelola di provider / controller, bukan di hardcode di view.
- [ ] Tampilan konsisten dan menggunakan komponen reusable dari `core/widgets/`.

---

*Prompt ini mencakup requirement PRD Sistem Informasi Manajemen Gym untuk Mobile Apps. Eksekusi kode secara modular per fitur menggunakan GetX pattern agar struktur kode rapi, scalable, dan maintainable.*
