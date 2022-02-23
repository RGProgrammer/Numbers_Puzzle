import 'package:equatable/equatable.dart';

abstract class AssistantEvent extends Equatable {
  const AssistantEvent();

  @override
  List<Object> get props => [];
}

class ResetToIdle extends AssistantEvent {
  const ResetToIdle();
}

class ShowHelp extends AssistantEvent {
  const ShowHelp();
}

class ShowTutorial extends AssistantEvent {
  const ShowTutorial();
}
class PuzzleSolved extends AssistantEvent {
  const PuzzleSolved ();
}