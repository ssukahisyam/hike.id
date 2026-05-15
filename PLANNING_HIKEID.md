# 🏔️ PLANNING — Hike.id
> *Offline-First Hiking Companion untuk Pendaki Indonesia*
> Codename: HikeID | Version: 1.0 | Tanggal: Mei 2026

---

## 1. Ringkasan Proyek

**Hike.id** adalah aplikasi mobile berbasis Flutter untuk pendaki gunung Indonesia yang memungkinkan tracking jalur GPS secara real-time tanpa koneksi internet, lengkap dengan peta offline, checkpoint, data elevasi, fitur SOS darurat, dan riwayat pendakian. Dibangun dengan pendekatan *offline-first* — semua fitur inti bekerja penuh tanpa sinyal, kapan pun, di gunung manapun.

| Atribut | Detail |
|---|---|
| **Nama Aplikasi** | Hike.id |
| **Tagline** | *"Setiap Langkah, Tercatat."* |
| **Codename Internal** | HikeID |
| **Platform** | Flutter — Android-first, iOS menyusul |
| **Distribusi Awal** | Private testing via release APK (GitHub Actions) |
| **Model Bisnis** | Freemium |
| **Map Provider** | OpenStreetMap + flutter_map |
| **Database** | Drift / SQLite |
| **Target Rilis MVP** | 20 minggu dari kickoff |

---

## 2. Visi Produk

Menjadi aplikasi pendakian #1 di Indonesia yang benar-benar bisa diandalkan di alam bebas — bekerja penuh tanpa internet, membantu pengguna tidak tersesat, merekam setiap momen petualangan, dan menyelamatkan nyawa lewat fitur darurat yang sederhana namun efektif.

---

## 3. Prinsip Produk

| Prinsip | Penjelasan |
|---|---|
| **Offline-first** | Semua fungsi pendakian inti harus bekerja tanpa sinyal |
| **Battery-aware** | Tracking harus survive hiking panjang tanpa menguras baterai secara berlebihan |
| **Safety-oriented** | Informasi darurat harus mudah diakses bahkan dalam kondisi panik/stres |
| **Lightweight but premium** | UI harus terasa cepat, terbaca, dan terpercaya — tidak murahan |
| **Android-first** | Optimasi untuk perilaku Android sebelum ekspansi ke platform lain |
| **Local-first MVP** | Tidak butuh akun untuk versi pertama |
| **Future-ready** | Arsitektur harus mengakomodasi akun, cloud sync, dan komunitas trail ke depan |

---

## 4. Target Pengguna

### Persona 1 — Pendaki Pemula
- Usia 18–28 tahun, mahasiswa / fresh graduate
- Baru 2–5x mendaki, sering ikut open trip
- Kebutuhan: tahu posisinya, tidak tersesat, tenang dengan SOS
- Pain point: sinyal hilang, baterai cepat habis, takut tersesat

### Persona 2 — Pendaki Berpengalaman
- Usia 25–40 tahun, sudah 20+ gunung
- Sering buat rute sendiri, butuh GPX import/export, kontrol baterai
- Kebutuhan: rekam jalur, statistik akurat, off-route warning
- Pain point: tidak ada satu apps yang cukup lengkap untuk Indonesia

### Persona 3 — Koordinator Grup / Guide
- Usia 25–45 tahun, sering bawa rombongan
- Butuh checkpoint, catatan jalur, ringkasan hike untuk anggota
- Kebutuhan: marking checkpoint air/kemah/puncak, sharing lokasi darurat
- Pain point: sulit koordinasi dan dokumentasi saat di lapangan

### Persona 4 — Private Tester (khusus fase awal)
- Relawan pengujian sebelum public release
- Kebutuhan: install APK dari GitHub Actions, laporkan bug

---

## 5. Tech Stack

### Mobile (Flutter)
```
Flutter SDK              ^3.22+
Dart                     ^3.4+
State Management         Riverpod (flutter_riverpod)
Navigation               Go Router
Local Database           Drift + SQLite (battle-tested, query powerful)
GPS & Sensors            geolocator, sensors_plus
Peta Offline             flutter_map + tile caching (MBTiles)
Background GPS           flutter_background_service + Android Foreground Service
GPX                      gpx package (import & export)
Grafik & Chart           fl_chart
File Handling            path_provider, share_plus
Notifikasi Lokal         flutter_local_notifications
Connectivity             connectivity_plus
Audio (voice note)       record, just_audio
Kamera                   image_picker
Localization             flutter_localizations (ID + EN)
In-App Purchase          revenue_cat (fase freemium)
Crash Analytics          sentry_flutter
```

### Backend (opsional, fase lanjut — bukan MVP)
```
Runtime                  Node.js + Fastify
Database                 PostgreSQL + PostGIS
Auth                     Supabase Auth
Realtime                 Supabase Realtime (WebSocket)
Storage                  Supabase Storage (backup GPX & foto)
Hosting                  Railway / Fly.io
```

