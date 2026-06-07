import 'package:flutter/material.dart';
import '../../services/sheets_service.dart';

class AdminMeetingUpdateScreen extends StatefulWidget {
  const AdminMeetingUpdateScreen({super.key});
  @override
  State<AdminMeetingUpdateScreen> createState() =>
      _AdminMeetingUpdateScreenState();
}

class _AdminMeetingUpdateScreenState
    extends State<AdminMeetingUpdateScreen> {
  final _titleCtrl = TextEditingController();
  final _dateCtrl = TextEditingController();
  final _noticeCtrl = TextEditingController();
  final _reportCtrl = TextEditingController();
  bool _saving = false;
  List<Map<String, dynamic>> _meetings = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadMeetings();
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _dateCtrl.dispose();
    _noticeCtrl.dispose();
    _reportCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadMeetings() async {
    setState(() => _loading = true);
    final data = await SheetsService.getMeetings();
    setState(() {
      _meetings = data;
      _loading = false;
    });
  }

  Future<void> _save() async {
    if (_titleCtrl.text.isEmpty || _dateCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('শিরোনাম ও তারিখ অবশ্যই দিন'),
            backgroundColor: Colors.orange),
      );
      return;
    }
    setState(() => _saving = true);
    final success = await SheetsService.addMeeting({
      'title': _titleCtrl.text,
      'date': _dateCtrl.text,
      'notice': _noticeCtrl.text,
      'report': _reportCtrl.text,
      'attachment_url': '',
    });
    setState(() => _saving = false);

    if (success) {
      _titleCtrl.clear();
      _dateCtrl.clear();
      _noticeCtrl.clear();
      _reportCtrl.clear();
      await _loadMeetings();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('মিটিং নোটিশ যোগ হয়েছে'),
              backgroundColor: Colors.green),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('সমস্যা হয়েছে, আবার চেষ্টা করুন'),
              backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('মিটিং নোটিশ আপডেট'),
        backgroundColor: const Color(0xFF8E24AA),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          // নতুন মিটিং যোগ করার ফর্ম
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
                        color: Color(0xFF8E24AA)),
                    SizedBox(width: 8),
                    Text('নতুন মিটিং নোটিশ',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold)),
                  ]),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _titleCtrl,
                    decoration: InputDecoration(
                      labelText: 'শিরোনাম *',
                      prefixIcon: const Icon(Icons.title),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _dateCtrl,
                    decoration: InputDecoration(
                      labelText: 'তারিখ * (যেমন: ০১/০৭/২০২৬)',
                      prefixIcon: const Icon(Icons.calendar_today),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _noticeCtrl,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: 'নোটিশ',
                      prefixIcon: const Icon(Icons.info_outline),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _reportCtrl,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: 'রিপোর্ট',
                      prefixIcon:
                      const Icon(Icons.description_outlined),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(height: 16),
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
                          _saving ? 'সংরক্ষণ হচ্ছে...' : 'সংরক্ষণ করুন',
                          style: const TextStyle(
                              color: Colors.white, fontSize: 16)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8E24AA),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // আগের মিটিং লিস্ট
          Row(children: [
            const Icon(Icons.history, color: Colors.grey),
            const SizedBox(width: 8),
            const Text('আগের মিটিং',
                style: TextStyle(
                    fontSize: 15, fontWeight: FontWeight.bold)),
            const Spacer(),
            IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _loadMeetings),
          ]),

          _loading
              ? const CircularProgressIndicator()
              : _meetings.isEmpty
              ? const Text('কোনো মিটিং নেই',
              style: TextStyle(color: Colors.grey))
              : ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _meetings.length,
            itemBuilder: (_, i) {
              final m = _meetings[i];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                shape: RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.circular(10)),
                child: ListTile(
                  leading: const Icon(Icons.event_note,
                      color: Color(0xFF8E24AA)),
                  title: Text(
                      m['title']?.toString() ?? '',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold)),
                  subtitle: Text(
                      'তারিখ: ${m['date']?.toString() ?? ''}'),
                ),
              );
            },
          ),
        ]),
      ),
    );
  }
}