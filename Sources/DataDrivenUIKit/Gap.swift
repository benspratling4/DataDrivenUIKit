//
//  Gap.swift
//  
//
//  Created by Benjamin Spratling on 11/27/22.
//

import Foundation
import UIKit



public struct Gap {
	///a fixed space
	public init(_ space:CGFloat) {
		self.space = space
	}
	
	///flex space
	public init() {
		self.space = nil
	}
	
	internal var space:CGFloat?
	
	//TODO: support dynamic spacing from a publisher
}


internal class FixedDimensionalView : UIView {
	
	init(axis:Axis, value:CGFloat?) {
		self.axis = axis
		self.value = value
		super.init(frame: .zero)
		establishConstraints()
	}
	
	typealias Axis = NSLayoutConstraint.Axis
	
	var axis:Axis
	var value:CGFloat?
	
	func establishConstraints() {
		switch (axis, value) {
		case (.horizontal, nil):
			setContentHuggingPriority(UILayoutPriority(1.0), for: .horizontal)
			
		case (.vertical, nil):
			setContentHuggingPriority(UILayoutPriority(1.0), for: .vertical)
			
		case (.horizontal, .some( let space)):
			addConstraint(widthAnchor.constraint(equalToConstant: space))
			
		case (.vertical, .some(let space)):
			addConstraint(heightAnchor.constraint(equalToConstant: space))
			
		@unknown default:
			break
		}
	}
	
	
	//MARK: - UIView overrides
	
	@available(*, deprecated, message:"DO NOT CALL")
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
