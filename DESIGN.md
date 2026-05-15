# DESIGN — Hike.id
> Design System & Visual Language
> Codename: HikeID · Version: 1.0 · Tanggal: Mei 2026
> Audience: designers, developers, AI agents, brand stakeholders

---

## 0. Cara Membaca Dokumen Ini

Dokumen ini adalah **single source of truth** untuk semua keputusan visual & interaksi di Hike.id. Strukturnya:

1. **Filosofi & Brand Voice** — kenapa kita memilih estetika ini
2. **Token Sistem** — warna, typography, spacing, radius, shadow
3. **Komponen** — bagaimana token disusun jadi UI
4. **Pattern** — bagaimana komponen dikomposisi jadi screen
5. **Motion & Haptic** — bagaimana app terasa
6. **Mode** — light, dark, outdoor
7. **Aset Brand** — logo, ikon, atribusi

> **Aturan emas:** kalau ada bentrokan antara file ini dengan implementasi, file ini menang. Update dokumen sebelum implementasi.

---

## 1. Filosofi Desain

### 1.1 Tagline Visual
> *Quiet Confidence. Built for the Trail.*

### 1.2 Vibe yang Kita Tuju

Hike.id punya audiens Gen Z yang aktif dan sadar estetika — tapi target user ada di gunung, bukan di feed Instagram. Itu berarti:

| Kita Tuju | Kita Hindari |
|---|---|
| Editorial, calm, premium | Neon, glitter, glow |
| Outdoor Indonesia yang otentik | Stock-photo "mountain vibes" generik |
| Mono-font untuk angka (technical-cool) | Bubble font, comic, novelty |
| Palet earthy + 1 aksen tegas | Pelangi, gradient 5 warna |
| Whitespace generous | Padat, pakai semua sudut layar |
| Animasi halus & purposeful | Bounce berlebihan, parallax kacau |
| Bahasa "kamu", santai-tegas | "Anda" formal · "lu/gw" cringe · over-emoji |
| Foto otentik gunung Indonesia | Render 3D, ilustrasi cute |

**Referensi vibe (bukan untuk dijiplak, untuk dirasakan):**
- Komoot — clarity & trail-focus
- AllTrails redesign 2024 — outdoor premium
- Linear app — typographic discipline
- Arc Browser — confident negative space
- Apple Maps in dark mode — informasi padat tapi tenang
- Outdoor Voices, Snow Peak — earthy palette

### 1.3 5 Prinsip Desain

1. **Legible First** — bisa dibaca di terik matahari sambil ngos-ngosan. Kontras dan ukuran > dekorasi.
2. **One-Hand Friendly** — semua aksi kritis bisa dijangkau jempol satu tangan.
3. **Honest Hierarchy** — angka penting paling besar; estetika tidak menutupi data.
4. **Calm in Chaos** — saat user panik (SOS, baterai habis), UI harus *menenangkan*, bukan menambah panik.
5. **Indonesia, Not Globalish** — palet, tipografi, dan tone bicara harus terasa milik pendaki Indonesia, bukan terjemahan dari Bay Area.

---

## 2. Brand Voice (Tone of Copy)

### 2.1 Voice DNA

| Atribut | Skala | Posisi Hike.id |
|---|---|---|
| Formal — Santai | 0–10 | **6** (cenderung santai, tapi tidak slang) |
| Serius — Playful | 0–10 | **4** (lebih serius, sesekali wit) |
| Pendek — Detail | 0–10 | **3** (pendek, langsung) |
| Hangat — Distan | 0–10 | **7** (hangat, peduli) |

### 2.2 Aturan Copy

- Pakai **"kamu"**. Tidak pernah "Anda" (terlalu formal) atau "lu/gw" (cringe).
- Kalimat pendek. Maksimum 12 kata per kalimat di UI.
- Angka pakai numeral, bukan dieja: "5 km", bukan "lima kilometer".
- Tidak ada exclamation mark di state normal. Hanya untuk peringatan urgent.
- Emoji: **dilarang di UI inti**. Boleh di copy marketing (max 1 per screen).
- Hindari jargon hiking yang tidak universal ("kompas anginan", dll).

### 2.3 Contoh Copy

| Situasi | Yang BENAR | Yang SALAH |
|---|---|---|
| Tombol mulai | `Mulai Hike` | `Yuk Mulai Petualanganmu! 🏔️` |
| Empty history | `Belum ada hike. Sini mulai yang pertama.` | `Wah masih kosong nih bestie!` |
| GPS lemah | `Sinyal GPS lemah. Pindah ke area terbuka.` | `OOPS! Gak dapet sinyal :(` |
| SOS disclaimer | `Hike.id tidak mengirim rescue otomatis. Hubungi bantuan secara aktif.` | `Tenang ya, kita bakal bantu kok!` |
| Paywall | `Buka semua fitur. Rp 29.000 / bulan.` | `Upgrade SEKARANG! Limited offer 🔥` |

