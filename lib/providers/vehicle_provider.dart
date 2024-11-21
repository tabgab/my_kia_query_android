import 'package:flutter/material.dart';
import '../models/vehicle.dart';
import '../models/enums.dart';
import '../services/vehicle_service.dart';

class VehicleProvider extends ChangeNotifier {
  final VehicleService _service;
  List<Vehicle> _vehicles = [];
  bool _isLoading = false;
  bool _isAuthenticated = false;
  String? _error;

  VehicleProvider(this._service);

  List<Vehicle> get vehicles => _vehicles;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;
  String? get error => _error;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? value) {
    _error = value;
    notifyListeners();
  }

  Future<bool> authenticate({
    required String username,
    required String password,
    required String pin,
    required Region region,
    required Brand brand,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      final success = await _service.authenticate(
        username,
        password,
        pin,
        region.value,
        brand.value,
      );

      _isAuthenticated = success;
      notifyListeners();

      if (success) {
        await refreshVehicles();
      }

      return success;
    } catch (e) {
      _setError('Authentication failed: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> refreshVehicles() async {
    if (!_isAuthenticated) {
      _setError('Not authenticated');
      return;
    }

    _setLoading(true);
    _setError(null);

    try {
      final vehicles = await _service.getVehicles();
      if (vehicles.isEmpty) {
        print('No vehicles returned from service');
      } else {
        print('Received ${vehicles.length} vehicles from service');
        for (var vehicle in vehicles) {
          print('Vehicle: ${vehicle.name}');
          print('Status: ${vehicle.status != null ? 'present' : 'missing'}');
        }
      }
      _vehicles = vehicles;
      notifyListeners();
    } catch (e) {
      _setError('Failed to get vehicles: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> refreshVehicleData() async {
    if (!_isAuthenticated) {
      _setError('Not authenticated');
      return;
    }

    _setLoading(true);
    _setError(null);

    try {
      final success = await _service.refreshVehicleData();
      if (success) {
        await refreshVehicles();
      } else {
        _setError('Failed to refresh vehicle data');
      }
    } catch (e) {
      _setError('Failed to refresh vehicle data: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  String getFormattedRange(Vehicle vehicle) {
    final range = vehicle.status?.rangeKm;
    if (range != null) {
      return '${range.toStringAsFixed(1)} km';
    }
    return 'N/A';
  }

  String getFormattedBatteryLevel(Vehicle vehicle) {
    final evBattery = vehicle.status?.evBattery;
    final battery = vehicle.status?.battery;

    String batteryInfo = '';

    // Add EV battery info if available
    if (evBattery?.level != null) {
      batteryInfo = '${evBattery!.level!.toStringAsFixed(1)}%';
      if (evBattery.charging == true) {
        batteryInfo += ' (Charging)';
      }
    }

    // Add 12V battery info if available
    if (battery?.level != null) {
      if (batteryInfo.isNotEmpty) {
        batteryInfo += ' | ';
      }
      batteryInfo += '12V: ${battery!.level!.toStringAsFixed(1)}%';
    }

    return batteryInfo.isNotEmpty ? batteryInfo : 'N/A';
  }

  String getFormattedChargingTime(Vehicle vehicle) {
    final evStatus = vehicle.status?.evStatus;
    if (evStatus?.remainingChargingTime != null) {
      return evStatus!.remainingChargingTime!;
    }
    return 'N/A';
  }

  String getFormattedOdometer(Vehicle vehicle) {
    final odometer = vehicle.status?.odometer;
    if (odometer != null) {
      return '${odometer.toStringAsFixed(1)} km';
    }
    return 'N/A';
  }

  String getFormattedLastUpdated(Vehicle vehicle) {
    final lastUpdated = vehicle.status?.lastUpdated;
    if (lastUpdated != null) {
      try {
        final dateTime = DateTime.parse(lastUpdated);
        return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} '
               '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}:${dateTime.second.toString().padLeft(2, '0')}';
      } catch (e) {
        return lastUpdated;
      }
    }
    return 'N/A';
  }

  String getFormattedTirePressure(double? pressure) {
    if (pressure != null) {
      return '${pressure.toStringAsFixed(1)} bar';
    }
    return 'N/A';
  }

  String getFormattedTemperature(Vehicle vehicle) {
    final temp = vehicle.status?.airTemperature;
    if (temp?.value != null) {
      return '${temp!.value?.toStringAsFixed(1)}°${temp.unit ?? 'C'}';
    }
    return 'N/A';
  }
}
