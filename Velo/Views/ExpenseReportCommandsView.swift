import SwiftUI

struct ExpenseReportCommandsView: Commands {
	@Environment(\.openWindow) private var openWindow
	@Environment(\.modelContext) private var context
	
	var body: some Commands {
		CommandGroup(after: .newItem) {
			Button("Add Expense Report", systemImage: "plus") {
				let blank = ExpenseReport.blank
				context.insert(blank)
				openWindow(value: blank)
			}
			.keyboardShortcut("N")
		}
	}
}

