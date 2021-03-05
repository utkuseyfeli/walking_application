import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:walking_app/models/user.dart';
import 'package:walking_app/screens/authanticate/authanticate.dart';
import 'package:walking_app/screens/home/home.dart';
import 'package:walking_app/screens/wrapper.dart';
import 'package:walking_app/services/auth.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return StreamProvider<User>.value(
    catchError: (_, __) => null,
    value: AuthService().user,
      child: MaterialApp(
        home: Wrapper(),
      ),
    );
  }
}

