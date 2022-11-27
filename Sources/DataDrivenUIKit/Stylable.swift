//
//  Stylable.swift
//  DataDrivenUIKit
//
//  Created by Benjamin Spratling on 11/1/22.
//

import Foundation
import UIKit
import Combine

/**
 To have a property on your UIView subclass updated from the stylesheet cascade, conform your view to Stylable and call this method for each property you want set ONCE
 ```
 convenience init() {
	init(frame:.zero)
	setUpStylesheetStyles()
 }
 func setUpStylesheetStyles() {
	set(\.textColor, fromStylesheet:\.foregroundColor)
 }
 ```
 */
extension Stylable where Self : UIView {
	public func set<ViewType, Value>(_ keyPath:ReferenceWritableKeyPath<ViewType, Value>, fromStylesheet stylesheetKey:KeyPath<StyleSheet, Value>) where ViewType == Self {
		let styleSetter = StylePropertySetting(viewKeyPath: keyPath, stylesheetKeyPath: stylesheetKey)
		self.stylePropertySetters.setters.append(styleSetter)
		styleSetter.update(in: self, with: self.stylesheet)
	}
}


extension Stylable {
	
	public func setting<ViewType, Value>(_ keyPath:ReferenceWritableKeyPath<ViewType, Value>, value:Value)->ViewType where ViewType == Self {
		self[keyPath: keyPath] = value
		return self
	}
	
}


/**
 To set a stylesheet property for subviews, call this method on a UIViiew, (it returns a view of a different type)
 */

extension UIView {
	public func style<Value>(_ key:WritableKeyPath<StyleSheet, Value>, value:Value)->some UIView {
		var sheet = self.stylesheet
		sheet[keyPath: key] = value
		updateFromStylesheet()
		return self
	}
	
	///This method will dynamically update a style sheet property from a publisher
	public func style<Value, Puber:Publisher>(_ key:WritableKeyPath<StyleSheet, Value>, from publisher:Puber)->UIView where Puber.Output == Value {
		publisher
			.receive(on: DispatchQueue.main)
			.sink { result in
				//this space intentionally left blank
			} receiveValue: { [weak self] value in
				guard let self else { return }
				var sheet = self.stylesheet
				sheet[keyPath: key] = value
				self.updateFromStylesheet()
			}
			.store(in: &stylePropertySetters.propertyPublisherCancellables)
		return self
	}
	
	///This method will dynamically update an optional style sheet property from a publisher
	public func style<Value, Puber:Publisher>(_ key:WritableKeyPath<StyleSheet, Value?>, from publisher:Puber)->UIView where Puber.Output == Value {
		publisher
			.receive(on: DispatchQueue.main)
			.sink { result in
				//this space intentionally left blank
			} receiveValue: { [weak self] value in
				guard let self else { return }
				var sheet = self.stylesheet
				sheet[keyPath: key] = value
				self.updateFromStylesheet()
			}
			.store(in: &stylePropertySetters.propertyPublisherCancellables)
		return self
	}
	
}


//MARK: - Creating your own style sheet properties

///To define custom properties on the StyleSheet, create an empty struct conforming to StyleSheetKey with a static default value
public protocol StyleSheetKey {
	associatedtype Value
	static var defaultValue:Value { get }
}



/**
 Then implement an extension on StyleSheet with a computed property
 which uses your StyleSheetKey type to set and get the values with the subscript
 */
public struct StyleSheet {
	
	//to be called in an extension on StyleSheet as a way of setting or getting a property value
	public subscript<Key:StyleSheetKey>(_ key:Key.Type)->Key.Value {
		get {
			//see if this values has a value set
			if let thisLevelValue = storage[key] {
				return thisLevelValue
			}
			//if not, try running up the chain
			if let sheet = view.superview?.stylesheet {
				return sheet[key]
			}
			//if not return the default
			return Key.defaultValue
		}
		nonmutating set {
			storage[key] = newValue
		}
	}
	
	private let storage:StyleSheetStorage
	private let view:UIView
	
