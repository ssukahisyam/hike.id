# PRD — Product Requirements Document
## Hike.id — Offline-First Hiking Companion untuk Indonesia
> Codename: HikeID · Version: 1.1 · Status: Draft · Tanggal: Mei 2026
> Audience: developers, AI agents, product planning, private testing

---

## 1. Overview Produk

### Visi
Menjadi aplikasi pendakian #1 di Indonesia yang benar-benar bisa diandalkan di alam bebas — bekerja penuh tanpa internet, membantu pengguna tidak tersesat, merekam setiap petualangan, dan menyediakan informasi darurat yang bisa menyelamatkan nyawa.

### Problem Statement
Pendaki gunung di Indonesia menghadapi 3 masalah utama:
1. **Tersesat** — tidak ada navigasi offline yang reliabel untuk gunung Indonesia.
2. **Kecelakaan tanpa bantuan** — sulit minta tolong karena tidak ada sinyal, dan tools darurat terlalu rumit saat panik.
3. **Data pendakian hilang** — tidak ada catatan digital yang terstruktur, akurat, dan tersimpan lokal.

Banyak aplikasi existing terlalu bergantung pada koneksi online, terlalu generik, terlalu kompleks, atau tidak fokus pada kondisi hiking Indonesia.

### Solusi
Hike.id adalah aplikasi *offline-first* yang menggabungkan GPS tracking, peta offline OpenStreetMap, GPX interoperabilitas, checkpoint, catatan lapangan, sistem darurat SOS, dan statistik pendakian — dalam satu aplikasi ringan yang bekerja di atas gunung manapun.

---

## 2. Goals & Non-Goals

### Goals (MVP)
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
- Live tracking real-time (butuh sinyal terus-menerus)
- Dispatch rescue otomatis
- Komunikasi satelit
- Paket peta offline seluruh Indonesia pre-bundled
- Play Store release di milestone pertama
- Social / community trail sharing

---

## 3. Target Pengguna

| Persona | Karakteristik | Kebutuhan Utama |
|---|---|---|
| Pendaki Pemula | 18–28, baru 2–5x mendaki | Tidak tersesat, tenang dengan SOS |
| Pendaki Menengah | Sudah 10+ gunung | Recording, statistik, peta offline |
| Pendaki Berpengalaman | 20+ gunung, sering buat rute | GPX import/export, kontrol baterai |
| Koordinator Grup / Guide | Bawa rombongan | Checkpoint, ringkasan hike |
| Private Tester | Relawan pengujian | Install APK, laporkan bug |

---

## 4. Functional Requirements

### 4.1 App Foundation

| ID | Requirement |
|---|---|
| F-FOUND-01 | App berjalan di Android (minimal API 24 / Android 7.0) |
| F-FOUND-02 | Dibangun dengan Flutter `^3.22` |
| F-FOUND-03 | Support light mode, dark mode, dan outdoor mode (lihat DESIGN.md) |
| F-FOUND-04 | Lokalisasi: Indonesian (default) + English |
| F-FOUND-05 | Tidak butuh login untuk MVP |
| F-FOUND-06 | Semua fitur inti bekerja di Airplane Mode |
| F-FOUND-07 | Onboarding 4 layar, dapat di-skip |

---

### 4.2 Local Data

| ID | Requirement |
|---|---|
| F-DATA-01 | Simpan trip lokal (Drift/SQLite) |
| F-DATA-02 | Simpan track points lokal |
| F-DATA-03 | Simpan checkpoints lokal |
| F-DATA-04 | Simpan notes lokal (text, foto, voice) |
| F-DATA-05 | Simpan emergency contacts lokal |
| F-DATA-06 | Simpan settings lokal |
| F-DATA-07 | App berfungsi penuh tanpa internet setelah install pertama |
| F-DATA-08 | File besar (foto, audio) disimpan di file storage, bukan database row |
| F-DATA-09 | Schema migration tidak boleh kehilangan data user |

---

### 4.3 GPS Tracking

#### US-TRK-01 — Mulai Tracking
> Sebagai pendaki, saya ingin memulai tracking dengan satu ketukan sehingga bisa fokus mendaki tanpa setup yang rumit.

**Acceptance Criteria:**
- Tombol "Mulai Hike" terlihat jelas di home screen
- Tracking mulai dalam < 3 detik setelah tap (setelah GPS lock)
- Indikator aktif (pulsing dot) muncul di peta
- Koordinat GPS tampil di overlay peta
- Tracking terus berjalan saat layar mati
- Persistent notification muncul di notification bar
- Auto-save track points setiap 30 detik

