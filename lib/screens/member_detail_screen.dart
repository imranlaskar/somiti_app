import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/user_model.dart';
import '../widgets/drive_image.dart';

class MemberDetailScreen extends StatelessWidget {
  final UserModel member;
  const MemberDetailScreen({super.key, required this.member});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('সদস্য বিস্তারিত'),
        backgroundColor: const Color(0xFF3F51B5),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          // Photo
          Center(
            child: CircleAvatar(
              radius: 60,
              backgroundColor: const Color(0xFF3F51B5),
              child: DriveImage(
                fileId: member.fileId,
                size: 120,
                fallbackText: member.name,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(member.name,
              style: const TextStyle(
                  fontSize: 22, fontWeight: FontWeight.bold)),
          Text(member.role,
              style: const TextStyle(color: Color(0xFF3F51B5), fontSize: 16)),
          const SizedBox(height: 24),

          // Info card
          Card(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(children: [
                _InfoRow(icon: Icons.badge, label: 'সদস্য আইডি', value: member.memberId),
                _InfoRow(icon: Icons.phone, label: 'ফোন', value: member.phone),
                _InfoRow(icon: Icons.location_on, label: 'ঠিকানা', value: member.address),
                _InfoRow(icon: Icons.calendar_today, label: 'যোগদানের তারিখ', value: member.joinDate),
              ]),
            ),
          ),
        ]),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoRow(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(children: [
        Icon(icon, color: const Color(0xFF3F51B5), size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label,
                style: TextStyle(fontSize: 12, color: Colors.grey[600])),
            Text(value.isNotEmpty ? value : '—',
                style: const TextStyle(fontSize: 15)),
          ]),
        ),
      ]),
    );
  }
}