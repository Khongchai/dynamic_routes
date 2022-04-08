# Dynamic Routes

Dynamic Routes is a library that lets you specify in advance which pages should be show and in what order.
This is invaluable when you manage your flow and would like some pages to show, or the order to be swapped, based
on some information that you obtain during runtime.

# Overview

This library comprises of two main parts, the _Initiator_, and the _Participator_.

First, we'd need to mark the participating page with the _DynamicRoutesParticipator_ mixin.
This would give that component access to the dynamicRoutesParticipator object that is tied to the
scope of the initiator page which we'll mark with the _DynamicRoutesInitiator_.

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

//TODO
