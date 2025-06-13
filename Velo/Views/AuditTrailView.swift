import SwiftUI

struct AuditTrailView: View {
    @State private var entries: [AuditTrailEntry] = []
    
    var type: String
    var id: Int
    
    var body: some View {
        List {
            ForEach(entries) { entry in
                VStack(alignment: .leading) {
                    Text(entry.text)
                    
                    Text(entry.enteredBy)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .navigationTitle("Audit Trail")
        .task {
            do {
                self.entries = try await AuditTrailEntry.getItems(queryItems: [
                    .init(name: "type", value: "Configuration"),
                    .init(name: "id", value: "23455"),
                    .init(name: "pageSize", value: "1000"),
                ])
            } catch {
                print(error)
            }
        }
    }
}

#Preview {
    AuditTrailView(
        type: "Configuration",
        id: 23455
    )
}
