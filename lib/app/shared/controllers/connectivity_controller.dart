import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';

class ConnectivityController extends GetxController {
  static ConnectivityController get to => Get.find<ConnectivityController>();

  final _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  final isOnline = true.obs;

  @override
  void onInit() {
    super.onInit();
    _checkInitialConnectivity();
    _subscription = _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  Future<void> _checkInitialConnectivity() async {
    try {
      final results = await _connectivity.checkConnectivity();
      _updateConnectionStatus(results);
    } catch (_) {
      isOnline.value = true;
    }
  }

  void _updateConnectionStatus(List<ConnectivityResult> results) {
    final hasActiveConnection = results.any(
      (r) => r != ConnectivityResult.none,
    );
    isOnline.value = hasActiveConnection;
  }

  @override
  void onClose() {
    _subscription?.cancel();
    super.onClose();
  }
}
