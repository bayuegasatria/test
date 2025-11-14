import 'package:flutter/material.dart';
import 'package:newapp/perpindahan/dashboard_perpindahan.dart';
import 'package:newapp/pinjam/dashboard.dart';
import 'package:newapp/pinjam/datamobilpage.dart';
import 'package:newapp/pinjam/historypinjampage.dart';
import 'package:newapp/pinjam/reportpage.dart';
import 'package:newapp/pinjam/user_provider.dart';
import 'package:provider/provider.dart';

class DashboardBmn extends StatefulWidget {
  const DashboardBmn({super.key});

  @override
  State<DashboardBmn> createState() => _DashboardBmnState();
}

class _DashboardBmnState extends State<DashboardBmn> {
  String? selectedMenu;

  void handleMenuSelect(String menuType) {
    setState(() => selectedMenu = menuType);

    Future.delayed(const Duration(milliseconds: 300), () {
      setState(() => selectedMenu = null);

      if (menuType == 'kendaraan') {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const DataMobilPage()),
        );
      } else if (menuType == 'laporan') {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ReportPage()),
        );
      } else if (menuType == 'history') {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const HistoryPinjamPage()),
        );
      } else if (menuType == 'perpindahan') {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const DashboardPerpindahan()),
        );
      }
    });
  }

  void _handleBackToDashboard() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const Dashboard()),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context, listen: false);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 100,
        title: const Text(
          "BMN",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF1E88E5),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(color: Colors.blueGrey, width: 1),
              ),
            ),
            padding: const EdgeInsets.all(12),
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                IconButton(
                  onPressed: _handleBackToDashboard,
                  icon: const Icon(Icons.arrow_back, color: Colors.black),
                ),
                const SizedBox(width: 12),
                const Text(
                  "Menu BMN",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
      ),

      // ===== Main Body =====
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            const SizedBox(height: 16),

            // ---- Perpindahan BMN ----
            _menuCard(
              context,
              title: 'Data Kendaraan',
              subtitle: 'Kendaraan Dinas',
              description: 'Cek ketersediaan, jadwal dan history kendaraan',
              icon: Icons.garage,
              iconBgColor: const Color(0xFF8B5CF6),
              isSelected: selectedMenu == 'kendaraan',
              borderColor: const Color(0xFF7C3AED),
              onTap: () => handleMenuSelect('kendaraan'),
            ),

            // ---- Perpindahan DBR ----
            _menuCard(
              context,
              title: 'History Peminjaman',
              subtitle: 'History peminjaman perorangan',
              description: 'Cek caratan peminjaman yang sudah berlalu',
              icon: Icons.timelapse,
              iconBgColor: const Color(0xFF06B6D4),
              isSelected: selectedMenu == 'history',
              borderColor: const Color(0xFF0891B2),
              onTap: () => handleMenuSelect('history'),
            ),
            _menuCard(
              context,
              title: 'Laporan',
              subtitle: 'Laporan pemakaian kendaraan dan perbaikan bmn',
              description:
                  'Cetak laporan pemakaian kendaraan atau perbaikan bmn',
              icon: Icons.folder,
              iconBgColor: const Color.fromARGB(255, 46, 224, 76),
              isSelected: selectedMenu == 'laporan',
              borderColor: const Color.fromARGB(255, 10, 253, 30),
              onTap: () => handleMenuSelect('laporan'),
            ),
            if (user.role == 'AdminTIK')
              _menuCard(
                context,
                title: 'Perpindahan',
                subtitle: 'Perpindahan dbr dan distribusi bmn',
                description: 'Lakukan perpindahan dbr atau distribusi bmn',
                icon: Icons.move_down,
                iconBgColor: const Color.fromARGB(255, 217, 245, 61),
                isSelected: selectedMenu == 'perpindahan',
                borderColor: const Color.fromARGB(255, 173, 235, 2),
                onTap: () => handleMenuSelect('perpindahan'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _menuCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String description,
    required IconData icon,
    required Color iconBgColor,
    required bool isSelected,
    required Color borderColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: isSelected ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? borderColor : const Color(0xFFE5E7EB),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(24),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF9CA3AF),
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1E88E5)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
