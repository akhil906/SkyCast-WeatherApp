import 'package:flutter/material.dart';
import 'package:weather_app/models/weather_model.dart';
import 'package:weather_app/models/forecast_model.dart';
import 'package:weather_app/services/weather_service.dart';
import 'package:weather_app/services/location_service.dart';
import 'package:geolocator/geolocator.dart';

class WeatherController extends ChangeNotifier {
  final WeatherService _weatherService;
  final LocationService _locationService;

  WeatherController(this._weatherService, this._locationService);

  WeatherModel? weather;
  Map<String, List<ForecastModel>>? forecast;
  Map<String, dynamic>? airQualityData;

  String city = '';
  String unit = 'metric';
  bool isLoading = false;

  final TextEditingController textController = TextEditingController();

  //This method fetches information based on the entered city name or ZIP code in the search bar field.

  Future<void> fetchByInput() async {
    _setLoading(true);
    final input = textController.text.trim();

    if (input.isEmpty) {
      await fetchByLocation();
      return;
    }

    airQualityData = null;

    try {
      final data = await _weatherService.fetchWeather(input, unit);
      final forecastData = await _weatherService.fetchForecast(input, unit);

      if (data == null || forecastData == null) {
        weather = null;
        forecast = null;
        city = '';
        notifyListeners();
        throw Exception("City or ZIP code not found.");
      }

      city =
          int.tryParse(input) != null && data.name.isNotEmpty
              ? data.name
              : input;
      weather = data;
      forecast = forecastData;
    } catch (e) {
      weather = null;
      forecast = null;
      city = '';
      notifyListeners();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // This method
  Future<void> fetchByLocation() async {
    _setLoading(true);

    airQualityData = null;

    try {
      Position position = await _locationService.determinePosition();
      final lat = position.latitude;
      final lon = position.longitude;
      final coord = '$lat,$lon';

      final data = await _weatherService.fetchWeather(coord, unit);
      final forecastData = await _weatherService.fetchForecast(coord, unit);

      if (data == null || forecastData == null) {
        throw Exception("Failed to get weather using device location.");
      }

      city =
          data.name.isNotEmpty
              ? 'Your Location – ${data.name}'
              : 'Your Location';
      weather = data;
      forecast = forecastData;
    } catch (e) {
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Calls the
  Future<void> fetchAirQualityIndex() async {
    if (weather == null) return;

    final lat = weather!.lat;
    final lon = weather!.lon;

    final data = await _weatherService.fetchAirQuality(lat, lon);
    if (data != null) {
      airQualityData = data;
      notifyListeners();
    }
  }

  void toggleUnit(bool toMetric) {
    unit = toMetric ? 'metric' : 'imperial';
    notifyListeners();
  }

  void _setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }
}
