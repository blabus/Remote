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
	private let _minVolume:Float = -80
	private var _maxVolume:Float?
	private var _receiverOn:Bool = false
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
		_maxVolume = NSUserDefaults.standardUserDefaults().floatForKey("max_volume")
		_maxVolume = round(max(min(_maxVolume!, 16.5), _minVolume) * 2) / 2
		NSUserDefaults.standardUserDefaults().setFloat(_maxVolume!, forKey: "max_volume")
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
	
	@objc func startUpdatingState() {
		_getState()
		dispatch_async(dispatch_get_main_queue(), {
			self._pollingTimer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: #selector(self._getState), userInfo: nil, repeats: true)
		})
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
	
	func _sendTVRequest(body: [String: AnyObject]?, completionHandler: (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void) {
		let session = NSURLSession.sharedSession()
		let request = NSMutableURLRequest(URL: NSURL(string: "http://\(_tvAddress!)/sony/system")!)
		request.HTTPMethod = "POST"
		request.cachePolicy = .ReloadIgnoringCacheData
		request.addValue("sony-livingroom", forHTTPHeaderField: "X-Auth-PSK")
		request.addValue("application/json", forHTTPHeaderField: "Content-Type")
		do { request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(body!, options: NSJSONWritingOptions()) } catch { print(error) }
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
					dispatch_async(dispatch_get_main_queue(), {
						callback(selectedSource: (self._receiverOn ? newSelectedSource : nil))
					})
				}
			} else if (self.selectedSource?.input != newSelectedSource?.input && self._receiverOn) {
				self.selectedSource = newSelectedSource
				for callback in self._sourceChangeEventListeners {
					dispatch_async(dispatch_get_main_queue(), {
						callback(selectedSource: self.selectedSource)
					})
				}
			}
			if (self.volume != newVolume) {
				self.volume = newVolume!
				for callback in self._volumeChangeEventListeners {
					dispatch_async(dispatch_get_main_queue(), {
						callback(volume: self.volume!)
					})
				}
			}
			if (self.muted != newMuted) {
				self.muted = newMuted!
				for callback in self._muteChangeEventListeners {
					dispatch_async(dispatch_get_main_queue(), {
						callback(muted: self.muted!)
					})
				}
			}
		}
	}
	
	func selectSource(source: Source?) {
		stopUpdatingState()
		self.selectedSource = source
		let requestBody: String?
		if (self.selectedSource != nil) {
			requestBody = "<YAMAHA_AV cmd=\"PUT\"><Main_Zone><Power_Control><Power>On</Power></Power_Control><Input><Input_Sel>\(self.selectedSource!.input)</Input_Sel></Input></Main_Zone></YAMAHA_AV>"
			_setTVOn(true)
		} else {
			requestBody = "<YAMAHA_AV cmd=\"PUT\"><Main_Zone><Power_Control><Power>Standby</Power></Power_Control></Main_Zone></YAMAHA_AV>"
			_setTVOn(false)
		}
		_sendReceiverRequest(requestBody) { (data, response, error) in
			dispatch_async(dispatch_get_main_queue(), { // Delay restarting the polling to wait for receiver to switch inputs
				NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(self.startUpdatingState), userInfo: nil, repeats: false)
			})
		}
	}
	
	func setVolume(volume: Float) {
		self.volume = max(min(volume, _maxVolume!), _minVolume)
		let volumeStr = "\(Int(self.volume! * 10))"
		_sendReceiverRequest("<YAMAHA_AV cmd=\"PUT\"><Main_Zone><Volume><Lvl><Val>\(volumeStr)</Val><Exp>1</Exp><Unit>dB</Unit></Lvl></Volume></Main_Zone></YAMAHA_AV>") { (data, response, error) in }
	}
	
	func setMuted(muted: Bool) {
		self.muted = muted
	}
	
	func _setTVOn(on: Bool) {
		let requestBody = [
			"id": 2,
			"method": "setPowerStatus",
			"version": "1.0",
			"params": [["status": on]]
		]
		_sendTVRequest(requestBody) { (data, response, error) in }
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
