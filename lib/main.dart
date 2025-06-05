import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import 'providers/farm_provider.dart';
import 'screens/sensor_diagrams_screen.dart';
// import 'screens/statistics_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => FarmProvider(),
      child: MaterialApp(
        title: 'Agrinet',
        debugShowCheckedModeBanner: false,
        theme: ThemeData.dark().copyWith(
          colorScheme: ColorScheme.dark(
            primary: Colors.green,
            secondary: Colors.greenAccent,
            surface: const Color(0xFF1E1E1E),
            background: const Color(0xFF121212),
            onSurface: Colors.white,
            onBackground: Colors.white,
          ),
          scaffoldBackgroundColor: const Color(0xFF121212),
          cardTheme: CardTheme(
            color: const Color(0xFF1E1E1E),
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF1E1E1E),
            elevation: 0,
          ),
          useMaterial3: true,
        ),
        home: const HomeScreen(),
      ),
    );
  }
} 

/*
#include <DHT.h>

// Définir le type de capteur et la broche utilisée
#define DHTPIN 5         // Pin D5
#define DHTTYPE DHT22    // Capteur DHT22 (pas DHT11 !)

DHT dht(DHTPIN, DHTTYPE);

void setup() {
  Serial.begin(9600);
  Serial.println("Initialisation du capteur DHT22...");
  dht.begin();
}

void loop() {
  delay(2000);  // Délai recommandé pour les capteurs DHT

  float h = dht.readHumidity();    // Lecture de l'humidité
  float t = dht.readTemperature(); // Lecture de la température en °C

  // Vérification si les lectures sont valides
  if (isnan(h) || isnan(t)) {
    Serial.println("Erreur de lecture du capteur !");
    return;
  }

  Serial.print("Humidité : ");
  Serial.print(h);
  Serial.print(" %\t");
  Serial.print("Température : ");
  Serial.print(t);
  Serial.println(" °C");
}

*/