> **Catatan penting:** Semua fitur MVP berjalan 100% offline via Drift/SQLite lokal. Backend hanya diperlukan di fase Group Tracking dan Cloud Backup yang bukan bagian MVP.

### Infrastruktur Peta
```
Tile Source              OpenStreetMap (Humanitarian tiles — terbaik untuk Indonesia)
Tile Format              MBTiles (SQLite-based, efisien untuk offline)
Tile Cache               flutter_map tile provider dengan disk cache
Koordinat                WGS84 / EPSG:4326
Elevasi                  Sensor barometer (primary) + SRTM via open-elevation (fallback)
Lisensi                  ODbL — bebas dipakai, wajib atribusi OSM
```

---

## 6. Arsitektur Aplikasi

```
┌─────────────────────────────────────────────────────┐
│               PRESENTATION LAYER                    │
│   Screens, Widgets, Bottom Sheets, Dialogs          │
└──────────────────────┬──────────────────────────────┘
                       │
┌──────────────────────▼──────────────────────────────┐
│              APPLICATION LAYER                      │
│   Riverpod Providers, Use Cases, State Notifiers    │
└──────────────────────┬──────────────────────────────┘
                       │
┌──────────────────────▼──────────────────────────────┐
│                 DOMAIN LAYER                        │
│   Entities: Trip, TrackPoint, Checkpoint, Note      │
└──────────────────────┬──────────────────────────────┘
                       │
┌──────────────────────▼──────────────────────────────┐
│             INFRASTRUCTURE LAYER                    │
│   Drift DB │ GPS Service │ Map Tiles │ GPX Parser   │
│   File Storage │ Foreground Service │ HTTP Client   │
└─────────────────────────────────────────────────────┘
```

**Pattern:** Clean Architecture + Repository Pattern. Tiap fitur punya folder sendiri di `/features/`.

---

## 7. Fase Development

### Phase 1 — Project Foundation (Minggu 1–2)

**Goal:** Flutter project dan arsitektur dasar siap.

**Deliverables:**
- Flutter app diinisialisasi, package Android dikonfigurasi
- App name: Hike.id, codename HikeID terdokumentasi
- Folder structure Clean Architecture
- Riverpod dikonfigurasi
- Go Router dengan struktur navigasi dasar
- Theme structure untuk light/dark mode
- Struktur lokalisasi ID & EN (strings.arb)
- GitHub Actions workflow untuk release APK

**Acceptance Criteria:**
- App launch di Android emulator dan device fisik
- Release APK dapat diproduksi dari GitHub Actions
- Home screen tampil dengan navigasi dasar

---

### Phase 2 — Local Data Foundation (Minggu 3–4)

**Goal:** Persistensi lokal yang solid sebagai basis semua fitur.

**Deliverables:**
- Drift/SQLite database setup
- Model: Trip, TrackPoint, Checkpoint, Note, AppSettings
- Layout file storage lokal (foto, audio, GPX export, tile cache)
- Repository layer untuk tiap entity
- Basic CRUD operations

**Acceptance Criteria:**
- App bisa create, list, view, dan delete trip lokal
- Data persist setelah app restart
- File storage path konsisten di semua Android version

---

### Phase 3 — GPS Tracking Core (Minggu 5–6)

**Goal:** Rekam jalur hiking secara reliable.

**Deliverables:**
- Start / pause / resume / stop tracking
- Sampling track point (lat, lng, elevation, accuracy, timestamp)
- Kalkulasi jarak real-time (Haversine formula)
- Kalkulasi durasi & kecepatan
- Display koordinat & elevasi saat ini
- Accuracy indicator (weak / good / excellent)
- Auto-save setiap 30 detik (crash protection)

**Acceptance Criteria:**
- User bisa merekam trip
- User bisa simpan trip yang direkam
- User bisa lihat ringkasan rute yang direkam
- Data tidak hilang saat app di-force close

---

### Phase 4 — Background Tracking & Battery Modes (Minggu 7–8)

**Goal:** Tracking tetap aktif saat layar mati.

**Deliverables:**
- Android Foreground Service implementation
- Persistent notification selama tracking aktif (tampil jarak + durasi)
- 3 mode tracking:
  - **High Accuracy**: update 3–5 detik, GPS full power
  - **Balanced** (default): update 10–15 detik, adaptive
  - **Battery Saver**: update 30–60 detik, reduced frequency
- Peringatan battery sebelum mulai High Accuracy mode
- Setting pilih default tracking mode
- Estimasi konsumsi baterai per mode

**Acceptance Criteria:**
- Tracking continue dengan layar mati
- Persistent notification tampil & akurat
- User paham tradeoff baterai sebelum mulai
- Mode berpengaruh nyata pada interval & akurasi

