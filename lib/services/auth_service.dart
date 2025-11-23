import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);

  // Get current user
  GoogleSignInAccount? get currentUser => _googleSignIn.currentUser;

  // Sign in with Google
  Future<GoogleSignInAccount?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? account = await _googleSignIn.signIn();
      return account;
    } catch (error) {
      print('Error signing in with Google: $error');
      return null;
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _googleSignIn.signOut();
  }

  // Check if user is signed in
  bool isSignedIn() {
    return _googleSignIn.currentUser != null;
  }

  // Silent sign in (auto login)
  Future<GoogleSignInAccount?> signInSilently() async {
    try {
      return await _googleSignIn.signInSilently();
    } catch (error) {
      print('Error signing in silently: $error');
      return null;
    }
  }
}
