import SwiftUI

struct FetchableListView<Item: Fetchable & Searchable, ItemView: View>: View {
    @State private var isLoading: Bool = false
    @State private var searchText: String = ""
    @State private var items: [Item] = []
    
    @Binding var selectedItem: Item?
    
    var queryItems: [URLQueryItem]?
    
    @ViewBuilder var itemView: (Item) -> ItemView
    
    var body: some View {
        var filteredItems: [Item] {
            
            if searchText.isEmpty {
                print(items.isEmpty)
                return items
            } else {
                return items.filter { $0.searchValue.localizedCaseInsensitiveContains(searchText)
                }
            }
        }
        
        ZStack {
//            Image(.backgroundPattern)
//                .resizable()
//                .ignoresSafeArea()
//                .scaledToFill()
//                .opacity(0.1)
            
            if isLoading {
                ProgressView()
            } else {
                if filteredItems.isEmpty {
                    ContentUnavailableView(
                        "No items found",
                        systemImage: "exclamationmark.triangle"
                    )
                } else {
                    List(
                        filteredItems,
                        selection: $selectedItem
                    ) { item in
                        itemView(item)
                    }
                }
//                .scrollContentBackground(.hidden)
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
        selectedItem: .constant(Company.veloExample)
    ) { company in
        Text(company.name)
    }
}
