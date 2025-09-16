import Foundation
import UserNotifications
import Starscream

protocol PayloadData: Codable {}

struct InitPayload: PayloadData {
	var tokenLifetime: Int
	var workspaceSid: String
	var accountSid: String
	var channelId: String
}

enum PayloadEventType: String, Codable {
	case initalized = "init"
	case reservationCreated = "reservation.created"
	case workerActivityUpdated = "worker.activity.update"
}

struct PayloadEventTypeSwitcher: Decodable {
	var eventType: PayloadEventType
}

struct ReservationPayload: Decodable {
	var sid: String
	var workerSid: String
}

struct ReservationPayloadEvent: Decodable {
	var payload: ReservationPayload
}

@Observable
final class WebsocketManager: NSObject, WebSocketDelegate {
	let center = UNUserNotificationCenter.current()

	var socket: WebSocket!
	var event: WebSocketEvent?
	var isConnected: Bool = false
	let server = WebSocketServer()
	var token: String = ""
	var request: URLRequest!
	var decoder: JSONDecoder {
		let d = JSONDecoder()
		d.keyDecodingStrategy = .convertFromSnakeCase
		return d
	}
	
	override init() {
		super.init()
		guard let baseUrl = URL(string: "ws://127.0.0.1:54321/functions/v1/engagement-event-bridge") else {
			fatalError()
		}
		
		var components = URLComponents(
			url: baseUrl,
			resolvingAgainstBaseURL: true
		)!
		
		components.queryItems = [
			.init(name: "token", value: ""),
			.init(name: "closeExistingSessions", value: "true"),
			.init(name: "clientVersion", value: "2.0.11"),
		]
		
		guard let url = components.url else { fatalError() }
		
		self.request = URLRequest(url: url)
		self.request.timeoutInterval = 5
		self.request
			.setValue(
				SUPABASE_URL?.absoluteString,
				forHTTPHeaderField: "Origin"
			)
	}
	
	func didReceive(event: Starscream.WebSocketEvent, client: any Starscream.WebSocketClient) {
		self.event = event
		switch event {
			case .connected(let headers):
				isConnected = true
				print("websocket is connected: \(headers)")
			case .disconnected(let reason, let code):
				isConnected = false
				print("websocket is disconnected: \(reason) with code: \(code)")
			case .text(let string):
				print("Received text: \(string)")
				
				if let value = string.data(using: .utf8), string != " " {
					do {
						let decoded = try decoder.decode(PayloadEventTypeSwitcher.self, from: value)
						print(decoded.eventType)
						switch decoded.eventType {
							case .reservationCreated: do {
								if let decodedReservation = try? decoder.decode(ReservationPayloadEvent.self, from: value) {
									let content = UNMutableNotificationContent()
									content.title = "Incoming Call"
									content.body = "Call from (901) 598-8651"
									content.categoryIdentifier = INCOMING_RESERVATION_CATEGORY_IDENTIFIER
									content.userInfo = [
										"reservation_sid": decodedReservation.payload.sid,
										"worker_sid": decodedReservation.payload.workerSid
									]
									content.sound = UNNotificationSound.default
									
									print(decodedReservation)
									
									let request = UNNotificationRequest(identifier: "incoming-reseration", content: content, trigger: nil)
									center.add(request)
								}
							}
							default:
								break
						}
					} catch {
						print(error)
					}
				} else {
					
				}
			case .binary(let data):
				print("Received data: \(data.count)")
			case .ping(_):
				break
			case .pong(_):
				break
			case .viabilityChanged(_):
				break
			case .reconnectSuggested(_):
				break
			case .cancelled:
				isConnected = false
			case .error(let error):
				isConnected = false
//				handleError(error)
				print(error)
			case .peerClosed:
				break
		}
	}
	
	func connect() {
		socket = WebSocket(request: self.request)
		socket.delegate = self
		socket.connect()
	}
	
	func on(event: PayloadEventType, _ handleEvent: () -> Void) {
		
	}
}
