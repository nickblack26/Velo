import SwiftUI
import MapKit
import SwiftData
import SFSafeSymbols

enum CompanyTab: String, CaseIterable {
	case home, contacts, configurations
	
	var icon: String {
		switch self {
			case .home:
				"house"
			case .contacts:
				"person.2"
			case .configurations:
				"cable.coaxial"
		}
	}
}

fileprivate enum Tab: String, CaseIterable {
	case home, expenses, proposals
	
	var icon: SFSymbol {
		switch self {
			case .home:
				.house
			case .expenses:
				.dollarsign
			case .proposals:
				.textDocument
		}
	}
}

struct ContentView: View {
	@Environment(VeloManager.self) private var veloManager
	@Environment(\.modelContext) private var context
	@Environment(\.openWindow) private var openWindow
	
	@State private var selectedConfiguration: Configuration.ID?
	@State private var selectedContact: Contact.ID?
	@State private var selectedCompany: Company?
//	@State private var selectedTab: CompanyTab? = .home
	@State private var selectedExpenseReport: ExpenseReport? = ExpenseReport.example
	@State private var selectedTab: Tab? = .home
	
	@Query var openReports: [ExpenseReport]
	@Query var closedReports: [ExpenseReport]
	
	@State private var isPresented = false
	
	
	init() {
		let open = ExpenseReportStatus.Open.rawValue
		
		let openFilter = #Predicate<ExpenseReport> { budget in
			budget.rawStatus == open
		}
		let closedFilter = #Predicate<ExpenseReport> { budget in
			budget.rawStatus != open
		}
		print(openFilter, closedFilter)
		let sort: [SortDescriptor<Array<ExpenseReport>.Element>] = [.init(\ExpenseReport.dateStart, order: .reverse)]
		self._openReports = Query(sort: sort)
		self._closedReports = Query(sort: sort)
	}
	
	
	var body: some View {
		@Bindable var veloManager = veloManager
		NavigationSplitView {
			List(
				Tab.allCases,
				id: \.self,
				selection: $selectedTab
			) { tab in
				NavigationLink(value: tab) {
					Label(
						tab.rawValue.capitalized,
						systemImage: tab.icon.rawValue
					)
				}
			}
		} detail: {
			switch selectedTab {
				case .home:
					EmptyView()
				case .expenses:
					List {
						Section("Open") {
							ForEach(openReports.filter({ $0.status == .Open })) { expenseEntry in
								Button {
									openWindow(value: expenseEntry)
								} label: {
									HStack {
										Text(expenseEntry.searchValue)
										
										Spacer()
										
										Text(expenseEntry.calculatedTotal, format: .currency(code: Locale.current.currency?.identifier ?? "USD"))
									}
								}
								.buttonStyle(.plain)
								.contextMenu {
									Button("Delete", systemImage: "trash") {
										withAnimation {
											context.delete(expenseEntry)
										}
									}
								}
								.onDeleteCommand {
									withAnimation {
										context.delete(expenseEntry)
									}
								}
							}
						}
						
						Section("Closed") {
							ForEach(closedReports.filter({ $0.status != .Open })) { expenseEntry in
								Button {
									openWindow(value: expenseEntry)
								} label: {
									HStack {
										Text(expenseEntry.searchValue)
										
										Spacer()
										
										Text(expenseEntry.calculatedTotal, format: .currency(code: Locale.current.currency?.identifier ?? "USD"))
									}
								}
								.buttonStyle(.plain)
								.contextMenu {
									Button("Delete", systemImage: "trash") {
										withAnimation {
											context.delete(expenseEntry)
										}
									}
								}
								.onDeleteCommand {
									withAnimation {
										context.delete(expenseEntry)
									}
								}
							}
						}
					}
					.navigationDestination(for: ExpenseReport.self) { expenseReport in
						ExpenseReportDetailView(expenseReport)
					}
				case .proposals:
					ProposalsListView()
				case nil:
					EmptyView()
			}
		}
		.task {
			do {
				let items = try await ExpenseReport.getItems(queryItems: [
					.init(name: "conditions", value: "member/id = 310")
				])
				
				items.forEach { item in
					context.insert(item)
					try? context.save()
				}
			} catch {
				print(error)
			}
		}
		.navigationTitle("Expense Reports")
		.navigationSubtitle("Test")
		.toolbar {
			ToolbarItem {
				Button("Add item", systemImage: "plus") {
					let period = currentCalendarPeriod()
					withAnimation {
						context.insert(
							ExpenseReport(
								id: Int.random(in: 0...150_000),
								dateStart: period.0,
								dateEnd: period.1,
								dueDate: period.1,
								year: 2025,
								period: 1,
								total: 0
							)
						)
					}
				}
			}
			ToolbarItem {
				Button(
					"Share",
					systemImage: "rectangle.on.rectangle"
				) {
					isPresented.toggle()
					openWindow(id: SCREEN_SHARING_REQUEST_WINDOW_ID)
				}
			}
		}

		.floatingPanel(isPresented: $isPresented) {
			ScreenSharingNotificationRequest()
		}
			//            FetchableListView(
			//                selectedItem: $selectedExpenseReport,
			//                queryItems: [
			//                    .init(name: "conditions", value: "member/id = 310"),
			//                    .init(name: "orderBy", value: "dateStart desc")
			//                ]
			//            ) { item in
			//                NavigationLink(item.searchValue) {
			//                    ExpenseReportDetailView(expenseReport: item)
			//                }
			//            }
		
		
			//        .navigationSubtitle("Testing")
			//        NavigationSplitView {
			//            List(
			//                CompanyTab.allCases,
			//                id: \.self,
			//                selection: $selectedTab
			//            ) { tab in
			//                NavigationLink(
			//                    tab.rawValue.capitalized,
			//                    value: tab
			//                )
			//            }
			//            .toolbar {
			//                ToolbarItem {
			//                    Button(
			//                        "Choose a company",
			//                        systemImage: "building.2"
			//                    ) {
			//                        veloManager.currentCompanyId = nil
			//                    }
			//                }
			//            }
			//        } detail: {
			//            NavigationStack {
			//                switch selectedTab {
			//                case .home:
			//                    List {
			//                        Section {
			//                            Map()
			//                                .frame(minHeight: 300)
			//                        }
			//                    }
			//                    //                        .navigationTitle(selectedCompany.name)
			//                case .contacts:
			//                    FetchableListView<Contact, NavigationLink>(
			//                        selectedItem: $selectedContact,
			//                        queryItems: [
			//                            .init(
			//                                name: "conditions",
			//                                value: "company/id = \(veloManager.currentCompanyId ?? -1) and inactiveFlag = false"
			//                            ),
			//                            .init(
			//                                name: "childConditions",
			//                                value: "(types/id = 17 or types/id = 21)"
			//                            ),
			//                            .init(
			//                                name: "pageSize",
			//                                value: "1000"
			//                            ),
			//                            .init(
			//                                name: "orderBy",
			//                                value: "firstName"
			//                            )
			//                        ]
			//                    ) { contact in
			//                        NavigationLink(contact.name) { contact in
			//                            ContactDetailView()
			//                        }
			//                    }
			//                    .navigationTitle("Contacts")
			//                case .configurations:
			//                    FetchableListView<Configuration, NavigationLink>(
			//                        selectedItem: $selectedConfiguration,
			//                        queryItems: [
			//                            .init(
			//                                name: "conditions",
			//                                value: "status/id = 2 and company/id = \(veloManager.currentCompanyId ?? -1)"
			//                            ),
			//                            .init(
			//                                name: "pageSize",
			//                                value: "1000"
			//                            ),
			//                            .init(
			//                                name: "orderBy",
			//                                value: "name"
			//                            )
			//                        ]
			//                    ) { configuration in
			//                        NavigationLink {
			//                            ConfigurationDetailView(configurationId: configuration.id)
			//                        } label: {
			//                            VStack(alignment: .leading) {
			//                                Text(configuration.name)
			//                                Text("\(configuration.contact?.name ?? "") \(configuration.status?.name ?? "") \(configuration.type?.name ?? "")")
			//                                    .font(.caption)
			//                                    .foregroundStyle(.secondary)
			//                            }
			//                        }
			//                    }
			//                    .navigationTitle("Configurations")
			//                case .none:
			//                    VStack {
			//
			//                    }
			//                }
			//            }
			//            .navigationTitle(selectedCompany?.name ?? "Companies")
			//
			//        }
			//        .fullScreenCover(isPresented: .constant(veloManager.currentCompanyId == nil)) {
			//            NavigationStack {
			//                FetchableListView<Company, NavigationLink>(
			//                    selectedItem: $veloManager.currentCompanyId,
			//                    queryItems: [
			//                        .init(
			//                            name: "conditions",
			//                            value: "deletedFlag = false and status/id = 1"
			//                        ),
			//                        .init(
			//                            name: "childConditions",
			//                            value: "types/id = 1"
			//                        ),
			//                        .init(
			//                            name: "pageSize",
			//                            value: "1000"
			//                        ),
			//                        .init(
			//                            name: "orderBy",
			//                            value: "identifier"
			//                        )
			//                    ]
			//                ) { company in
			//                    NavigationLink(company.name, value: company.id)
			//                }
			//                .navigationTitle("Companies")
			//            }
			//        }
	}
}