#### US-TRK-02 — Pause & Resume
> Sebagai pendaki, saya ingin pause tracking saat istirahat sehingga jalur tidak terpotong tidak rapi.

**Acceptance Criteria:**
- Tombol pause tersedia & mudah dijangkau saat tracking aktif
- Saat pause: GPS update berhenti (hemat baterai)
- Data tersimpan sebelum pause
- Saat resume: garis jalur melanjutkan dari titik terakhir
- Durasi pause **tidak** dihitung dalam total durasi pendakian
- Visual indikator pause jelas (tidak ambigu)

#### US-TRK-03 — Selesai & Simpan
> Sebagai pendaki, saya ingin menyimpan pendakian dengan nama sehingga bisa dicari dan dikenang di kemudian hari.

**Acceptance Criteria:**
- Tap selesai → muncul summary screen (jarak, durasi, elevasi gain)
- User bisa beri nama trip dan pilih gunung (free text untuk MVP)
- Pilihan rating kesulitan (1–5)
- Cover foto opsional
- Data tersimpan lokal otomatis (auto-save tiap 30 detik)
- Konfirmasi dialog sebelum discard tracking aktif
- App recover tracking session setelah restart / crash

#### US-TRK-04 — Tracking Mode
> Sebagai pendaki, saya ingin pilih mode tracking sesuai kondisi sehingga bisa seimbangkan akurasi vs konsumsi baterai.

| Mode | Update | GPS Power | Use Case |
|---|---|---|---|
| High Accuracy | 3–5 detik | Full | Summit attempt, fotografi rute presisi |
| Balanced *(default)* | 10–15 detik | Adaptive | Pendakian normal |
| Battery Saver | 30–60 detik | Reduced | Hiking panjang, baterai limited |

**Acceptance Criteria:**
- User bisa pilih mode sebelum atau saat tracking
- Peringatan baterai muncul sebelum aktifkan High Accuracy
- Mode mempengaruhi nyata interval update dan akurasi
- Setting default mode tersimpan di preferences
- Switching mode saat tracking tidak menyebabkan data loss

#### US-TRK-05 — Recovery Setelah Crash
> Sebagai pendaki, saya ingin tracking saya tidak hilang kalau app crash sehingga data pendakian saya tetap aman.

**Acceptance Criteria:**
- App detect ada session aktif yang tidak ditutup secara normal
- Dialog recovery muncul saat app dibuka kembali
- Pilihan: lanjutkan tracking, simpan sebagai trip baru, atau buang
- Default action: lanjutkan tracking (paling aman)

---

### 4.4 Map & Offline

#### US-MAP-01 — Lihat Posisi di Peta Offline
> Sebagai pendaki, saya ingin lihat posisi saya di peta meski tidak ada sinyal sehingga tahu posisi saya relatif terhadap jalur.

**Acceptance Criteria:**
- Peta tampil dari tile cache lokal tanpa koneksi
- Posisi user: titik dengan direction indicator (heading kompas)
- Jalur direkam: polyline (warna sesuai DESIGN.md)
- Jalur GPX import: polyline (warna berbeda)
- Zoom in/out responsif < 100ms
- Auto-follow posisi user (toggle on/off)
- Banner "Mode Offline" saat tidak ada koneksi
- Missing tiles: tampil placeholder, tidak crash

#### US-MAP-02 — Tile Cache Offline
> Sebagai pendaki, saya ingin peta tetap tersedia meski tidak ada sinyal sehingga navigasi tetap bisa dilakukan di gunung.

**Acceptance Criteria:**
- Tile ter-cache otomatis saat browsing peta dengan koneksi
- Tile tersimpan di local storage (MBTiles via FMTC)
- Batas cache: 500MB (Free), unlimited (Pro)
- User bisa lihat berapa storage dipakai
- User bisa hapus cache per area
- Placeholder UI untuk fitur download-area sudah ada (fase future)

---

### 4.5 GPX Import & Export

#### US-GPX-01 — Import GPX
> Sebagai pendaki berpengalaman, saya ingin import rute GPX sehingga bisa follow jalur yang sudah dibuat sebelumnya.

**Acceptance Criteria:**
- User bisa pilih file GPX dari file manager (intent filter `.gpx`)
- GPX divalidasi strukturnya setelah dipilih
- Preview rute ditampilkan di peta sebelum disimpan
- Rute disimpan sebagai local route template
- Error import tampil pesan human-readable (bukan error code / stack trace)
- Tested dengan GPX dari AllTrails, Wikiloc, Garmin, OsmAnd, Strava

