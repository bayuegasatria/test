import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDb();
    return _database!;
  }

  /// Helper untuk format tanggal (YYYY-MM-DD)
  String _toDateString(DateTime dt) {
    return "${dt.year.toString().padLeft(4, '0')}-"
        "${dt.month.toString().padLeft(2, '0')}-"
        "${dt.day.toString().padLeft(2, '0')}";
  }

  Future<Database> _initDb() async {
    String path = join(await getDatabasesPath(), 'appdb.db');
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async {
    // === TABLE USER ===
    await db.execute('''
    CREATE TABLE user (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      nama TEXT,
      nip TEXT,
      role TEXT
    )
    ''');

    // isi data awal user (10 user)
    await db.insert("user", {
      "nama": "admin",
      "nip": "130803",
      "role": "atasan",
    });
    await db.insert("user", {"nama": "user", "nip": "123", "role": "pegawai"});
    await db.insert("user", {
      "nama": "Andi Wijaya",
      "nip": "2210010001",
      "role": "pegawai",
    });
    await db.insert("user", {
      "nama": "Siti Aminah",
      "nip": "2210010002",
      "role": "pegawai",
    });
    await db.insert("user", {
      "nama": "Budi Santoso",
      "nip": "2210010003",
      "role": "driver",
    });
    await db.insert("user", {
      "nama": "Rina Kartika",
      "nip": "2210010004",
      "role": "pegawai",
    });
    await db.insert("user", {
      "nama": "Agus Setiawan",
      "nip": "2210010005",
      "role": "driver",
    });
    await db.insert("user", {
      "nama": "Dewi Lestari",
      "nip": "2210010006",
      "role": "pegawai",
    });
    await db.insert("user", {
      "nama": "Fajar Pratama",
      "nip": "2210010007",
      "role": "pegawai",
    });
    await db.insert("user", {
      "nama": "Lina Marlina",
      "nip": "2210010008",
      "role": "pegawai",
    });
    await db.insert("user", {
      "nama": "Tono Rahman",
      "nip": "2210010009",
      "role": "driver",
    });

    // === TABLE MOBIL ===
    await db.execute('''
    CREATE TABLE mobil (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      nomor_inventaris TEXT,
      merk TEXT,
      da TEXT
    )
    ''');
    await db.insert("mobil", {
      "nomor_inventaris": "INV001",
      "merk": "Kijang Inova",
      "da": "DA 3029 UY",
    });
    await db.insert("mobil", {
      "nomor_inventaris": "INV002",
      "merk": "Toyota Avanza",
      "da": "DA 2134 RT",
    });
    await db.insert("mobil", {
      "nomor_inventaris": "INV003",
      "merk": "Toyota Rush",
      "da": "DA 6534 GD",
    });

    // === TABLE DRIVER ===
    await db.execute('''
    CREATE TABLE driver (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      nama TEXT,
      nip TEXT
    )
    ''');

    // isi driver dummy
    await db.insert("driver", {"nama": "Budi Santoso", "nip": "2210010003"});
    await db.insert("driver", {"nama": "Agus Setiawan", "nip": "2210010005"});
    await db.insert("driver", {"nama": "Tono Rahman", "nip": "2210010009"});

    // === TABLE PENGAJUAN ===
    await db.execute('''
    CREATE TABLE pengajuan (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      id_user INTEGER,
      no_pengajuan TEXT,
      tujuan TEXT,
      jenis_kendaraan TEXT,
      perlu_supir TEXT,
      pengemudi TEXT,
      tanggal_berangkat TEXT,
      tanggal_kembali TEXT,
      jumlah_pengguna INTEGER,
      keterangan TEXT,
      catatan TEXT,
      status TEXT,
      dibaca INTEGER DEFAULT 0
    )
    ''');

    // === TABLE PINJAM ===
    await db.execute('''
    CREATE TABLE pinjam (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      id_pengajuan INTEGER,
      tanggal_berangkat TEXT,
      tanggal_kembali TEXT,
      tanggal_pengembalian TEXT,
      id_kendaraan INTEGER,
      id_supir INTEGER,
      status TEXT
    )
    ''');
  }

  /// 🔹 Query: Ambil semua jadwal mobil (pinjam) mulai dari hari ini ke depan
  Future<List<Map<String, dynamic>>> getJadwalMobil(DateTime now) async {
    final db = await database;
    return await db.rawQuery(
      '''
    SELECT 
      p.id AS id_pinjam,
      p.tanggal_berangkat,
      p.tanggal_pengembalian,
      p.tanggal_kembali,
      p.status,
      m.merk AS nama_mobil,
      u.nama AS nama_user,
      pg.no_pengajuan,
      pg.tujuan
    FROM pinjam p
    JOIN pengajuan pg ON p.id_pengajuan = pg.id
    JOIN mobil m ON p.id_kendaraan = m.id
    JOIN user u ON pg.id_user = u.id
    WHERE DATE(p.tanggal_kembali) >= DATE(?) 
      AND p.status = 'berjalan'
    ORDER BY p.tanggal_berangkat ASC
    ''',
      [_toDateString(now)],
    );
  }

  /// 🔹 Query: Ambil status pinjam user login (hari ini)
  Future<List<Map<String, dynamic>>> getStatusPinjamUser(
    int userId,
    DateTime now,
  ) async {
    final db = await database;
    return await db.rawQuery(
      '''
      SELECT p.id, p.tanggal_berangkat, p.tanggal_kembali, p.status,
             m.merk AS nama_mobil, pg.tujuan, u.nama AS nama_user
      FROM pinjam p
      JOIN pengajuan pg ON p.id_pengajuan = pg.id
      JOIN user u ON pg.id_user = u.id
      JOIN mobil m ON p.id_kendaraan = m.id
      WHERE  DATE(p.tanggal_berangkat) >= DATE(?) 
        AND u.id = ? AND p.status != 'selesai'
      ''',
      [_toDateString(now), userId],
    );
  }

  /// 🔹 Query: Ambil notifikasi sesuai role
  Future<List<Map<String, dynamic>>> getNotifikasi({
    required String role,
    required int userId,
  }) async {
    final db = await database;
    if (role == "atasan") {
      return await db.query(
        'pengajuan',
        where: "status = ? AND dibaca = 0",
        whereArgs: ["baru"],
      );
    } else {
      return await db.query(
        'pengajuan',
        where: "id_user = ? AND status IN (?, ?) AND dibaca = 0",
        whereArgs: [userId, "disetujui", "ditolak"],
      );
    }
  }

  Future<List<Map<String, dynamic>>> getAccData({
    required String role,
    required int userId,
  }) async {
    final db = await database;

    if (role == "pegawai") {
      // pegawai hanya lihat pengajuan miliknya
      return await db.rawQuery(
        '''
      SELECT p.*, u.nama 
      FROM pengajuan p
      JOIN user u ON p.id_user = u.id
      WHERE p.id_user = ? 
      ORDER BY p.id DESC
      ''',
        [userId],
      );
    } else if (role == "atasan") {
      // atasan lihat semua data
      return await db.rawQuery('''
      SELECT p.*, u.nama 
      FROM pengajuan p
      JOIN user u ON p.id_user = u.id
      ORDER BY p.id DESC
      ''');
    }

    return [];
  }

  // Ambil daftar mobil
  Future<List<Map<String, dynamic>>> getMobil() async {
    final db = await database;
    return await db.query("mobil");
  }

  // Ambil daftar driver
  Future<List<Map<String, dynamic>>> getDriver() async {
    final db = await database;
    return await db.query("driver");
  }

  // Update status pengajuan jadi ditolak
  Future<void> tolakPengajuan(int pengajuanId, String catatan) async {
    final db = await database;
    await db.update(
      "pengajuan",
      {"status": "ditolak", "catatan": catatan},
      where: "id = ?",
      whereArgs: [pengajuanId],
    );
  }

  // Setujui pengajuan → update pengajuan + insert ke pinjam
  Future<void> accPengajuan({
    required Map<String, dynamic> pengajuan,
    required int idMobil,
    required int idSupir,
    required String catatan,
  }) async {
    final db = await database;

    // update pengajuan
    await db.update(
      "pengajuan",
      {"status": "disetujui", "catatan": catatan},
      where: "id = ?",
      whereArgs: [pengajuan["id"]],
    );

    // insert ke pinjam
    await db.insert("pinjam", {
      "id_pengajuan": pengajuan["id"],
      "tanggal_berangkat": pengajuan["tanggal_berangkat"],
      "tanggal_kembali": pengajuan["tanggal_kembali"],
      "tanggal_pengembalian": null,
      "id_kendaraan": idMobil,
      "id_supir": idSupir,
      "status": "berjalan",
    });
  }

  Future<Map<String, dynamic>?> getPengajuanById(int id) async {
    final db = await database;
    final res = await db.rawQuery(
      '''
    SELECT p.*, u.nama
    FROM pengajuan p
    JOIN user u ON p.id_user = u.id
    WHERE p.id = ?
  ''',
      [id],
    );

    if (res.isNotEmpty) {
      return res.first;
    }
    return null;
  }

  Future<int> getNotifCount({String status = 'pending'}) async {
    final db = await database;
    final result = await db.rawQuery(
      '''
      SELECT COUNT(*) as total 
      FROM pengajuan 
      WHERE status = ?
      ''',
      [status],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<List<Map<String, dynamic>>> getHistoryPinjam({
    int? userId,
    String? role,
  }) async {
    final db = await database;

    // Kalau pegawai -> filter berdasarkan id_user
    if (role == "pegawai" && userId != null) {
      return await db.rawQuery(
        '''
      SELECT pjm.id,
             pg.no_pengajuan,
             u.nama AS nama_user,
             pjm.tanggal_pengembalian,
             pjm.tanggal_kembali,
             pg.tujuan,
             k.merk AS nama_kendaraan,
             pjm.status
      FROM pinjam pjm
      JOIN pengajuan pg ON pjm.id_pengajuan = pg.id
      JOIN mobil k ON pjm.id_kendaraan = k.id
      JOIN user u ON pg.id_user = u.id
      WHERE pjm.status = 'selesai'
        AND u.id = ?
      ORDER BY pjm.tanggal_pengembalian DESC
    ''',
        [userId],
      );
    }

    // Kalau atasan -> lihat semua data
    return await db.rawQuery('''
    SELECT pjm.id,
           pg.no_pengajuan,
           u.nama AS nama_user,
           pjm.tanggal_pengembalian,
           pg.tujuan,
           k.merk AS nama_kendaraan,
           pjm.status
    FROM pinjam pjm
    JOIN pengajuan pg ON pjm.id_pengajuan = pg.id
    JOIN mobil k ON pjm.id_kendaraan = k.id
    JOIN user u ON pg.id_user = u.id
    WHERE pjm.status= 'selesai'
    ORDER BY pjm.tanggal_pengembalian DESC
  ''');
  }

  Future<List<Map<String, dynamic>>> getDetailAcc(int id) async {
    final db = await database;
    final res = await db.rawQuery(
      '''
    SELECT 
      pg.id,
      pg.dibaca,
      pg.no_pengajuan,
      pg.tujuan,
      pg.tanggal_berangkat,
      pg.tanggal_kembali,
      pg.catatan,
      pg.status,
      pg.perlu_supir,
      pg.pengemudi,
      u.nama,
      p.id_kendaraan,
      p.id_supir,
      m.merk || ' (' || m.da || ')' AS nama_kendaraan,
      s.nama AS nama_supir
    FROM pengajuan pg
    JOIN pinjam p ON pg.id = p.id_pengajuan
    JOIN user u ON pg.id_user = u.id
    JOIN mobil m ON p.id_kendaraan = m.id
    JOIN driver s ON p.id_supir = s.id 
    WHERE pg.id = ? 
    ''',
      [id],
    );
    return res;
  }

  Future<int> getNotifCountMultiple({
    required List<String> statuses,
    required int userId,
  }) async {
    final db = await database;
    final placeholders = List.filled(statuses.length, "?").join(",");
    final res = await db.rawQuery(
      """
    SELECT COUNT(*) as count 
    FROM pengajuan 
    WHERE status IN ($placeholders) AND id_user = ? AND dibaca = 0
    """,
      [...statuses, userId],
    );
    return Sqflite.firstIntValue(res) ?? 0;
  }

  Future<int> updateStatusPinjam(int idPinjam, String newStatus) async {
    final db = await database;
    final now = DateTime.now().toIso8601String(); // format YYYY-MM-DDTHH:mm:ss

    return await db.update(
      'pinjam',
      {'status': newStatus, 'tanggal_pengembalian': now},
      where: 'id = ?',
      whereArgs: [idPinjam],
    );
  }

  Future<Map<String, dynamic>?> getDetailPinjam(int idPinjam) async {
    final db = await database;
    final result = await db.rawQuery(
      '''
    SELECT p.id, p.status, 
           p.tanggal_berangkat, p.tanggal_kembali, p.tanggal_pengembalian,
           m.merk || ' - ' || m.da AS kendaraan,
           pg.no_pengajuan, pg.tujuan, u.nama
    FROM pinjam p
    JOIN pengajuan pg ON p.id_pengajuan = pg.id
    JOIN user u ON pg.id_user = u.id
    JOIN mobil m ON p.id_kendaraan = m.id
    WHERE p.id = ?
  ''',
      [idPinjam],
    );

    if (result.isNotEmpty) return result.first;
    return null;
  }

  Future<int> updateStatusPinjamById(int idPinjam, String newStatus) async {
    final db = await database;
    return await db.update(
      'pinjam',
      {'status': newStatus},
      where: 'id = ?',
      whereArgs: [idPinjam],
    );
  }

  Future<List<Map<String, dynamic>>> getAvailableMobil(
    DateTime tglBerangkat,
    DateTime tglKembali,
  ) async {
    final db = await database;

    final result = await db.rawQuery(
      '''
    SELECT m.*
    FROM mobil m
    WHERE m.id NOT IN (
      SELECT p.id_kendaraan
      FROM pinjam p
      WHERE p.status != 'selesai'
        AND (
          datetime(p.tanggal_berangkat) < datetime(?)
          AND datetime(p.tanggal_kembali) > datetime(?)
        )
    )
  ''',
      [
        tglKembali.add(const Duration(hours: 1)).toIso8601String(), // +1 jam
        tglBerangkat.toIso8601String(),
      ],
    );

    return result;
  }

  Future<List<Map<String, dynamic>>> getAvailableSupir(
    DateTime tglBerangkat,
    DateTime tglKembali,
  ) async {
    final db = await database;

    final result = await db.rawQuery(
      '''
    SELECT d.*
    FROM driver d
    WHERE d.id NOT IN (
      SELECT p.id_supir
      FROM pinjam p
      WHERE p.status != 'selesai'
        AND (
          datetime(p.tanggal_berangkat) < datetime(?)
          AND datetime(p.tanggal_kembali) > datetime(?)
        )
    )
  ''',
      [
        tglKembali.add(const Duration(hours: 1)).toIso8601String(),
        tglBerangkat.toIso8601String(),
      ],
    );

    return result;
  }

  Future<int> markNotifAsRead(int id) async {
    final db = await database;
    return await db.update(
      'pengajuan',
      {'dibaca': 1},
      where: 'id = ?',
      whereArgs: [id], // ✅ selalu List
    );
  }

  Future<List<Map<String, dynamic>>> getPinjamanAktifByUser(int userId) async {
    final db = await database;

    return await db.rawQuery(
      '''
  SELECT 
    pg.id,
    pg.id_user,
    pg.status AS status_pengajuan,
    p.status AS status_pinjam
  FROM pengajuan pg
  LEFT JOIN pinjam p ON pg.id = p.id_pengajuan
  WHERE pg.id_user = ?
    AND (
      pg.status = 'baru'
      OR (p.status IS NOT NULL AND p.status != 'selesai')
    )
  ''',
      [userId],
    );
  }

  Future<List<Map<String, dynamic>>> getMobilWithStatus() async {
    final db = await database;

    return await db.rawQuery('''
  SELECT 
      m.id,
      m.nomor_inventaris,
      m.merk,
      m.da,
      CASE 
          WHEN MIN(p.status) IS NOT NULL AND MIN(p.status) != 'selesai'
              THEN 'Dipakai'
          ELSE 'Ready'
      END as status,
      MIN(p.tanggal_berangkat) as tanggal_berangkat,
      MIN(p.tanggal_kembali) as tanggal_kembali
  FROM mobil m
  LEFT JOIN pinjam p 
      ON m.id = p.id_kendaraan 
      AND p.status != 'selesai'
  GROUP BY m.id, m.nomor_inventaris, m.merk, m.da
''');
  }

  Future<List<Map<String, dynamic>>> getAllPengajuan() async {
    final db = await database;
    return await db.query('pengajuan', orderBy: "id DESC");
  }
}
