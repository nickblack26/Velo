import SwiftUI

struct CompanyListView: View {
    @State private var companies: [Company] = []
    @State private var searchText: String = ""
    
    @Binding var selectedCompany: Company?
    
    var body: some View {
        var filteredCompanies: [Company] {
            if searchText.isEmpty {
                return companies
            } else {
                return companies.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
            }
        }
        
        List(selection: $selectedCompany) {
            ForEach(filteredCompanies) { company in
                NavigationLink(company.name, value: company)
            }
        }
        .task {
            do {
                self.companies = try await PSAManager.shared.getCompanies()
            } catch {
                print("Error: \(error)")
            }
        }
        .searchable(text: $searchText)
    }
}

#Preview {
    CompanyListView(selectedCompany: .constant(Company.veloExample))
}


struct Company: Fetchable {
    var id: Int
    var name: String

    internal var path: String = "/company/companies"
    
    static let veloExample: Self = .init(id: 250, name: "Velo IT Group")
}

struct OtherCompany: Fetchable {
    var path: String = "/company/companies"
    
    var id: Int
    var name: String
    
    static let veloExample: Self = .init(id: 250, name: "Velo IT Group")
}


extension String {
    func fromBase64() -> String? {
        guard let data = Data(base64Encoded: self) else {
            return nil
        }
        
        return String(data: data, encoding: .utf8)
    }
    
    func toBase64() -> String {
        return Data(self.utf8).base64EncodedString()
    }
}
