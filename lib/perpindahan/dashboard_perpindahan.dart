import 'package:flutter/material.dart';
import 'package:newapp/perpindahan/distribusi_bmn/distribusi_bmn.dart';
import 'package:newapp/perpindahan/perpindahan_dbr/perpindahan_dbr.dart';
import 'package:newapp/pinjam/dashboard_bmn.dart';

class DashboardPerpindahan extends StatefulWidget {
  const DashboardPerpindahan({super.key});

  @override
  State<DashboardPerpindahan> createState() => _DashboardPerpindahanState();
}

class _DashboardPerpindahanState extends State<DashboardPerpindahan> {
  String? selectedMenu;

  void handleMenuSelect(String menuType) {
    setState(() => selectedMenu = menuType);

    Future.delayed(const Duration(milliseconds: 300), () {
      setState(() => selectedMenu = null);

      if (menuType == 'bmn') {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const DistribusiBmnScreen()),
        );
      } else if (menuType == 'dbr') {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const PerpindahanDBRScreen()),
        );
      }
    });
  }

  void _handleBackToDashboard() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const DashboardBmn()),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 100,
        title: const Text(
          "Sistem Perpindahan",
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
                  "Manajemen Perpindahan Barang",
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
              title: 'Distribusi BMN',
              subtitle: 'Barang Milik Negara',
              description: 'Kelola perpindahan barang milik negara',
              icon: Icons.move_up,
              iconBgColor: const Color(0xFF8B5CF6),
              isSelected: selectedMenu == 'bmn',
              borderColor: const Color(0xFF7C3AED),
              onTap: () => handleMenuSelect('bmn'),
            ),

            // ---- Perpindahan DBR ----
            _menuCard(
              context,
              title: 'Perpindahan DBR',
              subtitle: 'Dana Bergulir',
              description: 'Kelola perpindahan dana bergulir',
              icon: Icons.room,
              iconBgColor: const Color(0xFF06B6D4),
              isSelected: selectedMenu == 'dbr',
              borderColor: const Color(0xFF0891B2),
              onTap: () => handleMenuSelect('dbr'),
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
