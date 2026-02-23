# Qurio App - iOS Yeni Sürüm (Güncelleme) Çıkarma Rehberi

Uygulamanızın v1.0.0 ilk sürümünü başarıyla App Store'a veya TestFlight'a gönderdikten sonra, Windows bilgisayarınızda (VS Code üzerinde) yeni kodlar eklediniz, hataları çözdünüz ya da tasarımı değiştirdiniz. Peki bu **yeni kodları Mac bilgisayara nasıl aktarıp yeni sürüm (örn: 1.0.1) olarak mağazadaki kullanıcılara sunacaksınız?**

İşte bu rehber, "Uygulamamı nasıl güncellerim?" sorusunun en detaylı cevabıdır.

---

## BÖLÜM 1: Windows'ta Sürüm Numarasını Artırmak

Bir uygulamayı güncellerken Apple sunucuları şuna dikkat eder: **Eğer göndermeye çalıştığınız dosyanın "Sürüm (Version)" veya "Yapı (Build)" numarası mağazadakinden büyük değilse, Red yersiniz!** Yeni bir paket olduğunu sisteme anlatmak zorundasınız.

1. Windows bilgisayarınızda VS Code ile **`pubspec.yaml`** dosyasını açın.
2. Dosyanın üst kısımlarında yer alan `version:` satırını bulun. (Örn: `version: 1.0.0+1`)
3. **Versiyon (Version):** İlk kısım (örn. 1.0.0) kullanıcının mağazada göreceği sürümdür.
   - Ufak bir hata veya özellik eklediyseniz: `1.0.1` veya `1.1.0` yapın.
   - Baştan aşağı devasa bir sistemi değiştirdiyseniz: `2.0.0` yapın.
4. **Yapı (Build Number):** `+` işaretinin yanındaki sayıdır (örn. `+1`). Her Xcode veya Google Play paketinde **mutlaka** 1 artmalıdır. 
   - Önceki sürüm `1.0.0+1` ise, yenisi **`1.0.1+2`** (Hatta +3, +4..) olmalıdır.

> *Örnek Güncelleme:* `version: 1.1.0+2` (Sürüm 1.1.0 oldu, Yapı numarası 2 oldu)

---

## BÖLÜM 2: Projeyi Tekrar Mac Bilgisayara Aktarma (Kodların Güncellenmesi)

Windows'taki en güncel klasörlerinizi Mac bilgisayarınıza atmanız gerekir.

### A) GitHub / Git Üzerinden Taşıma (En Güvenlisi)
Eğer projenizi bir GitHub veya Git reposunda tutuyorsanız (en iyi pratik budur):
1. Windows: Yenilikleri kaydedip Push edin (`git add .`, `git commit -m "Sürüm 1.1 güncellemeleri"`, `git push`).
2. Mac'e geçin, Terminali açıp projenin ana dizinindeyken en yeni kodları çekin: `git pull`

### B) Klasör Olarak Aktarma (USB / Google Drive vb.)
1. Windows'tan güncel `qr-sayfa` klasörünün içindeki tüm dosyaları (veya en azından değişen `lib/`, `assets/`, `pubspec.yaml` vs) Mac'teki proje klasörüne kopyalayıp eskisinin üzerine yazdırın. 
   *(Not: `ios`, `android`, `.dart_tool`, `build` gibi klasörlerde Apple tarafındaki ayarları silmemeye/ezmemeye dikkat edin. Bu yüzden `git` metodunu öncelikli öneririm, ancak pubspec ve lib dosyalarının güncel halini atmanız yeterlidir).*

---

## BÖLÜM 3: Mac Ortamında Uygulamayı Hazırlama

Sürüm değiştiği veya yeni paketler (`flutter pub add..`) yüklenmiş olma ihtimaline karşı Mac'te aşağıdaki işlemleri sırasıyla Terminal'e yazın. Mac Terminalde proje dizininize (Örn: `cd/Kullanici/qr-sayfa`) girin:

1. Eski ön bellek derlemelerini silin:
   ```bash
   flutter clean
   ```
