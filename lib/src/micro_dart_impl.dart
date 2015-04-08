part of micro_dart;

class MicroDart {
  final Logger _log = new Logger("BundleManager");

  Map<String, Bundle> _bundles = new Map();

  _BundleService _bundleService;
  BundleProxy _bundleProxy;
  Directory _directory;

  static Future<MicroDart> getInstance(Directory directory, {bool autoInstall: true, int proxyPort: 8080}) async {
    _BundleService bundleService = new _BundleService();
    BundleProxy bundleProxy = await BundleProxy.getInstance(port: proxyPort);
    MicroDart microDart = new MicroDart._internal(directory, bundleService, bundleProxy);
    if (autoInstall) {
      await microDart.install();
    }
    return microDart;
  }

  MicroDart._internal(Directory this._directory, _BundleService this._bundleService, BundleProxy this._bundleProxy);

  Future install([List<String> bundleNames]) async {
    Map<String, Bundle> discoveredBundles = await _bundleService.discoverBundles(_directory);
    _bundles = _filterBundlesByName(discoveredBundles, bundleNames);
  }

  Future start([List<String> bundleNames]) async {
    var bundlesToStart = _filterBundlesByName(_bundles, bundleNames);
    await _bundleService.startBundles(bundlesToStart);
    await _bundleProxy.addProxies(bundlesToStart);
  }

  Future stop([List<String> bundleNames]) async {
    var bundlesToStop = _filterBundlesByName(_bundles, bundleNames);
    _bundleService.stopBundles(bundlesToStop);
    _bundleProxy.removeProxies(bundlesToStop);
  }

  Future<Map<String, BundleStatus>> getStatus() async {
    Map<String, BundleStatus> statusMap = new Map();
    _bundles.forEach((name, bundle) {
      statusMap[name] = bundle.status;
    });
    return statusMap;
  }

  Future shutdown() async {
    await _bundleService.stopBundles(_bundles);
    await _bundleProxy.stop();
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