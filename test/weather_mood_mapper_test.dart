import 'package:flutter_test/flutter_test.dart';

import 'package:driviq/domain/catalog/weather_mood_mapper.dart';
import 'package:driviq/domain/enums/driviq_weather_mood.dart';

void main() {
  test('maps OpenWeather conditions to moods', () {
    expect(
      WeatherMoodMapper.fromOpenWeather(main: 'Clear', description: null, isNight: false),
      DriviqWeatherMood.clearDay,
    );
    expect(
      WeatherMoodMapper.fromOpenWeather(main: 'Clear', description: null, isNight: true),
      DriviqWeatherMood.clearNight,
    );
    expect(
      WeatherMoodMapper.fromOpenWeather(main: 'Clouds', description: 'overcast', isNight: false),
      DriviqWeatherMood.cloudy,
    );
    expect(
      WeatherMoodMapper.fromOpenWeather(main: 'Rain', description: 'light rain', isNight: false),
      DriviqWeatherMood.rain,
    );
    expect(
      WeatherMoodMapper.fromOpenWeather(main: 'Snow', description: null, isNight: false),
      DriviqWeatherMood.snow,
    );
    expect(
      WeatherMoodMapper.fromOpenWeather(main: 'Thunderstorm', description: null, isNight: false),
      DriviqWeatherMood.storm,
    );
    expect(
      WeatherMoodMapper.fromOpenWeather(main: 'Fog', description: null, isNight: false),
      DriviqWeatherMood.fog,
    );
  });

  test('detects night hours', () {
    expect(WeatherMoodMapper.isNightHour(21), isTrue);
    expect(WeatherMoodMapper.isNightHour(5), isTrue);
    expect(WeatherMoodMapper.isNightHour(12), isFalse);
  });
}
