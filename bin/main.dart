import 'dart:io';
import 'dart:convert';
import 'package:micro_dart/micro_dart.dart';

main() {
  BundleService bundleService = new BundleService(new Uri.file("../bundles"));
  Map<String, Bundle> bundles = bundleService.discoverBundles();

  MicroDartCommandRunner commandRunner = new MicroDartCommandRunner(bundleService, bundles);
  stdin.transform(UTF8.decoder).listen((String command) {
    command = command.replaceAll("\n", "");
    List<String> args = command.split(" ");
    commandRunner.run(args);
  });
}





