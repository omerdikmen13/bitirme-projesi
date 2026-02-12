# AKADEMİK RAPOR - ATIF ÇALIŞMASI

---

## BÖLÜM 2: TEORİK BİLGİLER

### 2.1. Flutter Framework

Flutter, Google tarafından geliştirilen açık kaynaklı bir kullanıcı arayüzü geliştirme kitidir [4]. 2017 yılında ilk sürümü yayınlanan Flutter, tek bir kod tabanı ile hem Android hem de iOS platformlarında çalışan uygulamalar geliştirmeyi mümkün kılmaktadır [4, 5]. Bu projede Flutter'ın tercih edilmesinin birkaç temel nedeni bulunmaktadır. Cross-platform geliştirme avantajı en önemli nedendir. Geleneksel mobil uygulama geliştirmede Android için Java veya Kotlin, iOS için ise Swift veya Objective-C kullanılması gerekmektedir. Bu durum aynı uygulamanın iki kez yazılması anlamına gelmektedir. Flutter ile tek bir Dart kod tabanı her iki platformda da çalışmaktadır. Bu yaklaşım geliştirme süresini önemli ölçüde kısaltmaktadır [5]. Flutter yüksek performans sağlamaktadır. Kodu doğrudan native makine koduna derleyen AOT derleyici kullanmaktadır [4]. React Native gibi JavaScript köprüsü kullanan framework'lerin aksine Flutter native modüllerle doğrudan iletişim kurmaktadır [5]. Yapılan karşılaştırmalarda Flutter uygulamaları 60 ile 120 FPS arasında performans sergilemekte ve bellek kullanımında daha verimli çalışmaktadır. Flutter zengin widget kütüphanesi sunmaktadır. Material Design ve Cupertino tasarım sistemlerini destekleyen kapsamlı widget'lar mevcuttur. Bu projede GridView, ListView, BottomNavigationBar, AlertDialog, TextField gibi hazır widget'lar kullanılmıştır. Widget tabanlı yapı sayesinde her şey modüler ve yeniden kullanılabilir parçalardan oluşmaktadır.

Flutter'ın Hot Reload özelliği geliştirme sürecini hızlandırmaktadır [4]. Kod değişiklikleri saniyeler içinde çalışan uygulamaya yansımaktadır. Geliştirici uygulamayı yeniden derlemeden sonuçları görebilmektedir. Bu durum özellikle kullanıcı arayüzü tasarımında büyük zaman tasarrufu sağlamaktadır.

### 2.2. Dart Programlama Dili

Dart, Google tarafından geliştirilen nesne yönelimli ve tip güvenli bir programlama dilidir [6]. Flutter uygulamaları Dart dilinde yazılmaktadır. Dart'ın C ailesine benzer sözdizimi bulunmaktadır. Java, C# veya JavaScript bilen geliştiriciler Dart'ı hızlıca öğrenebilmektedir.

Dart'ın null safety özelliği önemli bir avantajdır. Bu özellik 2021 yılında Dart 2.12 sürümü ile gelmiştir [6]. Null safety sayesinde null değer hataları derleme zamanında tespit edilmektedir. Projemizde değişkenler nullable ve non-nullable olarak açıkça tanımlanmıştır. Örneğin Image labeler labeler tanımı değişkenin null olabileceğini belirtmektedir. Bu yaklaşım çalışma zamanı hatalarını önemli ölçüde azaltmaktadır. Dart'ın en önemli özelliklerinden biri async/await yapısı ile asenkron programlamayı desteklemesidir [6]. Mobil uygulamalarda veritabanı sorguları, dosya okuma işlemleri ve ağ istekleri gibi zaman alan işlemler bulunmaktadır. Bu işlemler senkron olarak yapılırsa kullanıcı arayüzü donmaktadır. Projemizde Future ve async/await yapıları yoğun olarak kullanılmıştır. Örneğin labelImage metodu Future tipinde bir değer döndürmekte ve await anahtar kelimesi ile işlemin tamamlanması beklenmektedir. Bu süre zarfında kullanıcı arayüzü donmadan çalışmaya devam etmektedir.

