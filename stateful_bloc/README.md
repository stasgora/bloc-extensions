<div align="center">

# Stateful Bloc

<a href="https://pub.dev/packages/stateful_bloc"><img src="https://img.shields.io/pub/v/stateful_bloc.svg?color=blueviolet" alt="Pub"></a>
<a href="https://github.com/stasgora/bloc-extensions/actions"><img src="https://github.com/stasgora/bloc-extensions/workflows/stateful_bloc/badge.svg" alt="build"></a>
<a href="https://codecov.io/gh/stasgora/bloc-extensions"><img src="https://codecov.io/gh/stasgora/bloc-extensions/branch/master/graph/badge.svg?token=19FNNBVV4A"/></a>
<a href="https://github.com/dart-lang/lints"><img src="https://img.shields.io/badge/style-recommended-40c4ff.svg" alt="style: effective dart"></a>
<a href="https://github.com/stasgora/bloc-extensions/blob/master/LICENSE"><img src="https://img.shields.io/badge/license-MIT-blue.svg" alt="License: MIT"></a>

Extension to the [Bloc](https://pub.dev/packages/bloc) library that simplifies common state transition sequences
</div>

---

## Use case
Stateful extension is built to support __data loading__ and __submission__
patterns which are commonly implemented using Bloc.
Each one of them usually consist of the following states:
`SubjectInitial`, `SubjectActionInProgress`, `SubjectActionSuccess`, `SubjectActionFailure`

They are commonly used as follows:
- `SubjectInitial` is the `initialState` set in constructor
- when the action is triggered the `SubjectActionInProgress` is set
- some logic is executed to fetch / send / transform the data
- depending on the outcome `SubjectActionSuccess` / `SubjectActionFailure` is set

This extension abstracts away both the state types and their
transitions leaving only the logic to be supplied by the implementer.

## Usage comparison

Example of a generic cubit that provides state to a page, allowing it to display a loading indicator and error message

<div align="center"><table>

### Cubit

<tr><td align="center"> Pure cubit </td> <td align="center"> Stateful cubit </td></tr>
<tr><td>

```dart
class PageCubit extends Cubit<PageState> {
  PageCubit() : super(PageStateInitial());

  void loadPage() {
    emit(PageStateLoadInProgress());
    try {
      // data loading
      emit(PageStateLoadSuccess(/* data */));
    } catch(e) {
      emit(PageStateLoadFailure());
    }
  }
}
```

</td><td valign="top">

```dart
class PageCubit extends Cubit
    <StatefulState<PageData>> with StatefulCubit {
  PageCubit() : super(StatefulState());

  void loadPage() => load(body: () {
    // data loading
    return Outcome.finished(PageData(/* data */));
  });
}
```

</td></tr>
</table>

### State

<table>
<tr><td align="center"> Pure cubit state </td> <td align="center"> Stateful state </td></tr>
<tr><td>

```dart
abstract class PageState extends Equatable {
  @override
  List<Object> get props => [];
}

class PageStateInitial extends PageState {}

class PageStateLoadInProgress extends PageState {}

class PageStateLoadSuccess extends PageState {
  final String data;

  const LoadSuccess(this.data);

  @override
  List<Object>? get props => [data];
}

class PageStateLoadFailure extends PageState {}
```

</td><td valign="top">

```dart
// used as StatefulState<PageData>
class PageData extends Equatable {
  final String data;

  const PageData(this.data);

  @override
  List<Object>? get props => [data];
}
```

</td></tr>
</table></div>

## Advantages
Main advantages of using the Stateful extension:
- __Cubit / Bloc simplification__ - you don't have to worry
  about states, just focus on the logic and the data it changes
- __State simplification__ - no more repeating the same inheritance tree
  for each component, just focus on the data that's being provided
- __Uniform state types across the whole codebase__ - aside from
  the standardization itself this makes it easier to reuse state dependent
  widgets across multiple UI components (like showing a loading indicator
  on `ActionStatus.ongoing` or an error message on `ActionStatus.failed`).

## Maintainers
- [Stanisław Góra](https://github.com/stasgora/)

Special thanks to [Felix Angelov](https://github.com/felangel) and other [Bloc](https://pub.dev/packages/bloc) library contributors

## License
This library is licenced under [`MIT License`](https://github.com/stasgora/round-spot/blob/master/LICENSE)