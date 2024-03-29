import 'dart:io';
import 'dart:convert';
import 'package:micro_dart/micro_dart.dart';
import 'package:logging/logging.dart';
import 'package:logging_handlers/logging_handlers_shared.dart';
import 'package:logging_handlers/server_logging_handlers.dart';

main() async {
  Logger.root.level = Level.ALL;
  var loggerStream = Logger.root.onRecord.asBroadcastStream();
  loggerStream.listen(new LogPrintHandler());
  loggerStream.listen(new SyncFileLoggingHandler("micro_dart.log"));

  MicroDart bundleManager = await MicroDart.getInstance(new Directory("../bundles"));

  MicroDartCommandRunner commandRunner = new MicroDartCommandRunner(bundleManager);
  stdin.transform(UTF8.decoder).listen((String command) async {
    command = command.replaceAll("\n", "");
    List<String> args = command.split(" ");
    try {
      await commandRunner.run(args);
    } catch(e) {
      commandRunner.printUsage();
    }
  });
}