part of 'crypto_bloc.dart';

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

  void send({required String method, required Map<String, dynamic> params, required SendPort port}) {
    try {
      sendPort.send(['$method?${json.encode(params)}', port]);
    } catch (e) {}
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

void _generateMnemonic(SendPort port, Map<String, dynamic> params) {
  String mnemonic = generateMnemonic(
      wordCount: params['wordCount'], language: params['language']);
  port.send(mnemonic);
}

Future<void> _initializeWallet(SendPort port, Map<String, dynamic> params) async {
  Wallet? wallet;
  switch (params['seedSource']) {
    case 'mnemonic':
      wallet = await Wallet.fromMnemonic(
          id: params['id'],
          name: params['name'],
          description: params['description'],
          mnemonic: params['seed'],
      password: params['password']);
      break;
    case 'xprv':
      wallet = await Wallet.fromXprvStr(
          id: params['id'],
          name: params['walletName'],
          description: params['walletDescription'],
          xprv: params['seed'],
          password: params['password']);
      break;
    case 'encryptedXprv':
      try {
        wallet = await Wallet.fromEncryptedXprv(
          id: params['id'],
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
  port.send({'wallet': wallet});
}

void _generateKey(SendPort port, Map<String, dynamic> params) {
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

Future<void> _generateKeys(SendPort port, Map<String, dynamic> params) async {
  Wallet dbWallet = params['wallet'];
  int _from = params['from'];
  int _to = params['to'];

  for (int i = _from; i <= _to; i++) {
    await dbWallet.generateKey(index: i, keyType: params['keyType']);
  }
  port.send({'wallet': dbWallet});
}

/// _signTranstion
/// [SendPort] [port] sends the message back to the receiver
/// [params] is a Map containing:
/// 'xprv' [String] AES.CBC encrypted XPRV
/// 'password' [String] used to decrypt the xprv
/// 'signers' [List] List<String> contains the paths of the signers
/// 'transaction_id' [String] the hash of the transaction.
Future<void> _signTransaction(SendPort port, Map<String, dynamic> params) async {
  String password = params['password'];
  Map<String, List<String>> signers = params['signers'];
  String transactionId = params['transaction_id'];
  String errorMsg = '';

  try {


    // storage for signatures
    List<KeyedSignature> signatures = [];

    Map<String, KeyedSignature> _sigMap = {};
    signers.forEach((encryptedXprv, paths) {
      Xprv masterXprv = Xprv.fromEncryptedXprv(encryptedXprv, password);

      // get external xprv
      Xprv externalXprv = masterXprv /
          KEYPATH_PURPOSE /
          KEYPATH_COIN_TYPE /
          KEYPATH_ACCOUNT /
          EXTERNAL_KEYCHAIN;

      // get internal xprv
      Xprv internalXprv = masterXprv /
          KEYPATH_PURPOSE /
          KEYPATH_COIN_TYPE /
          KEYPATH_ACCOUNT /
          INTERNAL_KEYCHAIN;

      paths.forEach((path) {
        List<String> indexedPath = path.split('/');
        assert(indexedPath.length == 6, 'Path does not derive a valid Wallet');

        /// ['M','3h','4919h','0h','0', ...]
        /// index 4 is the external[0] or internal[1] key path
        Xprv signer;
        if (indexedPath.elementAt(4) == '0') {
          signer = externalXprv / int.parse(indexedPath.last);
        } else {
          assert(indexedPath.elementAt(4) == '1');
          signer = internalXprv / int.parse(indexedPath.last);
        }
        String address = signer.address.address;

        if (_sigMap.containsKey(address)) {
          signatures.add(_sigMap[address]!);
        } else {
          KeyedSignature signature =
          signer.address.signHash(transactionId, signer.privateKey);
          _sigMap[address] = signature;
          signatures.add(_sigMap[address]!);
        }
      });
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
