import '../enums/driviq_weather_mood.dart';

/// Maps external weather condition codes to [DriviqWeatherMood].
abstract final class WeatherMoodMapper {
  static bool isNightHour(int hour) => hour >= 20 || hour < 6;

  static DriviqWeatherMood fromOpenWeather({
    required String? main,
    required String? description,
    required bool isNight,
  }) {
    final token = '${main ?? ''} ${description ?? ''}'.toLowerCase();

    if (token.contains('thunder')) return DriviqWeatherMood.storm;
    if (token.contains('snow') || token.contains('sleet')) return DriviqWeatherMood.snow;
    if (token.contains('rain') || token.contains('drizzle')) return DriviqWeatherMood.rain;
    if (token.contains('fog') || token.contains('mist') || token.contains('haze')) {
      return DriviqWeatherMood.fog;
    }
    if (token.contains('cloud') || token.contains('overcast')) return DriviqWeatherMood.cloudy;
    if (token.contains('clear')) {
      return isNight ? DriviqWeatherMood.clearNight : DriviqWeatherMood.clearDay;
    }

    return DriviqWeatherMood.unknown;
  }

  static DriviqWeatherMood fromCoordinatesFallback({required bool isNight}) {
    return isNight ? DriviqWeatherMood.clearNight : DriviqWeatherMood.clearDay;
  }

  /// Maps WMO weather codes from Open-Meteo to [DriviqWeatherMood].
  static DriviqWeatherMood fromOpenMeteoCode(int? code, {required bool isDay}) {
    if (code == null) return DriviqWeatherMood.unknown;

    if (code == 0) {
      return isDay ? DriviqWeatherMood.clearDay : DriviqWeatherMood.clearNight;
    }
    if (code == 1 || code == 2 || code == 3) return DriviqWeatherMood.cloudy;
    if (code == 45 || code == 48) return DriviqWeatherMood.fog;
    if ((code >= 51 && code <= 67) || (code >= 80 && code <= 82)) {
      return DriviqWeatherMood.rain;
    }
    if ((code >= 71 && code <= 77) || (code >= 85 && code <= 86)) {
      return DriviqWeatherMood.snow;
    }
    if (code >= 95 && code <= 99) return DriviqWeatherMood.storm;
    return DriviqWeatherMood.unknown;
  }
}
