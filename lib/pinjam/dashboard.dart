import 'package:flutter/material.dart';
import 'package:newapp/pinjam/dashboard_bmn.dart';
import 'package:newapp/pinjam/dashboard_maintenance.dart';
import 'package:provider/provider.dart';
import 'package:newapp/pinjam/accpage.dart';
import 'package:newapp/pinjam/user_provider.dart' show UserProvider;

import '../api/pinjam_api.dart';
import '../api/notifikasi_api.dart';
import '../api/mobil_api.dart';
import 'widgets/account_panel.dart';
import 'widgets/status_card.dart';
import 'widgets/jadwal_section.dart';
import 'widgets/notification_panel.dart';
import '../services/notification_service.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> with WidgetsBindingObserver {
  List<Map<String, dynamic>> _statusList = [];
  List<Map<String, dynamic>> _jadwalList = [];
  List<Map<String, dynamic>> _notifList = [];
  int _notifCount = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final user = Provider.of<UserProvider>(context, listen: false);
    final now = DateTime.now();

    setState(() => _isLoading = true);

    final status = await PinjamApi.getStatusPinjamUser(int.parse(user.id), now);
    final jadwal = await MobilApi.getJadwalMobil(now);
    final notif = await NotifikasiApi.getNotifikasi(int.parse(user.id));
    final notifCount = await NotifikasiApi.getNotifCount(int.parse(user.id));

    if (!mounted) return;
    setState(() {
      _statusList = status;
      _jadwalList = jadwal;
      _notifList = notif;
      _notifCount = notifCount;
      _isLoading = false;
    });
  }

  Future<void> _refreshData() async {
    final user = Provider.of<UserProvider>(context, listen: false);
    final now = DateTime.now();

    try {
      final notifCount = await NotifikasiApi.getNotifCount(int.parse(user.id));
      final notif = await NotifikasiApi.getNotifikasi(int.parse(user.id));
      final status = await PinjamApi.getStatusPinjamUser(
        int.parse(user.id),
        now,
      );
      final jadwal = await MobilApi.getJadwalMobil(now);

      if (mounted) {
        setState(() {
          _notifCount = notifCount;
          _notifList = notif;
          _statusList = status;
          _jadwalList = jadwal;
        });
      }
    } catch (e) {
      print('❌ Gagal refresh data: $e');
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshData();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    NotificationService().onMessageCallback = null;

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        toolbarHeight: 91,
        backgroundColor: const Color(0xFF1E88E5),
        leading: IconButton(
          onPressed: () => showAccountPanel(context),
          icon: const CircleAvatar(
            radius: 18,
            backgroundColor: Colors.white,
            child: Icon(Icons.person, color: Color(0xFF1E88E5)),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              user.nama,
              style: const TextStyle(
                fontSize: 20,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              user.nip,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              showNotificationPanel(
                context,
                Future.value(_notifList),
                userId: int.parse(user.id),
                onClose: _refreshData,
              );
            },
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const CircleAvatar(
                  radius: 18,
                  backgroundColor: Color(0xFF1E88E5),
                  child: Icon(Icons.notifications, color: Colors.white),
                ),
                if (_notifCount > 0)
                  Positioned(
                    right: -2,
                    top: -2,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      transitionBuilder: (child, anim) =>
                          ScaleTransition(scale: anim, child: child),
                      child: Container(
                        key: ValueKey(_notifCount),
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 18,
                          minHeight: 18,
                        ),
                        child: Text(
                          _notifCount.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 20),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _refreshData,
              child: ListView(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E88E5),
                          borderRadius: const BorderRadius.vertical(
                            bottom: Radius.elliptical(200, 60),
                          ),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.blueGrey,
                              width: 1,
                            ),
                            color: Colors.white,
                            borderRadius: const BorderRadius.all(
                              Radius.circular(10),
                            ),
                          ),
                          margin: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 0,
                          ),
                          child: Center(
                            child: GridView.count(
                              crossAxisCount: 3,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              childAspectRatio: 0.8,
                              children: [
                                _buildMenuItem(
                                  context,
                                  iconPath: 'assets/icons/rent.png',
                                  title: "Peminjaman \nKendaraan",
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const AccPage(),
                                      ),
                                    );
                                  },
                                ),

                                _buildMenuItem(
                                  context,
                                  iconPath: 'assets/icons/optimizing.png',
                                  title: "Pemeliharaan",
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const DashboardMaintenance(),
                                    ),
                                  ),
                                ),

                                _buildMenuItem(
                                  context,
                                  iconPath: 'assets/icons/cart.png',
                                  title: "BMN",
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const DashboardBmn(),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      StatusCard(
                        statusFuture: Future.value(_statusList),
                        onRefresh: _refreshData,
                      ),

                      JadwalSection(jadwalFuture: Future.value(_jadwalList)),
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}

Widget _buildMenuItem(
  BuildContext context, {
  required String iconPath,
  required String title,
  VoidCallback? onTap,
}) {
  final screenWidth = MediaQuery.of(context).size.width;

  return InkWell(
    onTap: onTap,
    child: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            iconPath,
            width: screenWidth * 0.12,
            height: screenWidth * 0.12,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 6),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: screenWidth * 0.03),
          ),
        ],
      ),
    ),
  );
}
