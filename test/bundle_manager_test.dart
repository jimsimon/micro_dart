import "package:unittest/unittest.dart";
import "dart:io";
import "package:micro_dart/micro_dart.dart";
import "package:path/path.dart";

main() {
  group("BundleManager", (){
    test("should be managing 0 bundles after creation", (){
      Directory directory = new Directory("test/bundles");
      BundleManager bundleManager = new BundleManager(directory);
      expect(bundleManager.bundles, isEmpty);
    });

    test("refresh should find all bundles in specified bundle directory", () async {
      Directory directory = new Directory("test/bundles");
      BundleManager bundleManager = new BundleManager(directory);
      await bundleManager.refresh();
      expect(bundleManager.bundles.length, equals(2));
      expect(bundleManager.bundles.containsKey("test_bundle"), isTrue);

      Bundle testBundle = bundleManager.bundles["test_bundle"];
      expect(testBundle.name, equals("test_bundle"));
      expect(testBundle.entryPointPath, equals(absolute("test/bundles/test_bundle/main.dart")));
      expect(testBundle.packageRootPath, equals(absolute("test/bundles/test_bundle/packages")));
      expect(testBundle.rootPath, equals(absolute("test/bundles/test_bundle")));
      expect(testBundle.status, equals(BundleStatus.STOPPED));
      expect(testBundle.isolate, isNull);
    });

    group("start", () {
      test("should start all bundles if none specified", () async {
        Directory directory = new Directory("test/bundles");
        BundleManager bundleManager = new BundleManager(directory);
        await bundleManager.start();

        var bundles = bundleManager.bundles.values.toList();
        expect(bundles, isNotEmpty);

        var bundle = bundles.first;
        expect(bundle.isolate, isNotNull);
        expect(bundle.status, equals(BundleStatus.STARTED));

        var bundle2 = bundles[1];
        expect(bundle2.isolate, isNotNull);
        expect(bundle2.status, equals(BundleStatus.STARTED));
      });

      test("should start only specified bundles", () async {
        Directory directory = new Directory("test/bundles");
        BundleManager bundleManager = new BundleManager(directory);
        await bundleManager.start(["test_bundle"]);

        var bundles = bundleManager.bundles.values.toList();
        expect(bundles, isNotEmpty);

        var bundle = bundles.first;
        expect(bundle.isolate, isNotNull);
        expect(bundle.status, equals(BundleStatus.STARTED));

        var bundle2 = bundles[1];
        expect(bundle2.isolate, isNull);
        expect(bundle2.status, equals(BundleStatus.STOPPED));
      });
    });

    group("stop", () {
      test("should stop all bundles if none specified", () async {
        Directory directory = new Directory("test/bundles");
        BundleManager bundleManager = new BundleManager(directory);

        await bundleManager.start();

        var bundles = bundleManager.bundles.values.toList();
        expect(bundles, isNotEmpty);

        var bundle = bundles.first;
        expect(bundle.isolate, isNotNull);
        expect(bundle.status, equals(BundleStatus.STARTED));

        var bundle2 = bundles[1];
        expect(bundle2.isolate, isNotNull);
        expect(bundle2.status, equals(BundleStatus.STARTED));

        bundleManager.stop();

        expect(bundle.isolate, isNull);
        expect(bundle.status, equals(BundleStatus.STOPPED));

        expect(bundle2.isolate, isNull);
        expect(bundle2.status, equals(BundleStatus.STOPPED));
      });

      test("should stop only specified bundles", () async {
        Directory directory = new Directory("test/bundles");
        BundleManager bundleManager = new BundleManager(directory);

        await bundleManager.start();

        var bundles = bundleManager.bundles;
        expect(bundles, isNotEmpty);

        var bundle = bundles["test_bundle"];
        expect(bundle.isolate, isNotNull);
        expect(bundle.status, equals(BundleStatus.STARTED));

        var bundle2 = bundles["test_bundle2"];
        expect(bundle2.isolate, isNotNull);
        expect(bundle2.status, equals(BundleStatus.STARTED));

        bundleManager.stop(["test_bundle"]);

        expect(bundle.isolate, isNull);
        expect(bundle.status, equals(BundleStatus.STOPPED));

        expect(bundle2.isolate, isNotNull);
        expect(bundle2.status, equals(BundleStatus.STARTED));
      });
    });
  });
}