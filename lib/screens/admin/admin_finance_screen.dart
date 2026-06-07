import 'package:flutter/material.dart';
import '../../services/sheets_service.dart';

class AdminFinanceScreen extends StatefulWidget {
  const AdminFinanceScreen({super.key});
  @override
  State<AdminFinanceScreen> createState() => _AdminFinanceScreenState();
}

class _AdminFinanceScreenState extends State<AdminFinanceScreen> {
  List<Map<String, dynamic>> _rows = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final data = await SheetsService.getFinanceReport();
    setState(() {
      _rows = data;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    double totalIncome = _rows.fold(
        0,
            (s, r) => r['type'].toString() == 'income'
            ? s + (double.tryParse(r['amount'].toString()) ?? 0)
            : s);
    double totalExpense = _rows.fold(
        0,
            (s, r) => r['type'].toString() == 'expense'
            ? s + (double.tryParse(r['amount'].toString()) ?? 0)
            : s);
    double balance = totalIncome - totalExpense;

    return Scaffold(
      appBar: AppBar(
        title: const Text('মাসিক আয়-ব্যয় রিপোর্ট'),
        backgroundColor: const Color(0xFF1E88E5),
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _load)
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(children: [
        // Summary
        Padding(
          padding: const EdgeInsets.all(14),
          child: Row(children: [
            Expanded(
              child: _FinanceSummaryCard(
                label: 'মোট আয়',
                amount: totalIncome,
                color: Colors.green,
                icon: Icons.arrow_upward,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _FinanceSummaryCard(
                label: 'মোট ব্যয়',
                amount: totalExpense,
                color: Colors.red,
                icon: Icons.arrow_downward,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _FinanceSummaryCard(
                label: 'ব্যালেন্স',
                amount: balance,
                color: balance >= 0 ? Colors.blue : Colors.orange,
                icon: Icons.account_balance,
              ),
            ),
          ]),
        ),

        Expanded(
          child: RefreshIndicator(
            onRefresh: _load,
            child: _rows.isEmpty
                ? const Center(
                child: Text('কোনো তথ্য নেই',
                    style: TextStyle(color: Colors.grey)))
                : ListView.builder(
              padding: const EdgeInsets.symmetric(
                  horizontal: 14),
              itemCount: _rows.length,
              itemBuilder: (_, i) {
                final r = _rows[i];
                final isIncome =
                    r['type'].toString() == 'income';
                return Card(
                  margin:
                  const EdgeInsets.only(bottom: 10),
                  shape: RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(12)),
                  child: ListTile(
                    leading: Icon(
                      isIncome
                          ? Icons.arrow_upward
                          : Icons.arrow_downward,
                      color: isIncome
                          ? Colors.green
                          : Colors.red,
                      size: 28,
                    ),
                    title: Text(
                        r['description']?.toString() ?? '',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold)),
                    subtitle: Text(
                        '${r['month']} ${r['year']}  •  ${r['category'] ?? ''}'),
                    trailing: Text(
                      '৳${r['amount']}',
                      style: TextStyle(
                          color: isIncome
                              ? Colors.green
                              : Colors.red,
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

class _FinanceSummaryCard extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;
  final IconData icon;
  const _FinanceSummaryCard({
    required this.label,
    required this.amount,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 6),
          Text('৳${amount.toStringAsFixed(0)}',
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: color)),
          Text(label,
              style: TextStyle(
                  fontSize: 11, color: Colors.grey[600])),
        ]),
      ),
    );
  }
}