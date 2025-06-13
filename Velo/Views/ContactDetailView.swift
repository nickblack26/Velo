import SwiftUI

struct ChecklistItem: Identifiable {
    var id: Int
    var title: String
    var isChecked: Bool
    
    static let example1 = ChecklistItem(id: 1, title: "Download all data", isChecked: true)
    static let example2 = ChecklistItem(id: 2, title: "Download all data", isChecked: false)
}

struct ContactDetailView: View {
    @Environment(VeloManager.self) private var velo
    @State private var contact: Contact?
    
    @State private var selectedConfiguration: Configuration?
    @State private var selectedAuditTrailEntry: AuditTrailEntry?
    @State private var selectedTicket: Ticket?
    @State private var communicationItem: CommunicationItem?
    
    @State private var checklistItems: [ChecklistItem] = [.example1, .example2]
    @State private var configurations: [Configuration] = []
    @State private var tickets: [Ticket] = []
    @State private var notes: [ContactNote] = []
    
    @State private var isPresented: Bool = false
    @State private var showTicketSheet: Bool = false
    @State private var showInspector: Bool = false
        
    var body: some View {
        @Bindable var velo = velo
        var contactId = velo.currentContactId ?? 0
        VStack {
            
        }
//        List {
//            Section("Details") {
//                LabeledContent("First Name") {
//                    TextField("First Name", text: .constant(contact?.firstName ?? ""))
//                }
//                
//                LabeledContent("Last Name") {
//                    TextField("Last Name", text: .constant(contact?.lastName ?? ""))
//                }
//                
//                LabeledContent("Title") {
//                    TextField("Title", text: .constant(contact?.lastName ?? ""))
//                }
//            }
//            
//            Section("Checklist") {
//                ForEach(checklistItems) { checklistItem in
//                    Button(
//                        checklistItem.title,
//                        systemImage: checklistItem.isChecked ? "checkmark.circle" : "circle"
//                    ) {
//                        //                        var item = checklistItems.first { $0.id == checklistItem.id }
//                        //                        item.isChecked.toggle()
//                    }
//                    .buttonStyle(.plain)
//                    .strikethrough(checklistItem.isChecked)
//                }
//            }
//            
//            Section("Custom Fields") {
//                if let customFields = contact?.customFields {
//                    ForEach(customFields) { field in
//                        LabeledContent(field.caption) {
//                            Text(field.caption)
//                        }
//                    }
//                }
//            }
//            
//            Section("Communication Items") {
//                if let customFields = contact?.communicationItems {
//                    ForEach(customFields) { field in
//                        Button {
//                            self.communicationItem = field
//                        } label: {
//                            HStack {
//                                switch field.communicationType {
//                                case "Phone":
//                                    Image(systemName: "phone")
//                                default:
//                                    Image(systemName: "envelope")
//                                }
//                                
//                                Text(field.value)
//                                
//                                if field.defaultFlag {
//                                    Text("Default")
//                                        .font(.caption)
//                                        .padding(.vertical, 2.5)
//                                        .padding(.horizontal, 5)
//                                        .background(
//                                            Capsule()
//                                                .fill(.yellow)
//                                        )
//                                }
//                            }
//                        }
//                    }
//                }
//                
//                Button("Add communication type") {
//                    self.communicationItem = .init(
//                        id: -1,
//                        type: .init(id: -1, name: ""),
//                        value: "",
//                        contactId: contactId,
//                        defaultFlag: false,
//                        communicationType: ""
//                    )
//                }
//            }
//            
//            Section("Configurations") {
//                ForEach(configurations) { configuration in
//                    Button {
//                        self.selectedConfiguration = configuration
//                    } label: {
//                        VStack(alignment: .leading) {
//                            Text(configuration.name)
//                            Text(configuration.type?.name ?? "")
//                                .font(.subheadline)
//                                .foregroundStyle(.secondary)
//                        }
//                    }
//                    .buttonStyle(.plain)
//                }
//                
//                Menu {
//                    Button("Attach configuration", systemImage: "link") { self.isPresented.toggle() }
//                    Button("Create new", systemImage: "plus") {}
//                } label: {
//                    Text("Add configuration")
//                }
//            }
//            
//            Section("Tickets") {
//                ForEach(tickets) { ticket in
//                    VStack(alignment: .leading) {
//                        Text(ticket.summary)
//                        Text("\(ticket.board?.name ?? "") • \(ticket.status?.name ?? "")")
//                            .font(.subheadline)
//                            .foregroundStyle(.secondary)
//                    }
//                }
//                
//                Menu {
//                    Button("Attach ticket", systemImage: "link") { self.showTicketSheet.toggle() }
//                    Button("Create new", systemImage: "plus") {}
//                } label: {
//                    Text("Add ticket")
//                }
//            }
//            
//            Section("Notes") {
//                ForEach(notes) { note in
//                    VStack(alignment: .leading) {
//                        Text(note.text)
//                        //                        Text("\(ticket.board?.name ?? "") • \(ticket.status?.name ?? "")")
//                        //                            .font(.subheadline)
//                        //                            .foregroundStyle(.secondary)
//                    }
//                }
//                
//                Button("Add note") {}
//            }
//        }
//        .navigationTitle(contact?.name ?? "")
//        .toolbar {
//            ToolbarItem {
//                Button(
//                    "Toggle Inspector",
//                    systemImage: "info.circle"
//                ) {
//                    self.showInspector.toggle()
//                }
//            }
//        }
//        .sheet(
//            item: $communicationItem,
//            content: { item in
//                CommunicationItemForm(item: item)
//                    .environment(velo)
//            })
//        .inspector(isPresented: $showInspector) {
//            FetchableListView(
//                selectedItem: $selectedAuditTrailEntry,
//                queryItems: [
//                    .init(name: "type", value: "Contact"),
//                    .init(name: "id", value: "\(contactId)"),
//                    .init(name: "orderBy", value: "enteredDate desc"),
//                ]
//            ) { configuration in
//                Text(configuration.text)
//            }
//        }
//        .sheet(item: $selectedConfiguration, content: { item in
//            NavigationStack {
//                Form {
//                    TextField("Name", text: .constant(item.name))
//                }
//                .navigationTitle(item.name)
//            }
//        })
//        .sheet(isPresented: $isPresented) {
//            NavigationStack {
//                FetchableListView(
//                    selectedItem: $selectedConfiguration,
//                    queryItems: [
//                        .init(name: "conditions", value: "company/id = \(250)"),
//                        .init(name: "orderBy", value: "name"),
//                        .init(name: "pageSize", value: "1000")
//                    ]
//                ) { item in
//                    Button(item.name) {
//                        withAnimation {
//                            self.configurations.append(item)
//                            self.isPresented.toggle()
//                        }
//                    }
//                    .buttonStyle(.plain)
//                }
//                .navigationTitle("Configurations")
//            }
//        }
//        .sheet(isPresented: $showTicketSheet) {}
//        .task {
//            do {
//                self.configurations = try await Configuration.getItems(queryItems: [
//                    .init(name: "conditions", value: "contact/id = \(contactId)"),
//                    .init(name: "pageSize", value: "5"),
//                    .init(name: "orderBy", value: "lastUpdated desc")
//                ])
//                self.contact = try await Contact.getItem(id: contactId)
//                self.tickets = try await Ticket.getItems(queryItems: [
//                    .init(name: "conditions", value: "contact/id = \(contactId) and closedFlag = false"),
//                    .init(name: "pageSize", value: "5"),
//                    .init(name: "orderBy", value: "lastUpdated desc")
//                ])
//                self.notes = try await ContactNote.getItems()
//            } catch {
//                print(error)
//            }
//        }
    }
}

#Preview {
    NavigationStack {
        ContactDetailView()
    }
}
