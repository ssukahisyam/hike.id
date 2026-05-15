# PLANNING — Hike.id
> Offline-First Hiking Companion untuk Pendaki Indonesia
> Codename: HikeID · Version: 1.1 · Tanggal: Mei 2026

---

## 1. Ringkasan Proyek

**Hike.id** adalah aplikasi mobile berbasis Flutter untuk pendaki gunung Indonesia. Aplikasi ini memungkinkan tracking GPS real-time tanpa internet, lengkap dengan peta offline, checkpoint, data elevasi, sistem darurat SOS, dan riwayat pendakian.

Filosofi inti: **offline-first**. Semua fitur pendakian utama berfungsi penuh tanpa sinyal, di gunung manapun, kapanpun.

| Atribut | Detail |
|---|---|
| Nama Aplikasi | Hike.id |
| Tagline | *"Setiap Langkah, Tercatat."* |
| Codename Internal | HikeID |
| Platform | Flutter — Android-first, iOS menyusul |
| Distribusi Awal | Private testing via release APK (GitHub Actions) |
| Model Bisnis | Freemium |
| Map Provider | OpenStreetMap + flutter_map |
| Database Lokal | Drift / SQLite |
| Target Rilis MVP | 20 minggu dari kickoff |
| Target Rilis Public Beta | +6 minggu setelah MVP |

---

## 2. Visi Produk

Menjadi aplikasi pendakian #1 di Indonesia yang benar-benar bisa diandalkan di alam bebas — bekerja penuh tanpa internet, membantu pengguna tidak tersesat, merekam setiap momen petualangan, dan mendukung keselamatan lewat fitur darurat yang sederhana namun efektif.

---

## 3. Prinsip Produk

| Prinsip | Penjelasan |
|---|---|
| **Offline-first** | Semua fungsi pendakian inti harus bekerja tanpa sinyal |
| **Battery-aware** | Tracking harus survive hiking panjang tanpa menguras baterai |
| **Safety-oriented** | Informasi darurat harus mudah diakses bahkan saat panik / gemetar |
| **Lightweight but premium** | UI cepat, terbaca, dan terpercaya — tidak murahan, tidak alay |
| **Android-first** | Optimasi perilaku Android dulu, ekspansi platform kemudian |
| **Local-first MVP** | Tidak butuh akun untuk versi pertama |
| **Honest by default** | App tidak mengklaim hal yang tidak bisa dilakukan (mis. auto-rescue) |
| **Future-ready** | Arsitektur mengakomodasi akun, cloud sync, dan komunitas trail nanti |

---

## 4. Target Pengguna

### Persona 1 — Pendaki Pemula
- Usia 18–28, mahasiswa / fresh graduate
- Sudah 2–5x mendaki, sering ikut open trip
- Kebutuhan: tahu posisinya, tidak tersesat, tenang dengan SOS
- Pain point: sinyal hilang, baterai cepat habis, takut tersesat

### Persona 2 — Pendaki Berpengalaman
- Usia 25–40, sudah 20+ gunung
- Sering buat rute sendiri, butuh GPX import/export, kontrol baterai
- Kebutuhan: rekam jalur, statistik akurat, off-route warning
- Pain point: tidak ada satu apps yang cukup lengkap untuk Indonesia

### Persona 3 — Koordinator Grup / Guide
- Usia 25–45, sering bawa rombongan
- Butuh checkpoint, catatan jalur, ringkasan hike untuk anggota
- Kebutuhan: mark checkpoint air/kemah/puncak, share lokasi darurat
- Pain point: sulit koordinasi dan dokumentasi di lapangan

### Persona 4 — Private Tester (fase awal saja)
- Relawan pengujian sebelum public release
- Kebutuhan: install APK dari GitHub Actions, laporkan bug

---

## 5. Tech Stack

### Mobile (Flutter)

