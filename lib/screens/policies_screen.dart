import 'package:flutter/cupertino.dart';
import '../utils/app_state.dart';
import '../l10n/app_localizations.dart';

class PoliciesScreen extends StatelessWidget {
  const PoliciesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: const Color(0xFF0F172A),
      navigationBar: CupertinoNavigationBar(
        middle: Text(
          tr('legal_policies'),
          style: const TextStyle(color: CupertinoColors.white),
        ),
        backgroundColor: const Color(0xFF1E293B),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPolicySection(
                tr('policy_1_title'),
                tr('policy_1_content'),
              ),
              _buildPolicySection(
                tr('policy_2_title'),
                tr('policy_2_content'),
              ),
              _buildPolicySection(
                tr('policy_3_title'),
                tr('policy_3_content'),
              ),
              _buildPolicySection(
                tr('policy_4_title'),
                tr('policy_4_content'),
              ),
              _buildPolicySection(
                tr('policy_5_title'),
                tr('policy_5_content'),
              ),
              _buildPolicySection(
                tr('policy_6_title'),
                tr('policy_6_content'),
              ),
              const SizedBox(height: 10),
              Container(
                height: 1,
                color: CupertinoColors.white.withOpacity(0.1),
              ),
              const SizedBox(height: 20),
              Center(
                child: ValueListenableBuilder<String>(
                  valueListenable: appVersionNotifier,
                  builder: (context, version, _) {
                    return Text(
                      '${tr('last_update')}: 21 Şubat 2026\nVersion $version',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: CupertinoColors.systemGrey,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPolicySection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF00D2FF),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          content,
          style: const TextStyle(
            color: CupertinoColors.white,
            fontSize: 15,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }
}
