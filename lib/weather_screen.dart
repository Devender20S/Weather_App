import 'dart:convert';
import 'dart:ui';
import 'dart:io';

import 'package:weather_app/additional_info.dart';
import 'package:flutter/material.dart';
import 'package:http/io_client.dart';
import 'package:weather_app/hourly_forecast.dart';
import 'package:weather_app/secrets.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  String selectedCity = 'Delhi';

  List<String> cities = ['Delhi', 'Mumbai', 'Kolkata', 'Chennai', 'Bangalore'];

  List weatherData = [];
  double temp = 0;
  String? sky;
  double humidity = 0;
  double windSpeed = 0;
  double pressure = 0;

  IconData getWeatherIcon(String sky) {
    switch (sky) {
      case 'Clouds':
        return Icons.cloud;
      case 'Rain':
        return Icons.beach_access;
      case 'Clear':
        return Icons.sunny;
      default:
        return Icons.help_outline;
    }
  }

  // ✅ FIXED NETWORK CALL
  Future<void> getCurrentWeather() async {
    try {
      final client = IOClient(HttpClient());

      final url =
          'https://api.openweathermap.org/data/2.5/forecast?q=$selectedCity,india&APPID=$openWeatherAPIkey';

      final response = await client
          .get(Uri.parse(url), headers: {
        "Accept": "application/json",
      })
          .timeout(const Duration(seconds: 10));

      print("STATUS CODE: ${response.statusCode}");
      print("RESPONSE BODY: ${response.body}");

      if (response.statusCode != 200) {
        throw "HTTP Error: ${response.statusCode}";
      }

      final data = jsonDecode(response.body);

      if (data['cod'] != "200") {
        throw data['message'];
      }

      // ✅ SAFE ASSIGNMENTS
      weatherData = data['list'] ?? [];

      if (weatherData.isEmpty) {
        throw "No weather data received";
      }

      final current = weatherData[0];

      temp = (current['main']['temp'] ?? 0).toDouble();
      sky = current['weather'][0]['main'];
      humidity = (current['main']['humidity'] ?? 0).toDouble();
      pressure = (current['main']['pressure'] ?? 0).toDouble();
      windSpeed = (current['wind']['speed'] ?? 0).toDouble();

    } catch (e) {
      print("🔥 FULL ERROR: $e");
      rethrow;
    }
  }

  late Future<void> weatherFuture;

  @override
  void initState() {
    super.initState();
    weatherFuture = getCurrentWeather();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather App',
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          DropdownButton<String>(
            value: selectedCity,
            dropdownColor: Colors.black,
            icon: const Icon(Icons.location_city, color: Colors.white),
            underline: const SizedBox(),
            items: cities.map((city) {
              return DropdownMenuItem(
                value: city,
                child: Text(city, style: const TextStyle(color: Colors.white)),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                selectedCity = value!;
                weatherFuture = getCurrentWeather();
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh_sharp),
            onPressed: () {
              setState(() {
                weatherFuture = getCurrentWeather();
              });
            },
          ),
        ],
      ),
      backgroundColor: Colors.black87,
      body: FutureBuilder(
        future: weatherFuture,
        builder: (context, snapshot) {
          // 🔄 Loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator.adaptive());
          }

          // ❌ Error
          if (snapshot.hasError) {
            return Center(
              child: Text(
                '❌ Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.white),
              ),
            );
          }

          // ⚠️ No data safety
          if (weatherData.isEmpty) {
            return const Center(
              child: Text(
                "No data available",
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          // ✅ UI
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 🌤 Main Card
                  SizedBox(
                    width: double.infinity,
                    child: Card(
                      elevation: 25,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: BackdropFilter(
                          filter:
                          ImageFilter.blur(sigmaY: 10, sigmaX: 10),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                Text(
                                  '${(temp - 273).toStringAsFixed(2)} °C',
                                  style: const TextStyle(
                                      fontSize: 33,
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 16),
                                Icon(
                                  getWeatherIcon(sky ?? ""),
                                  size: 64,
                                ),
                                const SizedBox(height: 20),
                                Text(
                                  sky ?? "Unknown",
                                  style: const TextStyle(fontSize: 20),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ⏰ Hourly Forecast
                  const Text(
                    'Hourly Forecast',
                    style:
                    TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 10),

                  SizedBox(
                    height: 120,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: 5,
                      itemBuilder: (context, index) {
                        final item = weatherData[index + 1];

                        return hourlyForecastItem(
                          icon: getWeatherIcon(
                              item['weather'][0]['main']),
                          time: item['dt_txt'].substring(11, 16),
                          temp:
                          '${(item['main']['temp'] - 273).toStringAsFixed(2)} °C',
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 📊 Additional Info
                  const Text(
                    'Additional Information',
                    style:
                    TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 10),

                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        extraInfo(
                          icon: const Icon(Icons.water_drop),
                          text: const Text('Humidity'),
                          value: Text('$humidity%'),
                        ),
                        const SizedBox(width: 40),
                        extraInfo(
                          icon: const Icon(Icons.air_rounded),
                          text: const Text('Wind Speed'),
                          value: Text('$windSpeed m/s'),
                        ),
                        const SizedBox(width: 40),
                        extraInfo(
                          icon: const Icon(Icons.beach_access_sharp),
                          text: const Text('Pressure'),
                          value: Text('$pressure mb'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}