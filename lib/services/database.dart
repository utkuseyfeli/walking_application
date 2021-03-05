import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:walking_app/models/userData.dart';

class DatabaseService{

  final String uid;
  DatabaseService( {this.uid} );

  // collection reference
  final CollectionReference collection = Firestore.instance.collection("userData");
  
  Future updateUserData(double score, String name) async {
    return await collection.document(uid).setData({
      "score": score,
      "name": name,
      "uid": uid
    });
  }

  // userData list from snapshot
  List<UserData> _userDataListFromSnapshot(QuerySnapshot snapshot){
    return snapshot.documents.map((doc) {
      return UserData(
        name: doc.data["name"] ?? "",
        score: doc.data["score"] ?? 0,
        uid: doc.data["uid"] ?? null
      );
    }).toList();
  }

  // this sort uses bubble sort algorithm
  List<UserData> sort(List<UserData> userData) {
    if (userData != null){
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
  }

  // get userData stream
  Stream<List<UserData>> get userData {
    return collection.snapshots()
        .map(_userDataListFromSnapshot);
  }
}