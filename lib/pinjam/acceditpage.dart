import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:newapp/api/pengajuan_api.dart';
import 'package:newapp/api/mobil_api.dart';
import 'package:newapp/api/driver_api.dart';
import 'package:newapp/pinjam/user_provider.dart';
import 'package:newapp/pinjam/accpage.dart';
import 'package:newapp/pinjam/widgets/approval_form.dart';
import 'package:newapp/pinjam/widgets/read_only_field.dart';

class AccEditPage extends StatefulWidget {
  final Map<String, dynamic> data;

  const AccEditPage({super.key, required this.data});

  @override
  State<AccEditPage> createState() => _AccEditPageState();
}

class _AccEditPageState extends State<AccEditPage> {
  String? selectedKendaraan;
  String? selectedSupir;

  bool pakaiSupir = true; // default = pakai supir
  final TextEditingController pengemudiController = TextEditingController();
  final TextEditingController catatanController = TextEditingController();

  // 🔹 Tambahan variabel untuk menyimpan data tetap
  String? pengemudiManual; // Simpan nama pengemudi jika tidak pakai supir
  String? supirTerpilih; // Simpan ID supir jika pakai supir

  List<Map<String, dynamic>> kendaraanList = [];
  List<Map<String, dynamic>> supirList = [];

  @override
  void initState() {
    super.initState();
    _loadDropdownData();
    _loadExistingData();
  }

  Future<void> _loadExistingData() async {
    final detail = await PengajuanApi.getDetailAcc(
      int.parse(widget.data["id"].toString()),
    );
    if (detail != null) {
      setState(() {
        selectedKendaraan = detail["id_kendaraan"]?.toString();
        selectedSupir = detail["id_supir"]?.toString();
        supirTerpilih = selectedSupir; // simpan supir awal
        catatanController.text = detail["catatan"] ?? "";

        // Jika id_supir kosong, berarti tidak pakai supir
        pakaiSupir = selectedSupir != null && selectedSupir!.isNotEmpty;
        if (!pakaiSupir) {
          pengemudiController.text = detail["pengemudi"] ?? "";
          pengemudiManual = pengemudiController.text;
        }
      });
    }
  }

  Future<void> _loadDropdownData() async {
    final tglBerangkat = DateTime.parse(widget.data["tanggal_berangkat"]);
    final tglKembali = DateTime.parse(widget.data["tanggal_kembali"]);
    final type = widget.data["jenis_kendaraan"];

    final mobil = await MobilApi.getAvailableMobil(
      tglBerangkat,
      tglKembali,
      type,
    );
    final supir = await DriverApi.getAvailableSupir(tglBerangkat, tglKembali);

    setState(() {
      kendaraanList = mobil;
      supirList = supir;
    });
  }

  Future<void> _handleSimpan() async {
    final user = Provider.of<UserProvider>(context, listen: false);

    if (selectedKendaraan == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Pilih kendaraan terlebih dahulu")),
      );
      return;
    }

    if (pakaiSupir && (supirTerpilih == null || supirTerpilih!.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Pilih supir terlebih dahulu")),
      );
      return;
    }

    if (!pakaiSupir &&
        (pengemudiManual == null || pengemudiManual!.trim().isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Isi nama pengemudi terlebih dahulu")),
      );
      return;
    }

    final int idMobil = int.parse(selectedKendaraan!);
    final int? idSupir = pakaiSupir
        ? int.parse(supirTerpilih!)
        : null; // hanya kirim jika perlu
    final String pengemudi = pakaiSupir
        ? ""
        : pengemudiManual!.trim(); // hanya kirim jika manual

    final success = await PengajuanApi.updateAccPengajuan(
      idMobil: idMobil,
      idSupir: idSupir,
      idUserLogin: int.parse(user.id),
      catatan: catatanController.text,
      idPengajuan: int.parse(widget.data["id"].toString()),
      pengemudi: pengemudi,
    );

    if (success) {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AccPage()),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Gagal memperbarui data ACC")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 91,
        title: const Text(
          "Persetujuan Peminjaman",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF1E88E5),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(65),
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(color: Colors.blueGrey, width: 1),
              ),
            ),
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.arrow_back, color: Colors.black),
                ),
                const SizedBox(width: 20),
                const Text(
                  "Edit Detail Peminjaman",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ReadOnlyField(
              label: "Nomor Surat",
              value: widget.data["no_pengajuan"] ?? "-",
            ),
            ReadOnlyField(
              label: "Nama Pengaju",
              value: widget.data["nama"] ?? "-",
            ),
            ReadOnlyField(label: "Tujuan", value: widget.data["tujuan"] ?? "-"),
            ReadOnlyField(
              label: "Tanggal Berangkat",
              value: widget.data["tanggal_berangkat"] ?? "-",
            ),
            ReadOnlyField(
              label: "Tanggal Kembali",
              value: widget.data["tanggal_kembali"] ?? "-",
            ),
            const SizedBox(height: 20),
            ReadOnlyField(
              label: "Kendaraan Asal",
              value: widget.data["nama_kendaraan"] ?? "-",
            ),
            const SizedBox(height: 20),
            ReadOnlyField(
              label: "Supir Asal",
              value:
                  widget.data["nama_supir"] ?? widget.data["pengemudi"] ?? "-",
            ),

            const SizedBox(height: 20),
            const Text(
              "Pakai Supir?",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Row(
              children: [
                Expanded(
                  child: RadioListTile<bool>(
                    title: const Text("Ya"),
                    value: true,
                    groupValue: pakaiSupir,
                    onChanged: (value) {
                      setState(() {
                        pakaiSupir = value!;
                        // tidak menghapus data lain
                        if (pakaiSupir) {
                          supirTerpilih ??= selectedSupir;
                        } else {
                          pengemudiManual = pengemudiController.text;
                        }
                      });
                    },
                  ),
                ),
                Expanded(
                  child: RadioListTile<bool>(
                    title: const Text("Tidak"),
                    value: false,
                    groupValue: pakaiSupir,
                    onChanged: (value) {
                      setState(() {
                        pakaiSupir = value!;
                        // tidak menghapus data lain
                        if (pakaiSupir) {
                          supirTerpilih ??= selectedSupir;
                        } else {
                          pengemudiManual = pengemudiController.text;
                        }
                      });
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // 🔹 Jika tidak pakai supir → tampilkan input pengemudi manual
            if (!pakaiSupir)
              TextField(
                controller: pengemudiController..text = pengemudiManual ?? "",
                onChanged: (val) => pengemudiManual = val,
                decoration: const InputDecoration(
                  labelText: "Pengemudi",
                  border: OutlineInputBorder(),
                ),
              ),

            const SizedBox(height: 30),
            // Pilihan kendaraan dan supir
            ApprovalForm(
              kendaraanList: kendaraanList,
              supirList: supirList,
              selectedKendaraan: selectedKendaraan,
              selectedSupir: pakaiSupir ? supirTerpilih : null, // hide supir
              catatanController: catatanController,
              readOnly: false,
              perluSupir: pakaiSupir, // 🔹 hanya tampil jika pakai supir
              onKendaraanChanged: (val) =>
                  setState(() => selectedKendaraan = val),
              onSupirChanged: (val) => setState(
                () => supirTerpilih = val,
              ), // simpan di variabel tetap
            ),

            const SizedBox(height: 20),

            Center(
              child: ElevatedButton.icon(
                onPressed: _handleSimpan,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  minimumSize: const Size(200, 55),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.save, color: Colors.white),
                label: const Text(
                  "Simpan Perubahan",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
