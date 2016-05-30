//
//  SourceViewController.swift
//  Remote
//
//  Created by Bill Labus on 5/8/16.
//  Copyright © 2016 Bill Labus. All rights reserved.
//

import UIKit

class SourceViewController: UIViewController {
	var sources:[Source] = []
	var sourceButtons:[SourceButton] = []
	
	override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
		super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
		self.sources.append(Source.init(input: "HDMI1", label: "Apple TV", icon: UIImage.init(named: "source-appletv")!))
		self.sources.append(Source.init(input: "HDMI2", label: "Xbox", icon: UIImage.init(named: "source-xbox")!))
		self.sources.append(Source.init(input: "HDMI3", label: "PS4", icon: UIImage.init(named: "source-ps4")!))
		self.sources.append(Source.init(input: "HDMI4", label: "Wii", icon: UIImage.init(named: "source-wii")!))
		self.sources.append(Source.init(input: "HDMI5", label: "Blu-ray", icon: UIImage.init(named: "source-bluray")!))
		self.sources.append(Source.init(input: "HDMI6", label: "Cable", icon: UIImage.init(named: "source-cable")!))
		
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
			let source = self.sources[sourceButton.tag]
			sourceButton.icon = source.icon
			sourceButton.label = source.label
		}
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
	}
	
	@IBAction func sourceTapped(button: SourceButton) {
		//let source:Source = self.sources[button.tag]
		if (button.selected) {
			// TODO: SELECT SOURCE
			for sourceButton in self.sourceButtons { // Deselect all other buttons
				if (sourceButton != button) {
					sourceButton.setSelected(false, position: nil, animated: true)
				}
			}
		} else {
			// TODO: POWER OFF
		}
	}
}