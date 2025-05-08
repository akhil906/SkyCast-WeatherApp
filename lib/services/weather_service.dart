import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/weather_model.dart';
import '../models/forecast_model.dart';

class WeatherService {
  final String apiKey;

  WeatherService({required this.apiKey});

  Future<WeatherModel?> fetchWeather(String input, String unit) async {
    final bool isLatLon = input.contains(',');
    final query =
        isLatLon
            ? 'lat=${input.split(',')[0]}&lon=${input.split(',')[1]}'
            : (int.tryParse(input) != null ? 'zip=$input' : 'q=$input');

    final url =
        'https://api.openweathermap.org/data/2.5/weather?$query&units=$unit&appid=$apiKey';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return WeatherModel.fromJson(data);
      } else {
        print('Failed to fetch weather: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error fetching weather: $e');
      return null;
    }
  }

  Future<Map<String, List<ForecastModel>>?> fetchForecast(
    String input,
    String unit,
  ) async {
    final bool isLatLon = input.contains(',');
    final query =
        isLatLon
            ? 'lat=${input.split(',')[0]}&lon=${input.split(',')[1]}'
            : (int.tryParse(input) != null ? 'zip=$input' : 'q=$input');

    final url =
        'https://api.openweathermap.org/data/2.5/forecast?$query&units=$unit&appid=$apiKey';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List list = data['list'];

        Map<String, List<ForecastModel>> grouped = {};
        for (var entry in list) {
          final model = ForecastModel.fromJson(entry);
          final key =
              "${model.dateTime.year}-${model.dateTime.month}-${model.dateTime.day}";
          grouped.putIfAbsent(key, () => []).add(model);
        }

        return grouped;
      } else {
        print('Failed to fetch forecast: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error fetching forecast: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> fetchAirQuality(double lat, double lon) async {
    final response = await http.get(
      Uri.parse(
        'https://api.openweathermap.org/data/2.5/air_pollution?lat=$lat&lon=$lon&appid=$apiKey',
      ),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final item = data['list'][0];

      return {
        'aqi': item['main']['aqi'],
        'co': item['components']['co'],
        'no': item['components']['no'],
        'no2': item['components']['no2'],
        'o3': item['components']['o3'],
        'so2': item['components']['so2'],
        'pm2_5': item['components']['pm2_5'],
        'pm10': item['components']['pm10'],
        'nh3': item['components']['nh3'],
      };
    } else {
      return null;
    }
  }
}
