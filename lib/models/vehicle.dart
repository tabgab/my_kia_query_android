class Vehicle {
  final String id;
  final String name;
  final String model;
  final String? registrationDate;
  final String? vehicleIdentificationNumber;
  final VehicleStatus? status;

  Vehicle({
    required this.id,
    required this.name,
    required this.model,
    this.registrationDate,
    this.vehicleIdentificationNumber,
    this.status,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      id: json['id'] as String,
      name: json['name'] as String,
      model: json['model'] as String,
      registrationDate: json['registration_date'] as String?,
      vehicleIdentificationNumber: json['vehicle_identification_number'] as String?,
      status: json['status'] != null ? VehicleStatus.fromJson(json['status'] as Map<String, dynamic>) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'model': model,
      'registration_date': registrationDate,
      'vehicle_identification_number': vehicleIdentificationNumber,
      'status': status?.toJson(),
    };
  }
}

class VehicleStatus {
  final bool? engine;
  final bool? climate;
  final Map<String, bool>? doors;
  final bool? trunk;
  final bool? hood;
  final BatteryStatus? battery;
  final BatteryStatus? evBattery;
  final double? odometer;
  final double? range;
  final double? rangeKm;
  final String? lastUpdated;
  final bool? engineRunning;
  final bool? doorLock;
  final AirTemperature? airTemperature;
  final Location? location;
  final bool? defrost;
  final bool? steeringWheelHeat;
  final bool? sideBackWindowHeat;
  final EvStatus? evStatus;
  final ConsumptionData? consumption;

  VehicleStatus({
    this.engine,
    this.climate,
    this.doors,
    this.trunk,
    this.hood,
    this.battery,
    this.evBattery,
    this.odometer,
    this.range,
    this.rangeKm,
    this.lastUpdated,
    this.engineRunning,
    this.doorLock,
    this.airTemperature,
    this.location,
    this.defrost,
    this.steeringWheelHeat,
    this.sideBackWindowHeat,
    this.evStatus,
    this.consumption,
  });

  factory VehicleStatus.fromJson(Map<String, dynamic> json) {
    // Try to get consumption data from either root level or Drivetrain structure
    ConsumptionData? consumptionData;
    if (json['consumption'] != null) {
      // Try root level first
      Map<String, dynamic> consumption = json['consumption'] as Map<String, dynamic>;
      consumptionData = ConsumptionData(
        currentDrive: consumption['currentDrive'] != null ? (consumption['currentDrive'] as num).toDouble() : null,
        sinceLastCharge: consumption['sinceLastCharge'] != null ? (consumption['sinceLastCharge'] as num).toDouble() : null,
        sinceLastReset: consumption['sinceLastReset'] != null ? (consumption['sinceLastReset'] as num).toDouble() : null,
      );
    } else {
      // Try Drivetrain structure as fallback
      Map<String, dynamic>? drivetrain = json['Drivetrain'] as Map<String, dynamic>?;
      Map<String, dynamic>? fuelSystem = drivetrain?['FuelSystem'] as Map<String, dynamic>?;
      Map<String, dynamic>? averageFuelEconomy = fuelSystem?['AverageFuelEconomy'] as Map<String, dynamic>?;
      
      if (averageFuelEconomy != null) {
        consumptionData = ConsumptionData(
          currentDrive: averageFuelEconomy['Drive'] != null ? (averageFuelEconomy['Drive'] as num).toDouble() : null,
          sinceLastCharge: averageFuelEconomy['AfterRefuel'] != null ? (averageFuelEconomy['AfterRefuel'] as num).toDouble() : null,
          sinceLastReset: averageFuelEconomy['Accumulated'] != null ? (averageFuelEconomy['Accumulated'] as num).toDouble() : null,
        );
      }
    }

    // Get the location data from the raw JSON structure
    Map<String, dynamic>? locationData = json['Location'] as Map<String, dynamic>?;
    Location? location;
    if (locationData != null) {
      Map<String, dynamic>? geoCoord = locationData['GeoCoord'] as Map<String, dynamic>?;
      if (geoCoord != null) {
        location = Location(
          latitude: geoCoord['Latitude'] != null ? (geoCoord['Latitude'] as num).toDouble() : null,
          longitude: geoCoord['Longitude'] != null ? (geoCoord['Longitude'] as num).toDouble() : null,
        );
      }
    } else if (json['location'] != null) {
      Map<String, dynamic> locationJson = json['location'] as Map<String, dynamic>;
      location = Location(
        latitude: locationJson['latitude'] != null ? (locationJson['latitude'] as num).toDouble() : null,
        longitude: locationJson['longitude'] != null ? (locationJson['longitude'] as num).toDouble() : null,
      );
    }

    // Try to get odometer value from either root level or Drivetrain object
    double? odometerValue;
    if (json['odometer'] != null) {
      odometerValue = (json['odometer'] as num).toDouble();
    } else if (json['Drivetrain']?['Odometer'] != null) {
      odometerValue = (json['Drivetrain']['Odometer'] as num).toDouble();
    }

    return VehicleStatus(
      engine: json['engine'] as bool?,
      climate: json['climate'] as bool?,
      doors: json['doors'] != null ? Map<String, bool>.from(json['doors'] as Map) : null,
      trunk: json['trunk'] as bool?,
      hood: json['hood'] as bool?,
      battery: json['battery'] != null ? BatteryStatus.fromJson(json['battery'] as Map<String, dynamic>) : null,
      evBattery: json['evBattery'] != null ? BatteryStatus.fromJson(json['evBattery'] as Map<String, dynamic>) : null,
      odometer: odometerValue,
      range: json['range'] != null ? (json['range'] as num).toDouble() : null,
      rangeKm: json['rangeKm'] != null ? (json['rangeKm'] as num).toDouble() : null,
      lastUpdated: json['last_updated'] as String?,
      engineRunning: json['engineRunning'] as bool?,
      doorLock: json['doorLock'] as bool?,
      airTemperature: json['airTemperature'] != null ? AirTemperature.fromJson(json['airTemperature'] as Map<String, dynamic>) : null,
      location: location,
      defrost: json['defrost'] as bool?,
      steeringWheelHeat: json['steeringWheelHeat'] as bool?,
      sideBackWindowHeat: json['sideBackWindowHeat'] as bool?,
      evStatus: json['evStatus'] != null ? EvStatus.fromJson(json['evStatus'] as Map<String, dynamic>) : null,
      consumption: consumptionData,
    );
  }