---

## 3. Color System

### 3.1 Filosofi Warna

Palet Hike.id terinspirasi dari **landscape gunung Indonesia di pagi hari**:
- Hijau lumut (`forest`) — vegetasi tropis pegunungan
- Tanah vulkanik (`volcanic`) — basal & lahar
- Kabut subuh (`mist`) — gradient dingin
- Cahaya matahari pagi (`alpenglow`) — warna aksen

Bukan palet "outdoor generik" tipikal Patagonia stock. Ini Indonesia.

### 3.2 Core Palette

#### Primary — Forest (jangan disebut "hijau saja")
```
forest/50    #F2F7F3     // background tint
forest/100   #DCEAE0
forest/200   #B6D2BF
forest/300   #87B294
forest/400   #5A8E69
forest/500   #2F6A40     // PRIMARY
forest/600   #275836
forest/700   #1F4429
forest/800   #16321F
forest/900   #0E2014     // background dark mode primer
```

#### Secondary — Volcanic
```
volcanic/50   #F8F6F4
volcanic/100  #ECE7E1
volcanic/200  #D4CBBF
volcanic/300  #B5A595
volcanic/400  #8E7B6A
volcanic/500  #6B5A4A
volcanic/600  #524539
volcanic/700  #3C3329
volcanic/800  #2A241D
volcanic/900  #1A1611
```

#### Accent — Alpenglow (dipakai sangat hemat — hanya untuk aksi penting & active state)
```
alpenglow/300  #FDB36A
alpenglow/400  #FA9540    // ACCENT
alpenglow/500  #E87320
alpenglow/600  #C25A12
```

#### Neutral — Mist (UI surfaces)
```
mist/0     #FFFFFF
mist/50    #FAFAF9
mist/100   #F2F2F0
mist/200   #E4E4E1
mist/300   #C9C9C4
mist/400   #A1A19B
mist/500   #75756F
mist/600   #56564F
mist/700   #3E3E38
mist/800   #28281F     // surface dark mode
mist/900   #15150F     // background dark mode
mist/950   #0A0A06     // outdoor mode background
```

### 3.3 Semantic Colors

Setiap warna semantik punya 3 token: `background`, `foreground` (teks di atas bg), dan `border`.

```
success    bg #1F4429    fg #DCEAE0    border #2F6A40    // forest-aligned
warning    bg #5C4318    fg #FDB36A    border #FA9540    // alpenglow muted
danger     bg #5A1F22    fg #F4D5D7    border #C8413E    // volcanic-red
info       bg #1F3A4D    fg #C5DCED    border #3E7195    // mist-cyan
```

Catatan: warna danger dipakai sangat hemat. SOS button **tidak** pakai full red — pakai alpenglow karena tujuannya menenangkan, bukan panik (lihat §6.2).

### 3.4 Specialty Colors (Map & Tracking)

```
track/active       #2F6A40   forest/500   // jalur sedang direkam
track/history      #6B5A4A   volcanic/500 // trip lama di peta
track/imported     #3E7195   mist-cyan    // GPX yang diimport untuk diikuti
gps/excellent      #2F6A40   forest/500
gps/good           #FA9540   alpenglow/400
gps/weak           #C8413E   danger
elevation/high     #FDB36A   alpenglow/300
elevation/mid      #87B294   forest/300
elevation/low      #1F4429   forest/700
```

### 3.5 Aturan Penggunaan

- **80% surface** harus mist (netral). Forest dan volcanic dipakai untuk struktur dan branding.
- **Alpenglow hanya untuk aksi paling penting** di satu screen — biasanya 1 tombol primary, atau active state. Jangan pernah dipakai untuk dekorasi.
- **Gradient terbatas** ke dua titik adjacent dalam satu palette (mis. `forest/500 → forest/700`). Tidak ada gradient pelangi.
- **Kontras minimum:**
  - Body text: ratio ≥ 4.5:1 (WCAG AA)
  - Outdoor mode: ratio ≥ 7:1 (WCAG AAA)

### 3.6 Hindari

- Pure black `#000000` — terlalu keras. Pakai `mist/950` atau `forest/900`.
- Pure white di dark mode — silau. Pakai `mist/50`.
- Warna brand outdoor cliché: orange-magenta gradient, "adventure red".
- Lebih dari 2 warna semantik di satu screen (kecuali map markers).

---

## 4. Typography

### 4.1 Filosofi

Dua keluarga font, dipilih untuk membangun ketegangan editorial-technical yang khas Gen Z mature:

