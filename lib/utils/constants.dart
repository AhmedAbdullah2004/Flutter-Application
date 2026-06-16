import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF00C853);
  static const Color primaryDark = Color(0xFF00A844);
  static const Color accent = Color(0xFF2196F3);
  static const Color background = Color(0xFFF5F7FA);
  static const Color cardBg = Colors.white;
  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color success = Color(0xFF10B981);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
}

class AppStrings {
  static const String appName = 'Digital Wallet';
  static const String welcome = 'أهلاً بك في محفظتك الرقمية';

  static const String onboarding1Title = 'إرسال واستلام الأموال بسهولة';
  static const String onboarding1Desc =
      'حول الأموال لأصدقائك وعائلتك في ثوانٍ معدودة';

  static const String onboarding2Title = 'دفع الفواتير بضغطة واحدة';
  static const String onboarding2Desc =
      'ادفع فواتير الكهرباء والمياه والإنترنت بكل يسر';

  static const String onboarding3Title = 'تبادل العملات بأفضل الأسعار';
  static const String onboarding3Desc =
      'احصل على أفضل أسعار الصرف في السوق';

  static const String onboarding4Title = 'أمان مطلق وخصوصية تامة';
  static const String onboarding4Desc =
      'بياناتك محمية بأحدث تقنيات التشفير';
}

class ApiConstants {
  // السيرفر يحول الطلبات إلى HTTPS
  static const String baseUrl =
      'https://digitalwallet-001-site1.site4future.com';

  // Authentication
  static const String authRegister = '/api/Auth/register';
  static const String authLogin = '/api/Auth/login';
  static const String authVerifyOtp = '/api/Auth/verify-otp';
  static const String authSendOtp = '/api/Auth/send-otp';

  // User
  static const String userProfile = '/api/User/profile';

  // Wallet
  static const String myWallets = '/api/Wallet/my-wallets';
  static const String walletBalance = '/api/Wallet/{walletId}/balance';

  // Transfer
  static const String transferSend = '/api/Transfer/send';
  static const String transferHistory =
      '/api/Transfer/history/{walletId}';

  // Currency Exchange
  static const String currencyRate = '/api/CurrencyExchange/rate';
  static const String currencyExchange =
      '/api/CurrencyExchange/exchange';
  static const String currencyHistory =
      '/api/CurrencyExchange/history';

  // Bills
  static const String billers = '/api/BillPayment/billers';
  static const String billPay = '/api/BillPayment/pay';
  static const String billHistory =
      '/api/BillPayment/my-payments';

  // Notifications
  static const String notifications = '/api/Notification';
  static const String unreadCount =
      '/api/Notification/unread-count';
}