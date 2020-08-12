import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shop_app_flutter/models/http_exception.dart';

class Auth with ChangeNotifier {
  String _token;
  DateTime _expiryDate;
  String _userId;
  Timer _authTimer;
  static const _key = 'AIzaSyDADZH0BLG_fkV9PJsIvVyEVTbAoiWeReY';

  bool get isAuth {
    return token != null;
  }

  String get userId => _userId;

  String get token {
    if (_expiryDate != null && _expiryDate.isAfter(DateTime.now()) && _token != null) {
      return _token;
    } else {
      return null;
    }
  }

  Future<void> _authenticate(String email, String password, String segment) async {
    final _url = 'https://identitytoolkit.googleapis.com/v1/accounts:$segment?key=$_key';
    try {
      final response = await http.post(
        _url,
        body: json.encode({'email': email, 'password': password, 'returnSecureToken': true}),
      );
      final responseData = json.decode(response.body);
      if (responseData['error'] != null) {
        throw HttpException(responseData['error']['message']);
      } else {
        _token = responseData['idToken'];
        _userId = responseData['localId'];
        _expiryDate = DateTime.now().add(Duration(seconds: int.parse(responseData['expiresIn'])));
        _autoLogout();
        final prefs = await SharedPreferences.getInstance();
        final userData = json.encode({
          'token': _token,
          'userId': _userId,
          'expiryDate': _expiryDate.toIso8601String(),
        });
        prefs.setString('userData', userData);
        notifyListeners();
      }
    } catch (e) {
      throw e;
    }
  }

  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('userData')) {
      return false;
    } else {
      final extractedUserData = json.decode(prefs.getString('userData')) as Map<String, Object>;
      final expiryDate = DateTime.parse(extractedUserData['expiryDate']);
      if (expiryDate.isBefore(DateTime.now())) {
        return false;
      } else {
        _token = extractedUserData['token'];
        _userId = extractedUserData['userId'];
        _expiryDate = expiryDate;
        notifyListeners();
        _autoLogout();
        return true;
      }
    }
  }

  Future<void> singUp(String email, String password) async {
    return _authenticate(email, password, 'signUp');
  }

  Future<void> singIn(String email, String password) async {
    return _authenticate(email, password, 'signInWithPassword');
  }

  Future<void> logOut() async{
    _token = null;
    _expiryDate = null;
    _userId = null;
    if (_authTimer != null) {
      _authTimer.cancel();
      _authTimer = null;
    }
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    prefs.clear();
  }

  void _autoLogout() {
    if (_authTimer != null) {
      _authTimer.cancel();
    }
    final time = _expiryDate.difference(DateTime.now()).inSeconds;
    _authTimer = Timer(Duration(seconds: time), logOut);
  }
}
