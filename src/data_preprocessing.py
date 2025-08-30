#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
⚽ Football Match Score Prediction - Data Preprocessing Module
Author: Berke Özkul
Description: Premier League verilerini yükleme, temizleme ve ön işleme modülü
"""

import pandas as pd
import numpy as np
import os
import glob
from datetime import datetime
from typing import Tuple, List, Optional
import warnings
warnings.filterwarnings('ignore')

class FootballDataPreprocessor:
    """
    İngiliz Premier Ligi verilerini ön işleme sınıfı
    """
    
    def __init__(self, data_path: str = "../data/"):
        """
        Args:
            data_path (str): CSV dosyalarının bulunduğu klasör yolu
        """
        self.data_path = data_path
        self.raw_data = None
        self.processed_data = None
        self.team_mapping = {}
        
    def load_all_seasons(self) -> pd.DataFrame:
        """
        Tüm sezonların CSV dosyalarını yükler ve birleştirir
        
        Returns:
            pd.DataFrame: Birleştirilmiş veri
        """
        print("🔄 Tüm sezonları yüklüyor ve birleştiriyor...")
        
        # CSV dosyalarını bul
        csv_files = glob.glob(os.path.join(self.data_path, "E0*.csv"))
        if not csv_files:
            raise FileNotFoundError(f"❌ {self.data_path} klasöründe CSV dosyası bulunamadı!")
        
        all_seasons = []
        
        for file_path in sorted(csv_files):
            # Sezon adını dosya adından çıkar
            season_name = os.path.basename(file_path).replace('.csv', '').replace('E0 ', '')
            
            try:
                # CSV'yi oku
                df = pd.read_csv(file_path)
                
                # Sezon sütunu ekle
                df['Season'] = season_name
                
                all_seasons.append(df)
                print(f"  ✅ {season_name}: {len(df)} maç yüklendi")
                
            except Exception as e:
                print(f"  ❌ {season_name}: Hata - {str(e)}")
                continue
        
        if not all_seasons:
            raise ValueError("❌ Hiçbir sezon verisi yüklenemedi!")
        
        # Tüm sezonları birleştir
        self.raw_data = pd.concat(all_seasons, ignore_index=True)
        
        print(f"\n🎯 Toplam {len(all_seasons)} sezon birleştirildi")
        print(f"📊 Toplam veri boyutu: {self.raw_data.shape[0]:,} satır × {self.raw_data.shape[1]} sütun")
        
        return self.raw_data
    
    def clean_data(self) -> pd.DataFrame:
        """
        Veriyi temizler ve düzenler
        
        Returns:
            pd.DataFrame: Temizlenmiş veri
        """
        if self.raw_data is None:
            raise ValueError("❌ Önce load_all_seasons() metodunu çalıştırın!")
        
        print("\n🧹 Veriyi temizliyor...")
        df = self.raw_data.copy()
        
        # 1. Tarih sütununu düzelt
        print("  📅 Tarih sütununu düzeltiliyor...")
        df['Date'] = pd.to_datetime(df['Date'], format='%d/%m/%Y', errors='coerce')
        
        invalid_dates = df['Date'].isnull().sum()
        if invalid_dates > 0:
            print(f"    ⚠️  {invalid_dates} geçersiz tarih bulundu, kaldırılıyor...")
            df = df.dropna(subset=['Date'])
        
        # 2. Kritik sütunları kontrol et
        critical_columns = ['HomeTeam', 'AwayTeam', 'FTHG', 'FTAG', 'FTR']
        print("  🔍 Kritik sütunları kontrol ediliyor...")
        
        for col in critical_columns:
            missing_count = df[col].isnull().sum()
            if missing_count > 0:
                print(f"    ❌ {col} sütununda {missing_count} eksik veri bulundu")
                df = df.dropna(subset=[col])
        
        # 3. Takım isimlerini standardize et
        print("  ⚽ Takım isimlerini standardize ediliyor...")
        df = self._standardize_team_names(df)
        
        # 4. Gol sayılarını kontrol et (negatif olamaz)
        print("  🥅 Gol sayılarını kontrol ediliyor...")
        invalid_goals = (df['FTHG'] < 0) | (df['FTAG'] < 0)
        if invalid_goals.sum() > 0:
            print(f"    ❌ {invalid_goals.sum()} geçersiz gol verisi kaldırılıyor...")
            df = df[~invalid_goals]
        
        # 5. FTR sütununu kontrol et
        print("  🏆 Sonuç sütununu kontrol ediliyor...")
        valid_results = ['H', 'D', 'A']
        invalid_results = ~df['FTR'].isin(valid_results)
        if invalid_results.sum() > 0:
            print(f"    ❌ {invalid_results.sum()} geçersiz sonuç verisi kaldırılıyor...")
            df = df[~invalid_results]
        
        # 6. Bahis oranlarını temizle
        print("  💰 Bahis oranlarını temizliyor...")
        betting_columns = [col for col in df.columns if any(x in col for x in ['B365', 'BW', 'IW', 'LB', 'SB', 'WH'])]
        for col in betting_columns:
            # Negatif veya sıfır oranları temizle
            if col in df.columns:
                df.loc[df[col] <= 0, col] = np.nan
        
        # 7. Şut verilerini temizle
        shot_columns = ['HS', 'AS', 'HST', 'AST']
        for col in shot_columns:
            if col in df.columns:
                df.loc[df[col] < 0, col] = np.nan
        
        self.processed_data = df
        
        print(f"  ✅ Temizleme tamamlandı!")
        print(f"  📊 Kalan veri boyutu: {df.shape[0]:,} satır × {df.shape[1]} sütun")
        
        return df
    
    def _standardize_team_names(self, df: pd.DataFrame) -> pd.DataFrame:
        """
        Takım isimlerini standardize eder
        
        Args:
            df (pd.DataFrame): İşlenecek veri
            
        Returns:
            pd.DataFrame: Standardize edilmiş veri
        """
        # Takım isimleri için mapping sözlüğü
        team_name_mapping = {
            # Ortak hatalar ve alternatif isimler
            'Man United': 'Manchester United',
            'Man Utd': 'Manchester United',
            'Man City': 'Manchester City',
            'Man Utd': 'Manchester United',
            'Tottenham': 'Tottenham Hotspur',
            'Spurs': 'Tottenham Hotspur',
            'Leicester': 'Leicester City',
            'Wolves': 'Wolverhampton Wanderers',
            'Brighton': 'Brighton & Hove Albion',
            'West Ham': 'West Ham United',
            'Newcastle': 'Newcastle United',
            'Norwich': 'Norwich City',
            'Crystal Palace': 'Crystal Palace',
            'Sheffield United': 'Sheffield United',
            'Sheffield Utd': 'Sheffield United'
        }
        
        # Home ve Away takım isimlerini standardize et
        df['HomeTeam'] = df['HomeTeam'].replace(team_name_mapping)
        df['AwayTeam'] = df['AwayTeam'].replace(team_name_mapping)
        
        # Takım mapping'ini sakla
        unique_teams = sorted(list(set(df['HomeTeam'].unique()) | set(df['AwayTeam'].unique())))
        self.team_mapping = {team: idx for idx, team in enumerate(unique_teams)}
        
        print(f"    📝 {len(unique_teams)} benzersiz takım bulundu ve standardize edildi")
        
        return df
    
    def add_basic_features(self) -> pd.DataFrame:
        """
        Temel özellikler ekler
        
        Returns:
            pd.DataFrame: Özellikler eklenmiş veri
        """
        if self.processed_data is None:
            raise ValueError("❌ Önce clean_data() metodunu çalıştırın!")
        
        print("\n⚙️  Temel özellikler ekleniyor...")
        df = self.processed_data.copy()
        
        # 1. Tarih özellikler
        print("  📅 Tarih özellikleri ekleniyor...")
        df['Year'] = df['Date'].dt.year
        df['Month'] = df['Date'].dt.month
        df['DayOfWeek'] = df['Date'].dt.dayofweek  # 0=Pazartesi, 6=Pazar
        df['WeekOfYear'] = df['Date'].dt.isocalendar().week
        
        # 2. Takım encoding
        print("  🏷️  Takım kodlaması ekleniyor...")
        df['HomeTeam_encoded'] = df['HomeTeam'].map(self.team_mapping)
        df['AwayTeam_encoded'] = df['AwayTeam'].map(self.team_mapping)
        
        # 3. Toplam gol
        print("  ⚽ Toplam gol hesaplanıyor...")
        df['TotalGoals'] = df['FTHG'] + df['FTAG']
        
        # 4. Gol farkı
        print("  📊 Gol farkı hesaplanıyor...")
        df['GoalDifference'] = df['FTHG'] - df['FTAG']
        
        # 5. Ev sahibi avantajı
        print("  🏠 Ev sahibi avantajı hesaplanıyor...")
        df['HomeAdvantage'] = (df['FTR'] == 'H').astype(int)
        
        # 6. Over/Under 2.5 gol
        print("  🎯 Over/Under özellikleri ekleniyor...")
        df['Over2_5'] = (df['TotalGoals'] > 2.5).astype(int)
        df['Over1_5'] = (df['TotalGoals'] > 1.5).astype(int)
        df['Over3_5'] = (df['TotalGoals'] > 3.5).astype(int)
        
        # 7. Both Teams to Score
        print("  🥅 Both Teams to Score ekleniyor...")
        df['BTTS'] = ((df['FTHG'] > 0) & (df['FTAG'] > 0)).astype(int)
        
        # 8. Sonuç encoding
        print("  🏆 Sonuç kodlaması ekleniyor...")
        result_mapping = {'H': 0, 'D': 1, 'A': 2}
        df['FTR_encoded'] = df['FTR'].map(result_mapping)
        
        self.processed_data = df
        
        print(f"  ✅ Temel özellikler eklendi!")
        print(f"  📊 Yeni veri boyutu: {df.shape[0]:,} satır × {df.shape[1]} sütun")
        
        return df
    
    def get_data_summary(self) -> dict:
        """
        Veri özeti döndürür
        
        Returns:
            dict: Veri özeti
        """
        if self.processed_data is None:
            raise ValueError("❌ Veri henüz işlenmemiş!")
        
        df = self.processed_data
        
        summary = {
            'total_matches': len(df),
            'total_seasons': df['Season'].nunique(),
            'total_teams': len(self.team_mapping),
            'date_range': (df['Date'].min().strftime('%Y-%m-%d'), df['Date'].max().strftime('%Y-%m-%d')),
            'avg_home_goals': df['FTHG'].mean(),
            'avg_away_goals': df['FTAG'].mean(),
            'avg_total_goals': df['TotalGoals'].mean(),
            'home_win_rate': (df['FTR'] == 'H').mean(),
            'draw_rate': (df['FTR'] == 'D').mean(),
            'away_win_rate': (df['FTR'] == 'A').mean(),
            'missing_data_pct': (df.isnull().sum().sum() / (df.shape[0] * df.shape[1])) * 100,
            'columns': list(df.columns),
            'team_mapping': self.team_mapping
        }
        
        return summary
    
    def save_processed_data(self, output_path: str = "../data/processed_data.csv") -> None:
        """
        İşlenmiş veriyi kaydeder
        
        Args:
            output_path (str): Kayıt yolu
        """
        if self.processed_data is None:
            raise ValueError("❌ Kaydedilecek işlenmiş veri yok!")
        
        self.processed_data.to_csv(output_path, index=False)
        print(f"💾 İşlenmiş veri kaydedildi: {output_path}")
    
    def get_processed_data(self) -> pd.DataFrame:
        """
        İşlenmiş veriyi döndürür
        
        Returns:
            pd.DataFrame: İşlenmiş veri
        """
        if self.processed_data is None:
            raise ValueError("❌ Veri henüz işlenmemiş!")
        
        return self.processed_data.copy()

def main():
    """
    Ana fonksiyon - Veri ön işleme pipeline'ını çalıştırır
    """
    print("🚀 Football Data Preprocessing Pipeline başlıyor...")
    print("=" * 60)
    
    # 1. Preprocessor oluştur
    preprocessor = FootballDataPreprocessor(data_path="../data/")
    
    # 2. Tüm sezonları yükle
    raw_data = preprocessor.load_all_seasons()
    
    # 3. Veriyi temizle
    clean_data = preprocessor.clean_data()
    
    # 4. Temel özellikleri ekle
    processed_data = preprocessor.add_basic_features()
    
    # 5. Özet rapor
    summary = preprocessor.get_data_summary()
    
    print(f"\n📋 VERİ ÖN İŞLEME ÖZET RAPORU:")
    print("=" * 50)
    print(f"📊 Toplam maç sayısı: {summary['total_matches']:,}")
    print(f"🏆 Sezon sayısı: {summary['total_seasons']}")
    print(f"⚽ Takım sayısı: {summary['total_teams']}")
    print(f"📅 Tarih aralığı: {summary['date_range'][0]} - {summary['date_range'][1]}")
    print(f"🥅 Ortalama ev sahibi gol: {summary['avg_home_goals']:.2f}")
    print(f"🏃 Ortalama deplasman gol: {summary['avg_away_goals']:.2f}")
    print(f"⚽ Ortalama toplam gol: {summary['avg_total_goals']:.2f}")
    print(f"🏠 Ev sahibi galibiyet oranı: {summary['home_win_rate']:.1%}")
    print(f"🤝 Beraberlik oranı: {summary['draw_rate']:.1%}")
    print(f"✈️  Deplasman galibiyet oranı: {summary['away_win_rate']:.1%}")
    print(f"❌ Eksik veri oranı: {summary['missing_data_pct']:.2f}%")
    print(f"📈 Toplam sütun sayısı: {len(summary['columns'])}")
    
    # 6. Veriyi kaydet
    preprocessor.save_processed_data()
    
    print(f"\n✨ Veri ön işleme başarıyla tamamlandı! ✨")
    print("🎯 Sonraki adım: Özellik mühendisliği (feature engineering)")
    
    return preprocessor

if __name__ == "__main__":
    preprocessor = main()
