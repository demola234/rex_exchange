import 'dart:developer';

import 'package:exchange_mobile/core/components/overlay_loader.dart';
import 'package:exchange_mobile/core/injector/injector.dart';
import 'package:exchange_mobile/domain/repositories/repositories.dart';
import 'package:exchange_mobile/presentation/notifier/states/login_state.dart';
import 'package:exchange_mobile/presentation/screens/create_wallet_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoginControllerNotifier extends StateNotifier<LoginState> {
  LoginControllerNotifier(
    this._repository,
  ) : super(const LoginState.initial()) {
    getUserDetails();
  }

  final Repository _repository;

  Future<void> googleAuth({
    required BuildContext context,
  }) async {
    context.showOverlay();
    state = const LoginState.authenticatingUser();

    final result = await _repository.googleAuth();
    result.fold((failure) {
      context.hide();

      state = LoginState.error(error: failure.toString());
    }, (user) {
      context.hide();
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => const CreateWalletScreen()));

      // context.showToast(
      //   title: user.message,
      //   toastDurationInSeconds: 5,
      //   isSuccess: true,
      // );
      // state = LoginState.signUpSuccess(data: user);
    });
  }

  // Get User Details
  getUserDetails() async {
    state = const LoginState.authenticatingUser();

    final result = await _repository.getUserDetails();

    result.fold((failure) {
      state = LoginState.error(error: failure.toString());
    }, (user) {
      log(user.displayName!);
      state = LoginState.authenticated(userDetails: user);
    });
  }
}

Repository repository = sl<Repository>();

final loginUserNotifierController =
    StateNotifierProvider<LoginControllerNotifier, LoginState>(
  (ref) => LoginControllerNotifier(repository),
);
