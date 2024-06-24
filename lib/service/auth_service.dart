import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  User? _user;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get user {
    return _user;
  }

  AuthService() {
    _firebaseAuth.authStateChanges().listen(authStateChangesStreamListener);
  }

  Future<bool> login(String email, String password) async {
    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        _user = credential.user;
      }
      return true;
    } catch (e) {
      print(e);
    }
    return false;
  }

  Future<bool> signup(String email, String password) async {
    try {
      // Create a new user account with email and password
      final credential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        // User successfully signed up
        _user = credential.user;
        return true;
      } else {
        // Handle error
        return false;
      }
    } catch (e) {
      // Handle exception
      print(e);
      return false;
    }
  }

  Future<bool> logout() async {
    try {
      await _firestore.collection('tokens').doc(user!.uid).update({
        'is_online': false,
        'last_active': DateTime.now().millisecondsSinceEpoch.toString(),
      });
      await _firebaseAuth.signOut();

      return true;
    } catch (e) {
      print(e);
    }
    return false;
  }

  void authStateChangesStreamListener(User? user) {
    if (user != null) {
      _user = user;
    } else {
      _user = null;
    }
  }
  //it determines in  initial route which page they will go .if it becomes null then backto login page
}
