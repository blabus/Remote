//
//  SourceButton.swift
//  Remote
//
//  Created by Bill Labus on 5/28/16.
//  Copyright © 2016 Bill Labus. All rights reserved.
//

import UIKit

class SourceButton: UIView {
	var normalView:SourceButtonLayer?
	var highlightedView:SourceButtonLayer?
	
	override init(frame:CGRect) {
		super.init(frame:frame)
		setup()
	}
	
	required init(coder aDecoder:NSCoder) {
		super.init(coder:aDecoder)!
		setup()
	}
	
	private func setup() {
		self.backgroundColor = UIColor.clearColor()
		let views = NSBundle.mainBundle().loadNibNamed("SourceButtonLayer", owner:self, options:nil) as! [SourceButtonLayer]
		for view in views {
			if (view.tag == 0) {
				self.normalView = view
			} else if (view.tag == 1) {
				self.highlightedView = view
			}
			self.addSubview(view)
			view.frame = CGRectMake(1, 1, self.bounds.size.width - 2, self.bounds.size.height - 2)
			view.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
		}
	}
}
