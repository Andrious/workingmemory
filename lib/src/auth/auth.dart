import 'dart:async';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';



class Auth {
  
  static init() {

    if(_auth == null){

      _auth = FirebaseAuth.instance;

      _googleSignIn = GoogleSignIn();
    }
  }

  static dispose(){

    _auth = null;

    _googleSignIn = null;

  }

  static FirebaseAuth _auth;

  static GoogleSignIn _googleSignIn;

  static FirebaseUser _user;
  get user => _user;


  static Future<String> signInAnonymously() async {

    final currentUser = await _auth.currentUser();
    if(_user?.uid == currentUser.uid) return _user.uid;

    var user = await _auth.signInAnonymously();
    assert(user != null);
    assert(user.isAnonymous);
    assert(!user.isEmailVerified);
    assert(await user.getIdToken() != null);

    if (Platform.isIOS) {
      // Anonymous auth doesn't show up as a provider on iOS
      assert(user.providerData.isEmpty);
    } else if (Platform.isAndroid) {

      // Anonymous auth does show up as a provider on Android
      assert(user.providerData.length == 1);
      assert(user.providerData[0].providerId == 'firebase');
      assert(user.providerData[0].uid != null);
      assert(user.providerData[0].displayName == null);
      assert(user.providerData[0].photoUrl == null);
      assert(user.providerData[0].email == null);
    }
    
    _user = user;
    return user.uid;
  }


  static Future<String> signInWithGoogle() async {

    var currentUser = await _auth.currentUser();
    if(_user?.uid == currentUser.uid) return _user.uid;

    final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
    final GoogleSignInAuthentication googleAuth =
    await googleUser.authentication;

    var user = await _auth.signInWithGoogle(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    
    assert(user.email != null);
    assert(user.displayName != null);
    assert(!user.isAnonymous);
    assert(await user.getIdToken() != null);

    currentUser = await _auth.currentUser();
    assert(user.uid == currentUser.uid);
    _user = user;
    return user.uid;
  }

  static bool isSignedIn() => _auth?.currentUser() != null;

  static bool isLoggedIn() => _user != null;

  static signOut() => _auth.signOut();

  static String userProfile(String type) {
    return getProfile(_user, type);
  }

  static String getProfile(FirebaseUser user, String type) {
    if (user == null) {
      return '';
    }

    if (type == null) {
      return '';
    }

    String info = '';

    String holder = '';

    // Always return 'the last' available item.
    for (UserInfo profile in user.providerData.reversed) {
      switch (type.trim().toLowerCase()) {
        case "provider":
          holder = profile.providerId;

          break;
        case "userid":
          holder = profile.uid;

          break;
        case "name":
          holder = profile.displayName;

          break;
        case "email":
          holder = profile.email;

          break;
        case "photo":
          try {
            holder = profile.photoUrl.toString();
          } catch (ex) {
            holder = "";
          }

          break;
        default:
          holder = "";
      }

      if (holder != null && holder.isNotEmpty) {
        info = holder;
      }
    }

    return info;
  }


  static String getUid(){

    String userId;

    var user = getUser();

    if (user == null){

      userId = null;
    }else{

      userId = user.uid;
    }

    return userId;
  }


  static FirebaseUser getUser() {

    return _user;
  }


  static String userEmail(){

    return _user?.email;
  }



  static String userName(){

    return _user?.displayName;
  }



  static String userPhoto(){

    return _user?.photoUrl;
  }
}