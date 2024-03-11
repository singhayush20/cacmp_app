import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  static const String _keyIsLoggedIn = 'isLoggedIn';
  static const String _keyUserToken = 'userToken';
  static const String _accessToken="accessToken";
  static const String _refreshToken="refreshToken";
  static const String _username="username";
  // static const String _userId='userId';

  final _secureStorage = const FlutterSecureStorage();

  Future<void> writeIsLoggedIn(bool isLoggedIn) async {
    await _secureStorage.write(
        key: _keyIsLoggedIn, value: isLoggedIn.toString());
  }

  Future<bool> readIsLoggedIn() async {
    final value = await _secureStorage.read(key: _keyIsLoggedIn);
    return value == 'true';
  }


  Future<void> writeUserToken(String token) async {
    await _secureStorage.write(key: _keyUserToken, value: token);
  }

  Future<String?> readUserToken() async {
    return await _secureStorage.read(key: _keyUserToken);
  }

  Future<void> deleteOnLogOut() async {
    await _secureStorage.deleteAll();
  }

  Future<void> writeAccessToken(String token) async {
    await _secureStorage.write(key: _accessToken, value: token);
  }

  Future<String?> readAccessToken() async {
    return await _secureStorage.read(key: _accessToken);
  }


  Future<void> writeRefreshToken(String token) async {
    await _secureStorage.write(key: _refreshToken, value: token);
  }

  Future<String?> readRefreshToken() async {
    return await _secureStorage.read(key: _refreshToken);
  }

  Future<void> writeUsername(String username) async {
     await _secureStorage.write(key: _username, value: username);
  }

  Future<String?> readUsername() async {
    return await _secureStorage.read(key: _username);
  }

}