#### US-GPX-02 — Export GPX
> Sebagai pendaki, saya ingin export track yang direkam ke GPX sehingga bisa dibuka di aplikasi lain atau disimpan sebagai arsip.

**Acceptance Criteria:**
- Export tersedia dari trip detail screen
- GPX menyertakan track points + timestamps + elevation
- Checkpoint tersertakan sebagai GPX waypoints (opsional toggle)
- File bisa dishare via Android share sheet
- Export gratis 3x/bulan (Free), unlimited (Pro)
- Round-trip test: export → import dengan data identik

---

### 4.6 Checkpoint

Tipe checkpoint yang didukung:

| Tipe | Ikon (placeholder) | Use Case |
|---|---|---|
| Pos | flag | Pos pendakian resmi |
| Air | droplet | Sumber air minum |
| Kemah | tent | Area berkemah |
| Puncak | mountain-peak | Titik tertinggi / summit |
| Bahaya | alert-triangle | Area berbahaya, longsor, jurang |
| Custom | pin | Label bebas user |

#### US-CHK-01 — Tambah Checkpoint
> Sebagai pendaki, saya ingin tandai lokasi penting di jalur sehingga bisa jadi referensi saya dan orang lain.

**Acceptance Criteria:**
- FAB "+" saat tracking aktif = tambah checkpoint di posisi GPS saat ini
- Long-press di peta = tambah checkpoint di titik tersebut
- Dialog: nama, tipe, catatan teks opsional
- Ikon dan warna berbeda per tipe (sesuai DESIGN.md)
- Maksimal 5 checkpoint per trip (Free), unlimited (Pro)
- Checkpoint tampil di peta dan trip detail
- Aksi tambah checkpoint < 5 detik (3 tap maksimum)

#### US-CHK-02 — Edit & Hapus Checkpoint
**Acceptance Criteria:**
- Tap checkpoint di peta = tampil detail card
- Edit nama, tipe, catatan
- Hapus dengan konfirmasi
- Tidak bisa hapus checkpoint dari trip yang sudah selesai > 7 hari (mencegah edit history)

---

### 4.7 Notes

| Tipe | Free | Pro | Limit |
|---|---|---|---|
| Text note | ✅ | ✅ | Max 1000 karakter / note |
| Photo note | ❌ | ✅ | Max 10MB / foto, JPEG/PNG |
| Voice note | ❌ | ✅ | Max 3 menit, AAC/M4A |

**Acceptance Criteria (semua tipe):**
- Note bisa standalone atau terlampir ke checkpoint
- Semua note tersedia offline
- File besar di file storage, bukan DB row
- Photo note: dapat dari kamera atau galeri
- Voice note: visual waveform saat record + playback control
- Note bisa di-edit dan dihapus

---

### 4.8 Statistik

#### Saat Tracking (Live)

| Statistik | Update Frekuensi |
|---|---|
| Jarak tempuh | Real-time |
| Durasi aktif | Real-time |
| Elevasi saat ini | Real-time (barometer / GPS) |
| Elevasi gain / loss | Real-time |
| Kecepatan saat ini | Real-time |
| Kecepatan rata-rata | Real-time |
| Pace (mnt/km) | Real-time |
| Koordinat GPS | Real-time |
| Heading kompas | Real-time |
| Estimasi waktu ke tujuan | Saat follow GPX |

#### Trip Detail (Post-hike)

| Statistik | Tier |
|---|---|
| Jarak total | Free |
| Durasi total | Free |
| Durasi bergerak (exclude pause) | Free |
| Elevasi gain / loss / max | Free |
| Profil elevasi (grafik) | Free |
| Kecepatan rata-rata & maksimum | Free |
| Pace per km | Pro |
| Split per km | Pro |
| Heart rate (jika ada wearable di future) | Pro |

#### Statistik Personal Kumulatif (Pro)

- Total jarak semua pendakian
- Total jam mendaki
- Total elevasi gain
- Jumlah gunung yang dikunjungi
- Personal best: terpanjang, tertinggi, tercepat
- Grafik aktivitas bulanan (heatmap)

---

### 4.9 Off-Route Warning

**Acceptance Criteria:**
- Hanya aktif saat follow GPX route yang diimport
- Kalkulasi jarak current position ke nearest point di route (cross-track distance)
- Warning muncul jika melebihi threshold (default 100 meter)
- Warning: notifikasi + visual di peta, **bukan** dialog blocking
- Warning tidak terlalu sering (cooldown 60 detik antar warning)
- Threshold dapat dikonfigurasi di settings (Pro: custom 50–500m, Free: fixed 100m)
- Warning bisa di-mute per session jika user secara sengaja off-route

