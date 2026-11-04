import 'package:flutter_bloc/flutter_bloc.dart';

/// Global voice toggle state for map navigation instructions.
class NavigationVoiceCubit extends Cubit<bool> {
  NavigationVoiceCubit() : super(false);

  bool get isMuted => state;

  void toggleMute() => emit(!state);

  void mute() => emit(true);

  void unmute() => emit(false);
}
