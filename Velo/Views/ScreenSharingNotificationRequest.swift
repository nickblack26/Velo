import SwiftUI
@preconcurrency import LiveKit
import LiveKitComponents

let wsURL = ProcessInfo.processInfo.environment["LIVEKIT_URL"]!
let token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE3NTA4ODkyMTYsImlzcyI6IkFQSUtkUnlMN2t6czlMOCIsIm5iZiI6MTc1MDg4MjAxNiwic3ViIjoicXVpY2tzdGFydCB1c2VyIHU2aWowaCIsInZpZGVvIjp7ImNhblB1Ymxpc2giOnRydWUsImNhblB1Ymxpc2hEYXRhIjp0cnVlLCJjYW5TdWJzY3JpYmUiOnRydWUsInJvb20iOiJxdWlja3N0YXJ0IHJvb20iLCJyb29tSm9pbiI6dHJ1ZX19.FbXR2MQtMlpG4FYgbWdk2THvuzZdV96koB8uqVwxGYA"

struct ScreenSharingNotificationRequest: View {
	var name: String = "Nick Black"

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

	/// An NSPanel subclass that implements floating panel traits.
class FloatingPanel<Content: View>: NSPanel {
	@Binding var isPresented: Bool

	init(
		view: () -> Content,
		contentRect: NSRect,
		backing: NSWindow.BackingStoreType = .buffered,
		defer flag: Bool = false,
		isPresented: Binding<Bool>
	) {
			/// Initialize the binding variable by assigning the whole value via an underscore
		self._isPresented = isPresented

			/// Init the window as usual
		super.init(
			contentRect: contentRect,
			styleMask: [
				.titled,
				.nonactivatingPanel,
				.fullSizeContentView,
				//                .resizable,
				.closable,
			],
			backing: backing,
			defer: flag
		)

			/// Allow the panel to be on top of other windows
		isFloatingPanel = true
		level = .mainMenu + 3

			/// Allow the pannel to be overlaid in a fullscreen space
		collectionBehavior.insert(.fullScreenAuxiliary)
		collectionBehavior.insert(.canJoinAllSpaces)

			/// Don't show a window title, even if it's set
		titleVisibility = .hidden
		titlebarAppearsTransparent = true

			/// Since there is no title bar make the window moveable by dragging on the background
		isMovableByWindowBackground = false

			/// Keep the panel around after closing since I expect the user to open/close it often
		self.isReleasedWhenClosed = false

			/// Hide when unfocused
		hidesOnDeactivate = true

			/// Hide all traffic light buttons
		standardWindowButton(.closeButton)?.isHidden = true
		standardWindowButton(.miniaturizeButton)?.isHidden = true
		standardWindowButton(.zoomButton)?.isHidden = true

			// Set the background color
		if let contentView {
			contentView.wantsLayer = true
				//			contentView.layer?.backgroundColor = NSColor(named: "Muted Background")?.cgColor
			contentView.layer?.backgroundColor = NSColor.clear.cgColor // 1. Clear background color
		}

			/// Sets animations accordingly
		animationBehavior = .utilityWindow

			/// Set the content view.
			/// The safe area is ignored because the title bar still interferes with the geometry
		contentView = NSHostingView(rootView: view()
			.ignoresSafeArea()
			.environment(\.floatingPanel, self))
	}

	override func center() {
		let rect = self.screen?.frame
		self.setFrameOrigin(
			NSPoint(
				x: (rect!.width-self.frame.size.width)/2,
				y: (rect!.height-self.frame.size.height)/2
			)
		)
	}

		/// Close automatically when out of focus, e.g. outside click
	override func resignMain() {
		super.resignMain()
		close()
	}

		/// Close and toggle presentation, so that it matches the current state of the panel
	override func close() {
		super.close()
		isPresented = false
	}

		/// `canBecomeKey` and `canBecomeMain` are both required so that text inputs inside the panel can receive focus
	override var canBecomeKey: Bool {
		return true
	}

	override var canBecomeMain: Bool {
		return true
	}
}

private struct FloatingPanelKey: EnvironmentKey {
	static let defaultValue: NSPanel? = nil
}

extension EnvironmentValues {
	var floatingPanel: NSPanel? {
		get { self[FloatingPanelKey.self] }
		set { self[FloatingPanelKey.self] = newValue }
	}
}

	/// Add a  ``FloatingPanel`` to a view hierarchy
struct FloatingPanelModifier<PanelContent: View>: ViewModifier {
		/// Determines wheter the panel should be presented or not
	@Binding var isPresented: Bool

		/// Determines the starting size of the panel
	var contentRect: CGRect = CGRect(
		x: 0,
		y: 0,
		width: 750,
		height: 437
	)

		/// Holds the panel content's view closure
	@ViewBuilder let view: () -> PanelContent

		/// Stores the panel instance with the same generic type as the view closure
	@State var panel: FloatingPanel<PanelContent>?

	func body(content: Content) -> some View {
		content
			.onAppear {
					/// When the view appears, create, center and present the panel if ordered
				panel = FloatingPanel(
					view: view,
					contentRect: contentRect,
					isPresented: $isPresented
				)

					//				panel?.center()
				if isPresented {
					present()
				}
			}
			.onDisappear {
					/// When the view disappears, close and kill the panel
				panel?.close()
				panel = nil
			}
			.onChange(of: isPresented) { _, value in
					/// On change of the presentation state, make the panel react accordingly
				if value {
					present()
				} else {
					panel?.close()
				}
			}
	}

		/// Present the panel and make it the key window
	func present() {
		panel?.orderFront(nil)
			//		panel?.center()
		panel?.makeKey()
	}
}

extension View {
	/** Present a ``FloatingPanel`` in SwiftUI fashion
	 - Parameter isPresented: A boolean binding that keeps track of the panel's presentation state
	 - Parameter contentRect: The initial content frame of the window
	 - Parameter content: The displayed content
	 **/
	func floatingPanel<Content: View>(
		isPresented: Binding<Bool>,
		contentRect: CGRect = CGRect(
			x: 0,
			y: 0,
			width: 250,
			height: 140
		),
		@ViewBuilder content: @escaping () -> Content
	) -> some View {
		self.modifier(
			FloatingPanelModifier(
				isPresented: isPresented,
				contentRect: contentRect,
				view: content
			)
		)
	}
}
