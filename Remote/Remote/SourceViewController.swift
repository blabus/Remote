//
//  SourceViewController.swift
//  Remote
//
//  Created by Bill Labus on 5/8/16.
//  Copyright © 2016 Bill Labus. All rights reserved.
//

import UIKit

class SourceViewController: UIViewController {
	var sourceButtons:[SourceButton] = []
	private let api = ControlAPI.sharedInstance
	
	@IBOutlet var volumeControlContainer:UIView?
	var volumeControl:VolumeControl?
	
	override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
		super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
		
		func sourceButtons(rootView: UIView) -> [SourceButton] {
			var buttonArray = [SourceButton]()
			for subview in rootView.subviews {
				buttonArray += sourceButtons(subview)
				
				if subview is SourceButton {
					buttonArray.append(subview as! SourceButton)
				}
			}
			return buttonArray
		}
		self.sourceButtons = sourceButtons(self.view)
		for sourceButton in self.sourceButtons {
			let source = api.sources[sourceButton.tag]
			sourceButton.icon = source.icon
			sourceButton.label = source.label
		}
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		ControlAPI.sharedInstance.addSourceChangeListener(_onSourceChange)
		
		volumeControl = NSBundle.mainBundle().loadNibNamed("VolumeControl", owner:self, options:nil).first as? VolumeControl
		volumeControlContainer!.addSubview(volumeControl!)
		volumeControl!.frame = CGRectMake(0, 0, volumeControlContainer!.bounds.size.width, volumeControlContainer!.bounds.size.height)
		volumeControl!.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
	}
	
	private func _onSourceChange(selectedSource: Source?) {
		var sourceIndex = ControlAPI.sharedInstance.sources.indexOf({ (source) -> Bool in
			return source.input == selectedSource?.input
		})
		if (sourceIndex == nil) {
			sourceIndex = -1
		}
		for (index, button) in self.sourceButtons.enumerate() {
			button.setSelected(index == sourceIndex!, position: nil, animated: true)
		}
	}
	
	@IBAction func sourceTapped(button: SourceButton) {
		let source:Source = ControlAPI.sharedInstance.sources[button.tag]
		if (button.selected) {
			ControlAPI.sharedInstance.selectedSource = source
			for sourceButton in self.sourceButtons { // Deselect all other buttons
				if (sourceButton != button) {
					sourceButton.setSelected(false, position: nil, animated: true)
				}
			}
		} else {
			ControlAPI.sharedInstance.selectedSource = nil
		}
	}
}