import '../../domain/entities/home_weather_context.dart';
import '../../domain/enums/driviq_weather_mood.dart';

/// Resolves [DriviqWeatherMood] from device location and/or weather API codes.
abstract interface class WeatherMoodService {
  Future<HomeWeatherContext> resolveHomeWeather();

  /// Direct mapping when lat/lon weather payload is already available.
  DriviqWeatherMood moodFromWeatherCode({
    required String? conditionMain,
    required String? conditionDescription,
    required bool isNight,
  });
}
