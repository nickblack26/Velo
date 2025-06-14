import SwiftUI

struct FetchableListView<Item: Persistable & Searchable, ItemView: View>: View {
    @State private var isLoading: Bool = false
    @State private var searchText: String = ""
    @State private var items: [Item] = []
    
    @Binding var selectedItem: Item.ID?
    
    var queryItems: [URLQueryItem]?
    
    @ViewBuilder var itemView: (Item) -> ItemView
    
    var body: some View {
        var filteredItems: [Item] {
            if searchText.isEmpty {
                return items
            } else {
                return items.filter { $0.searchValue.localizedCaseInsensitiveContains(searchText)
                }
            }
        }
        
        ZStack {
            if isLoading {
                ProgressView()
            } else {
                List(
                    filteredItems,
                    selection: $selectedItem
                ) { item in
                    itemView(item)
                }
            }
        }
        .task {
            self.isLoading = true
            do {
                self.items = try await Item.getItems(queryItems: queryItems)
            } catch {
                print("Error: \(error)")
            }
            self.isLoading = false
        }
        .searchable(text: $searchText)
    }
}

#Preview {
    FetchableListView<Company, Text>(
        selectedItem: .constant(Company.veloExample.id)
    ) { company in
        Text(company.name)
    }
}
