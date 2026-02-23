# Qurio - Gelişmiş Firebase Event Analiz Rehberi

Bu rehber, Android uygulamanızda çalışır hale getirdiğim Firebase Google Analytics 4 (GA4) olaylarının tam listesini ve bu analizlerin iOS cihazlara geçtiğinizde nasıl çalıştırılacağını anlatır. 

Artık sadece "Kaç kişi uygulamayı açtı?" yerine kullanıcıların uygulamanızın **içinde tam olarak neler yaptığını** görebileceksiniz.

---

## 1. Eklenen Yeni Analitik Olayları (Event'ler)

Flutter tarafında `firebase_analytics` kütüphanesini dâhil edip çok temiz bir aracı (`analytics_service.dart`) yazdım. Mevcut olarak çalışan ve Firebase Console tarafında izleyebileceğiniz veriler şunlardır:

### Sistem Otomatik Olayları:
- **`screen_view`**: Kullanıcı hangi sayfada ne kadar saniye/dakika geçirdi (Dashboard, Settings, Scanner, Onboarding vs.). Bunların tamamı ana yapıdan otomatik ateşlenir.

### Özel Kullanıcı Davranışı Olayları:
1. **`giris_yap`**: Kullanıcı Onboarding ekranından başarıyla Google girişi yaptığında ateşlenir. (*Parametre: giris_yontemi=google*)
2. **`yeni_link_ekle`**: Ayarlardan başarılı bir şekilde yeni link eklediği zaman ateşlenir. (*Parametreler: platform_adi, kategori*) -> Yani en çok "Instagram" mi, yoksa "WhatsApp" mi ekleniyor görebileceksiniz.
3. **`link_sil`**: Kartın üzerine basılı tutup linkini sildiğinde ateşlenir. 
4. **`qr_popup_ac`**: Ana sayfadaki sosyal medya kartına basıp QR penceresini önizlediğinde.
5. **`qr_kod_olustur`**: Hızlı QR sekmesinden yeni bir dış bağlantı QR'ı oluşturup bunu **başarıyla** Galerisine kaydettiğinde.
6. **`qr_kod_okut`**: Scanner ekranından başarılı bir şekilde kamerasından kamera okuttuğunda.
7. **`galeriden_qr_okut`**: Galeriden QR Kodu başarılı bir şekilde okutulduğunda.
8. **`uygulama_paylas`**: Ayarlar sayfasında "Uygulamayı Paylaş" butonuna basıp linkinizi dağıttığında.

*Tüm bu event parametreleri genellikle Firebase panelinize (Event Dashboard) 12-24 saat arasında düşmeye başlar.*

---

## 2. iOS'te Event Analytics Kurulumu İçin Ekstra Gerekenler Nelerdir?

Android platformu için eklediğimiz Dart kodları doğrudan iOS platformunda da %100 oranında çalışacaktır. Yani `logScanQrCode` olayı iOS'te de aynı şekilde fırlatılacaktır. Ancak iPhone telefonlarda analitik olayların çalışması ve **Google Analytics** sisteminin devreye girmesi için Xcode ve Pod tarafında 2 çok ufak adım gerekir:

### Adım 1: Podfile İçindeki Analytics Framework Kontrolü
Cocoapods tabanlı projelerde Firebase paketleri yüklenirken bazen Analytics atlanabilir. Bu yüzden Mac'e geçtiğinizde `Terminal` üzerinden şu komutu girdiğinize emin olun:
```bash
cd ios
pod install --repo-update
```
Bu komut, demin dart'a yüklediğimiz "firebase_analytics" çekirdek dosyalarını Xcode'a çekecektir.

### Adım 2: Firebase GoogleService-Info.plist Dosyası
IOS_SERVICES_GUIDE.md dosyamızda anlattığım gibi Apple platformu için indirdiğiniz "GoogleService-Info.plist" dosyanızı Xcode içinden projenize bağladığınız anda, uygulamanız Firebase bulutuyla ilk teması kuracak ve olayları (eventleri) Apple sunucularından Firebase'e fırlatmaya başlayacaktır. Ekstra bir ayara kesinlikle gerek yoktur.

### (Apple Onayı İçin) Adım 3: App Tracking Transparency (Uygulama Takip Şeffaflığı İzni)
Kullanıcılarınızın bastığı butonları ve gittiği ekranları analiz etmek bir nevi "davranışsal veri toplamaya" girdiği için, uygulamanızı ilk yüklediklerinde onlardan **Takip İzni (Allow Tracking)** istemeniz gerekir.

> Info.plist dosyasına NSUserTrackingUsageDescription iznini sizin için daha önce ayarlamıştık. Apple incelemesinde "Uygulamanız neden veri topluyor?" sorusuna sadece "Geliştirmeleri sağlamak, hatalı menüleri ölçmek ve AdMob tarafında onlara kişiselleştirilmiş reklam göstermek için Analytics verisi alıyoruz." demeniz testten onay almanızı sağlayacaktır.

Eğer test ortamında (telefonu bağlayıp Android'de denerken) verilerinizin anında Firebese'de görünüp görünmediğini incelemek isterseniz, Firebase Console üzerindeki sol menüden **DebugView** sekmesini kullanarak uygulamadaki tıklamalarınızı gerçek zamanlı görebilirsiniz.
