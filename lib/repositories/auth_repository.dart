import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';

abstract class BaseAuthRepository {
  Stream<User?> get authStateChanges;
  Future<UserCredential?> signUp(String email, String password);
  Future<UserCredential?> signIn(String email, String password);
  Future<UserCredential?> signInWithGoogle();
  Future<void> signOut();
}

class AuthRepository implements BaseAuthRepository {
  FirebaseAuth? _authInstance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  FirebaseAuth get _auth {
    try {
      _authInstance ??= FirebaseAuth.instance;
      return _authInstance!;
    } catch (e) {
      throw Exception('Firebase not initialized.');
    }
  }

  @override
  Stream<User?> get authStateChanges {
    try {
      return _auth.authStateChanges();
    } catch (e) {
      debugPrint('AuthRepository: Stream error $e');
      return Stream.value(null);
    }
  }

  @override
  Future<UserCredential?> signUp(String email, String password) async {
    return await _auth.createUserWithEmailAndPassword(email: email, password: password);
  }

  @override
  Future<UserCredential?> signIn(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  @override
  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      return await _auth.signInWithCredential(credential);
    } catch (e) {
      debugPrint('Google Sign-In Error: $e');
      rethrow;
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
    } catch (_) {}
  }
}

class MockAuthRepository implements BaseAuthRepository {
  final _stateController = StreamController<User?>.broadcast();

  @override
  Stream<User?> get authStateChanges {
    // Immediate emission of null
    return _stateController.stream.asyncStart(() => null);
  }

  @override
  Future<UserCredential?> signUp(String email, String password) async => null;
  @override
  Future<UserCredential?> signIn(String email, String password) async => null;
  @override
  Future<UserCredential?> signInWithGoogle() async => null;
  @override
  Future<void> signOut() async => _stateController.add(null);
}

extension _StreamStartWith<T> on Stream<T> {
  Stream<T> asyncStart(FutureOr<T> Function() initial) async* {
    yield await initial();
    yield* this;
  }
}
