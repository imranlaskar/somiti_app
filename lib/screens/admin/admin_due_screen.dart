import 'package:flutter/material.dart';
import '../../services/sheets_service.dart';

class AdminDueScreen extends StatefulWidget {
  const AdminDueScreen({super.key});
  @override
  State<AdminDueScreen> createState() => _AdminDueScreenState();
}

class _AdminDueScreenState extends State<AdminDueScreen> {
  List<Map<String, dynamic>> _members = [];
  List<Map<String, dynamic>> _allChanda = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final results = await Future.wait([
      SheetsService.getMembers(),
      SheetsService.getAllChanda(),
    ]);
    setState(() {
      _members = results[0];
      _allChanda = results[1];
      _loading = false;
    });
  }

  double _getMemberDue(String memberId) {
    return _allChanda
        .where((r) =>
    r['member_id'].toString() == memberId &&
        r['status'].toString().toLowerCase() == 'due')
        .fold(0, (s, r) => s + (double.tryParse(r['amount'].toString()) ?? 0));
  }

  List<Map<String, dynamic>> _getDueList(String memberId) {
    return _allChanda
        .where((r) =>
    r['member_id'].toString() == memberId &&
        r['status'].toString().toLowerCase() == 'due')
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final dueMembers = _members
        .where((m) => _getMemberDue(m['member_id']?.toString() ?? '') > 0)
        .toList();

    double totalDue = dueMembers.fold(
        0,
            (s, m) =>
        s + _getMemberDue(m['member_id']?.toString() ?? ''));

    return Scaffold(
      appBar: AppBar(
        title: const Text('বকেয়া তালিকা'),
        backgroundColor: const Color(0xFFE53935),
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _load)
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(children: [
        // মোট বকেয়া
        Container(
          margin: const EdgeInsets.all(14),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFE53935),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('মোট বকেয়া',
                      style: TextStyle(
                          color: Colors.white70, fontSize: 13)),
                  Text('${dueMembers.length} জন সদস্যের',
                      style: const TextStyle(
                          color: Colors.white54, fontSize: 11)),
                ],
              ),
              Text('৳${totalDue.toStringAsFixed(0)}',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold)),
            ],
          ),
        ),

        dueMembers.isEmpty
            ? const Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle_outline,
                    size: 64, color: Colors.green),
                SizedBox(height: 12),
                Text('কোনো বকেয়া নেই!',
                    style: TextStyle(
                        color: Colors.green,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        )
            : Expanded(
          child: RefreshIndicator(
            onRefresh: _load,
            child: ListView.builder(
              padding:
              const EdgeInsets.symmetric(horizontal: 14),
              itemCount: dueMembers.length,
              itemBuilder: (_, i) {
                final m = dueMembers[i];
                final id = m['member_id']?.toString() ?? '';
                final name = m['name']?.toString() ?? '';
                final due = _getMemberDue(id);
                final dueList = _getDueList(id);

                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: ExpansionTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.red[100],
                      child: Text(
                        name.isNotEmpty ? name[0] : '?',
                        style: const TextStyle(
                            color: Color(0xFFE53935),
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    title: Text(name,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold)),
                    subtitle: Text(
                        '${dueList.length}টি বকেয়া'),
                    trailing: Text(
                      '৳${due.toStringAsFixed(0)}',
                      style: const TextStyle(
                          color: Color(0xFFE53935),
                          fontWeight: FontWeight.bold,
                          fontSize: 16),
                    ),
                    children: dueList
                        .map((r) => ListTile(
                      dense: true,
                      leading: const Icon(
                          Icons.arrow_right,
                          color: Colors.red),
                      title: Text(
                          '${r['month']} ${r['year']}'),
                      trailing: Text(
                          '৳${r['amount']}',
                          style: const TextStyle(
                              color: Colors.red,
                              fontWeight:
                              FontWeight.bold)),
                    ))
                        .toList(),
                  ),
                );
              },
            ),
          ),
        ),
      ]),
    );
  }
}