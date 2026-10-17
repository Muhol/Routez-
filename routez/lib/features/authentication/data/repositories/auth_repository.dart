import 'package:firebase_auth/firebase_auth.dart';
import 'user_profile_repository.dart';
import '../models/user_profile_model.dart';

class AuthRepository {
  final FirebaseAuth _firebaseAuth;
  final UserProfileRepository _userProfileRepository;

  AuthRepository({
    FirebaseAuth? firebaseAuth,
    UserProfileRepository? userProfileRepository,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _userProfileRepository =
            userProfileRepository ?? UserProfileRepository();

  /// Stream of user authentication state changes
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  /// Get current user
  User? get currentUser => _firebaseAuth.currentUser;

  /// Sign in with Email & Password
  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      return await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  /// Sign up with Email & Password and initialize user profile document in Firestore
  Future<UserCredential> signUpWithEmail({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (credential.user != null) {
        if (fullName.isNotEmpty) {
          await credential.user!.updateDisplayName(fullName);
        }

        // Create profile document in Firestore
        final profile = UserProfile(
          uid: credential.user!.uid,
          displayName: fullName.isNotEmpty ? fullName : 'Commuter',
          email: email,
        );
        await _userProfileRepository.createProfile(profile);
      }
      return credential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  /// Send Password Reset Email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  /// Sign Out
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  /// Convert Firebase Auth exception codes into user-friendly messages
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email address.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'weak-password':
        return 'The password provided is too weak (min 6 chars).';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'too-many-requests':
        return 'Too many failed attempts. Please try again later.';
      case 'CONFIGURATION_NOT_FOUND':
      case 'operation-not-allowed':
        return 'Email/Password authentication is disabled in your Firebase Console. Enable it under Authentication > Sign-in method.';
      default:
        return e.message ?? 'An unexpected authentication error occurred.';
    }
  }
}
