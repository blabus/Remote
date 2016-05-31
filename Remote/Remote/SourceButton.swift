//
//  SourceButton.swift
//  Remote
//
//  Created by Bill Labus on 5/28/16.
//  Copyright © 2016 Bill Labus. All rights reserved.
//

import UIKit

class SourceButton: UIControl {
	var normalView:SourceButtonLayer?
	var highlightedView:SourceButtonLayer?
	var highlightMaskLayer:CAShapeLayer?
	private var _icon:UIImage?
	private var _label:String?
	
	var icon:UIImage? {
		get {
			return _icon
		}
		set {
			_icon = newValue
			self.normalView?.iconImageView.image = _icon
			self.highlightedView?.iconImageView.image = _icon
		}
	}
	
	var label:String? {
		get {
			return _label
		}
		set {
			_label = newValue
			self.normalView?.label.text = _label
			self.highlightedView?.label.text = _label
		}
	}
	
	override init(frame:CGRect) {
		super.init(frame:frame)
		setup()
	}
	
	required init(coder aDecoder:NSCoder) {
		super.init(coder:aDecoder)!
		setup()
	}
	
	override func awakeFromNib() {
		self.highlightMaskLayer = CAShapeLayer()
		self.highlightMaskLayer!.fillColor = UIColor.blackColor().CGColor
		self.highlightedView!.layer.addSublayer(self.highlightMaskLayer!)
		self.highlightedView!.layer.mask = self.highlightMaskLayer!
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
		if (CGRectContainsPoint(self.highlightedView!.bounds, origin)) {
			setSelected(!self.selected, position: origin, animated: true)
			self.sendActionsForControlEvents(UIControlEvents.ValueChanged)
		}
	}
	
	func setSelected(selected: Bool, position: CGPoint?, animated: Bool) {
		if (self.selected != selected) {
			self.selected = selected
			var origin = position
			if (origin == nil) {
				origin = CGPointMake(self.highlightedView!.bounds.size.width / 2, self.highlightedView!.bounds.size.height / 2)
			}
			
			let startDiameter:CGFloat = selected ? 0 : radiusForOrigin(origin!) * 2
			let startRect = CGRectMake(origin!.x - startDiameter / 2, origin!.y - startDiameter / 2, startDiameter, startDiameter)
			let startPath = UIBezierPath.init(ovalInRect: startRect).CGPath
			self.highlightMaskLayer!.path = startPath
			
			let endDiameter = selected ? radiusForOrigin(origin!) * 2 : 0
			let endRect = CGRectMake(origin!.x - endDiameter / 2, origin!.y - endDiameter / 2, endDiameter, endDiameter)
			let endPath = UIBezierPath.init(ovalInRect: endRect).CGPath
			
			let animation = CABasicAnimation.init(keyPath: "path")
			animation.fillMode = kCAFillModeForwards
			animation.removedOnCompletion = false
			animation.toValue = endPath
			animation.duration = animated ? 0.4 : 0
			animation.timingFunction = CAMediaTimingFunction.init(controlPoints: 0.75, 0.0, 0.25, 1.00)
			self.highlightMaskLayer!.addAnimation(animation, forKey: animation.keyPath)
		}
	}
	
	func radiusForOrigin(origin: CGPoint) -> CGFloat {
		let centerX = origin.x > self.highlightedView!.bounds.size.width / 2 ? origin.x : self.highlightedView!.bounds.size.width - origin.x
		let centerY = origin.y > self.highlightedView!.bounds.size.height / 2 ? origin.y : self.highlightedView!.bounds.size.height - origin.y
		return sqrt(pow(centerX, 2) + pow(centerY, 2))
	}
}
