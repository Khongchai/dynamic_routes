import 'package:flutter/material.dart';

abstract class NavigationLogicProvider {
  /// This method is never called on the last page, rather,
  /// [lastPageCallback] is called instead.
  Future<T?> next<T>({required BuildContext context, required Widget nextPage});

  /// [previousPage] can be null when the current page is the first participator
  /// page.
  void back<T>(
      {required BuildContext context,
      Widget? previousPage,
      required Widget currentPage,
      required T result});
}

class NavigationLogicProviderImpl implements NavigationLogicProvider {
  const NavigationLogicProviderImpl();

  @override
  Future<T?> next<T>(
          {required BuildContext context, required Widget nextPage}) =>
      Navigator.of(context).push(MaterialPageRoute(
          settings: RouteSettings(name: nextPage.hashCode.toString()),
          builder: (_) => nextPage));

  @override
  void back<T>(
      {required BuildContext context,
      Widget? previousPage,
      required Widget currentPage,
      required T result}) {
    if (previousPage != null) {
      // Guarantees to pop all sub-routes, if some exists.
      Navigator.of(context).popUntil(ModalRoute.withName(
        currentPage.hashCode.toString(),
      ));
      // Then pop the current page.
      Navigator.of(context).pop(result);
    } else {
      Navigator.of(context).pop(result);
    }
  }
}
