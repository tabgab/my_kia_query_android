import 'package:json_annotation/json_annotation.dart';
import 'enums.dart';

part 'login_credentials.g.dart';

@JsonSerializable()
class LoginCredentials {
  final String username;
  final String password;
  final String? pin;
  final Region region;
  final Brand brand;
  final bool useBiometric;

  LoginCredentials({
    required this.username,
    required this.password,
    this.pin,
    required this.region,
    required this.brand,
    this.useBiometric = false,
  });

  factory LoginCredentials.fromJson(Map<String, dynamic> json) =>
      _$LoginCredentialsFromJson(json);

  Map<String, dynamic> toJson() => _$LoginCredentialsToJson(this);
}