extension Date {
	func startOfMonth() -> Date {
		return Calendar.current.date(
			from: Calendar.current.dateComponents([.year, .month, .day], from: Calendar.current.startOfDay(for: self))
		)!
	}
	
	func endOfMonth() -> Date {
		return Calendar.current.date(byAdding: DateComponents(month: 1, day: -1), to: self.startOfMonth())!
	}
}

enum CalendarPeriod {
	case firstHalf(start: Date, end: Date)
	case secondHalf(start: Date, end: Date)
}

func currentCalendarPeriod(for date: Date = Date(), calendar: Calendar = .current) -> (Date, Date) {
	let components = calendar.dateComponents([.year, .month, .day], from: date)
	guard let year = components.year, let month = components.month, let day = components.day else {
		fatalError("Invalid date components")
	}
	
	// First half: 1st–15th
	if day <= 15 {
		let start = calendar.date(from: DateComponents(year: year, month: month, day: 1))!
		let end = calendar.date(from: DateComponents(year: year, month: month, day: 15))!
		return (start, end)
	}
	
	// Second half: 16th–last day of month
	let start = calendar.date(from: DateComponents(year: year, month: month, day: 16))!
	let range = calendar.range(of: .day, in: .month, for: date)!
	let lastDay = range.count
	let end = calendar.date(from: DateComponents(year: year, month: month, day: lastDay))!
	return (start, end)
}

#Preview {
	@Previewable @State var env = VeloManager()
	
	ContentView()
		.environment(env)
}
