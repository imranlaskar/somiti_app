
class UserModel {
  final String memberId;
  final String name;
  final String phone;
  final String role;
  final String photoUrl;
  final String fileId;      //  Drive File ID আলাদা রাখবো
  final String address;
  final String joinDate;

  UserModel({
    required this.memberId,
    required this.name,
    required this.phone,
    required this.role,
    required this.photoUrl,
    required this.fileId,
    required this.address,
    required this.joinDate,
  });

  //  Drive লিংক থেকে File ID বের করা
  static String extractFileId(String url) {
    if (url.isEmpty) return '';
    final reg = RegExp(r'/file/d/([a-zA-Z0-9_-]+)');
    final match = reg.firstMatch(url);
    if (match != null) return match.group(1)!;
    // id= ফরম্যাট
    final reg2 = RegExp(r'id=([a-zA-Z0-9_-]+)');
    final match2 = reg2.firstMatch(url);
    if (match2 != null) return match2.group(1)!;
    return '';
  }

  // ✅ তারিখ ঠিক করো
  static String formatDate(String raw) {
    if (raw.isEmpty) return '—';
    try {
      // Google Sheets date format: 2026-06-27T18:00:00.000Z
      final dt = DateTime.parse(raw).toLocal();
      return '${dt.day.toString().padLeft(2, '0')}'
          '/${dt.month.toString().padLeft(2, '0')}'
          '/${dt.year}';
    } catch (_) {
      return raw; // parse না হলে যেমন আছে তেমন দেখাও
    }
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    final rawPhoto = map['photo_url']?.toString() ?? '';
    final id = extractFileId(rawPhoto);

    return UserModel(
      memberId: map['member_id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      phone: map['phone']?.toString() ?? '',
      role: map['role']?.toString() ?? 'সদস্য',
      photoUrl: rawPhoto,
      fileId: id,           // ✅ File ID আলাদা
      address: map['address']?.toString() ?? '',
      joinDate: formatDate(map['join_date']?.toString() ?? ''),
    );
  }
}