---

### 4.10 SOS & Keselamatan

> **PENTING:** SOS di Hike.id adalah *information screen* dan *sharing tool*, **bukan** layanan dispatch rescue otomatis. App tidak bisa mengirim bantuan secara mandiri. Disclaimer ini harus tampil di UI dengan jelas.

#### US-SOS-01 — SOS Screen
> Sebagai pendaki dalam situasi darurat, saya ingin akses cepat ke info lokasi sehingga bisa minta tolong dengan koordinat yang akurat.

**Acceptance Criteria:**
- SOS dapat diakses maksimal **2 tap** dari layar manapun
- Selalu tersedia offline — tidak butuh internet
- Tampil:
  - Koordinat terakhir (lat, lng) format DD dan DMS
  - Timestamp lokasi terakhir
  - Akurasi GPS (meter)
  - Elevasi saat ini
- Tombol **Salin Koordinat** (one tap ke clipboard)
- Tombol **Bagikan Lokasi** via Android share sheet (WhatsApp, SMS, email, dll)
  — hanya berfungsi jika ada sinyal atau app receiver compatible
- Kontak darurat yang sudah disimpan tampil di layar ini
- Nomor Basarnas nasional tampil statis: **115**
- Disclaimer jelas: *"App ini tidak mengirim rescue otomatis. Kamu harus menghubungi bantuan secara aktif."*
- SOS log tersimpan lokal (waktu, koordinat, action yang dilakukan)
- SOS button visual menonjol tapi tidak panic-inducing (lihat DESIGN.md)

#### US-SOS-02 — Kontak Darurat
> Sebagai pendaki, saya ingin simpan nomor darurat di app sehingga mudah diakses tanpa harus ingat nomornya.

**Acceptance Criteria:**
- Bisa simpan hingga 3 kontak darurat (nama + nomor + relasi opsional)
- Kontak tampil di SOS screen
- Tap nomor → buka dialer Android
- Tersimpan lokal, tidak dikirim ke server
- Validasi format nomor (Indonesia: +62 atau 0)

#### US-SOS-03 — Peringatan Baterai
**Acceptance Criteria:**
- Notifikasi lokal saat baterai < 20% dan tracking aktif
- Notifikasi kedua saat baterai < 10%
- Saran switch ke Battery Saver mode + tombol langsung switch
- Notifikasi tidak diulang dalam 5 menit untuk level yang sama

---

### 4.11 CI/CD

**Acceptance Criteria:**
- GitHub Actions build release APK (bukan debug APK)
- APK tersedia sebagai workflow artifact
- Build trigger: push ke `main` / manual workflow dispatch
- Build gagal = notifikasi di GitHub
- AAB untuk Play Store dapat ditambahkan nanti sebagai job terpisah
- APK signed dengan keystore yang disimpan di GitHub Secrets

---

## 5. Data Model

Skema diberikan dalam notasi seperti Drift / SQL untuk referensi developer.

### 5.1 Trip
```
Trip {
  id              TEXT PRIMARY KEY (UUID)
  name            TEXT NOT NULL
  mountain_name   TEXT
  difficulty      INTEGER         // 1..5
  cover_photo_uri TEXT
  started_at      INTEGER NOT NULL // epoch ms
  ended_at        INTEGER
  total_distance  REAL             // meter
  total_duration  INTEGER          // detik (active, exclude pause)
  elevation_gain  REAL             // meter
  elevation_loss  REAL             // meter
  max_elevation   REAL
  min_elevation   REAL
  avg_speed       REAL             // m/s
  max_speed       REAL
  status          TEXT             // active, paused, completed, discarded
  tracking_mode   TEXT             // high, balanced, saver
  source          TEXT             // recorded, imported_gpx
  created_at      INTEGER
  updated_at      INTEGER
}
```

### 5.2 TrackPoint
```
TrackPoint {
  id          INTEGER PRIMARY KEY AUTOINCREMENT
  trip_id     TEXT NOT NULL REFERENCES Trip(id) ON DELETE CASCADE
  latitude    REAL NOT NULL
  longitude   REAL NOT NULL
  elevation   REAL
  accuracy    REAL             // meter
  speed       REAL             // m/s
  heading     REAL             // degree 0..360
  timestamp   INTEGER NOT NULL // epoch ms
  is_paused   INTEGER          // 0 atau 1
}
INDEX (trip_id, timestamp)
```

