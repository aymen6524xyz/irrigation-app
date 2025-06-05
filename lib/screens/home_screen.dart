import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/farm_provider.dart';
import '../widgets/sensor_card.dart';
import 'sensor_diagrams_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agrinet Dashboard'),
        actions: [
          Consumer<FarmProvider>(
            builder: (context, farmProvider, child) {
              return GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('ESP32 Connection Status'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Status: ${farmProvider.isConnected ? 'Connected' : 'Disconnected'}'),
                          if (farmProvider.lastError != null) ...[
                            const SizedBox(height: 8),
                            Text(
                              'Error: ${farmProvider.lastError}',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.error,
                              ),
                            ),
                          ],
                          if (farmProvider.lastUpdate != null) ...[
                            const SizedBox(height: 8),
                            Text('Last Update: ${farmProvider.lastUpdate.toString()}'),
                          ],
                        ],
                      ),
                      actions: [
                        if (!farmProvider.isConnected)
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              farmProvider.reconnect();
                            },
                            child: const Text('Reconnect'),
                          ),
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Close'),
                        ),
                      ],
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      if (farmProvider.isLoading)
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        )
                      else
                        Icon(
                          farmProvider.isConnected ? Icons.wifi : Icons.wifi_off,
                          color: farmProvider.isConnected ? Colors.green : Colors.red,
                        ),
                      const SizedBox(width: 4),
                      Text(
                        farmProvider.isConnected ? 'Connected' : 'Disconnected',
                        style: TextStyle(
                          color: farmProvider.isConnected ? Colors.green : Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<FarmProvider>(
        builder: (context, farmProvider, child) {
          if (farmProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Power Button
                Center(
                  child: GestureDetector(
                    onTap: farmProvider.isConnected ? farmProvider.togglePower : null,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: farmProvider.isConnected
                            ? (farmProvider.isPowerOn ? Colors.green : Colors.red)
                            : Colors.grey,
                        boxShadow: [
                          BoxShadow(
                            color: (farmProvider.isPowerOn ? Colors.green : Colors.red)
                                .withOpacity(farmProvider.isConnected ? 0.3 : 0.1),
                            blurRadius: 15,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Icon(
                        farmProvider.isPowerOn ? Icons.power_settings_new : Icons.power_off,
                        size: 48,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Sensor Readings
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Sensor Readings',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    TextButton.icon(
                      onPressed: farmProvider.isConnected
                          ? () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const SensorDiagramsScreen(),
                                ),
                              );
                            }
                          : null,
                      icon: const Icon(Icons.show_chart),
                      label: const Text('View Charts'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 1.5,
                  children: [
                    SensorCard(
                      title: 'Temperature',
                      value: farmProvider.isConnected
                          ? '${farmProvider.temperature.toStringAsFixed(1)}°C'
                          : '--°C',
                      icon: Icons.thermostat,
                      color: farmProvider.isConnected ? Colors.orange : Colors.grey,
                    ),
                    SensorCard(
                      title: 'Humidity',
                      value: farmProvider.isConnected
                          ? '${farmProvider.humidity.toStringAsFixed(1)}%'
                          : '--%',
                      icon: Icons.water_drop,
                      color: farmProvider.isConnected ? Colors.blue : Colors.grey,
                    ),
                    SensorCard(
                      title: 'Soil Moisture',
                      value: farmProvider.isConnected
                          ? '${farmProvider.soilMoisture.toStringAsFixed(1)}%'
                          : '--%',
                      icon: Icons.grass,
                      color: farmProvider.isConnected ? Colors.green : Colors.grey,
                    ),
                    SensorCard(
                      title: 'Water Level',
                      value: farmProvider.isConnected
                          ? '${farmProvider.waterLevel.toStringAsFixed(1)}%'
                          : '--%',
                      icon: Icons.water,
                      color: farmProvider.isConnected ? Colors.lightBlue : Colors.grey,
                    ),
                  ],
                ),
                if (!farmProvider.isConnected) ...[
                  const SizedBox(height: 24),
                  Center(
                    child: Text(
                      'Not connected to ESP32',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: TextButton.icon(
                      onPressed: farmProvider.reconnect,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Reconnect'),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
} 