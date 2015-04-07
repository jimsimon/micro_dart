part of micro_dart;

class MicroDartCommandRunner extends CommandRunner {

  BundleManager bundleManager;
  MicroDartCommandRunner(this.bundleManager) : super("micro_dart", "Dart microservices framework") {
      addCommand(new StartCommand(bundleManager));
      addCommand(new StopCommand(bundleManager));
      addCommand(new ExitCommand(bundleManager));
  }
}