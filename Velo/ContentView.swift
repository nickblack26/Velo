import SwiftUI
import MapKit

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

struct ContentView: View {
    @Environment(VeloManager.self) private var veloManager
    @State private var selectedConfiguration: Configuration.ID?
    @State private var selectedContact: Contact.ID?
    @State private var selectedCompany: Company?
    @State private var selectedTab: CompanyTab? = .home
    
    //    var selectedCompany: Company? {
    //        get async throws {
    //            guard let id = veloManager.currentCompanyId else { return nil }
    //            print(id)
    //            return try await Company.getItem(id: id)
    //        }
    //    }
    
    
    var body: some View {
        @Bindable var veloManager = veloManager
        
        VStack {
            
        }
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

#Preview {
    @Previewable @State var env = VeloManager()
    
    ContentView()
        .environment(env)
}