### 2.3. Google ML Kit

Google ML Kit, mobil cihazlarda makine öğrenmesi modellerini çalıştırmak için Google tarafından sunulan bir yazılım geliştirme kitidir [7]. ML Kit hem Android hem de iOS platformlarını desteklemektedir. Kütüphane hazır kullanıma sunulan API'ler ve özel model entegrasyonu seçenekleri sunmaktadır. ML Kit'in temel felsefesi on-device çalışmadır [7]. Geleneksel yapay zeka sistemleri verileri bulut sunucularına göndermekte ve işlenmiş sonuçları almaktadır. ML Kit ise tüm işlemleri doğrudan cihaz üzerinde gerçekleştirmektedir. Bu yaklaşım edge AI veya on-device AI olarak adlandırılmaktadır.

ML Kit'in on-device çalışma özelliği birçok avantaj sağlamaktadır. Gizlilik açısından kullanıcı verileri cihazdan dışarı çıkmamaktadır. Fotoğraflar üçüncü taraf sunuculara gönderilmemektedir. Bu durum KVKK ve GDPR gibi veri koruma düzenlemelerine uyum açısından önemlidir [3]. Düşük gecikme açısından bulut tabanlı sistemlerde ağ gecikmesi yaşanırken on-device işlemede sonuçlar milisaniyeler içinde elde edilmektedir. Projemizde bir fotoğrafın etiketlenmesi ortalama 200 milisaniye sürmektedir. Çevrimdışı çalışma açısından internet bağlantısı olmayan ortamlarda bulut sistemleri kullanılamamaktadır. ML Kit ise tamamen çevrimdışı çalışabilmektedir [7]. Maliyet açısından bulut API'leri genellikle istek başına ücret alırken on-device işlemede herhangi bir API ücreti bulunmamaktadır.

### 2.4. Görüntü Etiketleme (Image Labeling)

Image Labeling API, bir görüntüdeki nesneleri, yerleri, aktiviteleri ve canlıları otomatik olarak tanıyan yapay zeka özelliğidir. ML Kit'in temel modeli 400'den fazla kategoriyi tanıyabilmektedir [8]. Bu kategoriler arasında hayvanlar, bitkiler, yiyecekler, araçlar, binalar ve aktiviteler bulunmaktadır.

API her tespit için iki bilgi döndürmektedir [8]. Birincisi etiket adıdır. Örneğin cat, dog, car, beach gibi İngilizce etiketler döndürülmektedir. İkincisi güvenilirlik skorudur. Bu değer 0 ile 1 arasında olup modelin tahmininden ne kadar emin olduğunu göstermektedir. Projemizde confidenceThreshold değeri 0.60 olarak ayarlanmıştır. Bu ayar yalnızca yüzde 60 ve üzeri güvenilirliğe sahip etiketlerin kabul edilmesini sağlamaktadır.

ML Kit'in Image Labeling özelliği arka planda MobileNet tabanlı bir evrişimli sinir ağı kullanmaktadır [11]. MobileNet, mobil cihazlar için optimize edilmiş hafif bir derin öğrenme modelidir. Depthwise separable convolution tekniği sayesinde geleneksel CNN modellerine kıyasla çok daha az hesaplama gücü gerektirmektedir [11]. Bu optimizasyon sayesinde model mobil cihazlarda hızlı ve verimli çalışabilmektedir.

### 2.5. Yüz Algılama (Face Detection)

Face Detection API, fotoğraflardaki insan yüzlerini tespit eden yapay zeka özelliğidir [9]. API yalnızca yüzlerin varlığını tespit etmekle kalmayıp aynı zamanda yüz koordinatlarını, yüz hatlarını ve yüz ifadelerini de analiz edebilmektedir [9].

