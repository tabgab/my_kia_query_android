import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/vehicle_provider.dart';
import '../models/vehicle.dart';

class VehicleScreen extends StatefulWidget {
  const VehicleScreen({super.key});

  @override
  State<VehicleScreen> createState() => _VehicleScreenState();
}

class _VehicleScreenState extends State<VehicleScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshData();
    });
  }

  Future<void> _refreshData() async {
    if (!mounted) return;
    final provider = context.read<VehicleProvider>();
    await provider.refreshVehicleData();
  }

  Future<void> _openInMaps(double latitude, double longitude) async {
    // Swap latitude and longitude since the API response has them in the wrong order
    final uri = Uri.https('www.google.com', '/maps', {
      'q': '$longitude,$latitude',  // Swap order for Google Maps URL format
    });
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

 Widget _buildLocationSection(Location location) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Vehicle Location', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Latitude: ${location.latitude?.toStringAsFixed(6) ?? 'N/A'}'),
                      Text('Longitude: ${location.longitude?.toStringAsFixed(6) ?? 'N/A'}'),
                    ],
                  ),
                ),
                if (location.latitude != null && location.longitude != null)
                  TextButton.icon(
                    icon: const Icon(Icons.map),
                    label: const Text('Open Location in Google Maps'),
                    onPressed: () => _openInMaps(location.latitude!, location.longitude!),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConsumptionSection(ConsumptionData consumption) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Consumption', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _buildStatusRow(
              icon: Icons.directions_car,
              label: 'Current Drive',
              value: '${consumption.currentDrive?.toStringAsFixed(1) ?? 'N/A'} kWh',
            ),
            _buildStatusRow(
              icon: Icons.battery_charging_full,
              label: 'Since Last Charge',
              value: '${consumption.sinceLastCharge?.toStringAsFixed(1) ?? 'N/A'} kWh',
            ),
            _buildStatusRow(
              icon: Icons.restart_alt,
              label: 'Since Last Reset',
              value: '${consumption.sinceLastReset?.toStringAsFixed(1) ?? 'N/A'} kWh',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEvStatusSection(EvStatus evStatus) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('EV Status', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _buildStatusRow(
              icon: Icons.power,
              label: 'Plugged In',
              value: evStatus.pluggedIn == true ? 'Yes' : 'No',
            ),
            _buildStatusRow(
              icon: Icons.battery_charging_full,
              label: 'Charging',
              value: evStatus.charging == true ? 'Yes' : 'No',
            ),
            if (evStatus.remainingChargingTime != null)
              _buildStatusRow(
                icon: Icons.timer,
                label: 'Remaining Time',
                value: evStatus.remainingChargingTime!,
              ),
            _buildStatusRow(
              icon: Icons.route,
              label: 'Estimated Range',
              value: '${evStatus.estimatedRange?.toStringAsFixed(1) ?? 'N/A'} km',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVehicleCard(BuildContext context, Vehicle vehicle, VehicleProvider provider) {
    final status = vehicle.status;

    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  vehicle.name,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  vehicle.model,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          ),
          if (status != null) ...[
            if (status.location != null) _buildLocationSection(status.location!),
            if (status.consumption != null) _buildConsumptionSection(status.consumption!),
            if (status.evStatus != null) _buildEvStatusSection(status.evStatus!),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatusRow(
                    icon: Icons.lock,
                    label: 'Door Lock',
                    value: status.doorLock == true ? 'Locked' : 'Unlocked',
                  ),
                  _buildStatusRow(
                    icon: Icons.power,
                    label: 'Engine',
                    value: status.engineRunning == true ? 'Running' : 'Off',
                  ),
                  _buildStatusRow(
                    icon: Icons.battery_charging_full,
                    label: 'Battery',
                    value: provider.getFormattedBatteryLevel(vehicle),
                  ),
                  if (status.evBattery?.chargingTime != null)
                    _buildStatusRow(
                      icon: Icons.timer,
                      label: 'Charging Time',
                      value: provider.getFormattedChargingTime(vehicle),
                    ),
                  _buildStatusRow(
                    icon: Icons.thermostat,
                    label: 'Temperature',
                    value: provider.getFormattedTemperature(vehicle),
                  ),
                  _buildStatusRow(
                    icon: Icons.speed,
                    label: 'Odometer',
                    value: provider.getFormattedOdometer(vehicle),
                  ),
                  _buildStatusRow(
                    icon: Icons.route,
                    label: 'Range',
                    value: provider.getFormattedRange(vehicle),
                  ),
                  if (status.defrost != null)
                    _buildStatusRow(
                      icon: Icons.ac_unit,
                      label: 'Defrost',
                      value: status.defrost! ? 'On' : 'Off',
                    ),
                  if (status.steeringWheelHeat != null)
                    _buildStatusRow(
                      icon: Icons.drive_eta,
                      label: 'Steering Wheel Heat',
                      value: status.steeringWheelHeat! ? 'On' : 'Off',
                    ),
                  if (status.sideBackWindowHeat != null)
                    _buildStatusRow(
                      icon: Icons.wb_sunny,
                      label: 'Back Window Heat',
                      value: status.sideBackWindowHeat! ? 'On' : 'Off',
                    ),
                ],
              ),
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Last Updated: ${provider.getFormattedLastUpdated(vehicle)}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Text(value),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Vehicles'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshData,
          ),
        ],
      ),
      body: Consumer<VehicleProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    provider.error!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _refreshData,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (provider.vehicles.isEmpty) {
            return const Center(
              child: Text('No vehicles found'),
            );
          }

          return RefreshIndicator(
            onRefresh: _refreshData,
            child: ListView.builder(
              itemCount: provider.vehicles.length,
              itemBuilder: (context, index) {
                final vehicle = provider.vehicles[index];
                return _buildVehicleCard(context, vehicle, provider);
              },
            ),
          );
        },
      ),
    );
  }
}