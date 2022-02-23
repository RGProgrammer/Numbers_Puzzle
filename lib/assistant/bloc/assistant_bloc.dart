import 'package:bloc/bloc.dart';
import 'package:numbers_puzzle/assistant/bloc/assistant_event.dart';
import 'package:numbers_puzzle/assistant/bloc/assistant_state.dart';

class AssistantBloc extends Bloc<AssistantEvent, AssistantState> {
  AssistantBloc() : super(const AssistantState(current: State.idle)) {
    on<ResetToIdle>(_reset);
    on<ShowHelp>(_showHelp);
    on<ShowTutorial>(_showTutorial);
  }

  void _reset(ResetToIdle event, Emitter<AssistantState> emit) {
    emit(const AssistantState(current : State.idle));
  }
  void _showHelp(ShowHelp event, Emitter<AssistantState> emit) {
    emit(const AssistantState(current : State.helpSeggestions));
  }
  void _showTutorial(ShowTutorial event, Emitter<AssistantState> emit) {
    emit(const AssistantState(current : State.tutorial));
  }
}
