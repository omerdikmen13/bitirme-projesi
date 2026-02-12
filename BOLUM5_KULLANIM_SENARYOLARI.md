## 5.2 Kullanım Senaryoları

Bu bölümde uygulamanın temel kullanım senaryoları detaylı olarak açıklanmaktadır. Her senaryo, kullanıcı etkileşiminden başlayarak sistem bileşenleri arasındaki veri akışını ve gerçekleştirilen işlemleri kapsamaktadır. Senaryolar, uygulamanın işlevsel gereksinimlerini karşılama biçimini göstermekte ve yazılım mimarisinin pratik uygulamasını ortaya koymaktadır.

---

### 5.2.1 Uygulama Başlatma ve Fotoğraf Yükleme

**Şekil 5.9:** Uygulama Başlatma Sıralı Diyagramı

Uygulama başlatma süreci, kullanıcı deneyiminin temelini oluşturan kritik bir senaryo olarak tasarlanmıştır. Bu süreç dört ana bileşenin koordineli çalışmasını gerektirmektedir. Kullanıcı uygulamayı başlattığında ilk olarak Flutter çerçevesinin platform kanallarıyla iletişim kurması için gerekli bağlam oluşturulmaktadır. Bu aşamada durum çubuğu şeffaf hale getirilerek karanlık tema ile uyumlu görsel bütünlük sağlanmaktadır.

Ana ekran bileşeninin yaşam döngüsü başlatma metodunda uygulama ilklendirme fonksiyonu çağrılmaktadır. Bu fonksiyon öncelikle üç yüz milisaniye gecikme uygulayarak kullanıcı arayüzünün hazır hale gelmesini beklemektedir. Ardından etiketleme servisinin başlatma metodu çağrılarak yapay zeka etiketleme modeli yüzde altmış güvenilirlik eşiği ile yapılandırılmaktadır.

İzin yönetimi fotoğraf yöneticisi kütüphanesinin genişletilmiş izin talep metodu aracılığıyla gerçekleştirilmektedir. Android on üç ve üzeri sürümlerde medya görüntüleri okuma izni, eski sürümlerde ise harici depolama okuma izni talep edilmektedir. İzin reddedildiğinde kullanıcıya bildirim çubuğu bileşeni aracılığıyla bilgilendirme yapılmakta ve yükleme işlemi sonlandırılmaktadır.

İzin onaylandıktan sonra varlık yolu listesi alma metodu ile cihazın tüm fotoğraf albümleri listelenmektedir. Uygulama öncelikle test için belirlenen özel klasörü aramakta, bulamazsa ilk albümü varsayılan olarak seçmektedir. Seçilen albümden sayfalı varlık listesi alma metodu ile ilk beş yüz fotoğraf sayfalı olarak yüklenmektedir. Bu sınırlama büyük galerilerde bellek kullanımını optimize etmek amacıyla uygulanmıştır.

Her fotoğraf için veritabanı yardımcısı sınıfının fotoğraf silindi mi metodu çağrılarak veritabanında silinme bayrağı kontrol edilmektedir. Çöp kutusuna taşınmış fotoğraflar filtrelenerek ana galeri listesinden çıkarılmaktadır. Kalan fotoğraflar tarihe göre gruplama fonksiyonu ile oluşturulma tarihine göre gruplandırılmaktadır. Son olarak durum güncelleme metodu ile kullanıcı arayüzü güncellenerek fotoğraflar görüntülenmektedir.

---

### 5.2.2 Yapay Zeka ile Fotoğraf Etiketleme

**Şekil 5.10:** Yapay Zeka Etiketleme Sıralı Diyagramı

Yapay zeka tabanlı fotoğraf etiketleme, uygulamanın en kritik özelliklerinden birini oluşturmaktadır. Bu işlem arka plan etiketleme fonksiyonu aracılığıyla arka planda asenkron olarak gerçekleştirilerek kullanıcı arayüzünün yanıt vermeye devam etmesi sağlanmaktadır. Etiketleme süreci dört temel bileşenin etkileşimini içermektedir.

Sürecin ilk adımında her fotoğraf için veritabanı yardımcısı sınıfının etiket var mı metodu çağrılarak daha önce etiketlenip etiketlenmediği sorgulanmaktadır. Bu optimizasyon sayesinde aynı fotoğrafın tekrar tekrar etiketlenmesi önlenmekte ve işlem süresi önemli ölçüde azaltılmaktadır. Metod, fotoğraf-etiket ilişki tablosunda ilgili kayıt olup olmadığını kontrol etmektedir.