### 5.3 Checkpoint
```
Checkpoint {
  id          TEXT PRIMARY KEY (UUID)
  trip_id     TEXT REFERENCES Trip(id) ON DELETE CASCADE
  type        TEXT NOT NULL    // pos, air, kemah, puncak, bahaya, custom
  name        TEXT NOT NULL
  description TEXT
  latitude    REAL NOT NULL
  longitude   REAL NOT NULL
  elevation   REAL
  created_at  INTEGER NOT NULL
}
```

### 5.4 Note
```
Note {
  id            TEXT PRIMARY KEY (UUID)
  trip_id       TEXT REFERENCES Trip(id) ON DELETE CASCADE
  checkpoint_id TEXT REFERENCES Checkpoint(id) ON DELETE SET NULL
  type          TEXT NOT NULL    // text, photo, voice
  content       TEXT             // text isi (untuk type text)
  file_path     TEXT             // path lokal foto/audio
  duration_ms   INTEGER          // untuk voice note
  latitude      REAL
  longitude     REAL
  created_at    INTEGER NOT NULL
}
```

### 5.5 EmergencyContact
```
EmergencyContact {
  id         TEXT PRIMARY KEY (UUID)
  name       TEXT NOT NULL
  phone      TEXT NOT NULL
  relation   TEXT
  priority   INTEGER             // 1..3
  created_at INTEGER NOT NULL
}
```

### 5.6 SosLog
```
SosLog {
  id          TEXT PRIMARY KEY (UUID)
  opened_at   INTEGER NOT NULL
  latitude    REAL
  longitude   REAL
  accuracy    REAL
  action      TEXT                 // opened, copied, shared, called
  share_via   TEXT                 // sms, whatsapp, email, etc
  trip_id     TEXT
}
```

### 5.7 AppSettings
```
AppSettings {
  key         TEXT PRIMARY KEY
  value       TEXT
  // contoh keys: tracking_mode_default, theme_mode, language,
  // off_route_threshold, tile_cache_limit_mb
}
```

### 5.8 Route (Imported GPX)
```
Route {
  id              TEXT PRIMARY KEY (UUID)
  name            TEXT NOT NULL
  description     TEXT
  source_file     TEXT
  total_distance  REAL
  total_elevation REAL
  imported_at     INTEGER
  // Track points disimpan di RoutePoint terpisah (mirror TrackPoint)
}
```

---

## 6. Screen Inventory

| ID | Screen | Tujuan | Akses Dari |
|---|---|---|---|
| S-01 | Onboarding | First-run intro 4 layar | Auto, first launch |
| S-02 | Permission Setup | Minta izin lokasi & notifikasi | Setelah onboarding |
| S-03 | Home / Dashboard | Tombol mulai hike + ringkasan | Bottom nav |
| S-04 | Map | Peta interaktif + tracking overlay | Bottom nav |
| S-05 | Tracking Active | Layar tracking aktif (bottom sheet) | Saat tracking |
| S-06 | Trip Summary | Ringkasan setelah selesai tracking | Setelah stop tracking |
| S-07 | History List | Daftar semua trip | Bottom nav |
| S-08 | Trip Detail | Detail satu trip (peta + stats + notes) | Tap trip dari history |
| S-09 | Trip Detail — Stats Tab | Profil elevasi, grafik | Tab di S-08 |
| S-10 | Trip Detail — Notes Tab | List notes & checkpoints | Tab di S-08 |
| S-11 | Add Checkpoint Dialog | Form tambah checkpoint | FAB tracking / long-press peta |
| S-12 | Add Note Dialog | Form tambah note | FAB tracking / dari checkpoint |
| S-13 | GPX Import Preview | Preview rute sebelum disimpan | Dari file picker |
| S-14 | GPX List | List rute yang sudah diimport | Drawer / settings |
| S-15 | SOS | Layar darurat | FAB persistent / long-press tombol fisik |
| S-16 | Emergency Contacts | Manage kontak darurat | Settings / SOS |
| S-17 | Settings | Pengaturan utama | Bottom nav / drawer |
| S-18 | Tracking Mode Settings | Pilih default mode | Settings |
| S-19 | Map & Storage Settings | Cache, tile, atribusi | Settings |
| S-20 | About / Legal | Versi, privacy, lisensi | Settings |
| S-21 | Paywall | Upgrade ke Pro | Saat hit limit free |
| S-22 | Stats Personal | Statistik kumulatif (Pro) | Bottom nav |
| S-23 | Crash Recovery | Dialog recovery setelah crash | Auto saat detect |

---

## 7. Non-Functional Requirements

### 7.1 Performance

