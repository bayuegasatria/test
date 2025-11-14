import 'package:flutter/material.dart';
import 'package:newapp/pemeliharaan/bmn_non_tik/aduan_nontik/daftar_aduan_kerusakan_nontik.dart';
import 'package:newapp/pemeliharaan/bmn_tik/daftar_aduan/daftar_aduan_kerusakan_tik.dart';

class DashboardMaintenance extends StatefulWidget {
  const DashboardMaintenance({super.key});

  @override
  State<DashboardMaintenance> createState() => _DashboardMaintenanceState();
}

class _DashboardMaintenanceState extends State<DashboardMaintenance> {
  String? selectedMenu;

  void handleMenuSelect(String menuType) {
    setState(() => selectedMenu = menuType);

    Future.delayed(const Duration(milliseconds: 300), () {
      setState(() => selectedMenu = null);

      if (menuType == 'non_tik') {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const DaftarAduanPemeliharaanScreen(),
          ),
        );
      } else if (menuType == 'tik') {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const DaftarAduanKerusakanTIKScreen(),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: true,
        toolbarHeight: 90,
        title: const Text(
          "Maintenance BMN",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF1E88E5),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            const SizedBox(height: 16),

            // --- Menu 1: Maintenance Non-TIK ---
            _menuCard(
              title: "Maintenance Non-TIK",
              subtitle: "Pemeliharaan barang non tik",
              description:
                  "Cek dan kelola aduan pemeliharaan non teknologi informasi",
              icon: Icons.build,
              iconBgColor: const Color(0xFF06B6D4),
              isSelected: selectedMenu == 'non_tik',
              borderColor: const Color(0xFF0891B2),
              onTap: () => handleMenuSelect('non_tik'),
            ),

            // --- Menu 2: Maintenance TIK ---
            _menuCard(
              title: "Maintenance TIK",
              subtitle: "Kerusakan dan pemeliharaan perangkat TIK",
              description:
                  "Laporkan atau kelola kendala pada komputer, printer, dan perangkat TIK lainnya",
              icon: Icons.computer,
              iconBgColor: const Color(0xFF8B5CF6),
              isSelected: selectedMenu == 'tik',
              borderColor: const Color(0xFF7C3AED),
              onTap: () => handleMenuSelect('tik'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _menuCard({
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
        padding: const EdgeInsets.all(24),
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
                  valueColor: AlwaysStoppedAnimation(Color(0xFF1E88E5)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
