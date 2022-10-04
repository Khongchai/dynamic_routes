# Dynamic Routes

Dynamic Routes is a library that lets you specify in advance which routes should be shown and in
what order. This is invaluable for flow management -- when you want some routes to show, or their
order swapped, based on some information that you obtain during runtime.

_This method assumes your pages don't depend on any data from other pages. Technically, they can
still read one another's data, but that becomes a problem when the order of your pages get swapped,
or some pages are conditionally removed from the navigation array._

# Overview

_Note: I'll be using the words Widget, Page, and Route interchangeably_

This library comprises two main parts, the _Initiator_, and the _Participator_.

We can begin by marking the participating page with the _DynamicRoutesParticipator_ mixin. This
would give that component access to the dynamicRoutesParticipator instance that is tied to the scope
of the Initiator page that we'll mark with the _DynamicRoutesInitiator_.

For the page directly before the flow:

```dart

class _SomeWidgetState extends State<SomeWidget> with DynamicRoutesInitiator {

  //...some code

  void onButtonPressed() {
    const isPage4Required = calculateIfPage4IsRequired();

    dynamicRoutesInitiator.initializeRoutes(
        [
          Page1(),
          Page2(),
          Page3(),
          if (isPage4Required) Page4(),
          Page5(),
        ],
        lastPageCallback: (context) {
          // Do something; maybe return to homepage.
        }
    );

    dynamicRoutesInitiator.pushFirst(context);
  }

//...some code

}
```

And then in the pages that are included in the array (the "participating" pages):

```dart

class _SomeWidgetState extends State<SomeWidget> with DynamicRoutesParticipator {
  void onButtonPressed() => dynamicRoutesParticipator.pushNext(context);
//...build methods and whatever
}
```

We can dispose the _DynamicRoutesInitiator_ instance along with the page itself by calling the
Initiator's _dispose_ method in the state's _dispose_ method. This will also dispose all
_DynamicRoutesParticipator_ instances.

```dart

@override
void dispose() {
  dynamicRoutesInitiator.dispose();

  super.dispose();
}

```

## Nested Navigation

You can also have a sort of sub-routing navigation, where for example, the second member in the
Initiator array is itself, also an Initiator, and can branch off into its dynamic routing
navigation.

To do this, we simply mark the state of the second page with both the Participator and the Initiator
mixins.

```dart
class _MixedPageState extends State<MixedPage>
    with DynamicRoutesParticipator, DynamicRoutesInitiator {
  // Some code
}
```

And then we can use either the Initiator or the Participator instances when appropriate.

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
                Navigator.of(context).pop();
                Navigator.of(context).pop();
                Navigator.of(context).pop();
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

## Navigate Through Multiple Pages

### pushFor

You can pop until the last Participator page, or until lastPageCallback with _pushFor_.

This method guarantees that you will never push beyond the last Participator page. 

The method returns a list of future of results from each of the page, so you can await all of them 
like so:

```dart
//TODO this needs to be tested.
final results = await Future.wait(dynamicRoutesParticipator.pushFor(context, 4));


```


### popFor

You can reset the flow, eg. go back to the first Participator page, or the Initiator page
with _popFor_.

_popFor_ guarantees that you will never pop beyond the Initiator page.

```dart
// Pop just 2 pages while returning true as the result to those two pages.
dynamicRoutesNavigator.popFor(context, 2, true);

// This pops until the first participator page.
final currentPageIndex = dynamicRoutesNavigator.getCurrentPageIndex();
dynamicRoutesNavigator.popFor(context, currentPageIndex);

// This pops until the first participator page.
final currentPageIndex = dynamicRoutesNavigator.getCurrentPageIndex();
dynamicRoutesNavigator.popFor(context, currentPageIndex);

// Add - 1 to currentPageIndex or just use double.infinity to pop to the Initiator page.
dynamicRoutesNavigator.popFor(context, currentPageIndex);
dynamicRoutesNavigator.popFor(context, double.infinity);
```

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

By default, cache data gets cleared alongside the instance of the Initiator page, this can be
overridden directly from the _dispose_ method.

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

It is possible to partly, or completely supplant or modify the navigation logic. If you want, for example, to do something everytime pushNext or pop is called, you can implement the NavigationLogicProvider class or its implementation, and provide yours as the new navigationLogicProvider.

_Note that setNavigationLogicProvider only exposes the part of the library that deals with the navigation after TODO_

### In the first example, we replaces the navigation logic completely. 

Instead of calling Flutter's _Navigator.of(context).push_, we just swap out the current widget with a new one.

_customNextCallback_ and _customBackCallback_ are just methods that I added to this class so that we can pass it custom implementation
from elsewhere.

```dart
// Create a new class that extends NavigationLogicProvider.
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

// ... somewhere inside your Initiator widget
late final CustomNavigationLogicProvider _customNavigationLogicProvider;

void initiateDynamicRoutesInstane(){
  // Initialize normally
  dynamicRoutesInitiator.initializeRoutes(_widgets,
      lastPageCallback: (newContext) {
    Navigator.popUntil(newContext, (route) => route.isFirst);
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

### In this second example, we extend the already exsiting implementation and log to firebase everytime a navigation occurs.

```dart
// Create a new class that extends the implementation of NavigationLogicProvider
class CustomNavigationLogicProvider extends NavigationLogicProviderImpl {
  const CustomNavigationLogicProvider();

  @override
  Future<T?> next<T>(BuildContext context, Widget nextPage) async {
    // Add the extra functionality(-ies) that we want
    logsToFireBase("forward");

    return super.next(context, nextPage);
  }

  @override
  void back<T>(BuildContext context, T result) {
    // Add the extra functionality(-ies) that we want
    logsToFireBase("back");

    super.back(context, result);
  }
}

// ... somewhere inside your Initiator widget

void initiateDynamicRoutesInstane(){
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