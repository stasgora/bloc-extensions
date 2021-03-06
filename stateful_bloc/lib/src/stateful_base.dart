import 'dart:async';

import 'stateful_state.dart';

/// Outcome of a gracefully finished action
class Outcome<Data> {
  /// Outcome status
  final ActionStatus status;

  /// User provided outcome data
  final Data? data;

  /// Indicates the action successfully finished
  const Outcome.finished([this.data]) : status = ActionStatus.done;

  /// Indicates the action failed
  const Outcome.failed([this.data]) : status = ActionStatus.failed;

  /// Indicates the action was canceled
  const Outcome.canceled([this.data]) : status = ActionStatus.canceled;
}

/// Executes a stateful action
Stream<StatefulState<Data>> execute<Data>({
  required StatefulState<Data> state,
  required ActionType type,
  required FutureOr<Outcome<Data>?> Function() body,
  required void Function(Object, StackTrace) onError,
  Data? initialData,
}) async* {
  ActionStatus? set(ActionStatus state, ActionType byType) =>
      byType == type ? state : null;
  yield state = state.copyWith(
    data: initialData,
    loadingStatus: set(ActionStatus.ongoing, ActionType.loading),
    submissionStatus: set(ActionStatus.ongoing, ActionType.submission),
  );
  try {
    var outcome = await body();
    var status = outcome?.status ?? ActionStatus.done;
    yield state.copyWith(
      data: outcome?.data,
      loadingStatus: set(status, ActionType.loading),
      submissionStatus: set(status, ActionType.submission),
    );
    // ignore: avoid_catches_without_on_clauses
  } catch (error, stackTrace) {
    yield state.copyWith(
      loadingStatus: set(ActionStatus.failed, ActionType.loading),
      submissionStatus: set(ActionStatus.failed, ActionType.submission),
    );
    onError(error, stackTrace);
  }
}
