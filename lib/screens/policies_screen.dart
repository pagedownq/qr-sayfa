import 'package:flutter/cupertino.dart';
import '../utils/app_state.dart';

class PoliciesScreen extends StatelessWidget {
  const PoliciesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: const Color(0xFF0F172A),
      navigationBar: CupertinoNavigationBar(
        middle: const Text(
          'Yasal Politikalar',
          style: TextStyle(color: CupertinoColors.white),
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
                '1. Gizlilik ve Veri Güvenliği',
                'Qurio asistan uygulaması, kullanıcı gizliliğini en temel öncelik olarak kabul eder. Uygulamamız, Google Hesabı bilgilerinizi yalnızca profil senkronizasyonu ve kullanıcı deneyimini iyileştirmek amacıyla kullanır. Tüm verileriniz Google Firebase altyapısında SSL şifreleme ile saklanmaktadır.',
              ),
              _buildPolicySection(
                '2. Bilgi Toplama ve Kullanım Kavramları',
                'Analitik veriler ve reklam performans ölçümleri için Google AdMob ve Firebase Analytics entegrasyonları kullanılmaktadır. Bu süreçte kişisel kimlik bilgileriniz paylaşılmaz, yalnızca uygulama performansını artırmaya yönelik teknik veriler anonim olarak işlenir.',
              ),
              _buildPolicySection(
                '3. KVKK ve Veri Silme Hakları',
                'Kullanıcılarımız 6698 sayılı KVKK ve ilgili regülasyonlar kapsamında her zaman verilerinin silinmesini talep etme hakkına sahiptir. Ayarlar panelindeki "Hesabı Sil" butonu ile tüm verilerinizi anında sistemden temizleyebilirsiniz.',
              ),
              _buildPolicySection(
                '4. İzinler ve Kamera Erişimi',
                'QR kodu tarama işlevi için gerekli olan kamera erişimi, görüntüyü kaydetmeden anlık olarak işler. Hiçbir görüntü sunucularımıza aktarılmaz veya saklanmaz. Logo ekleme özelliği için ise yalnızca seçtiğiniz görsele yerel bazlı erişim sağlanır.',
              ),
              _buildPolicySection(
                '5. Kullanım Koşulları ve Yasaklanan İçerikler',
                'Oluşturulan QR kodların içeriği tamamen kullanıcının sorumluluğundadır. Yasa dışı faaliyet teşviği, telif hakkı ihlali veya etik dışı içerik yönlendirmesi yapan kodların tespiti halinde hesap kullanımına son verilir.',
              ),
              _buildPolicySection(
                '6. İletişim ve Destek Hattı',
                'Politikalarımız hakkındaki geri bildirimleriniz veya destek talepleriniz için mgverse.dev@gmail.com adresinden bizimle 7/24 iletişime geçebilirsiniz.',
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
