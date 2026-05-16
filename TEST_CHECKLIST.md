# Test Checklist — Hike.id

Checklist untuk uji APK private testing di device fisik. Pakai sebelum bagikan APK ke tester eksternal, dan minta tester juga jalankan minimal **scope smoke**.

Format:
- ☐ = belum dites
- ✅ = pass
- ❌ = fail (buka issue)
- ➖ = N/A untuk device ini

## Setup

| Item | Detail |
|---|---|
| Device model | _______________________ |
| Android version | _______________________ |
| RAM | _______________________ |
| App version | _______________________ |
| APK variant | universal / arm64-v8a / armeabi-v7a / x86_64 |
| Tester | _______________________ |
| Tanggal | _______________________ |

## Scope: Smoke (15–30 menit, tanpa hike)

Wajib dijalankan sebelum bagikan APK.

### Install & Launch
- ☐ APK install tanpa error (allow "Install dari sumber tidak dikenal")
- ☐ App icon muncul di launcher
- ☐ Tap icon → app launch < 3 detik
- ☐ First-run: onboarding 3-screen muncul
- ☐ Onboarding "Lewati" / "Lanjut" bekerja
- ☐ Setelah onboarding selesai → home screen

### Permission
- ☐ App minta permission lokasi saat pertama buka tracking
- ☐ Permission "While using" diterima → GPS bisa fix
- ☐ Permission "Always" diterima → tracking lanjut di background
- ☐ Tolak permission → app kasih pesan jelas, tidak crash
- ☐ Permission notifikasi (Android 13+) diminta saat pertama mulai tracking

### Tracking dasar
- ☐ Tap "Mulai Hike" di home
- ☐ Start tracking sheet muncul → 3 mode option terlihat
- ☐ Pilih mode "Seimbang" → tap "Mulai Hike"
- ☐ Tracking screen terbuka → polyline mulai jalan saat berjalan
- ☐ Distance, duration, elevation update real-time
- ☐ Tap pause → tracking jeda, duration berhenti
- ☐ Tap resume → tracking lanjut
- ☐ Tap stop → confirm dialog → trip tersimpan
- ☐ Snackbar "Trip tersimpan" muncul → redirect ke history

### History & detail
- ☐ Trip baru muncul di history list
- ☐ Tap trip → detail screen terbuka
- ☐ Polyline trip ter-render di map
- ☐ Stat block (jarak, durasi, gain) tampil benar
- ☐ Elevation profile chart tampil (kalau >5 fix)
- ☐ Tombol export GPX bekerja → file ter-share/save

### SOS
- ☐ Buka SOS screen dari tracking screen ATAU dari menu
- ☐ Last-known location tampil dengan koordinat
- ☐ Tombol "Salin lokasi" → clipboard berisi koordinat
- ☐ Tombol "Share lokasi" → share sheet muncul
- ☐ Tambah kontak darurat → tersimpan
- ☐ Tap kontak → app dial bekerja (kalau ada SIM)
- ☐ Edit / delete kontak → bekerja

### Settings
- ☐ Buka settings dari home
- ☐ Ganti tema Light → instant change, konsisten di semua screen
- ☐ Ganti tema Dark → konsisten
- ☐ Ganti tema Outdoor → konsisten
- ☐ Default tracking mode bisa diubah → preference tersimpan
- ☐ Tutup app → buka lagi → preference masih tersimpan

### Connectivity & offline indicator
- ☐ Aktifkan airplane mode → banner "Mode Offline" muncul di atas tab
- ☐ Matikan airplane mode → banner hilang dalam beberapa detik
- ☐ Map online tetap berfungsi sebelum airplane mode diaktifkan (cached tile)

## Scope: Hike Mini (1–2 jam, jalur dekat / hutan kota)

Untuk verifikasi tracking realistis sebelum hike sungguhan.

### Akurasi GPS
- ☐ Mulai tracking di pintu masuk jalur, tunggu GPS lock (akurasi <15m)
- ☐ Track polyline mengikuti jalur secara umum, tidak meleset jauh
- ☐ Akurasi indicator (Good/Medium/Poor) bekerja
- ☐ Saat masuk hutan rapat, tracking tetap jalan (mungkin akurasi turun)

### Battery & background
- ☐ Mulai tracking, tutup app (home button) → notifikasi persistent muncul
- ☐ Buka app lain (browser, music) selama 30 menit → tracking lanjut
- ☐ Lock screen, taruh HP di saku 30 menit → tracking lanjut, polyline kontinu
- ☐ Buka app lagi → polyline lengkap, tidak ada gap besar
- ☐ Konsumsi baterai: catat % awal & akhir, hitung %/jam (bandingkan klaim PRD)

