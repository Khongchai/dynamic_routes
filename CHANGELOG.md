## 1.0.0

Initial release

## 1.0.1

Name change and docs edit

## 1.1.0

### New features.

- Added multi-page navigation methods for navigating multiple pages at once.
- `DynamicRoutesNavigator.popCurrent` can also return a value
- For more customizability, the navigation logic `next` and `back` can now be extended, or replaced.
- Before this version, using `popCurrent` was pointless other than for debugging purposes. Now, popCurrent guarantees that even in a nested navigation, it's going to be the current page that is popped, and that its navigation logic will be overridden when a new navigation logic provider is added.
- Handled double-calling navigation methods.
- Minor bug fixes.
- More tests coverage.

### Docs-related

- The first initiator example in the docs was missing a step.
- Some parts of the docs and the variable names were still referencing the old "StackedRoutes" name.
- More detailed

## 1.1.1

Docs edit