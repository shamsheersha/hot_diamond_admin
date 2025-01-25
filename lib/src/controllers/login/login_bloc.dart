import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'login_event.dart';
import 'login_state.dart';


class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc() : super(LoginInitial()) {
    on<LoginButtonPressed>(_onLoginButtonPressed);
    on<LogoutEvent>(_onLogoutEvent);
  }

  // Handle login logic
  Future<void> _onLoginButtonPressed(
      LoginButtonPressed event, Emitter<LoginState> emit) async {
    emit(LoginLoading());


    // Simulate delay for loading
    await Future.delayed(const Duration(seconds: 1));

    if (event.username == 'hotdiamonduser' &&
        event.password == 'hotdiamonduser') {
          log('lodded');
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('isLoggedIn',true);
      emit(LoginSuccess());

    } else {
      emit(LoginFailure("Invalid username or password."));
    }
  }



  // Handle logout logic
  Future<void> _onLogoutEvent(LogoutEvent event, Emitter<LoginState> emit) async {
   
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn',false);
    // Emit logged out state
    emit(LoggedOut());
  }
}
