# DataDrivenUIKit
 Adopt data-driven, declarative and functional aspects to UIKit


## Motivation

SwiftUI is pretty awesome philosophically, but in adoption, it has some rough edges.  We keep falling back to UIKit to actually get stuff done, where we cannot enjoy the benefits of SwiftUI.  One main problem is its back-deploy story.  Because SwiftUI is a framework, and not a language feature, new features in SwiftUI do not deploy to older OS versions.  In addition, on UIKit-based platforms, we cannot incrementally adopt SwiftUI from the inside out; SwiftUI must take over the entire view-controller.  What would be awesome is if we could adopt data-driven, declarative and functional designs for UIKit, allowing us to migrate our code a bit at a time, and maintain backwards compatibility with older OS's.

To that end, I have begun writing this "Data-Driven UIKit" package, a (hopefully) ever-growing collection of adaptations to UIKit classes to make them useful with the new philosophies.  We'll pick UIKit at iOS 13, because of the inclusion of `Combine`, which powers much of what we'll be doing with dynamic values.  Theoretically, we can build our own value-publisher-chain-like systems in earlier OS versions, but there is extensive support in the OS for integrations deep into features like non-blocking queue assignment and networking support which I find impracticle to bring in-scope.  


## Progress


- [x] Cascading style sheets for UIViews, with functional callers and generic returns
- [x] Data-driven UILabel, using Publishers to provide dynamic values
- [ ] Data-Driven UIImageView, "" "" ""
- [ ] Hot wires for horizontal and vertical stack views with alignments 
- [ ] SwiftUI / WorkableUIKit -style buttons, with complete accessibility support
- [ ] Bindings for UITextFields.
- [ ] Dynamically inserted / removed / altered views based on conditional expressions
- [ ] A section-oriented UITableViewDataSource implementation with declarative and data-driven inits.



## Data-drivenness is `@ObservableObject` / `@Publisher` -based

While SwiftUI has its `@State` in UIKit in iOS 13, these property wrappers literally do not work outside of SwiftUI `View`s, and part of the way they work is inherently struct-based.  Since working with UIKit means working with class-based UIViews, we'll just use Observable objects and published properties for all our value reading.
We'll use `ObservableObject` / `ObservedObject` and `Published` / `Publisher` for reading values 

Should it be `AsyncStream` based?


Example: init a UILabel to dynamically update it's `text` from a `Publisher<String, Never>`.

 ```swift
 @Published var someText:String
 ...
 UILabel($someText)
 ```

It really is that simple! (from the calling code) And now you have a UILabel which will update it's value from the published String (don't forget your `@Published var` must be inside a class conforming to `ObservableObject`).  This uses the `convenience init(_ publisher:any Publisher<String, Never>)` from the `extension UILabel`.  There are others matching the `init` methods from `Text` for SwiftUI, namely  `init(verbatim content: String)`, and `init(_ key: LocalizedStringKey, tableName: String? = nil, bundle: Bundle? = nil, comment: StaticString? = nil)`, however, I recommend not using the `LocalizedStringKey` method, since the language doesn't seem to truly support resolving those outside the OS's internal implementaiton.



## (Dynamic) Cascading Style Sheets (but not CSS) for UIKit

Sure, the `UIAppearance` protocols support the idea of cascading style sheets, but they aren't dyanmic.  That means, they aren't watching the value of a variable and adjusting accordingly.  DataDrivenUIKit adds the ability to set cascade styles from Publishers.


In the simple case, you can set literals in a functional syntax, using the `.style(_, value:)` modifier:

```swift
 @Published var text:String = "Original"
 ...
 UILabel($text)
	 .style(\.foregroundColor, value: .green)
```

But you can also provide a publisher to the value:


```swift
 @Published var textColor:UIColor = .green
 ...
 UILabel($text)
	 .style(\.foregroundColor, from: $textColor)
```

Currently, `UILabel` supports  `.foregroundColor` (`UIColor`), `.maxNumberOfLines` (`Int?`), and `.multilineTextAlignment` (`NSTextAlignment`).  You'll notice these modifier names match up with SwiftUI names, while the values are usually typical UIKit values.  This in intentional.  SwiftUI reflects more than a decade's worth of refinement of typical bext-practices in how such values should be configured, and these updated modifier names reflect that.  However, we are fundamentally working with UIKit types, and those values will usually provide the least impedance mismatch with migrating code to UIKit.
In the case of `.maxNumberOfLines` and `Int?` instead of an `Int`, keep in mind that UILabel's `.numberOfLines` property was cemented in stone long before Swift was invented, and thus the sentinel value of 0 has never been updated to be more Swift.


## Bindings for UITextField

TBD



## Dynamically inserted / hidden / removed subviews based on expressions of published values.

TBD


## UITableViewDeclarativeDataSource

TBD



## Examples

