import Foundation
import Observation
import LiveKit

@Observable
final class LiveKitManager {
	var activeRoom: Room?

	var rooms: [Room] = []
}
