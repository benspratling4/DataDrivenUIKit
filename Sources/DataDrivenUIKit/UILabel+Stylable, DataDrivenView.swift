//
//  UILabel+Stylable, DataDrivenView.swift
//  
//
//  Created by Benjamin Spratling on 11/1/22.
//

import Foundation
import Combine
import UIKit
import SwiftUI



/**
 
 Wouldn't you like to be able to do:
 
```swift
 @Published var text:String = "Original"
 ...
 
 UILabel($text)
	 .style(\.foregroundColor, value: .green)
 ````
 
 well, here's your chance.
 */


extension UILabel : DataDrivenView {
	
	public convenience init(verbatim content: String) {
		self.init(frame: .zero)
		setUpStylesheetProperties()
		self.text = content
	}
	
	public convenience init(_ key: LocalizedStringKey, tableName: String? = nil, bundle: Bundle? = nil, comment: StaticString? = nil) {
		self.init(frame: .zero)
		let key:String = key.stringKey ?? "\(key)"	//fallback doesn't work
		let title = NSLocalizedString(key, tableName:tableName, bundle: bundle ?? .main, comment: comment?.description ?? "") //String(localized: key, table: tableName, bundle: bundle, comment: comment)
		setUpStylesheetProperties()
		self.text = title
	}
	
	public convenience init(_ publisher:any Publisher<String, Never>) {
		self.init(frame: .zero)
		setUpStylesheetProperties()
		watch(publisher: publisher)
	}
	
	func setUpStylesheetProperties() {
		//these have to go in separate functions from the convenience inits due to a compiler bug involving demangling key path names from covariant Self
		//https://stackoverflow.com/questions/61137449/fatal-error-could-not-demangle-keypath-type
		set(\.textColor, fromStylesheet: \.foregroundColor)
		set(\.maxNumberOfLines, fromStylesheet: \.maxNumberOfLines)
		set(\.textAlignment, fromStylesheet: \.multilineTextAlignment)
		lineBreakMode = .byWordWrapping
		//TODO: fonts
	}
	
	func watch<Puber:Publisher>(publisher:Puber) where Puber.Output == String {
		//this has to go in separate functions from the convenience inits due to a compiler bug involving demangling key path names from covariant Self
		//https://stackoverflow.com/questions/61137449/fatal-error-could-not-demangle-keypath-type
		set(\.text, fromPublisher: publisher)
	}
	
}

extension LocalizedStringKey {
	//there does not seem to be a correct way to go from a LocalizedStringKey to a resolved localized value
	var stringKey: String? {
		Mirror(reflecting: self).children.first(where: { $0.label == "key" })?.value as? String
	}
//
//	func stringValue(locale: Locale = .current) -> String? {
//		guard let stringKey = self.stringKey else { return nil }
//		let language = locale.languageCode
//		guard let path = Bundle.main.path(forResource: language, ofType: "lproj") else { return stringKey }
//		guard let bundle = Bundle(path: path) else { return stringKey }
//		let localizedString = NSLocalizedString(stringKey, bundle: bundle, comment: "")
//		return localizedString
//	}
}



extension UILabel {
	public var maxNumberOfLines:Int? {
		get {
			if numberOfLines == 0 {
				return nil
			}
			else {
				return numberOfLines
			}
		}
		set {
			if let intValue = newValue {
				numberOfLines = intValue
			}
			else {
				numberOfLines = 0
			}
		}
	}
}

