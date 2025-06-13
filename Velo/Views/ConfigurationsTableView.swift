import SwiftUI

struct ConfigurationsTableView: View {
    @State private var isLoading: Bool = false
    @State private var searchText: String = ""
    @State private var items: [Configuration] = []
    
    @Binding var selectedItem: Configuration?
    
    var queryItems: [URLQueryItem]?
        
    var body: some View {
        var filteredItems: [Configuration] {
            if searchText.isEmpty {
                return items
            } else {
                return items.filter { $0.searchValue.localizedCaseInsensitiveContains(searchText) }
            }
        }
        
        ZStack {
            if isLoading {
                ProgressView()
            } else {
                Table(items) {
                    TableColumn("Name", value: \.name)
                    
                    TableColumn("Type") { column in
                        Text(column.type?.name ?? "")
                    }
                    
                    TableColumn("Status") { column in
                        Text(column.status?.name ?? "")
                    }
                }
            }
        }
        .task {
            do {
                self.isLoading = true
                self.items = try await Configuration.getItems(queryItems: queryItems)
                self.isLoading = false
            } catch {
                print("Error: \(error)")
            }
        }
        .searchable(text: $searchText)
    }
}

#Preview {
    ConfigurationsTableView(
        selectedItem: .constant(Configuration(id: 1, name: ""))
    )
}