	//the view is necessary to get the stuff up the cascade
	internal init(storage:StyleSheetStorage, view:UIView) {
		self.storage = storage
		self.view = view
	}
}



//-----------------------------------------------
//   all internal below here
//-----------------------------------------------

internal class StyleSheetStorage {
	//to be called in an extension on StyleSheet as a way of setting or getting a property value
	subscript<Key:StyleSheetKey>(_ key:Key.Type)->Key.Value? {
		get {
			if let thisValue = overrides[ObjectIdentifier(key)]
				,let converted = thisValue as? Key.Value
			{
				return converted
			}
			return nil
		}
		set {
			overrides[ObjectIdentifier(key)] = newValue
		}
	}
	private var overrides:[ObjectIdentifier:Any] = [:]
}


extension UIView {
	///if keys is nil, it means update everything, otherwise a focussed set of values to change
	internal func stylesheetDidUpdate(_ keys:Set<ObjectIdentifier>?) {
		//style myself
		let styleSheet = self.stylesheet
		let setters = self.stylePropertySetters.setters
		for setter in setters {
			setter.update(in: self, with: styleSheet)
		}
		
		//inform subviews
		for subview in subviews {
			subview.stylesheetDidUpdate(keys)
		}
	}
}


///conform your view to this protocol to be able to set values from the stylesheet
public protocol Stylable {
	///do not provide your own version of this
	func set<ViewType, Value>(_ keyPath:ReferenceWritableKeyPath<ViewType, Value>, fromStylesheet key:KeyPath<StyleSheet, Value>) where ViewType == Self
	
	///do not provide your own version of this
	func updateFromStylesheet()
}

extension UIView : Stylable {
	
}

extension Stylable where Self : UIView {
	
	//default implementation, do not override
	public func updateFromStylesheet() {
		stylesheetDidUpdate(nil)
	}
	
}

extension UIView {
	internal var stylesheet:StyleSheet {
		return StyleSheet(storage: stylePropertySetters.styleStorage, view: self)
	}
	
	@objc fileprivate var stylePropertySetters:StylePropertySetters {
		if let existingSetters = objc_getAssociatedObject(self, &styleSettersKey) as? StylePropertySetters {
			return existingSetters
		}
		else {
			let newSetters = StylePropertySetters()
			objc_setAssociatedObject(self, &styleSettersKey, newSetters, .OBJC_ASSOCIATION_RETAIN)
			newSetters.viewSuperviewPublisherCancellable = self.publisher(for: \.superview)
				.sink(receiveValue: { [weak self] newSuperView in
					self?.superviewPublisherDidChange()
			})
			return newSetters
		}
	}
	
	func superviewPublisherDidChange() {
		self.updateFromStylesheet()
	}
}

//key for the associated object of the view to hold a StylePropertySetters
fileprivate var styleSettersKey:String? = nil

//owned as an associated object of a uiview to hold type erased StylePropertySetting's
fileprivate class StylePropertySetters : NSObject {
	var setters:[StylePropertySettable] = []
	var viewSuperviewPublisherCancellable:AnyCancellable?
	var propertyPublisherCancellables:Set<AnyCancellable> = []
	var styleStorage:StyleSheetStorage = StyleSheetStorage()
}

//fully-typed and functional
fileprivate struct StylePropertySetting<ViewType:UIView, Value> {
	var viewKeyPath:ReferenceWritableKeyPath<ViewType, Value>
	var stylesheetKeyPath:KeyPath<StyleSheet, Value>
}

//type erasing protocol for holding StylePropertySetting of differenent specialized types in an array
fileprivate protocol StylePropertySettable {
	func update(in view:Stylable, with stylesheet:StyleSheet)
}

//actual functionality of the setting
extension StylePropertySetting : StylePropertySettable {
	fileprivate func update(in view:Stylable, with stylesheet:StyleSheet) {
		guard let selfView = view as? ViewType else { return }
		selfView[keyPath: viewKeyPath] = stylesheet[keyPath:stylesheetKeyPath]
	}
}

