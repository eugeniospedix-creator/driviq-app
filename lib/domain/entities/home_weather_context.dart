import '../enums/driviq_weather_mood.dart';

/// Resolved weather mood for the Home hero atmosphere.
class HomeWeatherContext {
  const HomeWeatherContext({
    required this.mood,
    required this.effectsEnabled,
    this.isLive = false,
  });

  final DriviqWeatherMood mood;
  final bool effectsEnabled;
  final bool isLive;

  static const fallback = HomeWeatherContext(
    mood: DriviqWeatherMood.unknown,
    effectsEnabled: false,
    isLive: false,
  );

  /// Particle overlays (rain, snow, fog) — only when API returned live data.
  bool get showEffects => isLive && effectsEnabled;

  HomeWeatherContext copyWith({
    DriviqWeatherMood? mood,
    bool? effectsEnabled,
    bool? isLive,
  }) {
    return HomeWeatherContext(
      mood: mood ?? this.mood,
      effectsEnabled: effectsEnabled ?? this.effectsEnabled,
      isLive: isLive ?? this.isLive,
    );
  }
}