| Kategori | Pilihan | Alasan |
|---|---|---|
| Flutter SDK | `^3.22` | LTS-stabil saat ini |
| Dart | `^3.4` | Null-safety + records |
| State Management | `flutter_riverpod` | Compile-time safe, testable, scalable |
| Navigation | `go_router` | Deep link friendly, type-safe routes |
| Local Database | `drift` + SQLite | Type-safe SQL, migration support |
| GPS | `geolocator` | Battle-tested di Android & iOS |
| Sensor | `sensors_plus` | Compass / barometer abstraction |
| Peta | `flutter_map` | Renderer OSM yang mature, customizable |
| Tile Caching | `flutter_map_tile_caching` (FMTC) | MBTiles + bulk download |
| Background Service | `flutter_background_service` | Foreground service Android |
| GPX | `gpx` | Parser GPX 1.0 / 1.1 yang stabil |
| Chart | `fl_chart` | Profil elevasi & grafik aktivitas |
| Notifikasi | `flutter_local_notifications` | Persistent notification tracking |
| Connectivity | `connectivity_plus` | Status sinyal untuk indikator offline |
| Audio | `record` + `just_audio` | Voice note record + playback |
| Kamera | `image_picker` | Photo note dari kamera/galeri |
| File Sharing | `share_plus` | Share GPX & koordinat ke aplikasi lain |
| Path | `path_provider` | Lokasi file storage cross-version |
| Localization | `flutter_localizations` | ID + EN via `.arb` |
| In-App Purchase | `purchases_flutter` (RevenueCat) | Manage paywall freemium |
| Crash Analytics | `sentry_flutter` | Error monitoring production |
| Logging | `logger` | Structured logs lokal |

### Backend (post-MVP, opsional)

| Komponen | Pilihan |
|---|---|
| Runtime | Node.js + Fastify |
| Database | PostgreSQL + PostGIS |
| Auth | Supabase Auth |
| Realtime | Supabase Realtime (WebSocket) |
| Storage | Supabase Storage (backup GPX & foto) |
| Hosting | Railway / Fly.io |

> **Penting:** Semua fitur MVP berjalan 100% offline via Drift/SQLite lokal. Backend hanya diperlukan di fase Group Tracking dan Cloud Backup — bukan bagian MVP.

### Infrastruktur Peta

| Aspek | Detail |
|---|---|
| Tile Source utama | OpenStreetMap Standard tiles |
| Tile Source alternatif | OpenTopoMap (untuk kontur elevasi) |
| Tile Format Cache | MBTiles (SQLite-based) |
| Sistem Koordinat | WGS84 / EPSG:4326 |
| Elevasi Realtime | Sensor barometer (primary) |
| Elevasi Fallback | SRTM via open-elevation.com (cached) |
| Lisensi | ODbL — bebas dipakai, wajib atribusi OSM di app |

---

## 6. Arsitektur Aplikasi

```
+-----------------------------------------------------+
|               PRESENTATION LAYER                    |
|   Screens, Widgets, Bottom Sheets, Dialogs          |
+----------------------+------------------------------+
                       |
+----------------------v------------------------------+
|              APPLICATION LAYER                      |
|   Riverpod Providers, Use Cases, State Notifiers    |
+----------------------+------------------------------+
                       |
+----------------------v------------------------------+
|                 DOMAIN LAYER                        |
|   Entities: Trip, TrackPoint, Checkpoint, Note      |
+----------------------+------------------------------+
                       |
+----------------------v------------------------------+
|             INFRASTRUCTURE LAYER                    |
|   Drift DB | GPS Service | Map Tiles | GPX Parser   |
|   File Storage | Foreground Service | HTTP Client   |
+-----------------------------------------------------+
```

**Pattern:** Clean Architecture + Repository Pattern. Tiap fitur punya folder sendiri di `/features/`. Domain layer **tidak boleh** import package eksternal selain `dart:*` dan `equatable`.

**Aturan dependency:**
- Presentation → Application → Domain
- Infrastructure → Domain (lewat interface)
- Domain tidak bergantung pada layer lain

---

## 7. Fase Development

Tiap fase punya:
- **Goal** — outcome yang ingin dicapai
- **Deliverables** — artefak yang dihasilkan
- **Acceptance Criteria** — bagaimana kita tahu fase selesai
- **Owner** — siapa yang bertanggung jawab utama

### Phase 1 — Project Foundation (Minggu 1–2)

**Goal:** Flutter project + arsitektur dasar siap.

