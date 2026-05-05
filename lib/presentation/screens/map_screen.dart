import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qr_flutter/qr_flutter.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  // Tracks what the screen is currently showing
  _LocationState _locationState = _LocationState.requesting;
  Position? _position;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    // Request permission as soon as screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _requestLocationPermission();
    });
  }

  Future<void> _requestLocationPermission() async {
    setState(() => _locationState = _LocationState.requesting);

    // Check current permission status first
    PermissionStatus status = await Permission.location.status;

    // If not granted yet, ask the user
    if (status.isDenied) {
      status = await Permission.location.request();
    }

    if (status.isGranted) {
      // Permission granted — now get the actual GPS position
      await _getCurrentPosition();
    } else if (status.isPermanentlyDenied) {
      // User said "never ask again" — must go to settings
      setState(() {
        _locationState = _LocationState.permanentlyDenied;
        _errorMessage =
            'Location permission was permanently denied. Please enable it in app settings.';
      });
    } else {
      // User denied but didn't say never ask again
      setState(() {
        _locationState = _LocationState.denied;
        _errorMessage =
            'Location permission is required to show your campus position.';
      });
    }
  }

  Future<void> _getCurrentPosition() async {
    setState(() => _locationState = _LocationState.loading);
    try {
      final Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _position = position;
        _locationState = _LocationState.success;
      });
    } catch (e) {
      setState(() {
        _locationState = _LocationState.denied;
        _errorMessage = 'Failed to get location: ${e.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: const Color(0xFF27C7D4),
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        title: const Text(
          'Campus Location',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          if (_locationState == _LocationState.success)
            IconButton(
              icon: const Icon(Icons.refresh_rounded),
              onPressed: _getCurrentPosition,
            ),
        ],
      ),
      body: _buildBody(isDark),
    );
  }

  Widget _buildBody(bool isDark) {
    switch (_locationState) {
      case _LocationState.requesting:
      case _LocationState.loading:
        return _buildLoading();
      case _LocationState.success:
        return _buildSuccess(isDark);
      case _LocationState.denied:
        return _buildDenied(isDark, permanently: false);
      case _LocationState.permanentlyDenied:
        return _buildDenied(isDark, permanently: true);
    }
  }

  // ── Loading / Requesting ──────────────────────────
  Widget _buildLoading() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: Color(0xFF27C7D4)),
          const SizedBox(height: 24),
          Text(
            _locationState == _LocationState.requesting
                ? 'Requesting location permission...'
                : 'Getting your position...',
            style: TextStyle(color: Colors.grey[500], fontSize: 14),
          ),
        ],
      ),
    );
  }

  // ── Success — show coordinates ────────────────────
  Widget _buildSuccess(bool isDark) {
    final cardColor =
        isDark ? const Color(0xFF1A1A2E) : const Color(0xFFFDF0E7);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Map placeholder with pin icon
          Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF27C7D4), Color(0xFF1AAAB6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.location_on_rounded,
                  color: Colors.white,
                  size: 56,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Position sur le campus',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'UniSy Campus — Live GPS',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.85),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Coordinates card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: const Color(0xFF27C7D4).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.gps_fixed_rounded,
                        color: Color(0xFF27C7D4),
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'GPS Coordinates',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _CoordinateRow(
                  label: 'Latitude',
                  value: _position!.latitude.toStringAsFixed(6),
                  icon: Icons.swap_vert_rounded,
                  isDark: isDark,
                ),
                const SizedBox(height: 12),
                _CoordinateRow(
                  label: 'Longitude',
                  value: _position!.longitude.toStringAsFixed(6),
                  icon: Icons.swap_horiz_rounded,
                  isDark: isDark,
                ),
                const SizedBox(height: 12),
                _CoordinateRow(
                  label: 'Accuracy',
                  value: '± ${_position!.accuracy.toStringAsFixed(1)} m',
                  icon: Icons.radar_rounded,
                  isDark: isDark,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // OS concept note
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFE9063).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFFE9063).withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline_rounded,
                  color: Color(0xFFFE9063),
                  size: 18,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Runtime permission granted — Location access is sandboxed to this app only.',
                    style: TextStyle(
                      color: isDark
                          ? Colors.white70
                          : const Color(0xFF555555),
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),

        const SizedBox(height: 16),

          // QR Code card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFE9063).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.qr_code_rounded,
                        color: Color(0xFFFE9063),
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Share My Location',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? Colors.white
                            : const Color(0xFF1A1A2E),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                QrImageView(
                  data:
                      'geo:${_position!.latitude},${_position!.longitude}',
                  version: QrVersions.auto,
                  size: 180,
                  backgroundColor: Colors.white,
                  padding: const EdgeInsets.all(8),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Scan with any camera app to open in Maps',
                  style: TextStyle(
                    color: Color(0xFF555555),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

        ],
      ),
    );
  }

  // ── Denied ────────────────────────────────────────
  Widget _buildDenied(bool isDark, {required bool permanently}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFFEA5863).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.location_off_rounded,
                size: 40,
                color: Color(0xFFEA5863),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Location Access Required',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF555555),
                fontSize: 13,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF27C7D4),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              onPressed: permanently
                  ? () => openAppSettings()
                  : _requestLocationPermission,
              icon: Icon(
                permanently ? Icons.settings_rounded : Icons.refresh_rounded,
                size: 18,
              ),
              label: Text(
                permanently ? 'Open Settings' : 'Try Again',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Coordinate Row Widget
// ─────────────────────────────────────────────────────────────
class _CoordinateRow extends StatelessWidget {
  const _CoordinateRow({
    required this.label,
    required this.value,
    required this.icon,
    required this.isDark,
  });

  final String label;
  final String value;
  final IconData icon;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF27C7D4)),
        const SizedBox(width: 10),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF555555),
            fontSize: 13,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : const Color(0xFF1A1A2E),
          ),
        ),
      ],
    );
  }
}

// Internal state enum — private to this file
enum _LocationState {
  requesting,
  loading,
  success,
  denied,
  permanentlyDenied,
}
