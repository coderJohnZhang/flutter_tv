/// Marks a widget as one of the launcher's content tabs.
///
/// The shell scopes focus-block discovery to the active tab, so blocks belonging
/// to tabs that the [IndexedStack] keeps alive never join the search space.
abstract interface class LauncherTabPage {}