- **Display & body** — humanist sans serif, hangat & terbaca
- **Stats & koordinat** — geometric monospace, technical & precise

Kombinasi ini terasa seperti notebook lapangan + aplikasi profesional, bukan poster festival.

### 4.2 Font Stack

| Role | Font | Fallback |
|---|---|---|
| Display & UI | **Inter** | system-ui, -apple-system, "Helvetica Neue", sans-serif |
| Mono & Stats | **JetBrains Mono** | "SF Mono", "Roboto Mono", monospace |
| Editorial (opsional, hanya untuk hero / quote) | **Fraunces** (variable, soft optical) | Georgia, serif |

> Inter dan JetBrains Mono open-source dan sudah teroptimasi untuk layar. Fraunces dipakai sangat selektif — hanya untuk headline marketing atau onboarding.

### 4.3 Type Scale (rem-based, mobile)

| Token | Font | Size | Line-height | Weight | Letter-spacing | Use Case |
|---|---|---|---|---|---|---|
| `display/xl` | Inter | 36 | 40 | 600 | -0.02em | Onboarding headline |
| `display/lg` | Inter | 28 | 34 | 600 | -0.01em | Screen title hero |
| `heading/xl` | Inter | 22 | 28 | 600 | -0.01em | Section header |
| `heading/lg` | Inter | 18 | 24 | 600 | 0 | Card title |
| `heading/md` | Inter | 16 | 22 | 600 | 0 | Subheader |
| `body/lg` | Inter | 16 | 24 | 400 | 0 | Body default |
| `body/md` | Inter | 14 | 20 | 400 | 0 | Secondary body |
| `body/sm` | Inter | 12 | 18 | 400 | 0.01em | Caption, helper |
| `label/lg` | Inter | 14 | 18 | 500 | 0.02em | Button label |
| `label/md` | Inter | 12 | 16 | 600 | 0.04em | Tag, chip (UPPERCASE) |
| `mono/xl` | JetBrains | 32 | 36 | 500 | -0.01em | Stat hero (jarak besar) |
| `mono/lg` | JetBrains | 22 | 28 | 500 | 0 | Stat utama |
| `mono/md` | JetBrains | 16 | 22 | 400 | 0 | Koordinat, nilai |
| `mono/sm` | JetBrains | 12 | 16 | 400 | 0.01em | Timestamp, ID kecil |
| `editorial` | Fraunces | 32 | 38 | 400 (italic optional) | -0.02em | Hero tagline only |

### 4.4 Pattern Penggunaan Mono

Mono font dipakai untuk:
- Semua angka statistik (jarak, durasi, elevasi, kecepatan)
- Koordinat GPS (lat/lng)
- Timestamp
- Tag teknis (mis. mode tracking)

Mono font **tidak** dipakai untuk:
- Body copy
- Nama trip / nama gunung
- Label tombol
- Pesan error

**Contoh komposisi:**
```
"Total jarak"           Inter 14, body/md, mist/500
"12.4 km"               JetBrains 28, mono/lg, mist/900
```

### 4.5 Aturan

- Maksimum 2 weight per screen (regular + semibold biasanya cukup).
- Hindari italic kecuali untuk copy editorial Fraunces.
- Underline hanya untuk hyperlink (jarang dipakai di mobile native).
- ALL CAPS hanya untuk `label/md` (chip & tag). Jangan pernah di body.
- Justify alignment: **dilarang** (ragged right semua).

---

## 5. Spacing, Radius, Shadow, Grid

### 5.1 Spacing Scale (4px base)

```
space/0    0px
space/1    4px      // tight inline gap
space/2    8px      // default inline gap
space/3    12px
space/4    16px     // padding default card / row
space/5    20px
space/6    24px     // section gap
space/8    32px     // major section break
space/10   40px
space/12   48px     // hero spacing
space/16   64px
space/20   80px
```

**Aturan:** sebisa mungkin pakai kelipatan 4. Hindari nilai sembarang seperti 13, 17.

### 5.2 Layout Grid

| Aspek | Detail |
|---|---|
| Container max width | 100% mobile (full bleed) |
| Horizontal padding screen | 20px (`space/5`) |
| Bottom safe area | 16px + system inset |
| Top safe area | 12px + system inset |
| Inter-card spacing | 12px (`space/3`) |
| Inter-section spacing | 32px (`space/8`) |

### 5.3 Border Radius

```
radius/none    0px
radius/sm      6px       // chip, tag, small button
radius/md      10px      // input, list item
radius/lg      14px      // card default
radius/xl      20px      // bottom sheet, modal
radius/full    9999px    // pill button, avatar
```

**Aturan:** dalam satu screen, maksimum 2 radius berbeda. Konsistensi > variasi.

### 5.4 Shadow (Elevation)

