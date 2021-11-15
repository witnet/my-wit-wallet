import 'dart:convert';
import 'dart:isolate';

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
      print(e);
    }
  }
}

void _cryptIso(SendPort sendPort) async {
  Stopwatch mainTimer = new Stopwatch()..start();
  ReceivePort receivePort = ReceivePort();

  // tell whoever created us what port they can reach us
  sendPort.send(receivePort.sendPort);
  // listen for messages
  await for (var msg in receivePort) {
    var data = msg[0] as String;
    SendPort replyToPort = msg[1];
    var method = data.split('?')[0];
    var params = json.decode(data.split('?')[1]);
    switch (method) {
      case 'generateMnemonic':
        String mnemonic = generateMnemonic(
            wordCount: params['wordCount'], language: params['language']);

        replyToPort.send(mnemonic);
        break;
      case 'initializeWallet':
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
              replyToPort.send({'error': e});
            }
            break;
        }
        replyToPort.send(wallet);

        break;
      case 'generateKey':
        Xprv _xprv = Xprv.fromXprv(params['keychain']);
        int index = params['index'];
        String keytype = params['keyType'];
        if (keytype.endsWith('external')) {
          replyToPort.send({'xprv': _xprv / 3.0 / 4919.0 / 0.0 / 0 / index});
        } else if (keytype.endsWith('internal')) {
          replyToPort.send({'xprv': _xprv / 3.0 / 4919.0 / 0.0 / 1 / index});
        }
        break;

      case 'generateKeys':
        Wallet wallet = params['wallet'];
        int _from = params['from'];
        int _to = params['to'];

        for (int i = _from; i <= _to; i++) {
          await wallet.generateKey(index: i, keyType: params['keyType']);
        }

        replyToPort.send({'wallet': wallet});
        break;
      case 'signTransaction':
        String encryptedXprv = params['xprv'];
        String password = params['password'];
        List<dynamic> signerPaths = params['signers'];
        String transactionId = params['transaction_id'];
        String errorMsg = '';
        try {
          Xprv masterXprv = Xprv.fromEncryptedXprv(encryptedXprv, password);
          Xprv externalXprv = masterXprv / 3.0 / 4919.0 / 0.0;
          Xprv internalXprv = masterXprv / 3.0 / 4919.0 / 0.0;
          List<KeyedSignature> signatures = [];
          signerPaths.forEach((element) {
            List<dynamic> path = element.toString().split('/');
            print(path[0]);
            assert(path.length == 6);
            if (path.elementAt(4) == '0') {
              Xprv signer = externalXprv / 0 / int.parse(path.last);

              print(signer.path);
              signatures.add(
                  signer.address.signHash(transactionId, signer.privateKey));
            } else {
              Xprv signer = internalXprv / 1 / int.parse(path.last);
              print(signer.address.address);
              print(signer.path);
              signatures.add(
                  signer.address.signHash(transactionId, signer.privateKey));
            }
          });
          List<dynamic> sigMap = [];
          signatures.forEach((element) {
            sigMap.add(element.jsonMap());
          });

          replyToPort.send(sigMap);
        } catch (e) {
          print(e);
          errorMsg = e.toString();
        }
        replyToPort.send(errorMsg);

        break;
      case '':
      case '':
    }
  }
  receivePort.close();
}
