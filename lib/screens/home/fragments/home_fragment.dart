// home_fragment.dart
import 'package:flutter/material.dart';
import 'package:skynet/data/room_data.dart';
import 'package:skynet/model/auth_data.model.dart';
import 'package:skynet/utils/firebase/db_service.dart';
import 'package:skynet/utils/shared_preferences/shared_preferences_service.dart';
import 'package:skynet/widgets/device_card.dart';
import 'package:skynet/widgets/room_section.dart';

class HomeFragment extends StatefulWidget {
  const HomeFragment({super.key});

  @override
  _HomeFragmentState createState() => _HomeFragmentState();
}

class _HomeFragmentState extends State<HomeFragment> {
  final _sharedPreferencesService = SharedPreferencesService();
  var _userName = "Home";
  bool _isBluetoothConnected = false;
  int _selectedIndex = 0;
  final _dbService = DbService();

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
        title: const Text("Home", style: TextStyle(color: Colors.white)),
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
                      const Text(
                        "Rooms",
                        style: TextStyle(
                          color: Color.fromARGB(255, 6, 26, 94),
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.more_vert,
                            color: Color.fromARGB(255, 6, 26, 94)),
                        onPressed: () {
                          // Handle three dot icon press
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  RoomSection(
                    selectedIndex: _selectedIndex,
                    onRoomSelected: (index) {
                      setState(() {
                        _selectedIndex = index;
                      });
                    },
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: SizedBox(
                width: double.maxFinite,
                child: GridView.builder(
                  itemCount: room_data_list[_selectedIndex]['devices'].length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemBuilder: (BuildContext context, int index) {
                    final device =
                    room_data_list[_selectedIndex]['devices'][index];
                    return DeviceCard(
                      isSelected: true,
                      room: room_data_list[_selectedIndex]['name'],
                      device: device,
                    );
                  },
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBannerCard(String username) {
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
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
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
                      padding: const EdgeInsets.only(right: 10.0),
                      child: Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: const BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 5),
                          const Text(
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
            children: const [
              Text(
                "Important News",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
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
