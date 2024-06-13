part of 'crypto_bloc.dart';

class CryptoIsolate {
  static final CryptoIsolate _cryptoIsolate = CryptoIsolate._internal();

  CryptoIsolate._internal();

  factory CryptoIsolate.instance() => _cryptoIsolate;
  DebugLogger get logger => Locator.instance<DebugLogger>();
  bool initialized = false;

  CryptoIsolate();

  Future<dynamic> send(
      {required String method, required Map<String, dynamic> params}) async {
    FutureOr<dynamic> isolateFunction() {
      return _methodMap[method]!(params);
    }

    try {
      return await Isolate.run(isolateFunction);
    } catch (err) {
      logger.log('Error in cryptoIsolate method: $method : $err');
      rethrow;
    }
  }
}

Map<String, Function(Map<String, dynamic>)> _methodMap = {
  'generateMnemonic': _generateMnemonic,
  'initializeWallet': _initializeWallet,
  'generateKey': _generateKey,
  'generateKeys': _generateKeys,
  'signTransaction': _signTransaction,
  'signUnstakeBody': _signUnstakeBody,
  'signMessage': _signMessage,
  'hashPassword': _hashPassword,
  'encryptXprv': _encryptXprv,
  'decryptXprv': _decryptXprv,
  'verifySheikahXprv': _verifySheikahXprv,
  'verifyLocalXprv': _verifyLocalXprv,
};

String _generateMnemonic(Map<String, dynamic> params) {
  return generateMnemonic(
      wordCount: params['wordCount'], language: params['language']);
}

Future<Wallet> _initializeWallet(Map<String, dynamic> params) async {
  bool isHdWallet = params['walletType'] == "hd";
  switch (params['seedSource']) {
    case 'mnemonic':
      try {
        return await Wallet.fromMnemonic(
            walletType: isHdWallet ? WalletType.hd : WalletType.single,
            name: params['walletName'],
            mnemonic: params['seed'],
            password: params['password']);
      } catch (e) {
        throw 'Error initializingWallet from mnemonic : $e';
      }
    case 'xprv':
      try {
        return await Wallet.fromXprvStr(
            walletType: isHdWallet ? WalletType.hd : WalletType.single,
            name: params['walletName'],
            xprv: params['seed'],
            password: params['password']);
      } catch (e) {
        throw 'Error initializingWallet from xprv : $e';
      }
    case 'encryptedXprv':
      try {
        return await Wallet.fromEncryptedXprv(
          walletType: isHdWallet ? WalletType.hd : WalletType.single,
          name: params['walletName'],
          xprv: params['seed'],
          password: params['password'],
        );
      } catch (e) {
        throw 'Error initializingWallet from encrypted xprv : $e';
      }
    default:
      throw 'Error initializingWallet: seedSource not supported';
  }
}

Xpub _generateKey(Map<String, dynamic> params) {
  int index = params['index'];
  String keytype = params['keyType'];
  if (keytype.endsWith('external')) {
    Xpub _xpub = Xpub.fromXpub(params['external_keychain']);
    return _xpub / index;
  } else if (keytype.endsWith('internal')) {
    Xpub _xpub = Xpub.fromXpub(params['internal_keychain']);
    return _xpub / index;
  } else if (keytype.endsWith('master')) {
    Xpub _xpub = Xpub.fromXpub(params['internal_keychain']);
    return _xpub / index;
  }
  throw 'Error genereting key: key type is not supported';
}

Future<Wallet> _generateKeys(Map<String, dynamic> params) async {
  Wallet dbWallet = params['wallet'];
  int _from = params['from'];
  int _to = params['to'];

  for (int i = _from; i <= _to; i++) {
    await dbWallet.generateKey(index: i, keyType: params['keyType']);
  }
  return dbWallet;
}

/// _signTranstion
/// [SendPort] [port] sends the message back to the receiver
/// [params] is a Map containing:
/// 'xprv' [String] AES.CBC encrypted XPRV
/// 'password' [String] used to decrypt the xprv
/// 'signers' [List] List<String> contains the paths of the signers
/// 'transaction_id' [String] the hash of the transaction.

