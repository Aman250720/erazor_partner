import 'package:erazor_partner/common/snackbar.dart';
import 'package:erazor_partner/controllers/firebase_controller.dart';
import 'package:erazor_partner/repositories/auth_repository.dart';
import 'package:erazor_partner/ui/MainScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authControllerProvider = StateNotifierProvider<AuthController, bool>(
  (ref) => AuthController(
      authRepository: ref.watch(authRepositoryProvider), ref: ref),
);

final authStateChangeProvider = StreamProvider((ref) {
  final authController = ref.watch(authControllerProvider.notifier);
  return authController.authStateChange;
});

class AuthController extends StateNotifier<bool> {
  final AuthRepository _authRepository;
  final Ref _ref;
  AuthController({required AuthRepository authRepository, required Ref ref})
      : _authRepository = authRepository,
        _ref = ref,
        super(false); // loading

  Stream<User?> get authStateChange => _authRepository.authStateChange;

  void signInWithGoogle(BuildContext context) async {
    state = true;
    final user = await _authRepository.signInWithGoogle();
    state = false;
    user.fold(
      (l) => showSnackBar(context, 'Some error occurred!'),
      (salon) {
        _ref.watch(salonDetailsProvider.notifier).update(
              (state) => salon,
            );
        showSnackBar(context, 'Login successful!');
      },
    );
  }

  void logout() async {
    _authRepository.logOut();
  }
}
