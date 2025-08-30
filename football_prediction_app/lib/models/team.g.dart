// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'team.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TeamsResponse _$TeamsResponseFromJson(Map<String, dynamic> json) =>
    TeamsResponse(
      success: json['success'] as bool,
      count: (json['count'] as num).toInt(),
      teams: (json['teams'] as List<dynamic>).map((e) => e as String).toList(),
    );

Map<String, dynamic> _$TeamsResponseToJson(TeamsResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'count': instance.count,
      'teams': instance.teams,
    };
