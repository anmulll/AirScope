
# AirScope — Air Quality Monitoring Application

AirScope adalah aplikasi mobile berbasis Flutter untuk memantau kualitas udara berdasarkan lokasi kota.

Aplikasi mengambil data kualitas udara melalui REST API publik, mengolah respons secara asynchronous, dan menyimpan kota terakhir yang dicari menggunakan local storage.

Proyek ini dikembangkan sebagai tugas mata kuliah Pemrograman Mobile.

## Project Information

| Item | Description |
|---|---|
| Application | AirScope |
| Platform | Android |
| Framework | Flutter |
| Programming Language | Dart |
| API Provider | Open-Meteo |
| HTTP Client | HTTP |
| Asynchronous UI | FutureBuilder |
| Local Storage | SharedPreferences |
| Design System | Material Design 3 |
| Version Control | Git & GitHub |

## Project Objectives

Proyek ini bertujuan mengimplementasikan tiga konsep utama pemrograman mobile:

1. REST API Integration
   Mengambil data kualitas udara dari server eksternal.

2. Asynchronous Programming
   Menggunakan FutureBuilder untuk menangani proses Loading, Success, dan Error.

3. Local Storage
   Menggunakan SharedPreferences untuk menyimpan kota terakhir yang dicari.

## Main Features

- [ ] Pencarian kualitas udara berdasarkan nama kota.
- [ ] Integrasi Geocoding API.
- [ ] Integrasi Air Quality API.
- [ ] Menampilkan nilai US AQI.
- [ ] Menampilkan kategori kualitas udara.
- [ ] Menampilkan konsentrasi PM2.5 dan PM10.
- [ ] Loading state.
- [ ] Success state.
- [ ] Error state dan Retry.
- [ ] Menyimpan kota terakhir menggunakan SharedPreferences.
- [ ] Memulihkan pencarian terakhir ketika aplikasi dibuka.

## Technology Stack

| Technology | Purpose |
|---|---|
| Flutter | Mobile application framework |
| Dart | Programming language |
| Open-Meteo | Air quality data provider |
| HTTP | REST API communication |
| FutureBuilder | Asynchronous UI |
| SharedPreferences | Local data persistence |
| Material 3 | User interface |
| Git | Version control |
| GitHub | Source code repository |

## API Integration

AirScope menggunakan dua endpoint utama dari Open-Meteo.


## Data Attribution

Air quality information is provided by Open-Meteo.

The air quality forecasts are based on atmospheric
composition models from the Copernicus Atmosphere
Monitoring Service (CAMS).

AirScope displays model-based air quality information
and does not represent direct measurements from
physical monitoring stations.

Data source:
https://open-meteo.com/

### 1. Geocoding API

Digunakan untuk mengubah nama kota menjadi koordinat geografis.

Endpoint:

https://geocoding-api.open-meteo.com/v1/search

Parameter:
- name
- count
- language
- format

### 2. Air Quality API

Digunakan untuk mengambil data kualitas udara berdasarkan koordinat geografis.

Endpoint:

https://air-quality-api.open-meteo.com/v1/air-quality

Parameter utama:
- latitude
- longitude
- current
- timezone

Data yang digunakan:
- US AQI
- PM2.5
- PM10

Catatan: Data kualitas udara Open-Meteo berbasis model atmosfer, bukan pengukuran langsung dari sensor pada setiap lokasi.

## Asynchronous UI

FutureBuilder digunakan untuk menangani tiga kondisi utama:

| State | Description |
|---|---|
| Loading | Menunggu respons API |
| Success | Menampilkan data kualitas udara |
| Error | Menampilkan pesan kesalahan dan tombol Retry |

## Local Storage

SharedPreferences digunakan untuk menyimpan kota terakhir yang berhasil dicari.

Alur penyimpanan:

1. Pengguna mencari kota.
2. Aplikasi mengambil koordinat kota.
3. Aplikasi meminta data kualitas udara.
4. Jika berhasil, nama kota disimpan secara lokal.
5. Ketika aplikasi dibuka kembali, kota terakhir dipulihkan.
6. Aplikasi mengambil kembali data kualitas udara kota tersebut.

Pencarian yang gagal tidak boleh menggantikan kota terakhir yang berhasil disimpan.

## Planned Project Structure

```text
airscope/
├── android/
├── lib/
│   ├── main.dart
│   ├── app/
│   │   └── app.dart
│   ├── core/
│   │   ├── theme/
│   │   ├── constants/
│   │   └── widgets/
│   └── features/
│       └── air_quality/
│           ├── domain/
│           ├── data/
│           └── presentation/
├── test/
├── README.md
├── DESIGN.md
├── AGENTS.md
└── pubspec.yaml
```

## Installation

### Prerequisites

- Flutter SDK
- Dart SDK
- Android Studio
- Android SDK
- Git

### Install Dependencies

```bash
flutter pub get
```

### Run Application

```bash
flutter run
```

### Run Tests

```bash
flutter analyze
flutter test
```

### Build APK

```bash
flutter build apk --release
```

Output:

```text
build/app/outputs/flutter-apk/app-release.apk
```

## Development Roadmap

| Commit | Development |
|---|---|
| 01 | Initialize Flutter project |
| 02 | Define requirements and design system |
| 03 | Setup Material 3 app theme |
| 04 | Add air quality data model |
| 05 | Integrate air quality REST API |
| 06 | Implement city search interface |
| 07 | Handle asynchronous data with FutureBuilder |
| 08 | Implement error handling and retry |
| 09 | Persist last searched city locally |
| 10 | Add model and repository tests |
| 11 | Polish UI and responsive layout |
| 12 | Finalize documentation and submission |

## References

- https://docs.flutter.dev/
- https://dart.dev/
- https://open-meteo.com/
- https://pub.dev/packages/shared_preferences

## Developer Information

Name: Muh. An'amullah A.

NIM: D121241032

Course: Pemrograman Mobile

Repository: AirScope

---

AirScope — Understand the Air Around You.
