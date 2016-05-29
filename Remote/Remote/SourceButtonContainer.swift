//
//  SourceButtonContainer.swift
//  Remote
//
//  Created by Bill Labus on 5/28/16.
//  Copyright © 2016 Bill Labus. All rights reserved.
//

import UIKit

class SourceButtonContainer: UIView {
	var sourceButton:SourceButton?
	
	override init(frame:CGRect) {
		super.init(frame:frame)
		loadFromNib()
	}
	
	required init(coder aDecoder:NSCoder) {
		super.init(coder:aDecoder)!
		loadFromNib()
	}
	
	private func loadFromNib() {
		self.sourceButton = NSBundle.mainBundle().loadNibNamed("SourceButton", owner:self, options:nil).first as? SourceButton
		self.addSubview(self.sourceButton!)
		self.sourceButton!.frame = self.bounds
		self.sourceButton!.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
	}
}
