struct ContactNote: Codable, Hashable, Sendable {
    let id: Int?
    let contactID: Int?
    let text: String?
    let type: TypeClass?
    let flagged: Bool?
    let enteredBy: String?
    let info: Info?

    enum CodingKeys: String, CodingKey {
        case id = "id"
        case contactID = "contactId"
        case text = "text"
        case type = "type"
        case flagged = "flagged"
        case enteredBy = "enteredBy"
        case info = "_info"
    }
}