import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/constants.dart';

class SheetsService {

  // ✅ Drive File ID দিয়ে base64 image আনো
  static Future<String?> getDriveImageBase64(String fileId) async {
    if (fileId.isEmpty) return null;
    try {
      final url = Uri.parse(
          '${AppConstants.scriptUrl}?action=image&fileId=$fileId');
      final res = await http.get(url).timeout(const Duration(seconds: 20));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data['success'] == true) {
          return 'data:${data['mimeType']};base64,${data['base64']}';
        }
      }
    } catch (e) {
      print('Image fetch error: $e');
    }
    return null;
  }

  static Future<List<Map<String, dynamic>>> _fetchSheet(String sheetName) async {
    try {
      final url = Uri.parse('${AppConstants.scriptUrl}?sheet=$sheetName');
      final res = await http.get(url).timeout(const Duration(seconds: 15));
      if (res.statusCode == 200) {
        final List data = jsonDecode(res.body);
        return data.cast<Map<String, dynamic>>();
      }
    } catch (e) {
      print('SheetsService error ($sheetName): $e');
    }
    return [];
  }

  static Future<Map<String, dynamic>?> validateLogin(
      String phone, String password) async {
    final users = await _fetchSheet('users');
    try {
      return users.firstWhere(
            (u) =>
        u['phone'].toString().trim() == phone.trim() &&
            u['password'].toString().trim() == password.trim(),
      );
    } catch (_) {
      return null;
    }
  }
  // সকল সদস্যের চাঁদা
  static Future<List<Map<String, dynamic>>> getAllChanda() =>
      _fetchSheet('chanda');

// সকল সদস্যের সঞ্চয়
  static Future<List<Map<String, dynamic>>> getAllLoanSavings() =>
      _fetchSheet('loan_savings');

// মাসিক আয়-ব্যয়
  static Future<List<Map<String, dynamic>>> getFinanceReport() =>
      _fetchSheet('finance');

// মিটিং আপডেট (Apps Script এ POST support লাগবে)
  static Future<bool> addMeeting(Map<String, String> data) async {
    try {
      // ✅ POST এর বদলে GET দিয়ে পাঠাও
      final params = {
        'action': 'addMeeting',
        'title': data['title'] ?? '',
        'date': data['date'] ?? '',
        'notice': data['notice'] ?? '',
        'report': data['report'] ?? '',
        'attachment_url': data['attachment_url'] ?? '',
      };

      final uri = Uri.parse(AppConstants.scriptUrl)
          .replace(queryParameters: params);

      final res = await http.get(uri)
          .timeout(const Duration(seconds: 15));

      if (res.statusCode == 200) {
        final result = jsonDecode(res.body);
        return result['success'] == true;
      }
      return false;
    } catch (e) {
      print('addMeeting error: $e');
      return false;
    }
  }

  static Future<List<Map<String, dynamic>>> getMembers() =>
      _fetchSheet('users');

  static Future<List<Map<String, dynamic>>> getMemberChanda(
      String memberId) async {
    final all = await _fetchSheet('chanda');
    return all.where((r) => r['member_id'].toString() == memberId).toList();
  }

  static Future<List<Map<String, dynamic>>> getLoanSavings(
      String memberId) async {
    final all = await _fetchSheet('loan_savings');
    return all.where((r) => r['member_id'].toString() == memberId).toList();
  }

  static Future<List<Map<String, dynamic>>> getMeetings() =>
      _fetchSheet('meeting');

  static Future<Map<String, dynamic>?> getSettings() async {
    final rows = await _fetchSheet('settings');
    return rows.isNotEmpty ? rows.first : null;
  }
  static Future<List<Map<String, dynamic>>> getRules() =>
      _fetchSheet('rules');

  static Future<List<Map<String, dynamic>>> getHelp() =>
      _fetchSheet('help');
  
  static Future<List<Map<String, dynamic>>> getAccounts() =>
      _fetchSheet('accounts');
}