Etiketlenmemiş bir fotoğraf tespit edildiğinde etiketleme servisinin görüntü etiketleme metodu çağrılmaktadır. Bu metod öncelikle dosya sınıfı ile dosyanın fiziksel olarak var olup olmadığını doğrulamaktadır. Silinmiş veya erişilemeyen dosyalar bu aşamada atlanarak hata oluşması engellenmektedir.

Dosya doğrulaması başarılı olduğunda dosya yolundan giriş görüntüsü oluşturma metodu ile görüntü yapay zeka formatına dönüştürülmektedir. Görüntü etiketleyici sınıfının görüntü işleme metodu çağrılarak yapay zeka analizi gerçekleştirilmektedir. Model olarak mobil cihazlar için optimize edilmiş sinir ağı modeli kullanılmakta olup dört yüzden fazla nesne kategorisini tanıyabilmektedir. Model tamamen cihaz üzerinde çalıştığından internet bağlantısı gerektirmemekte ve kullanıcı gizliliği korunmaktadır.

Model tarafından döndürülen etiket listesi üzerinde çeşitli işlemler uygulanmaktadır. Her etiketin adı küçük harfe çevirme ve boşluk temizleme metodlarıyla normalize edilmektedir. Etiketler güvenilirlik değerine göre azalan sırada sıralanmakta ve en güvenilir on tanesi seçilmektedir. Bu sınırlama veritabanı boyutunu kontrol altında tutmak ve en anlamlı etiketleri korumak amacıyla uygulanmıştır.

Etiketler veritabanı yardımcısı sınıfının etiket kaydetme metodu ile veritabanına kaydedilmektedir. Bu metod önce fotoğrafın fotoğraflar tablosunda kaydını aramakta, yoksa yeni kayıt oluşturmaktadır. Her etiket için etiketler tablosunda varlık kontrolü yapılmakta, yoksa ekleme işlemi gerçekleştirilmektedir. Son olarak fotoğraf-etiket ilişki tablosuna fotoğraf kimliği, etiket kimliği ve güvenilirlik skoru ile yeni kayıt eklenmektedir.

---

### 5.2.3 Etiket ile Fotoğraf Arama

**Şekil 5.11:** Etiket ile Arama Sıralı Diyagramı

Etiket tabanlı fotoğraf arama özelliği yapay zeka tarafından oluşturulan etiketlerin kullanıcıya pratik fayda sağlamasının temel yoludur. Bu senaryo arama çubuğu bileşeni, ana ekran ve veritabanı yardımcısı sınıflarının etkileşimini içermektedir. Arama işlemi kullanıcının metin giriş alanına metin girmesiyle başlatılmaktadır.

Kullanıcı arama terimini girdiğinde değişiklik geri çağırma fonksiyonu tetiklenmekte ve arama gerçekleştirme metodu çağrılmaktadır. Metod öncelikle girilen metnin temizlenip boş olup olmadığını kontrol etmektedir. Boş sorgu durumunda arama sonuçları sıfırlanmakta ve işlem sonlandırılmaktadır. Geçerli bir sorgu için durum güncelleme ile arama yapılıyor değişkeni doğru yapılarak yükleniyor göstergesi aktif edilmektedir.

Veritabanı yardımcısı sınıfının etikete göre arama metodu uygulamanın en karmaşık veritabanı sorgularından birini barındırmaktadır. Bu sorgu fotoğraflar, fotoğraf-etiket ilişki ve etiketler olmak üzere üç tabloyu iç birleştirme işlemi ile birleştirmektedir. Fotoğraflar tablosu fotoğrafların temel bilgilerini, etiketler tablosu etiket adlarını, fotoğraf-etiket tablosu ise bu ikisi arasındaki çoka-çok ilişkiyi saklayan bağlantı tablosudur.

Sorgu koşul ifadesinde etiket adının arama terimini içerip içermediği kontrol edilmektedir. Bu arama yaklaşımı kelimenin herhangi bir yerinde eşleşme olmasına izin vermektedir. Örneğin "kedi" araması hem "kedi" hem "kediler" hem de "yavru kedi" etiketlerini eşleştirecektir. Ayrıca silinme bayrağı sıfır koşulu ile çöp kutusundaki fotoğrafların sonuçlara dahil edilmemesi sağlanmaktadır.

Sonuçlar güvenilirlik sıralaması ile en yüksek güvenilirlik skoruna sahip fotoğraflar önce gelecek şekilde düzenlenmektedir. Maksimum yüz sonuç sınırlaması ile performans korunmaktadır. Sorgu sonuçları dosya yolu, güvenilirlik ve etiket adı bilgilerini içeren veri yapısı olarak döndürülmektedir.

