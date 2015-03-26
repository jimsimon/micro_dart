import 'dart:io';
import 'package:args/command_runner.dart';
import 'dart:convert';
import 'package:micro_dart/micro_dart.dart';

main() {
  BundleService bundleService = new BundleService(new Uri.file("../bundles"));
  Map<String, Bundle> bundles = bundleService.discoverBundles();

  CommandRunner commandRunner = new CommandRunner("micro_dart", "Dart microservices framework")
    ..addCommand(new StartCommand(bundleService, bundles))
    ..addCommand(new StopCommand(bundleService, bundles))
    ..addCommand(new ExitCommand(bundleService, bundles));

  stdin.transform(UTF8.decoder).listen((String command) {
    command = command.replaceAll("\n", "");
    List<String> args = command.split(" ");
    commandRunner.run(args);
  });
}





