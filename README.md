<a href="https://github.com/khongchai/dynamic_routes/actions"><img src="https://github.com/[USER_NAME]/[REPO_NAME]/workflows/Tests/badge.svg" alt="Build Status"></a>

# Dynamic Routes

Dynamic Routes is a library that lets you specify in advance which routes should be shown and in
what order, from just 1 place in your code. This is invaluable for flow management -- when you want some routes to show, or their order swapped, based on some information that you obtain during runtime.

A good example of such a flow would be a registration flow where, based some information in the database -- whether this user has already registered with your company before, where they live, etc. -- only the required pages are shown. 


# Overview

_Note1: I'll be using the words "widget", "page", and "route" interchangeably_

_Note2: I recommend that all your pages pass data to one another through a centralized cache for more modularity. This library provides a simple caching method that is scoped to each initiator. But you are welcome to use other solutions._

This library comprises two main parts, the _Initiator_, and the _Participator_.

The _Initiator_ page is a page immeidately before where you want your dynamic navigation flow to happen. We'll put all the navigation logic in this page. This could be, for example, a landing page.

```dart
  // landing_page.dart

class _SomeWidgetState extends State<SomeWidget> with DynamicRoutesInitiator {

  //...some code

  void onButtonPressed() {
    const isPage4Required = calculateIfPage4IsRequired();

    final routes = [
      Page1(),
      Page2(),
      Page3(),
      if (isPage4Required) Page4(),
      Page5(),
    ];

    dynamicRoutesInitiator.initializeRoutes(
        routes,
        lastPageCallback: (context) {
          // Do something; maybe return to homepage.
        }
    );

    // This will push the first Participator page.
    dynamicRoutesInitiator.pushFirst(context);
  }

//...some code

}
```

---

The pages in the `routes` array are Participator pages. These pages do not have navigation logic in them, the only thing they know is when to go to the next page and when to go back. 

```dart
// page1.dart

class _SomeWidgetState extends State<SomeWidget> with DynamicRoutesParticipator {
  // pushNext tells this participator page to push the next page in the routes array we saw earlier.
  void onNextButtonPressed() => dynamicRoutesParticipator.pushNext(context);
  // popCurrent tells this participator page to pop the current page and all of its sub-routes.
  // In some cases, this is the same as using Navigator.of(context).pop(context)
  void onBackButtonPressed() => dynamicRoutesParticipator.popCurrent(context);

//...build methods and whatever
}
```

### A bit more about `popCurrent`

`popCurrent` behaves similiarly to using Navigator.of(context).pop for most usecases. 
Unless really necessary, use `popCurrent` instead.

1. `popCurrent`'s implementation is bound to the NavigationLogicProvider, which can be overridden (see the extending navigation logic section).

2. This will guarantee that the page being popped is the current page.
In the next section, we'll show how you can do nested navigation with this library. In a
nested navigation, as you can imagine, a participator can also have its own flow, and using 
`Navigator.of(context).pop` will pop the page at the top of the stack instead of popping the current
participator page.

But, all in all, using `Navigator.of(context).pop` will not break your app. By default, the back button uses the pop method anyway.

---

## Disposing the Initiator and the Participators

We can dispose the `DynamicRoutesInitiator` instance along with the page itself by calling the
Initiator's `dispose` method in the state's `dispose` method. This will also dispose all
`DynamicRoutesParticipator` instances.

```dart

@override
void dispose() {
  dynamicRoutesInitiator.dispose();

  super.dispose();
}

```

---

## Nested Navigation

You can also have a sort of sub-routing navigation, where for example, the second member in the
Initiator array is also an Initiator and can branch off into its own dynamic navigation flow.

To do this, we simply mark the state of the second page with both the _Participator_ and the _Initiator_ mixins.

```dart
class _MixedPageState extends State<MixedPage>
    with DynamicRoutesParticipator, DynamicRoutesInitiator {
  // Some code
}
```

And then we can use either the _Initiator_ or the _Participator_ instances when appropriate.

