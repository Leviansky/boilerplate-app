import 'dart:convert';
import 'dart:io';

/// CLI Tool to parse and execute builds defined in build.json
void main(List<String> args) async {
  final configFile = File('build.json');
  if (!configFile.existsSync()) {
    stderr.writeln('Error: build.json not found in the root directory.');
    exit(1);
  }

  final Map<String, dynamic> config = jsonDecode(configFile.readAsStringSync()) as Map<String, dynamic>;
  final environments = config['environments'] as Map<String, dynamic>;

  if (args.isEmpty || args.contains('--help') || args.contains('-h')) {
    _printUsage();
    return;
  }

  if (args.contains('--list') || args.contains('-l')) {
    _listAvailableBuilds(environments);
    return;
  }

  final envArg = _extractArg(args, '--env');
  final platformArg = _extractArg(args, '--platform');
  final targetArg = _extractArg(args, '--target');
  final isDryRun = args.contains('--dry-run');

  if (envArg == null || platformArg == null) {
    stderr.writeln('Error: Both --env and --platform are required.');
    _printUsage();
    exit(1);
  }

  final envData = environments[envArg] as Map<String, dynamic>?;
  if (envData == null) {
    stderr.writeln("Error: Environment '$envArg' not found in build.json.");
    stderr.writeln("Available environments: ${environments.keys.join(', ')}");
    exit(1);
  }

  final platformData = envData[platformArg] as Map<String, dynamic>?;
  if (platformData == null) {
    stderr.writeln("Error: Platform '$platformArg' not found for environment '$envArg'.");
    exit(1);
  }

  final targets = platformData['targets'] as Map<String, dynamic>;
  String? targetKey = targetArg;

  if (targetKey == null) {
    targetKey = targets.keys.first;
    stdout.writeln("Defaulting to target: '$targetKey'");
  }

  final targetData = targets[targetKey] as Map<String, dynamic>?;
  if (targetData == null) {
    stderr.writeln("Error: Target '$targetKey' not found. Available targets: ${targets.keys.join(', ')}");
    exit(1);
  }

  final command = targetData['command'] as String;
  stdout.writeln('\n========================================');
  stdout.writeln('🚀 Build Specification');
  stdout.writeln('========================================');
  stdout.writeln('Environment : $envArg');
  stdout.writeln('Platform    : $platformArg');
  stdout.writeln('Target      : $targetKey');
  stdout.writeln('Command     : $command');
  stdout.writeln('========================================\n');

  if (isDryRun) {
    stdout.writeln('[Dry Run] Command would be executed in production/CI.');
    return;
  }

  stdout.writeln('Executing build command...');
  final parts = command.split(' ');
  final executable = parts.first;
  final cmdArgs = parts.sublist(1);

  final process = await Process.start(executable, cmdArgs, mode: ProcessStartMode.inheritStdio);
  final exitCode = await process.exitCode;

  if (exitCode != 0) {
    stderr.writeln('\n❌ Build failed with exit code $exitCode');
    exit(exitCode);
  } else {
    stdout.writeln('\n✅ Build completed successfully!');
  }
}

String? _extractArg(List<String> args, String flag) {
  for (final arg in args) {
    if (arg.startsWith('$flag=')) {
      return arg.substring(flag.length + 1);
    }
  }
  final index = args.indexOf(flag);
  if (index != -1 && index + 1 < args.length) {
    return args[index + 1];
  }
  return null;
}

void _listAvailableBuilds(Map<String, dynamic> environments) {
  stdout.writeln('\n📋 Available Builds from build.json:');
  for (final envEntry in environments.entries) {
    final envName = envEntry.key;
    final envData = envEntry.value as Map<String, dynamic>;
    stdout.writeln('\n[$envName] - Flavor: ${envData['flavor']} | Entry: ${envData['entrypoint']}');

    for (final platform in ['android', 'ios']) {
      final pData = envData[platform] as Map<String, dynamic>?;
      if (pData != null) {
        final targets = pData['targets'] as Map<String, dynamic>;
        for (final tEntry in targets.entries) {
          final tData = tEntry.value as Map<String, dynamic>;
          stdout.writeln('  • --platform=$platform --target=${tEntry.key}');
          stdout.writeln('    Cmd: ${tData['command']}');
        }
      }
    }
  }
  stdout.writeln('');
}

void _printUsage() {
  stdout.writeln('''
Usage:
  dart run tool/build.dart [options]

Options:
  --list, -l                   List all available build targets in build.json
  --env=<name>                 Environment name (development, staging, production)
  --platform=<android|ios>     Target platform
  --target=<target_name>       Target configuration (e.g. apk, appbundle, ipa)
  --dry-run                    Print the resolved command without executing it
  --help, -h                   Show this help message

Examples:
  dart run tool/build.dart --list
  dart run tool/build.dart --env=development --platform=android --dry-run
  dart run tool/build.dart --env=staging --platform=android --target=appbundle --dry-run
  dart run tool/build.dart --env=production --platform=ios --dry-run
''');
}
