import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  final Connectivity _connectivity = Connectivity();

  Future<bool> isConnected() async {

    final List<ConnectivityResult> results =
        await _connectivity.checkConnectivity();

    return results.any(
      (result) => result != ConnectivityResult.none,
    );
  }

  Stream<List<ConnectivityResult>> get connectivityStream =>
      _connectivity.onConnectivityChanged;
}