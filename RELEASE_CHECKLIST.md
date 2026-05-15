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

## 2. Build & Tag

```bash
# Pastikan di main yang sudah merged & up-to-date
git checkout main
git pull

# Tag dengan format vX.Y.Z (sama persis dengan version_name di pubspec)
git tag v0.1.0
git push origin v0.1.0
```

GitHub Actions akan otomatis:
1. Build universal + split-per-ABI APKs.
2. Upload sebagai artifact.
3. Create draft GitHub Release (prerelease=true) dengan APK ter-attach.

## 3. Verifikasi Release

- [ ] Run release workflow sukses (Actions tab).
- [ ] Release page muncul di Releases tab.
- [ ] Semua APK ter-attach: `*-universal.apk`, `*-arm64-v8a.apk`, `*-armeabi-v7a.apk`, `*-x86_64.apk`.
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
