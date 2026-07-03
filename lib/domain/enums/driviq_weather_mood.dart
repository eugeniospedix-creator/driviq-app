/// Ambient mood for the Home vehicle hero — driven by local weather/time.
enum DriviqWeatherMood {
  studio,
  sunny,
  cloudy,
  rainy,
  snowy,
  foggy,
  night;

  bool get isAnimated => this == DriviqWeatherMood.rainy || this == DriviqWeatherMood.snowy;

  bool get usesParticles => isAnimated;
}