API'nin sağladığı veriler arasında bounding box koordinatları bulunmaktadır. Bu koordinatlar yüzün fotoğraf içindeki konumunu belirtmektedir. Ayrıca yüz hatları olarak adlandırılan göz, burun ve ağız pozisyonları da tespit edilmektedir. Yüz ifadesi analizi kapsamında gülümseme olasılığı ve göz açıklık durumu gibi veriler elde edilmektedir.

Projemizde Face Detection API'si accurate modunda kullanılmaktadır [9, 15]. Bu mod daha yüksek doğruluk sağlamakta ancak biraz daha fazla işlem süresi gerektirmektedir. minFaceSize parametresi 0.1 olarak ayarlanmıştır [9]. Bu değer fotoğrafın en az yüzde 10'unu kaplayan yüzlerin algılanmasını sağlamaktadır. Algılanan her yüz için boundingBox koordinatları ve yüz ifadesi verileri veritabanına kaydedilmektedir.

### 2.6. SQLite Veritabanı

SQLite, sunucu gerektirmeyen, dosya tabanlı bir ilişkisel veritabanı yönetim sistemidir [10]. SQLite veritabanı tek bir dosya olarak saklanmaktadır. Herhangi bir kurulum veya konfigürasyon gerektirmemektedir. Bu özellikleri SQLite'ı mobil uygulamalar için ideal bir çözüm haline getirmektedir [18, 19].

Projemizde SQLite'ın tercih edilmesinin birkaç nedeni bulunmaktadır. Sunucusuz çalışması en önemli nedendir. Firebase veya MySQL gibi veritabanları uzak sunucu gerektirmektedir. SQLite ise doğrudan uygulama içinde çalışmaktadır. Bu durum internet bağlantısı gerektirmeden veri yönetimi yapılmasını sağlamaktadır. Hafif yapısı bir diğer nedendir. SQLite kütüphanesi birkaç megabayt boyutundadır. Mobil cihazların sınırlı kaynaklarını zorlamadan çalışmaktadır. Yüksek okuma performansı da önemli bir nedendir [18]. Galeri uygulamaları okuma ağırlıklı işlemler gerçekleştirmektedir. Fotoğraf listeleme, arama ve filtreleme gibi işlemler sık yapılmaktadır. SQLite okuma işlemlerinde mükemmel performans sergilemektedir. Gerekli detaylar veritabanı tasarım kısmında anlatılacaktır.

Projemizin veritabanı 7 adet tablo içermektedir. Bu tablolar Üçüncü Normal Form kurallarına uygun olarak tasarlanmıştır. photos tablosu fotoğraf meta verilerini, labels tablosu etiket bilgilerini, photo_labels tablosu fotoğraf-etiket ilişkilerini, albums tablosu albüm bilgilerini, album_photos tablosu albüm-fotoğraf ilişkilerini, persons tablosu kişi bilgilerini ve faces tablosu algılanan yüz verilerini saklamaktadır. Veritabanı performansını artırmak için kritik sütunlara indeksler eklenmiştir [18].

### 2.7. Singleton Tasarım Örüntüsü

Singleton, bir sınıftan yalnızca tek bir nesne oluşturulmasını garanti eden bir tasarım örüntüsüdür. Bu örüntü uygulama genelinde paylaşılan kaynakların yönetilmesinde kullanılmaktadır. Veritabanı bağlantıları ve servis sınıfları için yaygın olarak tercih edilmektedir.

Projemizde üç sınıf Singleton Pattern kullanılarak tasarlanmıştır. DatabaseHelper sınıfı veritabanı bağlantısını yönetmektedir. LabelingService sınıfı ML Kit etiketleyiciyi yönetmektedir. FaceDetectionService sınıfı ise yüz algılayıcıyı yönetmektedir. Singleton implementasyonu static final bir instance değişkeni ve private bir constructor içermektedir. Bu yapı sayesinde sınıftan yalnızca bir nesne oluşturulmakta ve bu nesne tüm uygulama boyunca kullanılmaktadır. Bu yaklaşım bellek tasarrufu sağlamakta ve tutarlı durum yönetimi sunmaktadır.

