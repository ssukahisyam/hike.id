# Hike.id

> *Setiap Langkah, Tercatat.*
>
> Offline-first hiking companion untuk pendaki gunung Indonesia.

Hike.id adalah aplikasi mobile (Flutter, Android-first) yang menggabungkan GPS tracking, peta offline OpenStreetMap, GPX import/export, checkpoint, catatan lapangan, sistem darurat SOS, dan statistik pendakian — dalam satu aplikasi ringan yang bekerja di gunung manapun, tanpa sinyal.

| Atribut | Detail |
|---|---|
| Codename | HikeID |
| Platform | Flutter (Android-first, iOS menyusul) |
| Distribusi awal | Private testing via release APK (GitHub Actions) |
| Map | OpenStreetMap + flutter_map |
| Database lokal | Drift / SQLite |
| Model bisnis | Freemium |
| Status | Pre-development (dokumentasi & desain) |

## Prinsip Inti

- **Offline-first** — semua fitur pendakian utama bekerja penuh tanpa internet.
- **Battery-aware** — 3 mode tracking (High Accuracy / Balanced / Battery Saver).
- **Safety-oriented** — SOS dapat diakses ≤ 2 tap, bahkan di Airplane Mode.
- **Honest by default** — app tidak mengklaim hal yang tidak bisa dilakukan (mis. auto-rescue).
- **Indonesia-first** — tone, palet, dan informasi disesuaikan dengan pendaki Indonesia.

## Dokumentasi

Tiga dokumen utama yang menjadi rujukan untuk pengembangan:

| Dokumen | Isi | Audience |
|---|---|---|
| [`PLANNING_HIKEID.md`](./PLANNING_HIKEID.md) | Roadmap 20 minggu, tech stack, fase development, freemium, risk register, KPI, testing strategy, team structure | Product Owner, Mobile Lead, semua kontributor |
| [`PRD_HIKEID.md`](./PRD_HIKEID.md) | Functional requirements, user stories, acceptance criteria, data model, screen inventory, NFR, edge cases, permissions | Developer, AI agent, QA, private tester |
| [`DESIGN.md`](./DESIGN.md) | Filosofi visual, brand voice, color & typography token, komponen, pattern screen, motion, mode (light/dark/outdoor), brand identity | Designer, Developer, brand stakeholder |

## Quick Start (Dokumen)

Kalau kamu baru di proyek ini, baca dengan urutan:

1. **README ini** — gambaran 1 menit.
2. **PLANNING_HIKEID.md** — pahami arah, fase, dan ruang lingkup.
3. **PRD_HIKEID.md** — pahami detail fitur dan data model.
4. **DESIGN.md** — pahami visual & UX language.

## Status MVP

MVP ditargetkan **20 minggu** sejak kickoff, dengan public beta **+6 minggu** setelah MVP. Lihat tabel milestone di `PLANNING_HIKEID.md` §9.

## Lisensi

To be decided. Atribusi pihak ketiga untuk OSM, Inter, JetBrains Mono, Lucide Icons dan lainnya didokumentasikan di `DESIGN.md` §14.
