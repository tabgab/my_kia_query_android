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
  // Additional fields
  final bool? defrost;
  final bool? steeringWheelHeat;
  final bool? sideBackWindowHeat;
  final TirePressure? tirePressure;
  final EvStatus? evStatus;

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
    this.tirePressure,
    this.evStatus,
  });

  factory VehicleStatus.fromJson(Map<String, dynamic> json) {
    return VehicleStatus(
      engine: json['engine'] as bool?,
      climate: json['climate'] as bool?,
      doors: json['doors'] != null ? Map<String, bool>.from(json['doors'] as Map) : null,
      trunk: json['trunk'] as bool?,
      hood: json['hood'] as bool?,
      battery: json['battery'] != null ? BatteryStatus.fromJson(json['battery'] as Map<String, dynamic>) : null,
      evBattery: json['evBattery'] != null ? BatteryStatus.fromJson(json['evBattery'] as Map<String, dynamic>) : null,
      odometer: json['odometer'] != null ? (json['odometer'] as num).toDouble() : null,
      range: json['range'] != null ? (json['range'] as num).toDouble() : null,
      rangeKm: json['rangeKm'] != null ? (json['rangeKm'] as num).toDouble() : null,
      lastUpdated: json['last_updated'] as String?,
      engineRunning: json['engineRunning'] as bool?,
      doorLock: json['doorLock'] as bool?,
      airTemperature: json['airTemperature'] != null ? AirTemperature.fromJson(json['airTemperature'] as Map<String, dynamic>) : null,
      location: json['location'] != null ? Location.fromJson(json['location'] as Map<String, dynamic>) : null,
      defrost: json['defrost'] as bool?,
      steeringWheelHeat: json['steeringWheelHeat'] as bool?,
      sideBackWindowHeat: json['sideBackWindowHeat'] as bool?,
      tirePressure: json['tirePressure'] != null ? TirePressure.fromJson(json['tirePressure'] as Map<String, dynamic>) : null,
      evStatus: json['evStatus'] != null ? EvStatus.fromJson(json['evStatus'] as Map<String, dynamic>) : null,
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
      'tirePressure': tirePressure?.toJson(),
      'evStatus': evStatus?.toJson(),
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

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      latitude: json['latitude'] != null ? (json['latitude'] as num).toDouble() : null,
      longitude: json['longitude'] != null ? (json['longitude'] as num).toDouble() : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}

class TirePressure {
  final double? frontLeft;
  final double? frontRight;
  final double? rearLeft;
  final double? rearRight;

  TirePressure({
    this.frontLeft,
    this.frontRight,
    this.rearLeft,
    this.rearRight,
  });

  factory TirePressure.fromJson(Map<String, dynamic> json) {
    return TirePressure(
      frontLeft: json['frontLeft'] != null ? (json['frontLeft'] as num).toDouble() : null,
      frontRight: json['frontRight'] != null ? (json['frontRight'] as num).toDouble() : null,
      rearLeft: json['rearLeft'] != null ? (json['rearLeft'] as num).toDouble() : null,
      rearRight: json['rearRight'] != null ? (json['rearRight'] as num).toDouble() : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'frontLeft': frontLeft,
      'frontRight': frontRight,
      'rearLeft': rearLeft,
      'rearRight': rearRight,
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
