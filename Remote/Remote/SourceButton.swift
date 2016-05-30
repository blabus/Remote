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
	var highlightMaskLayer:CAShapeLayer?
	var highlighted:Bool = false
	
	override init(frame:CGRect) {
		super.init(frame:frame)
		setup()
	}
	
	required init(coder aDecoder:NSCoder) {
		super.init(coder:aDecoder)!
		setup()
	}
	
	override func didMoveToSuperview() {
		if (self.highlightMaskLayer == nil) {
			self.highlightMaskLayer = CAShapeLayer()
			self.highlightMaskLayer!.fillColor = UIColor.blackColor().CGColor
			self.highlightedView!.layer.addSublayer(self.highlightMaskLayer!)
			self.highlightedView!.layer.mask = self.highlightMaskLayer!
		}
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
	
	override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
		let touch = touches.first
		let origin = touch!.locationInView(self.normalView)
		setHighlighted(true, position: origin, animated: true)
	}
	
	func setHighlighted(highlighted: Bool, position: CGPoint?, animated: Bool) {
		self.highlighted = highlighted
		var origin = position
		if (origin == nil) {
			origin = CGPointMake(self.highlightedView!.bounds.size.width / 2, self.highlightedView!.bounds.size.height / 2)
		}
		if (self.highlighted) {
			let startDiameter:CGFloat = 0
			let startRect = CGRectMake(origin!.x - startDiameter / 2, origin!.y - startDiameter / 2, startDiameter, startDiameter)
			let startPath = UIBezierPath.init(ovalInRect: startRect).CGPath
			self.highlightMaskLayer!.path = startPath
			
			let endDiameter = radiusForOrigin(origin!) * 2
			let endRect = CGRectMake(origin!.x - endDiameter / 2, origin!.y - endDiameter / 2, endDiameter, endDiameter)
			let endPath = UIBezierPath.init(ovalInRect: endRect).CGPath
			
			let animation = CABasicAnimation.init(keyPath: "path")
			animation.fillMode = kCAFillModeForwards
			animation.removedOnCompletion = false
			animation.toValue = endPath
			animation.duration = 0.35
			animation.timingFunction = CAMediaTimingFunction.init(name: kCAMediaTimingFunctionEaseInEaseOut)
			self.highlightMaskLayer!.addAnimation(animation, forKey: animation.keyPath)
		} else {
			
		}
	}
	
	func radiusForOrigin(origin: CGPoint) -> CGFloat {
		let centerX = origin.x > self.highlightedView!.bounds.size.width / 2 ? origin.x : self.highlightedView!.bounds.size.width - origin.x
		let centerY = origin.y > self.highlightedView!.bounds.size.height / 2 ? origin.y : self.highlightedView!.bounds.size.height - origin.y
		return sqrt(pow(centerX, 2) + pow(centerY, 2))
	}
}
