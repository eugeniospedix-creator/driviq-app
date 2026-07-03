import '../enums/driviq_weather_mood.dart';

/// Maps external weather condition codes to [DriviqWeatherMood].
/// Ready for OpenWeather / WeatherKit integration — not wired yet.
abstract final class WeatherMoodMapper {
  static DriviqWeatherMood fromOpenWeatherMain(String? main, {required bool isNight}) {
    if (isNight) return DriviqWeatherMood.night;

    return switch (main?.toLowerCase()) {
      'clear' => DriviqWeatherMood.sunny,
      'clouds' => DriviqWeatherMood.cloudy,
      'rain' || 'drizzle' || 'thunderstorm' => DriviqWeatherMood.rainy,
      'snow' => DriviqWeatherMood.snowy,
      'mist' || 'fog' || 'haze' => DriviqWeatherMood.foggy,
      _ => DriviqWeatherMood.studio,
    };
  }

  static bool isNightHour(int hour) => hour >= 20 || hour < 6;
}