**Deliverables:**
- Flutter app diinisialisasi, package Android dikonfigurasi (`id.hike.app`)
- App name: Hike.id, codename HikeID terdokumentasi
- Folder structure Clean Architecture
- Riverpod dikonfigurasi
- Go Router dengan struktur navigasi dasar
- Theme structure untuk light/dark mode + outdoor mode (lihat DESIGN.md)
- Struktur lokalisasi ID & EN (`lib/l10n/*.arb`)
- GitHub Actions workflow untuk release APK

**Acceptance Criteria:**
- App launch sukses di Android emulator dan minimal 1 device fisik
- Release APK dapat diproduksi dari GitHub Actions
- Home screen tampil dengan navigasi dasar
- Lint pass: `flutter analyze` zero issues

**Owner:** Mobile Lead

---

### Phase 2 — Local Data Foundation (Minggu 3–4)

**Goal:** Persistensi lokal yang solid sebagai basis semua fitur.

**Deliverables:**
- Drift/SQLite database setup + migration framework
- Schema: `Trip`, `TrackPoint`, `Checkpoint`, `Note`, `EmergencyContact`, `AppSettings`, `SosLog`
- Layout file storage lokal (foto, audio, GPX export, tile cache)
- Repository interface + implementasi untuk tiap entity
- Basic CRUD operations + integration tests

**Acceptance Criteria:**
- App bisa create, list, view, dan delete trip lokal
- Data persist setelah app restart, restart device, dan app reinstall (jika user pilih backup)
- File storage path konsisten di Android 7–14
- Migration test: schema v1 → v2 tidak kehilangan data

**Owner:** Mobile Lead

---

### Phase 3 — GPS Tracking Core (Minggu 5–6)

**Goal:** Rekam jalur hiking secara reliable di foreground.

**Deliverables:**
- Start / pause / resume / stop tracking
- Sampling track point: lat, lng, elevation, accuracy, speed, timestamp
- Kalkulasi jarak real-time (Haversine formula)
- Kalkulasi durasi & kecepatan
- Display koordinat & elevasi saat ini
- Accuracy indicator (weak / good / excellent) berbasis HDOP
- Auto-save setiap 30 detik (crash protection)

**Acceptance Criteria:**
- User bisa merekam, pause, resume, dan stop trip
- User bisa simpan trip yang direkam
- User bisa lihat ringkasan rute yang direkam
- Data tidak hilang saat app di-force close (test wajib)
- Akurasi tracking < 15m di area terbuka selama uji 1 jam

**Owner:** Mobile Engineer

---

### Phase 4 — Background Tracking & Battery Modes (Minggu 7–8)

**Goal:** Tracking tetap aktif saat layar mati tanpa drain baterai berlebihan.

**Deliverables:**
- Android Foreground Service implementation
- Persistent notification selama tracking aktif (jarak + durasi)
- 3 mode tracking:
  - **High Accuracy** — update 3–5 detik, GPS full power
  - **Balanced** *(default)* — update 10–15 detik, adaptive
  - **Battery Saver** — update 30–60 detik, reduced frequency
- Peringatan baterai sebelum mulai High Accuracy
- Setting default tracking mode
- Estimasi konsumsi baterai per mode (live estimate)
- Whitelist battery optimization onboarding

**Acceptance Criteria:**
- Tracking continue dengan layar mati ≥ 2 jam tanpa terputus
- Persistent notification tampil & akurat
- User paham tradeoff baterai sebelum mulai
- Mode berpengaruh nyata pada interval & akurasi
- Konsumsi baterai Balanced mode < 10%/jam (test perangkat reference)

**Owner:** Mobile Engineer

---

### Phase 5 — Map & Strategi Offline (Minggu 9–10)

**Goal:** Tampilkan rute dan posisi di peta, siap offline.

**Deliverables:**
- `flutter_map` integration dengan OSM tiles + atribusi
- Current location marker dengan direction indicator
- Polyline jalur direkam (warna aktif vs history)
- Polyline jalur GPX yang diimport
- Tile caching strategy (FMTC + MBTiles)
- Indikator status offline
- Auto-follow posisi user (toggle on/off)
- Placeholder UI untuk download-area map (fitur future)

