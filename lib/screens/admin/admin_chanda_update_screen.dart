import 'package:flutter/material.dart';
import '../../services/sheets_service.dart';

class AdminChandaUpdateScreen extends StatefulWidget {
  const AdminChandaUpdateScreen({super.key});
  @override
  State<AdminChandaUpdateScreen> createState() =>
      _AdminChandaUpdateScreenState();
}

class _AdminChandaUpdateScreenState
    extends State<AdminChandaUpdateScreen> {
  // Form controllers
  final _amountCtrl = TextEditingController();
  final _paidDateCtrl = TextEditingController();

  // Dropdown values
  String? _selectedMemberId;
  String? _selectedMemberName;
  String _selectedMonth = 'জানুয়ারি';
  String _selectedYear = '2026';
  String _selectedStatus = 'Paid';

  List<Map<String, dynamic>> _members = [];
  List<Map<String, dynamic>> _chandaList = [];
  bool _loadingMembers = true;
  bool _loadingChanda = false;
  bool _saving = false;

  final List<String> _months = [
    'জানুয়ারি', 'ফেব্রুয়ারি', 'মার্চ', 'এপ্রিল',
    'মে', 'জুন', 'জুলাই', 'আগস্ট',
    'সেপ্টেম্বর', 'অক্টোবর', 'নভেম্বর', 'ডিসেম্বর',
  ];

  final List<String> _years = [
    '2026', '2027', '2028', '2029', '2030'
  ];

  @override
  void initState() {
    super.initState();
    _loadMembers();
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _paidDateCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadMembers() async {
    setState(() => _loadingMembers = true);
    final data = await SheetsService.getMembers();
    setState(() {
      _members = data
          .where((m) => m['role'].toString().toLowerCase() != 'admin')
          .toList();
      _loadingMembers = false;
    });
  }

  Future<void> _loadMemberChanda(String memberId) async {
    setState(() => _loadingChanda = true);
    final data = await SheetsService.getMemberChanda(memberId);
    setState(() {
      _chandaList = data;
      _loadingChanda = false;
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        _paidDateCtrl.text =
        '${picked.day.toString().padLeft(2, '0')}/'
            '${picked.month.toString().padLeft(2, '0')}/'
            '${picked.year}';
      });
    }
  }

  Future<void> _save() async {
    if (_selectedMemberId == null) {
      _snack('সদস্য সিলেক্ট করুন', Colors.orange);
      return;
    }
    if (_amountCtrl.text.isEmpty) {
      _snack('টাকার পরিমাণ দিন', Colors.orange);
      return;
    }

    setState(() => _saving = true);
    final success = await SheetsService.addChanda({
      'member_id': _selectedMemberId!,
      'month': _selectedMonth,
      'year': _selectedYear,
      'amount': _amountCtrl.text,
      'paid_date': _paidDateCtrl.text,
      'status': _selectedStatus,
    });
    setState(() => _saving = false);

    if (success) {
      _amountCtrl.clear();
      _paidDateCtrl.clear();
      // চাঁদা লিস্ট রিফ্রেশ করো
      await _loadMemberChanda(_selectedMemberId!);
      _snack('চাঁদা যোগ হয়েছে ✅', Colors.green);
    } else {
      _snack('সমস্যা হয়েছে, আবার চেষ্টা করুন', Colors.red);
    }
  }

  void _snack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('চাঁদা আপডেট'),
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
      ),
      body: _loadingMembers
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(children: [

          // ফর্ম কার্ড
          Card(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(children: [
                    Icon(Icons.add_circle,
                        color: Color(0xFF4CAF50)),
                    SizedBox(width: 8),
                    Text('নতুন চাঁদা যোগ করুন',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold)),
                  ]),
                  const SizedBox(height: 16),

                  // সদস্য সিলেক্ট
                  DropdownButtonFormField<String>(
                    value: _selectedMemberId,
                    decoration: InputDecoration(
                      labelText: 'সদস্য সিলেক্ট করুন *',
                      prefixIcon: const Icon(Icons.person),
                      border: OutlineInputBorder(
                          borderRadius:
                          BorderRadius.circular(10)),
                    ),
                    items: _members.map((m) {
                      return DropdownMenuItem<String>(
                        value: m['member_id'].toString(),
                        child: Text(
                            '${m['name']} (${m['member_id']})'),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() {
                        _selectedMemberId = val;
                        _selectedMemberName = _members
                            .firstWhere((m) =>
                        m['member_id'].toString() ==
                            val)['name']
                            .toString();
                      });
                      if (val != null) _loadMemberChanda(val);
                    },
                  ),
                  const SizedBox(height: 12),

                  // মাস ও বছর — পাশাপাশি
                  Row(children: [
                    Expanded(
                      flex: 3,
                      child: DropdownButtonFormField<String>(
                        value: _selectedMonth,
                        decoration: InputDecoration(
                          labelText: 'মাস',
                          border: OutlineInputBorder(
                              borderRadius:
                              BorderRadius.circular(10)),
                        ),
                        items: _months
                            .map((m) => DropdownMenuItem(
                            value: m, child: Text(m)))
                            .toList(),
                        onChanged: (val) => setState(
                                () => _selectedMonth = val!),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 2,
                      child: DropdownButtonFormField<String>(
                        value: _selectedYear,
                        decoration: InputDecoration(
                          labelText: 'বছর',
                          border: OutlineInputBorder(
                              borderRadius:
                              BorderRadius.circular(10)),
                        ),
                        items: _years
                            .map((y) => DropdownMenuItem(
                            value: y, child: Text(y)))
                            .toList(),
                        onChanged: (val) => setState(
                                () => _selectedYear = val!),
                      ),
                    ),
                  ]),
                  const SizedBox(height: 12),

                  // টাকার পরিমাণ
                  TextField(
                    controller: _amountCtrl,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'টাকার পরিমাণ *',
                      prefixIcon:
                      const Icon(Icons.currency_exchange),
                      prefixText: '৳ ',
                      border: OutlineInputBorder(
                          borderRadius:
                          BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // পরিশোধের তারিখ
                  TextField(
                    controller: _paidDateCtrl,
                    readOnly: true,
                    onTap: _pickDate,
                    decoration: InputDecoration(
                      labelText: 'পরিশোধের তারিখ',
                      prefixIcon:
                      const Icon(Icons.calendar_today),
                      hintText: 'তারিখ বাছাই করুন',
                      border: OutlineInputBorder(
                          borderRadius:
                          BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // স্ট্যাটাস
                  Row(children: [
                    const Text('স্ট্যাটাস: ',
                        style: TextStyle(
                            fontWeight: FontWeight.w500)),
                    const SizedBox(width: 12),
                    _StatusChip(
                      label: 'পরিশোধ',
                      value: 'paid',
                      selected: _selectedStatus == 'paid',
                      color: Colors.green,
                      onTap: () => setState(
                              () => _selectedStatus = 'paid'),
                    ),
                    const SizedBox(width: 8),
                    _StatusChip(
                      label: 'বকেয়া',
                      value: 'due',
                      selected: _selectedStatus == 'due',
                      color: Colors.red,
                      onTap: () => setState(
                              () => _selectedStatus = 'due'),
                    ),
                  ]),
                  const SizedBox(height: 16),

                  // সংরক্ষণ বাটন
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: _saving ? null : _save,
                      icon: _saving
                          ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2))
                          : const Icon(Icons.save,
                          color: Colors.white),
                      label: Text(
                          _saving
                              ? 'সংরক্ষণ হচ্ছে...'
                              : 'সংরক্ষণ করুন',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                        const Color(0xFF4CAF50),
                        shape: RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // নির্বাচিত সদস্যের চাঁদার ইতিহাস
          if (_selectedMemberId != null) ...[
            Row(children: [
              const Icon(Icons.history, color: Colors.grey),
              const SizedBox(width: 8),
              Text(
                '${_selectedMemberName ?? ''} এর চাঁদার ইতিহাস',
                style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold),
              ),
            ]),
            const SizedBox(height: 10),
            _loadingChanda
                ? const Center(
                child: CircularProgressIndicator())
                : _chandaList.isEmpty
                ? const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Center(
                    child: Text(
                        'কোনো চাঁদার তথ্য নেই',
                        style: TextStyle(
                            color: Colors.grey))),
              ),
            )
                : ListView.builder(
              shrinkWrap: true,
              physics:
              const NeverScrollableScrollPhysics(),
              itemCount: _chandaList.length,
              itemBuilder: (_, i) {
                final r = _chandaList[i];
                final isPaid = r['status']
                    .toString()
                    .toLowerCase() ==
                    'paid';
                return Card(
                  margin: const EdgeInsets.only(
                      bottom: 8),
                  shape: RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(
                          10)),
                  child: ListTile(
                    leading: Icon(
                      isPaid
                          ? Icons.check_circle
                          : Icons.warning,
                      color: isPaid
                          ? Colors.green
                          : Colors.red,
                    ),
                    title: Text(
                        '${r['month']} ${r['year']}',
                        style: const TextStyle(
                            fontWeight:
                            FontWeight.bold)),
                    subtitle: Text(
                        'তারিখ: ${r['paid_date']?.toString().isNotEmpty == true ? r['paid_date'] : '—'}'),
                    trailing: Column(
                      mainAxisAlignment:
                      MainAxisAlignment.center,
                      crossAxisAlignment:
                      CrossAxisAlignment.end,
                      children: [
                        Text('৳${r['amount']}',
                            style: const TextStyle(
                                fontWeight:
                                FontWeight.bold,
                                fontSize: 15)),
                        Container(
                          padding: const EdgeInsets
                              .symmetric(
                              horizontal: 8,
                              vertical: 2),
                          decoration: BoxDecoration(
                            color: (isPaid
                                ? Colors.green
                                : Colors.red)
                                .withOpacity(0.12),
                            borderRadius:
                            BorderRadius.circular(
                                20),
                          ),
                          child: Text(
                            isPaid
                                ? 'paid'
                                : 'due',
                            style: TextStyle(
                                color: isPaid
                                    ? Colors.green
                                    : Colors.red,
                                fontSize: 11),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ]),
      ),
    );
  }
}

// স্ট্যাটাস chip widget
class _StatusChip extends StatelessWidget {
  final String label;
  final String value;
  final bool selected;
  final Color color;
  final VoidCallback onTap;
  const _StatusChip({
    required this.label,
    required this.value,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? color : color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}