Arama sonuçları sonuç listesi değişkenine atandıktan sonra durum güncelleme ile kullanıcı arayüzü güncellenmektedir. Sonuçlar ızgara görünüm oluşturucu bileşeni ile ızgara düzeninde gösterilmekte ve her fotoğraf kartının köşesinde eşleşen etiketin güvenilirlik yüzdesi görüntülenmektedir.

---

### 5.2.4 Kamera ile Fotoğraf Çekme

**Şekil 5.12:** Kamera ile Fotoğraf Çekme Sıralı Diyagramı

Kamera ile fotoğraf çekme senaryosu kullanıcının uygulama içinden doğrudan yeni görüntü oluşturmasını sağlamaktadır. Bu işlem ana ekran, görüntü seçici, etiketleme servisi ve veritabanı yardımcısı bileşenlerinin koordineli çalışmasını gerektirmektedir. Süreç ana ekranın sağ alt köşesinde bulunan yüzen eylem butonu bileşenine tıklanmasıyla başlatılmaktadır.

Kullanıcı butona tıkladığında kamera açma metodu çağrılmaktadır. İlk adımda görüntü seçici kütüphanesinin görüntü seçme metodu kamera kaynağı parametresi ile çağrılarak sistem kamerası aktif edilmektedir. Bu çağrıda görüntü kalitesi parametresi seksen beş olarak ayarlanarak dosya boyutu optimize edilmektedir. Görüntü seçici kütüphanesi Android için kamera izni kontrolünü otomatik olarak yönetmektedir.

Kullanıcı fotoğraf çektiğinde görüntü dosya nesnesi olarak döndürülmektedir. Fotoğrafın dosya adı görüntü öneki ve milisaniye cinsinden zaman damgası değeri ile benzersiz olarak oluşturulmaktadır. Hedef klasör olarak harici depolama alanındaki özel uygulama klasörü belirlenmektedir. Klasör yoksa dizin sınıfının oluşturma metodu ile özyinelemeli parametresi doğru olarak çağrılarak oluşturulmaktadır.

Fotoğraf dosya sınıfının kopyalama metodu ile hedef konuma kaydedilmektedir. Ardından fotoğraf yöneticisi düzenleyicisinin görüntüyü yol ile kaydetme metodu çağrılarak görüntü Android medya deposu veritabanına eklenmektedir. Bu işlem sayesinde fotoğraf diğer galeri uygulamalarından da erişilebilir hale gelmektedir.

Veritabanı kaydı için fotoğraf modeli oluşturularak veritabanı yardımcısı sınıfının fotoğraf ekleme metodu çağrılmaktadır. Model dosya yolu, dosya adı ve çekim tarihi bilgilerini içermektedir. Ardından etiketleme servisi çağrılarak fotoğraf yapay zeka ile etiketlenmekte ve sonuçlar etiket kaydetme metodu ile kaydedilmektedir. Yüz algılama servisi çağrılarak yüz algılama gerçekleştirilmektedir. Son olarak fotoğraf yükleme metodu çağrılarak galeri listesi güncellenmekte ve yeni fotoğraf kullanıcıya gösterilmektedir.

---

### 5.2.5 Albüm Oluşturma ve Fotoğraf Ekleme

**Şekil 5.13:** Albüm Oluşturma Sıralı Diyagramı

Albüm oluşturma ve fotoğraf ekleme senaryosu kullanıcının fotoğraflarını tematik koleksiyonlar halinde organize etmesini sağlamaktadır. Bu işlem albümler ekranı, uyarı diyaloğu ve veritabanı yardımcısı bileşenlerinin etkileşimini içermektedir. Senaryo iki ana akıştan oluşmaktadır: albüm oluşturma ve fotoğrafı albüme ekleme.

Albüm oluşturma süreci albümler ekranındaki artı butonuna tıklanmasıyla başlatılmaktadır. Butona tıklandığında diyalog gösterme fonksiyonu ile uyarı diyaloğu bileşeni görüntülenmektedir. Diyalog içinde metin giriş alanı bileşeni ile kullanıcıdan albüm adı istenmektedir. Metin giriş denetleyicisi aracılığıyla girilen metin alınmakta ve doğrulama işlemi yapılmaktadır.

