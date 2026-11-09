import 'core/config/env_config.dart';
import 'main_common.dart';

/// Default entry point: dynamically uses EnvConfig.environment or --dart-define=APP_ENV
Future<void> main() async {
  await bootstrapApp(EnvConfig.environment);
}
