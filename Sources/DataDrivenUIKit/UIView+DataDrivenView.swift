//
//  UIView+DataDriven.swift
//  
//
//  Created by Benjamin Spratling on 11/1/22.
//

import Foundation
import UIKit
import Combine



public protocol DataDrivenView : UIView {
	
	func set<ViewType, Value, PublishType:Publisher>(_ keyPath:ReferenceWritableKeyPath<ViewType, Value>, fromPublisher publisher:PublishType) where ViewType == Self , PublishType.Output == Value
	
	func set<ViewType, Value, PublishType:Publisher>(_ keyPath:ReferenceWritableKeyPath<ViewType, Value?>, fromPublisher publisher:PublishType) where ViewType == Self , PublishType.Output == Value
}

extension DataDrivenView {
	
	public func set<ViewType, Value, PublishType:Publisher>(_ keyPath:ReferenceWritableKeyPath<ViewType, Value>, fromPublisher publisher:PublishType) where ViewType == Self , PublishType.Output == Value {
		publisherUpdatingSetters.setters.append(PublisherUpdatingSetter(viewKeyPath: keyPath, publisher: publisher, view: self))
	}
	
	public func set<ViewType, Value, PublishType:Publisher>(_ keyPath:ReferenceWritableKeyPath<ViewType, Value?>, fromPublisher publisher:PublishType) where ViewType == Self , PublishType.Output == Value {
		publisherUpdatingSetters.setters.append(PublisherUpdatingSetterOptional(viewKeyPath: keyPath, publisher: publisher, view: self))
	}
}


extension UIView {
	@objc internal var publisherUpdatingSetters:PublisherUpdatingSetters {
		if let existingSetters = objc_getAssociatedObject(self, &publisherUpdatingKey) as? PublisherUpdatingSetters {
			return existingSetters
		}
		else {
			let newSetters = PublisherUpdatingSetters()
			objc_setAssociatedObject(self, &publisherUpdatingKey, newSetters, .OBJC_ASSOCIATION_RETAIN)
			return newSetters
		}
	}
}

fileprivate var publisherUpdatingKey :String? = nil

internal class PublisherUpdatingSetters : NSObject {
	var setters:[PublisherUpdatingSettable] = []
}

internal protocol PublisherUpdatingSettable {
	//force an update
}

internal class PublisherUpdatingSetter<ViewType, Value> : PublisherUpdatingSettable  where ViewType : UIView {
	
	init<Puber:Publisher>(viewKeyPath:ReferenceWritableKeyPath<ViewType, Value>, publisher:Puber, view:ViewType) where Puber.Output == Value {
		self.viewKeyPath = viewKeyPath
		self.view = view
		cancellable = publisher
			.receive(on: DispatchQueue.main)
			.sink(receiveCompletion: { result in
				//this space intentionally left blank
			}, receiveValue: { [weak self] value in
				if let view = self?.view {
					self?.update(view: view, with: value)
				}
			})
	}
	
	var cancellable:AnyCancellable?
	weak var view:ViewType?
	
	func update(view:ViewType, with value:Value) {
		view[keyPath: viewKeyPath] = value
		//TODO: tell table view super views I need re-layout
	}
	
	var viewKeyPath:ReferenceWritableKeyPath<ViewType, Value>
	
}

internal class PublisherUpdatingSetterOptional<ViewType, Value> : PublisherUpdatingSettable where ViewType : UIView {
	
	init<Puber:Publisher>(viewKeyPath:ReferenceWritableKeyPath<ViewType, Value?>, publisher:Puber, view:ViewType) where Puber.Output == Value {
		self.viewKeyPath = viewKeyPath
		self.view = view
		cancellable = publisher
			.receive(on: DispatchQueue.main)
			.sink(receiveCompletion: { result in
				//this space intentionally left blank
			}, receiveValue: { [weak self] value in
				if let view = self?.view {
					self?.update(view: view, with: value)
				}
			})
	}
	
	var cancellable:AnyCancellable?
	weak var view:ViewType?
	
	
	func update(view:ViewType, with value:Value) {
		view[keyPath: viewKeyPath] = value
		//TODO: tell table view super views I need re-layout
	}
	
	var viewKeyPath:ReferenceWritableKeyPath<ViewType, Value?>
	
}