Hike.id pakai shadow yang **soft & warm**, bukan harsh dropshadow.

```
shadow/0  none                                  // flat surface
shadow/1  0 1px 2px rgba(20, 30, 18, 0.06)      // raised list item
shadow/2  0 4px 12px rgba(20, 30, 18, 0.08)     // card hover, FAB
shadow/3  0 8px 24px rgba(20, 30, 18, 0.12)     // bottom sheet, modal
shadow/4  0 16px 40px rgba(20, 30, 18, 0.16)    // dialog over backdrop
```

Di dark mode, shadow digantikan dengan **border subtle** (`mist/800`) karena shadow tidak terlihat.

### 5.5 Border / Divider

```
border/subtle   1px solid mist/200    // dark: mist/800
border/default  1px solid mist/300    // dark: mist/700
border/strong   1px solid mist/400    // dark: mist/600
divider         1px solid mist/100    // dark: mist/900
```

---

## 6. Komponen Utama

Ini bukan exhaustive list — ini komponen yang paling sering muncul dan paling perlu konsisten.

### 6.1 Button

| Variant | Background | Foreground | Border | Use |
|---|---|---|---|---|
| `primary` | `forest/500` | `mist/0` | none | Aksi utama (Mulai Hike, Simpan) |
| `accent` | `alpenglow/400` | `mist/950` | none | Aksi konversi (Upgrade Pro) |
| `secondary` | `mist/0` | `mist/900` | `border/default` | Aksi sekunder |
| `ghost` | transparent | `forest/500` | none | Aksi tersier |
| `danger` | `mist/0` | `#C8413E` | `1px solid #C8413E` | Hapus, discard |

**Spec:**
- Tinggi default: 48px (touch target minimum)
- Tinggi compact: 40px (hanya untuk inline action di list)
- Padding horizontal: 20px
- Radius: `radius/md` (10px) untuk persegi, `radius/full` untuk pill
- Label: `label/lg`, weight 500
- State:
  - `pressed`: opacity 0.85 + scale 0.98
  - `disabled`: opacity 0.4
  - `loading`: spinner kiri, label tetap

> **Anti-pattern:** tombol gradient. Tombol full alpenglow bertumpuk dengan tombol forest. Tombol > 56px tinggi (terlihat clunky).

### 6.2 SOS Button — Special

SOS button adalah komponen paling penting & paling sensitif. Spec terpisah:

- **Bentuk:** persegi panjang lebar full di SOS screen, atau FAB persistent di pojok kanan bawah saat tracking
- **Warna:** `alpenglow/500` background, `mist/0` foreground (TIDAK pakai merah danger penuh)
- **Label:** `BUKA SOS` atau ikon `life-buoy`
- **Tinggi FAB:** 56px (sedikit lebih besar dari standar 48px)
- **Haptic:** medium impact saat ditekan
- **Confirmation:** SOS screen langsung tampil, **tidak** ada konfirmasi dialog (anti-friction saat darurat)

### 6.3 Card

Card adalah container default untuk konten dalam list.

```
background:        mist/0  (light) | mist/800 (dark)
border:            border/subtle
radius:            radius/lg (14px)
padding:           space/4 (16px) all sides
shadow:            shadow/1
```

**Variant:**
- `card/trip` — list trip, ada cover photo + title + stats mono
- `card/checkpoint` — checkpoint preview dengan icon kiri
- `card/stat` — single stat hero (mono/xl + label)

### 6.4 Stat Block

Pola berulang untuk menampilkan metric. Selalu vertical-stacked:

```
+---------------------+
| TOTAL JARAK         |  label/md, mist/500, UPPERCASE
| 12.4                |  mono/xl, mist/900
| km                  |  mono/sm, mist/500
+---------------------+
```

**Aturan:**
- Label di atas, angka di tengah, unit di bawah (atau inline kecil setelah angka)
- Maksimum 4 stat block side-by-side di satu row mobile
- Tidak ada border antar block (gunakan spacing saja)

### 6.5 List Item

```
height:        min 56px (single line) | 72px (two lines)
padding:       space/4 horizontal, space/3 vertical
icon-leading:  24px, optional
icon-trailing: 16px chevron untuk navigasi
divider:       border-bottom border/subtle
press state:   background mist/100
```

### 6.6 Bottom Sheet

Bottom sheet adalah pattern utama untuk:
- Tracking active screen
- Detail checkpoint saat di-tap di peta
- Filter & form pendek

**Spec:**
- Radius: `radius/xl` top corners only (20px)
- Drag handle: 36×4 px, `mist/300`, top center
- Snap points: 25% (peek), 50% (default), 90% (expanded)
- Background: `mist/0` (light) | `mist/800` (dark)
- Shadow: `shadow/3`
- Backdrop: `rgba(20, 30, 18, 0.4)` saat fully expanded

