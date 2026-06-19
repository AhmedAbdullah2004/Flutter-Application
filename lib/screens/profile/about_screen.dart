import 'package:flutter/material.dart';
import '../../utils/constants.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('عن التطبيق')),
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.account_balance_wallet, size: 60, color: Colors.white),
            ),
            const SizedBox(height: 16),
            const Text(
              'Digital Wallet',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const Text(
              'الإصدار 1.0.0',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
            ),
            const SizedBox(height: 32),
            _buildLinkTile(
              context,
              icon: Icons.description_outlined,
              title: 'الشروط والأحكام',
              onTap: () => _openPage(context, 'الشروط والأحكام', _termsText),
            ),
            const SizedBox(height: 12),
            _buildLinkTile(
              context,
              icon: Icons.privacy_tip_outlined,
              title: 'سياسة الخصوصية',
              onTap: () => _openPage(context, 'سياسة الخصوصية', _privacyText),
            ),
            const SizedBox(height: 32),
            const Text(
              'تابعنا على',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildSocialIcon(Icons.facebook, AppColors.accent),
                const SizedBox(width: 20),
                _buildSocialIcon(Icons.close, Colors.black),
                const SizedBox(width: 20),
                _buildSocialIcon(Icons.camera_alt_outlined, Colors.pink),
              ],
            ),
            const SizedBox(height: 32),
            const Text(
              '© 2026 Digital Wallet. جميع الحقوق محفوظة.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLinkTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary),
            const SizedBox(width: 12),
            Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
            const Spacer(),
            const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialIcon(IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color, size: 24),
    );
  }

  void _openPage(BuildContext context, String title, String content) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _TextPage(title: title, content: content),
      ),
    );
  }

  static const String _termsText = '''
الشروط والأحكام

1. قبول الشروط
باستخدام تطبيق Digital Wallet، فإنك توافق على الالتزام بهذه الشروط والأحكام.

2. الخدمات المقدمة
يوفر التطبيق خدمات تحويل الأموال ودفع الفواتير وصرف العملات.

3. مسؤوليات المستخدم
يلتزم المستخدم بتقديم معلومات صحيحة وحماية بيانات حسابه.

4. الأمان
نحن ملتزمون بحماية بياناتك باستخدام أحدث تقنيات التشفير.

5. تعديل الشروط
يحق لنا تعديل هذه الشروط في أي وقت مع إخطار المستخدمين.
''';

  static const String _privacyText = '''
سياسة الخصوصية

1. جمع البيانات
نجمع البيانات الضرورية لتقديم الخدمة وتحسين تجربة المستخدم.

2. استخدام البيانات
تُستخدم بياناتك فقط لتشغيل الخدمات وتحسينها ولا تُباع لأطراف ثالثة.

3. حماية البيانات
نطبق معايير أمان عالية لحماية معلوماتك الشخصية والمالية.

4. حقوق المستخدم
يحق لك طلب الاطلاع على بياناتك أو تعديلها أو حذفها في أي وقت.

5. ملفات تعريف الارتباط
نستخدم ملفات تعريف الارتباط لتحسين تجربة الاستخدام.
''';
}

class _TextPage extends StatelessWidget {
  final String title;
  final String content;

  const _TextPage({required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Text(
          content,
          style: const TextStyle(
            height: 1.8,
            fontSize: 14,
            color: AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}