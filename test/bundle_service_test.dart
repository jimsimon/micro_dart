import "package:micro_dart/micro_dart.dart";
import "package:unittest/unittest.dart";
import "dart:io";
import "package:path/path.dart";
import "package:logging/logging.dart";
import "package:logging_handlers/logging_handlers_shared.dart";
import "package:logging_handlers/server_logging_handlers.dart";

List<Bundle> createTestBundles() {
  List<Bundle> bundles = new List();
  Bundle bundle = new Bundle();
  bundle.name = "test_bundle";
  bundle.entryPointPath = absolute("test/bundles/test_bundle/main.dart");
  bundle.packageRootPath = absolute("test/bundles/test_bundle/packages");
  bundle.rootPath = absolute("test/bundles/test_bundle");
  bundle.status = BundleStatus.STOPPED;
  bundles.add(bundle);
  return bundles;
}

main() {
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen(new LogPrintHandler());

  group("BundleService", (){
    BundleService bundleService;

    setUp((){
      bundleService = new BundleService();
    });

    group("discoverBundles", () {
      test("should throw error if null bundle directory specified", () {
        expect(bundleService.discoverBundles(null), throwsArgumentError);
      });

      test("should throw error if bundle directory does not exist", (){
        expect(bundleService.discoverBundles(new Directory("lasjndlj")), throwsArgumentError);
      });

      test("should return all bundles for valid directory", () async {
        Directory directory = new Directory("test/bundles");
        Map<String, Bundle> bundles = await bundleService.discoverBundles(directory);
        expect(bundles.length, equals(1));
        expect(bundles.containsKey("test_bundle"), isTrue);

        Bundle testBundle = bundles["test_bundle"];
        expect(testBundle.name, equals("test_bundle"));
        expect(testBundle.entryPointPath, equals("test/bundles/test_bundle/main.dart"));
        expect(testBundle.packageRootPath, equals("test/bundles/test_bundle/packages"));
        expect(testBundle.rootPath, equals("test/bundles/test_bundle"));
        expect(testBundle.status, equals(BundleStatus.STOPPED));
        expect(testBundle.isolate, isNull);
      });
    });

    group("startBundle", (){
      test("should start the specified bundle", () async {
        var bundles = createTestBundles();
        var bundle = await bundleService.startBundle(bundles[0]);

        expect(bundle.isolate, isNotNull);
        expect(bundle.status, equals(BundleStatus.STARTED));
      });
    });

    group("startBundles", (){
      test("should start all bundles", () async {
        var bundles = createTestBundles();
        await bundleService.startBundles(bundles);

        expect(bundles[0].isolate, isNotNull);
        expect(bundles[0].status, equals(BundleStatus.STARTED));
      });
    });

    group("stopBundles", (){
      test("should stop all bundles", () async {
        var bundles = createTestBundles();
        await bundleService.startBundles(bundles);

        expect(bundles[0].isolate, isNotNull);
        expect(bundles[0].status, equals(BundleStatus.STARTED));

        bundleService.stopBundles(bundles);

        expect(bundles[0].isolate, isNull);
        expect(bundles[0].status, equals(BundleStatus.STOPPED));
      });
    });

    group("stopBundle", (){
      test("should stop the specified bundle", () async {
        var bundles = createTestBundles();
        await bundleService.startBundle(bundles[0]);

        expect(bundles[0].isolate, isNotNull);
        expect(bundles[0].status, equals(BundleStatus.STARTED));

        bundleService.stopBundle(bundles[0]);

        expect(bundles[0].isolate, isNull);
        expect(bundles[0].status, equals(BundleStatus.STOPPED));
      });
    });
  });
}