import 'dart:developer';

import 'package:skynet/data/room_data.dart';
import 'package:skynet/enum/db_collections.dart';
import 'package:skynet/utils/firebase/init_firebase.dart';
import 'package:skynet/utils/shared_preferences/shared_preferences_service.dart';

class DbService {
  final _dbService = FirebaseService();

  saveSignUpData(String email, String name, String userId) {
    _dbService.create(
        DbCollections.users.key,
        {
          'name': name,
          'userId': userId,
          'email': email,
        },
        userId);
  }

  getUserName(String userId) async {
    final data = await _dbService.read(DbCollections.users.key, userId);
    final name = data["name"];
    return name;
  }

  createDefaultRooms(String userId) {
    final rooms = transformDataset();
    _dbService.create(DbCollections.rooms.key, rooms, userId);
    }


Future<List<Map<String, dynamic>>> getDeviceByCategory(String userId, String room, String category) async {

  final data = await _dbService.read(DbCollections.rooms.key, userId);
  List<Map<String, dynamic>> devices = List.from(data[room][category]);
  return devices;
}


  Future<void> addNewDevice(String roomName, String deviceCategory, String deviceName, int socketId, { bool status = false, }) async {
    try {
      // Get the user ID from SharedPreferences
      final prefsService = SharedPreferencesService();
      final userId = await prefsService.getUserId();
      if (userId == null) {
        log("User ID not found in SharedPreferences.");
        return;
      }

      // Read the current room data from Firebase
      final data = await _dbService.read(DbCollections.rooms.key, userId);
      if (data == null) {
        log("No data found for user $userId");
        return;
      }

      // Check if the room exists in the dataset and the device category is present
      if (data.containsKey(roomName) && data[roomName].containsKey(deviceCategory)) {
        // Get the current list of devices for the given category in the room
        List<dynamic> currentDevices = List.from(data[roomName][deviceCategory]);

        // Create a new device data map
        Map<String, dynamic> newDevice = {
          'name': deviceName,
          'status': status,
          'socket': socketId
          // Add any other fields as needed (e.g., icon, bluetoothEnabled)
        };

        // Add the new device to the list
        currentDevices.add(newDevice);

        // Update the category in the room data with the new list of devices
        data[roomName][deviceCategory] = currentDevices;

        // Save the updated data back to Firebase.
        await _dbService.create(DbCollections.rooms.key, data, userId);

        log("Added device '$deviceName' to room '$roomName' under category '$deviceCategory'");
      } else {
        log("Room '$roomName' or category '$deviceCategory' not found.");
      }
    } catch (e) {
      log("Error adding device: $e");
    }
  }


  Future<List<int>> getAllSocketIds() async {
    final prefsService = SharedPreferencesService();
    final userId = await prefsService.getUserId();
    if (userId == null) {
      log("User ID not found in SharedPreferences.");
      return [];
    }

    final data = await _dbService.read(DbCollections.rooms.key, userId);
    if (data == null) return [];

    // Remove the "id" key if it exists.
    data.remove("id");

    List<int> socketIds = [];

    // Iterate over each room in the data.
    data.forEach((roomName, roomContent) {
      if (roomContent is Map) {
        // Iterate over each category in the room.
        roomContent.forEach((category, devices) {
          if (devices is List) {
            // Iterate over each device in the category.
            for (var device in devices) {
              if (device is Map && device.containsKey('socket')) {
                var socketValue = device['socket'];
                if (socketValue is int) {
                  socketIds.add(socketValue);
                }
              }
            }
          }
        });
      }
    });

    return socketIds;
  }




}
