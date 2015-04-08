import "package:unittest/unittest.dart";
import "dart:io";
import "package:micro_dart/micro_dart.dart";
import "dart:convert";

main() {

  MicroDart microDart;
  Directory directory;
  group("MicroDart", (){
    setUp(() async {
      directory = new Directory("test/bundles");
      microDart = await MicroDart.getInstance(directory);
    });

    tearDown(() async {
      await microDart.shutdown();
    });

    test("should have no bundles if autoInstall is off",() async {
      MicroDart microDart = await MicroDart.getInstance(directory, autoInstall: false, proxyPort: 8081);
      Map<String, BundleStatus> statusMap = await microDart.getStatus();
      expect(statusMap, isEmpty);
      microDart.shutdown();
    });

    test("should have no running bundles after creation", () async {
      Map<String, BundleStatus> statusMap = await microDart.getStatus();
      expect(statusMap.length, equals(2));
      statusMap.forEach((name, status){
        expect(status, equals(BundleStatus.STOPPED));
      });
    });

    group("install", (){
      test("should install all bundles if none specified", () async {
        MicroDart microDart = await MicroDart.getInstance(directory, autoInstall: false, proxyPort: 8081);
        await microDart.install();
        Map<String, BundleStatus> statusMap = await microDart.getStatus();
        expect(statusMap.length, equals(2));
        statusMap.forEach((name, status){
          expect(status, equals(BundleStatus.STOPPED));
        });
        microDart.shutdown();
      });

      test("should install only specified bundles", () async {
        MicroDart microDart = await MicroDart.getInstance(directory, autoInstall: false, proxyPort: 8081);
        await microDart.install(["test_bundle2"]);
        Map<String, BundleStatus> statusMap = await microDart.getStatus();
        expect(statusMap.length, equals(1));
        expect(statusMap["test_bundle2"], BundleStatus.STOPPED);
        microDart.shutdown();
      });
    });

    group("start", () {
      test("should start all bundles if none specified", () async {
        await microDart.start();

        var bundles = await microDart.getStatus();
        expect(bundles, isNotEmpty);
        expect(bundles["test_bundle"], equals(BundleStatus.RUNNING));
        expect(bundles["test_bundle2"], equals(BundleStatus.RUNNING));
      });

      test("should start only specified bundles", () async {
        await microDart.start(["test_bundle"]);

        var bundles = await microDart.getStatus();
        expect(bundles, isNotEmpty);
        expect(bundles["test_bundle"], equals(BundleStatus.RUNNING));
        expect(bundles["test_bundle2"], equals(BundleStatus.STOPPED));
      });
    });

    group("proxy", (){
      MicroDart microDart;
      setUp(() async {
        Directory directory = new Directory("test/rest_bundles");
        microDart = await MicroDart.getInstance(directory, proxyPort: 8082);
        await microDart.start();
      });

      tearDown(() async {
        await microDart.shutdown();
      });

      test("should proxy requests to bundle", () async {
        HttpClient client = new HttpClient();
        HttpClientRequest request = await client.get("localhost", 8082, "bundle1/test");
        HttpClientResponse response = await request.close();

        expect(response.statusCode, equals(200));
        await for (var content in response.transform(UTF8.decoder)) {
          expect(content, equals("test"));
        }
      });
    });

    group("stop", () {
      test("should stop all bundles if none specified", () async {
        await microDart.start();

        var bundles = await microDart.getStatus();
        expect(bundles, isNotEmpty);
        expect(bundles["test_bundle"], equals(BundleStatus.RUNNING));
        expect(bundles["test_bundle2"], equals(BundleStatus.RUNNING));

        await microDart.stop();

        bundles = await microDart.getStatus();
        expect(bundles, isNotEmpty);
        expect(bundles["test_bundle"], equals(BundleStatus.STOPPED));
        expect(bundles["test_bundle2"], equals(BundleStatus.STOPPED));
      });

      test("should stop only specified bundles", () async {
        await microDart.start();

        var bundles = await microDart.getStatus();
        expect(bundles, isNotEmpty);
        expect(bundles["test_bundle"], equals(BundleStatus.RUNNING));
        expect(bundles["test_bundle2"], equals(BundleStatus.RUNNING));

        await microDart.stop(["test_bundle"]);

        bundles = await microDart.getStatus();
        expect(bundles, isNotEmpty);
        expect(bundles["test_bundle"], equals(BundleStatus.STOPPED));
        expect(bundles["test_bundle2"], equals(BundleStatus.RUNNING));
      });
    });
  });
}