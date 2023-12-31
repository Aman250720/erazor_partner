import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:erazor_partner/common/failure.dart';
import 'package:erazor_partner/common/type_defs.dart';
import 'package:erazor_partner/models/salon_details.dart';
import 'package:erazor_partner/providers/firebase_providers.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:google_sign_in/google_sign_in.dart';

final authRepositoryProvider = Provider(
  (ref) => AuthRepository(
    firestore: ref.read(firestoreProvider),
    auth: ref.read(authProvider),
    googleSignIn: ref.read(googleSignInProvider),
  ),
);

class AuthRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;

  AuthRepository({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
    required GoogleSignIn googleSignIn,
  })  : _auth = auth,
        _firestore = firestore,
        _googleSignIn = googleSignIn;

  Stream<User?> get authStateChange => _auth.authStateChanges();
  CollectionReference get _salons => _firestore.collection('salons');

  FutureEither<SalonDetails> signInWithGoogle() async {
    try {
      UserCredential userCredential;
      if (kIsWeb) {
        GoogleAuthProvider googleProvider = GoogleAuthProvider();

        googleProvider
            .addScope('https://www.googleapis.com/auth/contacts.readonly');

        userCredential = await _auth.signInWithPopup(googleProvider);
      } else {
        final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

        final GoogleSignInAuthentication? googleAuth =
            await googleUser?.authentication;

        //if (googleAuth?.accessToken != null && googleAuth?.idToken != null) {
        // Create a new credential
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth?.accessToken,
          idToken: googleAuth?.idToken,
        );

        userCredential = await _auth.signInWithCredential(credential);
      }

      SalonDetails salon;

      if (userCredential.additionalUserInfo!.isNewUser) {
        salon = SalonDetails(
            cid: userCredential.user!.uid,
            salonName: '',
            ownerName: '',
            mobileNumber: 0,
            gpsLocation: '',
            state: '',
            city: '',
            address: '',
            pincode: 0,
            openingTime: '',
            closingTime: '',
            slotInterval: 0,
            seatingCapacity: 0,
            genderType: '',
            token: '',
            employees: []);

        await _salons.doc(userCredential.user!.uid).set(salon.toMap());
      } else {
        salon = await fetchR(userCredential.user!.uid).first;
      }

      return right(salon);
    } on FirebaseAuthException catch (e) {
      throw e.message!; // Displaying the error message
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  Stream<SalonDetails> fetchR(String uid) {
    return _salons.doc(uid).snapshots().map(
        (event) => SalonDetails.fromMap(event.data() as Map<String, dynamic>));
  }

  void logOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}