### 6.7 Toast & Banner

| Tipe | Posisi | Durasi | Background |
|---|---|---|---|
| Toast | Bottom, 16px dari nav | 3 detik | `mist/900` (dark text) |
| Banner offline | Top, di bawah app bar | Persistent | `volcanic/700` |
| Banner peringatan | Top | Persistent | `warning bg` |

> Toast tidak pernah punya tombol aksi. Kalau butuh aksi, pakai banner.

### 6.8 Form Input

```
height:        48px
padding:       12px horizontal
border:        1px solid mist/300 (default) | forest/500 (focus) | danger (error)
radius:        radius/md
font:          body/lg
label:         label/lg, di atas input, mist/700
helper text:   body/sm, mist/500, di bawah input
error text:    body/sm, danger color
```

### 6.9 Chip / Tag

```
height:        28px
padding:       4px 10px
font:          label/md (UPPERCASE)
radius:        radius/sm
```

Variant: filter chip (dengan checkmark), info chip (warna semantic), close-able chip.

### 6.10 GPS Accuracy Indicator

Komponen unik untuk Hike.id. Ditampilkan di tracking screen dan SOS screen.

```
[ ● ● ● ]  Excellent  (3 dot forest/500)
[ ● ● ○ ]  Good       (2 dot alpenglow/400)
[ ● ○ ○ ]  Weak       (1 dot danger)
[ ○ ○ ○ ]  No Signal  (3 dot mist/300)
```

Selalu accompany dengan label teks. Tidak pernah hanya icon.

### 6.11 Empty State

Empty state harus mendorong aksi, bukan apologetic.

**Struktur:**
1. Ilustrasi line-art monokrom (forest/300), max 120×120
2. Headline `heading/lg`, max 6 kata
3. Body copy `body/md`, max 2 baris
4. Tombol primary atau ghost

**Contoh:**
```
[ Ilustrasi gunung line-art ]

Belum ada hike

Setiap perjalanan dimulai dari langkah pertama.
Sini kita catat yang pertama.

[ Mulai Hike ]
```

Hindari: "Oops, kosong nih!", emoji sad face, ilustrasi cute mascot.

### 6.12 Error State

```
[ Ilustrasi line-art (small) ]

[Heading singkat dan jelas]
[Penjelasan dalam 1–2 kalimat]
[Tombol aksi: Coba Lagi / Pulang]
```

**Contoh:**
```
GPS belum terkunci

Pindah ke area yang lebih terbuka, lalu coba lagi.

[ Coba Lagi ]      [ Buka Tips GPS ]
```

---

## 7. Iconography

### 7.1 Style

- **Stroke 1.5px**, rounded line cap, rounded join
- Grid: 24×24
- Padding optical: 2px dari edge
- Dua ukuran: 20px (inline) dan 24px (default action)
- **Bukan** filled icon. Bukan duotone. Konsisten line-art.

### 7.2 Icon Library

Pakai **Lucide Icons** (open-source, MIT). Konsisten visual, lengkap, ringan.

Untuk icon spesifik hiking yang tidak ada di Lucide:
- `mountain-peak`, `trail-head`, `summit-flag` — custom, konsisten dengan stroke 1.5px
- `tent`, `droplet`, `fire-camp`, `compass-rose`

### 7.3 Checkpoint Icons (Custom)

| Tipe | Icon | Warna Container |
|---|---|---|
| Pos | `flag-pin` | `forest/500` |
| Air | `droplet` | `info bg` |
| Kemah | `tent` | `volcanic/500` |
| Puncak | `mountain-peak` | `alpenglow/400` |
| Bahaya | `alert-triangle` | `danger color` |
| Custom | `pin` | `mist/600` |

Icon di peta: bulatan 32px dengan icon putih di tengah, drop pin di bawah.

---

## 8. Map Style

### 8.1 Filosofi

Peta adalah konten utama Hike.id — bukan ornament. Tile harus terbaca, polyline harus jelas, tapi UI overlay harus ringan supaya tidak menutupi peta.

### 8.2 Tile Style

| Mode | Source | Treatment |
|---|---|---|
| Day (default) | OSM Standard | Saturasi -10%, brightness +5% — terbaca di terik |
| Night | OSM Standard | Apply dark filter (mist-tinted) |
| Topo | OpenTopoMap | Default, tidak ada filter |
| Outdoor mode | OSM | High contrast filter |

### 8.3 Polyline Style

```
track/active     stroke 5px, color forest/500, opacity 1.0, line-cap round
track/active     glow: 8px outer, forest/500 alpha 0.2
track/history    stroke 4px, color volcanic/500, opacity 0.7
track/imported   stroke 4px, color #3E7195, dashed (10px on, 6px off), opacity 0.85
```

