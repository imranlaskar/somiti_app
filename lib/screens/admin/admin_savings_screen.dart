import 'package:flutter/material.dart';
import '../../services/sheets_service.dart';

class AdminSavingsScreen extends StatefulWidget {
  const AdminSavingsScreen({super.key});
  @override
  State<AdminSavingsScreen> createState() => _AdminSavingsScreenState();
}

class _AdminSavingsScreenState extends State<AdminSavingsScreen> {
  List<Map<String, dynamic>> _members = [];
  List<Map<String, dynamic>> _allSavings = [];
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
      SheetsService.getAllLoanSavings(),
      SheetsService.getAllChanda(),
    ]);
    setState(() {
      _members = results[0];
      _allSavings = results[1]
          .where((r) => r['type'].toString() == 'savings')
          .toList();
      _allChanda = results[2];
      _loading = false;
    });
  }

  double _getMemberSavings(String memberId) {
    return _allSavings
        .where((r) => r['member_id'].toString() == memberId)
        .fold(0, (s, r) => s + (double.tryParse(r['amount'].toString()) ?? 0));
  }

  double _getMemberChanda(String memberId) {
    return _allChanda
        .where((r) =>
    r['member_id'].toString() == memberId &&
        r['status'].toString().toLowerCase() == 'paid')
        .fold(0, (s, r) => s + (double.tryParse(r['amount'].toString()) ?? 0));
  }

  @override
  Widget build(BuildContext context) {
    double grandTotal = 0;
    for (final m in _members) {
      final id = m['member_id']?.toString() ?? '';
      grandTotal += _getMemberSavings(id) + _getMemberChanda(id);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('সকল সদস্যের সঞ্চয়'),
        backgroundColor: const Color(0xFF00897B),
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _load)
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(children: [
        // মোট সঞ্চয় summary
        Container(
          margin: const EdgeInsets.all(14),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF00897B),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('সমিতির মোট সঞ্চয়',
                      style: TextStyle(
                          color: Colors.white70, fontSize: 13)),
                  Text('সকল সদস্য মিলিয়ে',
                      style: TextStyle(
                          color: Colors.white54, fontSize: 11)),
                ],
              ),
              Text('৳${grandTotal.toStringAsFixed(0)}',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold)),
            ],
          ),
        ),

        Expanded(
          child: RefreshIndicator(
            onRefresh: _load,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              itemCount: _members.length,
              itemBuilder: (_, i) {
                final m = _members[i];
                final id = m['member_id']?.toString() ?? '';
                final name = m['name']?.toString() ?? '';
                final savings = _getMemberSavings(id);
                final chanda = _getMemberChanda(id);
                final total = savings + chanda;

                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: const Color(0xFF00897B),
                      child: Text(
                        name.isNotEmpty ? name[0] : '?',
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    title: Text(name,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold)),
                    subtitle: Text(
                        'সঞ্চয়: ৳${savings.toStringAsFixed(0)}  •  চাঁদা: ৳${chanda.toStringAsFixed(0)}'),
                    trailing: Text(
                      '৳${total.toStringAsFixed(0)}',
                      style: const TextStyle(
                          color: Color(0xFF00897B),
                          fontWeight: FontWeight.bold,
                          fontSize: 16),
                    ),
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