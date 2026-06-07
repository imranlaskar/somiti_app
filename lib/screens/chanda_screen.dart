import 'package:flutter/material.dart';
import '../services/sheets_service.dart';

class ChandaScreen extends StatefulWidget {
  final String memberId;
  const ChandaScreen({super.key, required this.memberId});
  @override
  State<ChandaScreen> createState() => _ChandaScreenState();
}

class _ChandaScreenState extends State<ChandaScreen> {
  List<Map<String, dynamic>> _rows = [];
  bool _loading = true;
  double _total = 0;
  double _due = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final data = await SheetsService.getMemberChanda(widget.memberId);
    double paid = 0, due = 0;
    for (final r in data) {
      final amt = double.tryParse(r['amount'].toString()) ?? 0;
      if (r['status'].toString().toLowerCase() == 'paid') {
        paid += amt;
      } else {
        due += amt;
      }
    }
    setState(() {
      _rows = data;
      _total = paid;
      _due = due;
      _loading = false;
    });
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return Colors.green;
      case 'due':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('চাঁদা / লেনদেন'),
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
        actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: _load)],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: _load,
        child: Column(children: [
          // Summary cards
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(children: [
              Expanded(
                child: _SummaryCard(
                  label: 'মোট পরিশোধ',
                  amount: _total,
                  color: Colors.green,
                  icon: Icons.check_circle,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _SummaryCard(
                  label: 'বকেয়া',
                  amount: _due,
                  color: Colors.red,
                  icon: Icons.warning,
                ),
              ),
            ]),
          ),

          Expanded(
            child: _rows.isEmpty
                ? const Center(child: Text('কোনো তথ্য নেই'))
                : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              itemCount: _rows.length,
              itemBuilder: (_, i) {
                final r = _rows[i];
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.payments,
                          color: Color(0xFF4CAF50)),
                    ),
                    title: Text(
                        '${r['month']} ${r['year']}',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold)),
                    subtitle: Text(
                        'তারিখ: ${r['paid_date'] ?? '—'}'),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('৳${r['amount']}',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16)),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: _statusColor(
                                r['status'].toString())
                                .withOpacity(0.15),
                            borderRadius:
                            BorderRadius.circular(20),
                          ),
                          child: Text(
                            r['status'].toString(),
                            style: TextStyle(
                                color: _statusColor(
                                    r['status'].toString()),
                                fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ]),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;
  final IconData icon;
  const _SummaryCard(
      {required this.label,
        required this.amount,
        required this.color,
        required this.icon});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text('৳${amount.toStringAsFixed(0)}',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: color)),
          Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
        ]),
      ),
    );
  }
}