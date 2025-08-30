#!/usr/bin/env python3
"""
🚀 Development Setup Script
Otomatik IP detection ve Flutter app configuration
"""

import socket
import platform
import re
import os

def get_local_ip():
    """Local IP adresini otomatik tespit et"""
    try:
        # En yaygın yöntem
        s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        s.connect(("8.8.8.8", 80))
        ip = s.getsockname()[0]
        s.close()
        return ip
    except Exception:
        return "192.168.1.100"  # Fallback

def update_flutter_config(ip_address):
    """Flutter app constants'ını güncelle"""
    config_file = "football_prediction_app/lib/constants/app_constants.dart"
    
    if not os.path.exists(config_file):
        print(f"❌ {config_file} bulunamadı!")
        return False
    
    try:
        with open(config_file, 'r', encoding='utf-8') as f:
            content = f.read()
        
        # IP adresini güncelle
        pattern = r"static const String _developmentBaseUrl = 'http://[\d\.]+:8000';"
        replacement = f"static const String _developmentBaseUrl = 'http://{ip_address}:8000';"
        
        updated_content = re.sub(pattern, replacement, content)
        
        with open(config_file, 'w', encoding='utf-8') as f:
            f.write(updated_content)
        
        print(f"✅ Flutter config updated: {ip_address}:8000")
        return True
        
    except Exception as e:
        print(f"❌ Config update failed: {e}")
        return False

def main():
    print("🚀 Football Prediction App - Development Setup")
    print("=" * 50)
    
    # IP adresini tespit et
    ip_address = get_local_ip()
    print(f"🔍 Local IP detected: {ip_address}")
    
    # Kullanıcıdan onay al
    user_ip = input(f"IP adresi doğru mu? ({ip_address}) [Y/n]: ").strip().lower()
    
    if user_ip in ['n', 'no']:
        ip_address = input("Doğru IP adresini girin: ").strip()
    
    # Flutter config'i güncelle
    if update_flutter_config(ip_address):
        print("\n🎉 Setup completed successfully!")
        print(f"📱 Mobile devices can connect to: http://{ip_address}:8000")
        print("\n📋 Next steps:")
        print("1. Start API: cd src && python simple_api.py")
        print("2. Run Flutter: cd football_prediction_app && flutter run")
    else:
        print("\n❌ Setup failed!")

if __name__ == "__main__":
    main()
