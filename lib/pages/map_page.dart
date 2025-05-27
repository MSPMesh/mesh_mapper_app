import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  LatLng? _currentPosition;

  @override
  void initState() {
    super.initState();
    _getLocation();
  }

  Future<void> _getLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
      final position = await Geolocator.getCurrentPosition();
      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Only build the map if _currentPosition is non-null
    if (_currentPosition == null) {
      return Scaffold(appBar: AppBar(title: const Text("OpenStreetMap")), body: const Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("OpenStreetMap"),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
          ),
        ],
      ),
      body: SafeArea(
        // <-- Wrap with SafeArea
        child: Column(
          children: [
            Expanded(
              child: FlutterMap(
                options: MapOptions(
                  initialCenter: _currentPosition!, // Use non-nullable value
                  initialZoom: 15.0,
                  initialRotation: 0,
                  interactionOptions: const InteractionOptions(flags: InteractiveFlag.all & ~InteractiveFlag.rotate),
                ),
                children: [
                  TileLayer(urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', subdomains: const ['a', 'b', 'c'], userAgentPackageName: 'com.example.app'),
                  MarkerLayer(markers: [Marker(width: 40, height: 40, point: _currentPosition!, child: const Icon(Icons.location_pin, color: Colors.red, size: 40))]),
                ],
              ),
            ),
            Padding(padding: const EdgeInsets.all(16.0), child: SizedBox(width: double.infinity, child: ElevatedButton(onPressed: _scanClosestNodes, child: const Text('Scan')))),
          ],
        ),
      ),
    );
  }

  Future<void> _scanClosestNodes() async {
    if (_currentPosition == null) return;
    final lat = _currentPosition!.latitude;
    final lon = _currentPosition!.longitude;
    final url = Uri.parse('http://localhost:3000/closest-nodes?lat=$lat&lon=$lon&n=5');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> nodes = jsonDecode(response.body);
        // Print each node string
        for (var node in nodes) {
          print(node);
        }
      } else {
        print('Failed to fetch nodes: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching nodes: $e');
    }
  }
}
