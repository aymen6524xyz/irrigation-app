import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ESP32Service {
  static const String _baseUrl = 'http://192.168.4.1'; // For HTTP requests

  // Send command to ESP32
  Future<void> sendCommand(String command, Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/$command'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to send command: ${response.statusCode}');
      }
    } catch (e) {
      print('Error sending command: $e');
      rethrow;
    }
  }

  // Toggle system power
  Future<void> togglePower(bool isOn) async {
    await sendCommand('power', {'state': isOn});
  }

  // Get current sensor readings
 // Get current sensor readings
  Future<Map<String, dynamic>> getSensorReadings() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/sensors'));

      if (response.statusCode == 200) {
        print('Raw sensor data: ${response.body}');
        final data = json.decode(response.body);

        // Return the data in the same form as updateSensorData expects
        // Example: { 'data': "S1:997,S2:1005,TEMP:24.9,DIST:15.47" }
        return {
          'data': data["data"] ?? "",
        };
      } else {
        throw Exception(
            'Failed to get sensor readings: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  

  // Get water consumption history
  // Future<List<double>> getWaterConsumptionHistory() async {
  //   try {
  //     final response = await http.get(Uri.parse('$_baseUrl/water-consumption'));

  //     if (response.statusCode == 200) {
  //       final List<dynamic> data = json.decode(response.body);
  //       return data.map((e) => e.toDouble()).toList();
  //     } else {
  //       throw Exception(
  //           'Failed to get water consumption: ${response.statusCode}');
  //     }
  //   } catch (e) {
  //     print('Error getting water consumption: $e');
  //     rethrow;
  //   }
  // }

  // No WebSocket, no dispose needed for WebSocket resources
  void dispose() {
    // Nothing to dispose now
  }
}
