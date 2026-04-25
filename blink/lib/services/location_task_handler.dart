import 'dart:convert';

import 'package:battery_plus/battery_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

import '../core/constants/api_constants.dart';
import '../data/datasources/local/token_storage.dart';

@pragma('vm:entry-point')
void startLocationCallback() {
  FlutterForegroundTask.setTaskHandler(LocationTaskHandler());
}

class LocationTaskHandler extends TaskHandler {
  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {}

  @override
  void onRepeatEvent(DateTime timestamp) {
    _sendLocation();
  }

  @override
  Future<void> onDestroy(DateTime timestamp) async {}

  Future<void> _sendLocation() async {
    try {
      final ghostMode = await TokenStorage.readGhostModeFromPrefs();
      if (ghostMode) {
        FlutterForegroundTask.sendDataToMain({
          'event': 'location_skipped_ghost',
        });
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final token = await TokenStorage.readAccessTokenFromPrefs();
      if (token == null || token.isEmpty) {
        return;
      }

      int? batteryPercent;
      try {
        batteryPercent = await Battery().batteryLevel;
      } catch (_) {
        batteryPercent = null;
      }

      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.locationUpdate}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'lat': position.latitude,
          'lng': position.longitude,
          'accuracy': position.accuracy,
          if (batteryPercent != null) 'batteryPercent': batteryPercent,
        }),
      );

      FlutterForegroundTask.sendDataToMain({
        'event': 'location_sent',
        'lat': position.latitude,
        'lng': position.longitude,
        'status': response.statusCode,
      });
    } catch (e) {
      debugPrint('LocationTaskHandler error: $e');
      FlutterForegroundTask.sendDataToMain({
        'event': 'location_error',
        'error': e.toString(),
      });
    }
  }
}
