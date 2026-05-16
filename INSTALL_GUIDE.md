# Install Guide — Hike.id Private Testing

Panduan singkat untuk install APK private testing di device Android.

> **Penting:** APK ini adalah build **debug-signed** untuk uji internal. Jangan dibagikan publik (medsos, grup terbuka). Tunggu rilis Play Store untuk distribusi luas.

## Persyaratan Device

| Spec | Minimum |
|---|---|
| Android version | 7.0 (API 24) |
| Storage tersedia | ≥ 100 MB (app + DB lokal) |
| GPS | wajib (built-in semua HP modern) |
| RAM | 2 GB+ |

## Langkah Install

### 1. Cek arsitektur device (opsional, untuk hemat ukuran)

Mayoritas HP modern (>2018) pakai **arm64-v8a**. Kalau tidak yakin, pakai `*-universal.apk` — bekerja di semua arsitektur tapi sedikit lebih besar.

Cara cek (di HP):
- Settings → About phone → cari "CPU" atau "Architecture"
- Atau install app gratis "AIDA64" / "Droid Hardware Info"

| CPU info | APK |
|---|---|
| ARM64 / aarch64 | `*-arm64-v8a.apk` |
| ARMv7 / 32-bit | `*-armeabi-v7a.apk` |
| x86_64 (emulator) | `*-x86_64.apk` |
| Tidak yakin | `*-universal.apk` |

### 2. Download APK

Dari GitHub Releases atau link yang dibagikan (Google Drive, dll).

### 3. Izinkan install dari sumber tidak dikenal

Android **memblok** install APK dari luar Play Store secara default. Cara izinkan:

**Android 8.0+ (Oreo dan setelahnya):**
1. Tap file APK yang sudah di-download.
2. Akan muncul peringatan "Untuk keamanan, perangkatmu tidak diizinkan menginstall app dari sumber tidak dikenal."
3. Tap **Settings**.
4. Toggle "Izinkan dari sumber ini" untuk app yang kamu pakai (browser, file manager, dll).
5. Kembali → install dilanjutkan.

**Android 7.x dan sebelumnya:**
1. Settings → Security → centang "Sumber tidak dikenal".
2. Tap file APK → install.

### 4. Install

1. Tap APK file → tap **Install** di prompt.
2. Tunggu beberapa detik.
3. Setelah selesai, tap **Open** atau buka dari launcher.

### 5. Setup pertama kali

1. Onboarding 3-screen muncul → ikuti / skip.
2. Saat tap "Mulai Hike" pertama kali, app akan minta:
   - **Permission lokasi** — pilih "Saat menggunakan app" (atau "Setiap saat" untuk tracking di background).
   - **Permission notifikasi** (Android 13+) — pilih Allow supaya notif tracking persistent muncul.

3. (Opsional tapi disarankan) **Matikan battery optimization untuk Hike.id** supaya tracking tidak di-pause OS:
   - Settings → Apps → Hike.id → Battery → Unrestricted (atau "No restrictions").
   - Atau: Settings → Battery → Battery optimization → Hike.id → Don't optimize.

   **Kenapa:** Android Doze mode bisa sleep app yang dianggap idle. Untuk tracking GPS jangka panjang, ini harus dimatikan.

## Update ke Versi Baru

Tinggal install APK baru — **tidak perlu uninstall**. Data trip kamu akan ter-preserve (database lokal disimpan di app storage).

> **Catatan:** kalau update gagal dengan error "App not installed", bisa jadi karena keystore beda. Solusi: uninstall versi lama → install baru. **Data akan hilang** kalau cara ini dipakai (database di-clear oleh OS saat uninstall).

## Uninstall

Settings → Apps → Hike.id → Uninstall.

Atau: long-press icon di launcher → Uninstall.

## Troubleshooting

### "App not installed"
- Storage penuh? Bersihkan dulu.
- Versi sebelumnya pakai keystore beda? Uninstall versi lama dulu.

### App crash saat launch
- Cek Android version (minimum 7.0).
- Coba restart HP.
- Laporkan dengan detail device + Android version.

### GPS tidak fix
- Pastikan Location Services aktif di system settings.
- Buka outdoor / dekat jendela — fix awal butuh sinyal satelit langsung.
- Tunggu 30–60 detik di tempat terbuka untuk first fix.

### Notifikasi tracking hilang setelah beberapa jam
- Battery optimization belum dimatikan — lihat langkah 5.5 di atas.
- Beberapa OEM (Xiaomi, Huawei, Oppo) punya settings tambahan:
  - **Xiaomi/MIUI:** Security → Permissions → Autostart → enable Hike.id; Battery saver → No restrictions.
  - **Huawei/EMUI:** Phone Manager → Protected apps → enable Hike.id.
  - **Oppo/ColorOS:** Battery → Hike.id → Allow background activity.

### Permission lokasi ditolak permanen
- Settings → Apps → Hike.id → Permissions → Location → Allow.

## Privacy

- App **tidak** mengirim data lokasi ke server. Semua tracking disimpan lokal di device kamu.
- Tidak ada login / akun. Tidak ada analytics tracking pengguna.
- File GPX yang kamu export adalah punyamu sepenuhnya.
- Bug report dikirim manual via email atau GitHub issue — tidak otomatis.

Detail: lihat `PRIVACY.md` di repo.

## Feedback & Bug Report

Pakai salah satu:
- In-app bug reporter: Settings → Lapor bug
- GitHub Issue: https://github.com/ssukahisyam/hike.id/issues

Sertakan:
- Device model & Android version
- App version (lihat di Settings → About)
- Langkah reproduce
- Screenshot atau screen recording

Terima kasih sudah membantu uji Hike.id.
