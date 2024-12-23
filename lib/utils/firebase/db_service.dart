import 'dart:developer';

import 'package:skynet/data/room_data.dart';
import 'package:skynet/enum/db_collections.dart';
import 'package:skynet/utils/firebase/init_firebase.dart';

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
    log("data: $name");
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
  
}
