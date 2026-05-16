# Fix Plan — Hike.id Private Testing v0.1.0

> Status: WORK IN PROGRESS. Rencana perbaikan setelah real-device testing pertama.
> Update terakhir: ikut tanggal commit terakhir di branch `plan/fix-iteration-1`.

## Konteks

User feedback dari real-device testing v0.1.0:

> "setelah saya coba masih banyak fitur yang belum berfungsi. fitur tracking. kemudian belum ada import/export, download map, tombol FAB dan lain lain banyak sekali"

Dokumen ini mengurutkan masalah berdasarkan **dampak ke user** dan **effort fix**, supaya kita perbaiki yang paling penting dulu, satu per satu, dengan commit yang jelas per tahap.

## Prinsip

- **Fix yang prioritas dulu**, jangan semua sekaligus
- **Satu issue = satu commit** — supaya rollback gampang & history bersih
- **Reproduce dulu sebelum fix** — kalau saya tidak bisa pastikan masalahnya, minta detail dari user
- **Test plan per fix** — setiap fix punya step verifikasi yang jelas

## Klasifikasi

| Tag | Arti |
|---|---|
| **P0** | Blocker — fitur inti yang tidak jalan, app jadi tidak usable |
| **P1** | High — fitur penting tapi ada workaround |
| **P2** | Medium — nice-to-have, tidak block test |
| **P3** | Low — polish atau feature baru |
| **NEED-INFO** | Butuh klarifikasi dari user sebelum fix |
| **DOCUMENTED** | Sudah ada di KNOWN_LIMITATIONS — bukan bug, tapi missing feature |

## Daftar Issue (Iteration 1)

### Iteration 1A — Audit & Reproduce (sebelum fix)

Sebelum saya fix, harus konfirmasi masalah-masalah ini ke user dengan repro step. Kalau tidak ada feedback detail, saya akan asumsi dan code-review setiap touchpoint.

#### #FIX-1: Tracking screen tidak menampilkan GPS
- **Tag:** P0 / NEED-INFO
- **Repro saat ini (asumsi):** Tap "Mulai Hike" → pilih mode → tracking screen blank, polyline tidak jalan, distance/duration tidak update
- **Hipotesis:**
  1. Permission lokasi belum di-grant (most likely di first run)
  2. Permission ditolak permanen → harus minta lewat openAppSettings
  3. GPS device dimatikan
  4. Indoor / sinyal GPS poor (>30s tanpa fix)
  5. Foreground service tidak start (Android 13+ POST_NOTIFICATIONS)
  6. Stream provider tidak emit fix pertama
- **Yang perlu diaudit:**
  - `lib/features/tracking/data/gps_service.dart` — `ensureReady()` flow
  - `lib/features/tracking/application/tracking_controller.dart` — start() error handling
  - `lib/features/tracking/presentation/tracking_screen.dart` — error banner display
  - `lib/main.dart` — permission_handler init
- **Action:**
  - Tambah log debug di tiap step start tracking
  - Tampilkan permission status di UI tracking screen
  - Auto-trigger permission request flow yang user-friendly
  - Tambah "Buka pengaturan lokasi" CTA saat denied permanent

#### #FIX-2: FAB tidak muncul
- **Tag:** P0 / NEED-INFO
- **Hipotesis:** User maksud FAB checkpoint di tracking screen (line 132 tracking_screen.dart). FAB di-render dengan condition `session.isActive && session.lastFix != null` — kalau GPS belum lock atau tracking tidak running, FAB hilang. Logical, tapi user mungkin ekspektasi FAB selalu ada.
- **Action:**
  - Konfirmasi: FAB yang mana? Checkpoint? SOS?
  - Kalau checkpoint: jelaskan visibility rule, atau ubah jadi disabled state (bukan hidden)
  - Kalau ada FAB lain yang user expect tapi tidak ada: tambahkan

