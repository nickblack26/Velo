struct Company: Fetchable {
    static var path: String = "/company/companies"
    
    var id: Int
    var name: String
    
    static let veloExample: Self = .init(id: 250, name: "Velo IT Group")
}