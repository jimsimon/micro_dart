import "package:unittest/unittest.dart";
import "dart:io";
import "package:micro_dart/micro_dart.dart";
import "package:path/path.dart";

main() {

  BundleManager bundleManager;
  group("BundleManager", (){
    setUp((){
      Directory directory = new Directory("test/bundles");
      bundleManager = new BundleManager(directory);
    });

    test("should have no bundles if autoInstall is off",() async {
      Directory directory = new Directory("test/bundles");
      BundleManager bundleManager = new BundleManager(directory, autoInstall: false);
      Map<String, BundleStatus> statusMap = await bundleManager.getStatus();
      expect(statusMap, isEmpty);
    });

    test("should have no running bundles after creation", () async {
      Map<String, BundleStatus> statusMap = await bundleManager.getStatus();
      expect(statusMap.length, equals(2));
      statusMap.forEach((name, status){
        expect(status, equals(BundleStatus.STOPPED));
      });
    });

    group("install", (){
      test("should install all bundles if none specified", (){

      });

      test("should install only specified bundles", (){

      });
    });

    group("start", () {
      test("should start all bundles if none specified", () async {
        await bundleManager.start();

        var bundles = await bundleManager.getStatus();
        expect(bundles, isNotEmpty);
        expect(bundles["test_bundle"], equals(BundleStatus.RUNNING));
        expect(bundles["test_bundle2"], equals(BundleStatus.RUNNING));
      });

      test("should start only specified bundles", () async {
        await bundleManager.start(["test_bundle"]);

        var bundles = await bundleManager.getStatus();
        expect(bundles, isNotEmpty);
        expect(bundles["test_bundle"], equals(BundleStatus.RUNNING));
        expect(bundles["test_bundle2"], equals(BundleStatus.STOPPED));
      });
    });

    group("stop", () {
      test("should stop all bundles if none specified", () async {
        await bundleManager.start();

        var bundles = await bundleManager.getStatus();
        expect(bundles, isNotEmpty);
        expect(bundles["test_bundle"], equals(BundleStatus.RUNNING));
        expect(bundles["test_bundle2"], equals(BundleStatus.RUNNING));

        bundleManager.stop();

        bundles = await bundleManager.getStatus();
        expect(bundles, isNotEmpty);
        expect(bundles["test_bundle"], equals(BundleStatus.STOPPED));
        expect(bundles["test_bundle2"], equals(BundleStatus.STOPPED));
      });

      test("should stop only specified bundles", () async {
        await bundleManager.start();

        var bundles = await bundleManager.getStatus();
        expect(bundles, isNotEmpty);
        expect(bundles["test_bundle"], equals(BundleStatus.RUNNING));
        expect(bundles["test_bundle2"], equals(BundleStatus.RUNNING));

        bundleManager.stop(["test_bundle"]);

        bundles = await bundleManager.getStatus();
        expect(bundles, isNotEmpty);
        expect(bundles["test_bundle"], equals(BundleStatus.STOPPED));
        expect(bundles["test_bundle2"], equals(BundleStatus.RUNNING));
      });
    });
  });
}