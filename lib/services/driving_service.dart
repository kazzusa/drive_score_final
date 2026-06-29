import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sensors_plus/sensors_plus.dart';
import '../models/drive_session.dart';

// Thresholds
const double kSpeedLimitKmh = 110.0;
const double kDecelerationThreshold = -1.0; // m/s² sudden deceleration
const double kAccelerationThreshold = 1.0; // m/s² sudden acceleration
const double kBumpyThreshold = 1.50;
const double kSharpTurnThreshold = 1.00;     // rad/s gyroscope Z-axis

// Cooldowns to avoid spamming the same event
const Duration kEventCooldown = Duration(seconds: 10);

class DrivingService extends ChangeNotifier {
  int _score = 100;
  double _distanceKm = 0.0;
  double _currentSpeedKmh = 0.0;
  final List<DriveEvent> _events = [];
  bool _isRunning = false;
  DateTime? _startTime;
  Position? _lastPosition;
  double? _lastSpeedMps;
  DateTime? _lastSpeedTime;

  // Cooldown trackers
  DateTime? _lastSpeedingEvent;
  DateTime? _lastAccelerateEvent;
  DateTime? _lastTurnEvent;

  // Subscriptions
  StreamSubscription<Position>? _positionSub;
  StreamSubscription<AccelerometerEvent>? _accelSub;
  StreamSubscription<GyroscopeEvent>? _gyroSub;

  // Accelerometer smoothing
  final List<double> _accelBuffer = [];
  double _prevSmoothedX = 0;
  bool _accelInitialized = false;

  // Getters
  int get score => _score;
  double get distanceKm => _distanceKm;
  double get currentSpeedKmh => _currentSpeedKmh;
  List<DriveEvent> get events => List.unmodifiable(_events);
  bool get isRunning => _isRunning;
  DateTime? get startTime => _startTime;

  Future<bool> requestPermissions() async {
    LocationPermission locPerm = await Geolocator.checkPermission();
    if (locPerm == LocationPermission.denied) {
      locPerm = await Geolocator.requestPermission();
    }
    if (locPerm == LocationPermission.deniedForever ||
        locPerm == LocationPermission.denied) {
      return false;
    }
    return true;
  }

  Future<void> startDrive() async {
    _score = 100;
    _distanceKm = 0.0;
    _currentSpeedKmh = 0.0;
    _events.clear();
    _lastPosition = null;
    _lastSpeedMps = null;
    _lastSpeedTime = null;
    _lastSpeedingEvent = null;
    _lastAccelerateEvent = null;
    _lastTurnEvent = null;
    _accelBuffer.clear();
    _accelInitialized = false;
    _prevSmoothedX = 0;
    _isRunning = true;
    _startTime = DateTime.now();
    notifyListeners();

    _startLocationTracking();
    _startAccelerometerTracking();
    _startGyroscopeTracking();
  }

  void _startLocationTracking() {
    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.bestForNavigation,
      distanceFilter: 0, // meters (transmit signal everytime)
    );

