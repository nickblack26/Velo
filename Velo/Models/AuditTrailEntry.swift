import Foundation

struct AuditTrailEntry: Persistable, Searchable {
    let text: String
    let enteredDate: String
    let enteredBy: String
    let auditType: String
    let auditSource: String
    
    var id: Int {
        Int(text) ?? Int.random(in: 1...100000000)
    }
    
    static var path: String = "/system/audittrail"
    var searchValue: String {
        text
    }

//    enum CodingKeys: String, CodingKey {
//        case text = "text"
//        case enteredDate = "enteredDate"
//        case enteredBy = "enteredBy"
//        case auditType = "auditType"
//        case auditSource = "auditSource"
//    }
    
    init(
        text: String,
        enteredDate: String,
        enteredBy: String,
        auditType: String,
        auditSource: String
    ) {
        self.text = text
        self.enteredDate = enteredDate
        self.enteredBy = enteredBy
        self.auditType = auditType
        self.auditSource = auditSource
    }
}
