import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Dilempar ketika proses Google Sign-In gagal karena error nyata
/// (mis. konfigurasi salah, jaringan, atau SHA-1 belum terdaftar).
/// Pembatalan oleh user TIDAK dianggap error — lihat [GoogleAuthService].
class GoogleSignInException implements Exception {
  GoogleSignInException(this.message);

  final String message;

  @override
  String toString() => 'GoogleSignInException: $message';
}

class GoogleAuthService {
  GoogleAuthService._();
  static final GoogleAuthService instance = GoogleAuthService._();

  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Menjalankan alur Google Sign-In lalu mengembalikan **Firebase ID token**
  /// untuk dikirim ke backend Laravel.
  ///
  /// Mengembalikan `null` HANYA bila user membatalkan dialog pemilihan akun.
  /// Bila terjadi error nyata, melempar [GoogleSignInException] agar pesan
  /// error yang ditampilkan akurat (bukan "dibatalkan").
  Future<String?> signInAndGetIdToken() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null; // user membatalkan

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);

      final idToken = await userCredential.user?.getIdToken();
      if (idToken == null) {
        throw GoogleSignInException('Gagal mengambil token Google.');
      }
      return idToken;
    } on FirebaseAuthException catch (e) {
      throw GoogleSignInException(e.message ?? 'Autentikasi Google gagal.');
    } on GoogleSignInException {
      rethrow;
    } catch (e) {
      throw GoogleSignInException('Gagal login dengan Google. Coba lagi.');
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}
