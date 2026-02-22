# Qurio App - iOS Derleme ve Yayınlama Rehberi (Sıfırdan En Son Aşamaya)

Bu rehber, Windows üzerinde geliştirdiğiniz Flutter projenizi, bir Mac bilgisayara (veya bulut tabanlı bir Mac ortamına) taşıyarak **Xcode üzerinden Apple App Store'a (veya TestFlight'a)** nasıl çıkaracağınızı adım adım ve en ince ayrıntısına kadar anlatmaktadır.

---

## BÖLÜM 1: Mac Bilgisayarda İlk Hazırlıklar

### 1.1 Gerekli Programların Kurulumu
Mac bilgisayara geçtiğinizde şu programların yüklü olduğundan emin olun:
1. **Xcode:** App Store'dan indirin ve kurduktan sonra bir kez açıp "Lisans Sözleşmesi"ni kabul edin.
2. **Flutter SDK:** Resmi Flutter dokümanlarından Mac için Flutter'ı kurun ve PATH ayarlarını yapın (`flutter doctor` çalıştırarak her şeyin yeşil tikli olduğundan emin olun).
3. **CocoaPods:** Terminali (Mac Terminal) açın ve şu komutu girin: `sudo gem install cocoapods`

### 1.2 Projenin Mac'e Taşınması
- Windows bilgisayarınızdaki `qr-sayfa` proje klasörünüzü bir USB, Google Drive veya GitHub (önerilen) aracılığıyla Mac bilgisayarınıza çekin.
- Mac'te Terminali açıp projenin ana dizinine gidin (`cd /KULLANICI_YOLU/qr-sayfa`).

### 1.3 Bağımlılıkların (Paketlerin) Kurulması
Terminalde proje klasöründeyken sırasıyla şu komutları çalıştırın:
```bash
flutter clean
flutter pub get
```
Bu işlem pubspec.yaml içerisindeki tüm eklentileri sisteme indirir.

### 1.4 iOS Pod Dosyalarının Derlenmesi
Flutter'dan ziyade iOS'un kendi sistemine Firebase, AdMob vb. eklentileri tanıtmak için şu komutları çalıştırın:
```bash
cd ios
pod install --repo-update
cd ..
```
*Not: "Pod installation complete" yazısını görmelisiniz. Bu işlem internet hızına bağlı olarak biraz sürebilir.*

---

## BÖLÜM 2: Xcode Üzerinde Projeyi Açma ve Ayarlar

### 2.1 Doğru Dosyayı Açmak (Çok Önemli!)
1. Mac bilgisayarınızda Finder'dan uygulamanızın bulunduğu klasörü açın.
2. `ios` klasörünün içine girin.
3. **`Runner.xcworkspace`** dosyasını bulun (asla `.xcodeproj` dosyasını açmayın!) ve çift tıklayarak Xcode'da açın.

### 2.2 Apple Geliştirici Hesabını Xcode'a Bağlama
Apple'ın uygulamanızı tanıması ve onaylaması için sisteme giriş yapmalısınız:
1. Xcode'u açın. Üst menüden **Xcode > Settings (veya Preferences) > Accounts** yolunu izleyin.
2. Sol alttaki **`+`** (artı) ikonuna tıklayın, `Apple ID`'yi seçin.
3. Yıllık Apple Geliştirici Programı ($99) üyeliği satın alınmış Apple ID'niz ve şifrenizle giriş yapın.

### 2.3 İmzalama (Signing & Capabilities) Ayarları
1. Xcode'un sol menüsünde en üstte duran mavi renkli **`Runner`** ikonuna tıklayın.
2. Ortadaki pencereler açıldığında en üstteki sekmelerden **"Signing & Capabilities"** bölümünü seçin.
3. Seçenekleri şu şekilde ayarlayın:
   - **Automatically manage signing:** Yanındaki kutucuğu İŞARETLEYİN.
   - **Team:** Biraz önce eklediğiniz Apple ID Geliştirici isminizi (Kendi adınızı veya şirket adınızı) seçin.
   - **Bundle Identifier:** Bu sizin uygulamanızın kimlik numarasıdır (Örn: `com.sirketadi.qurio`). Değiştirmemeniz önerilir, fakat benzersiz bir isim girmeniz şarttır. Eğer Firebase tarafına yeni bir bundle id kaydettiyseniz, buradakinin birebir eşleştiğinden emin olun.

