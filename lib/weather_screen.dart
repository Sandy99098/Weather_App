import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:weather_app/additional_info_item.dart';
import 'package:weather_app/hourly_forecast_item.dart';
import 'package:http/http.dart' as http;
import 'package:weather_app/secrets.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  late Future<Map<String, dynamic>> weather = getCurrentWeather();
  Future<Map<String, dynamic>> getCurrentWeather() async {
    String cityName = 'Pokhara';
    try {
      final res = await http.get(Uri.parse(
          "https://api.openweathermap.org/data/2.5/forecast?q=$cityName&appid=$openWeatherApiKey"));
      final data = jsonDecode(res.body);

      if (data['cod'] != "200") {
        throw "Unexpected error occured ${data['message']} ";
      }
      return data;
      // data['main']['temp'];
    } catch (e) {
      debugPrint("Error fetching weather data: $e");
      throw e.toString();
    }
  }

  @override
  void initState() {
    super.initState();
    weather = getCurrentWeather();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Weather App",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                weather = getCurrentWeather();
              });
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: FutureBuilder(
        future: weather,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator.adaptive(),
            );
          }
          if (snapshot.hasError) {
            return Text(snapshot.error.toString());
          }
          //  final data = snapshot.data!;
          //   if (data['list'] == null || data['list'].isEmpty) {
          //     return const Center(child: Text("No forecast data available."));
          //   }

          final data = snapshot.data!;
          final currentTemp =
              (data['list'][0]['main']['temp'] - 273.15).toStringAsFixed(2) +
                  " °C ";
          final currentSky = data['list'][0]['weather'][0]['main'];
          final humidity = data['list'][0]['main']['humidity'].toString();
          final windSpeed = data['list'][0]['wind']['speed'].toString();
          final pressure = data['list'][0]['main']['pressure'].toString();

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: double.infinity,
                  child: Card(
                    elevation: 10,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const SizedBox(height: 20),
                              Text(
                                '$currentTemp',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Icon(
                                  currentSky == 'Clouds' || currentSky == 'Rain'
                                      ? Icons.cloud
                                      : Icons.wb_sunny,
                                  size: 60),
                              const SizedBox(height: 20),
                              Text(
                                "$currentSky",
                                style: const TextStyle(
                                  fontSize: 20,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Hourly Forecast",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 125,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: 5,
                    itemBuilder: (context, index) {
                      final hourlyForecast = data['list'][index + 1];
                      final weatherCondition =
                          hourlyForecast['weather'][0]['main'];
                      final icon = {
                            'Clouds': Icons.cloud,
                            'Rain': Icons.umbrella,
                            'Snow': Icons.ac_unit,
                            'Thunderstorm': Icons.flash_on,
                            'Clear': Icons.wb_sunny,
                          }[weatherCondition] ??
                          Icons.help_outline;

                      final hourlyTemperature =
                          (hourlyForecast["main"]['temp'] - 273.15)
                              .toStringAsFixed(2);
                      final hourlyDateTime =
                          DateTime.parse(hourlyForecast['dt_txt']);

                      return HourlyForecastItem(
                        time: DateFormat.j().format(hourlyDateTime),
                        temperature: hourlyTemperature,
                        icon: icon,
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Additional Information",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    AdditionalInfoItem(
                      icon: Icons.water_drop,
                      label: "Humidity",
                      value: humidity,
                    ),
                    AdditionalInfoItem(
                      icon: Icons.speed,
                      label: "Pressure",
                      value: pressure,
                    ),
                    AdditionalInfoItem(
                      icon: Icons.air,
                      label: "Wind Speed",
                      value: windSpeed,
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
