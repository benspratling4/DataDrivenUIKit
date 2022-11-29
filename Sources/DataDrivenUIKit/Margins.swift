//
//  File.swift
//  
//
//  Created by Benjamin Spratling on 11/28/22.
//

import Foundation
import UIKit



extension UIView {
	
	///Add some margin around a view, for layout purposes only
	public func margins(_ padding:NSDirectionalEdgeInsets = NSDirectionalEdgeInsets(equal: 10.0))->some UIView {
		return MarginView(content: self, padding: padding)
	}
	
	///draws a color behind a view (Wraps self in a MarginView if self isn't one already.)
	public func backgroundColor(_ color:UIColor)->UIView {
		if let marginsSelf = self as? MarginalView {
			marginsSelf.backgroundColor = color
			return self
		}
		else {
			let marginView = MarginView(content: self, padding: .zero)
			marginView.backgroundColor = color
			return marginView
		}
	}
	
	///Clip the corners to the specified radius.  (Wraps self in a MarginView if self isn't one already.)
	public func cornerRadius(_ radius:CGFloat, corners:UIRectCorner = .allCorners)->UIView {
		let margins = self as? MarginalView ?? MarginView(content: self, padding: .zero)
		margins.clipsToBounds = true
		margins.layer.cornerRadius = radius
		margins.layer.maskedCorners = CACornerMask(corners)
		return margins
	}
	
	///Draw a border around a view
	public func borderColor(_ color:UIColor, width:CGFloat = 1.0)->UIView {
		let margins = self as? MarginalView ?? MarginView(content: self, padding: .zero)
		margins.clipsToBounds = true
		margins.layer.borderColor = color.cgColor
		margins.layer.borderWidth = width
		return margins
	}
	
}


extension NSDirectionalEdgeInsets {
	//must be public because it is a default value
	public init(equal:CGFloat) {
		self.init(top: equal, leading: equal, bottom: equal, trailing: equal)
	}
}

extension CACornerMask {
	init(_ rectCorner:UIRectCorner) {
		self.init(rawValue: 0)
		if rectCorner.contains(.bottomLeft) {
			insert(.layerMinXMaxYCorner)
		}
		if rectCorner.contains(.topLeft) {
			insert(.layerMinXMinYCorner)
		}
		if rectCorner.contains(.bottomRight) {
			insert(.layerMaxXMaxYCorner)
		}
		if rectCorner.contains(.topRight) {
			insert(.layerMaxXMinYCorner)
		}
	}
}

public class MarginView<Content : UIView> : UIView {
	
	public init(content:Content, padding:NSDirectionalEdgeInsets) {
		content.translatesAutoresizingMaskIntoConstraints = false
		self.padding = padding
		self.content = content
		super.init(frame: .zero)
		setUp()
	}
	
	public let content:Content
	
	var padding:NSDirectionalEdgeInsets
	
	func setUp() {
		addSubview(content)
		content.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding.leading).isActive = true
		trailingAnchor.constraint(equalTo: content.trailingAnchor, constant: padding.trailing).isActive = true
		content.topAnchor.constraint(equalTo: topAnchor, constant: padding.top).isActive = true
		bottomAnchor.constraint(equalTo: content.bottomAnchor, constant: padding.bottom).isActive = true
	}
	
	
	//MARK: - UIView overrides
	
	public required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}


internal protocol MarginalView : UIView {
	
}

extension MarginView : MarginalView {
	
}

