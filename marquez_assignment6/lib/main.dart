import 'package:flutter/material.dart';
import 'package:marquez_assignment6/screens/geoscreen.dart';
void main() {
  runApp(WatchersApp());
}
class WatchersApp extends StatelessWidget {
  const WatchersApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
    home: GeocodingScreen(),
    debugShowCheckedModeBanner: false,
  );
  }
}