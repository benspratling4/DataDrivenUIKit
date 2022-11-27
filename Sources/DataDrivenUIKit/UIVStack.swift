//
//  UIVStack.swift
//  
//
//  Created by Benjamin Spratling on 11/27/22.
//

import Foundation
import UIKit


//TODO: add spacing as an option

//The VStackBuilder takes a closure which includes either UIView or Gap and transforms it into a UIStackView with a .vertical .axis
public func UIVStack(alignment:UIStackView.Alignment = .center, @VStackBuilder vertical subviews:()->(UIStackView))->UIStackView {
	let stack:UIStackView = subviews()
	stack.alignment = alignment
	return stack
}




@resultBuilder public struct VStackBuilder {
	
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
	
	static func buildFinalResult(_ component: VStackBuilder.Component) -> UIStackView {
		let stack = UIStackView(arrangedSubviews: component.allSubviews)
		stack.axis = .vertical
		return stack
	}
	
	
	enum Component {
		case gap(space:CGFloat?)
		case view(UIView)
		case components([Component])
		
		var allSubviews:[UIView] {
			switch self {
			case .gap(space: let spaceOrNil):
				return [FixedDimensionalView(axis: .vertical, value: spaceOrNil)]
				
			case .components(let subComponents):
				return subComponents.flatMap({ $0.allSubviews })
				
			case .view(let view):
				return [view]
			}
		}
	}
	
}