### 2.8. Katmanlı Mimari

Proje, katmanlı mimari yaklaşımı ile tasarlanmıştır. Bu yaklaşım, kodun modüler ve bakımı kolay olmasını sağlamaktadır. Katmanlı mimari aynı zamanda bağımlılıkların yönetilmesini ve test edilebilirliği kolaylaştırmaktadır. Proje dört ana katmandan oluşmaktadır.

**Presentation katmanı**, kullanıcı arayüzü bileşenlerini içermektedir. Bu katman iki alt bölümden oluşmaktadır: ekranlar ve yeniden kullanılabilir widget'lar. HomeScreen, PhotoViewerScreen, AlbumsScreen, FavoritesScreen, TrashScreen ve PersonsScreen gibi ekranlar bu katmana aittir. Ayrıca BottomNavBar, SearchBarWidget ve CommonWidgets gibi ortak arayüz bileşenleri de bu katmanda yer almaktadır.

**Services katmanı**, yapay zeka tabanlı iş mantığını içermektedir. Google ML Kit ile entegre çalışan LabelingService ve FaceDetectionService servisleri bu katmanda bulunmaktadır. Her iki servis de Singleton tasarım deseni kullanılarak uygulanmış olup, uygulama genelinde tek bir örnek üzerinden erişilmektedir.

**Data katmanı**, veri erişim ve yönetim kodlarını içermektedir. Bu katman iki alt bölümden oluşmaktadır: veritabanı ve modeller. DatabaseHelper sınıfı SQLite veritabanı işlemlerini yönetirken; PhotoModel, AlbumModel ve LabelModel gibi veri modelleri uygulama içindeki veri yapılarını tanımlamaktadır.

**Core katmanı**, uygulama genelinde kullanılan sabit değerleri içermektedir. Renk Paleti, boyut değerleri ve metin sabitleri gibi sabitler bu katmanda tanımlanmıştır. Bu yaklaşım, tasarım değişikliklerinin tek bir noktadan yapılabilmesini sağlamaktadır.

### 2.9. Kullanılan Kütüphaneler

Bu bölümde, yapay zeka destekli akıllı galeri uygulamasının geliştirilmesinde kullanılan yazılım kütüphaneleri açıklanmaktadır. Projede toplam on üç adet üretim bağımlılığı ve iki adet geliştirme bağımlılığı kullanılmıştır.

Flutter çatısının temel yapısını oluşturan flutter paketi, tüm widget bileşenlerini ve platform entegrasyonlarını sağlamaktadır [4]. Projede MaterialApp, Scaffold, AppBar, ListView, GridView ve PageView gibi temel widget yapıları kullanılmıştır. Uygulama teması karanlık tema olarak yapılandırılmış, Material Design 3 tasarım sistemi uygulanmıştır. Cupertino_icons paketi ise iOS platformuna özgü ikon setini sağlamakta olup çapraz platform uyumluluğunu artırmak amacıyla tercih edilmiştir. Geliştirme bağımlılıkları olarak flutter_test ve flutter_lints paketleri kullanılmıştır. Flutter_test paketi birim test ve widget test yazımı için gerekli araçları sağlamaktadır. Flutter_lints paketi ise kod analiz kurallarını içermekte olup sözdizimi hataları ve en iyi uygulama ihlallerinin tespit edilmesini sağlamaktadır.

