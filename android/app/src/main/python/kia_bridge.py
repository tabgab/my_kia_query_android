import json
from datetime import datetime
from hyundai_kia_connect_api import VehicleManager

class KiaBridge:
    def __init__(self):
        self.vm = None
        self.authenticated = False

    def authenticate(self, username, password, pin, region, brand):
        try:
            # Convert region string to int
            region_map = {
                'EUR': 1,  # Europe
                'CA': 2,   # Canada
                'USA': 3,  # USA
            }
            region_num = region_map.get(region, 1)  # Default to Europe if unknown

            # Convert brand string to int
            brand_map = {
                'kia': 1,
                'hyundai': 2,
                'genesis': 3
            }
            brand_num = brand_map.get(brand.lower(), 1)  # Default to Kia if unknown

            self.vm = VehicleManager(
                region=region_num,
                brand=brand_num,
                username=username,
                password=password,
                pin=pin
            )
            self.vm.check_and_refresh_token()
            self.vm.update_all_vehicles_with_cached_state()
            self.authenticated = True
            return True
        except Exception as e:
            print(f"Authentication error: {str(e)}")
            self.authenticated = False
            return False

    def get_vehicles(self):
        if not self.authenticated or not self.vm:
            return "[]"
        
        try:
            vehicle_list = []
            for vehicle_id in self.vm.vehicles:
                vehicle = self.vm.get_vehicle(vehicle_id)
                print(f"Python: Raw vehicle data for {vehicle.name}:")
                print(f"Raw data: {vehicle.data}")
                
                # Get odometer value from correct path in data structure
                odometer_value = None
                consumption_data = None
                try:
                    drivetrain = vehicle.data.get('Drivetrain', {})
                    odometer_value = drivetrain.get('Odometer')
                    print(f"Extracted odometer value: {odometer_value}")
                    
                    # Extract consumption data
                    fuel_system = drivetrain.get('FuelSystem', {})
                    average_fuel_economy = fuel_system.get('AverageFuelEconomy', {})
                    if average_fuel_economy:
                        consumption_data = {
                            'currentDrive': average_fuel_economy.get('Drive'),
                            'sinceLastCharge': average_fuel_economy.get('AfterRefuel'),
                            'sinceLastReset': average_fuel_economy.get('Accumulated')
                        }
                    print(f"Extracted consumption data: {consumption_data}")
                except Exception as e:
                    print(f"Error extracting drivetrain data: {str(e)}")
                
                # Format last_updated_at as ISO string if it's a datetime object
                last_updated = vehicle.last_updated_at
                if isinstance(last_updated, datetime):
                    last_updated = last_updated.isoformat()
                
                # Handle location tuple
                location_lat = 0
                location_lon = 0
                if vehicle.location and isinstance(vehicle.location, tuple) and len(vehicle.location) == 2:
                    location_lat = vehicle.location[0]  # First element is latitude
                    location_lon = vehicle.location[1]  # Second element is longitude
                
                # Get vehicle data
                vehicle_data = {
                    'id': vehicle.id,
                    'name': vehicle.name,
                    'model': vehicle.model,
                    'registration_date': vehicle.registration_date,
                    'vehicle_identification_number': vehicle.VIN,
                    'status': {
                        'engine': vehicle.engine_status == 'ON' if hasattr(vehicle, 'engine_status') else False,
                        'climate': vehicle.air_control_status == 'ON' if hasattr(vehicle, 'air_control_status') else False,
                        'doors': {
                            'front_left': vehicle.data.get('doorStatus', {}).get('frontLeft') == 'OPEN',
                            'front_right': vehicle.data.get('doorStatus', {}).get('frontRight') == 'OPEN',
                            'rear_left': vehicle.data.get('doorStatus', {}).get('rearLeft') == 'OPEN',
                            'rear_right': vehicle.data.get('doorStatus', {}).get('rearRight') == 'OPEN'
                        },
                        'trunk': vehicle.data.get('doorStatus', {}).get('trunk') == 'OPEN',
                        'hood': vehicle.data.get('doorStatus', {}).get('hood') == 'OPEN',
                        'battery': {
                            'level': vehicle.data.get('Electronics', {}).get('Battery', {}).get('Level'),
                            'charging': False,
                            'stateOfCharge': 0,
                            'chargingTime': 'N/A'
                        },
                        'evBattery': {
                            'level': vehicle.ev_battery_percentage,
                            'charging': vehicle.ev_charging_status == 'ON' if hasattr(vehicle, 'ev_charging_status') else False,
                            'stateOfCharge': vehicle.ev_battery_percentage,
                            'chargingTime': vehicle.data.get('evStatus', {}).get('remainTime', 'N/A')
                        },
                        'odometer': odometer_value,  # Use extracted odometer value
                        'range': vehicle.ev_driving_range,
                        'rangeKm': vehicle.ev_driving_range,
                        'last_updated': last_updated,
                        'engineRunning': vehicle.engine_status == 'ON' if hasattr(vehicle, 'engine_status') else False,
                        'doorLocked': vehicle.data.get('doorLock') == 'LOCKED',
                        'airTemperature': {
                            'value': vehicle.air_temperature if hasattr(vehicle, 'air_temperature') else None,
                            'unit': 'C'
                        },
                        'location': {
                            'latitude': location_lat,
                            'longitude': location_lon
                        },
                        'defrost': vehicle.defrost_status == 'ON' if hasattr(vehicle, 'defrost_status') else False,
                        'steeringWheelHeat': vehicle.steering_wheel_heat == 'ON' if hasattr(vehicle, 'steering_wheel_heat') else False,
                        'sideBackWindowHeat': vehicle.back_window_heat == 'ON' if hasattr(vehicle, 'back_window_heat') else False,
                        'evStatus': {
                            'pluggedIn': vehicle.ev_plugged_status == 'PLUGGED' if hasattr(vehicle, 'ev_plugged_status') else False,
                            'charging': vehicle.ev_charging_status == 'ON' if hasattr(vehicle, 'ev_charging_status') else False,
                            'batteryCharge12V': vehicle.data.get('evStatus', {}).get('batteryCharge12V'),
                            'batteryChargeHV': vehicle.data.get('evStatus', {}).get('batteryChargeHV'),
                            'remainingChargingTime': vehicle.data.get('evStatus', {}).get('remainTime'),
                            'estimatedRange': vehicle.ev_driving_range
                        },
                        'consumption': consumption_data  # Add consumption data
                    }
                }
                vehicle_list.append(vehicle_data)
            
            json_data = json.dumps(vehicle_list)
            print("Python: JSON output:")
            print(json.dumps(json.loads(json_data), indent=2))
            return json_data
            
        except Exception as e:
            print(f"Error getting vehicles: {str(e)}")
            print("Python: Attempting to serialize with error handling")
            try:
                # Try to serialize with basic error handling
                vehicle_list = []
                for vehicle_id in self.vm.vehicles:
                    vehicle = self.vm.get_vehicle(vehicle_id)
                    
                    # Handle location tuple in fallback
                    location_lat = 0
                    location_lon = 0
                    if vehicle.location and isinstance(vehicle.location, tuple) and len(vehicle.location) == 2:
                        location_lat = vehicle.location[0]
                        location_lon = vehicle.location[1]
                    
                    # Get odometer value and consumption data in fallback
                    odometer_value = None
                    consumption_data = None
                    try:
                        drivetrain = vehicle.data.get('Drivetrain', {})
                        odometer_value = drivetrain.get('Odometer')
                        fuel_system = drivetrain.get('FuelSystem', {})
                        average_fuel_economy = fuel_system.get('AverageFuelEconomy', {})
                        if average_fuel_economy:
                            consumption_data = {
                                'currentDrive': average_fuel_economy.get('Drive'),
                                'sinceLastCharge': average_fuel_economy.get('AfterRefuel'),
                                'sinceLastReset': average_fuel_economy.get('Accumulated')
                            }
                    except:
                        pass
                    
                    vehicle_data = {
                        'id': str(vehicle.id),
                        'name': str(vehicle.name),
                        'model': str(vehicle.model),
                        'registration_date': str(vehicle.registration_date) if vehicle.registration_date else None,
                        'vehicle_identification_number': str(vehicle.VIN),
                        'status': {
                            'odometer': float(odometer_value) if odometer_value is not None else 0,
                            'battery': {
                                'level': float(vehicle.data.get('Electronics', {}).get('Battery', {}).get('Level', 0)),
                            },
                            'evBattery': {
                                'level': float(vehicle.ev_battery_percentage) if vehicle.ev_battery_percentage else 0,
                            },
                            'range': float(vehicle.ev_driving_range) if vehicle.ev_driving_range else 0,
                            'rangeKm': float(vehicle.ev_driving_range) if vehicle.ev_driving_range else 0,
                            'location': {
                                'latitude': float(location_lat),
                                'longitude': float(location_lon)
                            },
                            'doorLocked': vehicle.data.get('doorLock') == 'LOCKED',
                            'airTemperature': {
                                'value': vehicle.air_temperature if hasattr(vehicle, 'air_temperature') else None,
                                'unit': 'C'
                            },
                            'last_updated': datetime.now().isoformat(),
                            'consumption': consumption_data  # Add consumption data in fallback
                        }
                    }
                    vehicle_list.append(vehicle_data)
                return json.dumps(vehicle_list)
            except Exception as e2:
                print(f"Error in fallback serialization: {str(e2)}")
                return "[]"

    def refresh_vehicle_data(self):
        if not self.authenticated or not self.vm:
            return False
            
        try:
            self.vm.check_and_refresh_token()
            self.vm.update_all_vehicles_with_cached_state()
            return True
        except Exception as e:
            print(f"Error refreshing vehicle data: {str(e)}")
            return False

# Create a singleton instance
kia_bridge = KiaBridge()

# Export functions for Java/Kotlin
def authenticate(username, password, pin, region, brand):
    return kia_bridge.authenticate(username, password, pin, region, brand)

def get_vehicles():
    return kia_bridge.get_vehicles()

def refresh_vehicle_data():
    return kia_bridge.refresh_vehicle_data()