**Acceptance Criteria:**
- Rute tampil di peta dengan smooth pan/zoom
- App tetap berguna tanpa network
- Missing tiles tampil placeholder, tidak crash
- Indikator offline jelas terlihat
- Render polyline > 5.000 points tetap 60fps (gunakan simplifier)

**Owner:** Mobile Engineer

---

### Phase 6 — GPX Import & Export (Minggu 11–12)

**Goal:** Interoperabilitas dengan tools outdoor lain.

**Deliverables:**
- GPX import dari file manager (intent filter `.gpx`)
- GPX validation & error handling readable
- Preview rute setelah import
- Simpan rute import sebagai local route template
- GPX export dari recorded trip (track points + timestamps)
- Opsi: checkpoint sebagai GPX waypoints di export
- Sample GPX files untuk keperluan testing
- Round-trip test: export → import = data identik

**Acceptance Criteria:**
- User bisa import GPX file
- User bisa follow imported GPX route
- User bisa export recorded trip sebagai GPX
- Error import tampil pesan manusiawi (bukan stack trace)
- Tested kompatibilitas dengan: AllTrails, Wikiloc, Garmin, OsmAnd, Strava

**Owner:** Mobile Engineer

---

### Phase 7 — Checkpoint & Notes (Minggu 13–14)

**Goal:** Tandai informasi penting di jalur.

**Deliverables:**
- Tambah checkpoint saat tracking aktif (FAB atau long-press peta)
- Tipe checkpoint: Pos, Air, Kemah, Puncak, Bahaya, Custom
- Ikon dan warna berbeda per tipe (sesuai DESIGN.md)
- Text note (standalone & terkait checkpoint)
- Photo note (dari kamera atau galeri)
- Voice note (rekam audio max 3 menit)
- Media besar disimpan di file storage, bukan database row
- Lihat checkpoint di peta & trip detail

**Acceptance Criteria:**
- User bisa tandai checkpoint < 5 detik sambil berjalan
- Semua note tersedia offline
- Foto dan audio tersimpan lokal dengan benar (round-trip read OK)
- Tap checkpoint di peta = tampil detail card
- Free tier limit 5 checkpoint / trip ditegakkan dengan paywall

**Owner:** Mobile Engineer

---

### Phase 8 — Safety Features (Minggu 15–16)

**Goal:** Dukung keputusan pendakian yang lebih aman — tanpa overpromising.

**Deliverables:**
- SOS screen (detail di PRD §4.10)
- Off-route warning saat follow imported GPX
- Emergency contact storage (3 nomor)
- Share location via Android share sheet
- Basarnas info statis: 115 + kontak regional umum
- Battery low warning saat tracking (< 20% dan < 10%)
- Disclaimer eksplisit "App tidak mengirim rescue otomatis"

**Acceptance Criteria:**
- SOS bisa dibuka bahkan offline (test Airplane Mode)
- User bisa copy koordinat offline
- User bisa share koordinat jika ada sinyal
- Off-route warning muncul tanpa terlalu banyak false alert (cooldown 60 detik)
- App TIDAK mengklaim bisa kirim rescue otomatis
- SOS dapat diakses ≤ 2 tap dari layar manapun

**Owner:** Mobile Lead + UX

---

### Phase 9 — Statistik Lanjut & UI Polish (Minggu 17–18)

**Goal:** Data bermakna + UI terasa premium dan nyaman outdoor.

**Deliverables:**

*Statistik:*
- Profil elevasi (grafik sepanjang jalur)
- Elevation gain / loss total
- Kecepatan rata-rata & pace (mnt/km)
- Estimasi waktu ke tujuan saat follow rute
- Kompas / arah heading
- Statistik kumulatif semua pendakian
- Grafik aktivitas bulanan (heatmap)
- Personal best tracking

*UI Polish:*
- Tracking screen bottom sheet (collapsed / expanded)
- Tombol aksi besar dan jelas
- Empty states yang informatif (sesuai DESIGN.md)
- Error states yang helpful
- Outdoor mode (high-contrast)
- Accessibility pass: kontras ratio, touch targets 48dp, semantic labels
- Onboarding flow (4 layar)

