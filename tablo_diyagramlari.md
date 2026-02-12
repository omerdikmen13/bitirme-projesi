# VERİTABANI TABLO DİYAGRAMLARI

## 4.3.1. Photos Tablosu

```mermaid
erDiagram
    PHOTOS {
        int id PK "Auto Increment"
        text file_path UK "Unique, Not Null"
        text file_name "File Name"
        int width "Pixels"
        int height "Pixels"
        int size_bytes "File Size"
        text date_taken "ISO 8601"
        text created_at "Timestamp"
        text updated_at "Timestamp"
        int is_favorite "0 or 1"
        int is_deleted "Soft Delete"
        text deleted_at "Deletion Time"
    }
```

**İndeksler:**
- `idx_photos_date` - Tarihe göre azalan sıralama
- `idx_photos_favorite` - Favori durumuna göre
- `idx_photos_deleted` - Silinme durumuna göre

---

## 4.3.2. Labels Tablosu

```mermaid
erDiagram
    LABELS {
        int id PK "Auto Increment"
        text name UK "Unique, Lowercase"
        text name_tr "Turkish Translation"
        text category "Animal, Vehicle, etc"
        text created_at "Timestamp"
    }
```

**İndeksler:**
- `idx_labels_name` - İngilizce isim
- `idx_labels_name_tr` - Türkçe isim

---

## 4.3.3. Photo_labels Tablosu

```mermaid
erDiagram
    PHOTO_LABELS {
        int photo_id FK "Cascade Delete"
        int label_id FK "Cascade Delete"
        real confidence "0.0 to 1.0"
        text created_at "Timestamp"
    }
```

**Birincil Anahtar:** (photo_id, label_id) - Bileşik Anahtar

**İndeksler:**
- `idx_photo_labels_photo` - Fotoğraf kimliği
- `idx_photo_labels_label` - Etiket kimliği

---

## 4.3.4. Albums Tablosu

```mermaid
erDiagram
    ALBUMS {
        int id PK "Auto Increment"
        text name "Album Name"
        text description "Optional"
        int cover_photo_id FK "Set NULL on Delete"
        text created_at "Timestamp"
        text updated_at "Timestamp"
    }
```

---

## 4.3.5. Album_photos Tablosu

```mermaid
erDiagram
    ALBUM_PHOTOS {
        int album_id FK "Cascade Delete"
        int photo_id FK "Cascade Delete"
        text added_at "Timestamp"
        int sort_order "Manual Ordering"
    }
```

**Birincil Anahtar:** (album_id, photo_id) - Bileşik Anahtar

**İndeksler:**
- `idx_album_photos_album` - Albüm kimliği

---

## 4.3.6. Persons Tablosu

```mermaid
erDiagram
    PERSONS {
        int id PK "Auto Increment"
        text name "User Assigned"
        text thumbnail_path "Face Thumbnail"
        int photo_count "Denormalized"
        text created_at "Timestamp"
        text updated_at "Timestamp"
    }
```

---

## 4.3.7. Faces Tablosu

```mermaid
erDiagram
    FACES {
        int id PK "Auto Increment"
        text photo_path "File Path"
        int person_id FK "Set NULL on Delete"
        text bounding_box "JSON Coordinates"
        text face_data "JSON Probabilities"
        int is_face_scanned "Scan Status"
        text created_at "Timestamp"
    }
```

**İndeksler:**
- `idx_faces_photo` - Fotoğraf yolu
- `idx_faces_person` - Kişi kimliği

---

## Genel ER Diyagramı

Aşağıdaki diyagram tüm tabloları ve aralarındaki ilişkileri göstermektedir:

![Veritabanı ER Diyagramı](C:/Users/MONSTER/.gemini/antigravity/brain/58672e71-211f-4d9d-a580-e7dd4eac931f/uploaded_image_1769102454302.png)
