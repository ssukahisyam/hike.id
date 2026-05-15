# 📋 PRD — Product Requirements Document
## Hike.id — Offline-First Hiking Companion untuk Indonesia
> Codename: HikeID | Version: 1.0 | Status: Draft | Tanggal: Mei 2026
> Audience: developers, AI agents, product planning, private testing

---

## 1. Overview Produk

### Visi
Menjadi aplikasi pendakian #1 di Indonesia yang benar-benar bisa diandalkan di alam bebas — bekerja penuh tanpa internet, membantu pengguna tidak tersesat, merekam setiap petualangan, dan menyediakan informasi darurat yang bisa menyelamatkan nyawa.

### Problem Statement
Pendaki gunung di Indonesia menghadapi 3 masalah utama:
1. **Tersesat** — tidak ada navigasi offline yang reliabel untuk gunung Indonesia
2. **Kecelakaan tanpa bantuan** — sulit minta tolong karena tidak ada sinyal, dan tools darurat terlalu rumit digunakan saat panik
3. **Data pendakian hilang** — tidak ada catatan digital yang terstruktur, akurat, dan tersimpan lokal

Banyak aplikasi existing terlalu bergantung pada koneksi online, terlalu generik, terlalu kompleks, atau tidak fokus pada kondisi hiking Indonesia.

### Solusi
Hike.id adalah aplikasi *offline-first* yang menggabungkan GPS tracking, peta offline OpenStreetMap, GPX interoperabilitas, checkpoint, catatan lapangan, sistem darurat SOS, dan statistik pendakian — dalam satu aplikasi ringan yang bekerja di atas gunung manapun.

---

## 2. Goals & Non-Goals

### Goals
- Rekam hiking track secara offline
- Follow GPX route yang diimport secara offline
- Tracking aktif saat layar mati (background mode)
- Statistik berguna selama dan setelah hike
- Tandai checkpoint dan catatan penting di jalur
- Bantu user share lokasi terakhir saat darurat (jika ada sinyal)
- Support private testing via release APK dari GitHub Actions
- Arsitektur siap untuk akun & cloud di masa depan

### Non-Goals (bukan bagian MVP)
- Login / akun user
- Cloud sync
- Live tracking (butuh sinyal terus-menerus)
- Dispatch rescue otomatis
- Komunikasi satelit
- Paket peta offline seluruh Indonesia
- Play Store release di milestone pertama
- Social / community trail sharing

---

## 3. Target Pengguna

- Pendaki pemula yang butuh panduan sederhana dan safety
- Pendaki menengah yang butuh recording, statistik, dan peta offline
- Pendaki berpengalaman yang butuh GPX import/export dan kontrol baterai
- Pemimpin grup / guide yang butuh checkpoint dan ringkasan hike
- Private tester sebelum public release

---

## 4. MVP Functional Requirements

### 4.1 App Foundation

- App berjalan di Android (minimal API 24 / Android 7.0)
- Dibangun dengan Flutter
- Support light mode dan dark mode
- Struktur teks Indonesian dan English (flutter_localizations)
- Tidak butuh login untuk MVP
- Semua fitur inti bekerja di Airplane Mode

---

### 4.2 Local Data

- Simpan trip lokal (Drift/SQLite)
- Simpan track points lokal
- Simpan checkpoints lokal
- Simpan notes lokal
- Simpan settings lokal
- App berfungsi penuh tanpa internet setelah install pertama
- File besar (foto, audio) disimpan di file storage, bukan database row

---

### 4.3 GPS Tracking

#### US-T01 — Mulai Tracking
```
Sebagai pendaki, saya ingin memulai tracking dengan satu ketukan
sehingga bisa fokus mendaki tanpa setup yang rumit.

Acceptance Criteria:
✓ Tombol "Mulai Hike" terlihat jelas di home screen
✓ Tracking mulai dalam < 3 detik setelah tap
✓ Indikator aktif (pulsing dot hijau) muncul di peta
✓ Koordinat GPS tampil di overlay peta
✓ Tracking terus berjalan saat layar mati
✓ Persistent notification muncul di Android notification bar
✓ Auto-save track points setiap 30 detik
```