**Acceptance Criteria:**
- Tracking screen bisa digunakan sambil berjalan (test sebenarnya, bukan hanya simulator)
- Aksi kritis mudah ditemukan satu tangan
- UI terbaca di terik matahari (kontras > 7:1) dan kondisi malam
- Onboarding selesai < 2 menit untuk user baru
- Lighthouse-equivalent accessibility audit: zero error

**Owner:** UX + Mobile Lead

---

### Phase 10 — Freemium & Private Testing Release (Minggu 19–20)

**Goal:** APK siap distribusi ke private tester + pondasi monetisasi.

**Deliverables:**
- Implementasi freemium paywall (RevenueCat)
- Feature gate: Free vs Pro (lihat tabel freemium di §10)
- Release APK GitHub Actions workflow final + signing
- Release checklist (lihat §15)
- Known limitations didokumentasikan
- Test checklist: route, battery, offline, GPS accuracy
- Sentry crash analytics aktif
- Privacy policy dasar (UU PDP)
- Bug reporter in-app (kirim log ke email/issue tracker)

**Acceptance Criteria:**
- Release APK bisa didownload dari GitHub Actions artifacts
- Private tester bisa install dan test app
- Crash reports masuk ke Sentry dengan symbolication
- Fitur free / pro ter-gate dengan benar (test paywall)
- Sandbox purchase berhasil round-trip

**Owner:** Mobile Lead

---

## 8. Struktur Folder Project

```
hike_id/
+-- lib/
|   +-- core/
|   |   +-- constants/         # warna, tema, strings keys
|   |   +-- extensions/        # extension methods
|   |   +-- utils/             # helpers: distance calc, GPX parse
|   |   +-- theme/             # ThemeData light, dark, outdoor
|   |   +-- widgets/           # shared UI components
|   +-- features/
|   |   +-- map/               # peta & navigasi
|   |   +-- tracking/          # GPS tracking aktif
|   |   +-- checkpoint/        # manajemen checkpoint
|   |   +-- notes/             # text, foto, voice note
|   |   +-- history/           # riwayat pendakian
|   |   +-- gpx/               # import & export GPX
|   |   +-- sos/               # SOS & emergency
|   |   +-- statistics/        # statistik & grafik
|   |   +-- settings/          # pengaturan app
|   |   +-- onboarding/        # first-run flow
|   |   +-- paywall/           # freemium paywall
|   +-- data/
|   |   +-- local/             # Drift tables & DAOs
|   |   +-- remote/            # HTTP clients (future)
|   |   +-- repositories/      # repository implementations
|   +-- l10n/                  # ID & EN .arb files
|   +-- main.dart
+-- assets/
|   +-- fonts/
|   +-- icons/
|   +-- images/
|   +-- samples/               # sample.gpx untuk testing
+-- test/
|   +-- unit/
|   +-- widget/
|   +-- integration/
+-- android/
+-- ios/
+-- .github/workflows/         # GitHub Actions APK build
+-- pubspec.yaml
+-- PLANNING_HIKEID.md
+-- PRD_HIKEID.md
+-- DESIGN.md
+-- README.md
```

---

## 9. Release Milestones

| Milestone | Konten | Fase |
|---|---|---|
| **M0 — Dokumentasi** | Planning, PRD, Design, Tech Architecture | Pre-dev |
| **M1 — App Skeleton** | Flutter app, navigasi, tema, CI APK | Phase 1 |
| **M2 — Local Trip Tracker** | Create trip, rekam GPS, simpan rute, statistik dasar | Phase 2–3 |
| **M3 — Background & Battery** | Background tracking, notifikasi, battery modes | Phase 4 |
| **M4 — Map & GPX** | Tampil rute, import GPX, export GPX | Phase 5–6 |
| **M5 — Hiking Safety** | Checkpoint, notes, SOS, off-route warning | Phase 7–8 |
| **M6 — Polish & Stats** | Statistik lanjut, UI polish, onboarding | Phase 9 |
| **M7 — Private Field Test** | APK distribusi, uji gunung nyata, battery test | Phase 10 |
| **M8 — Public Beta** | Play Store closed testing, paywall live | Post-MVP |

---

## 10. Freemium — Pembagian Fitur