| Metrik | Target |
|---|---|
| App launch (cold start) | < 2 detik |
| Peta render setelah pan/zoom | < 500ms |
| GPS lock (area terbuka) | < 10 detik |
| Database query (CRUD single row) | < 50ms |
| APK size (tanpa tile data) | < 25MB |
| UI frame rate | 60fps, no jank di tracking screen |
| Long track rendering | Simplify polyline > 5.000 points |
| Memory usage idle | < 150MB |
| Memory usage tracking aktif | < 250MB |

### 7.2 Battery

| Mode | Target Konsumsi |
|---|---|
| High Accuracy | < 15%/jam |
| Balanced | < 8%/jam |
| Battery Saver | < 4%/jam |
| Background vs foreground | Selisih < 2% |

### 7.3 Reliability

- Crash-free rate target: > 99% (setelah stable)
- Data tidak hilang saat app crash (auto-save 30 detik)
- GPS tracking tetap jalan saat layar mati
- App recover session tracking setelah restart
- Handle: GPS unavailable, permission denied, battery optimization aktif
- Handle: malformed GPX, storage penuh, file permission error

### 7.4 Usability

- SOS dapat diakses maksimal 2 tap dari layar manapun
- Semua tombol penting: min 48x48dp touch target
- Teks terbaca di sinar matahari langsung (kontras ratio > 7:1 untuk outdoor mode)
- Onboarding selesai < 2 menit
- Tidak butuh login untuk semua fitur core
- Semua critical action bisa dilakukan satu tangan

### 7.5 Accessibility

- Semua elemen interaktif punya `semanticLabel`
- Touch target minimum 48x48dp
- Kontras teks vs background:
  - Default: ratio ≥ 4.5:1 (WCAG AA)
  - Outdoor mode: ratio ≥ 7:1 (WCAG AAA)
- Support TalkBack (Android screen reader)
- Tidak menggunakan warna saja sebagai pembeda (selalu ada ikon/teks)
- Font size respect system setting (range 0.8x – 1.3x)
- Animation respect "Reduce Motion" Android setting

### 7.6 Compatibility

| Aspek | Detail |
|---|---|
| Android minimum | API 24 (Android 7.0 Nougat) |
| Coverage | ~95%+ devices Indonesia |
| Tested devices | Low-end (RAM 3GB), mid-range, flagship |
| Screen sizes | 5"–7" portrait primary, landscape supported |
| Orientation | Portrait primary, landscape opsional di peta |

### 7.7 Privacy & Security

- Data GPS user TIDAK dikirim ke server tanpa izin eksplisit (MVP: tidak pernah)
- Cloud sync: opt-in, bukan default (post-MVP)
- Tidak ada analytics yang kirim koordinat
- Emergency sharing: selalu butuh aksi eksplisit user
- Comply UU PDP Indonesia (No. 27/2022)
- Tidak ada iklan, tidak ada tracking pihak ketiga selain Sentry (crash only)
- Database lokal **tidak** dienkripsi di MVP (trade-off performance), tapi file foto/audio aman di scoped storage
- Privacy policy publik dan dapat diakses dari Settings

---

## 8. Android Permissions

| Permission | Kegunaan | Kapan Diminta |
|---|---|---|
| `ACCESS_FINE_LOCATION` | GPS tracking akurat | Saat pertama buka Map / mulai tracking |
| `ACCESS_BACKGROUND_LOCATION` | Tracking saat layar mati | Setelah fine location, dengan penjelasan |
| `FOREGROUND_SERVICE` | Background tracking service | Otomatis saat app install |
| `FOREGROUND_SERVICE_LOCATION` | Android 14+ requirement | Otomatis |
| `POST_NOTIFICATIONS` | Persistent tracking notification | Android 13+, saat mulai tracking |
| `READ_MEDIA_IMAGES` | Pilih foto untuk note | Saat tambah photo note (Android 13+) |
| `READ_EXTERNAL_STORAGE` | Foto pre-Android 13 | Saat tambah photo note (legacy) |
| `CAMERA` | Ambil foto langsung | Saat tambah photo note via kamera |
| `RECORD_AUDIO` | Voice note | Saat tambah voice note |
| `VIBRATE` | Haptic feedback | Otomatis |
| `WAKE_LOCK` | Pertahankan tracking saat dim screen | Otomatis saat tracking |

> **Prinsip:** Setiap permission dialog harus menjelaskan *mengapa* permission dibutuhkan dalam bahasa yang jelas. Jangan minta permission yang tidak dipakai.

---

## 9. Edge Cases & Error Handling

### 9.1 GPS & Location