Yapay zeka özellikleri Google ML Kit kütüphaneleri ile sağlanmıştır. Görüntü etiketleme için google_mlkit_image_labeling paketi kullanılmaktadır [8]. Bu paket TensorFlow Lite tabanlı MobileNet modelini içermekte olup 400'den fazla nesne kategorisini tanıyabilmektedir. Güvenilirlik eşiği %60 olarak ayarlanmış, bu eşiğin altındaki etiketler filtrelenmektedir. Her fotoğraf için en yüksek güvenilirliğe sahip 10 etiket saklanmaktadır. Yüz algılama için google_mlkit_face_detection paketi kullanılmaktadır [9]. Bu paket yüz konumunu, yüz noktalarını ve yüz ifadelerini algılayabilmektedir. Performans modu yüksek doğruluk olarak ayarlanmış, minimum yüz boyutu fotoğraf alanının %10'u olarak belirlenmiştir. Her iki yapay zeka modeli de tamamen cihaz üzerinde çalışmakta, internet bağlantısı gerektirmemektedir.

Yerel veritabanı yönetimi sqflite paketi ile sağlanmıştır [10]. Bu paket SQLite veritabanı erişimi sunmakta olup projede yedi adet tablo yönetilmektedir. Fotoğraf bilgileri, etiketler, fotoğraf-etiket ilişkileri, albümler, albüm-fotoğraf ilişkileri, kişiler ve yüz verileri bu tablolarda saklanmaktadır. Veritabanı işlemlerinde Singleton tasarım deseni uygulanmış, veri bütünlüğü transaction desteği ile korunmaktadır.

Cihaz galerisine erişim photo_manager paketi aracılığıyla sağlanmıştır [20]. Bu paket Android MediaStore API ve iOS Photos Framework ile doğrudan entegre çalışmaktadır. Fotoğraf meta verilerine erişim, küçük resim oluşturma ve albüm listeleme işlemleri bu paket üzerinden gerçekleştirilmektedir. Kamera erişimi için image_picker paketi kullanılmış olup kullanıcının uygulama içinden fotoğraf çekmesi bu paket aracılığıyla sağlanmıştır [21]. İzin yönetimi permission_handler paketi ile gerçekleştirilmekte, Android 13 ve üzeri sürümler için READ_MEDIA_IMAGES, eski sürümler için READ_EXTERNAL_STORAGE izinleri bu paket aracılığıyla talep edilmektedir [22].

Dosya sistemi işlemleri için path_provider, path ve file_picker paketleri kullanılmıştır [23]. Path_provider paketi cihazın dosya sistemi yollarına erişim sağlamakta, veritabanı dosyasının konumu bu paket aracılığıyla belirlenmektedir. Path paketi dosya yolu manipülasyonu için kullanılmakta, dosya adı çıkarma ve yol birleştirme işlemleri bu paket ile gerçekleştirilmektedir. File_picker paketi ise dosya seçme diyalog penceresini sağlamaktadır.

Tarih formatlama işlemleri intl paketi ile gerçekleştirilmiştir [24]. Fotoğrafların tarihe göre gruplandırılması sırasında Türkçe ay isimleri bu paket aracılığıyla formatlanmaktadır. Görüntü işleme için image paketi kullanılmış olup yapay zeka modeline gönderilmeden önce büyük boyutlu fotoğrafların küçültülmesi işlemi bu paket ile gerçekleştirilmektedir. İki megabayttan büyük fotoğraflar 1024 piksel genişliğe küçültülerek bellek kullanımı optimize edilmektedir. Tüm kütüphaneler minimum API seviyesi 21 ve hedef API seviyesi 34 ile uyumlu olacak şekilde seçilmiştir.

---

## BÖLÜM 3: LİTERATÜR TARAMASI

### 3.1. Mobil Görüntü Sınıflandırma ve Otomatik Etiketleme

