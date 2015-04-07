part of micro_dart;

class BundleManager {
  final Logger log = new Logger("BundleManager");
  Map<String, Bundle> _bundles = new Map();

  _BundleService _bundleService;

  Directory _directory;
  Directory get directory => _directory;
  bool autoInstall;

  BundleManager(Directory directory, {_BundleService bundleService, bool this.autoInstall: true}) {
    this._directory = directory;
    if (bundleService != null) {
      this._bundleService = bundleService;
    } else {
      this._bundleService = new _BundleService();
    }
  }

  _refresh() async {
    if (_bundles.isEmpty && autoInstall) {
      _bundles = await _bundleService.discoverBundles(_directory);
    }
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
    await _refresh();
    var bundlesToStart = getBundlesToChange(bundleNames);
    await _bundleService.startBundles(bundlesToStart);
  }

  void stop([List<String> bundleNames]) {
    var bundlesToStop = getBundlesToChange(bundleNames);
    _bundleService.stopBundles(bundlesToStop);
  }

  Future<Map<String, BundleStatus>> getStatus() async {
    await _refresh();
    Map<String, BundleStatus> statusMap = new Map();
    _bundles.forEach((name, bundle) {
      statusMap[name] = bundle.status;
    });
    return statusMap;
  }
}