import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  List<BluetoothDevice> previouslyConnectedDevices = [];

  @override
  void initState() {
    super.initState();
    _loadBluetoothDevices();
  }

  Future<void> _loadBluetoothDevices() async {
    // Get previously connected devices (bonded/paired)
    List<BluetoothDevice> bonded = await FlutterBluePlus.bondedDevices;

    setState(() {
      previouslyConnectedDevices = bonded;
    });
  }

  Widget _buildDeviceList(List<BluetoothDevice> devices) {
    if (devices.isEmpty) {
      return const ListTile(title: Text('None'));
    }

    return Column(children: devices.map((device) => ListTile(title: Text(device.name.isNotEmpty ? device.name : device.id.toString()), subtitle: Text(device.id.toString()))).toList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: RefreshIndicator(
        onRefresh: _loadBluetoothDevices,
        child: ListView(
          children: [
            const Padding(padding: EdgeInsets.all(16.0), child: Text('Previously Connected Devices', style: TextStyle(fontWeight: FontWeight.bold))),
            _buildDeviceList(previouslyConnectedDevices),
          ],
        ),
      ),
    );
  }
}