```dart
Widget buildButtons() {
  return Column(
      children: [
        TextButton(
            child: Text("Click this to branch off"),
            onPressed: () {
              dynamicRoutesInitiator.initializeRoutes(const [
                ParticipatorPage(title: "SubFlow 1 Sub page 1"),
                ParticipatorPage(title: "SubFlow 1 Sub page 2"),
                ParticipatorPage(title: "SubFlow 1 Sub page 3"),
              ], lastPageCallback: (context) {
                dynamicRoutesInitiator.popUntilInitiatorPage(context);

                // Or if you do this, this page, and all of the pages in the subflow that branched off
                // from this page, will be popped. Internally, we're using popUntil
                // dynamicRoutesParticipator.popCurrent(context);
              });
            }
        ),
        TextButton(
          child: Text("Click this to continue the flow"),
          onPressed: () => dynamicRoutesParticipator.pushNext(context),
        )
      ]
  );
}
```

---

## Doubly-Nested Navigation

I don't know when or where or why someone might need this, but as a result of the lib's
route-scoping, you can also have a subflow within another subflow.

```dart
Widget buildButtons() {
  return TextButton(
      child: Text("Click this to branch off"),
      onPressed: () {
        dynamicRoutesInitiator.initializeRoutes(const [
          // Where SubflowPage class is both a navigator and an initiator.
          SubflowPage(pages: [
            Page1(),
            Page2(),
            Page3(),
            SubflowPage(pages: [
              Page1(),
              if (page2Required) Page2(),
              if (page4BeforePage3) ...[Page4(), Page3()] else
                [
                  Page3(),
                  Page4(),
                ]
            ])
          ]),
          ParticipatorPage(title: "SubFlow 1 Sub page 3"),
        ], lastPageCallback: (context) {
          // Do whatever
        });
      }
  );
}
```
---

## Multi-page Navigation

### pushFor

You can push multiple pages at once with `pushFor`.

This method guarantees that you will never push beyond the last _Participator_ page.

```dart
// Pushes 4 pages.
dynamicRoutesParticipator.pushFor(context, 4);

// Pushes to the last participator page.
dynamicRoutesParticipator.pushFor(context, dynamicRoutesParticipator..getProgressFromCurrentPage());

// Pushes to the last participator page + invoke [lastPageCallback].
dynamicRoutesParticipator.pushFor(context, dynamicRoutesParticipator..getProgressFromCurrentPage() + 1);
```

The method returns a list of `Future` of results from each of the page; you can await all of them like
so:

```dart
// Assume that we are in the first participator page.
final results = await Future.wait(dynamicRoutesParticipator.pushFor(context, 3));

print(results); // [resultFromSecond, resultFromThird, resultFromFourth];

setState((){
  updateWhatever();
})
```

The method is only available to the `dynamicRoutesParticipator` instances. For a similar functionality for `dynamicRoutesInitiator`, use _pushFirstThenFor_.

---

### pushFirstThenFor

This is similar to `pushFor`, but is called from the initiator. Internally, we just call `pushFirst`
first, then call `pushFor`. All methods of awaiting the results mentioned above apply here as well.

```dart
dynamicRoutesInitiator.initializeRoutes(...);
// This will push the first page, then push 3 more pages. We are basically pushing a total of 4 pages.
final results = await Future.wait(dynamicRoutesInitiator.pushFirstThenFor(context, 3));

print(results); //[resultFromFirst, resultFromSecond, resultFromThird, resultFromFourth]
```

---

### popFor

You can reset the flow, eg. go back to the first _Participator_ page, or the _Initiator_ page with `popFor`.

`popFor` guarantees that you will never pop beyond the _Initiator_ page.

```dart
// Pop just 2 pages while returning true as the result to those two pages.
dynamicRoutesNavigator.popFor(context, 2 , true);

// This pops until the first participator page.
final currentPageIndex = dynamicRoutesNavigator.getCurrentPageIndex();
dynamicRoutesNavigator.popFor(context, currentPageIndex);

// Add + 1 to currentPageIndex or just use double.infinity to pop to the Initiator page.
dynamicRoutesNavigator.popFor(context, currentPageIndex);
dynamicRoutesNavigator.popFor(context, double.infinity);
```

---

## Caching

This library also supports a simple caching method.

You can call this whenever, and wherever, from both the Participators and Initiator pages.

```dart
void saveToCache(WhatEverClassThisThingIs someData) {
  dynamicRoutesParticipator.setCache(someData);

  // Or

  dynamicRoutesInitiator.setCache(someData);
}
```

Once set, this can be accessed from all members of the navigation.

