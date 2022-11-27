//
//  UIHStack.swift
//  
//
//  Created by Benjamin Spratling on 11/27/22.
//

import Foundation
import UIKit


///We're creating UIStackView's but initial in Swift looks identical to a static function call, so we'll just use that instead of creating new classes
///The view builder does not need you to return a UIStackView, just include UIView's and Gap's as needed and that special HStackBuilder will transform them into a UIStackView
/////TODO: add spacing as an option

public func UIHStack(alignment:UIStackView.Alignment = .center, @HStackBuilder horizontal subviews:()->(UIStackView))->UIStackView {
	let stack:UIStackView = subviews()
	stack.alignment = alignment
	return stack
}



@resultBuilder public struct HStackBuilder {
	
	static func buildExpression(_ expression: UIView) -> Component {
		return Component.view(expression)
	}
	
	static func buildExpression(_ expression: Gap) -> Component {
		return Component.gap(space: expression.space)
	}
	
	static func buildBlock(_ components: Component...) -> Component {
		if components.count == 1 {
			return components[0]
		}
		return .components(components)
	}
	
	static func buildFinalResult(_ component: HStackBuilder.Component) -> UIStackView {
		let stack = UIStackView(arrangedSubviews: component.allSubviews)
		stack.axis = .horizontal
		return stack
	}
	
	
	enum Component {
		case gap(space:CGFloat?)
		case view(UIView)
		case components([Component])
		
		var allSubviews:[UIView] {
			switch self {
			case .gap(space: let spaceOrNil):
				return [FixedDimensionalView(axis: .horizontal, value: spaceOrNil)]
				
			case .components(let subComponents):
				return subComponents.flatMap({ $0.allSubviews })
				
			case .view(let view):
				return [view]
			}
		}
	}
	
}
