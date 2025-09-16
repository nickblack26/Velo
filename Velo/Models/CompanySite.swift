import Foundation
import SwiftData
import MapKit

@Model
final class CompanySite: Codable {
	@Attribute(.unique) var id: Int
	var name: String
	var addressLine1: String
	var addressLine2: String?
	var city: String
	var zip: String
	
	var fullAddress: String {
		if let addressLine2 {
			return "\(addressLine1) \(addressLine2) \(city) \(zip)"
		} else {
			return "\(addressLine1) \(city) \(zip)"
		}
	}
	
	init(id: Int, name: String, addressLine1: String, addressLine2: String? = nil, city: String, zip: String) {
		self.id = id
		self.name = name
		self.addressLine1 = addressLine1
		self.addressLine2 = addressLine2
		self.city = city
		self.zip = zip
	}
	
	enum CodingKeys: CodingKey {
		case id
		case name
		case addressLine1
		case addressLine2
		case city
		case zip
	}
	
	init(from decoder: any Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		self.id = try container.decode(Int.self, forKey: .id)
		self.name = try container.decode(String.self, forKey: .name)
		self.addressLine1 = try container.decode(String.self, forKey: .addressLine1)
		self.addressLine2 = try container.decodeIfPresent(String.self, forKey: .addressLine2)
		self.city = try container.decode(String.self, forKey: .city)
		self.zip = try container.decode(String.self, forKey: .zip)
	}
	
	func encode(to encoder: any Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(self.id, forKey: .id)
		try container.encode(self.name, forKey: .name)
		try container.encode(self.addressLine1, forKey: .addressLine1)
		try container.encodeIfPresent(self.addressLine2, forKey: .addressLine2)
		try container.encode(self.city, forKey: .city)
		try container.encode(self.zip, forKey: .zip)
	}
	
	func getCoordinate() async throws -> [MKMapItem] {
		if #available(macOS 26.0, *) {
			guard let request = MKGeocodingRequest(addressString: fullAddress) else { return [] }
			return try await request.mapItems
		} else {
			let geocoder = CLGeocoder()
			let items = try await geocoder.geocodeAddressString(fullAddress)
			var addressMapItems = [MKMapItem]()

			for item in items {
				if let placemark = item as! MKPlacemark? {
					addressMapItems.append(MKMapItem(placemark: placemark))
				}
			}
			
			return addressMapItems
		}
	}
}
