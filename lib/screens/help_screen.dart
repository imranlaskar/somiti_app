import 'package:flutter/material.dart';
import '../services/sheets_service.dart';

class HelpScreen extends StatefulWidget {
  const HelpScreen({super.key});
  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  List<Map<String, dynamic>> _rows = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final data = await SheetsService.getHelp();
    setState(() {
      _rows = data;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('হেল্পলাইন'),
        backgroundColor: const Color(0xFF00897B),
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _load)
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: _load,
        child: _rows.isEmpty
            ? const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.headset_mic_outlined,
                  size: 64, color: Colors.grey),
              SizedBox(height: 12),
              Text('কোনো তথ্য যোগ করা হয়নি',
                  style: TextStyle(color: Colors.grey)),
            ],
          ),
        )
            : ListView.builder(
          padding: const EdgeInsets.all(14),
          itemCount: _rows.length,
          itemBuilder: (_, i) =>
              _HelpCard(data: _rows[i]),
        ),
      ),
    );
  }
}

class _HelpCard extends StatelessWidget {
  final Map<String, dynamic> data;
  const _HelpCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final title = data['title']?.toString() ?? '';
    final notice = data['notice']?.toString() ?? '';
    final report = data['report']?.toString() ?? '';
    final attachmentUrl = data['attachment_url']?.toString() ?? '';

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14)),
      elevation: 2,
      child: ExpansionTile(
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFF00897B).withOpacity(0.12),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.headset_mic,
              color: Color(0xFF00897B), size: 22),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // যোগাযোগ / নোটিশ
                if (notice.isNotEmpty) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00897B).withOpacity(0.07),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: const Color(0xFF00897B).withOpacity(0.2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 2),
                        Text(notice,
                            style: const TextStyle(
                                fontSize: 14, height: 1.6)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                ],

                // বিস্তারিত
                if (report.isNotEmpty) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.07),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: Colors.blue.withOpacity(0.2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(children: [
                          Icon(Icons.info_outline,
                              size: 16, color: Colors.blue),
                          SizedBox(width: 6),
                          Text('বিস্তারিত',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                  fontSize: 13)),
                        ]),
                        const SizedBox(height: 8),
                        Text(report,
                            style: const TextStyle(
                                fontSize: 14, height: 1.6)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                ],

                // Attachment
                if (attachmentUrl.isNotEmpty)
                  InkWell(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('লিংক: $attachmentUrl'),
                          action: SnackBarAction(
                              label: 'কপি', onPressed: () {}),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: Colors.orange.withOpacity(0.3)),
                      ),
                      child: const Row(children: [
                        Icon(Icons.attach_file,
                            color: Colors.orange, size: 18),
                        SizedBox(width: 8),
                        Text('সংযুক্তি দেখুন',
                            style: TextStyle(
                                color: Colors.orange,
                                fontWeight: FontWeight.w600)),
                      ]),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}