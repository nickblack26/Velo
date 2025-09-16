//
//  Config.swift
//  Velo
//
//  Created by Nick Black on 9/9/25.
//

import Foundation
import KeychainAccess
import LiveKit

let SCREEN_SHARING_REQUEST_WINDOW_ID: String = "screenSharingRequest"
let ACTIVE_ENGAGEMENT_ID: String = "active-engagement"

@MainActor
let sync = ValueStore<Preferences>(
	store: Keychain(service: "io.livekit.example.SwiftSDK.1"),
	key: "preferences",
	default: Preferences()
)

// MARK: Incoming Reservation Notification
let INCOMING_RESERVATION_CATEGORY_IDENTIFIER = "INCOMING_RESERVATION"
let ACCEPT_INCOMING_RESERVATION_IDENTIFIER = "ACCEPT_RESERVATION_ACTION"
let REJECT_INCOMING_RESERVATION_IDENTIFIER = "REJECT_RESERVATION_ACTION"

let TWILIO_ACCOUNT_SID = ProcessInfo.processInfo.environment["TWILIO_ACCOUNT_SID"]!
let TWILIO_AUTH_TOKEN = ProcessInfo.processInfo.environment["TWILIO_AUTH_TOKEN"]!

var taskrouterRequest: URLRequest {
	var r = URLRequest(url: URL(string: "https://taskrouter.twilio.com/v1/Workspaces/")!)
	r.allHTTPHeaderFields = [
		"Authorization" : "Basic \("\(TWILIO_ACCOUNT_SID):\(TWILIO_AUTH_TOKEN)".toBase64())"
	]
	return r
}
