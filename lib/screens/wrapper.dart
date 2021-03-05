import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:walking_app/screens/home/home.dart';
import 'package:walking_app/screens/authanticate/authanticate.dart';
import 'package:walking_app/models/user.dart';

class Wrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    final user = Provider.of<User>(context);
    print(user);

    // return either home or authenticate
    if (user == null) {
      return Authenticate();
    } else {
      return Main();
    }
  }
}