#### US-T02 — Pause & Resume
```
Sebagai pendaki, saya ingin pause tracking saat istirahat
sehingga jalur tidak terpotong tidak rapi.

Acceptance Criteria:
✓ Tombol pause tersedia dan mudah dijangkau saat tracking aktif
✓ Saat pause: GPS update berhenti (hemat baterai)
✓ Data tersimpan sebelum pause
✓ Saat resume: garis jalur melanjutkan dari titik terakhir
✓ Durasi pause tidak dihitung dalam total durasi pendakian
```

#### US-T03 — Selesai & Simpan
```
Sebagai pendaki, saya ingin menyimpan pendakian dengan nama
sehingga bisa dicari dan dikenang di kemudian hari.

Acceptance Criteria:
✓ Tap selesai → muncul summary screen (jarak, durasi, elevasi gain)
✓ User bisa beri nama trip dan pilih gunung dari daftar
✓ Pilihan rating kesulitan (1–5)
✓ Cover foto opsional
✓ Data tersimpan lokal otomatis (auto-save tiap 30 detik selama tracking)
✓ Konfirmasi dialog sebelum discard tracking aktif
✓ App recover tracking session setelah restart / crash
```

#### US-T04 — Tracking Mode
```
Sebagai pendaki, saya ingin pilih mode tracking sesuai kondisi
sehingga bisa seimbangkan akurasi vs konsumsi baterai.

Mode:
- High Accuracy: update 3–5 detik, GPS full power, akurasi terbaik
- Balanced (default): update 10–15 detik, adaptive
- Battery Saver: update 30–60 detik, konsumsi minimal

Acceptance Criteria:
✓ User bisa pilih mode sebelum atau saat tracking
✓ Peringatan baterai muncul sebelum aktifkan High Accuracy
✓ Mode mempengaruhi nyata interval update dan akurasi
✓ Setting default mode tersimpan di preferences
```

---

### 4.4 Map & Offline

#### US-M01 — Lihat Posisi di Peta Offline
```
Sebagai pendaki, saya ingin lihat posisi saya di peta meski tidak ada sinyal
sehingga tahu saya berada di mana relatif terhadap jalur.

Acceptance Criteria:
✓ Peta tampil dari tile cache lokal tanpa koneksi
✓ Posisi user: titik dengan direction indicator
✓ Jalur direkam: polyline hijau
✓ Jalur GPX import: polyline biru/teal
✓ Zoom in/out responsif < 100ms
✓ Auto-follow posisi user (bisa dimatikan)
✓ Banner "Mode Offline" saat tidak ada koneksi
✓ Missing tiles tidak crash app — tampil placeholder abu-abu
```

#### US-M02 — Tile Cache Offline
```
Sebagai pendaki, saya ingin peta tetap tersedia meski tidak ada sinyal
sehingga navigasi tetap bisa dilakukan di gunung.

Acceptance Criteria:
✓ Tile ter-cache otomatis saat browsing peta dengan koneksi
✓ Tile tersimpan di local storage (MBTiles)
✓ Batas cache: 500MB (Free), unlimited (Pro)
✓ User bisa lihat berapa storage dipakai
✓ User bisa hapus cache per area
✓ Placeholder untuk fitur download-area sudah ada di UI (fase future)
```

---

### 4.5 GPX Import & Export

#### US-G01 — Import GPX
```
Sebagai pendaki berpengalaman, saya ingin import rute GPX
sehingga bisa follow jalur yang sudah dibuat sebelumnya.

Acceptance Criteria:
✓ User bisa pilih file GPX dari file manager
✓ GPX divalidasi strukturnya setelah dipilih
✓ Preview rute ditampilkan di peta sebelum disimpan
✓ Rute disimpan sebagai local route template
✓ Error import tampil pesan human-readable (bukan error code)
✓ Tested dengan GPX dari AllTrails, Wikiloc, Garmin, OsmAnd
```

