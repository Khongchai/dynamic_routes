## 1.0.0

Initial release

## 1.0.1

Name change and docs edit

## 1.1.0

### New features.

- Added a method to pop for a number of pages between 0 to pages.length.
- DynamicRoutesNavigator.pop now conforms to the Navigator.pop interface.
- Added popFor, pushFor.
- Sub-routing now possible.
- For more customizability, the navigation logic _next_ and _back_ can now be extended, or replaced.
- Before this version, using popCurrent was pointless other than for debugging purposes. Now, popCurrent guarantees that even in a nested navigation, it's going to be the current page that is popped, and that its navigation logic will be overridden when a new navigation logic provider is added.
- Handled double-calling navigation methods.

### Docs-related

- The first initiator example in the docs was missing a step.
- Some parts of the docs and the variable names were still referencing the old "StackedRoutes" name.
