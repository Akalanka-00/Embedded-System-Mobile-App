import 'package:flutter/material.dart';
import 'package:skynet/data/room_data.dart';
import 'package:skynet/model/auth_data.model.dart';
import 'package:skynet/utils/firebase/db_service.dart';

import '../../../utils/shared_preferences/shared_preferences_service.dart';

class HomeFragment extends StatefulWidget {
  HomeFragment({super.key});

  @override
  _HomeFragmentState createState() => _HomeFragmentState();
}

class _HomeFragmentState extends State<HomeFragment> {
  final _sharedPreferencesService = SharedPreferencesService();
  var _userName = "Home";
  bool _isBluetoothConnected = false;
  int _selectedIndex = 0;
  final _dbService = DbService();

  // final List<Map<String, dynamic>> rooms = [
  //   {"name": "Living Room", "icon": Icons.chair_alt},
  //   {"name": "Bed Room", "icon": Icons.bed},
  //   {"name": "Bath Room", "icon": Icons.bathtub},
  //   {"name": "Kitchen", "icon": Icons.kitchen},
  //   {"name": "Dining", "icon": Icons.dining},
  // ];

  // final List<Map<String, dynamic>> connectedDevices = [
  //   {"name": "Lighting", "status": true, "icon": Icons.lightbulb},
  //   {"name": "Smart TV", "status": false, "icon": Icons.tv},
  //   {"name": "CC Camera", "status": true, "icon": Icons.camera_alt},
  //   {"name": "Home Pod Mini", "status": false, "icon": Icons.speaker},
  // ];

  @override
  void initState() {
    super.initState();
    _loadUserName();
    _checkBluetoothConnection();
    _dbService.createDefaultRooms("userId");
  }

  Future<void> _loadUserName() async {
    _userName = await _sharedPreferencesService.getUserName();
    setState(() {});
  }

  void _checkBluetoothConnection() {
    _isBluetoothConnected = true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Skynet", style: TextStyle(color: Colors.white)),
        automaticallyImplyLeading: false,
        backgroundColor: const Color.fromARGB(255, 6, 26, 94),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications, color: Colors.white),
            onPressed: () {
              // Handle notification icon press
            },
          ),
        ],
        elevation: 4.0, // Add shadow to the AppBar
        shadowColor: Colors.black.withOpacity(0.5), // Customize shadow color
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                child: _buildBannerCard(_userName),
              ),
            ),
            _buildSchedulerCard(),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Rooms",
                        style: TextStyle(
                          color: const Color.fromARGB(255, 6, 26, 94),
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.more_vert,
                            color: const Color.fromARGB(255, 6, 26, 94)),
                        onPressed: () {
                          // Handle three dot icon press
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _buildRoomSection(),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: SizedBox(
                width: double.maxFinite,
                child: GridView.builder(
                  itemCount: room_data_list[_selectedIndex]['devices'].length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, // Number of items per row
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemBuilder: (BuildContext context, int index) {
                    final device =
                        room_data_list[_selectedIndex]['devices'][index];
                    return _buildDeviceCard(
                        room_data_list[_selectedIndex]['name'], device);
                  },
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

// This function will display the device card with the number of devices
  Widget _buildDeviceCard(String room, category) {
    String deviceName = category['name'];
    IconData deviceIcon = category['icon'];
    return FutureBuilder<LoginData?>(
      future: _sharedPreferencesService.getLoginData(),
      builder: (context, loginDataSnapshot) {
        if (loginDataSnapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (!loginDataSnapshot.hasData) {
          return Center(child: Text('Login data not found'));
        }

        String userId = loginDataSnapshot.data!.userID;

        return FutureBuilder<List<Map<String, dynamic>>>(
          future: _dbService.getDeviceByCategory(userId, room, deviceName),
          builder: (context, devicesSnapshot) {
            int totalDevices = 0;
            int connectedDevices = 0;
            if (devicesSnapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            if (!devicesSnapshot.hasData || devicesSnapshot.data!.isEmpty) {
            } else {
              List<Map<String, dynamic>> devices = devicesSnapshot.data!;
              totalDevices = devices.length;
              connectedDevices =
                  devices.where((device) => device['status'] == true).length;
            }

            return Card(
              color: Colors.blueAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      deviceIcon, // Example icon for devices
                      size: 32,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      deviceName,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      totalDevices == 0
                          ? 'No Devices Found'
                          : connectedDevices == 0
                              ? 'No Devices Connected'
                              : '$connectedDevices/$totalDevices Devices Connected',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildRoomSection() {
    final data = room_data_list;
    return SizedBox(
      height: 100, // Adjust the height for the scrollable bar
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: data.length,
        itemBuilder: (context, index) {
          final room = data[index];
          final isSelected = index == _selectedIndex;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedIndex = index; // Update the selected index
              });
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.blueAccent
                          : Colors.blueAccent.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Icon(
                      room['icon'],
                      size: 32,
                      color: isSelected ? Colors.white : Colors.blueAccent,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    room['name'],
                    style: TextStyle(
                      color: isSelected
                          ? Colors.blueAccent
                          : const Color.fromARGB(255, 6, 26, 94),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBannerCard(username) {
    return SizedBox(
      width: double.infinity,
      child: Card(
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: Container(
          height: 150,
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 6, 26, 94),
            borderRadius: BorderRadius.circular(15.0),
          ),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Welcome, \n$username",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Your home is in your hands",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 10,
                right: 0,
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.transparent,
                      child: Image.asset("assets/images/logo.png"),
                    ),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.only(
                          right: 10.0), // Adjust the padding here
                      child: Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            "Connected",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSchedulerCard() {
    return SizedBox(
      width: double.infinity,
      child: Card(
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15.0),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Important News",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Schedulers are going to run soon. Please be prepared.",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