    _positionSub = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen((Position position) {
      if (!_isRunning) return;

      _currentSpeedKmh = (position.speed * 3.6).clamp(0, 300);

      final speedMps = position.speed;
      final now = DateTime.now();

      if (_lastSpeedMps != null && _lastSpeedTime != null) {
        final dt = now.difference(_lastSpeedTime!).inMilliseconds / 1000.0;

        if (dt > 0) {
          final acceleration = (speedMps - _lastSpeedMps!) / dt;

          // Check acceleration / deceleration
          if (acceleration <= kDecelerationThreshold) {
            if (_lastAccelerateEvent == null ||
                now.difference(_lastAccelerateEvent!) >
                    kEventCooldown) {
              _lastAccelerateEvent = now;
              _recordEvent('Hard braking (${acceleration.toStringAsFixed(2)} m/s²)', 3);
            }
          }
          else if (acceleration >= kAccelerationThreshold) {
            if (_lastAccelerateEvent == null ||
                now.difference(_lastAccelerateEvent!) >
                    kEventCooldown) {
              _lastAccelerateEvent = now;
              _recordEvent('Harsh acceleration (${acceleration.toStringAsFixed(2)} m/s²)', 3);
            }
          }
        }
      }

      _lastSpeedMps = speedMps;
      _lastSpeedTime = now;

      if (_lastPosition != null) {
        final distMeters = Geolocator.distanceBetween(
          _lastPosition!.latitude,
          _lastPosition!.longitude,
          position.latitude,
          position.longitude,
        );
        _distanceKm += distMeters / 1000.0;
      }
      _lastPosition = position;

      // Check speeding
      if (_currentSpeedKmh > kSpeedLimitKmh) {
        if (_lastSpeedingEvent == null ||
            now.difference(_lastSpeedingEvent!) > kEventCooldown) {
          _lastSpeedingEvent = now;
          _recordEvent('Speeding', 5);
        }
      }

      notifyListeners();
    }, onError: (e) {
      debugPrint('Location error: $e');
    });
  }

  void _startAccelerometerTracking() {
    _accelSub = accelerometerEventStream(
      samplingPeriod: const Duration(milliseconds: 100),
    ).listen((AccelerometerEvent event) {
      if (!_isRunning) return;

      // Use X axis (forward/backward when phone is held normally)
      // Apply simple low-pass filter to remove noise
      _accelBuffer.add(event.x);
      if (_accelBuffer.length > 5) _accelBuffer.removeAt(0);
      final smoothed = _accelBuffer.reduce((a, b) => a + b) / _accelBuffer.length;

      if (!_accelInitialized) {
        _prevSmoothedX = smoothed;
        _accelInitialized = true;
        return;
      }

      // Check bumpy ride
      final delta = smoothed - _prevSmoothedX;
      _prevSmoothedX = smoothed;

      final now = DateTime.now();
      if (delta <= -kBumpyThreshold || delta >= kBumpyThreshold) {
        if (_lastAccelerateEvent == null ||
            now.difference(_lastAccelerateEvent!) > kEventCooldown) {
          _lastAccelerateEvent = now;
          _recordEvent('Bumpy ride (${delta.toStringAsFixed(2)} g)', 3);
        }
      }
    }, onError: (e) {
      debugPrint('Accelerometer error: $e');
    });
  }

  void _startGyroscopeTracking() {
    _gyroSub = gyroscopeEventStream(
      samplingPeriod: const Duration(milliseconds: 100),
    ).listen((GyroscopeEvent event) {
      if (!_isRunning) return;

      // Z-axis = rotation around vertical axis (Sharp turn)
      final zRate = event.z.abs();
      final now = DateTime.now();

      if (zRate > kSharpTurnThreshold) {
        if (_lastTurnEvent == null ||
            now.difference(_lastTurnEvent!) > kEventCooldown) {
          _lastTurnEvent = now;
          _recordEvent('Sharp turn', 1);
        }
      }
    }, onError: (e) {
      debugPrint('Gyroscope error: $e');
    });
  }

  void _recordEvent(String type, int deduction) {
    _score = max(0, _score - deduction);
    _events.add(DriveEvent(
      type: type,
      pointsDeducted: deduction,
      timestamp: DateTime.now(),
    ));
    notifyListeners();
  }

  DriveSession stopDrive() {
    _isRunning = false;
    _positionSub?.cancel();
    _accelSub?.cancel();
    _gyroSub?.cancel();
    _positionSub = null;
    _accelSub = null;
    _gyroSub = null;

    final session = DriveSession(
      startTime: _startTime ?? DateTime.now(),
      endTime: DateTime.now(),
      finalScore: _score,
      distanceKm: double.parse(_distanceKm.toStringAsFixed(1)),
      events: List.from(_events),
    );

    notifyListeners();
    return session;
  }

  @override
  void dispose() {
    _positionSub?.cancel();
    _accelSub?.cancel();
    _gyroSub?.cancel();
    super.dispose();
  }
}
