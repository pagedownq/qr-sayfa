# 🍎 Qurio - iOS Yayınlama ve macOS Kurulum Rehberi

Bu rehber, projenizi bir Windows makinesinden devralıp macOS üzerinde iOS için nasıl derleyeceğinizi, optimize edeceğinizi ve App Store'a nasıl yükleyeceğinizi adım adım açıklar.

## 1. Gereksinimler
iOS derlemesi alabilmek için mutlaka bir **macOS** işletim sistemine ve **Apple Developer** hesabına ihtiyacınız vardır.

- **Xcode**: Mac App Store'dan en güncel sürümü indirin.
- **Flutter SDK**: macOS için olan sürümü kurun.
- **CocoaPods**: iOS kütüphane yönetimi için gereklidir (`sudo gem install cocoapods`).

---

## 2. macOS Üzerinde İlk Kurulum

Projeyi Mac'inize indirdikten sonra terminali açın ve proje dizininde şu komutları çalıştırın:

```bash
# Bağımlılıkları çekin
flutter pub get

# iOS klasörüne gidin
cd ios

# CocoaPods kütüphanelerini kurun (Iniltel işlemci Mac'ler için)
pod install

# M1/M2/M3 (Apple Silicon) işlemcili Mac'ler için gerekliyse:
arch -x86_64 pod install
```

---

## 3. Xcode Yapılandırması (Kritik Adımlar)

`ios/Runner.xcworkspace` dosyasını Xcode ile açın ve şu ayarları kontrol edin:

### A. Signing & Capabilities (Sertifika ve Kimlik)
1. **Runner** hedefini (Target) seçin.
2. **Signing & Capabilities** sekmesine gidin.
3. **Add Account** diyerek Apple Developer ID'nizi ekleyin.
4. **Team** kısmından kendi adınızı veya firmanızı seçin.
5. **Bundle Identifier**'ın (`com.mgverse.qurio` gibi) benzersiz olduğundan emin olun.

### B. Deployment Target
- **General** sekmesinde `Minimum Deployments` kısmının en az **iOS 13.0** (Google Ads ve Firebase gereksinimi) olduğundan emin olun.

### C. Info.plist İzinleri (Önceden Optimize Edildi)
Projenizde şu izinler zaten eklenmiştir, tekrar kontrol etmeniz yeterlidir:
- `NSCameraUsageDescription`: QR tarama için.
- `NSPhotoLibraryUsageDescription`: Karekod kaydetme/seçme için.
- `NSUserTrackingUsageDescription`: iOS 14.5+ reklam takibi için.

---

## 4. Firebase ve Google Servisleri

iOS için Firebase'in çalışması için `GoogleService-Info.plist` dosyasını Firebase Console'dan (iOS uygulaması ekleyerek) indirmeniz ve **Xcode içinden** `Runner/Runner` klasörüne sürükleyip bırakmanız gerekir. 
*(Not: Dosyayı sadece klasöre kopyalamak yetmez, Xcode içinden projeye dahil edilmelidir.)*

---

## 5. Uygulama İkonları ve Görseller

iOS için uygulama ikonlarını `ios/Runner/Assets.xcassets/AppIcon.appiconset` içine yerleştirin.
- **Kısayol İkonları**: Eklediğimiz "QR Okut" ve "Hızlı QR" kısayolları için `icon_scan` ve `icon_generate` isimli PDF veya PNG dosyalarını yine bu Asset kataloğuna eklemelisiniz.

---

## 6. Yayınlama Adımları (Build & Archive)

Uygulama test edildikten ve hazır olduktan sonra:

1. **Temizlik yapın**:
   ```bash
   flutter clean
   flutter pub get
   cd ios && pod install && cd ..
   ```

2. **iOS Build alın**:
   ```bash
   flutter build ios --release
   ```

3. **Xcode'da Arşivleyin**:
   - Xcode üst menüsünden cihaz olarak **Any iOS Device (arm64)** seçin.
   - **Product > Archive** yolunu izleyin.
   - Arşivleme bittikten sonra açılan pencerede **Distribute App** diyerek App Store Connect'e gönderin.

---

## 7. App Store Connect İşlemleri

1. [App Store Connect](https://appstoreconnect.apple.com/) üzerinden yeni bir uygulama oluşturun.
2. Xcode'dan gönderdiğiniz build (yapı) birkaç dakika içinde burada görünecektir.
3. **TestFlight**: Uygulamanızı yayına almadan önce dış test kullanıcılarına (arkadaşlarınıza veya ekibinize) TestFlight üzerinden göndererek mutlaka test edin.

---

## 💡 Profesyonel İpucu
iOS derleme hatalarında genellikle ilk çözüm `ios/Podfile.lock` dosyasını ve `Pods` klasörünü silip tekrar `pod install` yapmaktır. Bu işlem, Windows'tan gelen olası dosya uyumsuzluklarını giderir.

**Başarılar! 🚀**