Future<dynamic> _signTransaction(Map<String, dynamic> params) async {
  String password = params['password'];
  Map<String, dynamic> signers = params['signers'];
  String transactionId = params['transaction_id'];
  // storage for signatures
  List<KeyedSignature> signatures = [];

  Map<String, KeyedSignature> _sigMap = {};
  signers.forEach((encryptedXprv, paths) {
    Xprv masterXprv = Xprv.fromEncryptedXprv(encryptedXprv, password);

    paths.forEach((path) {
      /// ['M','3h','4919h','0h','0', ...]
      /// index 4 is the external[0] or internal[1] key path
      Xprv signer;
      if (path.contains("/")) {
        List<String> indexedPath = path.split('/');
        assert(indexedPath.length == 6, 'Path does not derive a valid Wallet');

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

        if (indexedPath.elementAt(4) == '0') {
          signer = externalXprv / int.parse(indexedPath.last);
        } else {
          assert(indexedPath.elementAt(4) == '1');
          signer = internalXprv / int.parse(indexedPath.last);
        }
      } else {
        /// master key
        assert(path == "m", "Invalid master path");
        signer = masterXprv;
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

  List<KeyedSignature> sigMap = [];
  signatures.forEach((element) {
    sigMap.add(element);
  });
  return sigMap;
}

Future<KeyedSignature> _signUnstakeBody(Map<String, dynamic> params) async {
  String password = params["password"];
  Map<String, dynamic> signerMap = params['signer'];
  Uint8List message = params['message'];
  assert(signerMap.length == 1);
  String encryptedXprv = signerMap.keys.first;
  String path = signerMap[encryptedXprv];
  Xprv masterXprv = Xprv.fromEncryptedXprv(encryptedXprv, password);
  Xprv signer;

  if (path.contains("/")) {
    List<String> indexedPath = path.split('/');
    assert(indexedPath.length == 6, 'Path does not derive a valid Wallet');
    if (indexedPath.elementAt(4) == '0') {
      signer = masterXprv /
          KEYPATH_PURPOSE /
          KEYPATH_COIN_TYPE /
          KEYPATH_ACCOUNT /
          EXTERNAL_KEYCHAIN /
          int.parse(indexedPath.last);
    } else {
      assert(indexedPath.elementAt(4) == '1');
      signer = masterXprv /
          KEYPATH_PURPOSE /
          KEYPATH_COIN_TYPE /
          KEYPATH_ACCOUNT /
          INTERNAL_KEYCHAIN /
          int.parse(indexedPath.last);
    }
  } else {
    assert(path == "m", "Invalid master path");
    signer = masterXprv;
  }

  KeyedSignature signature = signer.address
      .signHash(bytesToHex(sha256(data: message)), signer.privateKey);
  return signature;
}

Future<Map<String, dynamic>> _signMessage(Map<String, dynamic> params) async {
  String password = params["password"];
  Map<String, dynamic> signerMap = params['signer'];

  Map<String, dynamic> signedMessage = {};
  String address;
  String message = params['message'];
  assert(signerMap.length == 1);
  String encryptedXprv = signerMap.keys.first;
  String path = signerMap[encryptedXprv];
  Xprv masterXprv = Xprv.fromEncryptedXprv(encryptedXprv, password);
  Xprv signer;

  if (path.contains("/")) {
    List<String> indexedPath = path.split('/');
    assert(indexedPath.length == 6, 'Path does not derive a valid Wallet');
    if (indexedPath.elementAt(4) == '0') {
      signer = masterXprv /
          KEYPATH_PURPOSE /
          KEYPATH_COIN_TYPE /
          KEYPATH_ACCOUNT /
          EXTERNAL_KEYCHAIN /
          int.parse(indexedPath.last);
    } else {
      assert(indexedPath.elementAt(4) == '1');
      signer = masterXprv /
          KEYPATH_PURPOSE /
          KEYPATH_COIN_TYPE /
          KEYPATH_ACCOUNT /
          INTERNAL_KEYCHAIN /
          int.parse(indexedPath.last);
    }
  } else {
    assert(path == "m", "Invalid master path");
    signer = masterXprv;
  }

  address = signer.address.address;
  KeyedSignature signature = signer.address.signHash(
      bytesToHex(sha256(data: Uint8List.fromList(message.codeUnits))),
      signer.privateKey);

  String _formatBytes(List<int> data) =>
      "0x${bytesToHex(Uint8List.fromList(data))}";

  signedMessage["address"] = address;
  signedMessage["message"] = message;
  signedMessage["public_key"] = _formatBytes(signature.publicKey.publicKey);
  signedMessage["signature"] = _formatBytes(signature.signature.secp256k1.der);
  return signedMessage;
}

String _hashPassword(Map<String, dynamic> params) {
  return Password.hash(params['password']);
}

String _encryptXprv(Map<String, dynamic> params) {
  Xprv _xprv = Xprv.fromXprv(params['xprv']);
  return _xprv.toEncryptedXprv(password: params['password']);
}

String _decryptXprv(Map<String, dynamic> params) {
  Xprv _xprv = Xprv.fromEncryptedXprv(params['xprv'], params['password']);
  return _xprv.toSlip32();
}

bool _verifySheikahXprv(Map<String, dynamic> params) {
  try {
    Xprv.fromEncryptedXprv(params['xprv'], params['password']);
    return true;
  } catch (e) {
    return false;
  }
}

bool _verifyLocalXprv(Map<String, dynamic> params) {
  try {
    Xprv.fromEncryptedXprv(params['xprv'], Password.hash(params['password']));
    return true;
  } catch (e) {
    return false;
  }
}
