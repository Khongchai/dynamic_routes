# Dynamic Routes

Dynamic Routes is a library that lets you specify in advance which routes should be shown and in what order.
This is invaluable when you manage your flow and would like some routes to show, or order to be swapped, based
on some information that you obtain during runtime.

# Overview

_Note: I'll be using the words Widget, Page, and Route interchangeably_

This library comprises of two main parts, the _Initiator_, and the _Participator_.

First, we'd need to mark the participating page with the _DynamicRoutesParticipator_ mixin.
This would give that component access to the dynamicRoutesParticipator instance that is tied to the
scope of the initiator page that we'll mark with the _DynamicRoutesInitiator_.

For the page directly before the flow:

```dart
class SomeWidget extends StatefulWidget with DynamicRoutesInitiator {
 //...some code
}

class _SomeWidgetState extends State<SomeWidget> {

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
  }

  //...some code

}
```

And then, in the pages that are included in the array (the "participating" pages).

```dart
class SomeWidget extends StatefulWidget with DynamicRoutesParticipator{
  //...some code
}

class _SomeWidgetState extends State<SomeWidget> {
  void onButtonPressed() => widget.dynamicRoutesParticipator.pushNext(context);
   //...build methods and whatever
}
```

We can dispose the _DynamicRoutesInitiator_ instance along with the page itself by calling the
initiator's _dispose_ method in the state's _dispose_ method. This will also dispose all _DynamicRoutesParticipator_ instances.

```dart

@override
void dispose() {
  dynamicRoutesInitiator.dispose();

  super.dispose();
}

```

## Nested Navigation

You can also have a sort of sub-routing navigation, where for example, the second member in
the initiator array is itself, also an initiator and can branch of into its dynamic routing navigation.

To do this, we simply mark the state of the second page with both the participator and the initiator mixins.

```dart
class _MixedPageState extends State<MixedPage>
    with DynamicRoutesParticipator, DynamicRoutesInitiator {
  // Some code
  }
```

And then we can use either the initiator or the participator instances when appropriate.

```dart
Widget buildButtons(){
  return Column(
      children: [
        TextButton(
            child: Text("Click this to branch off"),
            onPressed: (){
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

I don't know when or where or why someone might need this, but as a result of the lib's route-scoping, you can also have a subflow within another subflow.

```dart
Widget buildButtons(){
  return TextButton(
            child: Text("Click this to branch off"),
            onPressed: (){
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
