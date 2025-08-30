import 'package:json_annotation/json_annotation.dart';

part 'team.g.dart';

@JsonSerializable()
class TeamsResponse {
  @JsonKey(name: 'success')
  final bool success;
  
  @JsonKey(name: 'count')
  final int count;
  
  @JsonKey(name: 'teams')
  final List<String> teams;

  const TeamsResponse({
    required this.success,
    required this.count,
    required this.teams,
  });

  factory TeamsResponse.fromJson(Map<String, dynamic> json) =>
      _$TeamsResponseFromJson(json);

  Map<String, dynamic> toJson() => _$TeamsResponseToJson(this);
}

class Team {
  final String name;
  final String displayName;
  final String emoji;
  final String? logoUrl;

  const Team({
    required this.name,
    required this.displayName,
    required this.emoji,
    this.logoUrl,
  });

  /// Takım isminden Team objesi oluşturur
  factory Team.fromName(String name) {
    return Team(
      name: name,
      displayName: _getDisplayName(name),
      emoji: _getTeamEmoji(name),
    );
  }

  /// Takım adını daha okunabilir hale getirir
  static String _getDisplayName(String name) {
    // Bazı yaygın kısaltmaları düzelt
    final Map<String, String> displayNameMap = {
      'Man United': 'Manchester United',
      'Man City': 'Manchester City',
      'Brighton': 'Brighton & Hove Albion',
      'Tottenham': 'Tottenham Hotspur',
      'West Ham': 'West Ham United',
      'Newcastle': 'Newcastle United',
      'Crystal Palace': 'Crystal Palace',
      'Sheffield United': 'Sheffield United',
      'Norwich': 'Norwich City',
      'Leicester': 'Leicester City',
    };
    
    return displayNameMap[name] ?? name;
  }

  /// Takım logosu URL'si döndürür - Çoklu kaynak desteği
  static String getTeamLogoUrl(String name) {
    final Map<String, String> logoUrlMap = {
      // Premier League takımları - Ana takımlar (Çoklu kaynak)
      'Arsenal': 'https://img.icons8.com/?size=100&id=21738&format=png&color=000000',
      'Chelsea': 'https://img.icons8.com/?size=100&id=21734&format=png&color=000000',
      'Liverpool': 'https://img.icons8.com/?size=100&id=21735&format=png&color=000000',
      'Man City': 'https://img.icons8.com/?size=100&id=21899&format=png&color=000000',
      'Manchester City': 'https://img.icons8.com/?size=100&id=21899&format=png&color=000000',
      'Man United': 'https://assets.stickpng.com/images/580b57fcd9996e24bc43c4e7.png',
      'Manchester United': 'https://assets.stickpng.com/images/580b57fcd9996e24bc43c4e7.png',
      'Tottenham': 'https://img.icons8.com/?size=100&id=moGvWnJxj14m&format=png&color=000000',
      'Tottenham Hotspur': 'https://img.icons8.com/?size=100&id=moGvWnJxj14m&format=png&color=000000',

      //ManU hariç hatalı
      
      // Icons8 fallback URL'leri
      'Newcastle': 'https://assets.stickpng.com/images/580b57fcd9996e24bc43c4ec.png',
      'Newcastle United': 'https://img.icons8.com/color/96/newcastle-united-fc.png',
      'Brighton': 'https://img.icons8.com/color/96/brighton-hove-albion-fc.png',
      'Brighton & Hove Albion': 'https://img.icons8.com/color/96/brighton-hove-albion-fc.png',
      'Aston Villa': 'https://img.icons8.com/color/96/aston-villa-fc.png',
      'West Ham': 'https://img.icons8.com/color/96/west-ham-united-fc.png',
      'West Ham United': 'https://img.icons8.com/color/96/west-ham-united-fc.png',
      'Crystal Palace': 'https://img.icons8.com/color/96/crystal-palace-fc.png',
      'Leicester': 'https://assets.stickpng.com/images/580b57fcd9996e24bc43c4e8.png',
      'Leicester City': 'https://assets.stickpng.com/images/580b57fcd9996e24bc43c4e8.png',
      'Everton': 'https://img.icons8.com/color/96/everton-fc.png',
      'Southampton': 'https://assets.stickpng.com/images/580b57fcd9996e24bc43c4ea.png',
      'Burnley': 'https://img.icons8.com/color/96/burnley-fc.png',
      'Norwich': 'https://assets.stickpng.com/images/580b57fcd9996e24bc43c4e9.png',
      'Norwich City': 'https://assets.stickpng.com/images/580b57fcd9996e24bc43c4e9.png',
      'Watford': 'https://img.icons8.com/color/96/watford-fc.png',
      'Wolves': 'https://img.icons8.com/color/96/wolverhampton-wanderers-fc.png',
      'Wolverhampton Wanderers': 'https://img.icons8.com/color/96/wolverhampton-wanderers-fc.png',
      'Leeds': 'https://img.icons8.com/color/96/leeds-united-fc.png',
      'Blackburn': 'https://img.icons8.com/color/96/blackburn-rovers-fc.png',
      'Birmingham': 'https://img.icons8.com/color/96/birmingham-city-fc.png',
      'Fulham': 'https://img.icons8.com/color/96/fulham-fc.png',
      'Brentford': 'https://img.icons8.com/color/96/brentford-fc.png',
      
      // 2005-2018 dönemindeki diğer takımlar
      'Sheffield United': 'https://img.icons8.com/color/96/sheffield-united-fc.png',
      'Bournemouth': 'https://img.icons8.com/color/96/afc-bournemouth.png',
      'Cardiff': 'https://img.icons8.com/color/96/cardiff-city-fc.png',
      'Huddersfield': 'https://img.icons8.com/color/96/huddersfield-town-fc.png',
      'Stoke': 'https://assets.stickpng.com/images/580b57fcd9996e24bc43c4eb.png',
      'Swansea': 'https://img.icons8.com/color/96/swansea-city-fc.png',
      'Hull': 'https://img.icons8.com/color/96/hull-city-fc.png',
      'Middlesbrough': 'https://img.icons8.com/color/96/middlesbrough-fc.png',
      'Sunderland': 'https://img.icons8.com/color/96/sunderland-afc.png',
      'QPR': 'https://img.icons8.com/color/96/queens-park-rangers-fc.png',
      'Queens Park Rangers': 'https://img.icons8.com/color/96/queens-park-rangers-fc.png',
      'Derby': 'https://img.icons8.com/color/96/derby-county-fc.png',
      'Bolton': 'https://img.icons8.com/color/96/bolton-wanderers-fc.png',
      'Wigan': 'https://img.icons8.com/color/96/wigan-athletic-fc.png',
      'Reading': 'https://img.icons8.com/color/96/reading-fc.png',
      'Blackpool': 'https://img.icons8.com/color/96/blackpool-fc.png',
      
      // Potansiyel eksik takımlar için genel futbol logosu
      'West Brom': 'https://img.icons8.com/color/96/west-bromwich-albion-fc.png',
      'West Bromwich Albion': 'https://img.icons8.com/color/96/west-bromwich-albion-fc.png',
      'Nottingham Forest': 'https://img.icons8.com/color/96/nottingham-forest-fc.png',
      'Sheffield Wednesday': 'https://img.icons8.com/color/96/sheffield-wednesday-fc.png',
    };
    
    return logoUrlMap[name] ?? 'https://img.icons8.com/fluency/96/football.png';
  }

