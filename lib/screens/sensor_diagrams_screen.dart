import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/farm_provider.dart';

class SensorDiagramsScreen extends StatelessWidget {
  const SensorDiagramsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sensor Diagrams'),
        backgroundColor: Theme.of(context).colorScheme.surface,
      ),
      body: Consumer<FarmProvider>(
        builder: (context, farmProvider, child) {
          // if (!farmProvider.isConnected) {
          //   return Center(
          //     child: Column(
          //       mainAxisAlignment: MainAxisAlignment.center,
          //       children: [
          //         Icon(
          //           Icons.wifi_off,
          //           size: 64,
          //           color: Theme.of(context).colorScheme.error,
          //         ),
          //         const SizedBox(height: 16),
          //         Text(
          //           'Not Connected to ESP32',
          //           style: Theme.of(context).textTheme.titleLarge?.copyWith(
          //                 color: Theme.of(context).colorScheme.error,
          //               ),
          //         ),
          //         const SizedBox(height: 8),
          //         TextButton.icon(
          //           onPressed: () {
          //             farmProvider.reconnect();
          //           },
          //           icon: const Icon(Icons.refresh),
          //           label: const Text('Reconnect'),
          //         ),
          //       ],
          //     ),
          //   );
          // }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildSensorChart(
                context,
                'Temperature',
                farmProvider.temperature,
                Colors.orange,
                '°C',
                Icons.thermostat,
              ),
              const SizedBox(height: 16),
              _buildSensorChart(
                context,
                'Humidity',
                farmProvider.humidity,
                Colors.blue,
                '%',
                Icons.water_drop,
              ),
              const SizedBox(height: 16),
              _buildSensorChart(
                context,
                'Soil Moisture',
                farmProvider.soilMoisture,
                Colors.green,
                '%',
                Icons.grass,
              ),
              const SizedBox(height: 16),
              _buildSensorChart(
                context,
                'Water Level',
                farmProvider.waterLevel,
                Colors.cyan,
                '%',
                Icons.water,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSensorChart(
    BuildContext context,
    String title,
    double currentValue,
    Color color,
    String unit,
    IconData icon,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                Text(
                  '$currentValue$unit',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: color,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return LineChart(
                    LineChartData(
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        horizontalInterval: 1,
                        getDrawingHorizontalLine: (value) {
                          return FlLine(
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
                            strokeWidth: 1,
                          );
                        },
                      ),
                      titlesData: FlTitlesData(
                        show: true,
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 30,
                            interval: 6,
                            getTitlesWidget: (value, meta) {
                              return Text(
                                '${value.toInt()}:00',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                                  fontSize: 12,
                                ),
                              );
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: 100,
                            getTitlesWidget: (value, meta) {
                              return Text(
                                '${value.toInt()}$unit',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                                  fontSize: 12,
                                ),
                              );
                            },
                            reservedSize: 30,
                          ),
                        ),
                      ),
                      borderData: FlBorderData(
                        show: true,
                        border: Border(
                          bottom: BorderSide(
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
                          ),
                          left: BorderSide(
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
                          ),
                        ),
                      ),
                      lineBarsData: [
                        LineChartBarData(
                          spots: List.generate(
                            24,
                            (index) => FlSpot(
                              index.toDouble(),
                              currentValue + (index % 3 - 1) * 2, // Simulated data variation
                            ),
                          ),
                          isCurved: true,
                          color: color,
                          barWidth: 3,
                          dotData: FlDotData(
                            show: true,
                            getDotPainter: (spot, percent, barData, index) {
                              return FlDotCirclePainter(
                                radius: 4,
                                color: color,
                                strokeWidth: 1,
                                strokeColor: Theme.of(context).colorScheme.surface,
                              );
                            },
                          ),
                          belowBarData: BarAreaData(
                            show: true,
                            color: color.withOpacity(0.1),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
} 