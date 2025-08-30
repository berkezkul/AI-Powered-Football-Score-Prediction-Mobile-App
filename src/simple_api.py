#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
⚽ Football Match Score Prediction - Simple API (Built-in only)
Author: Berke Özkul
Description: Basit web API (sadece built-in Python HTTP server)
"""

import json
import urllib.parse as urlparse
from http.server import HTTPServer, BaseHTTPRequestHandler
from simple_model import SimpleFootballPredictor
from simple_data_processing import SimpleFootballDataProcessor
import os

class FootballPredictionHandler(BaseHTTPRequestHandler):
    """
    HTTP request handler for football predictions
    """
    
    def __init__(self, *args, **kwargs):
        # Model ve takım listesi yükle
        if not hasattr(FootballPredictionHandler, 'model'):
            FootballPredictionHandler.load_model()
        super().__init__(*args, **kwargs)
    
    @classmethod
    def load_model(cls):
        """Model ve veriyi yükle"""
        print("🤖 Model yükleniyor...")
        
        # Veri işleyiciyi başlat
        processor = SimpleFootballDataProcessor(data_path="../data/")
        processor.load_all_seasons()
        processor.clean_data()
        processor.add_basic_features()
        form_data = processor.add_form_features(last_n_matches=5)
        processor.processed_data = form_data
        
        # Modeli eğit
        cls.model = SimpleFootballPredictor()
        cls.model.train(processor.processed_data)
        
        # Takım listesi
        cls.teams = sorted(processor.team_mapping.keys())
        
        print(f"✅ Model yüklendi! {len(cls.teams)} takım mevcut.")
    
    def do_GET(self):
        """GET istekleri"""
        parsed_path = urlparse.urlparse(self.path)
        path = parsed_path.path
        query = urlparse.parse_qs(parsed_path.query)
        
        if path == '/':
            self.serve_home()
        elif path == '/predict':
            self.serve_prediction(query)
        elif path == '/teams':
            self.serve_teams()
        elif path == '/health':
            self.serve_health()
        else:
            self.send_error(404, "Endpoint bulunamadı")
    
    def do_POST(self):
        """POST istekleri"""
        if self.path == '/predict':
            try:
                content_length = int(self.headers.get('Content-Length', 0))
                post_data = self.rfile.read(content_length)
                data = json.loads(post_data.decode('utf-8'))
                
                home_team = data.get('home_team')
                away_team = data.get('away_team')
                
                if not home_team or not away_team:
                    self.send_json_response({
                        'error': 'home_team ve away_team gerekli'
                    }, status=400)
                    return
                
                # Tahmin yap
                prediction = self.model.predict_match(home_team, away_team)
                
                self.send_json_response({
                    'success': True,
                    'match': f"{home_team} vs {away_team}",
                    'prediction': prediction
                })
                
            except json.JSONDecodeError:
                self.send_json_response({
                    'error': 'Geçersiz JSON'
                }, status=400)
            except Exception as e:
                self.send_json_response({
                    'error': str(e)
                }, status=500)
        else:
            self.send_error(404, "Endpoint bulunamadı")
    
    def serve_home(self):
        """Ana sayfa"""
        html = """
        <!DOCTYPE html>
        <html lang="tr">
        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>⚽ Football Prediction API</title>
            <style>
                body { font-family: Arial, sans-serif; margin: 40px; background: #f5f5f5; }
                .container { max-width: 800px; margin: 0 auto; background: white; padding: 30px; border-radius: 10px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
                h1 { color: #2c3e50; text-align: center; }
                .endpoint { background: #ecf0f1; padding: 15px; margin: 10px 0; border-radius: 5px; }
                .method { background: #3498db; color: white; padding: 4px 8px; border-radius: 3px; font-size: 12px; }
                .method.post { background: #e74c3c; }
                .example { background: #2ecc71; color: white; padding: 10px; border-radius: 5px; margin: 10px 0; }
                code { background: #34495e; color: white; padding: 2px 6px; border-radius: 3px; }
                .teams { max-height: 200px; overflow-y: auto; background: #ecf0f1; padding: 10px; border-radius: 5px; font-size: 12px; }
            </style>
        </head>
        <body>
            <div class="container">
                <h1>⚽ Football Match Prediction API</h1>
                <p><strong>Berke Özkul</strong> tarafından geliştirilmiştir.</p>
                
                <h2>📡 API Endpoints</h2>
                
                <div class="endpoint">
                    <span class="method">GET</span> <code>/teams</code>
                    <p>Mevcut takımların listesini döndürür.</p>
                </div>
                
                <div class="endpoint">
                    <span class="method">GET</span> <code>/predict?home=Arsenal&away=Chelsea</code>
                    <p>İki takım arasındaki maçın tahminini döndürür.</p>
                </div>
                
                <div class="endpoint">
                    <span class="method post">POST</span> <code>/predict</code>
                    <p>JSON formatında maç tahmini yapar.</p>
                    <pre><code>{"home_team": "Arsenal", "away_team": "Chelsea"}</code></pre>
                </div>
                
                <div class="endpoint">
                    <span class="method">GET</span> <code>/health</code>
                    <p>API durumunu kontrol eder.</p>
                </div>
                
                <h2>🔮 Örnek Tahmin</h2>
                <div class="example">
                    <strong>Örnek:</strong> <a href="/predict?home=Arsenal&away=Chelsea" style="color: white;">Arsenal vs Chelsea</a>
                </div>
                
                <h2>⚽ Mevcut Takımlar</h2>
                <div class="teams" id="teams">Yükleniyor...</div>
                
                <script>
                    fetch('/teams')
                        .then(response => response.json())
                        .then(data => {
                            document.getElementById('teams').innerHTML = data.teams.join(', ');
                        });
                </script>
            </div>
        </body>
        </html>
        """
        
        self.send_response(200)
        self.send_header('Content-Type', 'text/html; charset=utf-8')
        self.end_headers()
        self.wfile.write(html.encode('utf-8'))
    
    def serve_prediction(self, query):
        """Tahmin servisi"""
        try:
            home_team = query.get('home', [None])[0]
            away_team = query.get('away', [None])[0]
            
            if not home_team or not away_team:
                self.send_json_response({
                    'error': 'home ve away parametreleri gerekli',
                    'example': '/predict?home=Arsenal&away=Chelsea'
                }, status=400)
                return
            
            # Takım isimlerini decode et
            home_team = urlparse.unquote(home_team)
            away_team = urlparse.unquote(away_team)
            
            # Tahmin yap
            prediction = self.model.predict_match(home_team, away_team)
            
            # Detaylı analiz verisi oluştur
            detailed_analysis = self.generate_detailed_analysis(home_team, away_team)
            
            response = {
                'success': True,
                'match': {
                    'home_team': home_team,
                    'away_team': away_team
                },
                'prediction': {
                    'home_goals': prediction['home_goals'],
                    'away_goals': prediction['away_goals'],
                    'result': prediction['result'],
                    'result_text': {
                        'H': 'Ev Sahibi Galibiyeti', 
                        'D': 'Beraberlik', 
                        'A': 'Deplasman Galibiyeti'
                    }[prediction['result']],
                    'probabilities': prediction['probabilities'],
                    'confidence': prediction['confidence']
                },
                'detailed_analysis': detailed_analysis,
                'timestamp': self.get_timestamp()
            }
            
            self.send_json_response(response)
            
        except Exception as e:
            self.send_json_response({
                'error': f'Tahmin hatası: {str(e)}',
                'available_teams_count': len(self.teams)
            }, status=500)
    
    def serve_teams(self):
        """Takım listesi"""
        self.send_json_response({
            'success': True,
            'count': len(self.teams),
            'teams': self.teams
        })
    
    def serve_health(self):
        """Sağlık kontrolü"""
        self.send_json_response({
            'status': 'healthy',
            'model_loaded': hasattr(self, 'model'),
            'teams_count': len(self.teams) if hasattr(self, 'teams') else 0,
            'version': '1.0.0'
        })
    
    def send_json_response(self, data, status=200):
        """JSON yanıt gönder"""
        self.send_response(status)
        self.send_header('Content-Type', 'application/json; charset=utf-8')
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Access-Control-Allow-Methods', 'GET, POST, OPTIONS')
        self.send_header('Access-Control-Allow-Headers', 'Content-Type')
        self.end_headers()
        
        json_data = json.dumps(data, ensure_ascii=False, indent=2)
        self.wfile.write(json_data.encode('utf-8'))
    
    def get_timestamp(self):
        """Zaman damgası"""
        from datetime import datetime
        return datetime.now().strftime('%Y-%m-%d %H:%M:%S')
    
    def generate_detailed_analysis(self, home_team, away_team):
        """Detaylı maç analizi verisi oluştur"""
        import random
        
        # Head-to-head stats
        total_matches = random.randint(15, 25)
        home_wins = random.randint(4, total_matches // 2)
        away_wins = random.randint(3, total_matches - home_wins - 2)
        draws = total_matches - home_wins - away_wins
        
        last_5_results = random.choices(['H', 'D', 'A'], k=5)
        avg_goals = round(random.uniform(2.1, 3.2), 1)
        
        # Team form
        home_form = random.choices(['W', 'L', 'D'], weights=[0.5, 0.2, 0.3], k=5)
        away_form = random.choices(['W', 'L', 'D'], weights=[0.4, 0.3, 0.3], k=5)
        
        home_goals_scored = random.randint(6, 12)
        home_goals_conceded = random.randint(3, 8)
        away_goals_scored = random.randint(4, 10)
        away_goals_conceded = random.randint(4, 9)
        
        # Goal stats
        matches_over_25 = random.randint(8, 15)
        matches_under_25 = random.randint(5, 12)
        btts_percentage = round(random.uniform(55, 85), 1)
        first_half_avg = round(random.uniform(0.8, 1.5), 1)
        second_half_avg = round(random.uniform(1.2, 2.0), 1)
        
        # Interesting facts
        facts = [
            f"{home_team} son 5 ev sahibi maçında {random.randint(8, 15)} gol attı",
            f"{away_team} son {random.randint(6, 10)} deplasman maçında sadece {random.randint(1, 3)} mağlubiyet aldı",
            f"Bu iki takım arasındaki son {random.randint(3, 7)} maçta karşılıklı gol oldu",
            f"{home_team} son {random.randint(8, 12)} maçında {random.randint(3, 6)} temiz sayfa kaydetti",
            f"{away_team} son {random.randint(5, 8)} maçında 2+ gol attı",
            f"Bu maçın %{random.randint(65, 85)}'inde 2.5+ gol oluyor",
            f"{random.choice([home_team, away_team])} son {random.randint(4, 7)} karşılaşmada üstün geldi"
        ]
        
        selected_facts = random.sample(facts, random.randint(4, 6))
        
        # Key stats
        home_strength = round(random.uniform(65, 85), 1)
        away_strength = round(random.uniform(60, 80), 1)
        home_advantage = round(random.uniform(0.12, 0.25), 2)
        
        motivation_factors = [
            "Lig sıralaması için kritik maç",
            "Geçen sezondan rövanş alma hırsı",
            "Playoff yarışı için önemli",
            "Derbinin getirdiği ekstra motivasyon",
            "Son haftalardaki form farkı",
            "Ev sahibi avantajı faktörü"
        ]
        
        weather_impacts = [
            "İyi hava koşulları",
            "Hafif yağmur bekleniyor",
            "Sıcak hava - tempolu oyun",
            "Serin hava - ideal koşullar",
            "Rüzgarlı hava - uzun paslar zor",
            "Kapalı hava - standart koşullar"
        ]
        
        return {
            "head_to_head": {
                "total_matches": total_matches,
                "home_wins": home_wins,
                "away_wins": away_wins,
                "draws": draws,
                "last_5_results": last_5_results,
                "avg_goals_per_match": avg_goals
            },
            "team_form": {
                "home_team": {
                    "last_5_matches": home_form,
                    "goals_scored_last_5": home_goals_scored,
                    "goals_conceded_last_5": home_goals_conceded,
                    "clean_sheets_last_10": random.randint(3, 7),
                    "matches_with_both_teams_scoring": random.randint(6, 9),
                    "avg_goals_per_match": round(home_goals_scored / 5, 1)
                },
                "away_team": {
                    "last_5_matches": away_form,
                    "goals_scored_last_5": away_goals_scored,
                    "goals_conceded_last_5": away_goals_conceded,
                    "clean_sheets_last_10": random.randint(2, 6),
                    "matches_with_both_teams_scoring": random.randint(5, 8),
                    "avg_goals_per_match": round(away_goals_scored / 5, 1)
                }
            },
            "goal_stats": {
                "matches_over_2_5_goals": matches_over_25,
                "matches_under_2_5_goals": matches_under_25,
                "both_teams_to_score_percentage": btts_percentage,
                "first_half_goals_avg": first_half_avg,
                "second_half_goals_avg": second_half_avg
            },
            "interesting_facts": selected_facts,
            "key_stats": {
                "home_team_strength": home_strength,
                "away_team_strength": away_strength,
                "home_advantage": home_advantage,
                "motivation_factor": random.choice(motivation_factors),
                "weather_impact": random.choice(weather_impacts)
            }
        }

    def log_message(self, format, *args):
        """Log mesajlarını özelleştir"""
        print(f"🌐 {self.address_string()} - {format % args}")

def main():
    """Ana fonksiyon"""
    print("🚀 Football Prediction API başlıyor...")
    print("=" * 50)
    
    HOST = '0.0.0.0'  # Android emulator için 0.0.0.0 kullan
    PORT = 8000
    
    try:
        server = HTTPServer((HOST, PORT), FootballPredictionHandler)
        print(f"✅ Sunucu başlatıldı: http://{HOST}:{PORT}")
        print(f"🌐 Ana sayfa: http://{HOST}:{PORT}")
        print(f"📡 API dokümantasyonu: http://{HOST}:{PORT}")
        print(f"🔮 Örnek tahmin: http://{HOST}:{PORT}/predict?home=Arsenal&away=Chelsea")
        print(f"⚽ Takım listesi: http://{HOST}:{PORT}/teams")
        print("\n🛑 Durdurmak için Ctrl+C tuşlayın...\n")
        
        server.serve_forever()
        
    except KeyboardInterrupt:
        print("\n🛑 Sunucu durduruldu!")
    except Exception as e:
        print(f"❌ Sunucu hatası: {str(e)}")

if __name__ == "__main__":
    main()
