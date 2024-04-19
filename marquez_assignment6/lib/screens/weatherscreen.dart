import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class WeatherScreen extends StatefulWidget {
  @override
  _WeatherScreenState createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  TextEditingController locationController = TextEditingController();
  String _weatherData = '';

  Future<void> _fetchWeatherData() async {
    String apiKey = '3ce3cf8909c7942b0ca957fff23c47c3';
    String location = locationController.text;
    String url =
        'https://api.openweathermap.org/data/2.5/weather?q=$location&appid=$apiKey';

    try {
      http.Response response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);
        String description = data['weather'][0]['description'];
        double temperature = (data['main']['temp'] - 273.15);

        setState(() {
          _weatherData =
              'Current location \n Weather Status: $description\nTemperature: ${temperature.toStringAsFixed(2)}°C';
        });
      } else {
        setState(() {
          _weatherData = 'Error: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _weatherData = 'Error: $e';
      });
    }
  }

  @override
  void dispose() {
    locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor:Color(0xFF0D47A1),
        title: Text('Weather Check',
            style: TextStyle(
                fontSize: 24,
                color: Colors.white,
                fontWeight: FontWeight.bold,
                letterSpacing: 2)),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0D47A1), // Dark Blue
                Color(0xFF311B92), // Deep Purple
                Color(0xFF1A237E), // Indigo
                Color(0xFF0D47A1), // Dark Blue (repeated)
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.all(16.0),
              child: TextField(
                controller: locationController,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Enter your location',
                  labelStyle: TextStyle(color: Colors.white),
                  
                ),
              ),
            ),
            ElevatedButton(
              onPressed: _fetchWeatherData,
              child: Text('See weather Status'),
            ),
            SizedBox(height: 16.0),
            Text(
              _weatherData,
              style: TextStyle(fontSize: 18.0,
              color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
