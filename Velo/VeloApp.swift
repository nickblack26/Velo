import SwiftUI
import Combine
import LiveKitComponents

@main
struct VeloApp: App {
	@State private var veloManager = VeloManager()
	@State private var liveKitManager = LiveKitManager()

	@StateObject private var manager = StatusItemManager()

	@State private var isPresented = false

	var body: some Scene {
		WindowGroup {
			VStack {
				Button("Show") {
					self.isPresented.toggle()
				}

				ContentView()
			}
			.environment(veloManager)
			.onAppear {
				manager.createStatusItem()
			}
			.floatingPanel(isPresented: $isPresented) {
				ScreenSharingNotificationRequest()
			}
		}
	}
}

final class StatusItemManager: ObservableObject {
	private var hostingView: NSHostingView<StatusItem>?
	private var statusItem: NSStatusItem?

	private var sizePassthrough = PassthroughSubject<CGSize, Never>()
	private var sizeCancellable: AnyCancellable?

	func createStatusItem() {
		let statusItem: NSStatusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
		let hostingView = NSHostingView(rootView: StatusItem(sizePassthrough: sizePassthrough))
		hostingView.frame = NSRect(x: 0, y: 0, width: 80, height: 24)
		statusItem.button?.frame = hostingView.frame
		statusItem.button?.addSubview(hostingView)

		self.statusItem = statusItem
		self.hostingView = hostingView

		sizeCancellable = sizePassthrough.sink { [weak self] size in
			let frame = NSRect(origin: .zero, size: .init(width: size.width, height: 24))
			self?.hostingView?.frame = frame
			self?.statusItem?.button?.frame = frame
		}
	}
}

private struct SizePreferenceKey: PreferenceKey {
	static var defaultValue: CGSize = .zero
	static func reduce(value: inout CGSize, nextValue: () -> CGSize) { value = nextValue() }
}

struct StatusItem: View {
	var sizePassthrough: PassthroughSubject<CGSize, Never>
	@State private var showCallers: Bool = false
	@State private var micOn: Bool = false
	@State private var videoOn: Bool = false
	@State private var menuShown: Bool = false

	@ViewBuilder
	var mainContent: some View {
		HStack(spacing: 0) {
			Button(
				"Toggle Microphone",
				systemImage: micOn ? "mic.slash.fill" : "mic.fill"
			) {
				withAnimation(.snappy(duration: 0.125)) {
					micOn.toggle()
				}
			}
			.buttonStyle(StatusItemButtonStyle(toggleBoolean: $micOn))

			Button(
				"Toggle Video",
				systemImage: videoOn ? "video.slash.fill" : "video.fill"
			) {
				withAnimation(.snappy(duration: 0.125)) {
					videoOn.toggle()
				}
			}
			.buttonStyle(StatusItemButtonStyle(toggleBoolean: $videoOn))

			Button {
				menuShown.toggle()
			} label: {
				Divider()
			}
			.buttonStyle(StatusItemButtonStyle())

				//            if showCallers {
				//                Button {
				//                    menuShown.toggle()
				//                } label: {
				//                    HStack(spacing: -5) {
				//                        Image(.nick)
				//                            .resizable()
				//                            .clipShape(Circle())
				//
				//                        Image(.nick)
				//                            .resizable()
				//                            .clipShape(Circle())
				//                    }
				//                }
				//                .buttonStyle(StatusItemButtonStyle())
				//            }
		}
		.popover(isPresented: $menuShown) {
			Image(systemName: "hand.wave")
				.resizable()
				.frame(width: 100, height: 100)
				.padding()
		}
		.background(.accent)
		.clipShape(RoundedRectangle(cornerRadius: 5))
		.fixedSize()
		.task {
			try! await Task.sleep(for: .seconds(5))
			withAnimation {
				self.showCallers = true
			}
		}
	}

	var body: some View {
		mainContent
			.overlay(
				GeometryReader { geometryProxy in
					Color.clear
						.preference(key: SizePreferenceKey.self, value: geometryProxy.size)
				}
			)
			.onPreferenceChange(SizePreferenceKey.self, perform: { size in
				sizePassthrough.send(size)
			})
	}
}

struct StatusItemButtonStyle: ButtonStyle {
	var toggleBoolean: Binding<Bool>? = nil

	func makeBody(configuration: ButtonStyleConfiguration) -> some View {
		configuration.label
			.padding(5)
			.labelStyle(.iconOnly)
			.symbolRenderingMode(toggleBoolean?.wrappedValue != nil && toggleBoolean!.wrappedValue ? .hierarchical : .monochrome)
			.foregroundColor(.white)
			.frame(maxHeight: .infinity)
			.background(
				RoundedRectangle(cornerRadius: 5)
					.fill(Color.white.opacity(configuration.isPressed ? 0.25 : 0))
			)
	}
}
