import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/sheets_service.dart';

class AccountsScreen extends StatefulWidget {
  const AccountsScreen({super.key});
  @override
  State<AccountsScreen> createState() => _AccountsScreenState();
}

class _AccountsScreenState extends State<AccountsScreen> {
  List<Map<String, dynamic>> _all = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final data = await SheetsService.getAccounts();
    setState(() {
      _all = data;
      _loading = false;
    });
  }

  void _copyToClipboard(String number, String name) {
    Clipboard.setData(ClipboardData(text: number));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(children: [
          const Icon(Icons.check_circle, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Text('$name এর নম্বর কপি হয়েছে'),
        ]),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // bank আগে, mobile পরে — সিরিয়াল ঠিক রাখো
    final banks = _all
        .where((r) => r['type'].toString().toLowerCase() == 'bank')
        .toList();
    final mobiles = _all
        .where((r) => r['type'].toString().toLowerCase() == 'mobile')
        .toList();
    final sorted = [...banks, ...mobiles];

    return Scaffold(
      appBar: AppBar(
        title: const Text('ব্যাংক ও মোবাইল ব্যাংকিং'),
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _load)
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : sorted.isEmpty
          ? const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.account_balance_outlined,
                size: 64, color: Colors.grey),
            SizedBox(height: 12),
            Text('কোনো তথ্য যোগ করা হয়নি',
                style: TextStyle(color: Colors.grey)),
          ],
        ),
      )
          : RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.all(14),
          children: [
            // মোবাইল ব্যাংকিং সেকশন
            if (mobiles.isNotEmpty) ...[
              const SizedBox(height: 6),
              _SectionHeader(
                icon: Icons.phone_android,
                label: 'মোবাইল ব্যাংকিং',
                color: const Color(0xFF00695C),
              ),
              const SizedBox(height: 10),
              ...mobiles.map((d) => _MobileCard(
                data: d,
                onCopy: _copyToClipboard,
              )),
            ],

            // ব্যাংক সেকশন
            if (banks.isNotEmpty) ...[
              _SectionHeader(
                icon: Icons.account_balance,
                label: 'ব্যাংক অ্যাকাউন্ট',
                color: const Color(0xFF1565C0),
              ),
              const SizedBox(height: 10),
              ...banks.map((d) => _BankCard(
                data: d,
                onCopy: _copyToClipboard,
              )),
            ],
          ],
        ),
      ),
    );
  }
}

// সেকশন হেডার
class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _SectionHeader({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Icon(icon, color: color, size: 20),
      const SizedBox(width: 8),
      Text(label,
          style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color)),
      const SizedBox(width: 10),
      Expanded(
          child: Divider(color: color.withOpacity(0.3), thickness: 1)),
    ]);
  }
}

// ব্যাংক কার্ড
class _BankCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final Function(String number, String name) onCopy;
  const _BankCard({required this.data, required this.onCopy});

  Color _color(String name) {
    if (name.contains('ডাচ') || name.contains('Dutch')) {
      return const Color(0xFF1B5E20);
    } else if (name.contains('অগ্রণী') || name.contains('Agrani')) {
      return const Color(0xFF0D47A1);
    } else if (name.contains('জনতা') || name.contains('Janata')) {
      return const Color(0xFF880E4F);
    }
    return const Color(0xFF1565C0);
  }

  @override
  Widget build(BuildContext context) {
    final bankName = data['bank_name']?.toString() ?? '';
    final accountName = data['account_name']?.toString() ?? '';
    final accountNumber = data['account_number']?.toString() ?? '';
    final routingNumber = data['routing_number']?.toString() ?? '';
    final branch = data['branch']?.toString() ?? '';
    final color = _color(bankName);

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      child: Column(children: [
        // হেডার
        Container(
          padding: const EdgeInsets.symmetric(
              horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: color,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
          ),
          child: Row(children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  bankName.isNotEmpty ? bankName[0] : 'B',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(bankName,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold)),
                  if (branch.isNotEmpty)
                    Text(branch,
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 12)),
                ],
              ),
            ),
            const Icon(Icons.account_balance,
                color: Colors.white54, size: 28),
          ]),
        ),

        // বডি
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(children: [
            if (accountName.isNotEmpty) ...[
              _InfoRow(
                  icon: Icons.person_outline,
                  label: 'অ্যাকাউন্টের নাম',
                  value: accountName,
                  color: color),
              const SizedBox(height: 12),
            ],
            _NumberRow(
              icon: Icons.credit_card,
              label: 'অ্যাকাউন্ট নম্বর',
              number: accountNumber,
              color: color,
              onCopy: () => onCopy(accountNumber, bankName),
            ),
            if (routingNumber.isNotEmpty) ...[
              const SizedBox(height: 10),
              _NumberRow(
                icon: Icons.route_outlined,
                label: 'রাউটিং নম্বর',
                number: routingNumber,
                color: color,
                onCopy: () =>
                    onCopy(routingNumber, '$bankName রাউটিং'),
              ),
            ],
          ]),
        ),
      ]),
    );
  }
}

