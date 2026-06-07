class MeetingModel {
  final String title;
  final String date;
  final String notice;
  final String report;
  final String attachmentUrl;

  MeetingModel({
    required this.title,
    required this.date,
    required this.notice,
    required this.report,
    required this.attachmentUrl,
  });

  factory MeetingModel.fromMap(Map<String, dynamic> map) {
    return MeetingModel(
      title: map['title']?.toString() ?? '',
      date: map['date']?.toString() ?? '',
      notice: map['notice']?.toString() ?? '',
      report: map['report']?.toString() ?? '',
      attachmentUrl: map['attachment_url']?.toString() ?? '',
    );
  }
}