### Tier GRATIS
- GPS tracking real-time (unlimited trips)
- Peta offline cache (max 500MB)
- Checkpoint (max 5 per trip)
- Text note
- Riwayat pendakian (10 trip terakhir)
- SOS screen — **selalu gratis, non-negotiable**
- Import GPX
- Export GPX (3x per bulan)
- Statistik dasar (jarak, durasi, elevasi)

### Tier PRO — Hike.id Pro
- Unlimited tile download (semua gunung Indonesia)
- Unlimited checkpoint + foto & voice note per trip
- Unlimited riwayat pendakian
- Statistik lanjut (pace, personal best, grafik aktivitas)
- Export GPX unlimited + KML + PDF laporan
- Off-route warning lanjut (custom threshold)
- Dead Man's Switch (check-in timer otomatis)
- Group tracking real-time (max 10 orang, butuh sinyal)
- Cloud backup riwayat pendakian
- Offline route planning sebelum berangkat
- Widget layar utama Android

**Harga:** Rp 29.000/bulan atau Rp 199.000/tahun *(hemat 43%)*

**Trial:** 14 hari Pro gratis untuk user baru, tanpa kartu kredit (tergantung kebijakan store).

---

## 11. Risk Register

| Risiko | Dampak | Probabilitas | Mitigasi |
|---|---|---|---|
| Background tracking di-kill Android battery optimization | Tinggi | Tinggi | Foreground service + persistent notification + onboarding whitelist |
| Battery drain di hiking panjang | Tinggi | Tinggi | 3 mode tracking + warning baterai + adaptive interval |
| OSM tile licensing issues | Tinggi | Rendah | Review ODbL, atribusi visible, user-managed cache |
| GPS tidak akurat di bawah pohon / jurang | Medium | Tinggi | Indikator akurasi, filter Kalman, sensor fusion |
| GPX file format bervariasi antar sumber | Medium | Medium | Validasi import + error message readable |
| SOS disalahartikan sebagai auto-rescue | Tinggi | Medium | Disclaimer eksplisit, tidak ada klaim otomatis |
| App crash saat tracking lama | Tinggi | Medium | Auto-save 30 detik, Foreground service, Sentry |
| Storage penuh karena tile cache | Medium | Medium | Batas cache configurable, auto-delete tile lama |
| App terlalu kompleks terlalu cepat | Medium | Medium | Build in phases, scope discipline ketat di MVP |
| Ada developer keluar di tengah jalan | Tinggi | Rendah | Pair programming, dokumentasi tiap PR, code review wajib |
| Play Store review reject (background location) | Tinggi | Medium | Justifikasi privacy policy + video demo use-case |

---

## 12. Open Decisions

- [ ] Final Android package name (`id.hike.app` vs `com.hikeid.app`)
- [ ] Apakah Play Store release pakai nama Hike.id atau nama legal lain (cek trademark)
- [ ] Tile provider final + batas download area untuk tier gratis
- [ ] Apakah support GeoJSON setelah GPX MVP
- [ ] Apakah dummy/sample GPX disertakan di app untuk onboarding demo
- [ ] Backend hosting provider untuk fase Group Tracking (Railway vs Supabase full)
- [ ] Apakah strategi monetisasi pakai trial 14 hari atau freemium ketat tanpa trial

---

## 13. Testing Strategy

### Tingkat Pengujian

| Tingkat | Cakupan | Tools | Target |
|---|---|---|---|
| **Unit Test** | Utility, calculator (Haversine, elevation), parser GPX, repository | `flutter_test`, `mocktail` | > 70% coverage business logic |
| **Widget Test** | Rendering komponen, interaksi, state Riverpod | `flutter_test` | Semua screen kritis |
| **Integration Test** | Flow start tracking → save trip, GPX import → preview | `integration_test` | Happy path semua fitur |
| **Manual / Field Test** | Hiking nyata di gunung, low signal, baterai panjang | Checklist + tester | Setiap milestone |

### Field Test Wajib Sebelum Public Release

- 3 pendakian half-day (Cikuray / Papandayan / Salak)
- 1 pendakian full overnight (Gede / Lawu)
- 1 pendakian dengan signal hilang total > 6 jam
- 2 device berbeda secara paralel untuk verifikasi

