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
        
        let decodedStart = try container.decodeIfPresent(String.self, forKey: .dateStart)
        let decodedEnd = try container.decodeIfPresent(String.self, forKey: .dateEnd)

        let isoFormatter = ISO8601DateFormatter()

        if let startString = decodedStart {
            self.dateStart = isoFormatter.date(from: startString)
        } else {
            self.dateStart = nil
        }

        if let endString = decodedEnd {
            self.dateEnd = isoFormatter.date(from: endString)
        } else {
            self.dateEnd = nil
        }
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
