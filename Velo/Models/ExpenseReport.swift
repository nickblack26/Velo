import Foundation

struct ExpenseReport: Persistable, Searchable {
    static var path: String = "/expense/reports"
    
    var searchValue: String {
        (dateStart?.formatted(date: .numeric, time: .omitted) ?? "") + " - " + (dateEnd?.formatted(date: .numeric, time: .omitted) ?? "" )
    }
    
    var id: Int
    var dateStart: Date?
    var dateEnd: Date?
    var member: Member?
    var status: Self.Status?
    
    init(
        id: Int,
        dateStart: Date? = nil,
        dateEnd: Date? = nil,
        member: Member? = nil,
        status: Self.Status? = nil
    ) {
        self.id = id
        self.dateStart = dateStart
        self.dateEnd = dateEnd
        self.member = member
        self.status = status
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int.self, forKey: .id)
        self.member = try container.decodeIfPresent(Member.self, forKey: .member)
        self.status = try container.decodeIfPresent(ExpenseReport.Status.self, forKey: .status)
        
        let dateFormatter = DateFormatter()
        let decodedStart = try container.decodeIfPresent(String.self, forKey: .dateStart)
        let decodedEnd = try container.decodeIfPresent(String.self, forKey: .dateEnd)
        
        print(decodedStart, decodedEnd)
        
        self.dateStart = dateFormatter.date(from: decodedStart ?? "") ?? Date()
        self.dateEnd = dateFormatter.date(from: decodedEnd ?? "") ?? Date()
    }
   
    
    static var example: Self = .init(
        id: 1,
        dateStart: Date(),
        dateEnd: Date(),
        member: .example,
        status: .Open
    )
    
    enum Status: String, Codable {
        case Open,
             Rejected,
             PendingApproval,
             ErrorsCorrected,
             PendingProjectApproval,
             ApprovedByTierOne,
             RejectBySecondTier,
             ApprovedByTierTwo,
             ReadyToBill,
             Billed,
             WrittenOff,
             BilledAgreement
    }
}
