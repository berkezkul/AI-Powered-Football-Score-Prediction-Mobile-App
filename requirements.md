⚽️ Kullanılabilecek Temel Sütunlar

Skor tahmini için her şeyi değil, anlamlı özellikleri seçmek gerekir. Bu dataset’te öne çıkanlar:

Maç Bilgisi:

HomeTeam, AwayTeam → Takımlar

Date → Sezon trendleri için (ay/hafta bazlı form)

Sonuç Bilgileri (label/target):

FTHG (Full Time Home Goals)

FTAG (Full Time Away Goals)

FTR (Full Time Result: H/D/A → ev sahibi/berabere/deplasman)

İlk Yarı Bilgileri (opsiyonel predictor olabilir):

HTHG, HTAG, HTR

Bahis / İstatistiksel Tahmin Kolonları:

B365H, B365D, B365A (Bet365 oranları → model için önemli predictive feature olabilir)

BbAvH, BbAvD, BbAvA (farklı bahis ortalamaları)

👉 Yani skor tahmini için:
📌 HomeTeam, AwayTeam, Date, HTHG, HTAG, B365H, B365D, B365A → giriş
📌 FTHG, FTAG → çıkış

🛠️ Teknoloji Stack’i

Mobil + Data Science entegre bir proje için şunu öneririm:

Veri Hazırlama (Python tarafı)

pandas → data cleaning

scikit-learn → preprocessing, train/test split

xgboost / lightgbm → güçlü modeller skor tahmininde iyi

keras / pytorch → daha gelişmiş deep learning (ör. LSTM, RNN → zaman serisi trendleri için)

Model

Başlangıçta: Classification (H/D/A tahmini)

Daha ileri seviye: Regression (FTHG, FTAG tahmini → skor bazlı)

Servis Katmanı (Backend)

FastAPI / Flask → modeli REST API olarak deploy et

Mobil Uygulama (Flutter)

Kullanıcı yaklaşan maçları seçsin

API’den tahminleri çeksin

UI’da skor veya kazanma olasılığı göstersin

🚀 Adım Adım Yol Haritası

Veri Ön İşleme

Takım adlarını encode et (OneHotEncoder / LabelEncoder)

Tarihten sezon/ay/hafta çıkar

Eksik değerleri temizle

Feature Engineering

Son 5 maç performansını hesapla (form durumu)

Ev sahibi / deplasman avantajı için binary feature ekle

Bahis oranlarını normalize et

Model Eğitimi

Basit Logistic Regression (H/D/A sınıflandırması)

Ardından XGBoost/LightGBM ile gelişmiş model

Skor tahmini için 2 regresyon modeli: FTHG ve FTAG

Evaluation

Accuracy (H/D/A için)

MAE (gol tahminleri için)

Deployment

Modeli .pkl olarak kaydet

FastAPI ile REST endpoint aç

Flutter → bu API’den tahminleri göster

Mobil UI

Yaklaşan maçları listele

Tahmini skor veya kazanma yüzdesi göster