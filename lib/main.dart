import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/vehicle_provider.dart';
import 'services/vehicle_service.dart';
import 'screens/auth_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => VehicleProvider(VehicleService()),
      child: MaterialApp(
        title: 'MyKia Query',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
          useMaterial3: true,
        ),
        home: const AuthScreen(),
      ),
    );
  }
}
