import '../domain/catalog/weather_mood_mapper.dart';
import '../domain/entities/home_weather_context.dart';
import '../domain/enums/driviq_weather_mood.dart';
import 'interfaces/weather_mood_service.dart';

/// Mock resolver — time-based fallback until location + weather API is wired.
class MockWeatherMoodService implements WeatherMoodService {
  MockWeatherMoodService({DriviqWeatherMood? debugMood}) : _debugMood = debugMood;

  final DriviqWeatherMood? _debugMood;

  @override
  Future<HomeWeatherContext> resolveHomeWeather() async {
    await Future<void>.delayed(const Duration(milliseconds: 8));

    final mood = _debugMood ?? _autoMood();
    return HomeWeatherContext(
      mood: mood,
      effectsEnabled: true,
      isLive: _debugMood == null,
    );
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

  DriviqWeatherMood _autoMood() {
    final now = DateTime.now();
    final isNight = WeatherMoodMapper.isNightHour(now.hour);
    if (isNight) return DriviqWeatherMood.clearNight;

    // Visible premium demo cycle by hour — replace with API when ready.
    return switch (now.hour % 6) {
      0 => DriviqWeatherMood.clearDay,
      1 => DriviqWeatherMood.cloudy,
      2 => DriviqWeatherMood.rain,
      3 => DriviqWeatherMood.snow,
      4 => DriviqWeatherMood.fog,
      _ => DriviqWeatherMood.storm,
    };
  }
}
