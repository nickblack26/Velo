	//
	//  AthenaManager.swift
	//  Velo
	//
	//  Created by Nick Black on 9/9/25.
	//

import Foundation
import LiveKit

@Observable
final class AthenaManager {
	var isInEngagement: Bool = false
	var activeEngagement: Room?
	
	init() {}
	
	func connectToEngagement(
		with token: String,
		roomOptions: RoomOptions = .init(
			defaultCameraCaptureOptions: CameraCaptureOptions(
				dimensions: .h1080_169
			),
			defaultScreenShareCaptureOptions: ScreenShareCaptureOptions(
				dimensions: .h1080_169,
				appAudio: true,
				useBroadcastExtension: true
			),
			defaultVideoPublishOptions: VideoPublishOptions(
				simulcast: true
			),
			adaptiveStream: true,
			dynacast: true,
			//			e2eeOptions: .init(keyProvider: <#T##BaseKeyProvider#>)
			//			 isE2eeEnabled: true,
			//			e2eeOptions: e2eeOptions,
			reportRemoteTrackStatistics: true
		),
		connectOptions: ConnectOptions = .init(
			autoSubscribe: true,
			enableMicrophone: true
		)
	) async throws {
		let room = Room()
		let keyProvider = BaseKeyProvider(isSharedKey: true)
		let key = await sync.value.e2eeKey
		keyProvider.setKey(key: key)
			//		e2eeOptions = E2EEOptions(keyProvider: keyProvider)
		try await room.connect(
			url: sync.value.url,
			token: sync.value.token,
			connectOptions: connectOptions,
			roomOptions: roomOptions
		)
		
		self.activeEngagement = room
	}
	
	func createEngagement(
		_ roomOptions: RoomOptions = .init(
			defaultCameraCaptureOptions: CameraCaptureOptions(
				dimensions: .h1080_169
			),
			defaultScreenShareCaptureOptions: ScreenShareCaptureOptions(
				dimensions: .h1080_169,
				appAudio: true,
				useBroadcastExtension: true
			),
			defaultVideoPublishOptions: VideoPublishOptions(
				simulcast: true
			),
			adaptiveStream: true,
			dynacast: true,
			//			e2eeOptions: .init(keyProvider: <#T##BaseKeyProvider#>)
			//			 isE2eeEnabled: true,
			//			e2eeOptions: e2eeOptions,
			reportRemoteTrackStatistics: true
		),
		_ connectOptions: ConnectOptions = .init(
			autoSubscribe: true,
			enableMicrophone: true
		)
	) async throws {
		let room = Room()
		let keyProvider = BaseKeyProvider(isSharedKey: true)
		let key = await sync.value.e2eeKey
		keyProvider.setKey(key: key)
			//		e2eeOptions = E2EEOptions(keyProvider: keyProvider)
		try await room.connect(
			url: sync.value.url,
			token: sync.value.token,
			connectOptions: connectOptions,
			roomOptions: roomOptions
		)
		
		self.activeEngagement = room
	}
}