| Skenario | Penanganan |
|---|---|
| Permission lokasi ditolak | Modal edukasi + tombol buka Settings |
| GPS off di device | Banner persistent + tombol shortcut Settings |
| Akurasi GPS sangat buruk (>50m) | Indikator merah, peringatan visual |
| GPS lock > 30 detik tidak dapat | Tombol "GPS sulit lock?" → tips troubleshooting |
| Lompat jauh antar track point (teleport bug) | Filter outlier > 200 m/detik, log untuk debug |

### 9.2 Storage

| Skenario | Penanganan |
|---|---|
| Storage penuh saat tracking | Stop new tile cache, lanjut tracking, banner peringatan |
| Storage penuh saat save photo | Toast error + saran clear cache |
| File foto/audio corrupt | Skip render, tampil placeholder, opsi delete |
| Database corrupt | Backup file user data sebelum migration mana mungkin |

### 9.3 GPX Import

| Skenario | Penanganan |
|---|---|
| File bukan GPX valid | Pesan: "File tidak terbaca sebagai GPX. Pastikan format benar." |
| GPX valid tapi tidak ada track | Pesan: "GPX ini tidak punya track. Apakah file waypoint?" |
| GPX terlalu besar (> 10MB) | Konfirmasi: "File besar (X MB). Lanjutkan?" |
| Import duplikat (nama sama) | Konfirmasi: replace / rename / batal |

### 9.4 Background Tracking

| Skenario | Penanganan |
|---|---|
| Foreground service di-kill OS | Auto-restart + notif: "Tracking di-restart, X detik data hilang" |
| Battery optimization aktif | Onboarding whitelist + dialog persistent |
| Notification dismissed user | Notif baru muncul, edukasi: "Notif harus aktif untuk tracking" |

### 9.5 Tracking State

| Skenario | Penanganan |
|---|---|
| Tracking > 24 jam | Auto-pause + dialog: "Trip masih aktif. Lanjutkan atau selesai?" |
| Tracking dengan kecepatan > 100 km/h | Filter outlier (kemungkinan user di kendaraan) |
| Stop tracking tanpa track point | Skip save, info: "Tidak ada data untuk disimpan" |

---

## 10. Freemium Feature Matrix

| Fitur | Gratis | Hike.id Pro |
|---|---|---|
| GPS Tracking | Unlimited | Unlimited |
| Peta Offline Cache | 500MB | Unlimited |
| Checkpoint per Trip | 5 max | Unlimited |
| Text Note | ✅ | ✅ |
| Photo Note | ❌ | ✅ |
| Voice Note | ❌ | ✅ |
| Riwayat Pendakian | 10 terbaru | Unlimited |
| SOS Screen | ✅ Selalu gratis | ✅ Selalu gratis |
| Import GPX | ✅ | ✅ |
| Export GPX | 3x/bulan | Unlimited |
| Export KML / PDF | ❌ | ✅ |
| Statistik Dasar | ✅ | ✅ |
| Statistik Lanjut + Grafik | ❌ | ✅ |
| Off-route Warning | Basic (100m) | Custom threshold |
| Dead Man's Switch | ❌ | ✅ |
| Group Tracking | ❌ | ✅ Max 10 orang |
| Cloud Backup | ❌ | ✅ |
| Offline Route Planning | ❌ | ✅ |
| Widget Layar Utama | ❌ | ✅ |

**Harga Pro:** Rp 29.000/bulan atau Rp 199.000/tahun

---

## 11. Localization

| Aspek | Detail |
|---|---|
| Bahasa utama | Indonesian (`id`) |
| Bahasa sekunder | English (`en`) |
| Format tanggal | Sesuai locale device |
| Format angka | Sesuai locale (koma vs titik desimal) |
| Format jarak | Metric (km, m) — fixed |
| Format kecepatan | km/h — fixed |
| Format koordinat | DD (decimal degrees) primary, DMS sebagai info tambahan |
| Format zona waktu | Local device timezone |
| String management | `flutter_localizations` + `.arb` files |
| Kode & docs teknikal | English |
| Default bahasa | Ikut bahasa system device, fallback ID |

**Tone of voice (lihat DESIGN.md untuk detail):**
- Bahasa Indonesia: santai-profesional, "kamu" (bukan "Anda" atau "lu")
- Bahasa English: clear, friendly, second-person

---

## 12. Integrasi Eksternal

