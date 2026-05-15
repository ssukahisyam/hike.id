# Development Guide — Hike.id

Panduan singkat untuk menjalankan, mengembangkan, dan build app secara lokal.

## Prasyarat

- **Flutter** stable channel `^3.22` ([install guide](https://docs.flutter.dev/get-started/install))
- **JDK 17** (wajib untuk Android Gradle Plugin 8.x)
- **Android SDK** dengan Android 14 (API 34) terinstall
- **Android device** atau emulator dengan API ≥ 24 (Android 7.0)

Cek versi:

```bash
flutter --version
flutter doctor
```

`flutter doctor` harus hijau untuk Android toolchain. iOS opsional di tahap MVP (Android-first per PLANNING §2).

## Setup pertama kali

```bash
# Install dependency
flutter pub get

# Generate localization (id + en)
flutter gen-l10n

# Generate Drift database code
dart run build_runner build --delete-conflicting-outputs
```

> **Penting:** file `lib/data/local/database.g.dart` dan `lib/l10n/generated/*.dart` adalah file generated — tidak di-commit. Jalankan `build_runner` setelah pertama clone dan setiap kali ubah tabel/locale.

## Jalankan app

```bash
# Pastikan device terhubung
flutter devices

# Run di device default
flutter run

# Run di device tertentu
flutter run -d <device-id>
```

## Lint & Test

```bash
flutter analyze
flutter test
```

CI di `.github/workflows/release_apk.yml` menjalankan keduanya pada setiap PR.

## Build release APK

```bash
flutter build apk --release
# Hasil: build/app/outputs/flutter-apk/app-release.apk
```

Untuk private testing, APK boleh debug-signed (sudah dikonfigurasi di `android/app/build.gradle.kts` sebagai fallback). Production signing menyusul di Phase 10 (PLANNING §7).

## Struktur Folder

```
lib/
├── app/                       # Routing & app shell (router, app, shell, bottom nav)
├── core/
│   ├── theme/                 # Design tokens — DESIGN.md jadi referensi
│   │   ├── color_tokens.dart
│   │   ├── typography.dart
│   │   ├── spacing.dart       # spacing + radius
│   │   ├── shadows.dart
│   │   ├── motion.dart
│   │   ├── app_theme.dart
│   │   └── theme_mode_controller.dart
│   ├── utils/                 # Pure helpers (distance, formatters)
│   └── widgets/               # Shared UI: AppButton, AppCard, StatBlock, dll
├── data/
│   └── local/                 # Drift tables & database
├── features/                  # Feature-first
│   ├── checkpoint/{domain,...}
│   ├── history/{presentation,...}
│   ├── home/presentation
│   ├── map/presentation
│   ├── notes/{domain,...}
│   ├── onboarding/presentation
│   ├── paywall/presentation
│   ├── settings/presentation
│   ├── sos/{domain,presentation}
│   ├── statistics/presentation
│   └── tracking/{domain,presentation}
├── l10n/
│   ├── app_id.arb             # Indonesian (default)
│   ├── app_en.arb             # English
│   └── generated/             # generated, ignored
└── main.dart
```

Mengikuti **Clean Architecture + feature-first** dari PLANNING §6.

## Konvensi penting

- Pakai token (HColors, HTypography, HSpacing, HRadius) — **jangan** pakai hex literal di luar `color_tokens.dart`.
- Angka stat selalu pakai **mono font** (DESIGN.md §4.4).
- Tidak ada emoji di UI inti (DESIGN.md §2.2).
- String semua via `.arb` — jangan hardcode.
- Touch target minimum 48dp.
- Test sebelum push: `flutter analyze && flutter test`.

## Status implementasi

Lihat PLANNING_HIKEID.md §7 untuk roadmap fase. Saat ini app berada di:

- Phase 1 — Project foundation (theme, navigation, locale, CI) — **selesai**
- Phase 2 — Local data foundation (Drift tables, repositories) — **selesai**
- Phase 3 — GPS tracking core (geolocator, state notifier, auto-save, recovery) — **selesai**
- Phase 4 — Background tracking & battery modes — belum (perlu real device test)
- Phase 5 — Map & offline (flutter_map, OSM tiles, polylines) — **selesai (online)**
- Phase 6 — GPX import & export — **selesai**
- Phase 7 — Checkpoint & notes — **checkpoint selesai**, photo/voice note belum
- Phase 8 — Safety / SOS (last-known location, contacts CRUD, share) — **selesai**
- Phase 9 — Stats lanjut & polish — belum
- Phase 10 — Release APK distribusi — belum

Yang masih placeholder: profile elevasi grafik, off-route warning, tile cache offline (perlu paket FMTC), background foreground service, photo/voice notes.
