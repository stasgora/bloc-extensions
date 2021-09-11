import 'package:bloc/bloc.dart';
import 'package:stateful_bloc/stateful_bloc.dart';

class SimpleBlocObserver extends BlocObserver {
  @override
  void onEvent(Bloc bloc, Object? event) {
    super.onEvent(bloc, event);
    print('onEvent: ${bloc.runtimeType}, event: $event');
  }

  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    print('onChange: ${bloc.runtimeType}, change: $change');
  }
}

class TestCubit extends Cubit<StatefulState<int>> with StatefulCubit {
  TestCubit() : super(StatefulState(data: 0));

  void successfullyLoad() => load(body: () => Outcome.finished(1));

  void failToSubmit() => submit(body: () => Outcome.failed());
}

enum Event { successfullyLoad, failToSubmit }

class TestBloc extends Bloc<Event, StatefulState<int>> with StatefulBloc {
  TestBloc() : super(StatefulState(data: 0));

  @override
  Stream<StatefulState<int>> mapEventToState(Event event) async* {
    if (event == Event.successfullyLoad) {
      yield* load(body: () => Outcome.finished(1));
    } else if (event == Event.failToSubmit) {
      yield* submit(body: () => Outcome.failed());
    }
  }
}

void main() async {
  Bloc.observer = SimpleBlocObserver();

  var cubit = TestCubit();
  cubit.successfullyLoad();
  await Future.delayed(Duration.zero);
  cubit.failToSubmit();
  await Future.delayed(Duration.zero);

  var bloc = TestBloc();
  bloc.add(Event.successfullyLoad);
  bloc.add(Event.failToSubmit);
}
