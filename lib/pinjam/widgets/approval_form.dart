import 'package:flutter/material.dart';

class ApprovalForm extends StatefulWidget {
  final List<Map<String, dynamic>> kendaraanList;
  final List<Map<String, dynamic>> supirList;
  final String? selectedKendaraan;
  final String? selectedSupir;
  final TextEditingController catatanController;
  final bool readOnly;
  final bool perluSupir;
  final ValueChanged<String?>? onKendaraanChanged;
  final ValueChanged<String?>? onSupirChanged;

  const ApprovalForm({
    super.key,
    required this.kendaraanList,
    required this.supirList,
    required this.selectedKendaraan,
    required this.selectedSupir,
    required this.catatanController,
    required this.readOnly,
    required this.perluSupir,
    this.onKendaraanChanged,
    this.onSupirChanged,
  });

  @override
  State<ApprovalForm> createState() => _ApprovalFormState();
}

class _ApprovalFormState extends State<ApprovalForm> {
  String? selectedKendaraanLabel;
  String? selectedSupirLabel;

  @override
  void initState() {
    super.initState();
    selectedKendaraanLabel = _findLabel(
      widget.kendaraanList,
      widget.selectedKendaraan,
      "merk",
      "police_number",
    );
    selectedSupirLabel = _findLabel(
      widget.supirList,
      widget.selectedSupir,
      "name",
      null,
    );
  }

  String? _findLabel(
    List<Map<String, dynamic>> list,
    String? id,
    String key1,
    String? key2,
  ) {
    if (id == null) return null;
    final item = list.firstWhere(
      (e) => e["id"].toString() == id,
      orElse: () => {},
    );
    if (item.isEmpty) return null;
    if (key2 == null || item[key2] == null) {
      return "${item[key1]}";
    }
    return "${item[key1]} (${item[key2]})";
  }

  void _unfocusAll() {
    FocusScope.of(context).unfocus();
    FocusManager.instance.primaryFocus?.unfocus();
  }

  Future<void> _showSearchDialog({
    required List<Map<String, dynamic>> data,
    required String title,
    required ValueChanged<Map<String, dynamic>> onSelected,
    required String key1,
    String? key2,
  }) async {
    final controller = TextEditingController();
    List<Map<String, dynamic>> filtered = List.from(data);

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(title),
              content: SizedBox(
                width: double.maxFinite,
                height: 400,
                child: Column(
                  children: [
                    TextField(
                      controller: controller,
                      decoration: const InputDecoration(
                        hintText: "Cari...",
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        _unfocusAll();
                        setState(() {
                          filtered = data
                              .where(
                                (e) =>
                                    e[key1].toString().toLowerCase().contains(
                                      value.toLowerCase(),
                                    ) ||
                                    (key2 != null &&
                                        e[key2]
                                            .toString()
                                            .toLowerCase()
                                            .contains(value.toLowerCase())),
                              )
                              .toList();
                        });
                      },
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: ListView.builder(
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final item = filtered[index];
                          final status = (item["status_pinjam"] ?? "")
                              .toString();
                          final isReady = status.toLowerCase() == "ready";

                          return Container(
                            decoration: const BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: Colors.black12,
                                  width: 1,
                                ),
                              ),
                            ),
                            child: ListTile(
                              leading: Icon(
                                isReady
                                    ? Icons.check_circle
                                    : Icons.cancel_rounded,
                                color: isReady
                                    ? Colors.green
                                    : Colors.redAccent,
                              ),
                              title: Text(
                                key2 == null
                                    ? "${item[key1]}"
                                    : "${item[key1]} (${item[key2]})",
                              ),
                              subtitle: Text(
                                status,
                                style: TextStyle(
                                  color: isReady
                                      ? Colors.green
                                      : Colors.redAccent,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              onTap: () {
                                Navigator.pop(context);
                                onSelected(item);
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Pilih Kendaraan",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: widget.readOnly
              ? null
              : () => _showSearchDialog(
                  data: widget.kendaraanList,
                  title: "Pilih Kendaraan",
                  key1: "merk",
                  key2: "police_number",
                  onSelected: (item) {
                    setState(() {
                      selectedKendaraanLabel =
                          "${item["merk"]} (${item["police_number"]})";
                    });
                    widget.onKendaraanChanged?.call(item["id"].toString());
                  },
                ),
          child: AbsorbPointer(
            child: TextFormField(
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.arrow_drop_down),
              ),
              controller: TextEditingController(
                text: selectedKendaraanLabel ?? "",
              ),
              readOnly: true,
            ),
          ),
        ),

        const SizedBox(height: 20),

        if (widget.perluSupir)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Pilih Supir",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: widget.readOnly
                    ? null
                    : () => _showSearchDialog(
                        data: widget.supirList,
                        title: "Pilih Supir",
                        key1: "name",
                        onSelected: (item) {
                          setState(() {
                            selectedSupirLabel = "${item["name"]}";
                          });
                          widget.onSupirChanged?.call(item["id"].toString());
                        },
                      ),
                child: AbsorbPointer(
                  child: TextFormField(
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.arrow_drop_down),
                    ),
                    controller: TextEditingController(
                      text: selectedSupirLabel ?? "",
                    ),
                    readOnly: true,
                  ),
                ),
              ),
            ],
          ),

        const SizedBox(height: 20),
        const Text(
          "Catatan",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: widget.catatanController,
          maxLines: 3,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: "Tambahkan catatan (opsional)...",
          ),
        ),
      ],
    );
  }
}
