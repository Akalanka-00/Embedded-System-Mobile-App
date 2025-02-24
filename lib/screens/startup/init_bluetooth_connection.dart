import 'dart:developer';
import 'dart:typed_data';
import 'package:bluetooth_classic/bluetooth_classic.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';
import 'package:skynet/enum/device_configuration.dart';
import 'package:skynet/enum/request_types.dart';
import 'package:skynet/screens/home/home.dart';
import 'package:skynet/service/bluetooth/bluetooth_handler.dart';
import 'package:skynet/utils/shared_preferences/shared_preferences_service.dart';
import 'dart:convert';

import 'package:uuid/uuid.dart';

class InitBluetooth extends StatefulWidget {
  const InitBluetooth({Key? key}) : super(key: key);

  @override
  _InitBluetoothState createState() => _InitBluetoothState();
}

class _InitBluetoothState extends State<InitBluetooth> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  String qrText = "FC:A8:9A:00:23:2D";
  bool _scannedValidCode = true; // flag to indicate a valid code has been scanned
  Uint8List _data = Uint8List(0);

  @override
  void reassemble() {
    super.reassemble();
    if (controller != null) {
      controller!.pauseCamera();
      controller!.resumeCamera();
    }
  }

  Future<void> connect() async {
    BluetoothHandler().initBluetooth();
    await BluetoothHandler().connect(qrText);
    final prefsService = SharedPreferencesService();
    final userId = await prefsService.getUserId();
    if (userId == null) {
      log("User ID not found in SharedPreferences.");
      return;
    }
    String uuid = Uuid().v4();
    final data = {
      "action":"auth",
      "userId":userId,
      "uuid":uuid
    };

    // "{\"action\": \"control\", \"userId\": \"String2 dup\", \"socketId\": \"Socket2\", \"status\": true}"
    await BluetoothHandler().sendData(data);

    // Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => HomePage()));

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Connect to SkyNet", style: TextStyle(color: Colors.white)),
        automaticallyImplyLeading: false,
        backgroundColor: const Color.fromARGB(255, 6, 26, 94),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.white),
            onPressed: () {
              // Handle notification icon press
            },
          ),
        ],
        elevation: 4.0,
        shadowColor: Colors.black.withOpacity(0.5),
      ),
      body: _scannedValidCode
          ? Center( // Center the content on the screen
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              "Connecting to SkyNet...",
              style: TextStyle(
                fontSize: 18,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),  // Add space between text and loader
            const CircularProgressIndicator(
              color: Colors.blueAccent,
            ),
          ],
        ),
      )
          : Column(
        children: [
          Expanded(
            flex: 4,
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
            ),
          ),
          Container(
            height: 70,
            color: const Color.fromARGB(255, 6, 26, 94),
            child: const Center(
              child: Text(
                "Scan QR and Connect",
                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) async {
      final code = "FC:A8:9A:00:23:2D"; // For testing purposes, replace with scanData.code
      // Regular expression for matching the QR code with the pattern
      final regex = RegExp(r'^[A-Za-z0-9]{2}(:[A-Za-z0-9]{2}){5}$');
      if (regex.hasMatch(code)) {
        setState(() {
          qrText = code;
          _scannedValidCode = true;
        });
        debugPrint("Valid QR Code: $code");

        // Call the connect method when a valid QR code is scanned
        await connect();
      } else {
        debugPrint("Invalid QR Code scanned: $code");
        // Keep scanning if the pattern doesn't match
      }
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
