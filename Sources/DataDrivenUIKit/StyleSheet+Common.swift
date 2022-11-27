//
//  StyleSheet+Common.swift
//  
//
//  Created by Benjamin Spratling on 11/1/22.
//

import Foundation
import UIKit



extension StyleSheet {
	///like label text color
	public var foregroundColor:UIColor {
		get { self[UIForegroundColorKey.self] }
		set { self[UIForegroundColorKey.self] = newValue }
	}
}

internal struct UIForegroundColorKey : StyleSheetKey {
	static var defaultValue: UIColor = .label
}

extension StyleSheet {
	//nil means unlimited, default unlimited
	public var maxNumberOfLines:Int? {
		get { self[MaxNumberOfLinesKey.self] }
		set { self[MaxNumberOfLinesKey.self] = newValue }
	}
}

internal struct MaxNumberOfLinesKey : StyleSheetKey {
	static var defaultValue: Int? = nil
}

extension StyleSheet {
	public var multilineTextAlignment:NSTextAlignment {
		get { self[TextAlignmentKey.self] }
		set { self[TextAlignmentKey.self] = newValue }
	}
}


internal struct TextAlignmentKey : StyleSheetKey {
	static var defaultValue: NSTextAlignment = .natural
}

/*
 //TODO: write me
extension StyleSheet {
	public var font:DynamicFont {
		get { self[FontKey.self] }
		set { self[FontKey.self] = newValue }
	}
}

internal struct FontKey : StyleSheetKey {
	static var defaultValue: DynamicFont = .system(.body)
}
*/