2. Yeni eklentilerinizi ve paketlerinizi kurun:
   ```bash
   flutter pub get
   ```
3. Eğer yeni bir paket eklendiyse (Analiz, Kamera vb.) Apple tarafının da bunu tanıması (pod) gerekir:
   ```bash
   cd ios
   pod install --repo-update
   cd ..
   ```

---

## BÖLÜM 4: Xcode Üzerinden Yeni Paketi Mağazaya Yollama

Yeni kodlar geldi, yeni versiyon VS Code'dan ayarlandı (1.1.0), pod'lar yüklendi. Sırada mağazaya yollamak var!

### 4.1 Xcode'u Açın (Aynı Tas Aynı Hamam!)
1. Finder'dan uygulamanızın bulunduğu klasörü açın.
2. `ios` klasörünün içine girin ve yine **`Runner.xcworkspace`** dosyasına iki kere tıklayarak açın.

### 4.2 Versiyon ve Seçici Ayarlarının Kontrolü
1. Sol menüden üstteki mavi renkli **`Runner`**'a tıklayın.
2. **General** sekmesinde `Version` ve `Build` kısımlarına bakın. *Eğer pubspec.yaml içerisindeki sürüm buraya (örn Version: 1.1.0, Build: 2 şeklinde) başarılı bir şekilde yansımışsa hiçbir şeye dokunmayın harika.* (Yansımadıysa elle bu ikisini oradaki hanelere yazarak eşitleyin).
3. En üst orta kısımda cihaz olarak **`Any iOS Device (arm64)`** 'in seçili olduğundan emin olun!

### 4.3 Temizle ve Arşivle (Paketleme Zamanı)
1. Üst menüden **Product > Clean Build Folder** diyerek eski paket hatalarının önüne geçin.
2. **Product > Archive** deyin. Ortalama 2-5 dakika arası bekleyin, bittiğinde önünüze **Organizer** ekranı gelecektir.

### 4.4 Mağazaya Yükleme Aşaması
İlk sürümde çıkarttığınız mantığın %100 aynısıdır:
1. "Organizer" ekranında sağ taraftan mavi **Distribute App** butonuna tıklayın.
2. **App Store Connect** > **Upload** > **Automatically manage signing** diyerek ilerleyin.
3. Altta "Upload" çıkınca basıp Apple sunucularına "Successfully uploaded" yazısı gelene kadar internet hızınıza bağlı olarak yüklemesini bekleyin.

---

## BÖLÜM 5: App Store Connect Panelinde Sürümü Yayına Alma

Uygulamanız paket olarak Apple sunucularına "Yapı 2 (Build 2)" adıyla ulaştı. 

1. İnternet tarayıcınızdan **[App Store Connect](https://appstoreconnect.apple.com/)**'e giriş yapın, **Uygulamalarım**'a tıklayıp Qurio'yu seçin.
2. Sol tarafta "App Store" sekmesi altından **"+ Sürüm veya Platform"** ekle diyerek (Mevcut mağazadaki sürüm 1.0 ise) yeni bir `1.1.0` taslağı oluşturun.
3. Çıkan bilgi formlarına "Bu Sürümdeki Yenilikler Neler?" diye bir kutu gelir. Oraya "Gelişmiş analitikler eklendi, yeni karşılama ekranı tasarlandı, ikon sorunları giderildi." gibi güzel notlar yazın.
4. "Derleme (Build)" kısmına gelip `+` ya tıklayınca, Xcode'dan kargoladığınız yepyeni `Versiyon 1.1.0, Build 2` olan dosyayı bulup seçeceksiniz (Bu dosyanın buraya yansıması 5-15 dakika Apple kod işlemesi sürer).
5. En sağ üstteki **"İncelemeye Gönder"** butonuna basarak yeni güncellemeyi onaycıların sihrine bırakın!

**İşte hepsi bu kadar!**
Kullanıcılar onay geldikten 2 saat sonra telefonlarındaki "App Store" ikonunda uygulamanızın "Güncelle (Update)" butonunu görecekler ve yeni kodlarınıza anında kavuşacaklar! 🚀
