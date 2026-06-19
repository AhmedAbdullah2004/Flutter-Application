import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/constants.dart';
import '../auth/login_screen.dart';
import 'personal_data_screen.dart';
import 'security_screen.dart';
import 'transaction_history_screen.dart';
import 'help_support_screen.dart';
import 'about_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('حسابي')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundColor: AppColors.primary,
              child: Icon(Icons.person, size: 60, color: Colors.white),
            ),
            const SizedBox(height: 16),
            Text(
              authProvider.user?.name ?? 'أحمد محمد',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            Text(
              authProvider.user?.email ?? 'ahmed@test.com',
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 32),

            _buildMenuItem(Icons.person_outline, 'البيانات الشخصية', () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const PersonalDataScreen()));
            }),
            _buildMenuItem(Icons.security, 'الأمان والتحقق', () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const SecurityScreen()));
            }),
            _buildMenuItem(Icons.history, 'سجل العمليات', () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const TransactionHistoryScreen()));
            }),
            _buildMenuItem(Icons.help_outline, 'المساعدة والدعم', () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const HelpSupportScreen()));
            }),
            _buildMenuItem(Icons.info_outline, 'عن التطبيق', () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const AboutScreen()));
            }),

            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () async {
                  await authProvider.logout();
                  if (context.mounted) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (route) => false,
                    );
                  }
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: const BorderSide(color: AppColors.error),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('تسجيل الخروج'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      tileColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
    );
  }
}