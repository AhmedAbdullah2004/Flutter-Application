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
  static const String onboarding1Desc = 'حول الأموال لأصدقائك وعائلتك في ثوانٍ معدودة';
  static const String onboarding2Title = 'دفع الفواتير بضغطة واحدة';
  static const String onboarding2Desc = 'ادفع فواتير الكهرباء والمياه والإنترنت بكل يسر';
  static const String onboarding3Title = 'تبادل العملات بأفضل الأسعار';
  static const String onboarding3Desc = 'احصل على أفضل أسعار الصرف في السوق';
  static const String onboarding4Title = 'أمان مطلق وخصوصية تامة';
  static const String onboarding4Desc = 'بياناتك محمية بأحدث تقنيات التشفير';
}

class ApiConstants {
  // TODO: Change to your actual backend URL
  static const String baseUrl = 'https://your-backend-url.com/api';
  // For local testing: 'http://10.0.2.2:7182/api' for Android emulator
  static const String authRegister = '/Auth/register';
  static const String authLogin = '/Auth/login';
  static const String authVerifyOtp = '/Auth/verify-otp';
  static const String authSendOtp = '/Auth/send-otp';
  
  static const String walletCreate = '/wallet';
  static const String walletMyWallets = '/wallet/my-wallets';
  static const String walletBalance = '/wallet/{walletId}/balance';
  
  static const String transferSend = '/Transfer/send';
  static const String transferHistory = '/Transfer/history/{walletId}';
  
  static const String currencyRate = '/CurrencyExchange/rate';
  static const String currencyExchange = '/CurrencyExchange/exchange';
  static const String currencyHistory = '/CurrencyExchange/history';
  
  static const String billers = '/BillPayment/billers';
  static const String billPay = '/BillPayment/pay';
  static const String billHistory = '/BillPayment/my-payments';
  
  static const String userProfile = '/User/profile';
  static const String notifications = '/Notification';
  static const String unreadCount = '/Notification/unread-count';
}