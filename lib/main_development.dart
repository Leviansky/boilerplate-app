import 'core/config/env_config.dart';
import 'main_common.dart';

/// Entry point for Development environment flavor
Future<void> main() async {
  await bootstrapApp(Environment.development);
}
