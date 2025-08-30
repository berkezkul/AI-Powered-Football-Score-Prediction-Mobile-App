from http.server import BaseHTTPRequestHandler
import json
from datetime import datetime

class handler(BaseHTTPRequestHandler):
    def do_GET(self):
        self.send_response(200)
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Content-Type', 'application/json')
        self.end_headers()
        
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
        
        self.wfile.write(json.dumps(response).encode())
