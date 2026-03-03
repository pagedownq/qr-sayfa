# Apple App Store Abonelik (Subscription) Kurulum Rehberi

Bu dosya, Flutter uygulamanızda Apple üzerinden **otomatik yenilenen abonelik (Auto-Renewable Subscription)** sistemini aktif etmek için Apple Developer ve App Store Connect üzerinde yapmanız gereken adımları detaylıca açıklar.

## 1. Sözleşmeler, Vergi ve Banka Bilgileri (CRITICAL)
Apple üzerinden para kazanabilmek için bu adımın **tamamen** bitmiş ve "Active" görünüyor olması şarttır.

1. [App Store Connect](https://appstoreconnect.apple.com/)'e giriş yapın.
2. **Agreements, Tax, and Banking** bölümüne gidin.
3. **Paid Applications** sözleşmesini imzalayın.
4. Banka, Vergi ve İletişim bilgilerini eksiksiz doldurun.
   - *Not: "Active" ibaresini görene kadar abonelik testleriniz çalışmayacaktır (S2S bildirimleri gelmez, ürünler invalid döner).*

---

## 2. Identifier ve Capabilities
Uygulama kimliğinizin abonelik yetkisine sahip olması gerekir.

1. [Apple Identifiers](https://developer.apple.com/account/resources/identifiers/list) sayfasında uygulamanızın **Bundle ID**'sine tıklayın.
2. **Capabilities** listesinde **In-App Purchase** kutucuğunun işaretli olduğundan emin olun.
3. **Xcode Ayarları:**
   - `ios/Runner.xcworkspace` projesini Xcode'da açın.
   - **Runner -> Signing & Capabilities** sekmesine gelin.
   - "+ Capability" butonuna basarak **In-App Purchase**'i ekleyin.

---

## 3. Abonelik Grubu ve Ürün Oluşturma
Apple'da abonelikler bir "Grup" altında toplanır. Kullanıcı bir gruptan aynı anda sadece bir ürüne abone olabilir.

1. App Store Connect -> **My Apps** -> Uygulamanız.
2. Sol menüden **In-App Purchases** -> **Subscriptions** yolunu izleyin.
3. **Subscription Group (Abonelik Grubu) Oluşturun:**
   - İsim verin (Örn: "Premium Abonelik").
   - Bu grup içinde farklı süreler (aylık/yıllık) tanımlayabilirsiniz.
4. **Subscription (Abonelik) Ekleyin:**
   - Group içine girip "+" butonuna basarak `premium_monthly` ve `premium_yearly` ürünlerini ekleyin.
   - **Type:** "Auto-Renewable Subscription" (Otomatik Yenilenen Abonelik).
   - **Product ID:** Kodunuzdaki (`lib/services/iap_service.dart`) ID'lerle birebir aynı olmalı.
   - **Subscription Duration:** 1 Month / 1 Year olarak seçin.
5. **Metadata ve İnceleme (Review):**
   - Her abonelik için **Subscription Display Name** ve **Description** ekleyin.
   - **Review Screenshot:** Uygulamanın ödeme sayfasının bir ekran görüntüsünü yükleyin. Bu olmadan Apple onay vermez.

---

## 4. App Store Connect Shared Secret
Aboneliklerin durumunu kontrol etmek ve fatura doğrulamak için bu anahtar gereklidir.

1. App Store Connect -> **My Apps** -> Uygulamanız -> **App Store** sekmesi.
2. Sol menüde **In-App Purchases** -> **App-Specific Shared Secret**.
3. **Manage** butonuna basın ve anahtarı oluşturup kopyalayın.

---

## 5. Abonelikler İçin Kritik UI Kuralları (Ret Sebebi!)
Apple, abonelik satan uygulamalarda şu 3 şeyin ödeme ekranında olmasını **şart** koşar. Yoksa uygulamanız reddedilir:
- **Restore Purchases Butonu:** Daha önce satın almış kullanıcıların hakkını geri yüklemesi için.
- **Terms of Use (EULA) Linki:** Apple'ın standart EULA'sına veya kendi kullanım koşullarınıza link.
- **Privacy Policy Linki:** Gizlilik politikanıza link.

---

## 6. Sandbox (Test) Ortamı
1. App Store Connect -> **Users and Access** -> **Sandbox Testers**.
2. Bir test hesabı oluşturun.
3. Cihazınızda test ederken, ödeme ekranı açıldığında bu test hesabı bilgilerini girin.

---

## 7. Kod Kontrol Listesi
- [ ] `iap_service.dart` içindeki `_productIds` listesi App Store'dakilerle aynı mı?
- [ ] `completePurchase` çağrılıyor mu? (Çağrılmazsa Apple aboneliği 3 gün sonra iptal eder/iade eder).
- [ ] Uygulama açılışında `restorePurchases()` veya `queryPastPurchases` ile kullanıcının aktif aboneliği var mı kontrol ediliyor mu?

Bol şans!
