class HourForecast {
  final DateTime time;
  final double tempC;
  final int conditionCode;
  final String conditionText;
  final String iconUrl;
  final double chanceOfRain;
  final bool isDay;

  const HourForecast({
    required this.time,
    required this.tempC,
    required this.conditionCode,
    required this.conditionText,
    required this.iconUrl,
    required this.chanceOfRain,
    required this.isDay,
  });

  factory HourForecast.fromJson(Map<String, dynamic> json) {
    final condition = json['condition'] as Map<String, dynamic>? ?? const {};
    final iconRaw = (condition['icon'] as String?) ?? '';
    final epoch = (json['time_epoch'] as num?)?.toInt() ?? 0;
    return HourForecast(
      time: DateTime.fromMillisecondsSinceEpoch(epoch * 1000),
      tempC: (json['temp_c'] as num?)?.toDouble() ?? 0,
      conditionCode: (condition['code'] as num?)?.toInt() ?? 1000,
      conditionText: (condition['text'] as String?) ?? '',
      iconUrl: iconRaw.startsWith('//') ? 'https:$iconRaw' : iconRaw,
      chanceOfRain: (json['chance_of_rain'] as num?)?.toDouble() ?? 0,
      isDay: ((json['is_day'] as num?)?.toInt() ?? 1) == 1,
    );
  }
}
