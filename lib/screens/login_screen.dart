import 'package:flutter/material.dart';
import 'package:project_work/screens/help_screen.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/sheets_service.dart';
import '../widgets/drive_image.dart';
import 'dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _loading = false;
  bool _obscure = true;
  String _orgName = 'নবদিগন্ত সমিতি';
  String _logoFileId = '';   // ✅ Drive File ID

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final s = await SheetsService.getSettings();
    if (s != null && mounted) {
      final rawUrl = s['logo_url']?.toString() ?? '';
      setState(() {
        _orgName = s['org_name']?.toString() ?? 'সমিতি অ্যাপ';
        _logoFileId = UserModel.extractFileId(rawUrl); // File ID বের করো
      });
    }
  }

  Future<void> _login() async {
    if (_phoneCtrl.text.isEmpty || _passCtrl.text.isEmpty) {
      _snack('ফোন নম্বর ও পাসওয়ার্ড দিন', Colors.orange);
      return;
    }
    setState(() => _loading = true);
    try {
      final user = await AuthService.login(
          _phoneCtrl.text, _passCtrl.text);
      if (!mounted) return;
      if (user != null) {
        Navigator.pushReplacement(context,
            MaterialPageRoute(
                builder: (_) => DashboardScreen(user: user)));
      } else {
        _snack('ফোন নম্বর বা পাসওয়ার্ড ভুল', Colors.red);
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _snack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: color));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F8),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: Column(children: [

            // ✅ লোগো — Drive থেকে অথবা default আইকন
            Container(
              height: 100,
              width: 100,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 10)
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: _logoFileId.isNotEmpty
                    ? DriveImage(
                  fileId: _logoFileId,
                  size: 100,
                  fallbackText: '',   // লোড না হলে আইকন দেখাবে
                  fallbackWidget: const Icon(
                    Icons.account_balance,
                    size: 50,
                    color: Color(0xFF3F51B5),
                  ),
                )
                    : const Icon(
                  Icons.account_balance,
                  size: 50,
                  color: Color(0xFF3F51B5),
                ),
              ),
            ),

            const SizedBox(height: 20),
            Text(_orgName,
                style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF3F51B5))),
            const SizedBox(height: 8),
            Text('আপনার অ্যাকাউন্টে লগইন করতে ইন্টারনেট কানেকশন চালু রাখুন',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600])),
            const SizedBox(height: 36),

            // Login Card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(children: [
                  TextField(
                    controller: _phoneCtrl,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: 'ফোন নম্বর',
                      prefixIcon: const Icon(Icons.phone),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _passCtrl,
                    obscureText: _obscure,
                    onSubmitted: (_) => _login(),
                    decoration: InputDecoration(
                      labelText: 'পাসওয়ার্ড',
                      prefixIcon: const Icon(Icons.lock),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                      suffixIcon: IconButton(
                        icon: Icon(_obscure
                            ? Icons.visibility
                            : Icons.visibility_off),
                        onPressed: () =>
                            setState(() => _obscure = !_obscure),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _loading ? null : _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3F51B5),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: _loading
                          ? const CircularProgressIndicator(
                          color: Colors.white)
                          : const Text('লগইন করুন',
                          style: TextStyle(
                              fontSize: 18, color: Colors.white)),
                    ),
                  ),
                ]),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Do you need any Help?'),
                  SizedBox(width: 8,),
                  InkWell(
                    onTap: ()=>Navigator.push(context, MaterialPageRoute(builder: (context) => HelpScreen())),
                    child: Text('Click Here.',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue
                    ),
                    ),
                  )
                ],
              ),
            )
          ]),
        ),
      ),
    );
  }
}