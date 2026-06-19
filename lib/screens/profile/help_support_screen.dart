import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../utils/constants.dart';

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  final _subjectCtrl = TextEditingController();
  final _messageCtrl = TextEditingController();

  final List<Map<String, String>> _faqs = [
    {
      'q': 'كيف أرسل أموالاً؟',
      'a': 'من الصفحة الرئيسية اضغط على "إرسال"، ثم أدخل رقم هاتف أو بريد المستلم والمبلغ وأكد العملية.',
    },
    {
      'q': 'كيف أدفع فاتورة؟',
      'a': 'اضغط على "فواتير" من القائمة السفلية، اختر نوع الفاتورة وأدخل بيانات الحساب.',
    },
    {
      'q': 'كيف أرفع مستوى KYC؟',
      'a': 'توجه إلى إعدادات الأمان وابدأ عملية التحقق من الهوية بتقديم المستندات المطلوبة.',
    },
    {
      'q': 'ماذا أفعل إذا نسيت كلمة المرور؟',
      'a': 'في شاشة تسجيل الدخول اضغط على "نسيت كلمة المرور" واتبع الخطوات لإعادة تعيينها.',
    },
    {
      'q': 'هل المحفظة آمنة؟',
      'a': 'نعم، نستخدم أحدث تقنيات التشفير وحماية البيانات للحفاظ على أمان حسابك.',
    },
  ];

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('تم نسخ "$text"')),
    );
  }

  void _submitReport() {
    if (_subjectCtrl.text.trim().isEmpty || _messageCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى ملء جميع الحقول')),
      );
      return;
    }
    _subjectCtrl.clear();
    _messageCtrl.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم إرسال تقريرك بنجاح، سنتواصل معك قريباً')),
    );
  }

  @override
  void dispose() {
    _subjectCtrl.dispose();
    _messageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('المساعدة والدعم')),
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('الأسئلة الشائعة'),
            const SizedBox(height: 8),
            Container(
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
              child: ExpansionPanelList.radio(
                elevation: 0,
                children: _faqs.map((faq) {
                  return ExpansionPanelRadio(
                    value: faq['q']!,
                    headerBuilder: (ctx, isExpanded) => ListTile(
                      title: Text(
                        faq['q']!,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    body: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: Text(
                        faq['a']!,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          height: 1.6,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 28),
            _buildSectionTitle('اتصل بنا'),
            const SizedBox(height: 8),
            _buildContactTile(Icons.phone, '+20 100 123 4567', () => _copyToClipboard('+201001234567')),
            const SizedBox(height: 8),
            _buildContactTile(Icons.email_outlined, 'support@digitalwallet.com', () => _copyToClipboard('support@digitalwallet.com')),
            const SizedBox(height: 28),
            _buildSectionTitle('الإبلاغ عن مشكلة'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(20),
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
              child: Column(
                children: [
                  TextField(
                    controller: _subjectCtrl,
                    decoration: InputDecoration(
                      labelText: 'الموضوع',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _messageCtrl,
                    maxLines: 4,
                    decoration: InputDecoration(
                      labelText: 'رسالتك',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _submitReport,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('إرسال'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildContactTile(IconData icon, String text, VoidCallback onTap) {
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
            Text(text, style: const TextStyle(fontSize: 14)),
            const Spacer(),
            const Icon(Icons.copy, size: 18, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}