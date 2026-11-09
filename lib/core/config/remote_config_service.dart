import 'package:get/get.dart';
import 'env_config.dart';

class RemoteConfigService extends GetxService {
  static RemoteConfigService get to => Get.find<RemoteConfigService>();

  final _minAppVersion = '1.0.0'.obs;
  final _isEmergencyKillSwitchActive = false.obs;
  final _enabledPaymentMethods = <String>['VIRTUAL_ACCOUNT', 'E_WALLET', 'CREDIT_CARD'].obs;
  final _isPromoModuleEnabled = true.obs;

  bool get isEmergencyKillSwitchActive => _isEmergencyKillSwitchActive.value;
  bool get isPromoModuleEnabled => _isPromoModuleEnabled.value;
  List<String> get enabledPaymentMethods => List.unmodifiable(_enabledPaymentMethods);

  Future<RemoteConfigService> init() async {
    // In production, fetch remote configuration from Firebase Remote Config or proprietary API
    await _fetchRemoteConfigs();
    return this;
  }

  Future<void> _fetchRemoteConfigs() async {
    // Default config values / sync
    _minAppVersion.value = '1.0.0';
    _isEmergencyKillSwitchActive.value = false;
  }

  bool isPaymentMethodEnabled(String channelCode) {
    if (_isEmergencyKillSwitchActive.value) return false;
    return _enabledPaymentMethods.contains(channelCode.toUpperCase());
  }

  bool isVersionSupported() {
    final current = EnvConfig.appVersion.split('.').map(int.tryParse).toList();
    final min = _minAppVersion.value.split('.').map(int.tryParse).toList();

    for (var i = 0; i < 3; i++) {
      final currPart = (i < current.length) ? (current[i] ?? 0) : 0;
      final minPart = (i < min.length) ? (min[i] ?? 0) : 0;
      if (currPart < minPart) return false;
      if (currPart > minPart) return true;
    }
    return true;
  }
}
