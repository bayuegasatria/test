import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:open_filex/open_filex.dart' show OpenFilex;

class PinjamForm extends StatefulWidget {
  final TextEditingController nomorAjuanController;
  final TextEditingController namaPengajuController;
  final TextEditingController tujuanController;
  final TextEditingController pengemudiController;
  final TextEditingController jumlahPenumpangController;
  final TextEditingController keteranganController;

  final DateTime dariTanggal;
  final TimeOfDay dariJam;
  final DateTime sampaiTanggal;
  final TimeOfDay sampaiJam;

  final String jenisKendaraan;
  final String supir;

  final Function(String) onJenisKendaraanChanged;
  final Function(String) onSupirChanged;

  final Function(bool) pilihTanggal;
  final Function(bool) pilihJam;
  final VoidCallback onSelesai;

  final Function(File?)? onFilePicked;

  const PinjamForm({
    super.key,
    required this.nomorAjuanController,
    required this.namaPengajuController,
    required this.tujuanController,
    required this.pengemudiController,
    required this.jumlahPenumpangController,
    required this.keteranganController,
    required this.dariTanggal,
    required this.dariJam,
    required this.sampaiTanggal,
    required this.sampaiJam,
    required this.jenisKendaraan,
    required this.supir,
    required this.onJenisKendaraanChanged,
    required this.onSupirChanged,
    required this.pilihTanggal,
    required this.pilihJam,
    required this.onSelesai,
    this.onFilePicked,
  });

  @override
  State<PinjamForm> createState() => _PinjamFormState();
}

class _PinjamFormState extends State<PinjamForm> {
  File? _lampiran;