Kullanıcı oluştur butonuna tıkladığında veritabanı yardımcısı sınıfının albüm oluşturma metodu çağrılmaktadır. Bu metod albümler tablosuna yeni kayıt eklemekte olup ad, açıklama, kapak fotoğrafı kimliği, oluşturulma tarihi ve güncellenme tarihi sütunları doldurulmaktadır. Metod başarılı olduğunda oluşturulan albümün kimlik numarası döndürülmektedir. Kullanıcıya bildirim çubuğu bileşeni ile başarı bildirimi gösterilmekte ve albüm yükleme metodu ile albüm listesi güncellenmektedir.

Fotoğrafı albüme ekleme işlemi fotoğraf görüntüleyici ekranından gerçekleştirilmektedir. Kullanıcı paylaş butonuna tıkladığında modal alt sayfa gösterme fonksiyonu ile mevcut albümlerin listesi gösterilmektedir. Kullanıcı hedef albümü seçtiğinde fotoğrafı albüme ekleme metodu çağrılmaktadır. Bu metod albüm-fotoğraf bağlantı tablosuna albüm kimliği, fotoğraf kimliği, ekleme tarihi ve sıralama değeri sütunlarını içeren yeni kayıt eklemektedir.

Çoka-çok ilişki tasarımı sayesinde bir fotoğraf birden fazla albüme eklenebilmektedir. Bu durumda fotoğrafın fiziksel kopyası oluşturulmamakta yalnızca mantıksal referanslar saklanmaktadır. Albüm silindiğinde kademeli silme kuralı gereği yalnızca ilişki kayıtları kaldırılmakta fotoğrafların kendisi fotoğraflar tablosunda korunmaktadır.

---

### 5.2.6 Yapay Zeka ile Yüz Algılama

**Şekil 5.14:** Yüz Algılama Sıralı Diyagramı

Yüz algılama özelliği Google yapay zeka kütüphanesinin yüz algılama modülü kullanılarak gerçekleştirilmektedir. Bu senaryo ana ekran, yüz algılama servisi, yapay zeka modülü ve veritabanı yardımcısı bileşenlerinin etkileşimini içermektedir. İşlem arka plan yüz tarama metodu aracılığıyla arka planda asenkron olarak yürütülmektedir.

Yüz algılama servisi tek örnek tasarım deseni ile oluşturulmuştur. Yüz algılayıcı nesnesi yüz algılayıcı seçenekleri ile yapılandırılmaktadır. Doğru performans modu seçilerek yüksek doğruluk sağlanmakta, yüz işaretlerini etkinleştir parametresi doğru olarak ayarlanarak göz, burun ve ağız noktaları tespit edilmektedir. Sınıflandırmayı etkinleştir parametresi ile gülümseme ve göz açıklığı olasılıkları hesaplanmaktadır. Minimum yüz boyutu değeri sıfır nokta bir olarak belirlenerek fotoğrafın en az yüzde onunu kaplayan yüzler algılanmaktadır.

Her fotoğraf için öncelikle veritabanı yardımcısı sınıfının fotoğraf yüz tarandı mı metodu çağrılarak daha önce taranıp taranmadığı kontrol edilmektedir. Taranmamış fotoğraflar için yüzleri algıla ve kaydet metodu çağrılmaktadır. Bu metod dosya yolundan giriş görüntüsü oluşturma ile görüntüyü yapay zeka formatına dönüştürmekte ve yüz algılayıcının görüntü işleme metodu ile yüz algılama işlemini gerçekleştirmektedir.

Algılanan her yüz için yüz nesnesi oluşturulmaktadır. Sınırlayıcı kutu bilgisi sol, üst, genişlik ve yükseklik değerlerini içeren veri yapısında saklanmaktadır. Yüz verileri içinde gülümseme olasılığı, sol göz açık olasılığı, sağ göz açık olasılığı, baş dikey açısı ve baş yatay açısı özellikleri kaydedilmektedir. Bu veriler veritabanı yardımcısı sınıfının yüz ekleme metodu ile yüzler tablosuna eklenmektedir.

Bir fotoğrafta birden fazla yüz tespit edilebilmekte ve her biri ayrı kayıt olarak saklanmaktadır. Yüzler başlangıçta herhangi bir kişiye atanmamakta olup kullanıcı manuel olarak gruplama yapabilmektedir. Kişiler tablosu bu gruplama için tasarlanmış olup yüzler tablosundaki kişi kimliği sütunu ile ilişkilendirilmektedir.

---

### 5.2.7 Fotoğrafı Favorilere Ekleme

**Şekil 5.15:** Favorilere Ekleme Sıralı Diyagramı

Favorilere ekleme senaryosu kullanıcının beğendiği fotoğrafları özel bir koleksiyon olarak işaretlemesini sağlamaktadır. Bu işlem fotoğraf görüntüleyici ekranı ve veritabanı yardımcısı bileşenlerinin etkileşimini içermektedir. Süreç tam ekran görüntüleyicide kalp simgesine tıklanmasıyla başlatılmaktadır.