  /// Takıma uygun emoji döndürür
  static String _getTeamEmoji(String name) {
    final Map<String, String> emojiMap = {
      // Premier League takımları
      'Arsenal': '🔴',
      'Chelsea': '🔵',
      'Liverpool': '🔴',
      'Man City': '💙',
      'Manchester City': '💙',
      'Man United': '🔴',
      'Manchester United': '🔴',
      'Tottenham': '⚪',
      'Tottenham Hotspur': '⚪',
      'Newcastle': '⚫',
      'Newcastle United': '⚫',
      'Brighton': '🔵',
      'Brighton & Hove Albion': '🔵',
      'Aston Villa': '🟣',
      'West Ham': '🟤',
      'West Ham United': '🟤',
      'Crystal Palace': '🔴',
      'Leicester': '🔵',
      'Leicester City': '🔵',
      'Everton': '🔵',
      'Southampton': '🔴',
      'Burnley': '🟤',
      'Sheffield United': '🔴',
      'Norwich': '🟡',
      'Norwich City': '🟡',
      'Watford': '🟡',
      'Bournemouth': '🔴',
      'Fulham': '⚫',
      'Cardiff': '🔴',
      'Huddersfield': '🔵',
      'Stoke': '🔴',
      'Swansea': '⚪',
      'Hull': '🟡',
      'Middlesbrough': '🔴',
      'Sunderland': '🔴',
      'Reading': '🔵',
      'Birmingham': '🔵',
      'Blackpool': '🟡',
      'Bolton': '⚪',
      'Wigan': '🔵',
      'Wolves': '🟡',
      'Wolverhampton Wanderers': '🟡',
      'QPR': '🔵',
      'Leeds': '⚪',
      'Derby': '⚪',
      'Blackburn': '🔵',
    };
    
    return emojiMap[name] ?? '⚽';
  }

  /// Takım rengini döndürür (gelecekte logo rengi için kullanılabilir)
  static String getTeamColor(String name) {
    final Map<String, String> colorMap = {
      'Arsenal': '#DC143C',
      'Chelsea': '#034694',
      'Liverpool': '#C8102E',
      'Man City': '#6CABDD',
      'Manchester City': '#6CABDD',
      'Man United': '#DA020E',
      'Manchester United': '#DA020E',
      'Tottenham': '#132257',
      'Newcastle': '#241F20',
      'Brighton': '#0057B8',
      'Aston Villa': '#95BFE5',
      'West Ham': '#7A263A',
    };
    
    return colorMap[name] ?? '#6C6C80';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Team && runtimeType == other.runtimeType && name == other.name;

  @override
  int get hashCode => name.hashCode;

  @override
  String toString() => displayName;
}