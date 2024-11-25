part of 'splash_bloc.dart';

 class SplashState  {
  final double opacity;
  final bool isCompleted;

  const SplashState({required this.opacity, required this.isCompleted});
  // Helper to create the initial state
  factory SplashState.initial()=> const SplashState(opacity: 0.0,isCompleted: false);
  
  //Copy state to update opacity or completion status
  SplashState copyWith({double? opacity,bool? isCompleted}){
    return SplashState(opacity: opacity ?? this.opacity, isCompleted: isCompleted ?? this.isCompleted);
  }
}
