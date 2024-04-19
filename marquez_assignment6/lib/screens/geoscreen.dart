import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:marquez_assignment6/screens/weatherscreen.dart';

class GeocodingScreen extends StatefulWidget {
  @override
  _GeocodingScreenState createState() => _GeocodingScreenState();
}

class _GeocodingScreenState extends State<GeocodingScreen> {
  String latitude = '';
  String longitude = '';
  String altitude = '';
  String address = '';
  String weatherData = '';
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _getUserLocation();
  }

  Future<void> _getUserLocation() async {
    try {
      setState(() {
        isLoading = true;
      });

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse) {
        Position position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.best);

        setState(() {
          latitude = position.latitude.toString();
          longitude = position.longitude.toString();
          altitude = position.altitude.toString();
        });

        List<Placemark> placemarks = await placemarkFromCoordinates(
            position.latitude, position.longitude);

        if (placemarks != null && placemarks.isNotEmpty) {
          Placemark placemark = placemarks[0];
          String formattedAddress =
              '${placemark.street}, ${placemark.locality}, ${placemark.administrativeArea}, ${placemark.country}';
          setState(() {
            address = formattedAddress;
          });
        }

        await _fetchWeatherData();
      }

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print('Error: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _fetchWeatherData() async {
  String apiKey = '3ce3cf8909c7942b0ca957fff23c47c3';
  String url = 'https://api.openweathermap.org/data/2.5/weather?lat=$latitude&lon=$longitude&appid=$apiKey';

  try {
    setState(() {
      isLoading = true;
    });

    http.Response response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      Map<String, dynamic> data = jsonDecode(response.body);
      String description = data['weather'][0]['description'];
      double temperature = (data['main']['temp'] - 273.15);

      setState(() {
        weatherData = 'Weather Status: $description\nTemperature: ${temperature.toStringAsFixed(2)}°C';
      });
    } else {
      setState(() {
        weatherData = 'Error: ${response.statusCode}';
      });
    }
  } catch (e) {
    setState(() {
      weatherData = 'Error fetching weather data: $e';
    });
  } finally {
    setState(() {
      isLoading = false;
    });
  }
}

 Widget _buildInfoCard(String title, String content) {
  return Card(
    child: Container(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8.0),
          Flexible(
        
            child: Text(
              content,
              style: TextStyle(fontSize: 16.0),
              overflow: TextOverflow.ellipsis, 
              maxLines: 2,
            ),
          ),
        ],
      ),
    ),
  );
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor:Color(0xFF0D47A1),
        title: Text(
          'Hikers Watch',
          style: TextStyle(
            fontSize: 30,
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
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
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              'Your current location details!',
              style: TextStyle(
                fontSize: 28,
                color: Color.fromARGB(255, 252, 248, 247),
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildInfoCard('Latitude:', latitude),
                _buildInfoCard('Longitude:', longitude),
                _buildInfoCard('Altitude:', altitude),
              ],
            ),
            SizedBox(height: 16.0),
            Card(
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Address:',
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8.0),
                    Text(
                      address,
                      style: TextStyle(fontSize: 16.0),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16.0),
            isLoading
                ? CircularProgressIndicator()
                : Card(
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        weatherData,
                        style: TextStyle(fontSize: 22.0),
                      ),
                    ),
                  ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => WeatherScreen()),
                );
              },
              child: Text('CHECK WEATHER'),
            ),
          ],
        ),
      ),
    );
  }
}