### 8.4 Map Markers

- **Current position:** lingkaran 14px, `forest/500` solid, ring putih 3px, accuracy circle radius sesuai HDOP `forest/500` alpha 0.15
- **Direction indicator:** triangle kecil di atas dot, mengikuti heading
- **Pulse animation:** ring tambahan 24px → 40px, alpha 0.5 → 0, loop 2 detik (saat tracking aktif)
- **Checkpoint markers:** lihat §7.3
- **Start marker:** dot dengan border alpenglow
- **End marker:** finish-flag icon

### 8.5 Map Overlay UI

Overlay di atas peta wajib tetap terbaca:
- Background `mist/0` opacity 0.95 + blur backdrop 12px
- Atau full opaque card untuk informasi penting

Atribusi OSM **wajib tampil** di pojok kanan bawah, `body/sm`, mist/600.

---

## 9. Mode Tampilan

Hike.id punya 3 mode — diatur otomatis (mengikuti system) atau manual.

### 9.1 Light Mode (Default Day)

- Background: `mist/0`
- Surface card: `mist/0` dengan shadow
- Border: `mist/200`
- Text primer: `mist/900`
- Text sekunder: `mist/600`
- Primary action: `forest/500`

### 9.2 Dark Mode (Default Night / Sistem)

- Background: `mist/950`
- Surface card: `mist/900` (sedikit lebih terang dari bg)
- Border: `mist/800`
- Text primer: `mist/50`
- Text sekunder: `mist/300`
- Primary action: `forest/400` (sedikit lebih cerah)

> Dark mode **bukan** sekedar invert. Beberapa warna di-shift 1 step.

### 9.3 Outdoor Mode (High Contrast — fitur khas Hike.id)

Dirancang untuk **terbaca di matahari terik tropis**. Bisa diaktifkan manual atau otomatis berdasarkan ambient light sensor (future).

- Background: `mist/0` pure
- Text primer: `mist/950` (pure dark)
- Text sekunder: `mist/700`
- Primary action: `forest/700` (lebih gelap untuk kontras max)
- Tombol border: 2px, lebih tebal
- Font weight default naik 1 step (regular → medium)
- Disable shadow, ganti dengan border tebal
- Map tile: high contrast filter
- Animasi: di-disable / dipangkas

> Trade-off: outdoor mode terlihat lebih "kasar" — itu intentional. Kebutuhan kontras > estetika halus saat di gunung.

### 9.4 Switching Logic

| Trigger | Mode |
|---|---|
| Sistem light + indoor | Light |
| Sistem dark + indoor | Dark |
| Tracking aktif + ambient light tinggi (future) | Auto-suggest Outdoor |
| User pilih manual | Override semua |

---

## 10. Motion & Haptic

### 10.1 Filosofi Motion

Animasi di Hike.id harus:
- **Singkat** — tidak menghalangi user yang sedang berjalan
- **Purposeful** — komunikasikan perubahan state, bukan dekorasi
- **Respect "Reduce Motion"** — hormati setting OS

### 10.2 Duration Token

```
duration/instant   0ms       // state toggle yang harus terasa instan
duration/fast      120ms     // micro-interaction, hover, press
duration/base      200ms     // page transition default
duration/slow      320ms     // bottom sheet, modal in/out
duration/lazy      500ms     // hero animation, onboarding only
```

### 10.3 Easing

```
easing/standard    cubic-bezier(0.2, 0, 0, 1)        // material standard
easing/decelerate  cubic-bezier(0, 0, 0, 1)          // entering element
easing/accelerate  cubic-bezier(0.3, 0, 1, 1)        // exiting element
easing/spring      stiffness 300, damping 30         // bottom sheet
```

### 10.4 Pattern Animasi

| Aksi | Motion | Duration |
|---|---|---|
| Tap button | scale 0.98 + opacity 0.85 | fast |
| Bottom sheet open | slide up + spring bounce kecil | slow |
| Page push | slide right-to-left + fade | base |
| Toast appear | fade + slide up 8px | base |
| GPS pulse | scale 1.0 → 1.5 + opacity 1 → 0 | 2000ms loop |
| Tracking start | tombol → confirmation morph | base |
| Stat count-up | number tween dari old → new | base |

### 10.5 Anti-Pattern

- Bouncy animation untuk semua transisi (lelah)
- Parallax scrolling di list (mahal performa)
- Animasi loading > 1 detik tanpa progress
- Page transition dengan flip / 3D rotate

### 10.6 Haptic Feedback

Pakai `HapticFeedback` Flutter dengan tepat — terlalu banyak haptic = annoying.