---

### Phase 5 — Map & Strategi Offline (Minggu 9–10)

**Goal:** Tampilkan rute dan posisi di peta, siap offline.

**Deliverables:**
- flutter_map integration dengan OSM tiles
- Current location marker dengan direction indicator
- Polyline jalur yang direkam (warna aktif vs history)
- Polyline jalur GPX yang diimport
- Tile caching strategy (disk cache MBTiles)
- Indikator status offline
- Auto-follow posisi user (bisa dimatikan)
- Placeholder UI untuk download-area map (fitur future)

**Acceptance Criteria:**
- Rute tampil di peta
- App tetap berguna tanpa network
- Missing tiles tidak break tracking atau app crash
- Indikator offline jelas terlihat

---

### Phase 6 — GPX Import & Export (Minggu 11–12)

**Goal:** Interoperabilitas dengan tools outdoor lainnya.

**Deliverables:**
- GPX import dari file manager
- GPX validation & error handling yang readable
- Preview rute setelah import
- Simpan rute import sebagai local route template
- GPX export dari recorded trip (track points + timestamps)
- Opsional: checkpoint sebagai GPX waypoints di export
- Sample GPX files untuk keperluan testing

**Acceptance Criteria:**
- User bisa import GPX file
- User bisa follow imported GPX route
- User bisa export recorded trip sebagai GPX
- Error import tampil pesan yang manusiawi (bukan stack trace)
- Tested dengan GPX dari AllTrails, Wikiloc, Garmin

---

### Phase 7 — Checkpoint & Notes (Minggu 13–14)

**Goal:** Biarkan user menandai informasi penting di jalur.

**Deliverables:**
- Tambah checkpoint saat tracking aktif (tap lama peta atau FAB)
- Tipe checkpoint: Post, Air, Kemah, Puncak, Bahaya, Custom
- Ikon berbeda per tipe + warna berbeda
- Text note (standalone & terkait checkpoint)
- Photo note (dari kamera atau galeri)
- Voice note (rekam audio pendek)
- Media besar disimpan di file storage, bukan database row
- Lihat checkpoint di peta & trip detail

**Acceptance Criteria:**
- User bisa tandai checkpoint dengan cepat sambil berjalan
- Semua note tersedia offline
- Foto dan audio tersimpan lokal dengan benar
- Tap checkpoint di peta = tampil detail

---

### Phase 8 — Safety Features (Minggu 15–16)

**Goal:** Dukung keputusan pendakian yang lebih aman.

**Deliverables:**
- SOS screen (detail di bagian tersendiri)
- Off-route warning saat follow imported GPX
- Emergency contact storage (minimal 3 nomor)
- Share location via Android share sheet (WhatsApp, SMS, email)
- Basarnas info static: 115, regional contacts
- Battery low warning saat tracking (< 20% & < 10%)

**Acceptance Criteria:**
- SOS bisa dibuka bahkan offline
- User bisa copy koordinat offline
- User bisa share koordinat jika ada sinyal / apps lain
- Off-route warning muncul tanpa terlalu banyak false alert
- App TIDAK mengklaim bisa kirim rescue otomatis

---

### Phase 9 — Statistik Lanjut & UI Polish (Minggu 17–18)

**Goal:** Data bermakna + UI terasa premium dan nyaman outdoor.

**Deliverables:**

*Statistik:*
- Profil elevasi (grafik sepanjang jalur)
- Elevation gain / loss total
- Kecepatan rata-rata & pace
- Estimasi waktu ke tujuan (saat follow rute)
- Kompas / arah heading
- Statistik kumulatif semua pendakian (jarak total, jam, gunung)
- Grafik aktivitas bulanan
- Personal best tracking

*UI Polish:*
- Tracking screen bottom sheet (collapsed / expanded)
- Tombol aksi besar dan jelas
- Empty states yang informatif
- Error states yang helpful
- High contrast mode untuk outdoor
- Accessibility pass: kontras ratio, touch targets 48dp
- Onboarding flow (4 layar)

**Acceptance Criteria:**
- Tracking screen bisa digunakan sambil berjalan
- Aksi kritis mudah ditemukan
- UI terbaca di terik matahari dan kondisi malam

---

### Phase 10 — Freemium & Private Testing Release (Minggu 19–20)

**Goal:** APK siap distribusi ke private tester dan pondasi monetisasi.

**Deliverables:**
- Implementasi freemium paywall (RevenueCat)
- Feature gate: Free vs Pro (lihat tabel freemium)
- Release APK GitHub Actions workflow final
- Release checklist
- Known limitations didokumentasikan
- Test checklist: route, battery, offline, GPS accuracy
- Sentry crash analytics aktif
- Privacy policy dasar

