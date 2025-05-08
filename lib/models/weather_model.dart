class WeatherModel {
  final String name;
  final double temperature;
  final String condition;
  final int humidity;
  final double windSpeed;
  final double lat;
  final double lon;

  WeatherModel({
    required this.name,
    required this.temperature,
    required this.condition,
    required this.humidity,
    required this.windSpeed,
    required this.lat,
    required this.lon,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    return WeatherModel(
      name: json['name'] ?? '',
      temperature: (json['main']['temp'] as num).toDouble(),
      condition: json['weather'][0]['main'],
      humidity: json['main']['humidity'],
      windSpeed: (json['wind']['speed'] as num).toDouble(),
      lat: (json['coord']['lat'] as num).toDouble(),
      lon: (json['coord']['lon'] as num).toDouble(),
    );
  }
}