  Future<void> _pilihFile() async {
    _unfocusAll();
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
      withData: false,
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        _lampiran = File(result.files.single.path!);
      });

      if (widget.onFilePicked != null) {
        widget.onFilePicked!(_lampiran);
      }
    }
  }

  void _unfocusAll() {
    try {
      FocusScope.of(context).unfocus();
    } catch (_) {}

    try {
      FocusManager.instance.primaryFocus?.unfocus();
    } catch (_) {}

    FocusScope.of(context).requestFocus(FocusNode());
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _judul("Nomor Ajuan"),
          TextField(
            controller: widget.nomorAjuanController,
            readOnly: true,
            decoration: const InputDecoration(
              labelText: "Nomor Ajuan",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),

          _judul("Nama Pengaju"),
          TextField(
            controller: widget.namaPengajuController,
            readOnly: true,
            decoration: const InputDecoration(
              labelText: "Nama Pengaju",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),

          _judul("Tanggal Pemakaian"),
          _tanggalRow(context, true),
          const SizedBox(height: 12),
          _tanggalRow(context, false),
          const SizedBox(height: 20),

          _judul("Tujuan"),
          TextField(
            controller: widget.tujuanController,
            decoration: const InputDecoration(
              labelText: "Tujuan",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),

          _judul("Jenis Kendaraan"),
          Row(
            children: [
              Expanded(
                child: RadioListTile(
                  title: const Text("Mobil"),
                  value: "Mobil",
                  groupValue: widget.jenisKendaraan,
                  onChanged: (v) {
                    widget.onJenisKendaraanChanged(v.toString());
                    _unfocusAll();
                  },
                ),
              ),
              Expanded(
                child: RadioListTile(
                  title: const Text("Motor"),
                  value: "Motor",
                  groupValue: widget.jenisKendaraan,
                  onChanged: (v) {
                    widget.onJenisKendaraanChanged(v.toString());
                    _unfocusAll();
                  },
                ),
              ),
            ],
          ),

          if (widget.jenisKendaraan == "Mobil") ...[
            _judul("Supir"),
            Row(
              children: [
                Expanded(
                  child: RadioListTile(
                    title: const Text("Ya"),
                    value: "Ya",
                    groupValue: widget.supir,
                    onChanged: (v) {
                      widget.onSupirChanged(v.toString());
                      _unfocusAll();
                    },
                  ),
                ),
                Expanded(
                  child: RadioListTile(
                    title: const Text("Tidak"),
                    value: "Tidak",
                    groupValue: widget.supir,
                    onChanged: (v) {
                      widget.onSupirChanged(v.toString());
                      _unfocusAll();
                    },
                  ),
                ),
              ],
            ),
          ],

          if ((widget.jenisKendaraan == "Mobil" && widget.supir == "Tidak") ||
              widget.jenisKendaraan == "Motor") ...[
            _judul("Pengemudi"),
            TextField(
              controller: widget.pengemudiController,
              decoration: const InputDecoration(
                labelText: "Pengemudi",
                border: OutlineInputBorder(),
              ),
            ),
          ],

          _judul("Jumlah Penumpang"),
          SizedBox(
            width: 150,
            child: TextField(
              controller: widget.jumlahPenumpangController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Jumlah Penumpang",
                border: OutlineInputBorder(),
              ),
            ),
          ),
          const SizedBox(height: 20),

          _judul("Keterangan"),
          TextField(
            controller: widget.keteranganController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: "Keterangan",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),

          _judul("File Pendukung (Opsional)"),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(9)),
                      ),
                    ),
                    onPressed: _pilihFile,
                    icon: const Icon(Icons.attach_file, color: Colors.white),
                    label: const Text(
                      "Pilih File",
                      style: TextStyle(color: Colors.white, fontSize: 15),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              if (_lampiran != null)
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.grey.shade100,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  clipBehavior: Clip.hardEdge,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 120,
                        width: double.infinity,
                        color: Colors.grey.shade200,
                        child: Center(
                          child: Icon(
                            () {
                              final path = _lampiran!.path.toLowerCase();
                              if (path.endsWith('.pdf')) {
                                return Icons.picture_as_pdf;
                              } else if (path.endsWith('.doc') ||
                                  path.endsWith('.docx')) {
                                return Icons.description;
                              } else if (path.endsWith('.jpg') ||
                                  path.endsWith('.jpeg') ||
                                  path.endsWith('.png') ||
                                  path.endsWith('.gif') ||
                                  path.endsWith('.bmp') ||
                                  path.endsWith('.webp')) {
                                return Icons.image;
                              } else {
                                return Icons.insert_drive_file;
                              }
                            }(),
                            color: () {
                              final path = _lampiran!.path.toLowerCase();
                              if (path.endsWith('.pdf')) {
                                return Colors.red;
                              } else if (path.endsWith('.doc') ||
                                  path.endsWith('.docx')) {
                                return Colors.blue;
                              } else if (path.endsWith('.jpg') ||
                                  path.endsWith('.jpeg') ||
                                  path.endsWith('.png') ||
                                  path.endsWith('.gif') ||
                                  path.endsWith('.bmp') ||
                                  path.endsWith('.webp')) {
                                return Colors.green;
                              } else {
                                return Colors.grey;
                              }
                            }(),
                            size: 48,
                          ),
                        ),
                      ),
                      ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                        ),
                        leading: Icon(
                          () {
                            final path = _lampiran!.path.toLowerCase();
                            if (path.endsWith('.pdf')) {
                              return Icons.picture_as_pdf;
                            } else if (path.endsWith('.doc') ||
                                path.endsWith('.docx')) {
                              return Icons.description;
                            } else if (path.endsWith('.jpg') ||
                                path.endsWith('.jpeg') ||
                                path.endsWith('.png') ||
                                path.endsWith('.gif') ||
                                path.endsWith('.bmp') ||
                                path.endsWith('.webp')) {
                              return Icons.image;
                            } else {
                              return Icons.insert_drive_file;
                            }
                          }(),
                          color: () {
                            final path = _lampiran!.path.toLowerCase();
                            if (path.endsWith('.pdf')) {
                              return Colors.red;
                            } else if (path.endsWith('.doc') ||
                                path.endsWith('.docx')) {
                              return Colors.blue;
                            } else if (path.endsWith('.jpg') ||
                                path.endsWith('.jpeg') ||
                                path.endsWith('.png') ||
                                path.endsWith('.gif') ||
                                path.endsWith('.bmp') ||
                                path.endsWith('.webp')) {
                              return Colors.green;
                            } else {
                              return Colors.grey;
                            }
                          }(),
                          size: 25,
                        ),

                        title: Text(
                          _lampiran!.path.split('/').last,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        trailing: PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'open') {
                              OpenFilex.open(_lampiran!.path);
                            } else if (value == 'remove') {
                              setState(() {
                                _lampiran = null;
                              });
                            }
                          },
                          itemBuilder: (context) => const [
                            PopupMenuItem(value: 'open', child: Text('Buka')),
                            PopupMenuItem(
                              value: 'remove',
                              child: Text('Hapus'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              else
                const Text(
                  "Belum ada file dipilih",
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
            ],
          ),

          const SizedBox(height: 30),

          Center(
            child: SizedBox(
              height: 70,
              width: 200,
              child: ElevatedButton(
                onPressed: widget.onSelesai,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                ),
                child: const Text(
                  "Selesai",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _judul(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Text(text, style: const TextStyle(fontWeight: FontWeight.w600)),
  );

  Widget _tanggalRow(BuildContext context, bool isDari) => Row(
    children: [
      Expanded(
        child: InkWell(
          onTap: () {
            _unfocusAll();
            widget.pilihTanggal(isDari);
          },
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: isDari ? "Dari" : "Sampai",
              border: const OutlineInputBorder(),
            ),
            child: Text(
              isDari
                  ? "${widget.dariTanggal.day}/${widget.dariTanggal.month}/${widget.dariTanggal.year}"
                  : "${widget.sampaiTanggal.day}/${widget.sampaiTanggal.month}/${widget.sampaiTanggal.year}",
            ),
          ),
        ),
      ),
      const SizedBox(width: 8),
      Expanded(
        child: InkWell(
          onTap: () {
            _unfocusAll();
            widget.pilihJam(isDari);
          },
          child: InputDecorator(
            decoration: const InputDecoration(
              labelText: "Jam",
              border: OutlineInputBorder(),
            ),
            child: Text(
              isDari
                  ? "${widget.dariJam.hour.toString().padLeft(2, '0')}:${widget.dariJam.minute.toString().padLeft(2, '0')}"
                  : "${widget.sampaiJam.hour.toString().padLeft(2, '0')}:${widget.sampaiJam.minute.toString().padLeft(2, '0')}",
            ),
          ),
        ),
      ),
    ],
  );
}
