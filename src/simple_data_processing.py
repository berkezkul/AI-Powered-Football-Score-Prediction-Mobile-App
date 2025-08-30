#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
⚽ Football Match Score Prediction - Simple Data Processing (Built-in only)
Author: Berke Özkul
Description: Sadece built-in Python kütüphaneleriyle veri işleme
"""

import csv
import os
import glob
from datetime import datetime
from collections import defaultdict, Counter

class SimpleFootballDataProcessor:
    """
    Basit veri işleme sınıfı (sadece built-in Python)
    """
    
    def __init__(self, data_path="../data/"):
        self.data_path = data_path
        self.raw_data = []
        self.processed_data = []
        self.team_mapping = {}
        
    def load_all_seasons(self):
        """Tüm sezonları yükler"""
        print("🔄 Tüm sezonları yüklüyor...")
        
        # CSV dosyalarını bul
        csv_files = glob.glob(os.path.join(self.data_path, "E0*.csv"))
        if not csv_files:
            raise FileNotFoundError(f"❌ {self.data_path} klasöründe CSV dosyası bulunamadı!")
        
        all_data = []
        
        for file_path in sorted(csv_files):
            season_name = os.path.basename(file_path).replace('.csv', '').replace('E0 ', '')
            
            try:
                with open(file_path, 'r', encoding='utf-8') as f:
                    reader = csv.DictReader(f)
                    season_data = []
                    
                    for row in reader:
                        row['Season'] = season_name
                        season_data.append(row)
                    
                    all_data.extend(season_data)
                    print(f"  ✅ {season_name}: {len(season_data)} maç yüklendi")
                    
            except Exception as e:
                print(f"  ❌ {season_name}: Hata - {str(e)}")
                continue
        
        self.raw_data = all_data
        print(f"\n🎯 Toplam {len(all_data)} maç yüklendi")
        return all_data
    
    def clean_data(self):
        """Veriyi temizler"""
        print("\n🧹 Veriyi temizliyor...")
        
        cleaned_data = []
        
        for row in self.raw_data:
            # Kritik alanları kontrol et
            if not all([
                row.get('HomeTeam'), 
                row.get('AwayTeam'), 
                row.get('FTHG'), 
                row.get('FTAG'), 
                row.get('FTR')
            ]):
                continue
            
            # Gol sayılarını sayıya çevir
            try:
                row['FTHG'] = int(row['FTHG'])
                row['FTAG'] = int(row['FTAG'])
                
                # Negatif gol kontrolü
                if row['FTHG'] < 0 or row['FTAG'] < 0:
                    continue
                    
            except (ValueError, TypeError):
                continue
            
            # Sonuç kontrolü
            if row['FTR'] not in ['H', 'D', 'A']:
                continue
            
            # Tarih işleme
            try:
                date_str = row.get('Date', '')
                # dd/mm/yyyy formatını parse et
                if '/' in date_str:
                    day, month, year = date_str.split('/')
                    row['Date_Parsed'] = f"{year}-{month.zfill(2)}-{day.zfill(2)}"
                    row['Year'] = int(year)
                    row['Month'] = int(month)
                else:
                    row['Date_Parsed'] = ''
                    row['Year'] = 0
                    row['Month'] = 0
            except:
                row['Date_Parsed'] = ''
                row['Year'] = 0
                row['Month'] = 0
            
            cleaned_data.append(row)
        
        self.processed_data = cleaned_data
        print(f"  ✅ Temizleme tamamlandı: {len(cleaned_data)} geçerli maç")
        return cleaned_data
    
    def add_basic_features(self):
        """Temel özellikler ekler"""
        print("\n⚙️  Temel özellikler ekleniyor...")
        
        # Takım mapping oluştur
        all_teams = set()
        for row in self.processed_data:
            all_teams.add(row['HomeTeam'])
            all_teams.add(row['AwayTeam'])
        
        self.team_mapping = {team: idx for idx, team in enumerate(sorted(all_teams))}
        
        # Özellikler ekle
        for row in self.processed_data:
            # Takım kodlaması
            row['HomeTeam_encoded'] = self.team_mapping[row['HomeTeam']]
            row['AwayTeam_encoded'] = self.team_mapping[row['AwayTeam']]
            
            # Gol özellikleri
            row['TotalGoals'] = row['FTHG'] + row['FTAG']
            row['GoalDifference'] = row['FTHG'] - row['FTAG']
            
            # Ev sahibi avantajı
            row['HomeAdvantage'] = 1 if row['FTR'] == 'H' else 0
            
            # Over/Under
            row['Over2_5'] = 1 if row['TotalGoals'] > 2.5 else 0
            row['Over1_5'] = 1 if row['TotalGoals'] > 1.5 else 0
            row['Over3_5'] = 1 if row['TotalGoals'] > 3.5 else 0
            
            # Both Teams to Score
            row['BTTS'] = 1 if (row['FTHG'] > 0 and row['FTAG'] > 0) else 0
            
            # Sonuç kodlaması
            result_mapping = {'H': 0, 'D': 1, 'A': 2}
            row['FTR_encoded'] = result_mapping[row['FTR']]
        
        print(f"  ✅ Özellikler eklendi: {len(self.team_mapping)} takım kodlandı")
        return self.processed_data
    
    def get_summary(self):
        """Veri özeti"""
        if not self.processed_data:
            return {}
        
        total_matches = len(self.processed_data)
        total_goals_home = sum(row['FTHG'] for row in self.processed_data)
        total_goals_away = sum(row['FTAG'] for row in self.processed_data)
        
        # Sonuç sayıları
        results = Counter(row['FTR'] for row in self.processed_data)
        
        # Sezon sayıları
        seasons = set(row['Season'] for row in self.processed_data)
        
        summary = {
            'total_matches': total_matches,
            'total_seasons': len(seasons),
            'total_teams': len(self.team_mapping),
            'avg_home_goals': total_goals_home / total_matches if total_matches > 0 else 0,
            'avg_away_goals': total_goals_away / total_matches if total_matches > 0 else 0,
            'avg_total_goals': (total_goals_home + total_goals_away) / total_matches if total_matches > 0 else 0,
            'home_wins': results.get('H', 0),
            'draws': results.get('D', 0),
            'away_wins': results.get('A', 0),
            'home_win_rate': results.get('H', 0) / total_matches if total_matches > 0 else 0,
            'draw_rate': results.get('D', 0) / total_matches if total_matches > 0 else 0,
            'away_win_rate': results.get('A', 0) / total_matches if total_matches > 0 else 0,
            'seasons': sorted(seasons),
            'teams': sorted(self.team_mapping.keys())
        }
        
        return summary
    
    def save_processed_data(self, output_path="../data/processed_simple.csv"):
        """İşlenmiş veriyi CSV olarak kaydeder"""
        if not self.processed_data:
            print("❌ Kaydedilecek veri yok!")
            return
        
        # Temel sütunları belirle (tüm satırlarda ortak olanlar)
        core_fields = [
            'Season', 'Date', 'HomeTeam', 'AwayTeam', 'FTHG', 'FTAG', 'FTR',
            'Date_Parsed', 'Year', 'Month', 'HomeTeam_encoded', 'AwayTeam_encoded',
            'TotalGoals', 'GoalDifference', 'HomeAdvantage', 'Over2_5', 'Over1_5', 
            'Over3_5', 'BTTS', 'FTR_encoded'
        ]
        
        # Sadece temel alanları kaydet
        simplified_data = []
        for row in self.processed_data:
            simplified_row = {field: row.get(field, '') for field in core_fields}
            simplified_data.append(simplified_row)
        
        with open(output_path, 'w', newline='', encoding='utf-8') as f:
            writer = csv.DictWriter(f, fieldnames=core_fields)
            writer.writeheader()
            writer.writerows(simplified_data)
        
        print(f"💾 İşlenmiş veri kaydedildi: {output_path}")
    
    def get_team_stats(self):
        """Takım istatistikleri"""
        if not self.processed_data:
            return {}
        
        team_stats = defaultdict(lambda: {
            'home_matches': 0, 'away_matches': 0,
            'home_goals_for': 0, 'home_goals_against': 0,
            'away_goals_for': 0, 'away_goals_against': 0,
            'home_wins': 0, 'away_wins': 0, 'draws': 0
        })
        
        for row in self.processed_data:
            home_team = row['HomeTeam']
            away_team = row['AwayTeam']
            
            # Ev sahibi istatistikleri
            team_stats[home_team]['home_matches'] += 1
            team_stats[home_team]['home_goals_for'] += row['FTHG']
            team_stats[home_team]['home_goals_against'] += row['FTAG']
            
            if row['FTR'] == 'H':
                team_stats[home_team]['home_wins'] += 1
            elif row['FTR'] == 'D':
                team_stats[home_team]['draws'] += 1
            
            # Deplasman istatistikleri
            team_stats[away_team]['away_matches'] += 1
            team_stats[away_team]['away_goals_for'] += row['FTAG']
            team_stats[away_team]['away_goals_against'] += row['FTHG']
            
            if row['FTR'] == 'A':
                team_stats[away_team]['away_wins'] += 1
            elif row['FTR'] == 'D':
                team_stats[away_team]['draws'] += 1
        
        return dict(team_stats)
    
    def add_form_features(self, last_n_matches=5):
        """Son N maçın formu ekler"""
        print(f"\n📈 Son {last_n_matches} maç formu hesaplanıyor...")
        
        # Tarihe göre sırala
        sorted_data = sorted(self.processed_data, key=lambda x: (x.get('Year', 0), x.get('Month', 0)))
        
        # Her takım için son maçları takip et
        team_form = defaultdict(list)  # team -> [(result, goals_for, goals_against, date), ...]
        
        for i, row in enumerate(sorted_data):
            home_team = row['HomeTeam']
            away_team = row['AwayTeam']
            
            # Ev sahibi için önceki form
            home_form = team_form[home_team][-last_n_matches:] if team_form[home_team] else []
            away_form = team_form[away_team][-last_n_matches:] if team_form[away_team] else []
            
            # Form özellikleri hesapla
            row['home_form_points'] = sum(3 if match[0] == 'W' else 1 if match[0] == 'D' else 0 for match in home_form)
            row['away_form_points'] = sum(3 if match[0] == 'W' else 1 if match[0] == 'D' else 0 for match in away_form)
            
            row['home_form_goals_for'] = sum(match[1] for match in home_form)
            row['home_form_goals_against'] = sum(match[2] for match in home_form)
            row['away_form_goals_for'] = sum(match[1] for match in away_form)
            row['away_form_goals_against'] = sum(match[2] for match in away_form)
            
            row['home_form_matches'] = len(home_form)
            row['away_form_matches'] = len(away_form)
            
            # Form puan ortalaması
            row['home_form_avg'] = row['home_form_points'] / max(1, row['home_form_matches'])
            row['away_form_avg'] = row['away_form_points'] / max(1, row['away_form_matches'])
            
            # Bu maçın sonucunu forma ekle
            home_result = 'W' if row['FTR'] == 'H' else 'D' if row['FTR'] == 'D' else 'L'
            away_result = 'W' if row['FTR'] == 'A' else 'D' if row['FTR'] == 'D' else 'L'
            
            team_form[home_team].append((home_result, row['FTHG'], row['FTAG'], i))
            team_form[away_team].append((away_result, row['FTAG'], row['FTHG'], i))
        
        print(f"  ✅ Form özellikleri eklendi: son {last_n_matches} maç bazında")
        return sorted_data

def main():
    """Ana fonksiyon"""
    print("🚀 Simple Football Data Processing başlıyor...")
    print("=" * 60)
    
    # İşleyici oluştur
    processor = SimpleFootballDataProcessor(data_path="../data/")
    
    # Veriyi yükle
    raw_data = processor.load_all_seasons()
    
    # Temizle
    clean_data = processor.clean_data()
    
    # Özellik ekle
    processed_data = processor.add_basic_features()
    
    # Form özelliklerini ekle
    form_data = processor.add_form_features(last_n_matches=5)
    processor.processed_data = form_data
    
    # Özet al
    summary = processor.get_summary()
    
    print(f"\n📋 VERİ ÖN İŞLEME ÖZET RAPORU:")
    print("=" * 50)
    print(f"📊 Toplam maç sayısı: {summary['total_matches']:,}")
    print(f"🏆 Sezon sayısı: {summary['total_seasons']}")
    print(f"⚽ Takım sayısı: {summary['total_teams']}")
    print(f"🥅 Ortalama ev sahibi gol: {summary['avg_home_goals']:.2f}")
    print(f"🏃 Ortalama deplasman gol: {summary['avg_away_goals']:.2f}")
    print(f"⚽ Ortalama toplam gol: {summary['avg_total_goals']:.2f}")
    print(f"🏠 Ev sahibi galibiyet: {summary['home_wins']} ({summary['home_win_rate']:.1%})")
    print(f"🤝 Beraberlik: {summary['draws']} ({summary['draw_rate']:.1%})")
    print(f"✈️  Deplasman galibiyet: {summary['away_wins']} ({summary['away_win_rate']:.1%})")
    
    print(f"\n🏆 Sezonlar: {', '.join(summary['seasons'])}")
    print(f"\n⚽ İlk 10 takım: {', '.join(summary['teams'][:10])}")
    
    # Veriyi kaydet
    processor.save_processed_data()
    
    # Takım istatistikleri
    team_stats = processor.get_team_stats()
    print(f"\n📈 Takım istatistikleri hesaplandı: {len(team_stats)} takım")
    
    print(f"\n✨ Basit veri ön işleme başarıyla tamamlandı! ✨")
    
    return processor

if __name__ == "__main__":
    processor = main()
