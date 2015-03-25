import 'dart:isolate';
import 'dart:async';
import 'dart:io';
import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'dart:convert';
import 'package:path/path.dart';

main() {
  bool running = true;
  Map<String, Bundle> bundles = new Map();
  List<Isolate> isolates = new List();
  Directory directory = new Directory.fromUri(new Uri.file("../bundles"));
  directory.listSync().forEach((FileSystemEntity fileSystemEntity) {
    if (fileSystemEntity is Directory) {
      String entryPointPath = join(fileSystemEntity.path, "main.dart");
      File entryPoint = new File.fromUri(new Uri.file(entryPointPath));
      if (entryPoint.existsSync()) {
        Bundle bundle = new Bundle();
        bundle.name = basename(fileSystemEntity.path);
        bundle.rootPath = fileSystemEntity.path;
        bundle.entryPointPath = entryPointPath;
        bundle.packageRootPath = join(fileSystemEntity.path, "packages");
        bundles[bundle.name] = bundle;
      }
    }
  });

  CommandRunner commandRunner = new CommandRunner("micro_dart", "Dart microservices framework")
    ..addCommand(new StartCommand(bundles))
    ..addCommand(new StopCommand(bundles))
    ..addCommand(new ExitCommand(bundles));

  stdin.transform(UTF8.decoder).listen((String command) {
    command = command.replaceAll("\n", "");
    List<String> args = command.split(" ");
    commandRunner.run(args);
  });
}

class Bundle {
  String name, rootPath, entryPointPath, packageRootPath, status = "stopped";
  Isolate isolate;
}

class StartCommand extends Command {

  Map<String, Bundle> bundles;
  StartCommand(this.bundles);

  String get name => "start";
  String get description => "Starts all bundles";
  void run() {
    bundles.forEach((name, bundle) async {
      print("Starting bundle: ${bundle.name}");
      Isolate isolate = await Isolate.spawnUri(new Uri.file(bundle.entryPointPath), null, null, packageRoot: new Uri.file(bundle.packageRootPath));
      bundle.status = "running";
      ReceivePort receivePort = new ReceivePort();
      isolate.addOnExitListener(receivePort.sendPort);
      receivePort.listen((message){
        print("message: $message");
        if (message == null) {
          print("Bundle exited: ${bundle.name}");
          bundle.status = "stopped";
        }
      });
      bundle.isolate = isolate;
    });
  }
}

class StopCommand extends Command {

  Map<String, Bundle> bundles;
  StopCommand(this.bundles);

  String get name => "stop";
  String get description => "Stops all bundles";
  void run() {
    bundles.forEach((name, bundle) {
      if (bundle.status == "running") {
        print("Stopping bundle: ${bundle.name}");
        bundle.isolate.kill();
      } else if (bundle.status == "stopped") {
        print("Bundle not running: ${bundle.name}");
      }
    });
  }
}

class ExitCommand extends Command {

  Map<String, Bundle> bundles;
  ExitCommand(this.bundles);

  String get name => "exit";
  String get description => "Stops all bundles";
  void run() {
    new StopCommand(bundles).run();
    print("Shutting down...");
    exit(0);
  }
}