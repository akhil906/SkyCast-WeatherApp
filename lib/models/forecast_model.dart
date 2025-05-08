class ForecastModel {
  final DateTime dateTime;
  final double temperature;
  final String condition;
  final int humidity;
  final double windSpeed;

  ForecastModel({
    required this.dateTime,
    required this.temperature,
    required this.condition,
    required this.humidity,
    required this.windSpeed,
  });

  factory ForecastModel.fromJson(Map<String, dynamic> json) {
    return ForecastModel(
      dateTime: DateTime.parse(json['dt_txt']),
      temperature: (json['main']['temp'] as num).toDouble(),
      condition: json['weather'][0]['main'],
      humidity: json['main']['humidity'],
      windSpeed: (json['wind']['speed'] as num).toDouble(),
    );
  }
}
