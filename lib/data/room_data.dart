import 'package:flutter/material.dart';

final List<Map<String, dynamic>> room_data_list = [
  {
    "name": "Living Room",
    "icon": Icons.tv, // Add an icon for the room
    "devices": [
      {"name": "TV", "status": false, "icon": Icons.tv},
      {"name": "Lighting", "status": true, "icon": Icons.lightbulb},
      {"name": "Air Conditioner", "status": false, "icon": Icons.ac_unit},
      {"name": "Curtains", "status": false, "icon": Icons.window},
      {"name": "Sound System", "status": true, "icon": Icons.speaker},
    ],
  },
  {
    "name": "Bedroom",
    "icon": Icons.bed, // Add an icon for the room
    "devices": [
      {"name": "TV", "status": false, "icon": Icons.tv},
      {"name": "Bedside Lamps", "status": true, "icon": Icons.light},
      {"name": "Air Conditioner", "status": true, "icon": Icons.ac_unit},
      {"name": "Smart Curtains", "status": false, "icon": Icons.window},
      {"name": "Air Purifier", "status": false, "icon": Icons.air},
    ],
  },
  {
    "name": "Kitchen",
    "icon": Icons.kitchen, // Add an icon for the room
    "devices": [
      {"name": "Smart Refrigerator", "status": true, "icon": Icons.kitchen},
      {"name": "Oven", "status": false, "icon": Icons.microwave},
      {"name": "Dishwasher", "status": false, "icon": Icons.wash},
      {"name": "Exhaust Fan", "status": true, "icon": Icons.wind_power},
      {"name": "Coffee Machine", "status": false, "icon": Icons.coffee},
    ],
  },
  {
    "name": "Bathroom",
    "icon": Icons.bathtub, // Add an icon for the room
    "devices": [
      {"name": "Lighting", "status": true, "icon": Icons.lightbulb},
      {"name": "Exhaust Fan", "status": true, "icon": Icons.wind_power},
      {"name": "Water Heater", "status": false, "icon": Icons.hot_tub},
      {"name": "Smart Mirror", "status": false, "icon": Icons.smart_display},
    ],
  },
  {
    "name": "Garden",
    "icon": Icons.grass, // Add an icon for the room
    "devices": [
      {"name": "Gate", "status": false, "icon": Icons.door_sliding},
      {"name": "Outdoor Lights", "status": true, "icon": Icons.lightbulb},
      {"name": "Sprinkler System", "status": false, "icon": Icons.grass},
      {"name": "Cameras", "status": true, "icon": Icons.camera_alt},
    ],
  },
];


Map<String, Map<String, List<Map<String, dynamic>>>> transformDataset() {
  Map<String, Map<String, List<Map<String, dynamic>>>> newDataset = {};

  // Iterate over the room data
  for (var room in room_data_list) {
    String roomName = room['name']; // Get the room name
    List<Map<String, dynamic>> devices = room['devices']; // Get devices for the room

    // Initialize an empty map to categorize devices
    Map<String, List<Map<String, dynamic>>> categorizedDevices = {};

    // Group devices by category
    for (var device in devices) {
      String category = _getCategory(device['name']); // Get category of the device

      // If category doesn't exist, initialize it
      if (!categorizedDevices.containsKey(category)) {
        categorizedDevices[category] = [];
      }

      // Add the device under the correct category
      // categorizedDevices[category]!.add({
      //   'name': device['name'],
      //   'status': device['status'],
      // });
    }

    // Add the room to the new dataset with categorized devices
    newDataset[roomName] = categorizedDevices;
  }

  return newDataset;
}

// Helper function to determine device category based on its name
String _getCategory(String deviceName) {
  if (deviceName.toLowerCase().contains('light')) {
    return 'Lighting';
  } else if (deviceName.toLowerCase().contains('ac') || deviceName.toLowerCase().contains('air')) {
    return 'Air Conditioning';
  } else if (deviceName.toLowerCase().contains('tv')) {
    return 'TV';
  } else if (deviceName.toLowerCase().contains('curtain')) {
    return 'Curtains';
  } else if (deviceName.toLowerCase().contains('fan')) {
    return 'Fans';
  } else if (deviceName.toLowerCase().contains('sound') || deviceName.toLowerCase().contains('speaker')) {
    return 'Sound System';
  } else {
    return 'Other'; // Default category
  }
}