// মোবাইল ব্যাংকিং কার্ড
class _MobileCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final Function(String number, String name) onCopy;
  const _MobileCard({required this.data, required this.onCopy});

  Color _color(String name) {
    if (name.contains('বিকাশ') || name.contains('bKash')) {
      return const Color(0xFFD81B60);
    } else if (name.contains('নগদ') || name.contains('Nagad')) {
      return const Color(0xFFE65100);
    } else if (name.contains('রকেট') || name.contains('Rocket')) {
      return const Color(0xFFE02BC2);
    } else if (name.contains('শিওর') || name.contains('SureCash')) {
      return const Color(0xFF1565C0);
    } else if (name.contains('উপায়') || name.contains('Upay')) {
      return const Color(0xFF2E7D32);
    }
    return const Color(0xFF00695C);
  }

  IconData _icon(String name) {
    if (name.contains('বিকাশ')) return Icons.payments;
    if (name.contains('নগদ')) return Icons.account_balance_wallet;
    if (name.contains('রকেট')) return Icons.rocket_launch;
    return Icons.phone_android;
  }

  @override
  Widget build(BuildContext context) {
    final mobileName = data['bank_name']?.toString() ?? '';
    final accountName = data['account_name']?.toString() ?? '';
    final number = data['account_number']?.toString() ?? '';
    final branch = data['branch']?.toString() ?? '';
    final color = _color(mobileName);

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(children: [
            // হেডার
            Row(children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child:
                Icon(_icon(mobileName), color: color, size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(mobileName,
                        style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: color)),
                    if (accountName.isNotEmpty)
                      Text(accountName,
                          style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 13)),
                    if (branch.isNotEmpty)
                      Text(branch,
                          style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 12)),
                  ],
                ),
              ),
            ]),
            const SizedBox(height: 14),
            const Divider(height: 1),
            const SizedBox(height: 14),
            _NumberRow(
              icon: Icons.phone_android,
              label: 'মোবাইল নম্বর',
              number: number,
              color: color,
              onCopy: () => onCopy(number, mobileName),
            ),
          ]),
        ),
      ),
    );
  }
}

// তথ্য row
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Icon(icon, color: color, size: 18),
      const SizedBox(width: 10),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: TextStyle(
                    fontSize: 11, color: Colors.grey[600])),
            Text(value,
                style: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    ]);
  }
}

// নম্বর + কপি বাটন
class _NumberRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String number;
  final Color color;
  final VoidCallback onCopy;
  const _NumberRow({
    required this.icon,
    required this.label,
    required this.number,
    required this.color,
    required this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: TextStyle(
                      fontSize: 11, color: Colors.grey[600])),
              Text(
                number.isNotEmpty ? number : '—',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                    letterSpacing: 0.8),
              ),
            ],
          ),
        ),
        if (number.isNotEmpty)
          InkWell(
            onTap: onCopy,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.copy, color: Colors.white, size: 14),
                  SizedBox(width: 4),
                  Text('কপি',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
      ]),
    );
  }
}