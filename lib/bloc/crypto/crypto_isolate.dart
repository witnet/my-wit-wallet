import 'dart:convert';
import 'dart:isolate';

import 'package:witnet/constants.dart';
import 'package:witnet/crypto.dart';
import 'package:witnet/schema.dart';
import 'package:witnet/witnet.dart';
import 'package:witnet_wallet/util/witnet/wallet/wallet.dart';

class CryptoIsolate {
  static final CryptoIsolate _cryptoIsolate = CryptoIsolate._internal();

  CryptoIsolate._internal();

  factory CryptoIsolate.instance() => _cryptoIsolate;
  late Isolate isolate;
  late SendPort sendPort;
  late ReceivePort receivePort;
  bool initialized = false;

  CryptoIsolate();

  Future<void> init() async {
    receivePort = ReceivePort();
    isolate = await Isolate.spawn(_cryptIso, receivePort.sendPort);
    sendPort = await receivePort.first as SendPort;
  }

  void send(
      {required String method,
      required Map<String, dynamic> params,
      required SendPort port}) {
    try {
      sendPort.send(['$method?${json.encode(params)}', port]);
    } catch (e) {
    }
  }
}

void _cryptIso(SendPort sendPort) async {
  // Stopwatch mainTimer = new Stopwatch()..start();
  ReceivePort receivePort = ReceivePort();

  // tell whoever created us what port they can reach us
  sendPort.send(receivePort.sendPort);
  // listen for messages
  await for (var msg in receivePort) {
    var data = msg[0] as String;
    SendPort port = msg[1];
    var method = data.split('?')[0];
    var params = json.decode(data.split('?')[1]);
    switch (method) {
      case 'generateMnemonic':
        _generateMnemonic(port, params);
        break;
      case 'initializeWallet':
        await _initializeWallet(port, params);
        break;
      case 'generateKey':
        _generateKey(port, params);
        break;
      case 'generateKeys':
        await _generateKeys(port, params);
        break;
      case 'signTransaction':
        await _signTransaction(port, params);
        break;
      case '':
      default:
    }
  }
  receivePort.close();
}

void _generateMnemonic(SendPort port, Map<String, dynamic> params){
  String mnemonic = generateMnemonic(
      wordCount: params['wordCount'], language: params['language']);
  port.send(mnemonic);
}

Future<void> _initializeWallet(SendPort port, Map<String, dynamic> params) async{
  Wallet? wallet;
  switch (params['seedSource']) {
    case 'mnemonic':
      wallet = await Wallet.fromMnemonic(
          name: params['walletName'],
          description: params['walletDescription'],
          mnemonic: params['seed']);
      break;
    case 'xprv':
      wallet = await Wallet.fromXprvStr(
          name: params['walletName'],
          description: params['walletDescription'],
          xprv: params['seed']);
      break;
    case 'encryptedXprv':
      try {
        wallet = await Wallet.fromEncryptedXprv(
          name: params['walletName'],
          description: params['walletDescription'],
          xprv: params['seed'],
          password: params['password'],
        );
      } catch (e) {
        port.send({'error': e});
      }
      break;
  }
  port.send(wallet);
}

void _generateKey(SendPort port, Map<String, dynamic> params){
  int index = params['index'];
  String keytype = params['keyType'];
  if (keytype.endsWith('external')) {

    Xpub _xpub = Xpub.fromXpub(params['external_keychain']);
    port.send({'xpub': _xpub / index});
  } else if (keytype.endsWith('internal')) {
    Xpub _xpub = Xpub.fromXpub(params['internal_keychain']);
    port.send({'xpub': _xpub / index});
  }
}

Future<void> _generateKeys(SendPort port, Map<String, dynamic> params) async{
  Wallet wallet = params['wallet'];
  int _from = params['from'];
  int _to = params['to'];

  for (int i = _from; i <= _to; i++) {
    await wallet.generateKey(index: i, keyType: params['keyType']);
  }
  port.send({'wallet': wallet});
}

Future<void> _signTransaction(SendPort port, Map<String, dynamic> params) async {
  String encryptedXprv = params['xprv'];
  String password = params['password'];
  List<dynamic> signerPaths = params['signers'];
  String transactionId = params['transaction_id'];
  String errorMsg = '';

  try {
    Xprv masterXprv = Xprv.fromEncryptedXprv(encryptedXprv, password);


    Xprv externalXprv = masterXprv
        / KEYPATH_PURPOSE
        / KEYPATH_COIN_TYPE
        / KEYPATH_ACCOUNT
        / EXTERNAL_KEYCHAIN;


    Xprv internalXprv = masterXprv
        / KEYPATH_PURPOSE
        / KEYPATH_COIN_TYPE
        / KEYPATH_ACCOUNT
        / INTERNAL_KEYCHAIN;

    List<KeyedSignature> signatures = [];
    signerPaths.forEach((element) {
      List<dynamic> path = element.toString().split('/');

      assert(path.length == 6);
      if (path.elementAt(4) == '0') {

        Xprv signer = externalXprv / int.parse(path.last);


        print(signer.path);
        signatures.add(
            signer.address.signHash(transactionId, signer.privateKey));
      } else {
        Xprv signer = internalXprv / int.parse(path.last);

        signatures.add(
            signer.address.signHash(transactionId, signer.privateKey));
      }
    });
    List<dynamic> sigMap = [];
    signatures.forEach((element) {
      sigMap.add(element.jsonMap());
    });

    port.send(sigMap);
  } catch (e) {
    errorMsg = e.toString();
  }
  port.send(errorMsg);
}

