//
//  VolumeControl.swift
//  Remote
//
//  Created by Bill Labus on 5/30/16.
//  Copyright © 2016 Bill Labus. All rights reserved.
//

import UIKit

class VolumeControl: UIView {
	@IBOutlet var volumeUpButton:UIButton?
	@IBOutlet var volumeDownButton:UIButton?
	
	override func awakeFromNib() {
		ControlAPI.sharedInstance.addVolumeChangeListener(onVolumeChange)
		ControlAPI.sharedInstance.addMuteChangeListener(onMuteChange)
	}
	
	func onVolumeChange(volume: Float) {
		print(volume)
	}
	
	func onMuteChange(muted: Bool) {
		if (muted) {
			volumeDownButton?.setImage(UIImage.init(named: "volume-mute"), forState: .Normal)
		} else {
			volumeDownButton?.setImage(UIImage.init(named: "volume-down"), forState: .Normal)
		}
	}
}
