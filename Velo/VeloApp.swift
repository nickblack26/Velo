import SwiftUI
import Combine
import LiveKitComponents
import SwiftData

@main
struct VeloApp: App {
	@Environment(\.openWindow) private var openWindow
	
	@StateObject var appCtx = AppContext(store: sync)
	@StateObject private var manager = StatusItemManager()
	
	@State private var veloManager = VeloManager()
	@State private var liveKitManager = LiveKitManager()
	@State private var socketDelegate = WebsocketManager()
	@State private var authManager = AuthenticationManager()
	@State private var athenaManager = AthenaManager()
	
	@State private var isPresented = false
	
	var container: ModelContainer {
		do {
			return try .init(
				for: ExpenseEntry.self, ExpenseReport.self,
				configurations: .init(isStoredInMemoryOnly: false),
			)
		} catch {
			fatalError()
		}
	}
	
	var body: some Scene {
		WindowGroup {
			if authManager.isAuthenticated {
				ContentView()
					.environmentObject(appCtx)
					.onAppear {
						self.socketDelegate.connect()
						self.socketDelegate.on(event: .initalized) {
							print("Initialized happened")
						}
					}
					.preferredColorScheme(.dark)
				
			} else {
				LoginView()
					.background(.black, ignoresSafeAreaEdges: .all)
					.preferredColorScheme(.dark)
			}
		}
		.environment(authManager)
		.environment(athenaManager)
		.environment(veloManager)
		.handlesExternalEvents(matching: Set(arrayLiteral: "*"))
		.windowStyle(.hiddenTitleBar)
		.modelContainer(container)
		.commandsRemoved()
		.commands {
			ExpenseReportCommandsView()
		}
		
		Window("Active Engagement", id: ACTIVE_ENGAGEMENT_ID) {
			if let engagement = athenaManager.activeEngagement {
				RoomContextView()
					.environmentObject(appCtx)
			}
		}
		.environment(authManager)
		.environment(athenaManager)
		.environment(veloManager)
		.windowStyle(.hiddenTitleBar)
		.restorationBehavior(.disabled)
		.modelContainer(container)
		
//		WindowGroup(for: Room.self) { engagement in
//			if let engagement = engagement.wrappedValue {
//				RoomContextView()
//					.environmentObject(appCtx)
//			}
//		}
//		.environment(veloManager)
//		.windowStyle(.hiddenTitleBar)
//		.restorationBehavior(.disabled)
//		.modelContainer(container)
		
		WindowGroup(for: ExpenseReport.self) { expenseReport in
			if let expenseReport = expenseReport.wrappedValue {
				NavigationStack {
					ExpenseReportDetailView(expenseReport)
				}
			}
		}
		.environment(veloManager)
		.windowStyle(.hiddenTitleBar)
		.restorationBehavior(.disabled)
		.modelContainer(container)
		
		WindowGroup(for: Proposal.self) { proposal in
			if let proposal = proposal.wrappedValue {
				
			}
		}
		.environment(veloManager)
		.windowStyle(.hiddenTitleBar)
		.restorationBehavior(.disabled)
		.modelContainer(container)
		
		WindowGroup(id: SCREEN_SHARING_REQUEST_WINDOW_ID) {
			ScreenSharingNotificationRequest()
				.background(.thinMaterial)
				.toolbarVisibility(.hidden, for: .windowToolbar)
				.containerBackground(.clear, for: .window)
		}
		.windowStyle(.plain)
		.windowResizability(.contentSize)
		.windowLevel(.floating)
		.modelContainer(container)
		.restorationBehavior(.disabled)
		.defaultWindowPlacement { content, context in
			let viewSize = content.sizeThatFits(.init(context.defaultDisplay.visibleRect.size))
			return .init(.init(x: 0.995, y: 0), size: viewSize)
		}
	}
}

	//				.onAppear {
	//					manager.createStatusItem()
	//				}
	//				.floatingPanel(isPresented: $isPresented) {
	//					ScreenSharingNotificationRequest()
	//				}
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
			
				//			Button {
				//				menuShown.toggle()
				//			} label: {
				//				Divider()
				//			}
				//			.buttonStyle(StatusItemButtonStyle())
			
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

//extension Room: @retroactive Decodable {}
//extension Room: @retroactive Encodable {}