```dart

Whatever readFromCache() {
  return dynamicRoutesParticipator.getCache() as Whatever;
}

// Or

Whatever readFromCache() {
  return dynamicRoutesInitiator.getCache() as Whatever;
}

```

By default, cache data gets cleared along with `dynamicRoutesInitiator` when the `dispose` method is called. This can be overridden directly from the method with the `clearCache` argument.

```dart
@override
void initState() {
  dynamicRoutesInitiator.dispose(clearCache: false); // true by default.

  super.initState();
}

```

If your concern is the separation of concerns, then this caching is probably not for you and you're
better off using some dependency injection libraries for your cache.

## Modifying, extending, or replacing the navigation logic.

It is possible to partly, or completely supplant or modify the navigation logic. If you want, for
example, to do something everytime `pushNext` or pop is called, you can implement the
`NavigationLogicProvider` class or its implementation, and provide yours as the new
`navigationLogicProvider`.

_Note that `setNavigationLogicProvider` does not override the internal checks. 

```dart 
  // An example from pushFirst source code.
 @override
  Future<T?> pushFirst<T>(BuildContext context) {
    assert(
        _isStackLoaded,
        "the initializeRoutes() method should be called first before this can "
        "be used.");

    final firstPage = _pageDataMap.values.first;

    _widget = firstPage.widget;

    // This is what you are overriding; everything above stays the same.
    return _navigationLogicProvider
        .next(NextArguments(context: context, nextPage: _widget!));
  }
```

### In the first example, we replaces the navigation logic completely.

Instead of calling Flutter's `Navigator.of(context).push`, we just swap out the current widget with
a new one.

`customNextCallback`and `customBackCallback` are just methods that I added to this class so that we
can pass it custom implementation from elsewhere.

```dart
// Create a new class that extends NavigationLogicProvider.
class CustomNavigationLogicProvider implements NavigationLogicProvider {
  final Function(Widget) customNextCallback;
  final Function(Widget?) customBackCallback;

  const CustomNavigationLogicProvider(
      {required this.customNextCallback, required this.customBackCallback});

  @override
  void back<T>(_) {
    customBackCallback(previousPage);
  }

  @override
  Future<T?> next<T>(_) async {
    customNextCallback(nextWidget);

    return null;
  }
}

// ... somewhere inside your Initiator widget
late final CustomNavigationLogicProvider _customNavigationLogicProvider;

void initiateDynamicRoutesInstane() {
  // Initialize normally
  dynamicRoutesInitiator.initializeRoutes(_widgets,
      lastPageCallback: (newContext) {
        dynamicRoutesInitiator.popUntilInitiatorPage(context);
      });

  final customNavigationLogicProvider = CustomNavigationLogicProvider(
      customNextCallback: (Widget widget) {
        setState(() {
          _displayedWidget = widget;
        });
      }, customBackCallback: (Widget? maybeAWidget) {
    setState(() {
      _displayedWidget = maybeAWidget;
    });
  });

  // Again, make sure this is called after initializeRoutes.
  dynamicRoutesInitiator.setNavigationLogicProvider();

  dynamicRoutesInitiator.pushFirst(context);
}

```

### In this second example, we extend the already existing implementation and log to firebase everytime a navigation occurs.

```dart
// Create a new class that extends the implementation of NavigationLogicProvider
class CustomNavigationLogicProvider extends NavigationLogicProviderImpl {
  const CustomNavigationLogicProvider();

  @override
  Future<T?> next<T>(NextArguments args) async {
    // Add the extra functionality(-ies) that we want
    logsToFireBase("forward");

    return super.next(args);
  }

  @override
  void back<T>(BackArguments args) {
    // Add the extra functionality(-ies) that we want
    logsToFireBase("back");

    super.back(args);
  }
}

// ... somewhere inside your Initiator widget

void initiateDynamicRoutesInstance() {
  // Initialize normally
  dynamicRoutesInitiator.initializeRoutes(_widgets,
      lastPageCallback: (newContext) {
        Navigator.popUntil(newContext, (route) => route.isFirst);
      });

  final customNavigationLogicProvider = CustomNavigationLogicProvider();

  // Make sure this is called after initializeRoutes.
  dynamicRoutesInitiator.setNavigationLogicProvider(customNavigationLogicProvider);

  dynamicRoutesInitiator.pushFirst(context);
}
```