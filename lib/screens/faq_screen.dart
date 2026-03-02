import 'package:flutter/cupertino.dart';

class FAQScreen extends StatelessWidget {
  const FAQScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: const Color(0xFF0F172A),
      navigationBar: CupertinoNavigationBar(
        middle: const Text(
          'Sıkça Sorulan Sorular',
          style: TextStyle(color: CupertinoColors.white),
        ),
        backgroundColor: const Color(0xFF1E293B),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24.0),
          children: [
            _buildFAQItem(
              'Premium özellikleri nelerdir?',
              'Premium üyelik ile reklamları kaldırabilir, QR kodlarınızı sınırsız renk ve logo ile özelleştirebilir, yüksek çözünürlüklü (PDF) çıktılar alabilir ve sınırsız tarama geçmişine erişebilirsiniz.',
            ),
            _buildFAQItem(
              'QR kodum neden okunmuyor?',
              'QR kodunuzun kontrastı düşük olabilir veya üzerine eklediğiniz logo çok büyük olabilir. Premium özelleştirmelerde logo boyutunu dengeli tutmaya ve okunaklı renkler seçmeye özen gösterin.',
            ),
            _buildFAQItem(
              'Aboneliğimi nasıl iptal ederim?',
              'Aboneliğinizi dilediğiniz zaman Google Play Store veya Apple App Store hesap ayarlarınız üzerinden "Abonelikler" sekmesine giderek iptal edebilirsiniz.',
            ),
            _buildFAQItem(
              'Verilerim güvende mi?',
              'Evet, tüm verileriniz Google Firebase altyapısı üzerinde şifreli olarak saklanır. Kişisel verileriniz asla üçüncü taraflarla paylaşılmaz.',
            ),
            _buildFAQItem(
              'Telefon numarası QR kodu nasıl çalışır?',
              'Telefon numarası eklediğinizde oluşan QR kod taratıldığında, tarayan kişinin telefonunda otomatik olarak arama ekranı açılır ve numaranız hazır hale gelir.',
            ),
            const SizedBox(height: 40),
            const Center(
              child: Text(
                'Daha fazla soru için: mgverse.dev@gmail.com',
                style: TextStyle(
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
