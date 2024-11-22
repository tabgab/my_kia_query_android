// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'login_credentials.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LoginCredentials _$LoginCredentialsFromJson(Map<String, dynamic> json) =>
    LoginCredentials(
      username: json['username'] as String,
      password: json['password'] as String,
      pin: json['pin'] as String?,
      region: $enumDecode(_$RegionEnumMap, json['region']),
      brand: $enumDecode(_$BrandEnumMap, json['brand']),
      useBiometric: json['useBiometric'] as bool? ?? false,
    );

Map<String, dynamic> _$LoginCredentialsToJson(LoginCredentials instance) =>
    <String, dynamic>{
      'username': instance.username,
      'password': instance.password,
      'pin': instance.pin,
      'region': _$RegionEnumMap[instance.region]!,
      'brand': _$BrandEnumMap[instance.brand]!,
      'useBiometric': instance.useBiometric,
    };

const _$RegionEnumMap = {
  Region.europe: 'europe',
  Region.canada: 'canada',
  Region.usa: 'usa',
};

const _$BrandEnumMap = {
  Brand.kia: 'kia',
  Brand.hyundai: 'hyundai',
};