#### #FIX-3: GPX import/export tidak ada
- **Tag:** P1 / NEED-INFO
- **Repro saat ini (asumsi):** User cari import button → tidak ketemu di UI
- **Reality check:** `gpx_import_action.dart` ada, dipakai di history app bar (line dipanggil dari history_screen). Mungkin user tidak ngeh icon-nya kecil.
- **Action:**
  - Konfirmasi: tombol GPX di mana yang user lihat / tidak lihat?
  - Mungkin perlu jadi tombol lebih obvious + label text
  - Tambah onboarding hint / empty state CTA "Import dari GPX"

### Iteration 1B — Documented Limitations (bukan bug, tapi missing)

Yang user minta tapi memang belum diimplementasikan. Bukan bug, tapi mungkin user expect ada karena dilist di `KNOWN_LIMITATIONS.md` — perlu di-prioritaskan untuk Iteration 2.

#### #FEAT-1: Download map offline (tile cache)
- **Tag:** P1 / DOCUMENTED
- **Status:** Belum diimplementasikan (KNOWN_LIMITATIONS §2)
- **Effort:** ~2 hari — pakai `flutter_map_tile_caching` (FMTC)
- **Scope:** User pilih area di map → download tile area itu → tile dipakai saat offline
- **Plan:** Phase 5 Extension — terpisah dari fix iteration ini

#### #FEAT-2: Photo & voice notes
- **Tag:** P2 / DOCUMENTED
- **Status:** Belum diimplementasikan (KNOWN_LIMITATIONS §5)
- **Plan:** Phase 7 Extension — terpisah

#### #FEAT-3: Battery low notification
- **Tag:** P2 / DOCUMENTED
- **Status:** Deps sudah ada (`flutter_local_notifications`), tinggal wire
- **Effort:** ~2 jam — listener di `batterySnapshotProvider` saat `isLow`
- **Plan:** Bisa masuk Iteration 1 kalau perlu, atau Iteration 2

#### #FEAT-4: Map style switcher
- **Tag:** P3 / DOCUMENTED
- **Plan:** Iteration 3+

### Iteration 1C — Polish & UX

#### #UX-1: Empty states yang lebih actionable
- Saat history kosong → bukan cuma teks empty, tapi tombol "Mulai trip pertama" dan "Import GPX"
- Saat SOS contact kosong → CTA "Tambah kontak darurat"

#### #UX-2: Loading indicator yang konsisten
- Beberapa screen pakai CircularProgressIndicator default, beberapa tidak ada loading
- Standardize pakai shimmer / skeleton di list

#### #UX-3: Error message yang jelas
- Saat GPS denied → muncul "Izin lokasi belum diberikan." (cukup) tapi tidak ada CTA buka settings
- Saat database error → tidak ada UI feedback

## Eksekusi Plan

### Tahap 1 — Audit & Diagnostic Logging (commit 1)

Tambah logging detail di tracking flow supaya kita tahu pasti di step mana masalah terjadi. Tidak ubah behavior, hanya add `debugPrint` yang bisa kita lihat di `flutter run` console atau `adb logcat`.

**File yang dimodifikasi:**
- `lib/features/tracking/data/gps_service.dart` — log `ensureReady` step by step
- `lib/features/tracking/application/tracking_controller.dart` — log `start/stop/pause` lifecycle
- `lib/features/tracking/presentation/tracking_screen.dart` — log build dengan session state

**Estimasi:** 30 menit

### Tahap 2 — Permission UX Flow (commit 2)

Tracking yang gagal start karena permission jadi screen yang useful, bukan hanya error message. Tambah tombol "Buka Pengaturan" saat denied permanent + retry mechanism.

**File yang dimodifikasi:**
- `lib/features/tracking/presentation/tracking_screen.dart` — error UI dengan CTA
- `lib/features/tracking/data/gps_service.dart` — pakai `permission_handler` untuk `openAppSettings()`

**Estimasi:** 1 jam

### Tahap 3 — FAB Visibility & SOS Quick Access (commit 3)

FAB checkpoint tetap muncul tapi disabled (bukan hidden) saat tracking idle. Plus SOS button persistent di tracking screen.

