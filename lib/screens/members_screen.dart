import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../services/sheets_service.dart';
import '../models/user_model.dart';
import '../widgets/drive_image.dart';
import 'member_detail_screen.dart';


class MembersScreen extends StatefulWidget {
  const MembersScreen({super.key});
  @override
  State<MembersScreen> createState() => _MembersScreenState();
}

class _MembersScreenState extends State<MembersScreen> {
  List<UserModel> _members = [];
  List<UserModel> _filtered = [];
  bool _loading = true;
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final rows = await SheetsService.getMembers();
    final list = rows.map((r) => UserModel.fromMap(r)).toList();
    setState(() {
      _members = list;
      _filtered = list;
      _loading = false;
    });
  }

  void _search(String q) {
    setState(() {
      _filtered = _members
          .where((m) =>
      m.name.contains(q) ||
          m.phone.contains(q) ||
          m.memberId.contains(q))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('সদস্য তালিকা'),
        backgroundColor: const Color(0xFF3F51B5),
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _load),
        ],
      ),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: TextField(
            controller: _searchCtrl,
            onChanged: _search,
            decoration: InputDecoration(
              hintText: 'নাম, ফোন বা আইডি দিয়ে খুঁজুন',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
        ),
        Expanded(
          child: _loading
              ? _shimmerList()
              : RefreshIndicator(
            onRefresh: _load,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: _filtered.length,
              itemBuilder: (_, i) => _MemberTile(
                  member: _filtered[i],
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => MemberDetailScreen(
                              member: _filtered[i])))),
            ),
          ),
        ),
      ]),
    );
  }

  Widget _shimmerList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      itemCount: 6,
      itemBuilder: (_, __) => Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Card(
          margin: const EdgeInsets.only(bottom: 10),
          child: const ListTile(
            leading: CircleAvatar(radius: 26, backgroundColor: Colors.white),
            title: SizedBox(height: 14, width: 100),
            subtitle: SizedBox(height: 12),
          ),
        ),
      ),
    );
  }
}

class _MemberTile extends StatelessWidget {
  final UserModel member;
  final VoidCallback onTap;
  const _MemberTile({required this.member, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        leading: CircleAvatar(
          radius: 26,
          backgroundColor: const Color(0xFF3F51B5),
          child: DriveImage(
            fileId: member.fileId,
            size: 52,
            fallbackText: member.name,
          ),
        ),
        title: Text(member.name,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('${member.phone}  •  ${member.role}'),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}