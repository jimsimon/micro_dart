part of micro_dart;

class MicroDartCommandRunner extends CommandRunner {

  BundleService bundleService;
  Map<String, Bundle> bundles;
  MicroDartCommandRunner(this.bundleService, this.bundles) : super("micro_dart", "Dart microservices framework") {
      addCommand(new StartCommand(bundleService, bundles));
      addCommand(new StopCommand(bundleService, bundles));
      addCommand(new ExitCommand(bundleService, bundles));
  }
}