 Map<String, dynamic> toJson() {
    return {
      'engine': engine,
      'climate': climate,
      'doors': doors,
      'trunk': trunk,
      'hood': hood,
      'battery': battery?.toJson(),
      'evBattery': evBattery?.toJson(),
      'odometer': odometer,
      'range': range,
      'rangeKm': rangeKm,
      'last_updated': lastUpdated,
      'engineRunning': engineRunning,
      'doorLock': doorLock,
      'airTemperature': airTemperature?.toJson(),
      'location': location?.toJson(),
      'defrost': defrost,
      'steeringWheelHeat': steeringWheelHeat,
      'sideBackWindowHeat': sideBackWindowHeat,
      'evStatus': evStatus?.toJson(),
      'consumption': consumption?.toJson(),
    };
  }
}

class ConsumptionData {
  final double? currentDrive;
  final double? sinceLastCharge;
  final double? sinceLastReset;

  ConsumptionData({
    this.currentDrive,
    this.sinceLastCharge,
    this.sinceLastReset,
  });

  Map<String, dynamic> toJson() {
    return {
      'currentDrive': currentDrive,
      'sinceLastCharge': sinceLastCharge,
      'sinceLastReset': sinceLastReset,
    };
  }
}

class BatteryStatus {
  final double? level;
  final bool? charging;
  final double? stateOfCharge;
  final String? chargingTime;

  BatteryStatus({
    this.level,
    this.charging,
    this.stateOfCharge,
    this.chargingTime,
  });

  factory BatteryStatus.fromJson(Map<String, dynamic> json) {
    return BatteryStatus(
      level: json['level'] != null ? (json['level'] as num).toDouble() : null,
      charging: json['charging'] as bool?,
      stateOfCharge: json['stateOfCharge'] != null ? (json['stateOfCharge'] as num).toDouble() : null,
      chargingTime: json['chargingTime'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'level': level,
      'charging': charging,
      'stateOfCharge': stateOfCharge,
      'chargingTime': chargingTime,
    };
  }
}

class AirTemperature {
  final double? value;
  final String? unit;

  AirTemperature({
    this.value,
    this.unit,
  });

  factory AirTemperature.fromJson(Map<String, dynamic> json) {
    return AirTemperature(
      value: json['value'] != null ? (json['value'] as num).toDouble() : null,
      unit: json['unit'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'value': value,
      'unit': unit,
    };
  }
}

class Location {
  final double? latitude;
  final double? longitude;

  Location({
    this.latitude,
    this.longitude,
  });

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}

class EvStatus {
  final bool? pluggedIn;
  final bool? charging;
  final double? batteryCharge12V;
  final double? batteryChargeHV;
  final String? remainingChargingTime;
  final double? estimatedRange;

  EvStatus({
    this.pluggedIn,
    this.charging,
    this.batteryCharge12V,
    this.batteryChargeHV,
    this.remainingChargingTime,
    this.estimatedRange,
  });

  factory EvStatus.fromJson(Map<String, dynamic> json) {
    return EvStatus(
      pluggedIn: json['pluggedIn'] as bool?,
      charging: json['charging'] as bool?,
      batteryCharge12V: json['batteryCharge12V'] != null ? (json['batteryCharge12V'] as num).toDouble() : null,
      batteryChargeHV: json['batteryChargeHV'] != null ? (json['batteryChargeHV'] as num).toDouble() : null,
      remainingChargingTime: json['remainingChargingTime'] as String?,
      estimatedRange: json['estimatedRange'] != null ? (json['estimatedRange'] as num).toDouble() : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pluggedIn': pluggedIn,
      'charging': charging,
      'batteryCharge12V': batteryCharge12V,
      'batteryChargeHV': batteryChargeHV,
      'remainingChargingTime': remainingChargingTime,
      'estimatedRange': estimatedRange,
    };
  }
}
