import 'package:flutter/material.dart';

class DeviceDetailScreen extends StatelessWidget {
  final String category;
  final Map<String, dynamic> device;

  const DeviceDetailScreen({
    super.key,
    required this.category,
    required this.device,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(device['name'], style: const TextStyle(color: Colors.white)),
        backgroundColor: const Color.fromARGB(255, 6, 26, 94),
        elevation: 4.0,
        shadowColor: Colors.black.withOpacity(0.5),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Category: $category",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "Device Name: ${device['name']}",
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Device Details",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              device['description'] ?? "No additional information available.",
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Settings"),
        ],
        onTap: (index) {
          // Handle bottom bar navigation
        },
      ),
    );
  }
}
