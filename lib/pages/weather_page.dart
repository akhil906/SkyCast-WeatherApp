import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:weather_app/controllers/weather_controller.dart';
import 'package:weather_app/utils/icon_mapper.dart';
import 'dart:ui';

class WeatherPage extends StatelessWidget {
  const WeatherPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<WeatherController>(context);

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFE0F7FA), Color(0xFFB2EBF2)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: const Text("SkyCast"), centerTitle: true),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(50),
          child: Column(
            children: [
              _buildSearchBar(controller),
              const SizedBox(height: 30),
              _buildButtons(context, controller),
              const SizedBox(height: 24),

              if (controller.isLoading) const CircularProgressIndicator(),

              if (controller.weather != null) _buildWeatherCard(controller),

              if (controller.forecast != null) ...[
                _buildForecastList(controller),
                const SizedBox(height: 20),
                _buildAqiButton(context, controller),
              ],

              if (controller.airQualityData != null) ...[
                const SizedBox(height: 16),
                _buildAqiCard(controller),
              ],

              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar(WeatherController controller) {
    return Center(
      child: SizedBox(
        width: 500,
        child: TextField(
          controller: controller.textController,
          decoration: const InputDecoration(
            labelText: 'Enter City Name or ZIP Code',
            border: OutlineInputBorder(),
          ),
        ),
      ),
    );
  }

  Widget _buildButtons(BuildContext context, WeatherController controller) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton.icon(
          icon: const Icon(Icons.search),
          label: const Text("Search"),
          onPressed: () async {
            try {
              await controller.fetchByInput();
            } catch (e) {
              _showError(context, e.toString());
            }
          },
        ),
        const SizedBox(width: 10),
        ElevatedButton.icon(
          icon: const Icon(Icons.my_location),
          label: const Text("Locate Me"),
          onPressed: () async {
            try {
              await controller.fetchByLocation();
            } catch (e) {
              _showError(context, e.toString());
            }
          },
        ),
        const SizedBox(width: 20),
        ToggleButtons(
          isSelected: [
            controller.unit == 'metric',
            controller.unit == 'imperial',
          ],
          onPressed: (index) {
            controller.toggleUnit(index == 0);
          },
          borderRadius: BorderRadius.circular(8),
          selectedColor: Colors.white,
          fillColor: Colors.blueAccent,
          color: Colors.blueAccent,
          constraints: const BoxConstraints(minHeight: 40.0, minWidth: 80.0),
          children: const [
            Tooltip(message: 'Metric (Celsius)', child: Text('Metric')),
            Tooltip(message: 'Imperial (Fahrenheit)', child: Text('Imperial')),
          ],
        ),
      ],
    );
  }

  Widget _buildWeatherCard(WeatherController controller) {
    final w = controller.weather!;
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.blueAccent,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ],
              border: Border.all(color: Colors.white.withOpacity(0.3)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "Weather for: ${controller.city} (${controller.unit == 'metric' ? '°C' : '°F'})",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.yellow[200],
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  "Temperature: ${w.temperature}°${controller.unit == 'metric' ? 'C' : 'F'}",
                  style: _whiteText(),
                ),
                Text("Condition: ${w.condition}", style: _whiteText()),
                Text("Humidity: ${w.humidity}%", style: _whiteText()),
                Text("Wind Speed: ${w.windSpeed} m/s", style: _whiteText()),
                const SizedBox(height: 10),
                Image.asset(
                  IconMapper.getLocalWeatherIcon(w.condition),
                  height: 80,
                  width: 80,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildForecastList(WeatherController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        const Text(
          "5-Day Forecast",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.blueAccent,
          ),
        ),
        const SizedBox(height: 12),

        ...controller.forecast!.entries.map((entry) {
          final forecasts = entry.value;

          return ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8,
                      offset: Offset(0, 3),
                    ),
                  ],
                  border: Border.all(color: Colors.white.withOpacity(0.3)),
                ),
                child: ExpansionTile(
                  title: Text(
                    DateFormat('EEE, MMM d').format(forecasts.first.dateTime),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent,
                    ),
                  ),
                  children:
                      forecasts.map((item) {
                        return ListTile(
                          leading: Image.asset(
                            IconMapper.getLocalWeatherIcon(item.condition),
                            height: 40,
                            width: 40,
                          ),
                          title: Text(
                            '${DateFormat.jm().format(item.dateTime)} - ${item.condition}, ${item.temperature.toStringAsFixed(1)}°${controller.unit == 'metric' ? 'C' : 'F'}',
                            style: const TextStyle(color: Colors.black87),
                          ),
                          subtitle: Text(
                            '💧 ${item.humidity}%   💨 ${item.windSpeed.toStringAsFixed(1)} m/s',
                          ),
                        );
                      }).toList(),
                ),
              ),
            ),
          );
        }),

        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildAqiButton(BuildContext context, WeatherController controller) {
    return Center(
      child: ElevatedButton.icon(
        icon: const Icon(Icons.air),
        label: const Text("Show Air Quality Index"),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blueAccent,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        onPressed: () async {
          try {
            await controller.fetchAirQualityIndex();
          } catch (e) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text("Error fetching AQI: $e")));
          }
        },
      ),
    );
  }

  Widget _buildAqiCard(WeatherController controller) {
    final data = controller.airQualityData!;
    final aqi = data['aqi'].toString();
    final pm25 = data['pm2_5']?.toStringAsFixed(1) ?? 'N/A';
    final pm10 = data['pm10']?.toStringAsFixed(1) ?? 'N/A';
    final o3 = data['o3']?.toStringAsFixed(1) ?? 'N/A';
    final no2 = data['no2']?.toStringAsFixed(1) ?? 'N/A';
    final so2 = data['so2']?.toStringAsFixed(1) ?? 'N/A';
    final co = data['co']?.toStringAsFixed(1) ?? 'N/A';
    final nh3 = data['nh3']?.toStringAsFixed(1) ?? 'N/A';

    return Card(
      color: Colors.white.withOpacity(0.95),
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(vertical: 20),
      child: Padding(
        padding: const EdgeInsets.all(50),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Air Quality Index",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.blueAccent,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 12),
            _buildAqiRow("AQI", aqi),
            _buildAqiRow("PM2.5", "$pm25 µg/m³"),
            _buildAqiRow("PM10", "$pm10 µg/m³"),
            _buildAqiRow("O₃", "$o3 µg/m³"),
            _buildAqiRow("NO₂", "$no2 µg/m³"),
            _buildAqiRow("SO₂", "$so2 µg/m³"),
            _buildAqiRow("CO", "$co µg/m³"),
            _buildAqiRow("NH₃", "$nh3 µg/m³"),
          ],
        ),
      ),
    );
  }

  Widget _buildAqiRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 16, color: Colors.black54),
          ),
        ],
      ),
    );
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("Error: $message")));
  }

  TextStyle _whiteText() => const TextStyle(color: Colors.white, fontSize: 16);
}
