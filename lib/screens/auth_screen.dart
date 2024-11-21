import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/vehicle_provider.dart';
import '../models/enums.dart';
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
        pin: _pinController.text,
        region: _selectedRegion,
        brand: _selectedBrand,
      );

      if (success && mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const VehicleScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
                      child: Text(region.toString()),
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
                      child: Text(brand.toString()),
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
