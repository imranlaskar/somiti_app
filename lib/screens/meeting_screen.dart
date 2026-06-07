import 'package:flutter/material.dart';
import '../services/sheets_service.dart';
import '../models/meeting_model.dart';

class MeetingScreen extends StatefulWidget {
  const MeetingScreen({super.key});
  @override
  State<MeetingScreen> createState() => _MeetingScreenState();
}

class _MeetingScreenState extends State<MeetingScreen> {
  List<MeetingModel> _meetings = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final data = await SheetsService.getMeetings();
    setState(() {
      _meetings = data.map((r) => MeetingModel.fromMap(r)).toList();
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('নোটিশ'),
        backgroundColor: const Color(0xFFE91E63),
        foregroundColor: Colors.white,
        actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: _load)],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: _load,
        child: _meetings.isEmpty
            ? const Center(child: Text('কোনো মিটিং নেই'))
            : ListView.builder(
          padding: const EdgeInsets.all(14),
          itemCount: _meetings.length,
          itemBuilder: (_, i) =>
              _MeetingCard(meeting: _meetings[i]),
        ),
      ),
    );
  }
}

class _MeetingCard extends StatelessWidget {
  final MeetingModel meeting;
  const _MeetingCard({required this.meeting});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ExpansionTile(
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFFE91E63).withOpacity(0.12),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.event_note, color: Color(0xFFE91E63)),
        ),
        title: Text(meeting.title,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('তারিখ: ${meeting.date}'),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (meeting.notice.isNotEmpty) ...[
                  const Text('নোটিশ:',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFE91E63))),
                  const SizedBox(height: 4),
                  Text(meeting.notice),
                  const SizedBox(height: 10),
                ],
                if (meeting.report.isNotEmpty) ...[
                  const Text('রিপোর্ট:',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.teal)),
                  const SizedBox(height: 4),
                  Text(meeting.report),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}