import 'package:flutter/material.dart';
import 'package:walking_app/models/userData.dart';

class UserDataTile extends StatelessWidget {

  final UserData userData;
  UserDataTile({this.userData});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 8),
      child: Card(
        margin: EdgeInsets.fromLTRB(20, 6, 20, 0),
        child: ListTile(
          leading: CircleAvatar(
            radius: 25,
            backgroundColor: Colors.lightGreen,
          ),
          title: Text(userData.name),
          subtitle: Text("Score: ${userData.score}"),
        ),
      ),
    );
  }
}
