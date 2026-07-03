import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:geolocator/geolocator.dart';

import '../domain/catalog/weather_mood_mapper.dart';
import '../domain/entities/home_weather_context.dart';
import '../domain/enums/driviq_weather_mood.dart';
import 'interfaces/weather_mood_service.dart';

/// Resolves live weather from device location + Open-Meteo (no API key).
class LiveWeatherMoodService implements WeatherMoodService {
  LiveWeatherMoodService({HttpClient? client}) : _client = client ?? HttpClient();

  final HttpClient _client;

  @override
  Future<HomeWeatherContext> resolveHomeWeather() async {
    try {
      final position = await _currentPosition();
      if (position == null) {
        return HomeWeatherContext.fallback;
      }

      final uri = Uri.https('api.open-meteo.com', '/v1/forecast', {
        'latitude': position.latitude.toStringAsFixed(5),
        'longitude': position.longitude.toStringAsFixed(5),
        'current': 'weather_code,is_day',
        'timezone': 'auto',
      });

      final request = await _client.getUrl(uri).timeout(const Duration(seconds: 5));
      final response = await request.close().timeout(const Duration(seconds: 6));
      if (response.statusCode < 200 || response.statusCode >= 300) {
        return HomeWeatherContext.fallback;
      }

      final body = await response.transform(utf8.decoder).join();
      final json = jsonDecode(body) as Map<String, dynamic>;
      final current = json['current'] as Map<String, dynamic>?;
      final code = (current?['weather_code'] as num?)?.toInt();
      final isDay = (current?['is_day'] as num?)?.toInt() == 1;
      final mood = WeatherMoodMapper.fromOpenMeteoCode(code, isDay: isDay);

      if (mood == DriviqWeatherMood.unknown) {
        return HomeWeatherContext.fallback;
      }

      return HomeWeatherContext(
        mood: mood,
        effectsEnabled: true,
        isLive: true,
      );
    } catch (_) {
      return HomeWeatherContext.fallback;
    }
  }

  @override
  DriviqWeatherMood moodFromWeatherCode({
    required String? conditionMain,
    required String? conditionDescription,
    required bool isNight,
  }) {
    return WeatherMoodMapper.fromOpenWeather(
      main: conditionMain,
      description: conditionDescription,
      isNight: isNight,
    );
  }

  Future<Position?> _currentPosition() async {
    if (!await Geolocator.isLocationServiceEnabled()) return null;

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return null;
    }

    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.low,
        timeLimit: Duration(seconds: 5),
      ),
    ).timeout(const Duration(seconds: 6));
  }
}