### Test Devices Reference

| Tier | Device | Android |
|---|---|---|
| Low-end | Redmi 9A (RAM 3GB) | 11 |
| Mid-range | Samsung A24 | 14 |
| Flagship | Pixel 7 / Galaxy S23 | 14 |

---

## 14. Team Structure

Tim minimum yang dibutuhkan untuk MVP 20 minggu:

| Role | Alokasi | Tanggung Jawab |
|---|---|---|
| **Mobile Lead** | 100% | Arsitektur, code review, release management |
| **Mobile Engineer** | 100% | Implementasi fitur, testing |
| **UX / Product Designer** | 50% | Design system, prototype, user testing |
| **QA / Tester (rotasi)** | 25% | Field test, regression, bug triage |
| **Product Owner** | 25% | Roadmap, prioritas, stakeholder |

**Total:** ~3 FTE setara untuk durasi MVP.

### Cadence

- Daily standup async (Slack/Discord) — 5 menit
- Sprint planning Senin pagi — 2 minggu sprint
- Sprint review Jumat sore — 1 jam
- Field test setiap 2 milestone — 1 weekend

---

## 15. Release Checklist (Per APK Release)

### Pre-Build
- [ ] `pubspec.yaml` versi naik (semver)
- [ ] CHANGELOG diupdate
- [ ] `flutter analyze` zero issues
- [ ] `flutter test` semua hijau
- [ ] Tidak ada `print()` atau `debugPrint()` di production code
- [ ] Sentry DSN production di-inject lewat env

### Build
- [ ] GitHub Actions workflow sukses
- [ ] APK signed dengan release keystore
- [ ] APK size < 25MB

### Smoke Test (15 menit, wajib)
- [ ] Install APK fresh di reference device
- [ ] Onboarding selesai
- [ ] Start tracking 5 menit
- [ ] Stop tracking, simpan trip
- [ ] Buka trip detail, verifikasi data
- [ ] Buka SOS screen di Airplane Mode

### Distribusi
- [ ] APK di-upload ke release page GitHub
- [ ] Release notes ditulis (apa baru, apa fix, known issues)
- [ ] Notifikasi ke channel private tester

---

## 16. KPI & Definisi Sukses

| Metrik | Target Private Test | Target 3 Bulan Post-Launch | Target 6 Bulan |
|---|---|---|---|
| APK build sukses | 100% | — | — |
| Crash-free rate | > 95% | > 99% | > 99.5% |
| Tracking berjalan di background | Semua device test | — | — |
| GPS accuracy error | < 15 m | < 10 m | < 5 m |
| Baterai Balanced mode | < 10%/jam | < 8%/jam | < 8%/jam |
| Downloads | — | 1.000 | 10.000 |
| Premium conversion | — | 2% | 5% |
| Store rating | — | > 4.3 | > 4.5 |
| Pendakian direkam | 20 (tester) | 500 | 5.000 |
| Day-7 retention | — | > 25% | > 30% |
| SOS opened (any reason) | — | tracked, tidak ada target | tracked |

---

## 17. Glossary

| Istilah | Arti |
|---|---|
| **Track** | Rangkaian titik GPS yang direkam selama satu sesi pendakian |
| **TrackPoint** | Satu titik GPS individual: lat, lng, elev, accuracy, timestamp |
| **Trip** | Sesi pendakian lengkap (track + checkpoints + notes + metadata) |
| **Route** | Jalur yang sudah ada (mis. dari GPX), bisa diikuti |
| **Checkpoint** | Penanda titik penting di jalur (air, kemah, puncak, dll) |
| **Waypoint** | Istilah GPX standar untuk Checkpoint saat export |
| **Off-route** | Posisi user terlalu jauh dari jalur GPX yang sedang difollow |
| **MBTiles** | Format SQLite untuk menyimpan tile peta offline |
| **HDOP** | Horizontal Dilution of Precision — metrik akurasi GPS |
| **Foreground Service** | Android service yang persistent + tampil notification |
| **Cold Start** | App launch dari kondisi tidak running |

---

*Dokumen ini adalah living document — diupdate tiap sprint review.*
*Perubahan major butuh approval Product Owner + Mobile Lead.*
