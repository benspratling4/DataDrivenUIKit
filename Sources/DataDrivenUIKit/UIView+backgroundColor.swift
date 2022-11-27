//
//  File.swift
//  
//
//  Created by Benjamin Spratling on 11/26/22.
//

import Foundation
import UIKit


///with UIView's you often don't want to set everything to the same background color, you often want lots of transparent subviews, with a container setting the background.
extension UIView {
	convenience init(backgroundColor:UIColor) {
		self.init(frame:.zero)
		self.backgroundColor = backgroundColor
	}
}
