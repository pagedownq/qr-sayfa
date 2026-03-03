# 🍎 Qurio: Kapsamlı iOS Kurulum ve App Store Dağıtım Rehberi

Bu belge, **Qurio** projesinin iOS tarafını sıfırdan kurmak, yapılandırmak ve App Store'da yayınlamak için gereken tüm teknik detayları ve çözüm yollarını içerir.

---

## 📋 1. Başlamadan Önce (Gereksinimler)

iOS geliştirmesi için aşağıdaki araçların Mac cihazınızda yüklü olduğundan emin olun:

- **macOS:** En güncel sürüm önerilir.
- **Xcode:** En az sürüm 15.0+ (iOS 17+ SDK desteği için).
- **CocoaPods:** Flutter paketlerinin yerel kütüphanelerini yönetmek için.
  - Yüklemek için: `sudo gem install cocoapods`
- **Apple Developer Hesabı:** Uygulamayı yayınlamak ve Apple Giriş özelliğini kullanmak için aktif bir üyelik gereklidir.

---

## 🚀 2. İlk Kurulum ve Bağımlılıklar

Projeyi Mac'e indirdikten sonra terminalde şu sırayla ilerleyin:

### 2.1. Flutter Paketlerini Çekme
```bash
flutter pub get
```

### 2.2. iOS Pod Kurulumu
```bash
cd ios
# M1/M2 işlemcili Mac'ler için önerilen komut:
arch -x86_64 pod install --repo-update
# Intel işlemcili Mac'ler için:
pod install --repo-update
```
> **Not:** Eğer `Podfile.lock` kaynaklı hatalar alırsanız, `rm -rf Podfile.lock Pods` yaptıktan sonra tekrar deneyin.

---

## 🛠 3. Xcode Yapılandırması (Adım Adım)

Projenizi açarken **DAİMA** beyaz ikonlu `ios/Runner.xcworkspace` dosyasını kullanın.

### 3.1. Kimlik ve Sertifikalar (Signing)
1.  Xcode sol üstten mavi **Runner** projesine tıklayın.
2.  **TARGETS** listesinden **Runner**'ı seçin.
3.  **Signing & Capabilities** sekmesine gelin.
4.  **Add Capability (+)** butonuna basın ve şunları ekleyin:
    - **Sign In with Apple:** Apple Giriş özelliği için şarttır.
    - **Push Notifications:** Bildirim kullanacaksanız gereklidir.
5.  **Team:** Apple Developer hesabınızı seçin.
6.  **Bundle Identifier:** `com.mgverse.Qurio` olduğundan emin olun.

### 3.2. Uygulama Bilgileri (Info.plist)
Proje içinde `ios/Runner/Info.plist` dosyasını kontrol edin. Önemli anahtarlar:
- **CFBundleDisplayName:** Uygulamanın telefon ekranındaki ismi.
- **Privacy - Camera Usage Description:** QR tarama izni açıklaması.
- **Privacy - Photo Library Usage Description:** Galeriye kaydetme izni açıklaması.
- **CFBundleURLTypes:** Google Login ve Apple Login için geri dönüş URL'leri.

---

## 🔥 4. Firebase ve Google Sign-In Yapılandırması

### 4.1. GoogleService-Info.plist
- Firebase Console'dan indirdiğiniz `GoogleService-Info.plist` dosyasını Xcode üzerinden **Runner/Runner** klasörüne sürükleyip bırakın. 
- "Copy items if needed" seçeneğinin işaretli olduğundan emin olun.

### 4.2. URL Schemes
- `GoogleService-Info.plist` içindeki `REVERSED_CLIENT_ID` değerini kopyalayın.
- Xcode -> Runner -> Info -> URL Types -> + butonuna basarak bu değeri **URL Schemes** kısmına ekleyin. (Bu, Google Login sonrası uygulamaya dönüşü sağlar).

---

## 📦 5. Uygulama İkonları ve Lansman Ekranı

1.  **İkonlar:** `assets/icon/` klasöründeki ikonları güncellemek için terminalde çalıştırın:
    ```bash
    dart run flutter_launcher_icons
    ```
2.  **Lansman Ekranı:** Xcode içinde `LaunchScreen.storyboard` üzerinden görsel düzenleme yapabilirsiniz.

---

## 🏗 6. Build ve App Store'a Gönderme (Release)

Uygulamanız hazır olduğunda şu adımları izleyin:

### 6.1. Versiyon Güncelleme
`pubspec.yaml` dosyasındaki versiyon numarasını artırın:
- Örn: `version: 1.0.2+12` (Her gönderimde build numarası -artıdan sonraki kısım- artmalıdır).

### 6.2. Flutter Build
```bash
flutter build ios --release --no-codesign
```

### 6.3. Xcode Archive
1.  Xcode üst barından cihaz seçme kısmında **Any iOS Device (arm64)** seçin.
2.  Üst menüden **Product > Archive** seçeneğine tıklayın.
3.  Archive işlemi bittiğinde açılan pencereden (Organizer) **Distribute App** butonuna basın.
4.  **App Store Connect** seçeneği ile ilerleyin. Uygulamanız otomatik olarak Apple sunucularına yüklenecektir.

---

## ❓ 7. Sık Karşılaşılan Sorunlar ve Çözümler

- **Bitcode Hataları:** Xcode -> Build Settings -> **Enable Bitcode** ayarını `No` yapın.
- **CocoaPods Hiyerarşisi:** Eğer bir kütüphane bulunamıyorsa, `ios` klasöründe `rm -rf ~/Library/Developer/Xcode/DerivedData` komutuyla Xcode önbelleğini temizleyin.
- **Architecture (arm64) Hataları:** Simülatörde çalışırken hata alırsanız, Xcode -> Build Settings -> **Excluded Architectures** kısmına `arm64` eklemeyi deneyin.
- **Apple Giriş İsim Sorunu:** Kullanıcı ilk kez giriş yaptığında isim gelmiyorsa, kullanıcının Apple ID ayarlarından Qurio iznini kaldırıp tekrar denemesini sağlayın.

---

Bu rehber **MGVerse** standartlarına göre hazırlanmıştır. iOS tarafındaki her güncellemede bu belgeyi referans alabilirsiniz.
🚀
