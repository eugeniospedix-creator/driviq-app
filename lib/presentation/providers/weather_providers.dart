import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/home_weather_context.dart';
import '../../domain/enums/driviq_weather_mood.dart';
import '../../services/interfaces/weather_mood_service.dart';
import '../../services/mock_weather_mood_service.dart';

final weatherMoodServiceProvider = Provider<WeatherMoodService>((ref) {
  final override = ref.watch(weatherMoodOverrideProvider);
  return MockWeatherMoodService(debugMood: override);
});

/// Dev / QA override — set to `null` for automatic behaviour.
final weatherMoodOverrideProvider = Provider<DriviqWeatherMood?>((ref) => null);

final homeWeatherContextProvider = FutureProvider<HomeWeatherContext>((ref) async {
  return ref.watch(weatherMoodServiceProvider).resolveHomeWeather();
});