#### US-G02 — Export GPX
```
Sebagai pendaki, saya ingin export track yang direkam ke GPX
sehingga bisa dibuka di aplikasi lain atau disimpan sebagai arsip.

Acceptance Criteria:
✓ Export tersedia dari trip detail screen
✓ GPX menyertakan track points + timestamps
✓ Checkpoint tersertakan sebagai GPX waypoints (opsional toggle)
✓ File bisa dishare via Android share sheet
✓ Export gratis 3x/bulan (Free), unlimited (Pro)
```

---

### 4.6 Checkpoint

Tipe checkpoint yang didukung:
- **Post** — pos pendakian resmi
- **Air** — sumber air minum
- **Kemah** — area berkemah
- **Puncak** — titik tertinggi / summit
- **Bahaya** — area berbahaya
- **Custom** — label bebas

#### US-C01 — Tambah Checkpoint
```
Sebagai pendaki, saya ingin tandai lokasi penting di jalur
sehingga bisa jadi referensi saya dan orang lain.

Acceptance Criteria:
✓ FAB "+" saat tracking aktif = tambah checkpoint di posisi GPS saat ini
✓ Tap lama di peta = tambah checkpoint di titik tersebut
✓ Dialog: nama, tipe, catatan teks opsional
✓ Ikon dan warna berbeda per tipe
✓ Maksimal 5 checkpoint per trip (Free), unlimited (Pro)
✓ Checkpoint tampil di peta dan trip detail
```

---

### 4.7 Notes

Tipe note yang didukung:

| Tipe | Free | Pro |
|---|---|---|
| Text note | ✅ | ✅ |
| Photo note | ❌ | ✅ |
| Voice note | ❌ | ✅ |

```
Acceptance Criteria (semua tipe):
✓ Note bisa standalone atau terlampir ke checkpoint
✓ Semua note tersedia offline
✓ File besar (foto, audio) di file storage, bukan DB row
✓ Foto: max 10MB, format JPEG/PNG
✓ Voice note: max 3 menit, format AAC/M4A
```

---

### 4.8 Statistik

Selama tracking dan di trip detail:

| Statistik | Saat Tracking | Trip Detail |
|---|---|---|
| Jarak | ✅ real-time | ✅ |
| Durasi | ✅ real-time | ✅ |
| Elevasi saat ini | ✅ | — |
| Elevasi gain / loss | ✅ | ✅ |
| Kecepatan rata-rata | ✅ | ✅ |
| Pace (mnt/km) | ✅ | ✅ |
| Koordinat GPS | ✅ | ✅ |
| Kompas / heading | ✅ | — |
| Profil elevasi (grafik) | — | ✅ |
| Est. waktu ke tujuan | ✅ (saat follow GPX) | — |
| Cuaca | Placeholder (future) | — |
| Sunrise/sunset | Placeholder (future) | — |

**Statistik Personal Kumulatif (Pro):**
- Total jarak semua pendakian
- Total jam mendaki
- Total elevasi gain
- Jumlah gunung yang dikunjungi
- Personal best: terpanjang, tertinggi, tercepat
- Grafik aktivitas bulanan (mirip GitHub contributions)

---

### 4.9 Off-Route Warning

```
Acceptance Criteria:
✓ Hanya aktif saat follow GPX route yang diimport
✓ Kalkulasi jarak current position ke nearest point di route
✓ Warning muncul jika melebihi threshold (default 100 meter)
✓ Warning: notifikasi + visual di peta, bukan dialog blocking
✓ Warning tidak terlalu sering (cooldown 60 detik antar warning)
✓ Threshold bisa dikonfigurasi di settings (future Pro feature)
```

---

### 4.10 SOS & Keselamatan

