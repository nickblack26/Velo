import SwiftUI
import LiveKit

struct KeypadItem {
	var label: String
	var value: String
}

let keypadItems: [KeypadItem] = [
	.init(label: "1", value: "1"),
	.init(label: "2", value: "2"),
	.init(label: "3", value: "3"),
	.init(label: "4", value: "4"),
]

struct ActiveRoomFooter: View {
	@State private var showKeypad: Bool = true
	@State private var showDirectory: Bool = false
	
	@EnvironmentObject var room: Room
	
    var body: some View {
		let localParticipant = room.localParticipant
		let isMuted = !localParticipant.isMicrophoneEnabled()
		
		VStack {
			HStack {
				Button(
					isMuted ? "Unmuted" : "Mute",
					systemImage: isMuted ? "microphone.slash.fill" : "microphone.fill"
				) {
					Task {
						do {
							try await room.localParticipant.setMicrophone(enabled: !isMuted)
							
						} catch {
							print("Failed to set microphone: \(error.localizedDescription)")
						}
					}
				}
				.buttonStyle(.borderedProminent)
				.tint(isMuted ? .red : .green)
				.labelStyle(.iconOnly)
				
				Spacer()
				
				Button(
					"\(showDirectory ? "Show" : "Hide") directory",
					systemImage: "person.2.badge.plus"
				) {
					
				}
				.buttonStyle(.borderedProminent)
				.labelStyle(.iconOnly)

				
				Button(
					"Show keypad",
					systemImage: "circle.grid.3x3.fill"
				) {
					
				}
				.buttonStyle(.borderedProminent)
				.labelStyle(.iconOnly)

				
				Button(
					"Show transfer",
					systemImage: "phone.arrow.up.right"
				) {
					
				}
				.buttonStyle(.borderedProminent)
				.labelStyle(.iconOnly)

				Spacer()
				
				Button(
					"Disconnect room",
					systemImage: "phone.down.fill"
				) {
					Task {
						await room.disconnect()
					}
				}
				.buttonStyle(.borderedProminent)
				.tint(.red)
				.labelStyle(.iconOnly)
			}
			
			if (showKeypad) {
				Grid {
					
					GridRow {
						VStack {}
						VStack {}
						VStack {}
					}
					
					ForEach(keypadItems, id: \.value) { keypadItem in
						let index = keypadItems.firstIndex {
							keypadItem.value == $0.value
						}
//						if let index && index.isMultiple(of: 3) {
//							let item = keypadItems.indices[keypadItem]
//							
//							GridRow {
//								Button(item.label) {
//									
//								}
//							}
//						}
					}
				}
			}
		}
		.padding()
    }
}

#Preview {
	@Previewable @State var roomCtx = RoomContext(store: sync)
	
    ActiveRoomFooter()
		.environment(roomCtx)
		.environmentObject(roomCtx.room)
}
