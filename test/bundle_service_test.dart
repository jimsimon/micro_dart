import "package:micro_dart/micro_dart.dart";
import "package:unittest/unittest.dart";
import "dart:io";
import "package:path/path.dart";

main() {
  group("BundleService", (){
    group("discoverBundles", () {
      test("should throw error if null bundle directory specified", () {
        expect(new BundleService().discoverBundles(null), throwsArgumentError);
      });

      test("should throw error if bundle directory does not exist", (){
        expect(new BundleService().discoverBundles(new Directory("lasjndlj")), throwsArgumentError);
      });

      test("should return all bundles for valid directory", () async {
        Directory directory = new Directory("test/bundles");
        BundleService bundleService = new BundleService();
        Map<String, Bundle> bundles = await bundleService.discoverBundles(directory);
        expect(bundles.length, equals(1));
        expect(bundles.containsKey("test_bundle"), isTrue);

        Bundle testBundle = bundles["test_bundle"];
        expect(testBundle.name, equals("test_bundle"));
        expect(testBundle.entryPointPath, equals("test/bundles/test_bundle/main.dart"));
        expect(testBundle.packageRootPath, equals("test/bundles/test_bundle/packages"));
        expect(testBundle.rootPath, equals("test/bundles/test_bundle"));
        expect(testBundle.status, equals("stopped"));
        expect(testBundle.isolate, isNull);
      });
    });

    group("startBundles", (){
      test("should start all bundles", () async {
        List<Bundle> bundles = new List();
        Bundle bundle = new Bundle();
        bundle.name = "test_bundle";
        bundle.entryPointPath = absolute("test/bundles/test_bundle/main.dart");
        bundle.packageRootPath = absolute("test/bundles/test_bundle/packages");
        bundle.rootPath = absolute("test/bundles/test_bundle");
        bundle.status = "stopped";
        bundles.add(bundle);

        BundleService bundleService = new BundleService();
        await bundleService.startBundles(bundles);

        expect(bundle.isolate, isNotNull);
        expect(bundle.status, "started");
      });
    });
  });
}