> ⚠️ **PENTING:** SOS di Hike.id adalah *information screen* dan *sharing tool*, **bukan** layanan dispatch rescue otomatis. App tidak bisa mengirim bantuan. Disclaimer ini harus tampil di UI dengan jelas.

#### US-S01 — SOS Screen
```
Sebagai pendaki dalam situasi darurat, saya ingin akses cepat ke info lokasi
sehingga bisa minta tolong dengan koordinat yang akurat.

Acceptance Criteria:
✓ SOS dapat diakses maksimal 2 tap dari layar manapun
✓ Selalu tersedia offline — tidak butuh internet
✓ Tampil: koordinat terakhir (lat, lng), timestamp, akurasi GPS, elevasi
✓ Tombol copy koordinat (satu tap ke clipboard)
✓ Tombol share via Android share sheet (WhatsApp, SMS, email, dll)
  — hanya berfungsi jika ada sinyal atau app yang compatible
✓ Kontak darurat yang sudah disimpan tampil di layar ini
✓ Nomor Basarnas nasional tampil statis: 115
✓ Disclaimer jelas: "App ini tidak mengirim rescue otomatis"
✓ SOS log tersimpan lokal (waktu, koordinat, action yang dilakukan)
```

#### US-S02 — Kontak Darurat
```
Sebagai pendaki, saya ingin simpan nomor darurat di app
sehingga mudah diakses saat dibutuhkan tanpa harus ingat nomornya.

Acceptance Criteria:
✓ Bisa simpan hingga 3 kontak darurat (nama + nomor)
✓ Kontak tampil di SOS screen
✓ Tap nomor → buka dialer Android
✓ Tersimpan lokal, tidak dikirim ke server
```

#### US-S03 — Peringatan Baterai
```
Acceptance Criteria:
✓ Notifikasi lokal saat baterai < 20% dan tracking aktif
✓ Notifikasi kedua saat baterai < 10%
✓ Saran switch ke Battery Saver mode
```

---

### 4.11 CI/CD

```
Acceptance Criteria:
✓ GitHub Actions build release APK (bukan debug APK)
✓ APK tersedia sebagai workflow artifact
✓ Build trigger: push ke branch main / manual workflow dispatch
✓ Build gagal = notifikasi di GitHub
✓ AAB untuk Play Store bisa ditambahkan nanti sebagai job terpisah
```

---

## 5. Non-Functional Requirements

### 5.1 Performance
```
App launch (cold start)       < 2 detik
Peta render setelah pan/zoom  < 500ms
GPS lock (area terbuka)       < 10 detik
Database query (CRUD)         < 50ms
APK size (tanpa tile data)    < 25MB
UI frame rate                 60fps, tidak ada jank di tracking screen
Long track rendering          Simplify polyline > 5.000 points
```

### 5.2 Battery
```
High Accuracy mode        < 15%/jam
Balanced mode             < 8%/jam (target)
Battery Saver mode        < 4%/jam
Background vs foreground  < 2% perbedaan konsumsi
```

### 5.3 Reliability
```
✓ Crash-free rate target: > 99% (setelah stable)
✓ Data tidak hilang saat app crash (auto-save 30 detik)
✓ GPS tracking tetap jalan saat layar mati
✓ App recover session tracking setelah restart
✓ Handle: GPS unavailable, permission denied, battery optimization
✓ Handle: malformed GPX, storage penuh, file permission error
```

### 5.4 Usability
```
✓ SOS dapat diakses maksimal 2 tap dari layar manapun
✓ Semua tombol penting: min 48x48dp touch target
✓ Teks terbaca di sinar matahari langsung (kontras ratio > 7:1)
✓ Onboarding selesai < 2 menit
✓ Tidak butuh login untuk semua fitur core
✓ Semua critical action bisa dilakukan satu tangan
```

### 5.5 Compatibility
```
Android minimum  API 24 (Android 7.0 Nougat) — covers 95%+ devices Indonesia
Tested devices   Low-end (RAM 3GB), mid-range, flagship
Screen sizes     5" – 7" (portrait primary, landscape supported)
```

