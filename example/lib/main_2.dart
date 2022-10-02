import 'package:dynamic_routes/dynamic_routes/mixins/initiator.dart';
import 'package:dynamic_routes/dynamic_routes/navigation_logic_provider.dart';
import 'package:example/pages/mixed_page/mixed_page.dart';
import 'package:example/pages/participator_page.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

// This tests similar navigation logic as MyApp, but instead of using Flutter's
// Navigator, we'll ber overriding the NavigationLogicProvider and provide
// a custom implementation to allow for some sick sub-routing actions.
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.lightGreen,
      ),
      // Unique keys are needed because my participator pages are so similar
      // Flutter thinks they are the same widget. In a real app, this won't
      // be a problem.

      // All the nested-route stuff are still possible here, but because we have
      // already two sets of widgets. To keep things simple, I have decided to
      // do just 1-level navigation in this example.
      home: MyHomePage(
        title: 'Dynamic Routes Test',
        widgets1: [
          ParticipatorPage(title: "Page 1", key: UniqueKey()),
          ParticipatorPage(title: "Page 2", key: UniqueKey()),
          ParticipatorPage(title: "Page 3", key: UniqueKey()),
          ParticipatorPage(title: "Page 4", key: UniqueKey()),
          ParticipatorPage(title: "Page 5", key: UniqueKey()),
          ParticipatorPage(title: "Page 6", key: UniqueKey()),
        ],
        widgets2: [
          ParticipatorPage(title: "Page 1", key: UniqueKey()),
          ParticipatorPage(title: "Page 2", key: UniqueKey()),
          ParticipatorPage(title: "Page 3", key: UniqueKey()),
          ParticipatorPage(title: "Page 4", key: UniqueKey()),
          ParticipatorPage(title: "Page 5", key: UniqueKey()),
          ParticipatorPage(title: "Page 6", key: UniqueKey()),
        ],
      ),
    );
  }
}

class CustomNavigationLogicProvider implements NavigationLogicProvider {
  final Function(Widget) customNextCallback;
  final Function(Widget?) customBackCallback;

  const CustomNavigationLogicProvider(
      {required this.customNextCallback, required this.customBackCallback});

  @override
  void back<T>(BuildContext _, Widget? previousPage, T __) {
    customBackCallback(previousPage);
  }

  @override
  Future<T?> next<T>(
    BuildContext _,
    Widget nextWidget,
  ) async {
    customNextCallback(nextWidget);

    return null;
  }
}

class MyHomePage extends StatefulWidget {
  final List<Widget> widgets1;
  final List<Widget> widgets2;
  final String title;

  const MyHomePage({
    Key? key,
    required this.title,
    required this.widgets1,
    required this.widgets2,
  }) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: LayoutBuilder(builder: (context, constraints) {
        return SizedBox(
          height: constraints.maxHeight,
          child: Column(
            children: [
              Expanded(
                  child: WidgetWithNavigator(
                      title: "Top Widget", pageWidgets: widget.widgets1)),
              const Divider(color: Colors.grey),
              Expanded(
                child: WidgetWithNavigator(
                    title: "Bottom Widget", pageWidgets: widget.widgets2),
              ),
            ],
          ),
        );
      }),
    );
  }
}

class WidgetWithNavigator extends StatefulWidget {
  final List<Widget> pageWidgets;
  final String title;

  const WidgetWithNavigator({
    Key? key,
    required this.title,
    required this.pageWidgets,
  }) : super(key: key);

  @override
  State<WidgetWithNavigator> createState() => _WidgetWithNavigatorState();
}

class _WidgetWithNavigatorState extends State<WidgetWithNavigator>
    with DynamicRoutesInitiator {
  late List<Widget> _widgets = widget.pageWidgets;
  Widget? _displayedWidget;

  late final CustomNavigationLogicProvider _customNavigationLogicProvider;

  @override
  void dispose() {
    dynamicRoutesInitiator.dispose();

    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    _customNavigationLogicProvider =
        CustomNavigationLogicProvider(customNextCallback: (widget) {
      setState(() {
        _displayedWidget = widget;
      });
    }, customBackCallback: (maybeAWidget) {
      setState(() {
        _displayedWidget = maybeAWidget;
      });
    });

    dynamicRoutesInitiator.setCache(0);
  }

  @override
  Widget build(BuildContext context) {
    final value = dynamicRoutesInitiator.getCache();

    return _displayedWidget ??
        SizedBox(
          width: MediaQuery.of(context).size.width,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ElevatedButton(
                child: const Text("Shuffle page order"),
                onPressed: () {
                  final newWidgets = [..._widgets]..shuffle();
                  _widgets = newWidgets;
                },
              ),
              ElevatedButton(
                  onPressed: () => setState(
                      () => dynamicRoutesInitiator.setCache(value + 1)),
                  child: Text("Increment cached value: $value")),
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextButton(
                  child: const Text("Enter flow"),
                  onPressed: () {
                    dynamicRoutesInitiator.initializeRoutes(_widgets,
                        lastPageCallback: (newContext) {
                      setState(() {
                        _displayedWidget = null;
                      });
                    });
                    dynamicRoutesInitiator.setNavigationLogicProvider(
                        _customNavigationLogicProvider);

                    dynamicRoutesInitiator.pushFirst(context).then((_) {
                      // Call setState to refresh the displayed cached value.
                      setState(() {});
                    });
                  },
                ),
              ),
            ],
          ),
        );
  }
}
