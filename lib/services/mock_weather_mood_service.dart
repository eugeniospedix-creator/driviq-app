import '../domain/catalog/weather_mood_mapper.dart';
import '../domain/entities/home_weather_context.dart';
import '../domain/enums/driviq_weather_mood.dart';
import 'interfaces/weather_mood_service.dart';

/// Temporary resolver until location + weather API is wired.
/// Night is inferred from local time; everything else falls back to studio.
class MockWeatherMoodService implements WeatherMoodService {
  MockWeatherMoodService({DriviqWeatherMood? debugMood}) : _debugMood = debugMood;

  /// Set to preview a mood without a weather API. `null` = auto.
  final DriviqWeatherMood? _debugMood;

  @override
  Future<HomeWeatherContext> resolveHomeWeather() async {
    await Future<void>.delayed(const Duration(milliseconds: 16));

    final mood = _debugMood ?? _autoMood();
    if (mood == DriviqWeatherMood.studio) {
      return HomeWeatherContext.fallback;
    }

    return HomeWeatherContext(
      mood: mood,
      effectsEnabled: true,
      isLive: _debugMood == null && mood == DriviqWeatherMood.night,
    );
  }

  DriviqWeatherMood _autoMood() {
    if (WeatherMoodMapper.isNightHour(DateTime.now().hour)) {
      return DriviqWeatherMood.night;
    }
    return DriviqWeatherMood.studio;
  }
}
