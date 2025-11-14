# KONFIGURASI AWAL

##VSCODE DAN LAIN NYA
- Extension VS Code
  1.DART
  2.FLUTTER
  3.COMPOSER (untuk notif)
  4.PHP
- Android Studio Narwhal 3
  1. Konfigurasi Android Studio
     - Buka aplikasi lalu masuk ke Projects => More Action => SDK Manager
     - Ke menu Languages & Frameworks => Android SDK
     - Ke menu SDK platform lalu install 
       1. Android 16.0 ("Baklava") 36.0
       2. Andorid 14.0 ("UpsideDownCake") 34
     - Ke menu SDK Tools lalu install
       1. Android SDK Build-Tools
       2. NDK (Side by side)
       3. Android SDK Command-line Tools (latest)
       4. Cmake
       5. Android Emulator
       6. Android Emulator hypervisor driver (installer)
       7. Android SDK Platform-Tools
##API 
- Folder API di tempatkan di htdocs (..\htdocs\API)
- Koneksi database ada di config.php
```
<?php
$host = "localhost";
$user = "root";
$pass = "";
$db   = "nama_database"; 

$conn = new mysqli($host, $user, $pass, $db);

if ($conn->connect_error) {
    die(json_encode(["error" => "Connection failed: " . $conn->connect_error]));
}
$conn->set_charset("utf8");
?>
```
- Cronjob
  1. auto_mulai_pinjam.php (untuk update status pinjam dari menunggu ke berjalan) per 1 menit
  2. auto_tolak_pengajuan.php (untuk tolak otomatis pengajuan yang tanggal kembali nya udah lewat dari waktu sekarang) per 1 menit
  3. notif_telat_kembalikan.php (untuk kirim notif saat peminjaman melewati deadline) per 1 menit
  4. notif30mbefore.php (untuk kirim notif 30 menit sebelum deadline) per 1 menit

##DATABASE
  File "database sibob mobile.sql" di dalam masih ada data master user inventaris dan lain lain. database nya gabung peminjaman dan pemeliharaan.

##APLIKASI 
- Konfigurasi koneksi api ada di ..\lib\api\api_config.dart
```
class ApiConfig {
  static const String baseUrl = "http://domain(ip)_server/API(folder API tadi, kalau di ubah di sesuaikan)";

  static Uri uri(String endpoint, [Map<String, String>? params]) {
    final url = Uri.parse("$baseUrl/$endpoint");
    return params != null ? url.replace(queryParameters: params) : url;
  }
}

```
- Sebelum eksport atau run jalankan 
```
flutter clean
```
dan 
```
flutter pub get
```
run 
```
flutter run
```
- Untuk eksport ke apk ini syntax nya
```
flutter build apk --release
```
