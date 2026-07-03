import '../domain/entities/home_weather_context.dart';
import '../domain/enums/driviq_weather_mood.dart';
import 'interfaces/weather_mood_service.dart';
import 'live_weather_mood_service.dart';

/// Tries live location weather; returns neutral [HomeWeatherContext.fallback] when unavailable.
class CompositeWeatherMoodService implements WeatherMoodService {
  CompositeWeatherMoodService({
    required LiveWeatherMoodService live,
    DriviqWeatherMood? debugMood,
  })  : _live = live,
        _debugMood = debugMood;

  final LiveWeatherMoodService _live;
  final DriviqWeatherMood? _debugMood;

  @override
  Future<HomeWeatherContext> resolveHomeWeather() async {
    if (_debugMood != null) {
      return HomeWeatherContext(
        mood: _debugMood,
        effectsEnabled: false,
        isLive: false,
      );
    }

    final live = await _live.resolveHomeWeather();
    if (live.isLive && live.mood != DriviqWeatherMood.unknown) {
      return live;
    }

    return HomeWeatherContext.fallback;
  }

  @override
  DriviqWeatherMood moodFromWeatherCode({
    required String? conditionMain,
    required String? conditionDescription,
    required bool isNight,
  }) {
    return _live.moodFromWeatherCode(
      conditionMain: conditionMain,
      conditionDescription: conditionDescription,
      isNight: isNight,
    );
  }
}
