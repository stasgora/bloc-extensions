import 'package:stateful_bloc/src/stateful_base.dart';
import 'package:stateful_bloc/src/stateful_state.dart';
import 'package:test/test.dart';

import 'models.dart';
import 'utils.dart';

Map<ActionStatus, bool Function(StatefulState)> _loadingPairs = {
  ActionStatus.initial: (s) => s.notLoaded,
  ActionStatus.ongoing: (s) => s.beingLoaded,
  ActionStatus.done: (s) => s.loaded,
  ActionStatus.failed: (s) => s.loadFailed,
  ActionStatus.canceled: (s) => s.loadCanceled,
};

Map<ActionStatus, bool Function(StatefulState)> _submissionPairs = {
  ActionStatus.initial: (s) => s.notSubmitted,
  ActionStatus.ongoing: (s) => s.beingSubmitted,
  ActionStatus.done: (s) => s.submitted,
  ActionStatus.failed: (s) => s.submitFailed,
  ActionStatus.canceled: (s) => s.submitCanceled,
};

void main() {
  group('Stateful extension', () {
    group('Cubit', () {
      late TestCubit cubit;

      setUp(() {
        cubit = TestCubit();
      });

      void testFailCubit(ActionType type) async {
        final error = Error();
        Object? expectedError;
        final cubit = FailCubit(
          error: error,
          callback: (error, _) => expectedError = error,
        );
        type == ActionType.loading ? cubit.failLoad() : cubit.failSubmit();
        await expectStates(
          stream: cubit.stream,
          type: type,
          outcome: Outcome.failed(),
        );
        expect(expectedError, error);
      }

      test('emits correct loading states', () {
        cubit.loadData();
        expectStates(stream: cubit.stream, type: ActionType.loading);
      });
      test('emits correct loading states', () {
        cubit.submitData();
        expectStates(stream: cubit.stream, type: ActionType.submission);
      });
      test('emitData updates data field', () {
        var state = cubit.state;
        cubit.emitData(Data.initial);
        expect(cubit.state, equals(state.copyWith(data: Data.initial)));
      });
      test('data returns current data field', () {
        expect(cubit.data, equals(null));
        cubit.emitData(Data.initial);
        expect(cubit.data, equals(Data.initial));
      });
      test('passes load errors to onError', () {
        testFailCubit(ActionType.loading);
      });
      test('passes submit errors to onError', () {
        testFailCubit(ActionType.submission);
      });
    });
    group('Bloc', () {
      late TestBloc bloc;

      setUp(() {
        bloc = TestBloc();
      });

      void testFailBloc(ActionType type) async {
        final error = Error();
        Object? expectedError;
        final bloc = FailBloc(
          error: error,
          callback: (error, _) => expectedError = error,
        );
        type == ActionType.loading
            ? bloc.add(Event.load)
            : bloc.add(Event.submit);
        await expectStates(
          stream: bloc.stream,
          type: type,
          outcome: Outcome.failed(),
        );
        expect(expectedError, error);
      }

      test('emits correct loading states', () {
        bloc.add(Event.load);
        expectStates(stream: bloc.stream, type: ActionType.loading);
      });
      test('emits correct submit states', () {
        bloc.add(Event.submit);
        expectStates(stream: bloc.stream, type: ActionType.submission);
      });
      test('data returns current data field', () async {
        expect(bloc.data, equals(null));
        bloc.add(Event.simpleLoad);
        await bloc.stream.first;
        expect(bloc.data, equals(Data.loaded));
      });
      test('passes load errors to onError', () {
        testFailBloc(ActionType.loading);
      });
      test('passes submit errors to onError', () {
        testFailBloc(ActionType.submission);
      });
    });
    group('State', () {
      test('Loading indicators', () {
        for (var pair in _loadingPairs.entries) {
          expect(pair.value(StatefulState(loadingStatus: pair.key)), isTrue);
        }
      });
      test('Submission indicators', () {
        for (var pair in _submissionPairs.entries) {
          expect(pair.value(StatefulState(submissionStatus: pair.key)), isTrue);
        }
      });
    });
  });
}
