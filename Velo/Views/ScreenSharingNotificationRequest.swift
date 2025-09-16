import SwiftUI
@preconcurrency import LiveKit
import LiveKitComponents

let wsURL = ProcessInfo.processInfo.environment["LIVEKIT_URL"]!
let token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE3NTA4ODk1ODMsImlzcyI6IkFQSUtkUnlMN2t6czlMOCIsIm5iZiI6MTc1MDg4ODY4Mywic3ViIjoibmJsYWNrIiwidmlkZW8iOnsiY2FuVXBkYXRlT3duTWV0YWRhdGEiOnRydWUsInJvb20iOiJyb29tVGVzdCIsInJvb21Kb2luIjp0cnVlLCJyb29tTGlzdCI6dHJ1ZX19.67max9b-q8fefJcB1Rx9t-zF9t5x7SSJouphD4myvKA"

struct ScreenSharingNotificationRequest: View {
	var name: String = "Nick Black"
	@Environment(\.dismissWindow) private var dismissWindow

	@StateObject private var room: Room

	init() {
		let room = Room()
		_room = StateObject(wrappedValue: room)
	}

	var body: some View {
		Group {
			if room.connectionState == .disconnected {
				VStack(
					alignment: .leading,
					spacing: 10
				) {
					Text("Request access")
						.font(.title2)
						.fontWeight(.semibold)

					Text("Confirm the action to request access to your computer from \(name).")

					HStack(spacing: 10) {
						Button {
							Task {
								do {
									try await room.connect(
										url: wsURL,
										token: token,
										connectOptions: ConnectOptions(enableMicrophone: true)
									)
									try await room.localParticipant.setScreenShare(enabled: true)
								} catch {
									print("Failed to connect to LiveKit: \(error)")
								}
							}
						} label: {
							Text("Accept")
								.frame(maxWidth: .infinity)
								.padding(5)
								.fontWeight(.medium)
						}
						.buttonStyle(.borderedProminent)
						.tint(.green)

						Button {
							dismissWindow(id: SCREEN_SHARING_REQUEST_WINDOW_ID)
						} label: {
							Text("Decline")
								.frame(maxWidth: .infinity)
								.padding(5)
								.fontWeight(.medium)
						}
						.buttonStyle(.borderedProminent)
						.tint(.red)
					}
				}

			} else {
				LazyVStack {
					ForEachParticipant { _ in
						VStack {
							ForEachTrack(filter: .video) { trackReference in
								VideoTrackView(trackReference: trackReference)
									.frame(width: 500, height: 500)
							}
						}
					}
				}
			}
		}
		.padding()
		.frame(
			width: room.connectionState == .disconnected ? 250 : 500,
			height: room.connectionState != .disconnected ? 500 : nil
		)
		
		.environmentObject(room)
	}
}

#Preview {
	ScreenSharingNotificationRequest()
}

import Cocoa

final class ScreenNotification: NSPanel {
	init(contentRect: NSRect) {
		super.init(
			contentRect: contentRect,
			styleMask: [.borderless, .nonactivatingPanel],
			backing: .buffered,
			defer: false
		)

			// Setting window level
		self.level = .mainMenu + 1

			// Make it non-resizable and non-closable

		self.isFloatingPanel = true
		self.collectionBehavior = [.canJoinAllSpaces, .ignoresCycle]

			// Make it non-activating so it doesn't take focus
		self.isReleasedWhenClosed = false
		self.isMovableByWindowBackground = false
		self.isOpaque = false
		self.hasShadow = false
		self.backgroundColor = NSColor.clear

			// Create the content view
		let contentView = NSView(frame: contentRect)
		contentView.wantsLayer = true
		contentView.layer?.backgroundColor = NSColor.clear.cgColor // 1. Clear background color
		self.contentView = contentView

			// Create the closed button
		let icon = NSImage(systemSymbolName: "xmark", accessibilityDescription: nil)!
		let closeButton = NSButton(image: icon, target: self, action: #selector(closePanel))
		closeButton.bezelStyle = .circular
		closeButton.wantsLayer = true
		closeButton.layer?.cornerRadius = 5
		closeButton.layer?.masksToBounds = true

		let messageLabel = NSTextField(labelWithString: "This is a full screen notification")

		let messageContainer = NSView()
		messageContainer.layer?.backgroundColor = NSColor.black.cgColor
		messageContainer.layer?.cornerRadius = 10
		messageContainer.translatesAutoresizingMaskIntoConstraints = false
		messageContainer.addSubview(messageLabel)
		messageContainer.addSubview(closeButton)
		contentView.addSubview(messageContainer)

		let padding: CGFloat = 40
			// Add the message container constraints
		NSLayoutConstraint.activate([
			messageLabel.leadingAnchor.constraint(equalTo: messageContainer.leadingAnchor, constant: padding),
			messageLabel.trailingAnchor.constraint(equalTo: messageContainer.trailingAnchor, constant: -padding),
			messageLabel.topAnchor.constraint(equalTo: messageContainer.topAnchor, constant: padding),
			messageLabel.bottomAnchor.constraint(equalTo: messageContainer.bottomAnchor, constant: -padding),

			messageContainer.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
			messageContainer.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
		])

			// Add click gesture recognizer to the message container
		let clickRecognizer = NSClickGestureRecognizer(target: self, action: #selector(closePanel))
		messageLabel.addGestureRecognizer(clickRecognizer)

			// Initial state for fade-in animation
		self.alphaValue = 0
	}

	func show(animated: Bool = true, duration: Int? = 10) {
		self.orderFront(nil)
		if animated {
			NSAnimationContext.runAnimationGroup({ context in
				context.duration = 0.3
				context.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
				self.animator().alphaValue = 1.0
			}) {
				if let duration {
					DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(duration)) {
						self.closeWithFadeOutAnimation()
					}
				}
			}
		} else {
			self.alphaValue = 1.0
			if let duration {
				DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(duration)) {
					self.closeWithFadeOutAnimation()
				}
			}
		}
	}

	@objc func closePanel() {
		print("Closing!")
		closeWithFadeOutAnimation()
	}

	func closeWithFadeOutAnimation() {
		NSAnimationContext.runAnimationGroup({ context in
			context.duration = 0.3
			context.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
			self.animator().alphaValue = 0.0
		}) {
			self.orderOut(nil)
		}
	}

	static var shared: ScreenNotification!

	public static func showNotification(duration: Int = 10) {
		guard let screen = NSScreen.main else { return }

		let screenRect = screen.frame
		if shared == nil {
			shared = ScreenNotification(contentRect: screenRect)
		}
		shared.show(animated: true, duration: duration)
	}

	public static func hideNotification() {
		guard let shared else { return }
		shared.closeWithFadeOutAnimation()
	}
}