Mobil cihazlarda görüntü sınıflandırma konusunda yapılan çalışmalar, derin öğrenme modellerinin bu platformlara adaptasyonu üzerine yoğunlaşmaktadır. Evrişimli sinir ağları (CNN), görüntü özelliklerini çoklu evrişim katmanları aracılığıyla çıkaran ve görüntü sınıflandırmada yaygın olarak kullanılan derin sinir ağlarıdır. Ancak bu ağlar yoğun hesaplama ve gelişmiş donanım desteği gerektirmekte, bu durum mobil cihazlara uyum sağlamayı zorlaştırmaktadır. Hafifletilmiş derin öğrenme modelleri üzerine yapılan çalışmalar, mobil terminallerde verimlilik ve doğruluk arasında üstün bir denge sağlandığını göstermiştir [11]. Yapılan deneylerde Google ML Kit, diğer yaygın kullanılan önceden eğitilmiş CNN modellerine kıyasla etkili bir şekilde iyi doğruluk performansı elde etmiştir.

Otomatik görüntü etiketleme alanında TagSense gibi sistemler önemli bir yer tutmaktadır. TagSense, bir fotoğraftaki insanları, aktiviteyi ve bağlamı algılayan ve bunları anında etiketler oluşturmak için birleştiren mobil telefon tabanlı işbirlikçi bir sistemdir [12]. Bu sistem 8 Android telefon üzerinde test edilmiş ve Apple iPhoto ile Google Picasa gibi ticari uygulamalarla karşılaştırıldığında değerli sonuçlar elde etmiştir. Benzer şekilde, Flutter ve ML Kit kullanılarak geliştirilen fotoğraf yönetim sistemleri, Google Cloud Vision API ile entegre edilerek görüntü etiketleri elde etmede hesaplama karmaşıklığı açısından mevcut modelleri geride bırakabilmektedir [13].

### 3.2. Google ML Kit ve Cihaz Üzerinde Makine Öğrenmesi

Google ML Kit, mobil uygulamalara güçlü makine öğrenmesi işlevselliği sağlayan önemli bir araç kiti olarak literatürde yer almaktadır. ML Kit, hem iOS hem de Android platformlarında çalışan uygulamalara metin tanıma, yüz algılama, görüntü karakterizasyonu ve etiketleme gibi özellikler sunmaktadır [14]. Sadece birkaç satır kodla bu güçlü ve kullanımı kolay makine öğrenmesi paketleri entegre edilebilmektedir. Ayrıca ML Kit'in bulutta ve cihaz üzerinde çalıştırılması arasındaki dengeler incelendiğinde, cihaz üzerinde çalışmanın gizlilik ve düşük gecikme açısından avantajlı olduğu görülmektedir.

Yüz algılama performansı konusunda yapılan karşılaştırmalı çalışmalar, Google ML Kit'in bu alanda üstün sonuçlar sergilediğini ortaya koymuştur. Hettiarachchi (2021) tarafından yapılan yüksek lisans tezinde, birkaç yüz algılama ve tanıma modeli Android cihazda test edilmiş ve performansları değerlendirilmiştir [15]. Sonuçlar, Google ML Kit'in yüz algılama yöntemleri arasında en iyi sonuçları gösterdiğini, bir yüzü algılamak için ortalama yalnızca 68 milisaniye sürdüğünü ortaya koymuştur. Bu performans değeri, gerçek zamanlı uygulamalar için son derece uygun bir seviyedir.

### 3.3. Mobil Uç Hesaplama ve Gizlilik

Mobil uç hesaplama, bulut bilişim ve bilgi teknolojisi hizmetlerinin ağın ucunda sunulmasını sağlayan yeni bir hesaplama paradigmasıdır. Wang ve arkadaşları (2023) tarafından yapılan kapsamlı araştırma, MEC'in ultra düşük gecikme ve yerelleştirilmiş veri işleme gereksinimlerini karşılamaya yardımcı olduğunu göstermiştir [16]. Bulut bilişim yükünü bireysel yerel sunuculara kaydırarak MEC, son kullanıcılar için Nesnelerin İnterneti potansiyelini genişletmektedir. Ancak bu yaklaşımın kesişen doğası ek güvenlik ve gizlilik endişeleri ortaya çıkarmıştır. Yapay zeka algoritmalarının bu alandaki kullanımı, karmaşık verilerle başa çıkmada ve güvenlik tehditlerini önlemede belirgin avantajlar sunmaktadır.

