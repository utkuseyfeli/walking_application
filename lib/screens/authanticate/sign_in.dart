import 'package:flutter/material.dart';
import 'package:walking_app/services/auth.dart';

class SignIn extends StatefulWidget {

  final Function toggleView;
  SignIn({this.toggleView});

  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {

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
        title: Text("Sign In"),
        actions: [
          FlatButton.icon(
            icon: Icon(Icons.person_add),
            label: Text("Register"),
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
                  "Sign in",
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
                onPressed: () async {
                  if (_formKey.currentState.validate()){
                    dynamic result = await _auth.singInWithEmail(email, password);

                    if(result == null) {
                      setState(() {
                        error = "email or password is incorrect";
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
