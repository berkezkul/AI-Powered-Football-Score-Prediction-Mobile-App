#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
🔬 Advanced Football Match Prediction Model
Author: Berke Özkul
Description: Gelişmiş makine öğrenmesi modeli - Daha doğru tahminler
"""

import pandas as pd
import numpy as np
from sklearn.ensemble import RandomForestRegressor, GradientBoostingRegressor
from sklearn.model_selection import train_test_split, cross_val_score
from sklearn.preprocessing import StandardScaler, LabelEncoder
from sklearn.metrics import mean_absolute_error, mean_squared_error
import joblib
import json
from datetime import datetime, timedelta
from collections import defaultdict
import warnings
warnings.filterwarnings('ignore')

class AdvancedFootballPredictor:
    """
    Gelişmiş futbol tahmin modeli
    - Takım performans analizi
    - Form analizi
    - Ev sahibi avantajı
    - Sezonsal trendler
    - Ensemble modeling
    """
    
    def __init__(self):
        self.home_model = None
        self.away_model = None
        self.result_model = None
        self.scaler = StandardScaler()
        self.team_encoder = LabelEncoder()
        
        # Takım istatistikleri
        self.team_stats = defaultdict(lambda: {
            'home_goals_for': [],
            'home_goals_against': [],
            'away_goals_for': [],
            'away_goals_against': [],
            'home_wins': 0,
            'home_draws': 0,
            'home_losses': 0,
            'away_wins': 0,
            'away_draws': 0,
            'away_losses': 0,
            'recent_form': [],
            'head_to_head': defaultdict(list)
        })
        
        self.is_trained = False
        self.feature_importance = {}
        
    def load_and_prepare_data(self, data_files):
        """Tüm sezon verilerini yükle ve birleştir"""
        print("📊 Gelişmiş veri analizi başlıyor...")
        
        all_data = []
        
        for file_path in data_files:
            try:
                df = pd.read_csv(file_path)
                print(f"📁 {file_path}: {len(df)} maç yüklendi")
                all_data.append(df)
            except Exception as e:
                print(f"❌ {file_path} yüklenirken hata: {e}")
                
        if not all_data:
            raise ValueError("Hiç veri yüklenemedi!")
            
        # Tüm verileri birleştir
        combined_df = pd.concat(all_data, ignore_index=True)
        print(f"✅ Toplam {len(combined_df)} maç yüklendi")
        
        return self._process_data(combined_df)
    
    def _process_data(self, df):
        """Veriyi işle ve özellik çıkarımı yap"""
        print("🔧 Veri işleme ve özellik çıkarımı...")
        
        # Temel temizlik
        df = df.dropna(subset=['HomeTeam', 'AwayTeam', 'FTHG', 'FTAG'])
        
        # Tarih işleme
        if 'Date' in df.columns:
            df['Date'] = pd.to_datetime(df['Date'], errors='coerce')
            df = df.dropna(subset=['Date'])
            df = df.sort_values('Date')
            
        # Takım encoding
        all_teams = list(set(df['HomeTeam'].unique()) | set(df['AwayTeam'].unique()))
        self.team_encoder.fit(all_teams)
        
        # Özellik çıkarımı
        processed_data = []
        
        for idx, row in df.iterrows():
            home_team = row['HomeTeam']
            away_team = row['AwayTeam']
            home_goals = int(row['FTHG'])
            away_goals = int(row['FTAG'])
            
            # Maç sonucu
            if home_goals > away_goals:
                result = 'H'  # Home win
            elif home_goals < away_goals:
                result = 'A'  # Away win
            else:
                result = 'D'  # Draw
            
            # Takım istatistiklerini güncelle (maç öncesi duruma göre)
            home_stats = self._get_team_stats_before_match(home_team, idx, df)
            away_stats = self._get_team_stats_before_match(away_team, idx, df)
            
            # Head-to-head geçmişi
            h2h_stats = self._get_head_to_head_stats(home_team, away_team, idx, df)
            
            # Özellik vektörü oluştur
            features = {
                'home_team_encoded': self.team_encoder.transform([home_team])[0],
                'away_team_encoded': self.team_encoder.transform([away_team])[0],
                
                # Ev sahibi takım istatistikleri
                'home_avg_goals_for': home_stats['avg_goals_for'],
                'home_avg_goals_against': home_stats['avg_goals_against'],
                'home_win_rate': home_stats['win_rate'],
                'home_recent_form': home_stats['recent_form'],
                'home_home_advantage': home_stats['home_advantage'],
                
                # Deplasman takımı istatistikleri
                'away_avg_goals_for': away_stats['avg_goals_for'],
                'away_avg_goals_against': away_stats['avg_goals_against'],
                'away_win_rate': away_stats['win_rate'],
                'away_recent_form': away_stats['recent_form'],
                'away_away_performance': away_stats['away_performance'],
                
                # Head-to-head
                'h2h_home_wins': h2h_stats['home_wins'],
                'h2h_away_wins': h2h_stats['away_wins'],
                'h2h_draws': h2h_stats['draws'],
                'h2h_avg_total_goals': h2h_stats['avg_total_goals'],
                
                # Sezonsal faktörler
                'month': row.get('Date').month if 'Date' in row and pd.notna(row['Date']) else 6,
                'day_of_week': row.get('Date').weekday() if 'Date' in row and pd.notna(row['Date']) else 5,
                
                # Hedef değişkenler
                'target_home_goals': home_goals,
                'target_away_goals': away_goals,
                'target_result': result
            }
            
            processed_data.append(features)
            
            # Takım istatistiklerini güncelle (maç sonrası)
            self._update_team_stats_after_match(home_team, away_team, home_goals, away_goals, result)
            
        print(f"✅ {len(processed_data)} maç işlendi ve {len(features)-3} özellik çıkarıldı")
        return processed_data
    
    def _get_team_stats_before_match(self, team, match_idx, df):
        """Maç öncesi takım istatistiklerini hesapla"""
        # Son N maçı al
        recent_matches = []
        
        for i in range(match_idx):
            row = df.iloc[i]
            if row['HomeTeam'] == team or row['AwayTeam'] == team:
                recent_matches.append(row)
        
        # Son 10 maçı kullan
        recent_matches = recent_matches[-10:]
        
        if not recent_matches:
            return {
                'avg_goals_for': 1.5,
                'avg_goals_against': 1.5,
                'win_rate': 0.5,
                'recent_form': 0.5,
                'home_advantage': 0.0,
                'away_performance': 0.0
            }
        
        goals_for = []
        goals_against = []
        results = []
        home_results = []
        away_results = []
        
        for match in recent_matches:
            if match['HomeTeam'] == team:
                goals_for.append(match['FTHG'])
                goals_against.append(match['FTAG'])
                if match['FTHG'] > match['FTAG']:
                    results.append(3)  # Win
                    home_results.append(3)
                elif match['FTHG'] < match['FTAG']:
                    results.append(0)  # Loss
                    home_results.append(0)
                else:
                    results.append(1)  # Draw
                    home_results.append(1)
            else:  # Away team
                goals_for.append(match['FTAG'])
                goals_against.append(match['FTHG'])
                if match['FTAG'] > match['FTHG']:
                    results.append(3)  # Win
                    away_results.append(3)
                elif match['FTAG'] < match['FTHG']:
                    results.append(0)  # Loss
                    away_results.append(0)
                else:
                    results.append(1)  # Draw
                    away_results.append(1)
        
        return {
            'avg_goals_for': np.mean(goals_for) if goals_for else 1.5,
            'avg_goals_against': np.mean(goals_against) if goals_against else 1.5,
            'win_rate': len([r for r in results if r == 3]) / len(results) if results else 0.5,
            'recent_form': np.mean(results) / 3 if results else 0.5,  # 0-1 scale
            'home_advantage': np.mean(home_results) / 3 if home_results else 0.5,
            'away_performance': np.mean(away_results) / 3 if away_results else 0.5
        }
    
    def _get_head_to_head_stats(self, home_team, away_team, match_idx, df):
        """İki takım arasındaki geçmiş karşılaşmaları analiz et"""
        h2h_matches = []
        
        for i in range(match_idx):
            row = df.iloc[i]
            if ((row['HomeTeam'] == home_team and row['AwayTeam'] == away_team) or
                (row['HomeTeam'] == away_team and row['AwayTeam'] == home_team)):
                h2h_matches.append(row)
        
        if not h2h_matches:
            return {
                'home_wins': 0,
                'away_wins': 0,
                'draws': 0,
                'avg_total_goals': 2.5
            }
        
        home_wins = 0
        away_wins = 0
        draws = 0
        total_goals = []
        
        for match in h2h_matches:
            total_goals.append(match['FTHG'] + match['FTAG'])
            
            if match['HomeTeam'] == home_team:
                if match['FTHG'] > match['FTAG']:
                    home_wins += 1
                elif match['FTHG'] < match['FTAG']:
                    away_wins += 1
                else:
                    draws += 1
            else:  # home_team was away
                if match['FTAG'] > match['FTHG']:
                    home_wins += 1
                elif match['FTAG'] < match['FTHG']:
                    away_wins += 1
                else:
                    draws += 1
        
        total_matches = len(h2h_matches)
        return {
            'home_wins': home_wins / total_matches,
            'away_wins': away_wins / total_matches,
            'draws': draws / total_matches,
            'avg_total_goals': np.mean(total_goals) if total_goals else 2.5
        }
    
    def _update_team_stats_after_match(self, home_team, away_team, home_goals, away_goals, result):
        """Maç sonrası takım istatistiklerini güncelle"""
        # Bu fonksiyon gelecekte kullanılabilir
        pass
    
    def train_models(self, processed_data):
        """Ensemble modelleri eğit"""
        print("🤖 Gelişmiş makine öğrenmesi modelleri eğitiliyor...")
        
        # Veriyi DataFrame'e çevir
        df = pd.DataFrame(processed_data)
        
        # Özellik ve hedef değişkenleri ayır
        feature_cols = [col for col in df.columns if not col.startswith('target_')]
        X = df[feature_cols]
        
        y_home = df['target_home_goals']
        y_away = df['target_away_goals']
        y_result = df['target_result']
        
        # Result encoding
        result_encoder = LabelEncoder()
        y_result_encoded = result_encoder.fit_transform(y_result)
        
        # Veriyi böl
        X_train, X_test, y_home_train, y_home_test = train_test_split(
            X, y_home, test_size=0.2, random_state=42
        )
        _, _, y_away_train, y_away_test = train_test_split(
            X, y_away, test_size=0.2, random_state=42
        )
        _, _, y_result_train, y_result_test = train_test_split(
            X, y_result_encoded, test_size=0.2, random_state=42
        )
        
        # Özellikleri scale et
        X_train_scaled = self.scaler.fit_transform(X_train)
        X_test_scaled = self.scaler.transform(X_test)
        
        # Home goals modeli
        print("🏠 Ev sahibi gol modeli eğitiliyor...")
        self.home_model = GradientBoostingRegressor(
            n_estimators=200,
            learning_rate=0.1,
            max_depth=6,
            random_state=42
        )
        self.home_model.fit(X_train_scaled, y_home_train)
        
        # Away goals modeli
        print("✈️ Deplasman gol modeli eğitiliyor...")
        self.away_model = GradientBoostingRegressor(
            n_estimators=200,
            learning_rate=0.1,
            max_depth=6,
            random_state=42
        )
        self.away_model.fit(X_train_scaled, y_away_train)
        
        # Result modeli
        print("🎯 Sonuç tahmin modeli eğitiliyor...")
        self.result_model = RandomForestRegressor(
            n_estimators=300,
            max_depth=8,
            random_state=42
        )
        self.result_model.fit(X_train_scaled, y_result_train)
        
        # Model performansını değerlendir
        self._evaluate_models(X_test_scaled, y_home_test, y_away_test, y_result_test)
        
        # Feature importance
        self._calculate_feature_importance(feature_cols)
        
        self.is_trained = True
        print("✅ Tüm modeller başarıyla eğitildi!")
    
    def _evaluate_models(self, X_test, y_home_test, y_away_test, y_result_test):
        """Model performansını değerlendir"""
        print("\n📊 Model Performans Değerlendirmesi:")
        print("=" * 50)
        
        # Home goals prediction
        home_pred = self.home_model.predict(X_test)
        home_mae = mean_absolute_error(y_home_test, home_pred)
        home_rmse = np.sqrt(mean_squared_error(y_home_test, home_pred))
        
        print(f"🏠 Ev Sahibi Gol Tahmini:")
        print(f"   MAE: {home_mae:.3f}")
        print(f"   RMSE: {home_rmse:.3f}")
        
        # Away goals prediction
        away_pred = self.away_model.predict(X_test)
        away_mae = mean_absolute_error(y_away_test, away_pred)
        away_rmse = np.sqrt(mean_squared_error(y_away_test, away_pred))
        
        print(f"✈️ Deplasman Gol Tahmini:")
        print(f"   MAE: {away_mae:.3f}")
        print(f"   RMSE: {away_rmse:.3f}")
        
        # Result prediction accuracy
        result_pred = self.result_model.predict(X_test)
        result_accuracy = np.mean(np.abs(y_result_test - result_pred) < 0.5)  # Classification accuracy
        
        print(f"🎯 Sonuç Tahmini:")
        print(f"   Doğruluk: {result_accuracy:.3f}")
        
        # Overall confidence score
        overall_confidence = (1 - (home_mae + away_mae) / 4) * result_accuracy
        print(f"\n🎖️ Genel Güven Skoru: {overall_confidence:.3f}")
        
        return {
            'home_mae': home_mae,
            'away_mae': away_mae,
            'result_accuracy': result_accuracy,
            'confidence': overall_confidence
        }
    
    def _calculate_feature_importance(self, feature_cols):
        """Özellik önemini hesapla"""
        self.feature_importance = {
            'home_goals': dict(zip(feature_cols, self.home_model.feature_importances_)),
            'away_goals': dict(zip(feature_cols, self.away_model.feature_importances_)),
            'result': dict(zip(feature_cols, self.result_model.feature_importances_))
        }
        
        print("\n🔍 En Önemli Özellikler:")
        print("=" * 50)
        
        for model_name, importances in self.feature_importance.items():
            print(f"\n{model_name.title()} Model:")
            sorted_features = sorted(importances.items(), key=lambda x: x[1], reverse=True)[:5]
            for feature, importance in sorted_features:
                print(f"   {feature}: {importance:.3f}")
    
    def predict_match(self, home_team, away_team):
        """Gelişmiş maç tahmini"""
        if not self.is_trained:
            raise ValueError("Model henüz eğitilmedi!")
        
        print(f"🔮 Gelişmiş tahmin: {home_team} vs {away_team}")
        
        # Takım encoding
        try:
            home_encoded = self.team_encoder.transform([home_team])[0]
            away_encoded = self.team_encoder.transform([away_team])[0]
        except ValueError:
            print(f"⚠️ Bilinmeyen takım: {home_team} veya {away_team}")
            return self._generate_default_prediction(home_team, away_team)
        
        # Son performans istatistiklerini al (sahte veri - gerçek implementasyonda historical data kullanılacak)
        features = self._generate_prediction_features(home_team, away_team, home_encoded, away_encoded)
        
        # Tahmin yap
        X_pred = np.array([list(features.values())])
        X_pred_scaled = self.scaler.transform(X_pred)
        
        home_goals_pred = max(0, self.home_model.predict(X_pred_scaled)[0])
        away_goals_pred = max(0, self.away_model.predict(X_pred_scaled)[0])
        result_pred = self.result_model.predict(X_pred_scaled)[0]
        
        # Sonuç kategorisini belirle
        if result_pred < 0.5:
            result = 'A'  # Away win
            result_text = 'Deplasman Galibiyeti'
        elif result_pred > 1.5:
            result = 'H'  # Home win
            result_text = 'Ev Sahibi Galibiyeti'
        else:
            result = 'D'  # Draw
            result_text = 'Beraberlik'
        
        # Olasılık hesaplama (Poisson distribution based)
        home_prob = self._calculate_win_probability(home_goals_pred, away_goals_pred, 'home')
        draw_prob = self._calculate_win_probability(home_goals_pred, away_goals_pred, 'draw')
        away_prob = self._calculate_win_probability(home_goals_pred, away_goals_pred, 'away')
        
        # Normalize probabilities
        total_prob = home_prob + draw_prob + away_prob
        home_prob /= total_prob
        draw_prob /= total_prob
        away_prob /= total_prob
        
        # Güven skorunu hesapla
        confidence = max(home_prob, draw_prob, away_prob)
        
        return {
            'home_goals': round(home_goals_pred),
            'away_goals': round(away_goals_pred),
            'result': result,
            'result_text': result_text,
            'probabilities': {
                'home': round(home_prob, 3),
                'draw': round(draw_prob, 3),
                'away': round(away_prob, 3)
            },
            'confidence': round(confidence, 3),
            'model_type': 'advanced'
        }
    
    def _generate_prediction_features(self, home_team, away_team, home_encoded, away_encoded):
        """Tahmin için özellik vektörü oluştur"""
        # Gerçek implementasyonda bu veriler veritabanından gelecek
        # Şimdilik realistic değerler üretelim
        
        return {
            'home_team_encoded': home_encoded,
            'away_team_encoded': away_encoded,
            'home_avg_goals_for': np.random.normal(1.5, 0.3),
            'home_avg_goals_against': np.random.normal(1.2, 0.3),
            'home_win_rate': np.random.uniform(0.3, 0.7),
            'home_recent_form': np.random.uniform(0.4, 0.8),
            'home_home_advantage': np.random.uniform(0.5, 0.8),
            'away_avg_goals_for': np.random.normal(1.3, 0.3),
            'away_avg_goals_against': np.random.normal(1.4, 0.3),
            'away_win_rate': np.random.uniform(0.3, 0.7),
            'away_recent_form': np.random.uniform(0.4, 0.8),
            'away_away_performance': np.random.uniform(0.3, 0.6),
            'h2h_home_wins': np.random.uniform(0.2, 0.6),
            'h2h_away_wins': np.random.uniform(0.2, 0.6),
            'h2h_draws': np.random.uniform(0.2, 0.4),
            'h2h_avg_total_goals': np.random.normal(2.5, 0.5),
            'month': datetime.now().month,
            'day_of_week': datetime.now().weekday()
        }
    
    def _calculate_win_probability(self, home_goals, away_goals, outcome):
        """Poisson distribution kullanarak kazanma olasılığını hesapla"""
        from math import exp, factorial
        
        def poisson_prob(k, lam):
            return (lam ** k) * exp(-lam) / factorial(int(k))
        
        total_prob = 0
        
        for h in range(6):  # 0-5 gol
            for a in range(6):  # 0-5 gol
                prob = poisson_prob(h, home_goals) * poisson_prob(a, away_goals)
                
                if outcome == 'home' and h > a:
                    total_prob += prob
                elif outcome == 'away' and a > h:
                    total_prob += prob
                elif outcome == 'draw' and h == a:
                    total_prob += prob
        
        return total_prob
    
    def _generate_default_prediction(self, home_team, away_team):
        """Bilinmeyen takımlar için varsayılan tahmin"""
        return {
            'home_goals': 1,
            'away_goals': 1,
            'result': 'D',
            'result_text': 'Beraberlik',
            'probabilities': {
                'home': 0.333,
                'draw': 0.334,
                'away': 0.333
            },
            'confidence': 0.334,
            'model_type': 'default'
        }
    
    def save_model(self, path):
        """Modeli kaydet"""
        if not self.is_trained:
            raise ValueError("Model eğitilmedi!")
        
        model_data = {
            'home_model': self.home_model,
            'away_model': self.away_model,
            'result_model': self.result_model,
            'scaler': self.scaler,
            'team_encoder': self.team_encoder,
            'feature_importance': self.feature_importance,
            'is_trained': True
        }
        
        joblib.dump(model_data, path)
        print(f"✅ Gelişmiş model kaydedildi: {path}")
    
    def load_model(self, path):
        """Modeli yükle"""
        try:
            model_data = joblib.load(path)
            
            self.home_model = model_data['home_model']
            self.away_model = model_data['away_model']
            self.result_model = model_data['result_model']
            self.scaler = model_data['scaler']
            self.team_encoder = model_data['team_encoder']
            self.feature_importance = model_data.get('feature_importance', {})
            self.is_trained = model_data['is_trained']
            
            print(f"✅ Gelişmiş model yüklendi: {path}")
            return True
        except Exception as e:
            print(f"❌ Model yükleme hatası: {e}")
            return False

def main():
    """Ana fonksiyon - Gelişmiş model eğitimi"""
    print("🚀 Gelişmiş Football Prediction Model Eğitimi")
    print("=" * 60)
    
    # Data files
    data_files = [
        '../data/E0 2015-2016.csv',
        '../data/E0 2016-2017.csv',
        '../data/E0 2017-2018.csv',
        '../data/E0 2018-2019.csv'
    ]
    
    try:
        # Model oluştur
        predictor = AdvancedFootballPredictor()
        
        # Veriyi yükle ve işle
        processed_data = predictor.load_and_prepare_data(data_files)
        
        # Modeli eğit
        predictor.train_models(processed_data)
        
        # Test tahminleri
        print("\n🧪 Test Tahminleri:")
        print("=" * 30)
        
        test_matches = [
            ("Arsenal", "Chelsea"),
            ("Liverpool", "Manchester City"),
            ("Tottenham", "Manchester United")
        ]
        
        for home, away in test_matches:
            prediction = predictor.predict_match(home, away)
            print(f"\n{home} vs {away}:")
            print(f"   Skor: {prediction['home_goals']}-{prediction['away_goals']}")
            print(f"   Sonuç: {prediction['result_text']}")
            print(f"   Güven: %{prediction['confidence']*100:.1f}")
            print(f"   Olasılıklar: Ev %{prediction['probabilities']['home']*100:.1f} | "
                  f"Beraberlik %{prediction['probabilities']['draw']*100:.1f} | "
                  f"Deplasman %{prediction['probabilities']['away']*100:.1f}")
        
        # Modeli kaydet
        predictor.save_model('advanced_football_model.pkl')
        
        print("\n🎉 Gelişmiş model başarıyla eğitildi ve kaydedildi!")
        
    except Exception as e:
        print(f"❌ Hata: {e}")
        import traceback
        traceback.print_exc()

if __name__ == "__main__":
    main()
