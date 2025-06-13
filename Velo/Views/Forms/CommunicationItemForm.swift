import SwiftUI

struct CommunicationItemForm: View {
    @Environment(VeloManager.self) private var velo
    
    @State private var isLoading: Bool = false
    @State private var contacts: [Contact] = []
    @State private var item: CommunicationItem?
        
    init(item: CommunicationItem? = nil) {
        self._item = State(initialValue: item)
    }
    
    var body: some View {
        Form {
            TextField(
                "Value",
                text: Binding(
                    get: {
                        return item?.value ?? ""
                    },
                    set: { newValue in
                        item?.value = newValue
                    }
                )
            )
            
            Toggle(
                "Default",
                isOn: Binding(
                    get: {
                        item?.defaultFlag ?? false
                    },
                    set: { newValue in
                        item?.defaultFlag = newValue
                    }
                )
            )
            
            if !isLoading && !contacts.isEmpty {
                Picker(
                    "Contact",
                    selection: Binding(
                        get: {
                            item?.contactId ?? velo.currentContactId
                        },
                        set: { newValue in
                            item?.contactId = newValue
                        }
                    )
                ) {
                    ForEach(contacts, id: \.id) { contact in
                        Text(contact.name)
                            .tag(contact.id)
                    }
                }
                .pickerStyle(.menu)
                .disabled(isLoading)
            }
        }
        .task {
            self.isLoading = false
            do {
                self.contacts = try await Contact.getItems(queryItems: [
                    .init(
                        name: "conditions",
                        value: "company/id = \(velo.currentCompanyId ?? 250) and inactiveFlag = false"
                    ),
                    .init(
                        name: "childConditions",
                        value: "(types/id = 17 or types/id = 21)"
                    ),
                    .init(
                        name: "pageSize",
                        value: "1000"
                    ),
                    .init(
                        name: "orderBy",
                        value: "firstName"
                    )
                ])
            } catch {
                print(error)
            }
            self.isLoading = false
        }
    }
}

#Preview {
    CommunicationItemForm()
}