| Aksi | Haptic |
|---|---|
| Tap primary button | `lightImpact` |
| Long-press tambah checkpoint | `mediumImpact` |
| Pause tracking | `lightImpact` |
| Stop tracking confirm | `mediumImpact` |
| SOS button tekan | `heavyImpact` |
| Error / GPS lost | `vibrate` short pattern |
| Off-route warning | `mediumImpact` |
| Achievement (personal best) | `success` selectionClick |

---

## 11. Layout Pattern Per Screen Tipikal

Referensi cepat untuk screen-screen utama. Detail acceptance criteria di PRD §6.

### 11.1 Home / Dashboard (S-03)

```
+---------------------------------+
| 09:42        offline            |   app bar: time, status
+---------------------------------+
|                                 |
| Hai, ready?                     |   editorial / display/lg
| Cuaca cerah, gunung menanti.    |   body/lg, mist/600
|                                 |
| [   Mulai Hike   ]              |   primary button, full width, 56px
|                                 |
| ----                            |   divider 32px space
| RECENT                          |   label/md
|                                 |
| [card Trip 1]                   |
| [card Trip 2]                   |
| [card Trip 3]                   |
|                                 |
| ----                            |
| QUICK STATS                     |   label/md
|                                 |
| [stat block grid 2x2]           |
|                                 |
+---------------------------------+
| home  map  history  stats       |   bottom nav
+---------------------------------+
```

### 11.2 Tracking Active (S-05)

Layout: **peta full-screen** + **bottom sheet collapsible**.

```
+---------------------------------+
| (peta full screen)              |
|                                 |
|   ●  current position           |
|   ───────────  track polyline   |
|                                 |
|                       [SOS]     |   FAB pojok kanan atas
|                                 |
|                       [+]       |   FAB checkpoint kanan bawah
+---------------------------------+
| ━━━━ (drag handle)              |   bottom sheet, peek 25%
|                                 |
| [stat] [stat] [stat] [stat]     |   4 stat block: jarak, durasi, pace, elev
|                                 |
| [   Pause   ]   [   Selesai  ]  |   2 button
+---------------------------------+
```

Saat sheet di-expand:
- Tambah profil elevasi mini (fl_chart)
- Tambah daftar checkpoint yang sudah ditambah
- Tombol switch tracking mode

### 11.3 SOS Screen (S-15)

```
+---------------------------------+
| [<]  SOS                        |   app bar
+---------------------------------+
|                                 |
| LOKASI TERAKHIR                 |   label/md, mist/500
|                                 |
| -7.532821                       |   mono/xl, mist/900
| 110.443210                      |   mono/xl, mist/900
|                                 |
| Akurasi  ±8m       Elev 2.345m  |   mono/md
| Update 2 menit lalu             |   mono/sm, mist/500
|                                 |
| [ Salin Koordinat ]             |   secondary, full width
| [ Bagikan Lokasi  ]             |   primary, full width
|                                 |
| ----                            |
| KONTAK DARURAT                  |
|                                 |
| [list 3 kontak]                 |
|                                 |
| Basarnas Nasional  115          |
|                                 |
| ----                            |
|                                 |
| Hike.id tidak mengirim rescue   |   body/sm, mist/500
| otomatis. Hubungi bantuan       |
| secara aktif.                   |
|                                 |
+---------------------------------+
```

> Tone screen ini **sengaja tenang** — tidak ada warna merah panik, tidak ada animation bertubi. Pendaki yang panik butuh visual yang menenangkan.

### 11.4 Trip Detail (S-08)

Tab structure:
- **Map** — full peta dengan polyline + checkpoint markers
- **Stats** — profil elevasi, grafik, breakdown
- **Notes** — list checkpoint & note timeline

Hero section atas (sebelum tab):
- Cover photo (16:9) atau gradient placeholder
- Trip name `display/lg`
- Mountain name + tanggal `body/md`, mist/500
- 3 stat utama mono inline: jarak · durasi · elevasi gain

### 11.5 Paywall (S-21)

```
+---------------------------------+
| [x]                             |
+---------------------------------+
|                                 |
| Hike.id Pro                     |   editorial display
|                                 |
| Buka semua fitur untuk          |   body/lg
| pendakian tanpa batas.          |
|                                 |
| ✓  Unlimited tile peta offline  |
| ✓  Unlimited checkpoint & note  |
| ✓  Foto & voice note            |
| ✓  Statistik personal lengkap   |
| ✓  Export GPX, KML, PDF         |
| ✓  Group tracking real-time     |
|                                 |
| [Toggle: Bulanan | Tahunan]     |   pill segmented
|                                 |
| Rp 199.000 / tahun              |   mono/xl
| Hemat 43% vs bulanan            |   body/sm, mist/500
|                                 |
| [ Mulai 14 Hari Gratis ]        |   accent button alpenglow
|                                 |
| Bisa dibatalkan kapan saja.     |   body/sm, center, mist/500
|                                 |
+---------------------------------+
```

