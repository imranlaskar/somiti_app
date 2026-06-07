import 'package:flutter/material.dart';
import '../services/sheets_service.dart';

class RulesScreen extends StatefulWidget {
  const RulesScreen({super.key});
  @override
  State<RulesScreen> createState() => _RulesScreenState();
}

class _RulesScreenState extends State<RulesScreen> {
  List<Map<String, dynamic>> _rows = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final data = await SheetsService.getRules();
    setState(() {
      _rows = data;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('নিয়মকানুন'),
        backgroundColor: const Color(0xFF5C6BC0),
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
              Icon(Icons.rule_folder_outlined,
                  size: 64, color: Colors.grey),
              SizedBox(height: 12),
              Text('কোনো নিয়ম যোগ করা হয়নি',
                  style: TextStyle(color: Colors.grey)),
            ],
          ),
        )
            : ListView.builder(
          padding: const EdgeInsets.all(14),
          itemCount: _rows.length,
          itemBuilder: (_, i) => _RulesCard(
              data: _rows[i], index: i + 1),
        ),
      ),
    );
  }
}

class _RulesCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final int index;
  const _RulesCard({required this.data, required this.index});

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
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFF5C6BC0).withOpacity(0.12),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '$index',
              style: const TextStyle(
                color: Color(0xFF5C6BC0),
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
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
                // নোটিশ
                if (notice.isNotEmpty) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF5C6BC0).withOpacity(0.07),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: const Color(0xFF5C6BC0).withOpacity(0.2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(children: [
                          Icon(Icons.info_outline,
                              size: 16, color: Color(0xFF5C6BC0)),
                          SizedBox(width: 6),
                          Text('বিবরণ',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF5C6BC0),
                                  fontSize: 13)),
                        ]),
                        const SizedBox(height: 8),
                        Text(notice,
                            style: const TextStyle(fontSize: 14,
                                height: 1.6)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                ],

                // রিপোর্ট / বিস্তারিত
                if (report.isNotEmpty) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.teal.withOpacity(0.07),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: Colors.teal.withOpacity(0.2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(children: [
                          Icon(Icons.description_outlined,
                              size: 16, color: Colors.teal),
                          SizedBox(width: 6),
                          Text('বিস্তারিত',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.teal,
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

                // Attachment লিংক
                if (attachmentUrl.isNotEmpty)
                  InkWell(
                    onTap: () {
                      // URL খোলার জন্য url_launcher প্যাকেজ লাগবে
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