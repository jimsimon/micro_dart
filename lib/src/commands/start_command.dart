part of micro_dart;

class StartCommand extends Command {

  BundleService bundleService;
  Map<String, Bundle> bundles;
  StartCommand(this.bundleService, this.bundles);

  String get name => "start";
  String get description => "Starts all bundles";
  void run() {
    bundleService.startBundles(bundles.values.toList());
  }
}