**Acceptance Criteria:**
- Release APK bisa didownload dari GitHub Actions artifacts
- Private tester bisa install dan test app
- Crash reports masuk ke Sentry
- Fitur free/pro ter-gate dengan benar

---

## 8. Struktur Folder Project

```
hike_id/
├── lib/
│   ├── core/
│   │   ├── constants/         # warna, tema, strings keys
│   │   ├── extensions/        # extension methods
│   │   ├── utils/             # helpers: distance calc, GPX parse, dll
│   │   ├── theme/             # ThemeData light & dark
│   │   └── widgets/           # shared UI components
│   ├── features/
│   │   ├── map/               # peta & navigasi
│   │   ├── tracking/          # GPS tracking aktif
│   │   ├── checkpoint/        # manajemen checkpoint
│   │   ├── notes/             # text, foto, voice note
│   │   ├── history/           # riwayat pendakian
│   │   ├── gpx/               # import & export GPX
│   │   ├── sos/               # SOS & emergency
│   │   ├── statistics/        # statistik & grafik
│   │   ├── settings/          # pengaturan app
│   │   └── onboarding/        # first-run flow
│   ├── data/
│   │   ├── local/             # Drift tables & DAOs
│   │   ├── remote/            # HTTP clients (future)
│   │   └── repositories/      # repository implementations
│   ├── l10n/                  # ID & EN .arb files
│   └── main.dart
├── assets/
│   ├── fonts/
│   ├── icons/
│   ├── images/
│   └── samples/               # sample.gpx untuk testing
├── test/
├── .github/workflows/         # GitHub Actions APK build
└── pubspec.yaml
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

---

## 10. Freemium — Pembagian Fitur

### 🆓 Tier GRATIS
- GPS tracking real-time (unlimited trips)
- Peta offline cache (max 500MB)
- Checkpoint (max 5 per trip)
- Text note
- Riwayat pendakian (10 trip terakhir)
- SOS screen (**selalu gratis — non-negotiable**)
- Import GPX
- Export GPX (3x per bulan)
- Statistik dasar (jarak, durasi, elevasi)

### 👑 Tier PRO — Hike.id Pro
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

---

## 11. Risk Register

| Risiko | Dampak | Probabilitas | Mitigasi |
|---|---|---|---|
| Background tracking di-kill Android battery optimization | Tinggi | Tinggi | Foreground service + persistent notification + edukasi user |
| Battery drain di hiking panjang | Tinggi | Tinggi | 3 mode tracking + warning baterai, adaptive interval |
| OSM tile licensing issues | Tinggi | Rendah | Review kebijakan ODbL, user-managed cache strategy |
| GPS tidak akurat di bawah pohon / jurang | Medium | Tinggi | Tampilkan indikator akurasi, filter Kalman, sensor fusion |
| GPX file format bervariasi antar sumber | Medium | Medium | Validasi import, error message yang readable |
| SOS disalahartikan sebagai auto-rescue | Tinggi | Medium | Disclaimer eksplisit di SOS screen, tidak ada klaim otomatis |
| App crash saat tracking lama | Tinggi | Medium | Auto-save 30 detik, Foreground service, Sentry monitoring |
| Storage penuh karena tile cache | Medium | Medium | Batas cache configurable, auto-delete tile lama |
| App terlalu kompleks terlalu cepat | Medium | Medium | Build in phases, scope discipline ketat di MVP |

---

## 12. Open Decisions

- [ ] Final Android package name (`com.hikeid.app` atau lainnya)
- [ ] Apakah Play Store release pakai nama Hike.id atau nama legal lain (cek trademark)
- [ ] Tile provider final dan batas download area untuk tier gratis
- [ ] Apakah support GeoJSON setelah GPX MVP
- [ ] Apakah dummy/sample GPX disertakan di app untuk onboarding demo
- [ ] Backend hosting provider untuk fase Group Tracking (Railway vs Supabase full)

---

## 13. KPI & Definisi Sukses

| Metrik | Target Private Test | Target 3 Bulan Post-Launch | Target 6 Bulan |
|---|---|---|---|
| APK build sukses | 100% | — | — |
| Crash-free rate | > 95% | > 99% | > 99.5% |
| Tracking berjalan di background | Semua device test | — | — |
| GPS accuracy error | < 15 meter | < 10 meter | < 5 meter |
| Baterai Balanced mode | < 10%/jam | < 8%/jam | < 8%/jam |
| Downloads | — | 1.000 | 10.000 |
| Premium conversion | — | 2% | 5% |
| Store rating | — | > 4.3 | > 4.5 |
| Pendakian direkam | 20 (tester) | 500 | 5.000 |

---

*Dokumen ini adalah living document — diupdate tiap sprint review.*
*Perubahan major butuh approval sebelum implementasi.*
