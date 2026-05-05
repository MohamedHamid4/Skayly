enum WeatherMood {
  sunny,
  partlyCloudy,
  cloudy,
  rainy,
  thunderstorm,
  snowy,
  foggy,
  clearNight,
  cloudyNight,
}

class WeatherMoodMapper {
  WeatherMoodMapper._();

  // WeatherAPI.com condition codes:
  // https://www.weatherapi.com/docs/conditions.json
  static WeatherMood fromConditionCode(int code, {required bool isDay}) {
    if (code == 1000) {
      return isDay ? WeatherMood.sunny : WeatherMood.clearNight;
    }
    if (code == 1003) {
      return isDay ? WeatherMood.partlyCloudy : WeatherMood.cloudyNight;
    }
    if (code == 1006 || code == 1009) {
      return isDay ? WeatherMood.cloudy : WeatherMood.cloudyNight;
    }
    if (code == 1030 || code == 1135 || code == 1147) {
      return WeatherMood.foggy;
    }
    if (code == 1087 ||
        code == 1273 ||
        code == 1276 ||
        code == 1279 ||
        code == 1282) {
      return WeatherMood.thunderstorm;
    }
    const snowCodes = {
      1066, 1069, 1072, 1114, 1117, 1168, 1171, 1198, 1201, 1204, 1207,
      1210, 1213, 1216, 1219, 1222, 1225, 1237, 1249, 1252, 1255, 1258,
      1261, 1264,
    };
    if (snowCodes.contains(code)) return WeatherMood.snowy;

    const rainCodes = {
      1063, 1150, 1153, 1180, 1183, 1186, 1189, 1192, 1195, 1240, 1243, 1246,
    };
    if (rainCodes.contains(code)) return WeatherMood.rainy;

    return isDay ? WeatherMood.cloudy : WeatherMood.cloudyNight;
  }
}