> Paywall ini honest, tidak FOMO, tidak fake countdown. Konversi datang dari nilai, bukan tekanan.

---

## 12. Aksesibilitas

Refer ke PRD §7.5 untuk requirement teknis. Tambahan dari sisi desain:

- **Kontras teks vs background** dicek di tools (mis. Stark, Contrast app) sebelum ship
- **Color tidak boleh jadi satu-satunya pembeda** — selalu pasang ikon atau teks
- **Touch target 48×48dp** untuk semua interactive element, padding boleh extend ke ikon yang lebih kecil
- **Focus indicator** wajib visible (2px ring forest/500) untuk navigasi keyboard & switch control
- **Semantic label** untuk semua icon-only button
- **Reduce motion** disetting OS = potong duration ke instant atau fast saja

---

## 13. Brand Identity

### 13.1 Logo

Logomark: **garis kontur gunung + dot puncak alpenglow**, geometric, single weight 2px.

```
        ●
       /
      /
   ___/____
```

Variants:
- **Logomark only** (square) — untuk app icon, favicon
- **Logo horizontal** — logomark + wordmark "Hike.id"
- **Wordmark only** — Inter SemiBold, custom kerning

Clear space minimum: 1× tinggi logomark di semua sisi.

### 13.2 App Icon

- **Square 1024×1024** (untuk export)
- **Background:** gradient `forest/700 → forest/900` diagonal
- **Foreground:** logomark `mist/0` dengan dot puncak `alpenglow/400`
- **Tidak pakai** efek 3D, glossy, drop shadow tebal

Adaptive icon Android: foreground & background layer dipisah sesuai spec.

### 13.3 Photography Style

Foto yang dipakai di marketing & onboarding:
- Pendakian Indonesia otentik (bukan stock Pacific Northwest)
- Golden hour atau cloud-cover natural
- Subjek pendaki Indonesia, tidak selalu wajah jelas
- Color grade: highlight warm, shadow cool, saturasi -10%
- **Hindari:** Drone shot generik, model fashion, sticker filter

### 13.4 Voice & Marketing

Sama dengan §2 — tone "kamu", santai-tegas, jujur.

Tagline marketing: *Setiap Langkah, Tercatat.*
Sub-tagline opsional: *Offline-first. Built for Indonesia.*

---

## 14. Atribusi & Lisensi

Komponen open-source yang dipakai dalam design system harus diatribusi:

| Aset | Lisensi | Atribusi |
|---|---|---|
| Inter | OFL 1.1 | rsms.me/inter |
| JetBrains Mono | OFL 1.1 | jetbrains.com/mono |
| Fraunces | OFL 1.1 | fonts.google.com |
| Lucide Icons | ISC | lucide.dev |
| OpenStreetMap | ODbL 1.0 | "© OpenStreetMap contributors" — wajib visible di peta |

Halaman Settings → About → Lisensi wajib mencantumkan semuanya.

---

## 15. Implementation Checklist (Untuk Engineer)

Saat mengimplementasi UI, gunakan checklist ini:

- [ ] Apakah warna pakai token, bukan hex literal?
- [ ] Apakah spacing kelipatan 4?
- [ ] Apakah font dari typography scale, bukan size random?
- [ ] Apakah radius dari token?
- [ ] Apakah touch target ≥ 48dp?
- [ ] Apakah ada semantic label untuk icon-only?
- [ ] Apakah string sudah lewat `.arb`?
- [ ] Apakah reduce motion dihormati?
- [ ] Apakah outdoor mode tested?
- [ ] Apakah dark mode tested?
- [ ] Apakah empty/error/loading state ada?
- [ ] Apakah mono font dipakai untuk angka stat?
- [ ] Apakah tidak ada emoji di UI inti?

---

## 16. Open Design Decisions

- [ ] Final logomark design (sketch fase awal masih placeholder)
- [ ] Apakah pakai variable font Inter atau static weights
- [ ] Apakah perlu illustrator khusus untuk empty states atau pakai line-art generator
- [ ] Custom map style melalui Mapbox / Maputnik atau cukup tile filter
- [ ] App icon final: monogram H atau full mountain mark
- [ ] Sound design — apakah ada untuk haptic milestone (personal best, dll)

---

## 17. Changelog

| Version | Tanggal | Perubahan |
|---|---|---|
| 1.0 | Mei 2026 | Initial release. Define philosophy, tokens, components, modes, motion, brand. |

---

*Dokumen ini hidup bersama produk. Update dilakukan saat keputusan desain berubah, bukan retroaktif setelah implementasi.*
*Owner: UX / Product Designer · Reviewer: Mobile Lead.*
