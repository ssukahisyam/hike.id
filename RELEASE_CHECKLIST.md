# Release Checklist — Hike.id

Checklist sebelum kita tag rilis private testing baru. Bisa dipakai untuk verifikasi cepat sebelum push tag `vX.Y.Z`.

## 1. Pre-release (di branch / PR)

- [ ] Semua PR fitur untuk versi ini sudah di-merge ke `main`.
- [ ] CI hijau di `main` (lint, test, dan APK sanity build).
- [ ] `pubspec.yaml` `version:` sudah dinaikkan sesuai semver (lihat di bawah).
- [ ] `CHANGELOG.md` (kalau sudah ada) atau commit log terbaca rapi.
- [ ] Tidak ada `TODO(blocker)` atau `FIXME(release)` di code.
- [ ] Tidak ada print/log berlebihan di production path.
- [ ] `KNOWN_LIMITATIONS.md` di-update kalau ada hal baru yang belum bisa dites.

### Versioning

Format `pubspec.yaml`:

```
version: 0.1.0+1
         ^^^^^^ ^
         |      └── build number (incremental, naik tiap rilis)
         └────────── version name (semver: major.minor.patch)
```

| Perubahan | Naikkan |
|---|---|
| Bug fix kecil | patch (`0.1.0` → `0.1.1`) |
| Fitur baru, backward-compatible | minor (`0.1.x` → `0.2.0`) |
| Breaking change atau milestone besar | major (`0.x.y` → `1.0.0`) |
| **Selalu** | build number `+N` |

## 2. Build & Release

**Cara utama (manual dispatch — disarankan):**

1. Buka tab **Actions** di repo GitHub.
2. Pilih workflow **Release APK** di sidebar kiri.
3. Klik **Run workflow** (kanan atas).
4. Isi input:
   - **version**: nomor versi tanpa prefix `v`, mis. `0.1.0`. Akan otomatis jadi tag `v0.1.0` dan nama Release `Hike.id v0.1.0`.
   - **release_notes** (opsional): catatan singkat tentang rilis ini. Boleh kosong.
   - **prerelease**: `true` untuk private testing (default). Set ke `false` hanya kalau benar-benar siap publik.
5. Klik **Run workflow** hijau.
6. Tunggu ~10–15 menit. Workflow akan otomatis:
   - Build universal APK + split-per-ABI APKs.
   - Buat tag `v<version>` di commit `main` saat ini.
   - Buat GitHub Release dengan APK ter-attach.

**Cara alternatif (push tag — buat yang prefer git CLI):**

```bash
git checkout main
git pull
git tag v0.1.0
git push origin v0.1.0
```

Workflow yang sama akan trigger via tag push. Bedanya: tidak ada input `release_notes` & `prerelease` (default `prerelease=true`).

## 3. Verifikasi Release

- [ ] Run workflow sukses (Actions tab).
- [ ] Release page muncul di Releases tab dengan tag `v<version>`.
- [ ] APK ter-attach: `hikeid-<version>-universal.apk`, `*-arm64-v8a.apk`, `*-armeabi-v7a.apk`, `*-x86_64.apk`.
- [ ] Download `*-universal.apk`, install di minimal 1 device fisik.
- [ ] App launch tanpa crash.
- [ ] Onboarding screen muncul (first install) atau home screen (upgrade).

## 4. Smoke Test Wajib

Buka [`TEST_CHECKLIST.md`](./TEST_CHECKLIST.md). **Minimal scope smoke** sebelum bagikan APK ke tester:

- [ ] App launch & home screen
- [ ] Permission lokasi diminta dengan benar
- [ ] Mulai → pause → stop tracking dengan dummy walk 100m
- [ ] Trip tersimpan, muncul di history
- [ ] SOS screen bisa dibuka, kontak darurat bisa ditambah
- [ ] GPX export trip → file valid (cek di GPX viewer mana saja)
- [ ] Settings → ganti tema → konsisten
- [ ] Force close & reopen → trip aktif (kalau ada) ter-recover

Kalau salah satu gagal, **jangan** bagikan APK. Buka issue, fix, naikkan patch.

## 5. Distribusi ke Private Tester

- [ ] Share link Release ke grup tester (privat — jangan di publik).
- [ ] Sertakan instruksi install singkat (lihat `INSTALL_GUIDE.md`).
- [ ] Kasih link feedback (GitHub Issues atau email — sesuaikan).
- [ ] Set deadline test window (misal: 1 minggu) supaya feedback terkumpul.

## 6. Post-release

- [ ] Pantau crash report yang dikirim manual via in-app bug reporter.
- [ ] Kumpulkan feedback per kategori (UI, akurasi GPS, baterai, crash).
- [ ] Triage ke milestone berikutnya.
- [ ] Kalau ada blocker → patch release segera (tag baru).

## Ke depan: Production / Play Store

Saat siap publish ke Play Store closed testing, tambahan checklist:

- [ ] Generate keystore production (offline, di mesin lokal — TIDAK di CI).
- [ ] Setup `key.properties` lokal & GitHub Secrets untuk CI signing.
- [ ] Update `release_apk.yml` untuk decode keystore dari secret.
- [ ] Privacy policy live di URL publik.
- [ ] Play Console listing siap (screenshot, deskripsi, kategori).
- [ ] Build AAB (App Bundle), bukan APK.
- [ ] Upload ke Play Console internal/closed track.

Detailnya akan ditambah di [`docs/PRODUCTION_RELEASE.md`](./docs/PRODUCTION_RELEASE.md) saat sudah siap.
