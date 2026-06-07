import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/sheets_service.dart';
import '../widgets/drive_image.dart';
import 'members_screen.dart';
import 'chanda_screen.dart';
import 'loan_savings_screen.dart';
import 'meeting_screen.dart';
import '../services/auth_service.dart';
import '../screens/login_screen.dart';
import 'rules_screen.dart';
import 'help_screen.dart';
import 'accounts_screen.dart';
import 'admin/admin_screen.dart';

class DashboardScreen extends StatelessWidget {
  final Map<String, dynamic> user;
  const DashboardScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final name = user['name']?.toString() ?? 'সদস্য';
    final role = user['role']?.toString() ?? '';
    final memberId = user['member_id']?.toString() ?? '';

    // ✅ Drive File ID বের করো
    final rawPhoto = user['photo_url']?.toString() ?? '';
    final fileId = UserModel.extractFileId(rawPhoto);

    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFF3F51B5),
        foregroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('নবদিগন্ত সমিতি অ্যাপ',
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold)),
            Text('স্বাগতম, $name',
                style: const TextStyle(
                    fontSize: 12, color: Colors.white70)),
          ],
        ),
        actions: [
          // ✅ শুধু admin দেখবে
          if (user['role']?.toString().toLowerCase() == 'admin')
            IconButton(
              icon: const Icon(Icons.admin_panel_settings),
              tooltip: 'অ্যাডমিন প্যানেল',
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const AdminScreen()),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await AuthService.logout();
              if (context.mounted) {
                Navigator.pushReplacement(context,
                    MaterialPageRoute(
                        builder: (_) => const LoginScreen()));
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ✅ User info card — Drive থেকে ছবি
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(children: [

                  // ✅ ছবি
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: const Color(0xFF3F51B5),
                    child: ClipOval(
                      child: DriveImage(
                        fileId: fileId,
                        size: 60,
                        fallbackText: name,
                      ),
                    ),
                  ),

                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(name,
                            style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold)),
                        Text('Position: $role',
                            style: TextStyle(
                                color: Colors.grey[600])),
                        Text('ID: $memberId',
                            style: TextStyle(
                                color: Colors.grey[600])),
                      ],
                    ),
                  ),
                ]),
              ),
            ),

            const SizedBox(height: 20),
            const Text('মেনু',
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),

            // Menu grid
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                children: [
                  _MenuCard(
                    icon: Icons.payments,
                    label: 'চাঁদা / লেনদেন',
                    color: const Color(0xFF4CAF50),
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) =>
                                ChandaScreen(memberId: memberId))),
                  ),

                  _MenuCard(
                    icon: Icons.account_balance_wallet,
                    label: 'লোন / সঞ্চয়',
                    color: const Color(0xFFFF9800),
                    onTap: () async {
                      // ✅ চাঁদার মোট পরিশোধ আগে লোড করো
                      final chandaData =
                      await SheetsService.getMemberChanda(memberId);
                      double totalChanda = 0;
                      for (final r in chandaData) {
                        if (r['status'].toString().toLowerCase() == 'paid') {
                          totalChanda +=
                              double.tryParse(r['amount'].toString()) ?? 0;
                        }
                      }
                      if (context.mounted) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => LoanSavingsScreen(
                              memberId: memberId,
                              totalChandaPaid: totalChanda, // ✅ পাঠাও
                            ),
                          ),
                        );
                      }
                    },
                  ),

                  _MenuCard(
                    icon: Icons.event_note,
                    label: 'মিটিং নোটিশ',
                    color: const Color(0xFFE91E63),
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const MeetingScreen())),
                  ),
                  _MenuCard(
                    icon: Icons.account_balance,
                    label: 'ব্যাংক/মোবাইল',
                    color: const Color(0xFF1565C0),
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(
                            builder: (_) => const AccountsScreen())),
                  ),
                  _MenuCard(
                    icon: Icons.rule,
                    label: 'নিয়মকানুন',
                    color: const Color(0xFF5C6BC0),
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const RulesScreen())),
                  ),
                  _MenuCard(
                    icon: Icons.people,
                    label: 'সদস্য তালিকা',
                    color: const Color(0xFF3F51B5),
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const MembersScreen())),
                  ),
                  _MenuCard(
                    icon: Icons.headset_mic,
                    label: 'হেল্পলাইন',
                    color: const Color(0xFF00897B),
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const HelpScreen())),
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

class _MenuCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _MenuCard({
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
                style: const TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}