Fotoğraf görüntüleyici ekranı başlatıldığında yaşam döngüsü başlatma metodunda favori kontrol fonksiyonu çağrılmaktadır. Bu fonksiyon veritabanı yardımcısı sınıfının favori mi metodu ile mevcut fotoğrafın favori durumunu sorgulamaktadır. Metod fotoğraflar tablosunda favori bayrağı sütununu kontrol ederek mantıksal değer döndürmektedir. Sonuç favori mi değişkenine atanarak kalp simgesinin dolu veya boş gösterilmesi belirlenmektedir.

Kullanıcı kalp simgesine tıkladığında favori durumunu değiştir metodu çağrılmaktadır. Mevcut duruma göre favorilere ekle veya favorilerden çıkar metodu seçilmektedir. Favorilere ekle metodu fotoğraflar tablosunda favori bayrağı sütununu bir olarak, favorilerden çıkar ise sıfır olarak güncellemektedir. Her iki metod da güncellenme tarihi sütununu güncel zaman damgasıyla güncellemektedir.

Güncelleme işlemi başarılı olduğunda durum güncelleme ile favori mi değişkeni tersine çevrilerek kullanıcı arayüzü anında güncellenmektedir. Kullanıcıya bildirim çubuğu bileşeni ile favorilere eklendi veya favorilerden çıkarıldı bildirimi gösterilmektedir. Favoriler ekranı favori fotoğrafları getir metodu ile favori bayrağı bir ve silinme bayrağı sıfır koşulunu sağlayan tüm fotoğrafları listelemektedir.

---

### 5.2.8 Fotoğraf Silme ve Geri Yükleme

**Şekil 5.16:** Fotoğraf Silme ve Geri Yükleme Sıralı Diyagramı

Fotoğraf silme ve geri yükleme senaryosu yumuşak silme yaklaşımı ile tasarlanmıştır. Bu mimari kullanıcının yanlışlıkla sildiği verileri kurtarabilmesine olanak tanımaktadır. Senaryo fotoğraf görüntüleyici ekranı, çöp kutusu ekranı ve veritabanı yardımcısı bileşenlerinin etkileşimini içermektedir.

Silme işlemi fotoğraf görüntüleyici ekranında çöp kutusu simgesine tıklanmasıyla başlatılmaktadır. Fotoğraf silme metodu öncelikle uyarı diyaloğu ile kullanıcı onayı almaktadır. Onay verildiğinde veritabanı yardımcısı sınıfının çöpe taşı metodu çağrılmaktadır. Bu metod fotoğraflar tablosunda silinme bayrağı sütununu bir olarak işaretlemekte ve silinme tarihi sütununa silme zaman damgasını yazmaktadır. Fiziksel dosya silinmemekte yalnızca veritabanı bayrağı güncellenmektedir.

Fotoğraf veritabanında mevcut değilse metod önce yeni kayıt oluşturmakta sonra silme işaretini uygulamaktadır. Bu yaklaşım fotoğraf yöneticisi ile yüklenen ancak henüz veritabanına kaydedilmemiş fotoğrafların da çöp kutusuna taşınabilmesini sağlamaktadır. İşlem başarılı olduğunda kullanıcıya çöp kutusuna taşındı bildirimi gösterilmektedir.

Çöp kutusu ekranı çöp fotoğraflarını getir metodu ile silinme bayrağı bir koşulunu sağlayan tüm fotoğrafları silinme tarihine göre listelemektedir. Kullanıcı bir fotoğrafa tıkladığında modal alt sayfa gösterme fonksiyonu ile geri yükle ve kalıcı olarak sil seçenekleri sunulmaktadır.

Geri yükleme için çöpten geri yükle metodu çağrılmaktadır. Bu metod silinme bayrağı sütununu sıfır olarak güncellemekte ve silinme tarihi değerini boş yapmaktadır. Fotoğraf ana galeriye geri döndürülmekte ve çöp kutusu ekranı listesinden kaldırılmaktadır.

Kalıcı silme için kullanıcıdan ikinci bir onay alınmaktadır. Onay verildiğinde kalıcı silme metodu ile veritabanı kaydı silinmekte ve fotoğraf yöneticisi düzenleyicisinin kimliklerle silme metodu ile medya deposu kaydı kaldırılmaktadır. Bu işlem geri alınamaz olduğundan kullanıcı açıkça uyarılmaktadır.
