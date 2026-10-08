import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

/// App-wide translations. Add a key here and use `'key'.tr` in widgets.
///
/// Locale keys must match [supportedLocales] in `app.dart`
/// (`en_US`, `km_KH`).
class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
        'en_US': _en,
        'km_KH': _km,
      };

  /// Locale for a stored language code (`en` / `km`).
  static Locale localeFor(String? code) =>
      code == 'km' ? const Locale('km', 'KH') : const Locale('en', 'US');

  /// Applies a stored language code app-wide (`Get.updateLocale`).
  static void apply(String? code) => Get.updateLocale(localeFor(code));

  static const Map<String, String> _en = {
    // Common
    'app_name': 'Vithey',
    'continue': 'Continue',
    'skip': 'Skip',
    'back': 'Back',
    'next': 'Next',
    'save': 'Save',
    'cancel': 'Cancel',
    'retry': 'Retry',
    'search': 'Search',
    'loading': 'Loading...',

    // Language selection
    'select_language': 'Select Language',
    'select_language_subtitle': 'Choose your preferred language for the app.',
    'language_english': 'English (US)',
    'language_english_subtitle': 'English',
    'language_khmer': 'Khmer',
    'language_khmer_subtitle': 'ភាសាខ្មែរ',

    // Onboarding
    'onboarding_1_title': 'Connect with Your Campus Community',
    'onboarding_1_desc':
        'Discover posts, connect with friends, and stay updated.',
    'onboarding_2_title': 'Jobs & Career Growth',
    'onboarding_2_desc':
        'Discover job posts, apply with your CV, and connect with opportunities on campus.',
    'onboarding_3_title': 'Finance, Chat & AI Support',
    'onboarding_3_desc':
        'Track tuition payments, chat privately, and get AI help for study and career.',

    // Auth
    'welcome_back': 'Welcome Back',
    'email_address': 'Email Address',
    'email_hint': 'Email',
    'password': 'Password',
    'password_hint': 'Password',
    'forgot_password': 'Forgot password?',
    'sign_in': 'Sign In',
    'sign_in_with': 'Sign in with',
    'continue_with_google': 'Continue with Google',
    'dont_have_account': "Don't have an account?",
    'sign_up': 'Sign Up',
    'create_account': 'Create Account',

    // Home / navigation
    'home': 'Home',
    'reels': 'Reels',
    'ai': 'AI',
    'profile': 'Profile',
    'your_media': 'Your media',
    'nothing_here_yet': 'Nothing here yet',
    'follow_or_create': 'Follow people or create your first post',
    'create_post': 'Create Post',
    'post': 'Post',

    // Settings
    'settings': 'Settings',
    'preferences': 'Preferences',
    'account': 'Account',
    'privacy': 'Privacy',
    'language': 'Language',
    'system': 'System',
    'dark_mode': 'Dark Mode',
    'notifications': 'Notifications',
    'security': 'Security',
    'support': 'Support',
    'help_center': 'Help Center',
    'about': 'About',
    'general': 'General',
    'data_storage': 'Data & storage',
    'accessibility': 'Accessibility',
    'logout': 'Logout',
    'edit_profile': 'Edit profile',
    'scan_qr': 'Scan QR code',

    // Finance
    'finance': 'Finance',
    'outstanding_balance': 'Outstanding Balance',
    'total_paycheck': 'Total Paycheck',
    'pay_now': 'Pay Now',
    'recent_transaction': 'Recent Transaction',
    'see_all': 'See All',

    // Chat / notifications
    'messages': 'Messages',
    'notifications_title': 'Notification',
    'no_notifications': 'No notifications yet',
    'no_notifications_desc': 'Your latest activity will appear here',
    'no_messages': 'No messages yet',
    'message_requests': 'Message Requests',

    // Search
    'places_on_map': 'Places on map',
    'people': 'People',
    'posts': 'Posts',
    'jobs': 'Jobs',
    'videos': 'Videos',
  };

  static const Map<String, String> _km = {
    // Common
    'app_name': 'វិថី',
    'continue': 'បន្ត',
    'skip': 'រំលង',
    'back': 'ត្រឡប់ក្រោយ',
    'next': 'បន្ទាប់',
    'save': 'រក្សាទុក',
    'cancel': 'បោះបង់',
    'retry': 'ព្យាយាមម្តងទៀត',
    'search': 'ស្វែងរក',
    'loading': 'កំពុងផ្ទុក...',

    // Language selection
    'select_language': 'ជ្រើសរើសភាសា',
    'select_language_subtitle': 'ជ្រើសរើសភាសាដែលអ្នកចូលចិត្តសម្រាប់កម្មវិធី។',
    'language_english': 'អង់គ្លេស (ស.រ.អ)',
    'language_english_subtitle': 'English',
    'language_khmer': 'ខ្មែរ',
    'language_khmer_subtitle': 'ភាសាខ្មែរ',

    // Onboarding
    'onboarding_1_title': 'ភ្ជាប់ជាមួយសហគមន៍សាកលវិទ្យាល័យរបស់អ្នក',
    'onboarding_1_desc': 'រកឃើញការបង្ហោះ ភ្ជាប់ជាមួយមិត្តភក្តិ និងធ្វើបច្ចុប្បន្នភាពជានិច្ច។',
    'onboarding_2_title': 'ការងារ និងការរីកចម្រើនអាជីព',
    'onboarding_2_desc':
        'រកឃើញការបង្ហោះការងារ ដាក់ពាក្យជាមួយ CV របស់អ្នក និងភ្ជាប់ជាមួយឱកាសនៅសាកលវិទ្យាល័យ។',
    'onboarding_3_title': 'ហិរញ្ញវត្ថុ ជជែក និងជំនួយ AI',
    'onboarding_3_desc':
        'តាមដានការបង់ប្រាក់សិក្សា ជជែកដោយឯកជន និងទទួលជំនួយ AI សម្រាប់ការសិក្សា និងអាជីព។',

    // Auth
    'welcome_back': 'សូមស្វាគមន៍ត្រឡប់មកវិញ',
    'email_address': 'អាសយដ្ឋានអ៊ីមែល',
    'email_hint': 'អ៊ីមែល',
    'password': 'ពាក្យសម្ងាត់',
    'password_hint': 'ពាក្យសម្ងាត់',
    'forgot_password': 'ភ្លេចពាក្យសម្ងាត់?',
    'sign_in': 'ចូល',
    'sign_in_with': 'ចូលដោយប្រើ',
    'continue_with_google': 'បន្តជាមួយ Google',
    'dont_have_account': 'មិនទាន់មានគណនី?',
    'sign_up': 'ចុះឈ្មោះ',
    'create_account': 'បង្កើតគណនី',

    // Home / navigation
    'home': 'ទំព័រដើម',
    'reels': 'វីដេអូ',
    'ai': 'AI',
    'profile': 'ប្រវត្តិរូប',
    'your_media': 'មេឌៀរបស់អ្នក',
    'nothing_here_yet': 'មិនទាន់មានអ្វីទេ',
    'follow_or_create': 'តាមដានមនុស្ស ឬបង្កើតការបង្ហោះដំបូងរបស់អ្នក',
    'create_post': 'បង្កើតការបង្ហោះ',
    'post': 'បង្ហោះ',

    // Settings
    'settings': 'ការកំណត់',
    'preferences': 'ចំណូលចិត្ត',
    'account': 'គណនី',
    'privacy': 'ភាពឯកជន',
    'language': 'ភាសា',
    'system': 'ប្រព័ន្ធ',
    'dark_mode': 'របៀបងងឹត',
    'notifications': 'ការជូនដំណឹង',
    'security': 'សុវត្ថិភាព',
    'support': 'ជំនួយ',
    'help_center': 'មជ្ឈមណ្ឌលជំនួយ',
    'about': 'អំពី',
    'general': 'ទូទៅ',
    'data_storage': 'ទិន្នន័យ និងឃ្លាំង',
    'accessibility': 'ភាពអាចចូលប្រើ',
    'logout': 'ចាកចេញ',
    'edit_profile': 'កែប្រវត្តិរូប',
    'scan_qr': 'ស្កេនកូដ QR',

    // Finance
    'finance': 'ហិរញ្ញវត្ថុ',
    'outstanding_balance': 'សមតុល្យជំពាក់',
    'total_paycheck': 'សរុបត្រូវបង់',
    'pay_now': 'បង់ឥឡូវនេះ',
    'recent_transaction': 'ប្រតិបត្តិការថ្មីៗ',
    'see_all': 'មើលទាំងអស់',

    // Chat / notifications
    'messages': 'សារ',
    'notifications_title': 'ការជូនដំណឹង',
    'no_notifications': 'មិនទាន់មានការជូនដំណឹងទេ',
    'no_notifications_desc': 'សកម្មភាពចុងក្រោយរបស់អ្នកនឹងបង្ហាញនៅទីនេះ',
    'no_messages': 'មិនទាន់មានសារទេ',
    'message_requests': 'សំណើសារ',

    // Search
    'places_on_map': 'ទីកន្លែងលើផែនទី',
    'people': 'មនុស្ស',
    'posts': 'ការបង្ហោះ',
    'jobs': 'ការងារ',
    'videos': 'វីដេអូ',
  };
}
