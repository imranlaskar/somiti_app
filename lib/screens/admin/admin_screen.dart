import 'package:flutter/material.dart';
import 'admin_savings_screen.dart';
import 'admin_due_screen.dart';
import 'admin_meeting_update_screen.dart';
import 'admin_finance_screen.dart';
import 'admin_chanda_update_screen.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('অ্যাডমিন প্যানেল'),
        backgroundColor: const Color(0xFF37474F),
        foregroundColor: Colors.white,
      ),
      backgroundColor: const Color(0xFFF0F2F8),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // হেডার
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF37474F),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Row(children: [
                Icon(Icons.admin_panel_settings,
                    color: Colors.white, size: 32),
                SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('অ্যাডমিন কন্ট্রোল প্যানেল',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold)),
                    Text('সকল তথ্য পরিচালনা করুন',
                        style: TextStyle(
                            color: Colors.white70, fontSize: 12)),
                  ],
                ),
              ]),
            ),
            const SizedBox(height: 20),

            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                children: [
                  _AdminCard(
                    icon: Icons.payments,
                    label: 'চাঁদা\nআপডেট',
                    color: const Color(0xFF4CAF50),
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) =>
                            const AdminChandaUpdateScreen())),
                  ),
                  _AdminCard(
                    icon: Icons.edit_note,
                    label: 'মিটিং নোটিশ\nআপডেট',
                    color: const Color(0xFF8E24AA),
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) =>
                            const AdminMeetingUpdateScreen())),
                  ),
                  _AdminCard(
                    icon: Icons.savings,
                    label: 'সকল সদস্যের\nসঞ্চয়',
                    color: const Color(0xFF00897B),
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) =>
                            const AdminSavingsScreen())),
                  ),
                  _AdminCard(
                    icon: Icons.warning_amber,
                    label: 'বকেয়া\nতালিকা',
                    color: const Color(0xFFE53935),
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) =>
                            const AdminDueScreen())),
                  ),

                  _AdminCard(
                    icon: Icons.bar_chart,
                    label: 'মাসিক আয়-ব্যয়\nরিপোর্ট',
                    color: const Color(0xFF1E88E5),
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) =>
                            const AdminFinanceScreen())),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AdminCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _AdminCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 36, color: color),
            ),
            const SizedBox(height: 12),
            Text(label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}