import 'package:flutter/material.dart';
import '../../../core/constants/app_color.dart';
import '../../../core/utils/ts.dart';
import '../../../core/utils/app_text.dart';

class PrivacyPolicyView extends StatelessWidget {
  const PrivacyPolicyView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: AppColor.secondary,
            size: 20,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: AppText(
          'Privacy Policy',
          style: Ts.semiBold18(color: AppColor.secondary),
        ),
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText(
              'Privacy Policy for Peirlo',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColor.secondary,
              ),
            ),
            SizedBox(height: 16),
            AppText(
              'Last Updated: March 2026',
              style: TextStyle(
                fontSize: 14,
                color: AppColor.gray600,
                fontStyle: FontStyle.italic,
              ),
            ),
            SizedBox(height: 24),
            _PolicySection(
              title: '1. Information We Collect',
              content:
                  'We collect information you provide directly to us, such as when you create or modify your account, upload car listings, or communicate with us. This information may include your name, email, phone number, and any documents provided for verification purposes (e.g., PAN, Aadhaar).',
            ),
            _PolicySection(
              title: '2. How We Use Your Information',
              content:
                  'We use the information we collect to provide, maintain, and improve our services, such as to facilitate car listings, verify seller identity, and communicate with you about your account and transactions.',
            ),
            _PolicySection(
              title: '3. Data Storage and Security',
              content:
                  'We use industry-standard security measures to protect your personal information. Your data is stored securely using Firebase and local encrypted storage. We do not share your sensitive documents with third parties without your explicit consent.',
            ),
            _PolicySection(
              title: '4. Your Choices',
              content:
                  'You may update or correct your profile information at any time by logging into your account. You can also request the deletion of your account and associated data by contacting our support team.',
            ),
            _PolicySection(
              title: '5. Changes to This Policy',
              content:
                  'We may update this privacy policy from time to time. If we make significant changes, we will notify you through the app or by other means.',
            ),
            _PolicySection(
              title: '6. Contact Us',
              content:
                  'If you have any questions about this Privacy Policy, please contact us at support@peirlo.com.',
            ),
            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _PolicySection extends StatelessWidget {
  final String title;
  final String content;

  const _PolicySection({required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColor.secondary,
            ),
          ),
          const SizedBox(height: 8),
          AppText(
            content,
            style: const TextStyle(
              fontSize: 14,
              color: AppColor.textcolor,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
