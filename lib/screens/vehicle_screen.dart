import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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

  Widget _buildLocationSection(Location location) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Vehicle Location', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Latitude: ${location.latitude?.toStringAsFixed(6) ?? 'N/A'}'),
            Text('Longitude: ${location.longitude?.toStringAsFixed(6) ?? 'N/A'}'),
          ],
        ),
      ),
    );
  }

  Widget _buildTirePressureSection(TirePressure tirePressure) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Tire Pressure', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    const Text('Front Left'),
                    Text('${tirePressure.frontLeft?.toStringAsFixed(1) ?? 'N/A'} bar'),
                  ],
                ),
                Column(
                  children: [
                    const Text('Front Right'),
                    Text('${tirePressure.frontRight?.toStringAsFixed(1) ?? 'N/A'} bar'),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    const Text('Rear Left'),
                    Text('${tirePressure.rearLeft?.toStringAsFixed(1) ?? 'N/A'} bar'),
                  ],
                ),
                Column(
                  children: [
                    const Text('Rear Right'),
                    Text('${tirePressure.rearRight?.toStringAsFixed(1) ?? 'N/A'} bar'),
                  ],
                ),
              ],
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
                  // Additional status rows
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
            if (status.tirePressure != null)
              _buildTirePressureSection(status.tirePressure!),
            if (status.evStatus != null)
              _buildEvStatusSection(status.evStatus!),
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
