import 'dart:async';
import 'package:flutter/material.dart';
import '../services/esp32_service.dart';

class FarmProvider extends ChangeNotifier {
  // test data
  Map<String, dynamic> testdata = {
    "data": "TEMP:24.9,S1:997,S2:1005,DIST:15.47"
  };

  final ESP32Service _esp32Service = ESP32Service();

  bool _isPowerOn = false;
  bool _isConnected =
      true; // Assume connected for initial state;  hadi ghir bach njrb the local data flkhr lazm nrj3ha (((False)))
  bool _isLoading = true;
  String? _lastError;
  DateTime? _lastUpdate;

  double _temperature = 0.0;
  double _humidity = 0.0;
  double _soilMoisture = 0.0;
  double _waterLevel = 0.0;
  List<double> _dailyWaterConsumption = List.generate(24, (index) => 0.0);

  Timer? _pollingTimer;

  // Getters
  bool get isPowerOn => _isPowerOn;
  bool get isConnected => true;
  bool get isLoading => _isLoading;
  String? get lastError => _lastError;
  DateTime? get lastUpdate => _lastUpdate;

  double get temperature => _temperature;
  double get humidity => _humidity;
  double get soilMoisture => _soilMoisture;
  double get waterLevel => _waterLevel;
  List<double> get dailyWaterConsumption => _dailyWaterConsumption;

  FarmProvider() {
    _startPolling();
  }

  void _startPolling() {
    _isLoading = true;
    notifyListeners();

    _fetchInitialData();

    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      fetchAndUpdateSensorData();
    });
  }

  Future<void> _fetchInitialData() async {
    try {
      final sensorData = await _esp32Service.getSensorReadings();
      _isConnected = true;
      _lastError = null;
      _lastUpdate = DateTime.now();
      updateSensorData(/*sensorData*/);
    } catch (e) {
      _isConnected = false;
      _lastError = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void updateSensorData() {               // kayn hna paramete
  final raw = testdata['data'] as String? ?? '';
  final parts = raw.split(',');

  double? temp, soil, hum, dist;

  for (var part in parts) {
    final kv = part.split(':');
    if (kv.length != 2) continue;

    final key = kv[0].trim().toUpperCase();
    final value = double.tryParse(kv[1].trim());

    if (value == null) continue;

    switch (key) {
      case 'TEMP':
        temp = value;
        break;
      case 'S1':
        soil = value;
        break;
      case 'S2':
        hum = value;
        break;
      case 'DIST':
        dist = value;
        break;
    }
  }

  // Update values if valid
  if (temp != null) _temperature = temp;
  if (soil != null) _soilMoisture = soil / 10.0; // Assuming S1 is 0-1000 range (convert to 0-100%)
  if (hum != null) _humidity = hum / 10.0; // Assuming S2 is 0-1000 range (convert to 0-100%)
  if (dist != null) _waterLevel = dist;

  print('✅ Sensor Updated: TEMP=$_temperature, S1=$_soilMoisture, S2=$_humidity, DIST=$_waterLevel');
  
  notifyListeners();
}

  Future<void> fetchAndUpdateSensorData() async {
    try {
      final sensorData = await _esp32Service.getSensorReadings();
      _isConnected = true;
      _lastError = null;
      _lastUpdate = DateTime.now();
      updateSensorData(/*sensorData*/);
    } catch (e) {
      _isConnected = false;
      _lastError = e.toString();
      notifyListeners();
    }
  }

  Future<void> togglePower() async {
    if (!_isConnected) {
      _lastError = 'Cannot toggle power: Not connected to ESP32';
      notifyListeners();
      return;
    }

    try {
      await _esp32Service.togglePower(!_isPowerOn);
      _isPowerOn = !_isPowerOn;
      _lastError = null;
      _lastUpdate = DateTime.now();
      notifyListeners();
    } catch (e) {
      _lastError = 'Failed to toggle power: ${e.toString()}';
      notifyListeners();
    }
  }

  Future<void> reconnect() async {
    _isLoading = true;
    _lastError = null;
    notifyListeners();

    try {
      _startPolling();
    } catch (e) {
      _lastError = 'Failed to reconnect: ${e.toString()}';
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _esp32Service.dispose();
    super.dispose();
  }
}