**File yang dimodifikasi:**
- `lib/features/tracking/presentation/tracking_screen.dart`

**Estimasi:** 30 menit

### Tahap 4 — GPX Import/Export More Visible (commit 4)

GPX import button jadi prominent di history empty state + toolbar. Export di trip detail juga lebih obvious.

**File yang dimodifikasi:**
- `lib/features/history/presentation/history_screen.dart`
- `lib/features/history/presentation/trip_detail_screen.dart`

**Estimasi:** 30 menit

### Tahap 5 — Empty States Actionable (commit 5)

Empty state di history & SOS contacts dapat tombol primary CTA, bukan hanya teks.

**File yang dimodifikasi:**
- `lib/features/history/presentation/history_screen.dart`
- `lib/features/sos/presentation/sos_screen.dart`

**Estimasi:** 30 menit

### Tahap 6 — Battery Low Notification (commit 6, OPSIONAL)

Wire `batterySnapshotProvider` ke `flutter_local_notifications` — show notif lokal saat baterai <20% & tracking aktif.

**File yang dimodifikasi:**
- `lib/core/services/battery_service.dart` (atau new file `battery_alert_service.dart`)
- `lib/main.dart` (init notifications channel)

**Estimasi:** 2 jam

### Tahap 7 — Update KNOWN_LIMITATIONS & docs (commit 7)

Update dokumen status setelah fix.

**File yang dimodifikasi:**
- `KNOWN_LIMITATIONS.md`
- `README.md`

**Estimasi:** 15 menit

## Yang TIDAK Saya Kerjakan di Iteration 1

Ini eksplisit ditunda ke iteration berikutnya:

- **Tile cache offline (FMTC)** — perlu Phase 5 Extension dengan effort 2 hari
- **Photo/voice notes** — perlu Phase 7 Extension
- **Map style switcher** — Phase 5 Extension
- **Crashlytics / Sentry** — Phase 11
- **Production signing keystore** — Phase 10b
- **Play Store** — Phase 10b

## Test Plan Setelah Iteration 1

User akan test ulang dengan APK v0.1.1 (semua fix Iteration 1) di:

1. **Smoke test** (tanpa hike) — 30 menit
   - Mulai tracking → polyline jalan
   - Pause → resume → stop
   - History → trip muncul
   - SOS → kontak darurat
   - Permission denial flow → CTA buka settings

2. **Walk test** (1 km outdoor) — 1 jam
   - Tracking distance match dengan GPS
   - FAB checkpoint bisa di-tap
   - GPX export bisa
   - Off-route warning (kalau ada imported route)

Detail di `TEST_CHECKLIST.md`.

## Progress Tracking

| # | Tahap | Status | Commit | Date |
|---|---|---|---|---|
| 1 | Audit & Diagnostic Logging | ⏳ | — | — |
| 2 | Permission UX Flow | ⏳ | — | — |
| 3 | FAB Visibility & SOS | ⏳ | — | — |
| 4 | GPX Import/Export Visible | ⏳ | — | — |
| 5 | Empty States Actionable | ⏳ | — | — |
| 6 | Battery Low Notification | ⏳ | — | — |
| 7 | Update Docs | ⏳ | — | — |

Status legend: ⏳ pending · 🚧 in progress · ✅ done · ⏭ skipped

---

## Catatan untuk User

Sebelum saya mulai eksekusi tahap 1, saya butuh konfirmasi **3 hal**:

1. **Tracking GPS sudah dicoba outdoor dengan langit terbuka?** (Indoor 90% gagal lock dalam 2-5 menit pertama)
2. **Permission lokasi sudah Allow?** (Cek: HP Settings → Apps → Hike.id → Permissions → Location)
3. **FAB yang mana yang user maksud?** (Checkpoint? SOS button? Lainnya?)

Kalau kita yakin masalah memang ada (bukan user error), saya akan eksekusi 7 tahap di atas berurutan. Kalau ternyata tracking jalan setelah outdoor — kita lompat ke fix lain saja.

