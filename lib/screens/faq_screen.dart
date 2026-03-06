import 'package:flutter/cupertino.dart';
import '../l10n/app_localizations.dart';

class FAQScreen extends StatelessWidget {
  const FAQScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: const Color(0xFF0F172A),
      navigationBar: CupertinoNavigationBar(
        middle: Text(
          tr('faq'),
          style: const TextStyle(color: CupertinoColors.white),
        ),
        backgroundColor: const Color(0xFF1E293B),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24.0),
          children: [
            _buildFAQItem(
              tr('faq_premium_q'),
              tr('faq_premium_a'),
            ),
            _buildFAQItem(
              tr('faq_qr_q'),
              tr('faq_qr_a'),
            ),
            _buildFAQItem(
              tr('faq_cancel_q'),
              tr('faq_cancel_a'),
            ),
            _buildFAQItem(
              tr('faq_data_q'),
              tr('faq_data_a'),
            ),
            _buildFAQItem(
              tr('faq_phone_q'),
              tr('faq_phone_a'),
            ),
            const SizedBox(height: 40),
            Center(
              child: Text(
                tr('more_questions'),
                style: const TextStyle(
                  color: CupertinoColors.systemGrey,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQItem(String question, String answer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B).withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF00D2FF).withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question,
            style: const TextStyle(
              color: Color(0xFF00D2FF),
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            answer,
            style: const TextStyle(
              color: CupertinoColors.white,
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
