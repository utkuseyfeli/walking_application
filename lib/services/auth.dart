import 'package:firebase_auth/firebase_auth.dart';
import 'package:walking_app/models/user.dart';
import 'package:walking_app/services/database.dart';

class AuthService{

  final FirebaseAuth _auth = FirebaseAuth.instance;

  // create user obj
  User _userFromFirebaseUser( FirebaseUser user ){
    return user != null ? User(uid: user.uid) : null;
  }

  // auth change user stream
  Stream<User> get user {
    return _auth.onAuthStateChanged
        .map(_userFromFirebaseUser);
  }

  // sign in anon
  Future signInAnon() async{
    try{
      AuthResult result = await _auth.signInAnonymously();
      FirebaseUser user = result.user;
      return _userFromFirebaseUser(user);
    } catch(e){
      print(e.toString());
      return null;
    }
  }

  // register with mail
  Future registerWithEmail(String email, String password) async {
    try {
      AuthResult result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      FirebaseUser user = result.user;

      // creating a database for user
      await DatabaseService(uid: user.uid).updateUserData(0, "new user");
      return _userFromFirebaseUser(user);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  // sign in with mail
  Future singInWithEmail(String email, String password) async {
    try {
      AuthResult result = await _auth.signInWithEmailAndPassword(email: email, password: password);
      FirebaseUser user = result.user;
      return _userFromFirebaseUser(user);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  // sign out
  Future signOut() async {

    try {
      return await _auth.signOut();
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future<User> getUser() async{
    try {
      FirebaseUser user = await _auth.currentUser();
      return _userFromFirebaseUser(user);
    } catch(e) {
      print(e.toString());
      return null;
    }
  }

}