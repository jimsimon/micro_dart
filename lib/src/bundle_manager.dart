part of micro_dart;

class BundleManager {
  final Logger log = new Logger("BundleManager");
  Map<String, Bundle> _bundles = new Map();

  _BundleService _bundleService;
  Map<String, Bundle> get bundles => _bundles;

  Directory _directory;
  Directory get directory => _directory;

  BundleManager(Directory directory, {_BundleService bundleService}) {
    this._directory = directory;
    if (bundleService != null) {
      this._bundleService = bundleService;
    } else {
      this._bundleService = new _BundleService();
    }
  }


  refresh() async {
    _bundles = await _bundleService.discoverBundles(_directory);
  }


  List<Bundle> getBundlesToChange(List<String> bundleNames) {
    List<Bundle> bundlesToStart = _bundles.values.toList();
    if (bundleNames != null && bundleNames.isNotEmpty) {
      bundlesToStart = new List<Bundle>();
      bundleNames.forEach((name) {
        var bundle = _bundles[name];
        if (bundle != null) {
          bundlesToStart.add(bundle);
        }
      });
    }
    return bundlesToStart;
  }

  start([List<String> bundleNames]) async {
    await refresh();
    var bundlesToStart = getBundlesToChange(bundleNames);
    await _bundleService.startBundles(bundlesToStart);
  }

  void stop([List<String> bundleNames]) {
    var bundlesToStop = getBundlesToChange(bundleNames);
    _bundleService.stopBundles(bundlesToStop);
  }
}