import '../../domain/entities/home_weather_context.dart';

/// Resolves the Home hero weather mood from device location / weather APIs.
abstract interface class WeatherMoodService {
  Future<HomeWeatherContext> resolveHomeWeather();
}
