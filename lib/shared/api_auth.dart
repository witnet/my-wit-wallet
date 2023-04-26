import 'package:my_wit_wallet/shared/api_database.dart';
import 'package:my_wit_wallet/shared/locator.dart';
import 'package:my_wit_wallet/util/storage/database/database_service.dart';
import 'package:witnet/witnet.dart' show Xprv;
import 'package:quiver/core.dart' show hash2;

class WalletData {
  WalletData();
  late String name;
  late Xprv masterKey;

  @override
  String toString() {
    // TODO: implement toString
    return '$runtimeType($name, )';
  }

  @override
  bool operator ==(Object other) {
    if (other is WalletData) {
      return name == other.name;
    }
    return false;
  }

  // hashCode needs an override if the == operator is used
  @override
  int get hashCode => hash2(name, 'wit$name');
}

class AuthException {
  final int code;
  final String message;
  AuthException({required this.code, required this.message});

  @override
  String toString() =>
      '{"AuthException": {"code": $code, "message": "$message"}}';
}

class ApiAuth {
  late String _walletName;
  String get walletName => _walletName;

  Future<Map<String, dynamic>> unlockWallet({required String password}) async {
    /// get database bloc
    try {
      final tmp = Locator.instance.get<ApiDatabase>();
      return {'result': tmp};
    } on DBException catch (e) {
      throw AuthException(code: e.code, message: e.message);
    } on DatabaseException catch (e) {
      throw AuthException(code: e.code, message: e.message);
    }
  }

  void setWalletName(String name) {
    _walletName = name;
  }

  Future logout() async {
    Locator.instance.get<ApiDatabase>().lockDatabase();
    await Future.delayed(Duration(seconds: 1));
  }
}
