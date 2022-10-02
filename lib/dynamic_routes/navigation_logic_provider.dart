import 'package:flutter/material.dart';

abstract class NavigationLogicProvider {
  /// This method is never called on the last page, rather,
  /// [lastPageCallback] is called instead.
  Future<T?> next<T>(BuildContext context, Widget nextPage);

  /// [previousPage] can be null when the current page is the first participator
  /// page.
  void back<T>(BuildContext context, Widget? previousPage, T result);
}

class NavigationLogicProviderImpl implements NavigationLogicProvider {
  const NavigationLogicProviderImpl();

  @override
  Future<T?> next<T>(
    BuildContext context,
    Widget nextPage,
  ) =>
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => nextPage));

  @override
  void back<T>(BuildContext context, Widget? previousPage, T result) =>
      Navigator.of(context).pop(result);
}