### 2.4 Genel (General) Ayarları
Yine mavi **Runner**'a tıkladıktan sonra **"General"** sekmesini seçin:
- **Display Name:** Kullanıcının telefonunda ikonun altında görünecek olan isim: `Qurio`.
- **Minimum Deployments:** En az hangi iOS sürümlerine destek verecekseniz bunu seçin. (Sizin projenizin Podfile'ında bunu 14.0 yaptık, bu yüzden burada `iOS 14.0` veya üstü seçili görünmelidir).
- **Version:** Uygulama sürümü (Örn: 1.0.0). Her mağaza güncellemesinde değişmelidir.
- **Build:** App Store sistemi içindeki yapı numarası (Örn: 1, 2, 3..). Versiyon aynı kalsa bile yeni bir APK/IPA denerken bu numarayı +1 artırmanız gerekir.

---

## BÖLÜM 3: Uygulamayı Derleme (Build & Archive) Edip Çıkartma

### 3.1 Gerekli Seçici (Destination) Ayarı
Uygulamayı mağazaya çıkartmadan önce Xcode'a bunun gerçek bir cihaza gideceğini söylemelisiniz:
1. Xcode penceresinin en üst orta kısmında cihaz seçimi yapan bir buton bulunur (genellikle "iPhone 15 Pro" vs. yazar).
2. O butona tıklayın ve listeden sürükleyip en yukarılara çıkın: **`Any iOS Device (arm64)`** seçeneğini bulun ve ona tıklayın. (App Store'a göndermek için bu şarttır, Simulator seçiliyken mağazaya dosya gönderilemez).

### 3.2 Temizleme İşlemi
Olası ön bellek hatalarını önlemek için üst menüden şu işlemi yapın:
- **Product > Clean Build Folder**'a tıklayın. Alt kısımda "Clean Succeeded" yazısını görünce devam edin.

### 3.3 Arşivleme (Archive) Süreci — Uygulamayı Pakete Çevirme
1. Üst menüden **Product > Archive** seçeneğine tıklayın.
2. Bu işlem projenizin büyüklüğüne göre 3 ila 10 dakika arası sürebilir. Uygulamanız tamamen optimize edilerek Apple paketine (IPA) sıkıştırılıyor.
3. Derleme işlemi %100 bittiğinde karşınıza **"Organizer"** adında tamamen yeni bir pencere açılacak. Burada Qurio projesinin bir listesini ve sağında `Versiyon 1.0.0` logunu göreceksiniz.

---

## BÖLÜM 4: Apple App Store/TestFlight'a Test veya Yayın Süreci

"Organizer" ekranı açıldıktan sonra son adımdasınız!

### 4.1 Validate (Doğrulama)
1. Organizer penceresinde projeniz seçiliyken sağ tarafta bulunan **"Validate App..."** butonuna tıklayın.
2. Açılan pencerede otomatik (Automatically manage signing) seçeneğini işaretli bırakarak **Next** deyin.
3. Apple sistemleri kodlarınızı kontrol edecek. Eğer hiçbir kırmızı hata (Örn: İkon boyutu yanlış, eksik izin vs.) vermeden geçerse, yeşil tik göreceksiniz. Zaten sizin uygulamanız için gereken tüm İzinleri ve ikon süreçlerini biz ayarladık, hata vermeyecektir!

### 4.2 Distribute App (Uygulamayı Dağıtma)
1. "Organizer" ekranına geri dönün ve sağ taraftan mavi renkli **"Distribute App"** butonuna tıklayın.
2. Karşınıza dağıtım seçenekleri çıkacak. Buradan **App Store Connect** (App Store ve TestFlight dağıtımları için) seçeneğini işaretleyip **Next** deyin.
3. Daha sonra karşınıza iki veya tek seçenek gelecektir genelde **"Upload"** u seçerek (Apple'ın sunucularına doğrudan iletin) **Next** ile ilerleyin.
4. "Automatically manage signing" seçip ilerleyin.
5. Son aşamada karşınıza uygulamanın boyutları ve içindekilerin ufak bir kaba taslağı çıkacak. Sağ alttan tekrar **Upload**'a tıklayın.
6. Bu işlem de internet upload hızınıza göre biraz sürecektir. İşlem bitince gülen yüz benzeri koca bir yeşil tik göreceksiniz: **"Successfully uploaded"**.

---

## BÖLÜM 5: App Store Connect Üzerinden Son İzler

Kodunuzu Apple'ın sunucularına başarıyla ulaştırdınız. Şimdi yayına alma zamanı.

1. İnternet tarayıcınızdan **[App Store Connect](https://appstoreconnect.apple.com/)** adresine gidin ve Apple ID'niz ile giriş yapın.
2. **"Uygulamalarım" (My Apps)** sekmesine tıklayın. Orada Eğer daha önce Qurio isimli bir proje açmadıysanız "+" ya basıp yeni bir uygulama şablonu oluşturun (Bunda Bundle ID kısmından Xcode'a yazdığınız ID'yi seçin).
3. Uygulamanızın detaylar sayfasına indiğinizde;
   - Sol menüden **TestFlight** sekmesinden onaylanmasını beklemeden uygulamayı kendiniz yükleyebilir ve test edebilirsiniz.
   - Mağazaya çıkarmak için, sol menüdeki **Hazırlanıyor (Prepare for Submission)** veya **1.0.0 Dağıtımı** sayfasına tıklayın. Form alanlarını (ekran görüntüleri, gizlilik politikası vs) doldurun.
   - Sayfayı biraz kaydırdığınızda **"Derleme (Build)"** adında boş bir liste bulunacak. Hemen altındaki küçük yeşil `+` ikonuna basarsanız, demin Xcode'dan yükleme yaptığınız dosyayı (Versiyon 1.0.0, Build 1) göreceksiniz. Onu seçin.
4. Tüm formları doldurup (reklam durumu, içerik yaş kısıtlamaları), sağ üstteki **"İncelemeye Gönder" (Submit for Review)** butonuna basın!

**TEBRİKLER! 🎉**
Uygulamanız şu an Apple ekipleri tarafından inceleniyor. 24 saat ile 3 gün arasında bir sürede yayına (veya red aldıysanız red sebeplerinin mailine) kavuşmuş olacaksınız.
