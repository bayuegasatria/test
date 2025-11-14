import 'dart:io';
import 'package:flutter/material.dart';
import '../../api/add_api.dart';

String toDateString(DateTime dt, TimeOfDay tod) {
  final jam = tod.hour.toString().padLeft(2, '0');
  final menit = tod.minute.toString().padLeft(2, '0');
  return "${dt.year.toString().padLeft(4, '0')}-"
      "${dt.month.toString().padLeft(2, '0')}-"
      "${dt.day.toString().padLeft(2, '0')} $jam:$menit:00";
}

/// Fungsi popup pengganti snackbar
Future<void> showPopup(
  BuildContext context,
  String message, {
  String title = "Peringatan",
}) async {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      backgroundColor: Colors.white,
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20,
          color: Colors.blueAccent,
        ),
      ),
      content: Text(message, style: const TextStyle(fontSize: 16)),
      actions: [
        TextButton(
          style: TextButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Colors.blueAccent,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onPressed: () => Navigator.pop(ctx),
          child: const Text("Dismiss"),
        ),
      ],
    ),
  );
}

Future<void> pilihTanggalHelper({
  required BuildContext context,
  required bool isDari,
  required DateTime dariTanggal,
  required DateTime sampaiTanggal,
  required TimeOfDay dariJam,
  required TimeOfDay sampaiJam,
  required Function(DateTime, DateTime, TimeOfDay, TimeOfDay) onUpdate,
}) async {
  FocusScope.of(context).unfocus();

  final DateTime? picked = await showDatePicker(
    context: context,
    initialDate: isDari ? dariTanggal : sampaiTanggal,
    firstDate: DateTime(2020),
    lastDate: DateTime(2100),
  );

  if (picked == null) return;

  var newDariTanggal = dariTanggal;
  var newSampaiTanggal = sampaiTanggal;
  var newDariJam = dariJam;
  var newSampaiJam = sampaiJam;

  if (isDari) {
    newDariTanggal = picked;
    final selectedStart = DateTime(
      newDariTanggal.year,
      newDariTanggal.month,
      newDariTanggal.day,
      newDariJam.hour,
      newDariJam.minute,
    );
    if (selectedStart.isBefore(DateTime.now())) {
      await showPopup(
        context,
        "Tanggal & jam berangkat tidak boleh sebelum sekarang.",
      );
      return;
    }
    if (newDariTanggal.isAfter(newSampaiTanggal)) {
      newSampaiTanggal = newDariTanggal;
      newSampaiJam = newDariJam;
    }
  } else {
    newSampaiTanggal = picked;
    if (newSampaiTanggal.isBefore(newDariTanggal)) {
      await showPopup(
        context,
        "Tanggal & jam selesai tidak boleh sebelum berangkat.",
      );
      newSampaiTanggal = newDariTanggal;
    }
    if (newSampaiTanggal.isAtSameMomentAs(newDariTanggal)) {
      final startTime = DateTime(
        newDariTanggal.year,
        newDariTanggal.month,
        newDariTanggal.day,
        newDariJam.hour,
        newDariJam.minute,
      );
      final endTime = DateTime(
        newSampaiTanggal.year,
        newSampaiTanggal.month,
        newSampaiTanggal.day,
        newSampaiJam.hour,
        newSampaiJam.minute,
      );
      if (endTime.isBefore(startTime)) {
        newSampaiJam = newDariJam;
      }
    }
  }

  onUpdate(newDariTanggal, newSampaiTanggal, newDariJam, newSampaiJam);
}

Future<void> pilihJamHelper({
  required BuildContext context,
  required bool isDari,
  required DateTime dariTanggal,
  required DateTime sampaiTanggal,
  required TimeOfDay dariJam,
  required TimeOfDay sampaiJam,
  required Function(TimeOfDay, TimeOfDay) onUpdate,
}) async {
  FocusScope.of(context).unfocus();

  final TimeOfDay? picked = await showTimePicker(
    context: context,
    initialTime: isDari ? dariJam : sampaiJam,
    initialEntryMode: TimePickerEntryMode.input,
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
      child: child!,
    ),
  );

  if (picked == null) return;

  var newDariJam = dariJam;
  var newSampaiJam = sampaiJam;

  if (isDari) {
    newDariJam = picked;
    final selectedStart = DateTime(
      dariTanggal.year,
      dariTanggal.month,
      dariTanggal.day,
      newDariJam.hour,
      newDariJam.minute,
    );
    if (selectedStart.isBefore(DateTime.now())) {
      await showPopup(
        context,
        "Jam berangkat tidak boleh sebelum waktu sekarang.",
      );
      return;
    }

    final endTime = DateTime(
      sampaiTanggal.year,
      sampaiTanggal.month,
      sampaiTanggal.day,
      newSampaiJam.hour,
      newSampaiJam.minute,
    );
    if (selectedStart.isAfter(endTime)) {
      newSampaiJam = newDariJam;
    }
  } else {
    newSampaiJam = picked;
    final startTime = DateTime(
      dariTanggal.year,
      dariTanggal.month,
      dariTanggal.day,
      newDariJam.hour,
      newDariJam.minute,
    );
    final selectedEnd = DateTime(
      sampaiTanggal.year,
      sampaiTanggal.month,
      sampaiTanggal.day,
      newSampaiJam.hour,
      newSampaiJam.minute,
    );
    if (selectedEnd.isBefore(startTime)) {
      await showPopup(
        context,
        "Jam selesai tidak boleh sebelum jam berangkat.",
      );
      return;
    }
  }

  onUpdate(newDariJam, newSampaiJam);
}

Future<bool> simpanPengajuanHelper({
  required BuildContext context,
  required String userId,
  required DateTime dariTanggal,
  required TimeOfDay dariJam,
  required DateTime sampaiTanggal,
  required TimeOfDay sampaiJam,
  required String noPengajuan,
  required String tujuan,
  required String jenisKendaraan,
  required String supir,
  required String pengemudi,
  required String jumlahPenumpang,
  required String keterangan,
  File? fileLampiran,
}) async {
  final start = DateTime(
    dariTanggal.year,
    dariTanggal.month,
    dariTanggal.day,
    dariJam.hour,
    dariJam.minute,
  );
  final end = DateTime(
    sampaiTanggal.year,
    sampaiTanggal.month,
    sampaiTanggal.day,
    sampaiJam.hour,
    sampaiJam.minute,
  );

  if (start.isBefore(DateTime.now())) {
    await showPopup(
      context,
      "Tanggal/jam berangkat tidak boleh sebelum sekarang.",
    );
    return false;
  }
  if (start.isAfter(end)) {
    await showPopup(context, "Waktu mulai tidak boleh melebihi waktu selesai.");
    return false;
  }

  return await AddApi.simpanPengajuan(
    context,
    idUser: userId,
    noPengajuan: noPengajuan,
    tujuan: tujuan,
    jenisKendaraan: jenisKendaraan,
    perluSupir: supir,
    pengemudi: pengemudi,
    tanggalBerangkat: toDateString(dariTanggal, dariJam),
    tanggalKembali: toDateString(sampaiTanggal, sampaiJam),
    jumlahPengguna: jumlahPenumpang,
    keterangan: keterangan,
    fileLampiran: fileLampiran,
  );
}
