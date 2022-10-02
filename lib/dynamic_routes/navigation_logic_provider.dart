import 'package:flutter/material.dart';

abstract class NavigationLogicProvider {
  Future<T?> next<T>(BuildContext context, Widget nextPage);

  void back<T>(BuildContext context, T result);
}

class NavigationLogicProviderImpl implements NavigationLogicProvider {
  @override
  Future<T?> next<T>(
    BuildContext context,
    Widget nextPage,
  ) =>
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => nextPage));

  @override
  void back<T>(BuildContext context, T result) =>
      Navigator.of(context).pop(result);
}
