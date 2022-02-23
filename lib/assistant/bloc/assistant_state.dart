import 'package:equatable/equatable.dart';
enum State {
    idle ,
    helpSeggestions,
    tutorial,
    congratulate,

  }
class AssistantState extends Equatable {
  
  final State current ;
  const AssistantState({this.current= State.idle});
  @override
  List<Object?> get props => [current] ;
}