### 5.6 Privacy & Security
```
✓ Data GPS user TIDAK dikirim ke server tanpa izin eksplisit (MVP: tidak pernah)
✓ Cloud sync: opt-in, bukan default (fase future)
✓ Tidak ada analytics yang kirim koordinat
✓ Emergency sharing: selalu butuh aksi eksplisit user
✓ Comply UU PDP Indonesia
✓ Tidak ada iklan, tidak ada tracking pihak ketiga
```

---

## 6. Android Permissions

| Permission | Kegunaan | Kapan Diminta |
|---|---|---|
| `ACCESS_FINE_LOCATION` | GPS tracking akurat | Saat pertama buka Map / mulai tracking |
| `ACCESS_BACKGROUND_LOCATION` | Tracking saat layar mati | Setelah fine location, dengan penjelasan |
| `FOREGROUND_SERVICE` | Background tracking service | Otomatis saat app install |
| `FOREGROUND_SERVICE_LOCATION` | Android 14+ requirement | Otomatis |
| `POST_NOTIFICATIONS` | Persistent tracking notification | Android 13+, saat mulai tracking |
| `READ_MEDIA_IMAGES` | Pilih foto untuk note | Saat tambah photo note |
| `CAMERA` | Ambil foto langsung | Saat tambah photo note via kamera |
| `RECORD_AUDIO` | Voice note | Saat tambah voice note |
| `VIBRATE` | Haptic feedback | Otomatis |

> **Prinsip:** Setiap permission dialog harus menjelaskan *mengapa* permission dibutuhkan dalam bahasa yang jelas. Jangan minta permission yang tidak dipakai.

---

## 7. Freemium Feature Matrix

| Fitur | 🆓 Gratis | 👑 Hike.id Pro |
|---|---|---|
| GPS Tracking | ✅ Unlimited | ✅ Unlimited |
| Peta Offline Cache | ✅ 500MB | ✅ Unlimited |
| Checkpoint per Trip | ✅ 5 max | ✅ Unlimited |
| Text Note | ✅ | ✅ |
| Photo Note | ❌ | ✅ |
| Voice Note | ❌ | ✅ |
| Riwayat Pendakian | ✅ 10 terbaru | ✅ Unlimited |
| SOS Screen | ✅ Selalu gratis | ✅ Selalu gratis |
| Import GPX | ✅ | ✅ |
| Export GPX | ✅ 3x/bulan | ✅ Unlimited |
| Export KML / PDF | ❌ | ✅ |
| Statistik Dasar | ✅ | ✅ |
| Statistik Lanjut + Grafik | ❌ | ✅ |
| Off-route Warning | ✅ Basic | ✅ Custom threshold |
| Dead Man's Switch | ❌ | ✅ |
| Group Tracking | ❌ | ✅ Max 10 orang |
| Cloud Backup | ❌ | ✅ |
| Offline Route Planning | ❌ | ✅ |
| Widget Layar Utama | ❌ | ✅ |

**Harga Pro:** Rp 29.000/bulan atau Rp 199.000/tahun

---

## 8. Localization

| Aspek | Detail |
|---|---|
| Bahasa utama | Indonesian (id) |
| Bahasa sekunder | English (en) |
| Format tanggal | Sesuai locale device |
| Format angka | Sesuai locale (koma vs titik desimal) |
| String management | flutter_localizations + .arb files |
| Kode & docs teknikal | English |
| Default bahasa | Ikut bahasa system device |

---

## 9. Integrasi Eksternal

| Layanan | Kegunaan | Offline? | Tier |
|---|---|---|---|
| OpenStreetMap | Tile peta dasar | ✅ setelah cache | Gratis |
| open-elevation.com | Data SRTM elevasi fallback | ✅ setelah cache | Gratis |
| open-meteo.com | Cuaca & forecast | ❌ butuh sync | Gratis (future) |
| Supabase | Auth + Realtime group + Backup | ❌ | Free tier (future) |
| RevenueCat | In-app purchase management | ❌ | Free tier |
| Sentry | Crash & error monitoring | ❌ | Free tier |
| GitHub Actions | Release APK CI/CD | ❌ | Free |

