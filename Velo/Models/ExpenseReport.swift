import Foundation
import SwiftData

@Model
final class ExpenseReport: Persistable, Searchable {
	static var path: String = "/expense/reports"
	
	var searchValue: String {
		let formattedStartDate = dateStart.formatted(date: .numeric, time: .omitted)
		let formattedEndDate = dateEnd.formatted(date: .numeric, time: .omitted)
		
		return "\(formattedStartDate) - \(formattedEndDate)"
	}
	
	@Attribute(.unique) var id: Int
	
	var dateStart: Date
	var dateEnd: Date
	var dueDate: Date
	var year: Int
	var period: Int
	var total: Decimal
	
	@Transient
	var calculatedTotal: Decimal {
		expenses.reduce(0) { partialResult, entry in
			partialResult + entry.amount
		}
	}
	
	var member: Member?
	var status: ExpenseReportStatus
	
	@Relationship(deleteRule: .cascade, inverse: \ExpenseEntry.expenseReport)
	var expenses: [ExpenseEntry] = []
	
	@Transient var rawStatus: String {
		status.rawValue
	}
	
	init(
		id: Int,
		dateStart: Date,
		dateEnd: Date,
		dueDate: Date,
		year: Int,
		period: Int,
		total: Decimal,
		member: Member? = nil,
		status: ExpenseReportStatus = ExpenseReportStatus.Open
	) {
		self.id = id
		
		self.dateStart = dateStart
		self.dateEnd = dateEnd
		self.dueDate = dueDate
		self.year = year
		self.period = period
		self.total = total
		
		self.member = member
		self.status = status
	}
	
	init(from decoder: any Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		self.id = try container.decode(Int.self, forKey: .id)
		self.status = try container.decode(ExpenseReportStatus.self, forKey: .status)
		self.member = try container.decodeIfPresent(Member.self, forKey: .member)
		self.year = try container.decode(Int.self, forKey: .year)
		self.period = try container.decode(Int.self, forKey: .period)
		self.total = try container.decode(Decimal.self, forKey: .total)
				
		let decodedStart = try container.decode(String.self, forKey: .dateStart)
		let decodedEnd = try container.decode(String.self, forKey: .dateEnd)
		let decodedDueDate = try container.decode(String.self, forKey: .dueDate)
		
		let isoFormatter = ISO8601DateFormatter()
		
		self.dateStart = isoFormatter.date(from: decodedStart) ?? .now
		self.dateEnd = isoFormatter.date(from: decodedEnd) ?? .now
		self.dueDate = isoFormatter.date(from: decodedDueDate) ?? .now
	}
	
	enum CodingKeys: CodingKey {
		case id
		case dateStart
		case dateEnd
		case dueDate
		case year
		case period
		case total
		case member
		case status
	}
	
	func encode(to encoder: any Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(self.id, forKey: .id)
		try container.encodeIfPresent(self.member, forKey: .member)
		try container.encodeIfPresent(self.status, forKey: .status)
		
		try container.encodeIfPresent(self.dateStart, forKey: .dateStart)
		try container.encodeIfPresent(self.dateEnd, forKey: .dateEnd)
	}
	
	static var example: ExpenseReport = .init(
		id: 1,
		dateStart: Date(),
		dateEnd: Date(),
		dueDate: Date(),
		year: 2025,
		period: 1,
		total: 0.00,
		member: .example,
		status: .Open
	)

	static var blank: ExpenseReport = .init(
		id: Int.random(in: 0...150_000),
		dateStart: currentCalendarPeriod().0,
		dateEnd: currentCalendarPeriod().1,
		dueDate: currentCalendarPeriod().1,
		year: 2025,
		period: 1,
		total: 0
	)
}

enum ExpenseReportStatus: String, Codable {
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

	//struct ExpenseReport: Persistable, Searchable {
	//    static var path: String = "/expense/reports"
	//
	//    var searchValue: String {
	//        (dateStart?.formatted(date: .numeric, time: .omitted) ?? "") + " - " + (dateEnd?.formatted(date: .numeric, time: .omitted) ?? "" )
	//    }
	//
	//    var id: Int
	//    var dateStart: Date?
	//    var dateEnd: Date?
	//    var member: Member?
	//    var status: Self.Status?
	//
	//    init(
	//        id: Int,
	//        dateStart: Date? = nil,
	//        dateEnd: Date? = nil,
	//        member: Member? = nil,
	//        status: Self.Status? = nil
	//    ) {
	//        self.id = id
	//        self.dateStart = dateStart
	//        self.dateEnd = dateEnd
	//        self.member = member
	//        self.status = status
	//    }
	//
	//    init(from decoder: any Decoder) throws {
	//        let container = try decoder.container(keyedBy: CodingKeys.self)
	//        self.id = try container.decode(Int.self, forKey: .id)
	//        self.member = try container.decodeIfPresent(Member.self, forKey: .member)
	//        self.status = try container.decodeIfPresent(ExpenseReport.Status.self, forKey: .status)
	//
	//        let decodedStart = try container.decodeIfPresent(String.self, forKey: .dateStart)
	//        let decodedEnd = try container.decodeIfPresent(String.self, forKey: .dateEnd)
	//
	//        let isoFormatter = ISO8601DateFormatter()
	//
	//        if let startString = decodedStart {
	//            self.dateStart = isoFormatter.date(from: startString)
	//        } else {
	//            self.dateStart = nil
	//        }
	//
	//        if let endString = decodedEnd {
	//            self.dateEnd = isoFormatter.date(from: endString)
	//        } else {
	//            self.dateEnd = nil
	//        }
	//    }
	//
	//    static var example: Self = .init(
	//        id: 1,
	//        dateStart: Date(),
	//        dateEnd: Date(),
	//        member: .example,
	//        status: .Open
	//    )
	//
	//    enum Status: String, Codable {
	//        case Open,
	//             Rejected,
	//             PendingApproval,
	//             ErrorsCorrected,
	//             PendingProjectApproval,
	//             ApprovedByTierOne,
	//             RejectBySecondTier,
	//             ApprovedByTierTwo,
	//             ReadyToBill,
	//             Billed,
	//             WrittenOff,
	//             BilledAgreement
	//    }
	//}
