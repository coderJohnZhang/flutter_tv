import 'package:flutter/widgets.dart';

/// Lifecycle contract for view models.
abstract class ViewModel {
  void dispose();
}

/// Exposes a [ViewModel] to the subtree and disposes it with the host widget.
///
/// An [InheritedWidget] scope is enough: the instance never changes, so a
/// dependent never rebuilds.
class ViewModelProvider<T extends ViewModel> extends StatefulWidget {
  const ViewModelProvider({
    super.key,
    required this.viewModel,
    required this.child,
  });

  final T viewModel;
  final Widget child;

  static T of<T extends ViewModel>(BuildContext context) {
    final _ViewModelScope<T>? scope =
        context.dependOnInheritedWidgetOfExactType<_ViewModelScope<T>>();
    assert(scope != null, 'No ViewModelProvider<$T> above this context.');
    return scope!.viewModel;
  }

  @override
  State<ViewModelProvider<T>> createState() => _ViewModelProviderState<T>();
}

class _ViewModelProviderState<T extends ViewModel>
    extends State<ViewModelProvider<T>> {
  @override
  void dispose() {
    widget.viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => _ViewModelScope<T>(
        viewModel: widget.viewModel,
        child: widget.child,
      );
}

class _ViewModelScope<T extends ViewModel> extends InheritedWidget {
  const _ViewModelScope({required this.viewModel, required super.child});

  final T viewModel;

  @override
  bool updateShouldNotify(_ViewModelScope<T> oldWidget) =>
      !identical(oldWidget.viewModel, viewModel);
}
