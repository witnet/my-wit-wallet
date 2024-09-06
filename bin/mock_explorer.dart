import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_router/shelf_router.dart';

void main(List<String> args) async {
  await _loadMockData();
  final InternetAddress ip = InternetAddress.anyIPv4;
  final FutureOr<Response> Function(Request) handler =
      Pipeline().addMiddleware(logRequests()).addHandler(_router);
  final int port = int.parse(Platform.environment['PORT'] ?? '8080');
  final HttpServer server = await serve(handler, ip, port);
  print('Server listening on ${ip.address}:${server.port}');
}

// Configure routes.
final _router = Router()
  ..get('/', _rootHandler)
  ..get('/echo/<message>', _echoHandler)
  ..get('/api/status', statusHandler)
  ..get('/api/address/<path>', addressHandler)
  ..get('/api/transaction/<path>', transactionHandler)
  ..get('/api/search/<path>', searchHandler);

Future<Map<String, dynamic>> readJsonFile(String filePath) async {
  var input = await File(filePath).readAsString();
  var map = jsonDecode(input);
  return map;
}

Response searchHandler(Request request) {
  final Map<String, dynamic> queryParams = request.url.queryParameters;
  return Response.ok(
    json.encode(_hashData[queryParams['value']]),
    headers: _headerData,
  );
}

Response statusHandler(Request request) {
  return Response.ok(json.encode(_statusData), headers: _headerData);
}

Future<Response> _utxos(Request request) async {
  final Map<String, dynamic> queryParams = request.url.queryParameters;
  List<String> addresses = queryParams['addresses'];
  List<Object> addressList = [];
  addresses.forEach((address) {
    if (_utxoData.containsKey(address)) {
      addressList.add(json.encode(_utxoData[address]!));
    } else {
      addressList.add(json.encode({"address": address, "utxos": []}));
    }
  });
  return Response.ok(addressList.toString(), headers: _headerData);
}

Response _valueTransfers(Request request) {
  Map<String, dynamic> queryParams = request.requestedUri.queryParameters;
  String response = json.encode(_vttData[queryParams['address']]!);
  return Response.ok(response, headers: _headerData);
}

Response _dataRequestsSolved(Request request) {
  return Response.ok('[]', headers: _headerData);
}

Response _blocks(Request request) {
  return Response.ok('[]', headers: _headerData);
}

Future<Response> addressHandler(Request request) async {
  String method =
      request.requestedUri.toString().split('/').last.split('?').first;

  switch (method) {
    case "utxos":
      return _utxos(request);
    case 'value-transfers':
      return _valueTransfers(request);
    case 'data-requests-solved':
      return _dataRequestsSolved(request);
    case 'blocks':
      return _blocks(request);
    default:
      return Response.notFound("");
  }
}

Response transactionHandler(Request request) {
  String method =
      request.requestedUri.toString().split('/').last.split('?').first;
  switch (method) {
    case 'priority':
      return Response.ok(json.encode(_priorityData));
  }
  return Response.ok('');
}

Response _rootHandler(Request req) {
  return Response.ok('Hello, World!\n');
}

Response _echoHandler(Request request) {
  final message = request.params['message'];
  return Response.ok('$message\n');
}

Map<String, Object> _headerData = {};
Map<String, dynamic> _statusData = {};
Map<String, dynamic> _utxoData = {};
Map<String, dynamic> _vttData = {};
Map<String, dynamic> _hashData = {};
Map<String, dynamic> _priorityData = {};

Future<void> _loadMockData() async {
  var input = await File('bin/mock_data.json').readAsString();
  var map = jsonDecode(input);
  _headerData = Map<String, Object>.from(map['headers']);
  _headerData['x-pagination'] = json.encode({
    "total": 1,
    "total_pages": 1,
    "first_page": 1,
    "last_page": 1,
    "page": 1
  });
  _statusData = map['status'];
  _utxoData = map['utxos'];
  _vttData = map['value-transfers'];
  _priorityData = map['priority'];
  _hashData = map['hashes'];
}
