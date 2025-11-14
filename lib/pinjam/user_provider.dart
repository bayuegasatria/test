import 'package:flutter/material.dart';

class UserProvider with ChangeNotifier {
  String _role = "atasan";
  String _nama = "Bayu Ega Satria";
  String _nip = "2210010249";
  String _id = "1";
  String _div = "";
  String _divId = "1";
  String _namarole = "role";

  String get role => _role;
  String get nama => _nama;
  String get nip => _nip;
  String get id => _id;
  String get div => _div;
  String get divId => _divId;
  String get namarole => _namarole;

  void setRole(String newRole) {
    _role = newRole;
    notifyListeners();
  }

  void setUserData(
    String nama,
    String nip,
    String role,
    String id,
    String div,
    String divId,
    String namarole,
  ) {
    _nama = nama;
    _nip = nip;
    _role = role;
    _id = id;
    _div = div;
    _divId = divId;
    _namarole = namarole;
    notifyListeners();
  }
}
