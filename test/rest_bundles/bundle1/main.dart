import "dart:io";

main(List args) async {
  HttpServer server = await HttpServer.bind(InternetAddress.LOOPBACK_IP_V4, args[0]);
  server.listen((HttpRequest request) async {
    HttpResponse response = request.response;
    response.write("test");
    await response.close();
  });
}