import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart'
    as permission_handler;
import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  /// Check and request all Bluetooth permissions required for printer functionality
  Future<Map<Permission, PermissionStatus>>
      requestBluetoothPermissions() async {
    // Define all required permissions
    final permissions = <Permission>[
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.bluetoothAdvertise,
      Permission.location,
    ];

    debugPrint("Requesting Bluetooth permissions: $permissions");

    // Request all permissions
    final statuses = await permissions.request();

    // Log results for debugging
    for (var entry in statuses.entries) {
      debugPrint("Permission ${entry.key}: ${entry.value}");
    }

    return statuses;
  }

  /// Check if all Bluetooth permissions are granted
  Future<bool> hasBluetoothPermissions() async {
    final permissions = <Permission>[
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.bluetoothAdvertise,
      Permission.location,
    ];

    final statuses = <Permission, PermissionStatus>{};
    for (var permission in permissions) {
      statuses[permission] = await permission.status;
    }

    // Log current status
    for (var entry in statuses.entries) {
      debugPrint("Current permission status ${entry.key}: ${entry.value}");
    }

    return statuses.values.every((status) => status.isGranted);
  }

  /// Open app settings if permissions are permanently denied
  Future<bool> openAppSettings() async {
    return await permission_handler.openAppSettings();
  }
}
