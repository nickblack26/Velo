import SwiftUI
import SwiftData

struct ExpenseReportDetailView: View {
	@Environment(\.modelContext) var context
	@Environment(\.dismissWindow) var dismissWindow
	
	@State private var showDeleteAlert: Bool = false
    
	@Bindable var expenseReport: ExpenseReport
		
	@Query var entries: [ExpenseEntry]
	
	init(
		_ expenseReport: ExpenseReport,
	) {
		self.expenseReport = expenseReport
		self._entries = Query(
			filter: #Predicate<ExpenseEntry> { item in
				item.expenseReport.id == expenseReport.id
			},
			sort: [.init(\ExpenseEntry.date, order: .reverse)]
		)
	}
    
    var body: some View {
		List {
			Section {
				HStack {
					MetricView {
						DatePicker(
							"Date",
							selection: $expenseReport.dateStart,
							displayedComponents: .date
						)
					}

					MetricView {
						DatePicker(
							"Date",
							selection: $expenseReport.dateEnd,
							displayedComponents: .date
						)
					}
				}
			}
			
			Section("Expense Entries") {
				ForEach(entries) { item in
					NavigationLink {
						ExpenseEntryDetailView(expenseEntry: item)
					} label: {
						HStack(alignment: .top) {
							VStack(alignment: .leading) {
								Text(item.notes)
									.font(.headline)
									.fontWeight(.semibold)
								
								Text(item.type.name)
									.font(.subheadline)
									.foregroundStyle(.secondary)
								
								Text(item.date.formatted(date: .abbreviated, time: .omitted))
									.font(.subheadline)
									.foregroundStyle(.secondary)
							}
							
							Spacer()
							
							Text(item.amount.formatted(.currency(code: "USD")))
						}
					}
				}
			}
		}
        .navigationTitle(expenseReport.searchValue)
		.toolbar {
			ToolbarItem {
				Button("Add", systemImage: "plus") {
					withAnimation {
						let entry = ExpenseEntry(
							amount: 0,
							expenseReport: expenseReport,
							type: .init(id: 1, name: "Test")
						)
						
						context.insert(entry)
					}
				}
			}
			
			ToolbarItem {
				Button(
					"Delete",
					systemImage: "trash"
				) {
					showDeleteAlert.toggle()
				}
				.alert(
					"Alert title",
					isPresented: $showDeleteAlert,
					actions: {
						
							/// A destructive button that appears in red.
						Button(role: .destructive) {
								// Perform the deletion
							dismissWindow(value: expenseReport)
							context.delete(expenseReport)
						} label: {
							Text("Delete")
						}
						
							/// A cancellation button that appears with bold text.
						Button("Cancel", role: .cancel) {
								// Perform cancellation
						}
						
							/// A general button.
						Button("OK") {
								// Dismiss without action
						}
					},
					message: {
						Text("Alert message")
					}
				)
			}
		}
    }
}

#Preview {
    ExpenseReportDetailView(.example)
}
