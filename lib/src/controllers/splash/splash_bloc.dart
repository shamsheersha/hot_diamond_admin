import 'package:bloc/bloc.dart';
part 'splash_event.dart';
part 'splash_state.dart';

class SplashBloc extends Bloc<SplashEvent, SplashState> {
  SplashBloc() : super(SplashState.initial()) {
    on<StartSplash>((event, emit)async {
      emit(state.copyWith(opacity: 1));
        await Future.delayed(const Duration(seconds: 4));
      emit(state.copyWith(isCompleted: true));
    });
  }
}