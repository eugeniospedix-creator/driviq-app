import 'package:flutter_test/flutter_test.dart';

import 'package:driviq/domain/catalog/weather_mood_mapper.dart';
import 'package:driviq/domain/enums/driviq_weather_mood.dart';

void main() {
  test('maps OpenWeather main codes to moods', () {
    expect(WeatherMoodMapper.fromOpenWeatherMain('Clear', isNight: false), DriviqWeatherMood.sunny);
    expect(WeatherMoodMapper.fromOpenWeatherMain('Clouds', isNight: false), DriviqWeatherMood.cloudy);
    expect(WeatherMoodMapper.fromOpenWeatherMain('Rain', isNight: false), DriviqWeatherMood.rainy);
    expect(WeatherMoodMapper.fromOpenWeatherMain('Snow', isNight: false), DriviqWeatherMood.snowy);
    expect(WeatherMoodMapper.fromOpenWeatherMain('Fog', isNight: false), DriviqWeatherMood.foggy);
    expect(WeatherMoodMapper.fromOpenWeatherMain('Clear', isNight: true), DriviqWeatherMood.night);
  });

  test('detects night hours', () {
    expect(WeatherMoodMapper.isNightHour(21), isTrue);
    expect(WeatherMoodMapper.isNightHour(5), isTrue);
    expect(WeatherMoodMapper.isNightHour(12), isFalse);
  });
}
