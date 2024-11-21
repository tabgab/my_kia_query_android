// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vehicle.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Vehicle _$VehicleFromJson(Map<String, dynamic> json) => Vehicle(
      id: json['vehicleId'] as String,
      name: json['vehicleName'] as String,
      model: json['modelName'] as String,
      modelCode: json['modelCode'] as String?,
      type: json['vehicleType'] as String?,
      vin: json['vin'] as String,
      registrationDate: json['regDate'] as String?,
      brand: json['brandIndicator'] as String?,
      status: json['vehicleStatus'] == null
          ? null
          : VehicleStatus.fromJson(
              json['vehicleStatus'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$VehicleToJson(Vehicle instance) => <String, dynamic>{
      'vehicleId': instance.id,
      'vehicleName': instance.name,
      'modelName': instance.model,
      'modelCode': instance.modelCode,
      'vehicleType': instance.type,
      'vin': instance.vin,
      'regDate': instance.registrationDate,
      'brandIndicator': instance.brand,
      'vehicleStatus': instance.status?.toJson(),
    };

VehicleStatus _$VehicleStatusFromJson(Map<String, dynamic> json) =>
    VehicleStatus(
      lastUpdated: json['time'] as String?,
      airTemperature: json['airTemp'] == null
          ? null
          : AirTemperature.fromJson(json['airTemp'] as Map<String, dynamic>),
      engineRunning: json['engine'] as bool?,
      doorLock: json['doorLock'] as bool?,
      trunkOpen: json['trunkOpen'] as bool?,
      hoodOpen: json['hoodOpen'] as bool?,
      leftFrontDoorOpen: json['leftFrontDoor'] as bool?,
      rightFrontDoorOpen: json['rightFrontDoor'] as bool?,
      leftRearDoorOpen: json['leftRearDoor'] as bool?,
      rightRearDoorOpen: json['rightRearDoor'] as bool?,
      airConditioningOn: json['airCtrlOn'] as bool?,
      defrostOn: json['defrost'] as bool?,
      steeringWheelHeat: (json['steerWheelHeat'] as num?)?.toInt(),
      battery: json['battery'] == null
          ? null
          : BatteryStatus.fromJson(json['battery'] as Map<String, dynamic>),
      evBattery: json['evBattery'] == null
          ? null
          : EvBatteryStatus.fromJson(json['evBattery'] as Map<String, dynamic>),
      rangeKm: (json['dte'] as num?)?.toInt(),
      location: json['location'] == null
          ? null
          : VehicleLocation.fromJson(json['location'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$VehicleStatusToJson(VehicleStatus instance) =>
    <String, dynamic>{
      'time': instance.lastUpdated,
      'airTemp': instance.airTemperature?.toJson(),
      'engine': instance.engineRunning,
      'doorLock': instance.doorLock,
      'trunkOpen': instance.trunkOpen,
      'hoodOpen': instance.hoodOpen,
      'leftFrontDoor': instance.leftFrontDoorOpen,
      'rightFrontDoor': instance.rightFrontDoorOpen,
      'leftRearDoor': instance.leftRearDoorOpen,
      'rightRearDoor': instance.rightRearDoorOpen,
      'airCtrlOn': instance.airConditioningOn,
      'defrost': instance.defrostOn,
      'steerWheelHeat': instance.steeringWheelHeat,
      'battery': instance.battery?.toJson(),
      'evBattery': instance.evBattery?.toJson(),
      'dte': instance.rangeKm,
      'location': instance.location?.toJson(),
    };

AirTemperature _$AirTemperatureFromJson(Map<String, dynamic> json) =>
    AirTemperature(
      value: (json['value'] as num).toDouble(),
      unit: json['unit'] as String,
    );

Map<String, dynamic> _$AirTemperatureToJson(AirTemperature instance) =>
    <String, dynamic>{
      'value': instance.value,
      'unit': instance.unit,
    };

BatteryStatus _$BatteryStatusFromJson(Map<String, dynamic> json) =>
    BatteryStatus(
      stateOfCharge: (json['batSoc'] as num?)?.toInt(),
      state: json['batState'] as String?,
    );

Map<String, dynamic> _$BatteryStatusToJson(BatteryStatus instance) =>
    <String, dynamic>{
      'batSoc': instance.stateOfCharge,
      'batState': instance.state,
    };

EvBatteryStatus _$EvBatteryStatusFromJson(Map<String, dynamic> json) =>
    EvBatteryStatus(
      stateOfCharge: (json['batSoc'] as num?)?.toInt(),
      chargingTime: (json['remainTime2'] as List<dynamic>?)
          ?.map((e) => ChargingTime.fromJson(e as Map<String, dynamic>))
          .toList(),
      remainingRange: (json['drvDistance'] as List<dynamic>?)
          ?.map((e) => RemainingRange.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$EvBatteryStatusToJson(EvBatteryStatus instance) =>
    <String, dynamic>{
      'batSoc': instance.stateOfCharge,
      'remainTime2': instance.chargingTime,
      'drvDistance': instance.remainingRange,
    };

ChargingTime _$ChargingTimeFromJson(Map<String, dynamic> json) => ChargingTime(
      minutes: (json['remaining'] as num?)?.toInt(),
      type: json['type'] as String?,
    );

Map<String, dynamic> _$ChargingTimeToJson(ChargingTime instance) =>
    <String, dynamic>{
      'remaining': instance.minutes,
      'type': instance.type,
    };

RemainingRange _$RemainingRangeFromJson(Map<String, dynamic> json) =>
    RemainingRange(
      range: (json['rangeByFuel'] as num?)?.toInt(),
      type: json['type'] as String?,
    );

Map<String, dynamic> _$RemainingRangeToJson(RemainingRange instance) =>
    <String, dynamic>{
      'rangeByFuel': instance.range,
      'type': instance.type,
    };

VehicleLocation _$VehicleLocationFromJson(Map<String, dynamic> json) =>
    VehicleLocation(
      latitude: (json['lat'] as num).toDouble(),
      longitude: (json['lon'] as num).toDouble(),
      altitude: (json['alt'] as num?)?.toDouble(),
      speed: (json['speed'] as num?)?.toDouble(),
      heading: (json['heading'] as num?)?.toInt(),
    );

Map<String, dynamic> _$VehicleLocationToJson(VehicleLocation instance) =>
    <String, dynamic>{
      'lat': instance.latitude,
      'lon': instance.longitude,
      'alt': instance.altitude,
      'speed': instance.speed,
      'heading': instance.heading,
    };
