import 'dart:convert';
import 'dart:ui';
import 'package:weather_app/additional_info.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:weather_app/hourly_forecast.dart';
import 'package:weather_app/secrets.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  List weatherData = [];
  double temp = 0;
  String? sky;
  double humidity = 0;
  double Wind_speed = 0;
  double pressure = 0;
  double? temp_at_9am;
  double? temp_at_12pm;
  double? temp_at_15pm;
  double? temp_at18pm;
  double? temp_at21pm;
  double? temp_at00am;
  IconData getWeatherIcon(String sky) {
    if (sky == 'Clouds') {
      return Icons.cloud;
    } else if (sky == 'Rain') {
      return Icons.beach_access;
    } else if (sky == 'Clear') {
      return Icons.sunny;
    } else {
      return Icons.help_outline;
    }
  }

  Future getCurrentWeather() async {
    String cityName = 'Delhi';
    final result = await http.get(
      Uri.parse(
        'https://api.openweathermap.org/data/2.5/forecast?q=$cityName,india&APPID=$openWeatherAPIkey',
      ),
    );

    final data = jsonDecode(result.body);
    weatherData = data['list'];
    if (data['cod'] != '200') {
      throw 'Unexpected error occurred ';
    }

    temp = data['list'][0]['main']['temp'];
    sky = data['list'][0]['weather'][0]['main'];
    humidity = data['list'][0]['main']['humidity'];
    pressure = data['list'][0]['main']['pressure'];
    Wind_speed = data['list'][0]['wind']['speed'];
    temp_at_9am = data['list'][1]['main']['temp'];
    temp_at_12pm = data['list'][2]['main']['temp'];
    temp_at_15pm = data['list'][3]['main']['temp'];
    temp_at18pm = data['list'][4]['main']['temp'];
    temp_at21pm = data['list'][5]['main']['temp'];
    temp_at00am = data['list'][6]['main']['temp'];
  }

  late Future weatherFuture;

  @override
  void initState() {
    super.initState();
    weatherFuture = getCurrentWeather();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Weather App',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_sharp),
            splashColor: Colors.white70,
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
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: const CircularProgressIndicator.adaptive());
          }
          if (snapshot.hasError) {
            return Center(child: Text('An unexpected error occurred'));
          }
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //main card..........................................................
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
                          filter: ImageFilter.blur(sigmaY: 10, sigmaX: 10),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                Text(
                                  '${(temp - 273).toStringAsFixed(2)} °C',
                                  style: TextStyle(
                                    fontSize: 33,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Icon(
                                  sky == 'Clouds'
                                      ? Icons.cloud_circle
                                      : sky == 'Rain'
                                      ? Icons.beach_access_rounded
                                      : Icons.sunny,
                                  size: 64,
                                ),
                                SizedBox(height: 20),
                                Text(sky!, style: TextStyle(fontSize: 20)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 21),
                  //Hourly forecast cards..............................................
                  const Text(
                    'Hourly Forecast',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 9),

                  // SingleChildScrollView(
                  //   scrollDirection: Axis.horizontal,
                  //
                  //   child: Row(
                  //     children: [
                  //       for (int i = 0; i < 7; i++)
                  //         hourlyForecastItem(
                  //           time: weatherData[i]['dt_txt'].substring(11, 16),
                  //           icon: getWeatherIcon(
                  //             weatherData[i]['weather'][0]['main'],
                  //           ),
                  //           temp: weatherData[i]['main']['temp'].toString(),
                  //         ),
                  //     ],
                  //   ),
                  // ),
                   SizedBox(
                      height:120,



                      child: ListView.builder(
                        scrollDirection:Axis.horizontal,
                        itemCount: 5,
                        itemBuilder: (context, index) {
                          return hourlyForecastItem(
                            icon: getWeatherIcon(
                              weatherData[index+1]['weather'][0]['main'],
                            ),
                            time: weatherData[index+1]['dt_txt'].substring(11, 16),
                            temp: weatherData[index+1]['main']['temp'].toString(),
                          );
                        },
                      ),
                    ),


                  SizedBox(height: 21),
                  // Extra info..............................................................
                  Text(
                    'Additional Information',
                    style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 9),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,

                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,

                      children: [
                        extraInfo(
                          icon: Icon(Icons.water_drop),
                          text: Text('Humidity'),
                          value: Text('$humidity%'),
                        ),
                        SizedBox(width: 45),
                        extraInfo(
                          icon: Icon(Icons.air_rounded),
                          text: Text('Wind Speed '),
                          value: Text('$Wind_speed m/s'),
                        ),
                        SizedBox(width: 45),
                        extraInfo(
                          icon: Icon(Icons.beach_access_sharp),
                          text: Text('Pressure'),
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
