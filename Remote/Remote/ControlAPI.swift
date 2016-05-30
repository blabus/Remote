//
//  ControlAPI.swift
//  Remote
//
//  Created by Bill Labus on 5/29/16.
//  Copyright © 2016 Bill Labus. All rights reserved.
//

import Foundation
import UIKit

class ControlAPI {
	static let sharedInstance = ControlAPI()
	
	private let _receiverAddress:String?
	private let _tvAddress:String?
	private var _receiverOn:Bool = false
	private var _tvOn:Bool = false
	private var _pollingTimer:NSTimer?
	private var _sourceChangeEventListeners:[(selectedSource: Source?) -> Void] = []
	private var _volumeChangeEventListeners:[(volume: Float) -> Void] = []
	private var _muteChangeEventListeners:[(muted: Bool) -> Void] = []
	
	var sources:[Source] = []
	var selectedSource:Source?
	var volume:Float?
	var muted:Bool?
	
	init() {
		_receiverAddress = NSUserDefaults.standardUserDefaults().stringForKey("receiver_network_address")
		_tvAddress = NSUserDefaults.standardUserDefaults().stringForKey("tv_network_address")
		self.sources.append(Source.init(input: "HDMI1", label: "Apple TV", icon: UIImage.init(named: "source-appletv")!))
		self.sources.append(Source.init(input: "HDMI2", label: "Xbox", icon: UIImage.init(named: "source-xbox")!))
		self.sources.append(Source.init(input: "HDMI3", label: "PS4", icon: UIImage.init(named: "source-ps4")!))
		self.sources.append(Source.init(input: "HDMI4", label: "Wii", icon: UIImage.init(named: "source-wii")!))
		self.sources.append(Source.init(input: "HDMI5", label: "Blu-ray", icon: UIImage.init(named: "source-bluray")!))
		self.sources.append(Source.init(input: "HDMI6", label: "Cable", icon: UIImage.init(named: "source-cable")!))
		if (_receiverAddress != nil && _tvAddress != nil) {
			startUpdatingState()
		}
	}
	
	func startUpdatingState() {
		_pollingTimer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: #selector(ControlAPI._getState), userInfo: nil, repeats: true)
	}
	
	func stopUpdatingState() {
		_pollingTimer?.invalidate()
		_pollingTimer = nil
	}
	
	func _sendReceiverRequest(body: NSString?, completionHandler: (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void) {
		let session = NSURLSession.sharedSession()
		let request = NSMutableURLRequest(URL: NSURL(string: "http://\(_receiverAddress!)/YamahaRemoteControl/ctrl")!)
		request.HTTPMethod = "POST"
		request.cachePolicy = .ReloadIgnoringCacheData
		request.HTTPBody = body?.dataUsingEncoding(NSUTF8StringEncoding)
		let task = session.dataTaskWithRequest(request, completionHandler: completionHandler)
		task.resume()
	}
	
	@objc private func _getState() {
		var newReceiverOn:Bool?
		var newSelectedSource:Source?
		var newVolume:Float?
		var newMuted:Bool?
		let requestBody = "<YAMAHA_AV cmd=\"GET\"><Main_Zone><Basic_Status>GetParam</Basic_Status></Main_Zone></YAMAHA_AV>"
		_sendReceiverRequest(requestBody) { (data, response, error) in
			let xml = SWXMLHash.parse(data!)
			// Receiver Power
			let powerState = xml["YAMAHA_AV"]["Main_Zone"]["Basic_Status"]["Power_Control"]["Power"].element?.text!
			newReceiverOn = powerState == "On"
			// Receiver Input
			let inputState = xml["YAMAHA_AV"]["Main_Zone"]["Basic_Status"]["Input"]["Input_Sel"].element?.text!
			for source in self.sources {
				if (source.input == inputState) {
					newSelectedSource = source
					break
				}
			}
			// Volume
			let volumeState = xml["YAMAHA_AV"]["Main_Zone"]["Basic_Status"]["Volume"]["Lvl"]["Val"].element?.text!
			let decibalStr = (volumeState! as NSString).substringToIndex(volumeState!.characters.count - 1) + "." + (volumeState! as NSString).substringFromIndex(volumeState!.characters.count - 1)
			newVolume = (decibalStr as NSString).floatValue
			// Muted
			let mutedState = xml["YAMAHA_AV"]["Main_Zone"]["Basic_Status"]["Volume"]["Mute"].element?.text!
			newMuted = mutedState == "On"
			// Fire change events
			if (self._receiverOn != newReceiverOn) {
				self._receiverOn = newReceiverOn!
				for callback in self._sourceChangeEventListeners {
					callback(selectedSource: (self._receiverOn ? newSelectedSource! : nil))
				}
			} else if (self.selectedSource?.input != newSelectedSource?.input && self._receiverOn) {
				self.selectedSource = newSelectedSource
				for callback in self._sourceChangeEventListeners {
					callback(selectedSource: self.selectedSource)
				}
			}
			if (self.volume != newVolume) {
				self.volume = newVolume!
				for callback in self._volumeChangeEventListeners {
					callback(volume: self.volume!)
				}
			}
			if (self.muted != newMuted) {
				self.muted = newMuted!
				for callback in self._muteChangeEventListeners {
					callback(muted: self.muted!)
				}
			}
		}
	}
	
	func selectSource(source: Source?) {
		self.selectedSource = source
		let requestBody: String?
		if (self.selectedSource != nil) {
			requestBody = "<YAMAHA_AV cmd=\"PUT\"><Main_Zone><Power_Control><Power>On</Power></Power_Control><Input><Input_Sel>\(self.selectedSource!.input)</Input_Sel></Input></Main_Zone></YAMAHA_AV>"
		} else {
			requestBody = "<YAMAHA_AV cmd=\"PUT\"><Main_Zone><Power_Control><Power>Standby</Power></Power_Control></Main_Zone></YAMAHA_AV>"
		}
		_sendReceiverRequest(requestBody) { (data, response, error) in }
	}
	
	func setVolume(volume: Float) {
		self.volume = volume
	}
	
	func setMuted(muted: Bool) {
		self.muted = muted
	}
	
	func addSourceChangeListener(callback: (selectedSource: Source?)->()) {
		_sourceChangeEventListeners.append(callback)
	}
	
	func addVolumeChangeListener(callback: (volume: Float)->()) {
		_volumeChangeEventListeners.append(callback)
	}
	
	func addMuteChangeListener(callback: (muted: Bool)->()) {
		_muteChangeEventListeners.append(callback)
	}
}
