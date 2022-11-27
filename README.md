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



## (Dynamic) Cascading Style Sheets (but not CSS) for UIKit

Sure, the `UIAppearance` protocols support the idea of cascading style sheets, but they aren't dyanmic.  That means, they aren't watching the value of a variable and adjusting accordingly. 


UILabel
	Supported properties:
		.foregroundColor, .maxNumberOfLines, .textAlignment
		
While these property names take on SwiftUI-centric names, they take on UIKit-centric values, such as UIColor, and NSTextAlignment


## Bindings for UITextField

TBD



## Dynamically inserted / hidden / removed subviews based on expressions of published values.

TBD


## UITableViewDeclarativeDataSource

TBD



## Examples


### UILabel


Currently, UILabel supports data-drivennes for the .text property, and cascading styles for foreground color, alignment and max number of lines.  Unlike other init methods for UILabel, these init methods set line break mode to byWordWrapping, and numberOfLines to 0.  

```swift
 @Published var text:String = "Original"
 ...
 
 UILabel($text)
	 .style(\.foregroundColor, value: .green)
 ````
