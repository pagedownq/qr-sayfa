# Qurio App - iOS İçin 3. Parti Servisler (Firebase, AdMob vb.) Kurulum Rehberi

Bu rehber, Android tarafında zaten ayarlanmış olan Firebase, Google AdMob ve Google Sign-In gibi servislerin **iOS tarafında** (Apple ekosisteminde) tam olarak nasıl aktif edileceğine dair en detaylı adımları içerir. 

Eğer Mac'e geçtiğinizde uygulamanızda "Reklamlar Gözükmüyor" veya "Giriş Yapılmıyor" gibi sorunlar olursa, bu adımları sırasıyla kontrol etmeniz gerekecektir.

---

## BÖLÜM 1: Firebase & Google Sign-In (iOS Bağlantısı)

Şu an projeniz içerisinde daha önceden oluşturulmuş bir `GoogleService-Info.plist` dosyanız mevcut. Ancak bunu sadece klasöre kopyalamak yetmez, **Xcode'un bu dosyayı tanıması gerekir!** Aksi takdirde uygulamanız çöker veya Firebase'e bağlanamaz.

### 1.1 Firebase Konsolunda iOS Uygulamanızın Ekli Olduğundan Emin Olmak
1. [Firebase Console](https://console.firebase.google.com)'a girin ve Qurio projenizi seçin.
2. Sol üstteki dişli çark simgesine tıklayıp **"Proje Ayarları" (Project Settings)**na gidin.
3. Bölümün en altında "Uygulamalarınız" (Your apps) kısmına bakın. Eğer orada sadece Android logolu uygulamanız varsa, **"Uygulama Ekle" (Add app)** butonuna basıp **iOS** logosunu seçin.
4. **Apple paket kimliği (Bundle ID):** Xcode içerisine (General sekmesine) yazdığınız eşleşen kimlik numarasını yazın (Örn: `com.sirketadi.qurio`).
5. Firebase size yeni bir **`GoogleService-Info.plist`** dosyası indirecektir. Bu dosyayı indirin (eğer eskisi varsa onunla değiştirmiş olursunuz).

### 1.2 GoogleService-Info.plist Dosyasını Xcode'a Yüklemek (ÇOK ÖNEMLİ)
1. Mac bilgisayarınızda Finder'dan uygulamanızın bulunduğu klasörü açın.
2. `ios` klasörünün içine girip **`Runner.xcworkspace`** dosyasını Xcode ile açın.
3. İndirdiğiniz (veya mevcut klasörde olan) `GoogleService-Info.plist` dosyasını farenizle sürükleyerek, sol taraftaki panelde **Runner > Runner klasörünün doğrudan içine** bırakın.
4. Karşınıza bir pencere çıkacak. Buradaki çok önemli detay şudur:
   - **"Copy items if needed"** kutucuğunu **İŞARETLEYİN**.
   - **"Add to targets"** bölümünde **"Runner"** seçili OLMALIDIR.
5. "Finish" butonuna basarak işlemi bitirin. Xcode artık Firebase kimliğinizi tanıyor!

### 1.3 Google Sign-In Özel İzin Ayarı (Reversed Client ID)
Google Sign-In ekranının (Safari) açıldıktan sonra uygulamaya geri dönebilmesi için `Info.plist` dosyasına özel bir link şeması eklenmelidir (Projende bunu senin için ayarlamıştık ama kontrol etmenizde fayda var):
1. Xcode içinde Runner klasöründe bulunan `GoogleService-Info.plist` dosyasına tıklayın.
2. İçindeki **`REVERSED_CLIENT_ID`** yazan satırın karşısındaki uzun kodu (Örn: `com.googleusercontent.apps.108589...`) kopyalayın.
3. Soldan `Info.plist` (Runner hedefindeki) dosyasına sağ tıklayıp "Open As > Source Code" (veya Property List) seçin.
4. En alttaki **`URL Types`** dizisinin içine girip **`URL Schemes`** kısmına kopyaladığınız o ters ID hücresini yapıştırın. (Eğer Xcode "Info" sekmesindeyken en aşağıda "URL Types" alanı varsa oradan "+" simgesiyle de ekleyebilirsiniz).

---

## BÖLÜM 2: Google AdMob (iOS İçin Reklamlar)

AdMob reklamları, Android ve iOS için tamamen **farklı Reklam Birim Kimliklerine (Ad Unit ID)** sahip olmak zorundadır! Android reklam kimliğinizi iOS'ta kullanırsanız Apple sizi banlayabilir veya reklamlarınız gösterilmez.

### 2.1 AdMob'dan iOS Uygulaması Oluşturmak
1. [Google AdMob](https://apps.admob.com) adresine girin.
2. Sol menüden **Uygulamalar (Apps) > Uygulama Ekle** deyin.
3. Platform olarak **iOS** seçin. Eğer uygulamanız şu an App Store'da yayında değilse "Hayır yayında değil"i seçerek devam edin.
4. Uygulama adı: *"Qurio iOS"* olarak oluşturun.

### 2.2 Info.plist'e iOS Uygulama Kimliğini Ekleme
1. AdMob hesabı oluşturur oluşturmaz size bir **iOS Uygulama Kimliği (App ID)** verilir. (Örn: `ca-app-pub-xxxxxxxxxxxxxxxx~yyyyyyyyyy`).
2. Mac'teki Xcode projenize tekrar gidin ve **`Info.plist`** dosyasını açın.
3. **`GADApplicationIdentifier`** isimli anahtarın içine bu iOS Uygulama Kimliğinizi yapıştırın. (Şu an kodlarınızda varsayılan Google Test ID'si bulunuyor, yayına çıkmadan önce gerçek ID'nizi her iki platform için de kodlarınıza girmeyi unutmayın!).

### 2.3 Reklam Birimleri (Banner / Geçiş) Oluşturma ve Koda Ekleme
1. AdMob'daki uygulamanızın içerisinden "Reklam Birimi Ekle" diyerek iOS için yepyeni bir **Banner (Afiş)** ve **Ödüllü (Interstitial / Geçiş)** reklam kimliği oluşturun.
2. Dart kodlarınızda reklam kimliklerini şu şekilde işletim sistemine göre sorgulayarak ayırmanız gereklidir:

Eğer `lib/ad_helper.dart` adında bir sınıfınız varsa onu aşağıdaki mantığa göre güncellemelisiniz (Şu an projede var: ÖRNEK GÜNCELLEMEDİR):

```dart
import 'dart:io';

class AdHelper {
  // BANNED AD UNIT ID
  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/6300978111'; // Sizin ANDROID GERÇEK ID'NİZ 
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/2934735716'; // Sizin IOS GERÇEK ID'NİZ VEYA TEST IOS ID
    }
    throw UnsupportedError("Desteklenmeyen platform");
  }

  // INTERSTITIAL (Tam Ekran) AD UNIT ID
  static String get interstitialAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/1033173712'; // Sizin ANDROID GERÇEK ID
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/4411468910'; // Sizin IOS GERÇEK ID
    }
    throw UnsupportedError("Desteklenmeyen platform");
  }
}
```

### 2.4 Uygulama Takip Şeffaflığı (App Tracking Transparency) İzni
Apple kuralları gereği, eğer kullanıcılara özelleştirilmiş reklam sunacaksanız (AdMob ile para kazancınız artsın diye), mutlaka takip izni istemek zorundasınız.
Bu izin kodumuz halihazırda var. Sadece `Info.plist` içerisindeki **`NSUserTrackingUsageDescription`** anahtarının yanındaki "Size daha iyi reklamlar sunabilmemiz için izin istiyoruz" şeklindeki Türkçe metni değiştirmek isterseniz Xcode üzerinden güncelleyebilirsiniz. Apple inceleme ekibi, siz izin metnini açıkça sormazsanız uygulamanızı direk reddeder.

---

## ÖZETLE DİKKAT ETMENİZ GEREKENLER (Gerçekçi Kontrol Listesi)

Mağazaya ve cihaza çıkmadan 5 dakika önce:
1. **AdMob ID Kontrolü:** "Android mi iOS mu çalışıyor?" kontrolüyle doğru uygulamanın doğru gerçek Reklam kimliklerini çektiğinden emin oldum mu?
2. **plist Taşıma İşlemi:** Firebase verilerinin yedeğini alabilmek ve giriş yapabilmek için `GoogleService-Info.plist` dosyasını Xcode ekranından "Sürükle bırak" ile "Copy items if needed" onaylanmış şekilde attım mı?
3. Sürümünüz test cihazında Admob test reklamlarını düzgün (patlamadan) açıyor mu?

Bu 3 madde sağlamsa projeniz aynı Android'de olduğu gibi iOS tarafında da servislere tıkır tıkır bağlanacaktır!