| Layanan | Kegunaan | Offline? | Tier |
|---|---|---|---|
| OpenStreetMap | Tile peta dasar | ✅ setelah cache | Gratis |
| OpenTopoMap | Tile peta kontur (alternatif) | ✅ setelah cache | Gratis |
| open-elevation.com | Data SRTM elevasi fallback | ✅ setelah cache | Gratis |
| open-meteo.com | Cuaca & forecast | ❌ butuh sync | Gratis (future) |
| Supabase | Auth + Realtime + Backup | ❌ | Free tier (future) |
| RevenueCat | In-app purchase management | ❌ | Free tier |
| Sentry | Crash & error monitoring | ❌ | Free tier |
| GitHub Actions | Release APK CI/CD | ❌ | Free |

---

## 13. Analytics Events (Privacy-First)

Semua events anonymized. **Koordinat GPS tidak pernah dikirim.**

```
app_opened                      app_version, locale, theme_mode
tracking_started                mode, timestamp
tracking_ended                  duration, distance, elevation_gain    // tanpa koordinat
tracking_paused                 -
tracking_crashed_recovered      indikator reliability
gpx_imported                    source_app (jika dapat dideteksi)
gpx_export                      success, error_code
checkpoint_added                type                                   // tanpa koordinat
note_added                      type                                   // text, photo, voice
sos_screen_opened               timestamp, has_signal
sos_action                      copy / share / call
sos_shared_via                  sms / whatsapp / email
offline_mode_entered            duration_minutes
battery_warning_shown           level, mode
premium_upgrade_tapped          source_screen
premium_converted               plan: monthly / yearly
permission_granted              permission_name
permission_denied               permission_name
crash                           handled by Sentry
```

---

## 14. Acceptance Criteria — First Private APK

Sebuah build dianggap **siap untuk private testing** jika semua checklist ini terpenuhi.

### Fungsionalitas Core
- [ ] App bisa diinstall dari release APK (tidak perlu Play Store)
- [ ] App buka tanpa login
- [ ] User bisa start dan stop tracking session
- [ ] Tracking continue saat layar mati (test: layar mati 30 menit, cek track tidak terpotong)
- [ ] Trip tersimpan lokal dan tampil di riwayat
- [ ] Trip summary akurat (jarak, durasi, elevasi)
- [ ] GPX bisa diimport dari file manager
- [ ] GPX bisa diekspor dan dibuka di QGIS / AllTrails
- [ ] Peta tampil rute yang direkam
- [ ] SOS screen tampil koordinat terakhir
- [ ] SOS bekerja dalam Airplane Mode (tampil info + copy)

### Quality
- [ ] Tidak ada crash di happy path semua fitur
- [ ] App recover dari restart saat tracking aktif
- [ ] Light, dark, dan outdoor mode tampil benar
- [ ] Semua teks terbaca di luar ruangan (contrast check)
- [ ] Battery Balanced mode < 10%/jam dalam pengujian 2 jam

### Build
- [ ] GitHub Actions menghasilkan release APK yang bisa diinstall
- [ ] Sentry menerima event dari production build
- [ ] Known bugs dan limitasi terdokumentasi

---

## 15. Definition of Done — Per Fitur

Sebuah fitur dianggap **selesai** jika:

- [ ] Berfungsi penuh dalam Airplane Mode (jika relevan)
- [ ] Tidak ada data loss saat app di-force close
- [ ] Tested di low-end device (RAM 3GB, contoh: Redmi 9A)
- [ ] Loading time sesuai target performance
- [ ] UI mengikuti DESIGN.md (font, warna, spacing, touch target)
- [ ] Unit test coverage > 60% untuk business logic
- [ ] Tidak ada crash di happy path
- [ ] Accessibility: semua elemen interaktif punya `semanticLabel`
- [ ] String terlokalisasi (ID + EN tersedia)
- [ ] Error state ter-handle dengan pesan human-readable
- [ ] PR review approved oleh minimal 1 reviewer
- [ ] Manual smoke test dilakukan di device fisik

---

## 16. Future Features (Post-MVP)

- Akun user & login
- Cloud backup & sync
- Database trail gunung Indonesia yang dikurasi
- Community route sharing
- Ulasan & catatan kesulitan trail
- Group / team hiking mode (real-time, Pro)
- Live location sharing saat ada sinyal
- Play Store AAB release
- GeoJSON & KML import/export
- Integrasi cuaca real-time (open-meteo)
- Kalkulasi sunrise/sunset offline
- Integrasi perangkat satelit (Garmin inReach, SPOT)
- Apple Watch / Wear OS companion
- iOS release
- Rute populer crowdsourced

---

*PRD ini direview sebelum sprint planning tiap fase.*
*Perubahan scope butuh diskusi dan update dokumen ini.*
