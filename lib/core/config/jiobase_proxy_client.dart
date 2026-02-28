import 'package:http/http.dart' as http;

class JiobaseProxyClient extends http.BaseClient {
  final http.Client _inner;
  final Uri _proxyUri;

  JiobaseProxyClient(this._inner, String proxyUrl)
    : _proxyUri = Uri.parse(proxyUrl);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    if (request.url.host.contains('supabase.co')) {
      final newUrl = request.url.replace(
        scheme: _proxyUri.scheme,
        host: _proxyUri.host,
        port: _proxyUri.port,
      );

      final newReq = http.StreamedRequest(request.method, newUrl)
        ..headers.addAll(request.headers)
        ..contentLength = request.contentLength
        ..followRedirects = request.followRedirects
        ..maxRedirects = request.maxRedirects
        ..persistentConnection = request.persistentConnection;

      request.finalize().listen(
        newReq.sink.add,
        onError: newReq.sink.addError,
        onDone: newReq.sink.close,
      );

      return _inner.send(newReq);
    }

    return _inner.send(request);
  }
}