### Mode comparison (opsional, butuh 3 hike terpisah)
- ☐ Hike 1 jam mode High Accuracy → catat % drain
- ☐ Hike 1 jam mode Balanced → catat % drain
- ☐ Hike 1 jam mode Battery Saver → catat % drain

### Pause / resume di lapangan
- ☐ Pause saat istirahat 15 menit → distance & duration tidak naik
- ☐ Resume → tracking lanjut tanpa loncatan

### Checkpoint
- ☐ Tambah checkpoint via FAB saat sampai puncak / spot
- ☐ Long-press di map untuk tambah checkpoint di lokasi lain
- ☐ Checkpoint marker muncul di polyline
- ☐ Buka detail trip → list checkpoint lengkap

### Stop & save
- ☐ Tap stop di akhir hike → confirm → save
- ☐ Detail trip akhir lengkap dengan semua checkpoint
- ☐ Export GPX → import ke aplikasi lain (mis. Garmin Connect, Strava) → polyline cocok

## Scope: Hike Sungguhan (4+ jam, gunung beneran)

Wajib untuk validasi MVP. Lakukan di gunung dengan akses sinyal terbatas.

### Pre-hike
- ☐ Charge 100%, catat % awal
- ☐ Pilih mode Balanced atau Battery Saver (sesuai durasi rencana)
- ☐ Test offline indicator sebelum jalan: airplane mode → banner muncul
- ☐ Kontak darurat sudah ditambahkan

### Selama hike
- ☐ Tracking jalan kontinu (cek 30 menit sekali, polyline tidak putus)
- ☐ Notifikasi persistent stay terus (tidak hilang oleh battery optimization)
- ☐ HP bisa pause untuk foto / istirahat tanpa tracking berhenti
- ☐ Saat di luar sinyal (mode airplane otomatis dari hutan), tracking tetap jalan
- ☐ Rekam minimal 5 checkpoint (start, turning point, summit, dst.)
- ☐ Tambah note di minimal 1 checkpoint

### Edge case yang ingin ditest
- ☐ Off-route: keluar jalur >100m dari imported GPX → warning muncul
- ☐ Tap "Sengaja" pada warning → tidak muncul lagi untuk session ini
- ☐ Tap "Tutup" → muncul lagi nanti kalau masih off-route
- ☐ Battery sampai <20% → (US-SOS-03 belum live, hanya catat behavior)
- ☐ Force close app saat tracking aktif → buka lagi → trip ter-recover
- ☐ Restart device saat tracking aktif → buka app → trip ter-recover

### Post-hike
- ☐ Stop tracking → trip tersimpan
- ☐ % baterai akhir vs awal → hitung %/jam
- ☐ Total distance vs jarak GPX referensi (kalau ada) → margin <5%
- ☐ Total elevation gain reasonable (bandingkan dengan jalur publik)
- ☐ Export GPX → import di Garmin Connect / Strava → polyline cocok
- ☐ Statistik update (di tab Statistik) — total trips, jarak, gain naik

## Scope: Edge cases & stress

- ☐ Mulai tracking, langsung putar HP ke landscape → UI tidak rusak
- ☐ Multi-touch zoom map saat tracking → tidak ngelag, polyline tetap update
- ☐ Recording 100+ track points → memory tidak meledak, app tetap responsif
- ☐ Tutup app, restart device, buka app → tracking session lama (kalau ada) bisa di-resume / ditutup
- ☐ Permission lokasi ditolak (deny forever) → app tampilkan jalur ke settings
- ☐ Storage penuh → save trip kasih error message yang jelas
- ☐ Database corrupt (manual: hapus file db) → app launch tanpa crash, mulai fresh

## Reporting

Kalau ada item yang ❌:

1. Buka in-app bug reporter (Settings → Lapor bug).
2. Atau buka GitHub Issue: https://github.com/ssukahisyam/hike.id/issues
3. Sertakan: device model, Android version, app version, langkah reproduce, screenshot kalau ada.

Kalau item tidak applicable untuk skenario test, mark ➖.

---

**Catatan:** beberapa item dilist sebagai ☐ tapi sebenarnya **belum diimplementasikan** — lihat `KNOWN_LIMITATIONS.md` sebelum laporkan sebagai bug.
