from http.server import BaseHTTPRequestHandler
import json
import urllib.parse
import random
from datetime import datetime

class handler(BaseHTTPRequestHandler):
    def do_GET(self):
        """GET istekleri"""
        path = self.path
        
        # CORS headers
        self.send_response(200)
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Access-Control-Allow-Methods', 'GET, POST, OPTIONS')
        self.send_header('Access-Control-Allow-Headers', 'Content-Type')
        self.send_header('Content-Type', 'application/json')
        self.end_headers()
        
        if path == '/' or path == '/api':
            # Ana sayfa
            response = {
                "message": "⚽ Football Prediction API on Vercel",
                "version": "1.0.0",
                "status": "running",
                "provider": "Vercel Serverless",
                "endpoints": {
                    "health": "/api/health",
                    "teams": "/api/teams", 
                    "predict": "/api/predict (POST)"
                }
            }
        elif path == '/api/health':
            # Health check
            response = {
                "status": "healthy",
                "timestamp": datetime.now().isoformat(),
                "service": "football-prediction-api",
                "version": "1.0.0",
                "provider": "Vercel"
            }
        elif path == '/api/teams':
            # Teams list
            teams = [
                "Arsenal", "Aston Villa", "Birmingham", "Blackburn", "Blackpool",
                "Bolton", "Bournemouth", "Brentford", "Brighton", "Burnley",
                "Cardiff", "Chelsea", "Crystal Palace", "Derby", "Everton",
                "Fulham", "Hull", "Huddersfield", "Leicester", "Liverpool",
                "Man City", "Man United", "Middlesbrough", "Newcastle",
                "Norwich", "Portsmouth", "QPR", "Reading", "Sheffield United",
                "Southampton", "Stoke", "Sunderland", "Swansea", "Tottenham",
                "Watford", "West Brom", "West Ham", "Wigan", "Wolves"
            ]
            response = {
                "teams": sorted(teams),
                "count": len(teams),
                "timestamp": datetime.now().isoformat()
            }
        else:
            response = {"error": "Endpoint not found", "path": path}
        
        self.wfile.write(json.dumps(response).encode())
    
    def do_POST(self):
        """POST istekleri"""
        # CORS headers
        self.send_response(200)
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Access-Control-Allow-Methods', 'GET, POST, OPTIONS')
        self.send_header('Access-Control-Allow-Headers', 'Content-Type')
        self.send_header('Content-Type', 'application/json')
        self.end_headers()
        
        if self.path == '/api/predict':
            try:
                # Request body oku
                content_length = int(self.headers['Content-Length'])
                post_data = self.rfile.read(content_length)
                request_data = json.loads(post_data.decode('utf-8'))
                
                home_team = request_data.get("home_team")
                away_team = request_data.get("away_team")
                
                if not home_team or not away_team:
                    response = {"error": "home_team ve away_team gerekli"}
                elif home_team == away_team:
                    response = {"error": "Aynı takım seçilemez"}
                else:
                    # Prediction generate et
                    prediction = self.generate_prediction(home_team, away_team)
                    detailed_analysis = self.generate_detailed_analysis(home_team, away_team)
                    
                    response = {
                        "success": True,
                        "match": {
                            "home_team": home_team,
                            "away_team": away_team
                        },
                        "prediction": {
                            "home_goals": prediction["home_goals"],
                            "away_goals": prediction["away_goals"], 
                            "result": prediction["result"],
                            "result_text": {
                                "H": "Ev Sahibi Galibiyeti",
                                "D": "Beraberlik", 
                                "A": "Deplasman Galibiyeti"
                            }[prediction["result"]],
                            "probabilities": prediction["probabilities"],
                            "confidence": prediction["confidence"]
                        },
                        "detailed_analysis": detailed_analysis,
                        "timestamp": datetime.now().isoformat()
                    }
                    
            except Exception as e:
                response = {"error": f"Sunucu hatası: {str(e)}"}
        else:
            response = {"error": "POST endpoint not found", "path": self.path}
        
        self.wfile.write(json.dumps(response).encode())
    
    def do_OPTIONS(self):
        """CORS preflight"""
        self.send_response(200)
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Access-Control-Allow-Methods', 'GET, POST, OPTIONS')
        self.send_header('Access-Control-Allow-Headers', 'Content-Type')
        self.end_headers()
    
    def generate_prediction(self, home_team, away_team):
        """AI tahmin oluştur"""
        # Home advantage
        home_advantage = random.uniform(0.1, 0.3)
        
        # Team strengths (mock)
        home_strength = random.uniform(0.6, 0.9)
        away_strength = random.uniform(0.5, 0.8)
        
        # Goal prediction
        home_goals = max(0, int(random.normalvariate(home_strength * 2 + home_advantage, 0.8)))
        away_goals = max(0, int(random.normalvariate(away_strength * 1.8, 0.7)))
        
        # Result
        if home_goals > away_goals:
            result = "H"
            home_prob = random.uniform(0.4, 0.7)
        elif home_goals < away_goals:
            result = "A"
            home_prob = random.uniform(0.1, 0.3)
        else:
            result = "D"
            home_prob = random.uniform(0.25, 0.4)
        
        draw_prob = random.uniform(0.15, 0.3)
        away_prob = 1.0 - home_prob - draw_prob
        
        # Normalize probabilities
        total = home_prob + draw_prob + away_prob
        home_prob /= total
        draw_prob /= total  
        away_prob /= total
        
        confidence = random.uniform(0.75, 0.95)
        
        return {
            "home_goals": home_goals,
            "away_goals": away_goals,
            "result": result,
            "probabilities": {
                "home": round(home_prob, 3),
                "draw": round(draw_prob, 3), 
                "away": round(away_prob, 3)
            },
            "confidence": round(confidence, 3)
        }
    
    def generate_detailed_analysis(self, home_team, away_team):
        """Detaylı analiz oluştur"""
        total_matches = random.randint(15, 25)
        home_wins = random.randint(4, total_matches // 2)
        away_wins = random.randint(3, total_matches - home_wins - 2)
        draws = total_matches - home_wins - away_wins
        
        return {
            "head_to_head": {
                "total_matches": total_matches,
                "home_wins": home_wins,
                "away_wins": away_wins,
                "draws": draws,
                "last_5_results": random.choices(['H', 'D', 'A'], k=5),
                "avg_goals_per_match": round(random.uniform(2.1, 3.2), 1)
            },
            "team_form": {
                "home_team": {
                    "last_5_matches": random.choices(['W', 'L', 'D'], weights=[0.5, 0.2, 0.3], k=5),
                    "goals_scored_last_5": random.randint(6, 12),
                    "goals_conceded_last_5": random.randint(3, 8),
                    "clean_sheets_last_10": random.randint(3, 7),
                    "matches_with_both_teams_scoring": random.randint(6, 9),
                    "avg_goals_per_match": round(random.uniform(1.2, 2.4), 1)
                },
                "away_team": {
                    "last_5_matches": random.choices(['W', 'L', 'D'], weights=[0.4, 0.3, 0.3], k=5),
                    "goals_scored_last_5": random.randint(4, 10),
                    "goals_conceded_last_5": random.randint(4, 9),
                    "clean_sheets_last_10": random.randint(2, 6),
                    "matches_with_both_teams_scoring": random.randint(5, 8),
                    "avg_goals_per_match": round(random.uniform(0.8, 2.0), 1)
                }
            },
            "goal_stats": {
                "matches_over_2_5_goals": random.randint(8, 15),
                "matches_under_2_5_goals": random.randint(5, 12),
                "both_teams_to_score_percentage": round(random.uniform(55, 85), 1),
                "first_half_goals_avg": round(random.uniform(0.8, 1.5), 1),
                "second_half_goals_avg": round(random.uniform(1.2, 2.0), 1)
            },
            "interesting_facts": [
                f"{home_team} son 5 ev sahibi maçında {random.randint(8, 15)} gol attı",
                f"{away_team} son {random.randint(6, 10)} deplasman maçında sadece {random.randint(1, 3)} mağlubiyet aldı",
                f"Bu iki takım arasındaki son {random.randint(3, 7)} maçta karşılıklı gol oldu",
                f"Bu maçın %{random.randint(65, 85)}'inde 2.5+ gol oluyor"
            ],
            "key_stats": {
                "home_team_strength": round(random.uniform(65, 85), 1),
                "away_team_strength": round(random.uniform(60, 80), 1),
                "home_advantage": round(random.uniform(0.12, 0.25), 2),
                "motivation_factor": random.choice([
                    "Lig sıralaması için kritik maç",
                    "Geçen sezondan rövanş alma hırsı", 
                    "Playoff yarışı için önemli"
                ]),
                "weather_impact": random.choice([
                    "İyi hava koşulları",
                    "Sıcak hava - tempolu oyun",
                    "Serin hava - ideal koşullar"
                ])
            }
        }
