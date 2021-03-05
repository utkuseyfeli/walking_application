import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:walking_app/models/userData.dart';
import 'package:walking_app/screens/home/userData_tile.dart';
import 'package:walking_app/services/auth.dart';
import 'package:walking_app/models/user.dart';
import 'package:walking_app/services/database.dart';

class UserDataList extends StatefulWidget {
  @override
  _UserDataListState createState() => _UserDataListState();
}

class _UserDataListState extends State<UserDataList> {
  String userName;
  AuthService auth = AuthService();
  User user;
  DatabaseService dbase;
  UserData data;

  sortTheDataBase() async{
    user = await auth.getUser();
    dbase = DatabaseService(uid: user.uid);
  }

  @override
  void initState() {
    super.initState();
    sortTheDataBase();
  }

  @override
  Widget build(BuildContext context) {

    final userData = Provider.of<List<UserData>>(context) ?? [];

    // sorting the database
    if(userData != null) {
        // bubble sort used
        dynamic size = userData.length;
        for (int i = 0; i < size - 1; i++) {
          for (int j = 0; j < size - i - 1; j++) {
            if (userData[j].score < userData[j + 1].score) {
              UserData temp = userData[j];
              userData[j] = userData[j + 1];
              userData[j + 1] = temp;
            }
          }
        }
    }


    void _showSettingsPanel() {
      showModalBottomSheet(context: context, builder: (context) {
        return Container(
          padding: EdgeInsets.symmetric(vertical: 20, horizontal: 60),
          child: Column(
            children: [
              Center(
                child: Text(
                  "Update the username",
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
              ),
              TextFormField(
              onChanged: (val) {
                userName = val;
              },
            ),
              SizedBox(height: 10,),
              FlatButton(
                onPressed: () async {
                  int position = 0;
                  double score;
                  userData.forEach((element) {
                    if(element.uid == dbase.uid){
                      position++;
                      score = element.score;
                    }
                  });
                  dbase.updateUserData(score, userName);
                },
                child: Text(
                  "Update",
                ),
                color: Colors.lightGreen,
              ),

          ],
          ),

        );
      });
    }

    return Scaffold(
      backgroundColor: Colors.blue,
      appBar: AppBar(
        title: Text("Leader Board"),
        backgroundColor: Colors.lightGreen,
        actions: [
          FlatButton.icon(
            icon: Icon(Icons.settings),
            label: Text("Settings"),
            onPressed: () => _showSettingsPanel(),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: userData.length < 7 ? userData.length : 7,
        itemBuilder: (context, index) {
          return UserDataTile(userData: userData[index]);
        },
      ),
    );
  }
}
