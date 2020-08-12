import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app_flutter/models/http_exception.dart';
import 'package:shop_app_flutter/providers/auth.dart';
import 'package:shop_app_flutter/screens/products_overview_screen.dart';

enum AuthMode { Signup, Login }

class AuthScreen extends StatelessWidget {
  static const routeName = '/auth';

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF094D92), Color(0xFFF7B32B)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: [0.3, 1],
              ),
            ),
          ),
          SingleChildScrollView(
            child: Container(
              height: deviceSize.height,
              width: deviceSize.width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Flexible(
                    child: Container(
                      margin: EdgeInsets.only(bottom: 40.0),
                      padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 80.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: LinearGradient(
                          colors: [Color(0xFF252224), Color(0xFF1C1018)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          stops: [0, 1],
                        ),
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 8,
                            color: Colors.black26,
                            offset: Offset(0, 2),
                          )
                        ],
                      ),
                      child: Text(
                        'NW Shop',
                        style: TextStyle(
                          color: Theme.of(context).accentTextTheme.headline6.color,
                          fontSize: 35,
                          fontFamily: 'Anton',
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                  Flexible(
                    flex: deviceSize.width > 600 ? 2 : 1,
                    child: AuthCard(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AuthCard extends StatefulWidget {
  @override
  _AuthCardState createState() => _AuthCardState();
}

class _AuthCardState extends State<AuthCard> with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey();
  AuthMode _authMode = AuthMode.Login;
  Map<String, String> _authData = {'email': '', 'password': ''};
  var _isLoading = false;
  final _passwordController = TextEditingController();
  AnimationController _controller;
  Animation<Size> _heightAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: Duration(milliseconds: 300));
    _heightAnimation = Tween<Size>(
      begin: Size(double.infinity, 260),
      end: Size(double.infinity, 320),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.fastOutSlowIn));
    // _heightAnimation.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  void _showError(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('An Error Ocurred'),
        content: Text(message),
        actions: [
          FlatButton(
            child: Text('Okay'),
            onPressed: () => Navigator.of(context).pop(),
          )
        ],
      ),
    );
  }

  Future<void> _submit() async {
    final authProvider = Provider.of<Auth>(context, listen: false);
    if (!_formKey.currentState.validate()) {
      // Invalid!
      return;
    }
    _formKey.currentState.save();
    setState(() => _isLoading = true);
    try {
      if (_authMode == AuthMode.Login) {
        await authProvider.singIn(
          _authData['email'],
          _authData['password'],
        );
      } else {
        await authProvider.singUp(
          _authData['email'],
          _authData['password'],
        );
      }
      Navigator.of(context).pushReplacementNamed(ProductsOverviewScreen.routeName);
    } on HttpException catch (e) {
      String errorMessage = 'Authentication failed';
      if (e.toString().contains('EMAIL_EXISTS')) {
        errorMessage = 'This email address is already in use';
      } else if (e.toString().contains('INVALID_EMAIL')) {
        errorMessage = 'Invalid email';
      } else if (e.toString().contains('WEAK_PASSWORD')) {
        errorMessage = 'This password is too weak';
      } else if (e.toString().contains('EMAIL_NOT_FOUND')) {
        errorMessage = 'Email not found';
      } else if (e.toString().contains('INVALID_PASSWORD')) {
        errorMessage = 'Invalid password';
      }
      _showError(errorMessage);
    } catch (e) {
      final errorMessage = 'Couldn\'t autenticate you. PLease try again later';
      _showError(errorMessage);
    }
    setState(() => _isLoading = false);
  }

  void _switchAuthMode() {
    if (_authMode == AuthMode.Login) {
      setState(() => _authMode = AuthMode.Signup);
      _controller.forward();
    } else {
      setState(() => _authMode = AuthMode.Login);
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      elevation: 8.0,
      child: AnimatedBuilder(
        animation: _heightAnimation,
        builder: (context, child) => Container(
          height: _heightAnimation.value.height,
          constraints: BoxConstraints(minHeight: _heightAnimation.value.height),
          width: deviceSize.width * 0.75,
          padding: EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  TextFormField(
                    decoration: InputDecoration(labelText: 'E-Mail'),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value.isEmpty || !value.contains('@')) {
                        return 'Invalid email!';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _authData['email'] = value;
                    },
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Password'),
                    obscureText: true,
                    controller: _passwordController,
                    validator: (value) {
                      if (value.isEmpty || value.length < 5) {
                        return 'Password is too short!';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _authData['password'] = value;
                    },
                  ),
                  if (_authMode == AuthMode.Signup)
                    TextFormField(
                      enabled: _authMode == AuthMode.Signup,
                      decoration: InputDecoration(labelText: 'Confirm Password'),
                      obscureText: true,
                      validator: _authMode == AuthMode.Signup
                          ? (value) {
                              if (value != _passwordController.text) {
                                return 'Passwords do not match!';
                              }
                              return null;
                            }
                          : null,
                    ),
                  SizedBox(height: 20),
                  _isLoading
                      ? CircularProgressIndicator()
                      : RaisedButton(
                          child: Text(_authMode == AuthMode.Login ? 'LOGIN' : 'SIGN UP'),
                          onPressed: _submit,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 8.0),
                          color: Theme.of(context).primaryColor,
                          textColor: Colors.white,
                        ),
                  FlatButton(
                    child: Text('${_authMode == AuthMode.Login ? 'SIGNUP' : 'LOGIN'} INSTEAD'),
                    onPressed: _switchAuthMode,
                    padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 4),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    textColor: Theme.of(context).primaryColor,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
