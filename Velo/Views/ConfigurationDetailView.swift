import SwiftUI

struct ConfigurationDetailView: View {
    @State private var configuration: Configuration?
    @State private var contacts: [Contact] = []
    @State private var tickets: [Ticket] = []
    @State private var showInspector: Bool = false
    
    var configurationId: Int
    
    var body: some View {
        List {
            Section("Details") {
                
            }
            
            Section("Tickets") {
                
            }
        }
        .inspector(isPresented: $showInspector) {
            NavigationStack {
                AuditTrailView(
                    type: "Configuration",
                    id: configurationId
                )
            }
        }
        .toolbar {
            ToolbarItem {
                Button(
                    "Toggle inspector",
                    systemImage: "info.circle"
                ) {
                    self.showInspector.toggle()
                }
            }
        }
        .navigationTitle(configuration?.name ?? "")
        .task {
            do {
                self.configuration = try await Configuration.getItem(id: configurationId)
                self.tickets = try await Ticket.getItems(queryItems: [
                    .init(name: "conditions", value: "contact/id = \(32569)")
                ])
            } catch {
                print(error)
            }
        }
    }
}

#Preview {
    NavigationStack {
        ConfigurationDetailView(configurationId: 23455)
    }
}
