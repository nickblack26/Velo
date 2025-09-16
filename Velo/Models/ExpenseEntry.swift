import Foundation
import SwiftData

@Model
final class ExpenseEntry: Persistable, Searchable {
	var id: Int
	var expenseReport: ExpenseReport
	var type: ExpenseType
	var member: Member?
	var amount: Decimal
	var notes: String
	var date: Date
	var chargeToId: Int?
	var chargeToType: ChargeType?
	var billableOption: BillableOption = BillableOption.Billable
	var paymentMethod: PaymentType?
	var classification: Classification?
	
	static var path: String = "/expense/entries"
	
	var searchValue: String {
		notes
	}
	
	enum ChargeType: String, Codable {
		case Company,
			 ServiceTicket,
			 ProjectTicket,
			 ChargeCode,
			 Activity
	}
	
	enum BillableOption: String, CaseIterable, Codable {
		case Billable,
			 DoNotBill,
			 NoCharge,
			 NoDefault
		
		var name: String {
			switch self {
				case .Billable:
					"Billable"
				case .DoNotBill:
					"Do Not Bill"
				case .NoCharge:
					"No Charge"
				case .NoDefault:
					"No Default"
			}
		}
	}
	
	init(
		id: Int = .random(in: 1...50_000),
		billableOption: BillableOption = .Billable,
		notes: String = "",
		date: Date = Date(),
		chargeToId: Int? = nil,
		paymentMethod: PaymentType? = nil,
		amount: Decimal,
		classification: Classification? = nil,
		expenseReport: ExpenseReport,
		member: Member? = nil,
		type: ExpenseType
	) {
		self.id = id
		self.billableOption = billableOption
		self.notes = notes
		self.date = date
		self.chargeToId = chargeToId
		self.paymentMethod = paymentMethod
		self.amount = amount
		self.classification = classification
		self.expenseReport = expenseReport
		self.member = member
		self.type = type
	}
	
	init(from decoder: any Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		self.id = try container.decode(Int.self, forKey: .id)
		self.expenseReport = try container.decode(ExpenseReport.self, forKey: .expenseReport)
		self.type = try container.decode(ExpenseType.self, forKey: .type)
		self.member = try container.decodeIfPresent(Member.self, forKey: .member)
		self.amount = try container.decode(Decimal.self, forKey: .amount)
		self.notes = try container.decode(String.self, forKey: .notes)
		self.chargeToId = try container.decodeIfPresent(Int.self, forKey: .chargeToId)
		self.chargeToType = try container.decodeIfPresent(ExpenseEntry.ChargeType.self, forKey: .chargeToType)
		self.billableOption = try container.decode(ExpenseEntry.BillableOption.self, forKey: .billableOption)
		self.paymentMethod = try container.decodeIfPresent(PaymentType.self, forKey: .paymentMethod)
		self.classification = try container.decodeIfPresent(Classification.self, forKey: .classification)
		let isoFormatter = ISO8601DateFormatter()
		self.date = isoFormatter.date(from: try container.decode(String.self, forKey: .date)) ?? .now
	}
	
	enum CodingKeys: CodingKey {
		case id
		case expenseReport
		case type
		case member
		case amount
		case notes
		case date
		case chargeToId
		case chargeToType
		case billableOption
		case paymentMethod
		case classification
	}
	
	func encode(to encoder: any Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(self.id, forKey: .id)
		try container.encode(self.expenseReport, forKey: .expenseReport)
		try container.encode(self.type, forKey: .type)
		try container.encodeIfPresent(self.member, forKey: .member)
		try container.encode(self.amount, forKey: .amount)
		try container.encode(self.notes, forKey: .notes)
		try container.encode(self.date, forKey: .date)
		try container.encodeIfPresent(self.chargeToId, forKey: .chargeToId)
		try container.encodeIfPresent(self.chargeToType, forKey: .chargeToType)
		try container.encodeIfPresent(self.billableOption, forKey: .billableOption)
		try container.encodeIfPresent(self.paymentMethod, forKey: .paymentMethod)
		try container.encodeIfPresent(self.classification, forKey: .classification)
	}
	
		//    init(from decoder: any Decoder) throws {
		//        let container = try decoder.container(keyedBy: CodingKeys.self)
		//        self.id = try container.decode(Int.self, forKey: .id)
		//        self.expenseReport = try container.decode(ExpenseReport.self, forKey: .expenseReport)
		//        self.type = try container.decode(Reference.self, forKey: .type)
		//        self.member = try container.decodeIfPresent(Member.self, forKey: .member)
		//        self.amount = try container.decode(Decimal.self, forKey: .amount)
		//        self.notes = try container.decode(String.self, forKey: .notes)
		//        self.chargeToId = try container.decodeIfPresent(Int.self, forKey: .chargeToId)
		//        self.chargeToType = try container.decodeIfPresent(ExpenseEntry.ChargeType.self, forKey: .chargeToType)
		//        self.billableOption = try container.decodeIfPresent(ExpenseEntry.BillableOption.self, forKey: .billableOption)
		//        self.paymentMethod = try container.decodeIfPresent(PaymentType.self, forKey: .paymentMethod)
		//        self.classification = try container.decodeIfPresent(Classification.self, forKey: .classification)
		//
		//        let isoFormatter = ISO8601DateFormatter()
		//        self.date = isoFormatter.date(from: try container.decode(String.self, forKey: .date)) ?? .now
		//    }
}
