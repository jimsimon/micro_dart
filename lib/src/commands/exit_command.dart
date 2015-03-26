part of micro_dart;

class ExitCommand extends Command {

  BundleService bundleService;
  Map<String, Bundle> bundles;
  ExitCommand(this.bundleService, this.bundles);

  String get name => "exit";
  String get description => "Stops all bundles";
  void run() {
    new StopCommand(bundleService, bundles).run();
    print("Shutting down...");
    exit(0);
  }
}