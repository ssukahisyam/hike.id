# Known Limitations — Hike.id

Daftar jujur hal yang **belum bekerja** atau **belum lengkap** di build private testing saat ini. Tujuannya supaya tester tidak melaporkan sebagai bug, dan tim tahu prioritas backlog.

Mengikuti prinsip "Honest by default" (PRD §2 / DESIGN §1.4): kita jangan klaim hal yang tidak bisa kita lakukan.

> **Update terakhir:** mengikuti commit terakhir yang merge `feat/phase-10a-port-to-main`.

## 1. Background tracking & baterai

| Item | Status |
|---|---|
| Foreground service notification persistent | **Implementasi ada**, real-device test belum |
| Wake lock saat layar mati | Konfigurasi sudah, perlu uji 4+ jam di gunung |
| Battery optimization whitelist hint | Belum diimplementasikan — user harus matikan optimasi manual |
| Doze mode behavior pada Android 12+ | Belum diuji, kemungkinan tracking bisa pause beberapa menit |
| Survival 8+ jam di mode Battery Saver | Klaim PRD belum diverifikasi di lapangan |

## 2. Peta & offline

| Item | Status |
|---|---|
| Map online (OSM) | **Bekerja** — butuh sinyal saat pertama load tile |
| Tile cache offline (FMTC bulk download) | **Belum diimplementasikan** — tile yang sudah di-render bisa cached otomatis oleh OS, tapi tidak bisa pre-download area |
| MBTiles import | Belum diimplementasikan |
| Map style switcher (terrain / satellite) | Belum diimplementasikan |

**Konsekuensi praktis:** kalau kamu hike di area tanpa sinyal & belum pernah load map area itu, peta akan kosong. Track tetap tercatat, tapi map tidak menampilkan latar.

## 3. SOS & keamanan

| Item | Status |
|---|---|
| Last-known location share | **Bekerja** (offline, copy ke clipboard / share sheet) |
| Emergency contact CRUD | **Bekerja** |
| Off-route warning | **Bekerja** untuk imported route, threshold 100m |
| One-tap call darurat (112) | Pakai `url_launcher` ke `tel:` — perlu test di device fisik dengan SIM |
| Auto-rescue / auto-call when stranded | **Tidak akan dibuat** (tidak realistis tanpa sinyal — kita tidak janjikan) |
| SMS fallback ke kontak darurat saat tidak ada data | Belum diimplementasikan, perlu permission SMS |

## 4. GPX

| Item | Status |
|---|---|
| Export trip → GPX 1.1 | **Bekerja** |
| Import GPX → preview & save sebagai imported route | **Bekerja** |
| Edit trip metadata (name, mountain) sebelum export | **Bekerja** |
| Share via system share sheet | **Bekerja** |
| Open GPX dari file manager (deep link) | Manifest sudah configured, perlu test di device |

## 5. Notes & checkpoint

| Item | Status |
|---|---|
| Checkpoint dengan label, deskripsi, koordinat, elevation | **Bekerja** |
| Photo note (kamera + galeri) | **Belum diimplementasikan** |
| Voice note (record + playback) | **Belum diimplementasikan** |
| Edit / delete checkpoint setelah trip selesai | Perlu verifikasi di history detail screen |

## 6. Statistik

| Item | Status |
|---|---|
| Total trips, jarak, elevation gain | **Bekerja** |
| Personal best (longest, highest, fastest) | **Bekerja** |
| Monthly heatmap | **Bekerja** |
| Elevation profile chart | **Bekerja** |
| Pace / speed distribution chart | Belum diimplementasikan |

## 7. Onboarding & UX

| Item | Status |
|---|---|
| Onboarding 3-screen | **Bekerja** |
| Permission rationale dialog (lokasi) | Sebagian — pakai standar permission dialog OS |
| Empty state untuk semua list | **Bekerja** |
| Pull-to-refresh di history | Perlu verifikasi |
| Skeleton loading saat load besar | Belum standar di semua screen |

## 8. Theme

| Item | Status |
|---|---|
| Light, Dark, Outdoor (high contrast) modes | **Bekerja** |
| System mode follow | **Bekerja** |
| Color tokens konsisten (HColors only) | **Bekerja** — tidak ada hex literal di luar `color_tokens.dart` |

## 9. Internationalization

| Item | Status |
|---|---|
| Bahasa Indonesia (default) | **Bekerja** — semua strings via `app_id.arb` |
| Bahasa Inggris | Sebagian — beberapa string (Phase 4) masih hardcoded ID, belum di ARB |
| Pluralization | Belum dipakai (tidak banyak butuh) |

## 10. Crash & error reporting

| Item | Status |
|---|---|
| In-app bug reporter (mailto + log copy) | **Bekerja** (Phase 10a) |
| Sentry / Firebase Crashlytics | **Belum diimplementasikan** — crash silent untuk tester saat ini |
| Privacy policy URL | Draft di repo (`PRIVACY.md`), belum live di domain publik |

## 11. Distribution

| Item | Status |
|---|---|
| GitHub Actions release APK | **Bekerja** |
| Debug-signed APK untuk private testing | **Bekerja** |
| Split-per-ABI APKs | **Bekerja** |
| Play Store closed testing | **Belum** — direncanakan setelah private testing pass |
| Production signing keystore | **Belum** — direncanakan saat siap publish |
| App Bundle (AAB) | **Belum** — APK saja untuk private testing |

## 12. iOS

| Item | Status |
|---|---|
| iOS support | **Belum** — Android-first per PLANNING §2 |
| iOS-specific permission dialog | Code path ada (AppleSettings di gps_service), belum diuji |
| iOS background mode | Belum di-setup di Info.plist |

---

## Bukan Limitation, Tapi Sengaja Tidak Dibuat

Beberapa hal yang **sengaja kita tidak janjikan** sesuai prinsip "Honest by default":

- **Auto-rescue** — kita tidak punya integrasi BASARNAS otomatis. SOS mengandalkan share lokasi ke kontak darurat.
- **Real-time team tracking** — bukan fitur MVP, dan butuh server (kita offline-first).
- **Heart rate / fitness sensor** — di luar fokus pendakian.
- **Sosial feed (like, follow)** — bukan fokus produk.
- **Auto-detect summit** — pakai checkpoint manual saja, lebih jujur.

---

Kalau menemukan hal **di luar daftar ini** yang tidak bekerja → silakan laporkan via bug reporter di app atau buka issue di GitHub.
