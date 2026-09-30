import 'package:flutter/material.dart';
import 'package:aub_connect_app/core/constants/app_strings.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/modules/settings/widgets/settings_scaffold.dart';

class PrivacyPracticesScreen extends StatelessWidget {
  const PrivacyPracticesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SettingsScaffold(
      title: AppStrings.privacyPracticesTitle,
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'How Vithey protects your data',
            style: context.text.headlineSmall?.copyWith(fontSize: 20),
          ),
          const SizedBox(height: 16),
          _Section(
            title: 'What we collect',
            body:
                'Vithey stores account details, profile information, posts, job applications, chat messages, and verification documents needed to operate the app.',
          ),
          _Section(
            title: 'How we use it',
            body:
                'Your data powers core features such as the social feed, job applications, student finance, private chat, notifications, and Vithey AI assistance.',
          ),
          _Section(
            title: 'Sharing',
            body:
                'We do not sell personal data. Information is shared only with services required to run Vithey (for example authentication, file storage, and push notifications) under contractual safeguards.',
          ),
          _Section(
            title: 'Your controls',
            body:
                'Use Privacy Settings to control profile visibility, data sharing preferences, and activity tracking. You can update or delete account information from Settings.',
          ),
          _Section(
            title: 'Security',
            body:
                'Passwords and tokens are protected in transit with HTTPS. Sensitive credentials are stored using platform secure storage on your device.',
          ),
          _Section(
            title: 'Contact',
            body: 'Questions about privacy? Email support@aub.edu.kh or open Help Center in Settings.',
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: context.text.titleMedium),
          const SizedBox(height: 6),
          Text(body, style: TextStyle(color: context.appColors.muted, height: 1.45)),
        ],
      ),
    );
  }
}
