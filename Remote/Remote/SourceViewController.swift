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
		ControlAPI.sharedInstance.addSourceChangeListener { (selectedSource) in
			var sourceIndex = ControlAPI.sharedInstance.sources.indexOf({ (source) -> Bool in
				return source.input == selectedSource?.input
			})
			if (sourceIndex == nil) {
				sourceIndex = -1
			}
			for (index, button) in self.sourceButtons.enumerate() {
				dispatch_async(dispatch_get_main_queue(),{
					button.setSelected(index == sourceIndex!, position: nil, animated: true)
				})
			}
		}
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
	}
	
	@IBAction func sourceTapped(button: SourceButton) {
		let source:Source = ControlAPI.sharedInstance.sources[button.tag]
		if (button.selected) {
			ControlAPI.sharedInstance.selectSource(source)
			for sourceButton in self.sourceButtons { // Deselect all other buttons
				if (sourceButton != button) {
					sourceButton.setSelected(false, position: nil, animated: true)
				}
			}
		} else {
			ControlAPI.sharedInstance.selectSource(nil)
		}
	}
}