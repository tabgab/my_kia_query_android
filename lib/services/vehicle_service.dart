import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import '../models/vehicle.dart';
import 'package:path_provider/path_provider.dart';

class VehicleService {
  static const platform = MethodChannel('com.example.my_kia_query/kia_bridge');
  
  Future<bool> authenticate(String username, String password, String pin, String region, String brand) async {
    try {
      final bool result = await platform.invokeMethod('authenticate', {
        'username': username,
        'password': password,
        'pin': pin,
        'region': region,
        'brand': brand,
      });
      return result;
    } on PlatformException catch (e) {
      print('Failed to authenticate: ${e.message}');
      return false;
    }
  }

  Future<List<Vehicle>> getVehicles() async {
    try {
      final String result = await platform.invokeMethod('getVehicles');
      print('Raw JSON from Python bridge:');
      print(result);
      
      if (result.isEmpty || result == '[]') {
        print('No vehicle data received');
        return [];
      }

      List<dynamic> vehiclesJson;
      try {
        vehiclesJson = jsonDecode(result);
      } catch (e) {
        print('Error decoding JSON: $e');
        return [];
      }

      print('Decoded JSON:');
      print(const JsonEncoder.withIndent('  ').convert(vehiclesJson));
      
      final vehicles = <Vehicle>[];
      for (var json in vehiclesJson) {
        try {
          final vehicle = Vehicle.fromJson(json);
          vehicles.add(vehicle);
          
          // Debug output for each vehicle
          print('\nParsed Vehicle:');
          print('Name: ${vehicle.name}');
          print('Model: ${vehicle.model}');
          print('VIN: ${vehicle.vehicleIdentificationNumber}');
          if (vehicle.status != null) {
            print('Status:');
            print('  Odometer: ${vehicle.status!.odometer}');
            print('  Battery: ${vehicle.status!.battery?.level}');
            print('  EV Battery: ${vehicle.status!.evBattery?.level}');
            print('  Last Updated: ${vehicle.status!.lastUpdated}');
          }
        } catch (e) {
          print('Error parsing vehicle: $e');
          continue;
        }
      }

      // Cache the vehicle data for the widget
      await _cacheVehicleData(result);
      
      // Notify the widget about new data
      try {
        await platform.invokeMethod('notifyWidget');
      } catch (e) {
        print('Error notifying widget: $e');
      }
      
      return vehicles;
    } on PlatformException catch (e) {
      print('Failed to get vehicles: ${e.message}');
      return [];
    } catch (e) {
      print('Error getting vehicles: $e');
      return [];
    }
  }

  Future<bool> refreshVehicleData() async {
    try {
      final bool result = await platform.invokeMethod('refreshVehicleData');
      return result;
    } on PlatformException catch (e) {
      print('Failed to refresh vehicle data: ${e.message}');
      return false;
    }
  }

  Future<void> _cacheVehicleData(String jsonData) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final cacheDir = Directory('${directory.path}/cache');
      await cacheDir.create(recursive: true);
      final file = File('${cacheDir.path}/vehicle_data.json');
      await file.writeAsString(jsonData);
      print('Vehicle data cached successfully');
    } catch (e) {
      print('Error caching vehicle data: $e');
    }
  }
}
