import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:bluetooth_classic/models/device.dart';
import 'package:bluetooth_classic/bluetooth_classic.dart';
import 'package:skynet/enum/device_configuration.dart';
import 'package:skynet/screens/home/home.dart';
import 'package:skynet/utils/bluetooth/bluetooth_provider.dart';
import 'package:skynet/utils/shared_preferences/shared_preferences_service.dart';

class InitBluetooth extends StatefulWidget {
  const InitBluetooth({super.key});

  @override
  _InitBluetoothState createState() => _InitBluetoothState();
}

class _InitBluetoothState extends State<InitBluetooth> {
  final BluetoothProvider _bluetoothProvider = BluetoothProvider();
  final SharedPreferencesService _sharedPreferencesService =
      SharedPreferencesService();

  bool _isScanning = false;
  List<Device> _pairedDevices = [];
  List<Device> _discoveredDevices = [];
  Timer? _scanTimer;

  @override
  void initState() {
    super.initState();

    // Fetch paired devices
    _fetchPairedDevices();

    // Listen for discovered devices from the Bluetooth provider
    _bluetoothProvider.deviceDiscoveryStream.listen((device) {
      setState(() {
        if (!_discoveredDevices.contains(device)) {
          _discoveredDevices.add(device);
        }
      });
    });

    // Start scanning automatically 3 seconds after the page opens
    Future.delayed(Duration(seconds: 3), _startScanning);
  }

  // Fetch paired devices
  void _fetchPairedDevices() async {
    List<Device> pairedDevices = await _bluetoothProvider.getPairedDevices();
    setState(() {
      _pairedDevices = pairedDevices;
      log("Paired devices: ${_pairedDevices.length}");
    });
  }

  // Start scanning for devices
  void _startScanning() async {
    setState(() {
      _isScanning = true;
    });
    _discoveredDevices.clear();
    await _bluetoothProvider.startScanning();

    // Stop scanning after 30 seconds
    _scanTimer = Timer(Duration(seconds: 30), _stopScanning);
  }

  // Stop scanning for devices
  void _stopScanning() async {
    setState(() {
      _isScanning = false;
    });
    await _bluetoothProvider.stopScanning();
    _scanTimer?.cancel();
  }

  @override
  void dispose() {
    super.dispose();
    _bluetoothProvider.dispose();
    _scanTimer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Connect to Home Skynet"),
        backgroundColor: const Color.fromARGB(255, 6, 26, 94),
        titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
        elevation: 4,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle("Paired Devices"),
            _buildDeviceList(_pairedDevices, "No paired devices found"),
            const SizedBox(height: 20),
            _buildSectionTitle("Discovered Devices"),
            _buildDeviceList(_discoveredDevices, "No devices discovered yet"),
            const SizedBox(height: 20),
            _buildScanningControl(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Text(
        title,
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blueAccent),
      ),
    );
  }

  Widget _buildDeviceList(List<Device> devices, String emptyMessage) {
    if (devices.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Text(
            emptyMessage,
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ),
      );
    }
    return Expanded(
      child: ListView.separated(
        itemCount: devices.length,
        separatorBuilder: (context, index) => Divider(color: Colors.grey[300]),
        itemBuilder: (context, index) {
          final device = devices[index];
          return Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: ListTile(
              leading: Icon(Icons.bluetooth, color: Colors.blueAccent),
              title: Text(device.name ?? "Unknown Device", style: TextStyle(fontSize: 16)),
              subtitle: Text(device.address, style: TextStyle(color: Colors.grey)),
              trailing: Icon(Icons.join_full, size: 16, color: Colors.grey),
              onTap: () async {
                _sharedPreferencesService.saveIsNewDevice(false);
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => HomePage()));
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildScanningControl() {
    return Center(
      child: Column(
        children: [
          Text(
            _isScanning ? "Scanning for devices..." : "Scan complete",
            style: TextStyle(fontSize: 16, color: _isScanning ? Colors.blue : Colors.grey),
          ),
          const SizedBox(height: 10),
          ElevatedButton.icon(
            onPressed: _isScanning ? _stopScanning : _startScanning,
            icon: Icon(_isScanning ? Icons.stop_circle_outlined : Icons.search),
            label: Text(_isScanning ? "Stop Scanning" : "Start Scanning", style: TextStyle(color: Colors.white, fontSize: 16),),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              backgroundColor: _isScanning ? Colors.redAccent : Colors.blueAccent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              iconColor: Colors.white,
              iconSize: _isScanning? 20 : 16
              
            ),
          ),
        ],
      ),
    );
  }
}
