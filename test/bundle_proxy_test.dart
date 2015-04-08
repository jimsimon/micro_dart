import "dart:io";
import "package:micro_dart/micro_dart.dart";
import "package:unittest/unittest.dart";
import "dart:convert";

main() {
  test("proxy server forwards valid request to bundle via url", () async {
    Directory directory = new Directory("test/rest_bundles");
    BundleManager bundleManager = await BundleManager.getInstance(directory);
    await bundleManager.start();
    BundleProxy bundleProxy = new BundleProxy(bundleManager);
    await bundleProxy.start();
    HttpClient client = new HttpClient();
    HttpClientRequest request = await client.get("localhost", 8080, "bundle1/test");
    HttpClientResponse response = await request.close();

    expect(response.statusCode, equals(200));
    await for (var content in response.transform(UTF8.decoder)) {
      expect(content, equals("test"));
    }
    await bundleProxy.stop();
    await bundleManager.stop();
  });
}