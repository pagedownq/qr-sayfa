import 'package:flutter/cupertino.dart';
import '../utils/app_state.dart';
class PoliciesScreen extends StatelessWidget {
  const PoliciesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: const Color(0xFF0F172A),
      navigationBar: CupertinoNavigationBar(
        middle: Text('Politikalar ve Gizlilik'Title, style: const TextStyle(color: CupertinoColors.white)),
        backgroundColor: const Color(0xFF1E293B),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPolicySection(
                '1. Gizlilik Politikası (Privacy Policy)',
                'Qurio asistan uygulaması olarak gizliliğinize en yüksek önemi veriyoruz. Uygulamamız, profilinizi oluşturmak, sosyal linklerinizi ve tarama geçmişinizi tüm cihazlarınızda senkronize etmek için Google Hesabı bilgilerinizi (Ad, Soyad, E-posta ve UID) kullanır. Bu veriler Firebase (Google Cloud) altyapısı üzerinde yüksek güvenlikli SSL/TLS şifrelemesi ile saklanmaktadır.',
              ),
              _buildPolicySection(
                '2. Veri İşleme ve Üçüncü Taraf İş Ortakları',
                'Uygulama, reklam optimizasyonu ve analitik raporlama amacıyla Google AdMob ve Firebase Analytics servislerini kullanır. Bu servisler Apple (IDFA) ve Google (AAID) reklam tanımlayıcıları gibi anonim verileri toplayabilir. Kişisel verileriniz (e-posta vb.) asla 3. taraf reklam ağlarına pazarlama amacıyla satılmaz veya paylaşılmaz.',
              ),
              _buildPolicySection(
                '3. Veri Saklama ve Hesap Silme (Right to Erasure)',
                'Google Play ve Apple App Store regülasyonları gereği, kullanıcılarımız tüm verilerini diledikleri an silme hakkına sahiptir. Hesabınızı ve hesabınıza bağlı tüm verileri (sosyal linkler, tarama geçmişi) kalıcı olarak silmek için Ayarlar > Hesabı Sil adımlarını izleyebilir veya doğrudan mgverse.dev@gmail.com adresinden resmi veri silme talebinde bulunabilirsiniz. Talepleriniz 3 iş günü içinde sonuçlandırılır.',
              ),
              _buildPolicySection(
                '4. Kamera ve Galeri Erişimi',
                'QR kodlarını okumak için uygulamamız kamera erişimine ihtiyaç duyar. Kamera görüntüsü canlı olarak işlenir; hiçbir görüntü veya video sunucularımıza kaydedilmez veya saklanmaz. Sadece kodun içindeki metin/URL bilgisi, isteğinize bağlı olarak yerel geçmişinize kaydedilir.',
              ),
              _buildPolicySection(
                '5. Kullanıcı Sorumlulukları ve İçerik Politikası',
                'Kullanıcılar, oluşturdukları veya paylaştıkları QR kodların yönlendirdiği içeriklerden tamamen kendileri sorumludur. Apple ve Google içerik politikalarını ihlal eden; müstehcenlik, kumar, yasa dışı faaliyetler veya nefret söylemi içeren bağlantıların paylaşılması durumunda kullanıcı hesabı askıya alınır.',
              ),
              _buildPolicySection(
                '6. İletişim ve Geliştirici Bilgileri',
                'Bu politikalar ve veri haklarınız hakkında tüm sorularınız için geliştirici ekibimizle iletişime geçebilirsiniz:\\n\\n✉️ E-posta: mgverse.dev@gmail.com\\n🌐 Web: https://mgverse.dev',
              ),
              const SizedBox(height: 10),
              Container(
                height: 1,
                color: CupertinoColors.white.withValues(alpha: 0.1),
              ),
              const SizedBox(height: 20),
              Center(
                child: ValueListenableBuilder<String>(
                  valueListenable: appVersionNotifier,
                  builder: (context, version, _) {
                    return Text(
                      '${'Son Güncelleme'}: 21 Şubat 2026\nVersion $version',
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
