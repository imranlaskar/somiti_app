import 'package:flutter/material.dart';
import '../services/sheets_service.dart';

class LoanSavingsScreen extends StatefulWidget {
  final String memberId;
  final double totalChandaPaid; // ✅ চাঁদার টাকা

  const LoanSavingsScreen({
    super.key,
    required this.memberId,
    this.totalChandaPaid = 0, // default 0
  });

  @override
  State<LoanSavingsScreen> createState() => _LoanSavingsScreenState();
}

class _LoanSavingsScreenState extends State<LoanSavingsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  List<Map<String, dynamic>> _loans = [];
  List<Map<String, dynamic>> _savings = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
    _load();
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final data = await SheetsService.getLoanSavings(widget.memberId);
    setState(() {
      _loans =
          data.where((r) => r['type'].toString() == 'loan').toList();
      _savings = data
          .where((r) => r['type'].toString() == 'savings')
          .toList();
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('লোন / সঞ্চয়'),
        backgroundColor: const Color(0xFFFF9800),
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _load)
        ],
        bottom: TabBar(
          controller: _tabCtrl,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.money_off), text: 'লোন'),
            Tab(icon: Icon(Icons.savings), text: 'সঞ্চয়'),
          ],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
        controller: _tabCtrl,
        children: [
          _buildLoanList(),
          _buildSavingsList(),
        ],
      ),
    );
  }

  // লোন লিস্ট
  Widget _buildLoanList() {
    if (_loans.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.money_off_outlined,
                size: 64, color: Colors.grey),
            SizedBox(height: 12),
            Text('কোনো লোন নেই',
                style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    double totalLoan = _loans.fold(
        0, (s, r) => s + (double.tryParse(r['amount'].toString()) ?? 0));

    return Column(children: [
      // মোট লোন
      Container(
        margin: const EdgeInsets.all(14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.orange.withOpacity(0.12),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: Colors.orange.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Row(children: [
              Icon(Icons.money_off, color: Colors.orange),
              SizedBox(width: 8),
              Text('মোট লোন',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ]),
            Text('৳${totalLoan.toStringAsFixed(0)}',
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange)),
          ],
        ),
      ),
      Expanded(
        child: RefreshIndicator(
          onRefresh: _load,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            itemCount: _loans.length,
            itemBuilder: (_, i) => _ItemCard(
                data: _loans[i], isLoan: true),
          ),
        ),
      ),
    ]);
  }

  // সঞ্চয় লিস্ট
  Widget _buildSavingsList() {
    double sheetSavings = _savings.fold(
        0, (s, r) => s + (double.tryParse(r['amount'].toString()) ?? 0));

    double grandTotal = sheetSavings + widget.totalChandaPaid;

    return Column(children: [
      Padding(
        padding: const EdgeInsets.all(14),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.teal.withOpacity(0.12),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.teal.withOpacity(0.3)),
          ),
          child: Column(children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.account_balance_wallet,
                    color: Colors.teal, size: 20),
                SizedBox(width: 8),
                Text('মোট সঞ্চয়',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 15)),
              ],
            ),
            const SizedBox(height: 8),
            Text('৳${grandTotal.toStringAsFixed(0)}',
                style: const TextStyle(
                    fontSize: 38,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal)),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _MiniStat(
                  label: 'গত বছর পর্যন্ত সঞ্চয়',
                  amount: sheetSavings,
                  color: Colors.teal,
                  icon: Icons.savings,
                ),
                Container(
                    width: 1, height: 40, color: Colors.grey[300]),
                _MiniStat(
                  label: 'চলতি বছরের চাঁদা',
                  amount: widget.totalChandaPaid,
                  color: const Color(0xFF4CAF50),
                  icon: Icons.payments,
                ),
              ],
            ),
          ]),
        ),
      ),

      // ✅ নিচের লিস্ট সম্পূর্ণ বাদ — শুধু summary দেখাবে
    ]);
  }
}

// আইটেম কার্ড
class _ItemCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final bool isLoan;
  const _ItemCard({required this.data, required this.isLoan});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(
          isLoan ? Icons.trending_down : Icons.trending_up,
          color: isLoan ? Colors.orange : Colors.teal,
          size: 30,
        ),
        title: Text('৳${data['amount']}',
            style: const TextStyle(
                fontWeight: FontWeight.bold, fontSize: 16)),
        subtitle: Text(
            'তারিখ: ${data['date']?.toString().isNotEmpty == true ? data['date'] : '—'}'),
        trailing: data['balance']?.toString().isNotEmpty == true
            ? Text('ব্যালেন্স: ৳${data['balance']}',
            style: const TextStyle(fontSize: 12))
            : null,
      ),
    );
  }
}

// ছোট stat box
class _MiniStat extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;
  final IconData icon;
  const _MiniStat({
    required this.label,
    required this.amount,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Icon(icon, color: color, size: 18),
      const SizedBox(height: 4),
      Text('৳${amount.toStringAsFixed(0)}',
          style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: color)),
      Text(label,
          style:
          TextStyle(fontSize: 11, color: Colors.grey[600])),
    ]);
  }
}