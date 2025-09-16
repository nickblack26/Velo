//
//  AccessToken.swift
//  LiveKitExample
//
//  Created by Nick Black on 8/31/25.
//

import Foundation
import SwiftJWT

enum TrackSource: Int, Codable {
	case SOURCE_UNKNOWN = 0
	case SOURCE_CAMERA = 1
	case SOURCE_MICROPHONE = 2
	case SOURCE_SCREENSHARE = 3
	case SOURCE_SCREENSHARE_AUDIO = 4
}

struct AccessTokenOptions {
	/**
	 * amount of time before expiration
	 * expressed in seconds or a string describing a time span zeit/ms.
	 * eg: '2 days', '10h', or seconds as numeric value
	 */
	var ttl: Int?
	
	/**
	 * display name for the participant, available as `Participant.name`
	 */
	var name: String?;
	
	/**
	 * identity of the user, required for room join tokens
	 */
	var identity: String?;
	
	/**
	 * custom participant metadata
	 */
	var metadata: String?;
	
	/**
	 * custom participant attributes
	 */
//	var attributes?: Record<string, string>;
}

struct SIPGrant: Claims {
	/** manage sip resources */
	var admin: Bool?;
	
	/** make outbound calls */
	var call: Bool?;
}

struct VideoGrant: Claims {
	/** permission to create a room */
	var roomCreate: Bool?;
	
	/** permission to join a room as a participant, room must be set */
	var roomJoin: Bool?;
	
	/** permission to list rooms */
	var roomList: Bool?;
	
	/** permission to start a recording */
	var roomRecord: Bool?;
	
	/** permission to control a specific room, room must be set */
	var roomAdmin: Bool?;
	
	/** name of the room, must be set for admin or join permissions */
	var room: String?;
	
	/** permissions to control ingress, not specific to any room or ingress */
	var ingressAdmin: Bool?;
	
	/**
	 * allow participant to publish. If neither canPublish or canSubscribe is set,
	 * both publish and subscribe are enabled
	 */
	var canPublish: Bool?;
	
	/**
	 * TrackSource types that the participant is allowed to publish
	 * When set, it supersedes CanPublish. Only sources explicitly set here can be published
	 */
	var canPublishSources: [TrackSource]?;
	
	/** allow participant to subscribe to other tracks */
	var canSubscribe: Bool?;
	
	/**
	 * allow participants to publish data, defaults to true if not set
	 */
	var canPublishData: Bool?;
	
	/**
	 * by default, a participant is not allowed to update its own metadata
	 */
	var canUpdateOwnMetadata: Bool?;
	
	/** participant isn't visible to others */
	var hidden: Bool?;
	
	/** participant is recording the room, when set, allows room to indicate it's being recorded */
	var recorder: Bool?;
	
	/** participant allowed to connect to LiveKit as Agent Framework worker */
	var agent: Bool?;
	
	/** allow participant to subscribe to metrics */
	var canSubscribeMetrics: Bool?;
	
	/** destination room which this participant can forward to */
	var destinationRoom: String?;
}
