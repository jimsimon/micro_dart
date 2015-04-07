part of micro_dart;

class BundleManager {
  final Logger _log = new Logger("BundleManager");

  Map<String, Bundle> _bundles = new Map();

  _BundleService _bundleService;
  Directory _directory;

  static Future<BundleManager> getInstance(Directory directory, {bool autoInstall: true}) async {
    _BundleService bundleService = new _BundleService();
    BundleManager bundleManager = new BundleManager._internal(directory, bundleService);
    if (autoInstall) {
      await bundleManager.install();
    }
    return bundleManager;
  }

  BundleManager._internal(Directory directory, _BundleService bundleService) {
    this._directory = directory;
    this._bundleService = bundleService;
  }

  Future install([List<String> bundleNames]) async {
    Map<String, Bundle> discoveredBundles = await _bundleService.discoverBundles(_directory);
    _bundles = _filterBundlesByName(discoveredBundles, bundleNames);
  }

  Future start([List<String> bundleNames]) async {
    var bundlesToStart = _filterBundlesByName(_bundles, bundleNames);
    await _bundleService.startBundles(bundlesToStart);
  }

  Future stop([List<String> bundleNames]) async {
    var bundlesToStop = _filterBundlesByName(_bundles, bundleNames);
    _bundleService.stopBundles(bundlesToStop);
  }

  Future<Map<String, BundleStatus>> getStatus() async {
    Map<String, BundleStatus> statusMap = new Map();
    _bundles.forEach((name, bundle) {
      statusMap[name] = bundle.status;
    });
    return statusMap;
  }

  Map<String, Bundle> _filterBundlesByName(Map<String, Bundle> bundles, List<String> bundleNames) {
    if (bundleNames == null || bundleNames.isEmpty) {
      return bundles;
    }

    Map<String, Bundle> bundlesToStart = new Map();
    if (bundleNames != null && bundleNames.isNotEmpty) {
      bundleNames.forEach((name) {
        var bundle = bundles[name];
        if (bundle != null) {
          bundlesToStart[name] = bundle;
        }
      });
    }
    return bundlesToStart;
  }
}