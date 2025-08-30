#!/usr/bin/env python3
"""
🧪 Test Vercel API locally
"""

import requests
import json

def test_local_api():
    """Local API'yi test et"""
    base_url = "http://localhost:3000"  # Vercel dev server
    
    print("🧪 Testing Vercel API locally...")
    print("=" * 50)
    
    # Test health
    try:
        response = requests.get(f"{base_url}/api/health")
        print(f"✅ Health: {response.status_code}")
        print(f"📋 Response: {response.json()}")
    except Exception as e:
        print(f"❌ Health failed: {e}")
    
    print("\n" + "-" * 30)
    
    # Test teams
    try:
        response = requests.get(f"{base_url}/api/teams")
        print(f"✅ Teams: {response.status_code}")
        data = response.json()
        print(f"📋 Teams count: {data.get('count', 0)}")
    except Exception as e:
        print(f"❌ Teams failed: {e}")
    
    print("\n" + "-" * 30)
    
    # Test prediction
    try:
        payload = {
            "home_team": "Arsenal",
            "away_team": "Chelsea"
        }
        response = requests.post(f"{base_url}/api/predict", json=payload)
        print(f"✅ Prediction: {response.status_code}")
        data = response.json()
        if data.get('success'):
            pred = data['prediction']
            print(f"⚽ Score: {pred['home_goals']}-{pred['away_goals']}")
            print(f"🎯 Result: {pred['result_text']}")
            print(f"🔮 Confidence: {pred['confidence']}")
    except Exception as e:
        print(f"❌ Prediction failed: {e}")

if __name__ == "__main__":
    test_local_api()
