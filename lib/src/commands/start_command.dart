part of micro_dart;

class StartCommand extends Command {

  BundleManager bundleManager;
  StartCommand(this.bundleManager);

  String get name => "start";
  String get description => "Starts all bundles";
  void run() {
    bundleManager.start();
  }
}