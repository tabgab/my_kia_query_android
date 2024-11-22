import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/vehicle_provider.dart';
import '../models/enums.dart';
import '../models/login_credentials.dart';
import '../services/auth_service.dart';
import 'vehicle_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _pinController = TextEditingController();
  Region _selectedRegion = Region.europe;
  Brand _selectedBrand = Brand.kia;
  bool _rememberMe = false;
  bool _useBiometric = false;
  late AuthService _authService;
  bool _canUseBiometrics = false;
  bool _isAuthenticating = true;
  String? _securityPin;

  @override
  void initState() {
    super.initState();
    _initializeAuth();
  }

  Future<void> _initializeAuth() async {
    _authService = await AuthService.getInstance();
    _canUseBiometrics = await _authService.canUseBiometrics();
    
    if (_authService.hasSavedCredentials()) {
      final credentials = _authService.getSavedCredentials();
      if (credentials != null && _authService.shouldUseBiometric() && _canUseBiometrics) {
        final authenticated = await _authService.authenticateWithBiometrics();
        if (authenticated && mounted) {
          _loadSavedCredentials();
          // Auto-login after successful biometric authentication
          final provider = context.read<VehicleProvider>();
          final success = await provider.authenticate(
            username: credentials.username,
            password: credentials.password,
            pin: credentials.pin ?? '', // Provide empty string if PIN is null
            region: credentials.region,
            brand: credentials.brand,
          );
          
          if (success && mounted) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const VehicleScreen()),
            );
            return;
          }
        }
      } else if (_authService.hasPin()) {
        _showPinDialog();
      }
    }
    
    setState(() {
      _isAuthenticating = false;
    });
  }

  void _loadSavedCredentials() {
    final credentials = _authService.getSavedCredentials();
    if (credentials != null) {
      setState(() {
        _usernameController.text = credentials.username;
        _passwordController.text = credentials.password;
        if (credentials.pin != null) {
          _pinController.text = credentials.pin!;
        }
        _selectedRegion = credentials.region;
        _selectedBrand = credentials.brand;
        _rememberMe = true;
        _useBiometric = _authService.shouldUseBiometric();
      });
    }
  }

  Future<void> _toggleBiometric(bool? value) async {
    if (value == true) {
      // Require fingerprint authentication before enabling
      final authenticated = await _authService.authenticateWithBiometrics();
      if (authenticated) {
        setState(() {
          _useBiometric = true;
        });
      } else {
        // Show error message if authentication fails
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Fingerprint authentication failed. Cannot enable fingerprint login.'),
            ),
          );
        }
      }
    } else {
      setState(() {
        _useBiometric = false;
      });
    }
  }

  Future<void> _showPinDialog() async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        final pinController = TextEditingController();
        return AlertDialog(
          title: const Text('Enter Security PIN'),
          content: TextField(
            controller: pinController,
            keyboardType: TextInputType.number,
            maxLength: 6,
            obscureText: true,
            decoration: const InputDecoration(
              hintText: 'Enter your 6-digit PIN',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final verified = await _authService.verifyPin(pinController.text);
                Navigator.of(context).pop(verified);
              },
              child: const Text('Verify'),
            ),
          ],
        );
      },
    );

    if (result == true) {
      _loadSavedCredentials();
    }
  }

  Future<void> _showSetPinDialog() async {
    final result = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        final pinController = TextEditingController();
        final confirmPinController = TextEditingController();
        return AlertDialog(
          title: const Text('Set Security PIN'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: pinController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                obscureText: true,
                decoration: const InputDecoration(
                  hintText: 'Enter 6-digit PIN',
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: confirmPinController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                obscureText: true,
                decoration: const InputDecoration(
                  hintText: 'Confirm PIN',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(null);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (pinController.text == confirmPinController.text &&
                    pinController.text.length == 6) {
                  Navigator.of(context).pop(pinController.text);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('PINs must match and be 6 digits'),
                    ),
                  );
                }
              },
              child: const Text('Set PIN'),
            ),
          ],
        );
      },
    );

    if (result != null) {
      _securityPin = result;
    } else {
      setState(() {
        _rememberMe = false;
      });
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _authenticate() async {
    if (_formKey.currentState!.validate()) {
      final provider = context.read<VehicleProvider>();
      final success = await provider.authenticate(
        username: _usernameController.text,
        password: _passwordController.text,
        pin: _pinController.text.isEmpty ? '' : _pinController.text,
        region: _selectedRegion,
        brand: _selectedBrand,
      );

      if (success && mounted) {
        if (_rememberMe) {
          if (!_canUseBiometrics && _securityPin == null) {
            await _showSetPinDialog();
          }
          
          final credentials = LoginCredentials(
            username: _usernameController.text,
            password: _passwordController.text,
            pin: _pinController.text.isEmpty ? null : _pinController.text,
            region: _selectedRegion,
            brand: _selectedBrand,
            useBiometric: _useBiometric,
          );
          await _authService.saveCredentials(credentials, _useBiometric);
          
          if (_securityPin != null) {
            await _authService.savePin(_securityPin!);
          }
        } else {
          await _authService.clearCredentials();
        }

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const VehicleScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isAuthenticating) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _usernameController,
                  decoration: const InputDecoration(labelText: 'Username'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your username';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(labelText: 'Password'),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _pinController,
                  decoration: const InputDecoration(
                    labelText: 'PIN (Optional)',
                    hintText: 'Enter PIN if required',
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<Region>(
                  value: _selectedRegion,
                  decoration: const InputDecoration(labelText: 'Region'),
                  items: Region.values.map((region) {
                    return DropdownMenuItem(
                      value: region,
                      child: Text(region.toString().split('.').last),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedRegion = value;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<Brand>(
                  value: _selectedBrand,
                  decoration: const InputDecoration(labelText: 'Brand'),
                  items: Brand.values.map((brand) {
                    return DropdownMenuItem(
                      value: brand,
                      child: Text(brand.toString().split('.').last),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedBrand = value;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Checkbox(
                      value: _rememberMe,
                      onChanged: (value) {
                        setState(() {
                          _rememberMe = value ?? false;
                          if (!_rememberMe) {
                            _useBiometric = false;
                          }
                        });
                      },
                    ),
                    const Text('Remember me'),
                    if (_canUseBiometrics && _rememberMe) ...[
                      const SizedBox(width: 16),
                      Checkbox(
                        value: _useBiometric,
                        onChanged: _toggleBiometric,
                      ),
                      const Text('Use fingerprint'),
                    ],
                  ],
                ),
                const SizedBox(height: 24),
                Consumer<VehicleProvider>(
                  builder: (context, provider, child) {
                    if (provider.isLoading) {
                      return const CircularProgressIndicator();
                    }
                    return ElevatedButton(
                      onPressed: _authenticate,
                      child: const Text('Login'),
                    );
                  },
                ),
                const SizedBox(height: 16),
                Consumer<VehicleProvider>(
                  builder: (context, provider, child) {
                    if (provider.error != null) {
                      return Text(
                        provider.error!,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
