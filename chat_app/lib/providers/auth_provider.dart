import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:chat_app/cores/api_path.dart';
import 'package:chat_app/cores/base_url.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart';

class AuthProvider with ChangeNotifier, DiagnosticableTreeMixin {
  String _token;
  String _firstName;
  String _userId;

  String get token => _token;

  String get firstName => _firstName;

  String get userId => _userId;

  Future<void> login(String email, String password) async {
    try {
      final res = await post(
        Uri.https(
          BaseUrl.baseUrl,
          ApiPath.login,
        ),
        body: {
          'username': email,
          'password': password,
        },
      );
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        this._token = data['data']['token'];
        this._firstName = data['data']['first_name'];
        this._userId = data['data']['userid'];
        log(_token, name: 'token');
        log(_firstName, name: 'userName');
        notifyListeners();
      }
    } on Exception catch (e) {
      log(e.toString(), error: e);
    }
  }

  Future<void> updateFirebaseToken(String tokenId) async {
    try {
      final header = {
        HttpHeaders.contentTypeHeader: 'application/json',
        'auth-token': _token
      };

      final res = await post(
        Uri.https(
          BaseUrl.baseUrl,
          ApiPath.updateFirebaseToken,
        ),
        headers: header,
        body: json.encode({
          'tokenid': tokenId,
        }),
      );
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        log(data['message'], name: 'update firebase token');
        notifyListeners();
      }
    } on Exception catch (e) {
      log(e.toString(), error: e);
    }
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('token', _token));
  }
}