Yüz algılama ve tanıma uygulamalarının mobil platformlarda kullanımı giderek yaygınlaşmaktadır. Dospinescu ve Popa (2016) tarafından yapılan çalışmada, akıllı telefonların kamera kalitesinin yüksek çözünürlükte resimler çekmemizi sağladığı ve bu görüntüler üzerinde farklı tanıma türleri gerçekleştirilebildiği belirtilmiştir [17]. Yüz algılama, Facebook'ta arkadaşları etiketlemekten güvenlik sistemlerine kadar geniş bir kullanım alanına sahiptir. Bu tür uygulamalar, Alzheimer hastalarının sevdiklerini tanımalarına yardımcı olmak gibi sosyal faydalar da sağlayabilmektedir.

### 3.4. Cross-Platform Mobil Geliştirme ve Veritabanı Yönetimi

Cross-platform geliştirme çözümleri, tek bir kod tabanından birden fazla platform için mobil uygulama üretimini kolaylaştırmayı amaçlamaktadır. Dagne (2019) tarafından hazırlanan lisans tezinde, Google'ın Flutter'ı cross-platform uygulama geliştirmesine yardımcı olmak için tasarlanmış taşınabilir bir UI araç kiti olarak tanıttığı belirtilmiştir [5]. Flutter, kendi arayüz bileşenlerini, render mekanizmasını ve hızlı geliştirme döngüsünü sağlayarak native ve diğer cross-platform çözümlerle rekabet etmektedir. Tez, Flutter framework'ünün iç yapısını ve genel mimarisini diğer çözümlerle karşılaştırmalı olarak incelemiştir.

Mobil uygulamalarda veritabanı performansı kritik bir faktördür. SQLite Android ilişkisel veritabanı yönetim sistemi üzerine yapılan çalışmalar, çeşitli senaryolarda performans testleri sunmaktadır [18]. CRUD işlemleri, şifrelenmiş ve şifrelenmemiş veriler ile eşzamanlı erişim senaryoları değerlendirilmiştir. Test sonuçları, şifrelenmiş veriler üzerindeki işlemlerin şifrelenmemiş verilere göre daha uzun sürdüğünü, ancak yeni SQLite kilitleme ve günlükleme mekanizmasının verimli eşzamanlılık sağladığını göstermiştir.

Yerel veritabanları mobil uygulamalarda önemli bir bileşen haline gelmiştir. Google Play uygulama mağazasından en üst sıradaki 1.000 uygulama üzerinde yapılan büyük ölçekli ampirik çalışma, yerel veritabanı kullanımının yaygınlığını ve potansiyel sorunlarını ortaya koymuştur [19]. Çalışmalar, yerel veritabanlarının mobil cihazlarda en çok enerji tüketen bileşenlerden biri olduğunu ve API'lerinin yanlış kullanımının performans sorunlarına yol açabileceğini göstermiştir. Bu bulgular, geliştiriciler için uygulanabilir rehberliğe dönüştürülmüştür.

---

# KAYNAKLAR

[1] Photutorial. (2024). Photography Statistics 2024. [Çevrimiçi]. Erişim Adresi: https://photutorial.com/photos-statistics/ (Erişim Tarihi: Ekim-Kasım 2025).

[2] Google. (2021). Google Photos Storage Policy. [Çevrimiçi]. Erişim Adresi: https://support.google.com/photos/answer/6220791 (Erişim Tarihi: Ekim-Kasım 2025).

[3] KVKK. (2016). 6698 Sayılı Kişisel Verilerin Korunması Kanunu. [Çevrimiçi]. Erişim Adresi: https://www.kvkk.gov.tr/ (Erişim Tarihi: Ekim-Kasım 2025).

[4] Google. (2024). Flutter Documentation. [Çevrimiçi]. Erişim Adresi: https://docs.flutter.dev/ (Erişim Tarihi: Ekim-Kasım 2025).