---

## 10. Analytics Events (Privacy-First)

Semua events anonymized. **Koordinat GPS tidak pernah dikirim.**

```
app_opened                          — versi app, locale
tracking_started                    — mode tracking, timestamp
tracking_ended                      — durasi, jarak, elevasi gain (tanpa koordinat)
tracking_crashed_recovered          — indikator reliability
gpx_imported                        — source: file manager
gpx_export                          — berhasil/gagal
checkpoint_added                    — tipe checkpoint (tanpa koordinat)
sos_screen_opened                   — timestamp (tanpa koordinat)
sos_shared                          — via: sms/whatsapp/email, status: sent/failed
offline_mode_entered                — durasi offline
battery_warning_shown               — level baterai, mode aktif
premium_upgrade_tapped              — dari screen mana
premium_converted                   — plan: monthly/yearly
```

---

## 11. Acceptance Criteria — First Private APK

Sebuah build dianggap **siap untuk private testing** jika semua checklist ini terpenuhi:

**Fungsionalitas Core:**
- [ ] App bisa diinstall dari release APK (tidak perlu Play Store)
- [ ] App buka tanpa login
- [ ] User bisa start dan stop tracking session
- [ ] Tracking continue saat layar mati (test: layar mati 5 menit, cek track tidak terpotong)
- [ ] Trip tersimpan lokal dan tampil di riwayat
- [ ] Trip summary akurat (jarak, durasi, elevasi)
- [ ] GPX bisa diimport dari file manager
- [ ] GPX bisa diekspor dan dibuka di QGIS / AllTrails
- [ ] Peta tampil rute yang direkam
- [ ] SOS screen tampil koordinat terakhir
- [ ] SOS bekerja dalam Airplane Mode (tampil info + copy)

**Quality:**
- [ ] Tidak ada crash di happy path semua fitur
- [ ] App recover dari restart saat tracking aktif
- [ ] Light mode dan dark mode tampil benar
- [ ] Semua teks terbaca di luar ruangan (contrast check)
- [ ] Battery Balanced mode < 10%/jam dalam pengujian 2 jam

**Build:**
- [ ] GitHub Actions menghasilkan release APK yang bisa diinstall
- [ ] Sentry menerima event dari production build
- [ ] Known bugs dan limitasi terdokumentasi

---

## 12. Definition of Done — Per Fitur

Sebuah fitur dianggap **selesai** jika:
- [ ] Berfungsi penuh dalam Airplane Mode (jika relevan)
- [ ] Tidak ada data loss saat app di-force close
- [ ] Tested di low-end device (RAM 3GB, contoh: Redmi 9A)
- [ ] Loading time sesuai target performance
- [ ] UI mengikuti design system (font, warna, spacing, touch target)
- [ ] Unit test coverage > 60% untuk business logic
- [ ] Tidak ada crash di happy path
- [ ] Accessibility: semua elemen interaktif punya semanticLabel
- [ ] String terlokalisasi (ID + EN tersedia)
- [ ] Error state ter-handle dengan pesan yang human-readable

---

## 13. Future Features (Post-MVP)

- Akun user & login
- Cloud backup & sync
- Database trail gunung Indonesia yang dikurasi
- Community route sharing
- Ulasan & catatan kesulitan trail
- Group / team hiking mode (real-time)
- Live location sharing saat ada sinyal
- Play Store AAB release
- GeoJSON & KML import/export
- Integrasi cuaca real-time
- Kalkulasi sunrise/sunset offline
- Integrasi perangkat satelit (Garmin inReach, SPOT)
- Apple Watch / Wear OS companion

---

*PRD ini direview sebelum sprint planning tiap fase.*
*Perubahan scope butuh diskusi dan update dokumen ini.*
