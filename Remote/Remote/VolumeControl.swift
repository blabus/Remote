//
//  VolumeControl.swift
//  Remote
//
//  Created by Bill Labus on 5/30/16.
//  Copyright © 2016 Bill Labus. All rights reserved.
//

import UIKit

class VolumeControl: UIView {
	@IBOutlet weak var volumeUpButton:UIButton?
	@IBOutlet weak var volumeDownButton:UIButton?
	@IBOutlet weak var sliderContainerView:UIView?
	@IBOutlet weak var sliderHandleView:UIView?
	@IBOutlet weak var sliderFillView:UIView?
	@IBOutlet weak var sliderFillHeightConstraint: NSLayoutConstraint!
	
	private var _volume:Float = 0
	private var _muted = false
	private let _panRecognizer = UIPanGestureRecognizer()
	
	override func awakeFromNib() {
		ControlAPI.sharedInstance.addVolumeChangeListener(onVolumeChange)
		ControlAPI.sharedInstance.addMuteChangeListener(onMuteChange)
		
		_panRecognizer.addTarget(self, action: #selector(_onPan))
		sliderHandleView?.addGestureRecognizer(_panRecognizer)
	}
	
	private func _setVolume(volume: Float, animated: Bool = false) {
		if (_muted) {
			_muted = false
			_updateMuteUI()
		}
		ControlAPI.sharedInstance.volume = volume
		_setSliderValue(volume, animated: animated)
	}
	
	@objc private func _onPan(recognizer: UIPanGestureRecognizer) {
		let relativeValue = Float(min(max(1 - recognizer.locationInView(sliderContainerView).y / sliderContainerView!.bounds.size.height, 0), 1))
		switch recognizer.state {
		case .Began:
			ControlAPI.sharedInstance.stopUpdatingState()
		case .Changed:
			_setVolume(relativeValue)
		case .Ended:
			ControlAPI.sharedInstance.startUpdatingStateAfterDelay(1)
		default:
			break
		}
	}
	
	func onVolumeChange(volume: Float) {
		_volume = volume
		_setSliderValue(_volume, animated: true)
	}
	
	func onMuteChange(muted: Bool) {
		_muted = muted
		_updateMuteUI()
	}
	
	@IBAction func volumeUpButtonTapped() {
		_volume = ControlAPI.sharedInstance.volume + 0.02
		_setVolume(_volume, animated: true)
	}
	
	@IBAction func muteButtonTapped() {
		_muted = !_muted
		_updateMuteUI()
		ControlAPI.sharedInstance.muted = _muted
	}
	
	private func _setSliderValue(value: Float, animated: Bool) {
		let fillHeight = self.sliderContainerView!.bounds.size.height * CGFloat.init(max(min(value, 1), 0))
		sliderFillHeightConstraint.constant = fillHeight
		if (animated) {
			self.setNeedsUpdateConstraints()
			UIView.animateWithDuration(0.35) {
				self.layoutIfNeeded()
			}
		}
	}
	
	private func _updateMuteUI() {
		UIView.animateWithDuration(0.35) { 
			self.sliderFillView!.backgroundColor = self._muted ? UIColor.init(red: 89/255, green: 105/255, blue: 122/255, alpha: 1) : UIColor.whiteColor()
		}
		if (_muted) {
			volumeDownButton?.setImage(UIImage.init(named: "volume-mute"), forState: .Normal)
		} else {
			volumeDownButton?.setImage(UIImage.init(named: "volume-down"), forState: .Normal)
		}
	}
}