[5] L. Dagne, "Flutter for cross-platform App and SDK development," Metropolia University of Applied Sciences, Lisans Tezi, 2019.

[6] Google. (2024). Dart Programming Language. [Çevrimiçi]. Erişim Adresi: https://dart.dev/guides (Erişim Tarihi: Ekim-Kasım 2025).

[7] Google. (2024). Google ML Kit Documentation. [Çevrimiçi]. Erişim Adresi: https://developers.google.com/ml-kit (Erişim Tarihi: Ekim-Kasım 2025).

[8] Pub.dev. (2024). google_mlkit_image_labeling. [Çevrimiçi]. Erişim Adresi: https://pub.dev/packages/google_mlkit_image_labeling (Erişim Tarihi: Ekim-Kasım 2025).

[9] Pub.dev. (2024). google_mlkit_face_detection. [Çevrimiçi]. Erişim Adresi: https://pub.dev/packages/google_mlkit_face_detection (Erişim Tarihi: Ekim-Kasım 2025).

[10] SQLite Consortium. (2024). SQLite Documentation. [Çevrimiçi]. Erişim Adresi: https://www.sqlite.org/docs.html (Erişim Tarihi: Ekim-Kasım 2025).

[11] "MobileNetV3 ile Mobil Görüntü Sınıflandırma," 2021 IEEE 2nd International Conference on Big Data, Artificial Intelligence and Internet of Things Engineering (ICBAIE), 2021.

[12] T. Yan, D. Ganesan ve diğerleri, "TagSense: A Smartphone-based Approach to Automatic Image Tagging," ACM MobiSys, 2010.

[13] "On-Device Image Labelling Photo Management System Using Flutter and ML Kit."

[14] "Machine Learning on the Move: Teaching ML Kit for Firebase in a Mobile Apps Course."

[15] S. Hettiarachchi, "Face Detection and Recognition Models Performance Evaluation on Android Devices," Mid Sweden University, Yüksek Lisans Tezi, 2021.

[16] C. Wang, Z. Yuan, P. Zhou, Z. Xu, R. Li, D. O. Wu, "The Security and Privacy of Mobile-Edge Computing: An Artificial Intelligence Perspective," IEEE Internet of Things Journal, Vol. 10, Issue 24, 2023.

[17] O. Dospinescu, I. Popa, "Face Detection and Face Recognition in Android Mobile Applications," Informatica Economica, Vol. 20, No. 1, 2016.

[18] "Android SQLite Database Performance Analysis," 2019 18th International Symposium INFOTEH-JAHORINA (INFOTEH), 2019.

[19] "An Empirical Study on Local Database Usage in Mobile Applications," 2017 IEEE International Conference on Software Maintenance and Evolution (ICSME), 2017.

[20] Pub.dev. (2024). photo_manager - Flutter plugin for managing photos and videos. [Çevrimiçi]. Erişim Adresi: https://pub.dev/packages/photo_manager (Erişim Tarihi: Ekim-Kasım 2025).

[21] Pub.dev. (2024). image_picker - Flutter plugin for selecting images from the gallery. [Çevrimiçi]. Erişim Adresi: https://pub.dev/packages/image_picker (Erişim Tarihi: Ekim-Kasım 2025).

[22] Pub.dev. (2024). permission_handler - Permission handling for Flutter. [Çevrimiçi]. Erişim Adresi: https://pub.dev/packages/permission_handler (Erişim Tarihi: Ekim-Kasım 2025).

[23] Pub.dev. (2024). path_provider - Flutter plugin for finding commonly used locations. [Çevrimiçi]. Erişim Adresi: https://pub.dev/packages/path_provider (Erişim Tarihi: Ekim-Kasım 2025).

[24] Pub.dev. (2024). intl - Internationalization and localization facilities. [Çevrimiçi]. Erişim Adresi: https://pub.dev/packages/intl (Erişim Tarihi: Ekim-Kasım 2025).
