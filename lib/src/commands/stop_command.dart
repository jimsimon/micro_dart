part of micro_dart;

class StopCommand extends Command {

  BundleService bundleService;
  Map<String, Bundle> bundles;
  StopCommand(this.bundleService,  this.bundles);

  String get name => "stop";
  String get description => "Stops all bundles";
  void run() {
    bundleService.stopBundles(bundles.values.toList());
  }
}