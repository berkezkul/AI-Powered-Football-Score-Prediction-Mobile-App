#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
⚽ Football Match Score Prediction - Simple Model (Built-in only)
Author: Berke Özkul
Description: Basit makine öğrenmesi modeli (sadece built-in Python)
"""

import csv
import random
import math
from collections import defaultdict, Counter
from simple_data_processing import SimpleFootballDataProcessor

class SimpleFootballPredictor:
    """
    Basit futbol tahmin modeli
    """
    
    def __init__(self):
        self.home_advantage = 0.0
        self.team_strength = {}
        self.team_attack = {}
        self.team_defense = {}
        self.form_weight = 0.3
        self.is_trained = False
        
    def prepare_data(self, processed_data):
        """Veriyi model için hazırlar"""
        print("🔧 Veriyi model için hazırlıyor...")
        
        features = []
        targets = []
        
        for row in processed_data:
            # Özellikler
            feature_vector = [
                row.get('HomeTeam_encoded', 0),
                row.get('AwayTeam_encoded', 0),
                row.get('Month', 6),  # Default 6. ay
                row.get('home_form_avg', 1.5),  # Default ortalama
                row.get('away_form_avg', 1.5),
                row.get('home_form_goals_for', 1),
                row.get('home_form_goals_against', 1),
                row.get('away_form_goals_for', 1),
                row.get('away_form_goals_against', 1),
            ]
            
            # Hedef değişkenler
            target = {
                'home_goals': row['FTHG'],
                'away_goals': row['FTAG'],
                'result': row['FTR_encoded']  # 0=H, 1=D, 2=A
            }
            
            features.append(feature_vector)
            targets.append(target)
        
        print(f"  ✅ {len(features)} özellik vektörü hazırlandı")
        return features, targets
    
    def calculate_team_strengths(self, processed_data):
        """Takım güçlerini hesaplar"""
        print("💪 Takım güçleri hesaplanıyor...")
        
        team_stats = defaultdict(lambda: {
            'matches': 0, 'goals_for': 0, 'goals_against': 0, 
            'points': 0, 'home_matches': 0, 'away_matches': 0
        })
        
        # Takım istatistiklerini hesapla
        for row in processed_data:
            home_team = row['HomeTeam']
            away_team = row['AwayTeam']
            
            # Ev sahibi
            team_stats[home_team]['matches'] += 1
            team_stats[home_team]['home_matches'] += 1
            team_stats[home_team]['goals_for'] += row['FTHG']
            team_stats[home_team]['goals_against'] += row['FTAG']
            
            if row['FTR'] == 'H':
                team_stats[home_team]['points'] += 3
            elif row['FTR'] == 'D':
                team_stats[home_team]['points'] += 1
            
            # Deplasman
            team_stats[away_team]['matches'] += 1
            team_stats[away_team]['away_matches'] += 1
            team_stats[away_team]['goals_for'] += row['FTAG']
            team_stats[away_team]['goals_against'] += row['FTHG']
            
            if row['FTR'] == 'A':
                team_stats[away_team]['points'] += 3
            elif row['FTR'] == 'D':
                team_stats[away_team]['points'] += 1
        
        # Güçleri normalleştir
        for team, stats in team_stats.items():
            if stats['matches'] > 0:
                # Puan ortalaması (0-3 arası)
                self.team_strength[team] = stats['points'] / stats['matches']
                
                # Atak gücü (maç başına gol)
                self.team_attack[team] = stats['goals_for'] / stats['matches']
                
                # Savunma gücü (maç başına yediği gol, düşük=iyi)
                self.team_defense[team] = stats['goals_against'] / stats['matches']
        
        print(f"  ✅ {len(self.team_strength)} takımın gücü hesaplandı")
    
    def calculate_home_advantage(self, processed_data):
        """Ev sahibi avantajını hesaplar"""
        home_wins = sum(1 for row in processed_data if row['FTR'] == 'H')
        total_matches = len(processed_data)
        
        if total_matches > 0:
            home_win_rate = home_wins / total_matches
            # Ev sahibi avantajı: normal 0.33'ten ne kadar fazla
            self.home_advantage = max(0, home_win_rate - 0.33)
        
        print(f"  📊 Ev sahibi avantajı: {self.home_advantage:.3f}")
    
    def train(self, processed_data):
        """Modeli eğitir"""
        print("\n🤖 Model eğitimi başlıyor...")
        
        # Takım güçlerini hesapla
        self.calculate_team_strengths(processed_data)
        
        # Ev sahibi avantajını hesapla
        self.calculate_home_advantage(processed_data)
        
        self.is_trained = True
        print("  ✅ Model eğitimi tamamlandı!")
    
    def predict_match(self, home_team, away_team, home_form_avg=1.5, away_form_avg=1.5):
        """Tek maç tahmini yapar"""
        if not self.is_trained:
            raise ValueError("❌ Model henüz eğitilmemiş!")
        
        # Takım güçleri
        home_strength = self.team_strength.get(home_team, 1.5)
        away_strength = self.team_strength.get(away_team, 1.5)
        
        home_attack = self.team_attack.get(home_team, 1.3)
        home_defense = self.team_defense.get(home_team, 1.3)
        away_attack = self.team_attack.get(away_team, 1.3)
        away_defense = self.team_defense.get(away_team, 1.3)
        
        # Form etkisi
        form_factor = self.form_weight
        home_strength_adj = home_strength + (home_form_avg - 1.5) * form_factor
        away_strength_adj = away_strength + (away_form_avg - 1.5) * form_factor
        
        # Gol tahminleri (Poisson-benzeri model)
        # Ev sahibi gol tahmini
        home_goal_expectation = (
            home_attack * (2.0 - away_defense) * (1 + self.home_advantage) * 
            (0.8 + 0.4 * home_strength_adj / 3.0)
        )
        
        # Deplasman gol tahmini
        away_goal_expectation = (
            away_attack * (2.0 - home_defense) * (1 - self.home_advantage) * 
            (0.8 + 0.4 * away_strength_adj / 3.0)
        )
        
        # Gol sayılarını yuvarla
        home_goals = max(0, round(home_goal_expectation))
        away_goals = max(0, round(away_goal_expectation))
        
        # Sonuç tahmini
        if home_goals > away_goals:
            result = 'H'
            result_proba = min(0.9, 0.4 + (home_goals - away_goals) * 0.15 + self.home_advantage)
        elif away_goals > home_goals:
            result = 'A'
            result_proba = min(0.9, 0.4 + (away_goals - home_goals) * 0.15)
        else:
            result = 'D'
            result_proba = min(0.9, 0.3 + abs(home_strength_adj - away_strength_adj) * 0.1)
        
        # Olasılık dağılımı
        if result == 'H':
            home_proba = result_proba
            draw_proba = (1 - result_proba) * 0.4
            away_proba = (1 - result_proba) * 0.6
        elif result == 'A':
            away_proba = result_proba
            draw_proba = (1 - result_proba) * 0.4
            home_proba = (1 - result_proba) * 0.6
        else:
            draw_proba = result_proba
            home_proba = (1 - result_proba) * 0.5
            away_proba = (1 - result_proba) * 0.5
        
        return {
            'home_goals': home_goals,
            'away_goals': away_goals,
            'result': result,
            'probabilities': {
                'home': round(home_proba, 3),
                'draw': round(draw_proba, 3),
                'away': round(away_proba, 3)
            },
            'confidence': round(result_proba, 3)
        }
    
    def evaluate_model(self, test_data):
        """Modeli değerlendirir"""
        print("\n📊 Model değerlendiriliyor...")
        
        correct_results = 0
        total_predictions = 0
        goal_differences = []
        
        for row in test_data:
            if row['home_form_matches'] < 3:  # Yeterli form verisi yok
                continue
                
            try:
                prediction = self.predict_match(
                    home_team=row['HomeTeam'],
                    away_team=row['AwayTeam'],
                    home_form_avg=row.get('home_form_avg', 1.5),
                    away_form_avg=row.get('away_form_avg', 1.5)
                )
                
                # Sonuç doğruluğu
                actual_result = row['FTR']
                if prediction['result'] == actual_result:
                    correct_results += 1
                
                # Gol tahmini hatası
                goal_diff = abs(prediction['home_goals'] - row['FTHG']) + abs(prediction['away_goals'] - row['FTAG'])
                goal_differences.append(goal_diff)
                
                total_predictions += 1
                
            except Exception as e:
                continue
        
        if total_predictions > 0:
            accuracy = correct_results / total_predictions
            avg_goal_error = sum(goal_differences) / len(goal_differences) if goal_differences else 0
            
            print(f"  📈 Sonuç doğruluğu: {accuracy:.1%} ({correct_results}/{total_predictions})")
            print(f"  ⚽ Ortalama gol hatası: {avg_goal_error:.2f}")
            
            return {
                'accuracy': accuracy,
                'avg_goal_error': avg_goal_error,
                'total_predictions': total_predictions
            }
        else:
            print("  ❌ Yeterli test verisi bulunamadı!")
            return None
    
    def save_model(self, file_path="simple_football_model.txt"):
        """Modeli kaydeder"""
        if not self.is_trained:
            print("❌ Kaydedilecek eğitilmiş model yok!")
            return
        
        with open(file_path, 'w', encoding='utf-8') as f:
            f.write("# Simple Football Prediction Model\n")
            f.write(f"home_advantage={self.home_advantage}\n")
            f.write(f"form_weight={self.form_weight}\n")
            f.write("\n# Team Strengths\n")
            for team, strength in self.team_strength.items():
                f.write(f"strength,{team},{strength}\n")
            f.write("\n# Team Attack\n")
            for team, attack in self.team_attack.items():
                f.write(f"attack,{team},{attack}\n")
            f.write("\n# Team Defense\n")
            for team, defense in self.team_defense.items():
                f.write(f"defense,{team},{defense}\n")
        
        print(f"💾 Model kaydedildi: {file_path}")

def main():
    """Ana fonksiyon"""
    print("🚀 Simple Football Model Training başlıyor...")
    print("=" * 60)
    
    # Veri işleyiciyi çalıştır
    processor = SimpleFootballDataProcessor(data_path="../data/")
    processor.load_all_seasons()
    processor.clean_data()
    processor.add_basic_features()
    form_data = processor.add_form_features(last_n_matches=5)
    processor.processed_data = form_data
    
    # Veriyi böl (80% eğitim, 20% test)
    random.shuffle(processor.processed_data)
    split_point = int(len(processor.processed_data) * 0.8)
    train_data = processor.processed_data[:split_point]
    test_data = processor.processed_data[split_point:]
    
    print(f"\n📊 Veri bölünmesi:")
    print(f"  🏋️ Eğitim verisi: {len(train_data)} maç")
    print(f"  🧪 Test verisi: {len(test_data)} maç")
    
    # Model oluştur ve eğit
    model = SimpleFootballPredictor()
    model.train(train_data)
    
    # Model değerlendir
    evaluation = model.evaluate_model(test_data)
    
    # Örnek tahminler
    print(f"\n🔮 Örnek Tahminler:")
    print("=" * 40)
    
    # Popüler takımlarla örnek
    example_teams = ['Arsenal', 'Chelsea', 'Man United', 'Liverpool', 'Man City']
    available_teams = list(processor.team_mapping.keys())
    
    for i in range(3):
        if len(available_teams) >= 2:
            home = random.choice([t for t in available_teams if any(x in t for x in example_teams)] or available_teams)
            away = random.choice([t for t in available_teams if t != home])
            
            try:
                prediction = model.predict_match(home, away)
                print(f"\n🏟️  {home} vs {away}")
                print(f"  📊 Tahmin: {home} {prediction['home_goals']} - {prediction['away_goals']} {away}")
                result_map = {'H': 'Ev Sahibi', 'D': 'Beraberlik', 'A': 'Deplasman'}
                print(f"  🎯 Sonuç: {result_map[prediction['result']]}")
                print(f"  📈 Olasılıklar: Ev %{prediction['probabilities']['home']*100:.0f}, "
                      f"Beraberlik %{prediction['probabilities']['draw']*100:.0f}, "
                      f"Deplasman %{prediction['probabilities']['away']*100:.0f}")
                print(f"  🎲 Güven: %{prediction['confidence']*100:.0f}")
            except Exception as e:
                print(f"  ❌ Tahmin hatası: {str(e)}")
    
    # Modeli kaydet
    model.save_model("../models/simple_football_model.txt")
    
    print(f"\n✨ Model eğitimi ve değerlendirmesi tamamlandı! ✨")
    
    return model

if __name__ == "__main__":
    model = main()
