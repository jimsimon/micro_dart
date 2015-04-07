part of micro_dart;

class StopCommand extends Command {

  BundleManager bundleManager;
  StopCommand(this.bundleManager);

  String get name => "stop";
  String get description => "Stops all bundles";
  void run() {
    bundleManager.stop();
  }
}