/// Ambient mood for the Home vehicle hero — driven by local weather/time.
enum DriviqWeatherMood {
  clearDay,
  clearNight,
  cloudy,
  rain,
  snow,
  fog,
  storm,
  unknown;

  bool get isAnimated =>
      this == DriviqWeatherMood.rain ||
      this == DriviqWeatherMood.snow ||
      this == DriviqWeatherMood.storm;

  bool get usesParticles => isAnimated;

  bool get usesLightning => this == DriviqWeatherMood.storm;
}
