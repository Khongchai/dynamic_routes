import 'package:flutter/material.dart';

class NextArguments {
  final BuildContext context;
  final Widget nextPage;

  const NextArguments({
    required this.context,
    required this.nextPage,
  });
}

class BackArguments<T> {
  final BuildContext context;
  final Widget? previousPage;
  final Widget currentPage;
  final T result;

  const BackArguments(
      {required this.context,
      this.previousPage,
      required this.currentPage,
      required this.result});
}

abstract class NavigationLogicProvider {
  /// This method is never called on the last page, rather,
  /// [lastPageCallback] is called instead.
  Future<T?> next<T>(NextArguments nextParameters);

  /// [previousPage] can be null when the current page is the first participator
  /// page.
  void back<T>(BackArguments backParameters);
}

class NavigationLogicProviderImpl implements NavigationLogicProvider {
  const NavigationLogicProviderImpl();

  @override
  Future<T?> next<T>(NextArguments args) =>
      Navigator.of(args.context).push(MaterialPageRoute(
          settings: RouteSettings(name: args.nextPage.hashCode.toString()),
          builder: (_) => args.nextPage));

  @override
  void back<T>(BackArguments args) {
    if (args.previousPage != null) {
      // Guarantees to pop all sub-routes, if some exists.
      Navigator.of(args.context).popUntil(ModalRoute.withName(
        args.currentPage.hashCode.toString(),
      ));
      // Then pop the current page.
      Navigator.of(args.context).pop(args.result);
    } else {
      Navigator.of(args.context).pop(args.result);
    }
  }
}
