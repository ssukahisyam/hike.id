# Privacy Policy — Hike.id

> **Status:** DRAFT untuk private testing. Versi final akan di-host di domain publik sebelum rilis Play Store. Direvisi terakhir: mengikuti tag rilis terakhir.

## TL;DR

- Hike.id **offline-first**. Semua data tracking disimpan **lokal di device kamu**.
- Kami **tidak punya server**. Tidak ada login. Tidak ada akun.
- Data lokasi kamu **tidak dikirim ke kami atau pihak ketiga manapun**.
- Yang dikirim ke pihak ketiga (kalau kamu pilih): peta tile dari OpenStreetMap saat online.
- Bug report dikirim **manual** olehmu via email/issue — tidak otomatis.

## Data yang Kami Kumpulkan

### Yang TIDAK kami kumpulkan

- Identitas pribadi (nama, email, nomor telepon)
- Lokasi GPS kamu (tetap di device, tidak pernah di-upload)
- Track GPX kamu
- Foto, voice note, catatan
- Behavioral analytics (klik, screen view, dwell time)
- Device fingerprint
- Crash log otomatis (untuk private testing)

### Yang disimpan di device kamu (lokal saja)

| Data | Lokasi | Tujuan |
|---|---|---|
| GPS track points | SQLite local DB | Render polyline trip, statistik |
| Trip metadata (nama, gunung, tanggal, jarak) | SQLite local DB | History list |
| Checkpoint (lokasi, label, deskripsi) | SQLite local DB | Marker di peta |
| Imported GPX routes | SQLite local DB | Off-route warning, navigasi |
| Emergency contacts | SQLite local DB | SOS screen |
| Settings (theme, default tracking mode) | SharedPreferences | Personalisasi |
| Cached map tiles | App cache | Tampil peta saat sedikit offline |

Data ini **hanya bisa diakses oleh app Hike.id** di device-mu. Kalau uninstall app, data **akan terhapus**.

### Yang Hike.id share dengan pihak ketiga (saat kamu pilih)

| Aksi | Pihak ketiga | Data yang share |
|---|---|---|
| Browse map online | OpenStreetMap tile server | IP address kamu, koordinat tile yang di-request |
| Export GPX → share | Aplikasi target (Drive, WhatsApp, dll) | File GPX yang kamu pilih |
| Tap nomor kontak darurat di SOS | OS dialer | Nomor yang kamu pilih |
| Lapor bug via email | Provider email kamu | Pesan + log yang kamu attach |

Kami **tidak** mengirim data ini atas nama kamu — kamu yang explicit memicu setiap aksi.

## Permission Yang Kami Minta

| Permission | Kenapa | Wajib? |
|---|---|---|
| `ACCESS_FINE_LOCATION` | Track GPS pendakian | Ya |
| `ACCESS_COARSE_LOCATION` | Fallback saat GPS belum lock | Ya |
| `ACCESS_BACKGROUND_LOCATION` | Tracking saat layar mati / app di background | Ya untuk tracking lengkap |
| `FOREGROUND_SERVICE` + `FOREGROUND_SERVICE_LOCATION` | Service persistent supaya OS tidak kill tracking | Ya |
| `POST_NOTIFICATIONS` | Tampilkan notifikasi tracking aktif & low-battery warning | Disarankan (Android 13+) |
| `WAKE_LOCK` | CPU stay awake selama tracking, layar boleh mati | Ya |
| `INTERNET` + `ACCESS_NETWORK_STATE` | Load tile peta online, deteksi status offline | Disarankan |
| `CAMERA` | Photo note (Phase 7 future) | Tidak (belum live) |
| `RECORD_AUDIO` | Voice note (Phase 7 future) | Tidak (belum live) |
| `READ_MEDIA_IMAGES` / `READ_MEDIA_AUDIO` | Akses foto/audio yang di-attach ke note | Tidak (belum live) |
| `VIBRATE` | Haptic feedback (mis. saat tap checkpoint) | Tidak |

## Data Retention

- Data lokal **selama kamu pakai app**. Tidak ada expiry otomatis.
- Kamu bisa **export semua trip** sebagai GPX kapan saja.
- Kamu bisa **delete trip individual** atau **clear all data** lewat Settings (kalau fitur tersedia di versi ini).
- Uninstall app → semua data device terhapus.

## Anak di bawah usia

Hike.id **tidak ditujukan untuk anak di bawah 13 tahun**. Kami tidak mengumpulkan data dari mereka secara sengaja. Kalau kamu tahu anak di bawah 13 menggunakan app, beri tahu orang tua agar uninstall.

## Perubahan kebijakan ini

Saat ada perubahan, kami akan update file ini di repo dan tag rilis akan menyebutkan di release notes. Untuk versi Play Store nanti, perubahan kebijakan akan diumumkan via in-app notification.

## Hak kamu (UU PDP — RI)

Sesuai UU 27/2022 Perlindungan Data Pribadi:

- **Hak akses:** kamu bisa export semua data lokal kamu via fitur GPX export.
- **Hak hapus:** uninstall app menghapus semua data lokal.
- **Hak portabilitas:** GPX export = format standar, bisa di-import ke app lain.
- **Hak keberatan:** jangan pakai app — tidak ada penalti.

Karena kami tidak punya server / akun, sebagian besar pertanyaan "how do I delete my account" tidak applicable — tidak ada akun untuk dihapus.

## Kontak

Pertanyaan privacy: buka GitHub Issue di https://github.com/ssukahisyam/hike.id/issues dengan label `privacy`.

(Email kontak akan ditambah saat sudah punya domain publik.)

---

**Catatan untuk versi Play Store nanti:**

Saat siap publish, dokumen ini akan:
1. Di-host di domain publik (mis. `hike.id/privacy` atau GitHub Pages).
2. URL-nya dimasukkan ke Play Console listing.
3. Section "Data safety" di Play Console diisi sesuai dokumen ini.
4. Kalau Sentry / analytics di-aktifkan, bagian "Yang TIDAK kami kumpulkan" perlu di-update.
