import 'package:flutter/material.dart';
import 'package:walking_app/services/auth.dart';

class Register extends StatefulWidget {

  final Function toggleView;
  Register({this.toggleView});

  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {

  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();

  String email = "";
  String password = "";
  String error = "";

  @override
  Widget build(BuildContext context) {

    return Scaffold(
          backgroundColor: Colors.amber,
          appBar: AppBar(
            backgroundColor: Colors.lightGreen,
            elevation: 0,
            title: Text("Register"),
            actions: [
              FlatButton.icon(
                icon: Icon(Icons.perm_identity),
                label: Text("Sign in"),
                onPressed: () {
                  widget.toggleView();
                },
              )
            ],
          ),
          body: Container(
            padding: EdgeInsets.symmetric(vertical: 20, horizontal: 50),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  SizedBox(height: 20,),
                  TextFormField(
                    validator: (val) => val.isEmpty ? "Enter an email" : null,
                    onChanged: (val) {
                      setState(() {
                        email = val;
                      });
                    },
                  ),
                  SizedBox(height: 20,),
                  TextFormField(
                    validator: (val) => val.length < 6 ? "Enter a password 6+ characters long" : null,
                    onChanged: (val) {
                      setState(() {
                        password = val;
                      });
                    },
                    obscureText: true,
                  ),
                  SizedBox(height: 20,),
                  RaisedButton(
                    color: Colors.lightGreen,
                    child: Text(
                      "Register",
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    onPressed: () async {
                      if (_formKey.currentState.validate()){
                        dynamic result = await _auth.registerWithEmail(email, password);
                        if(result == null) {
                          setState(() {
                            error = "please provide a valid email";
                          });
                        }
                      }
                    },
                  ),
                  SizedBox(height: 12,),
                  Text(
                    "$error",
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );

  }
}
