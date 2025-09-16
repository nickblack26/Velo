import SwiftUI
import MapKit

struct SiteView: View {
	@State private var selection: MKMapItem?
	@State private var visitedStores: [MKMapItem] = []

	var body: some View {
		Map(selection: $selection) {
			ForEach(visitedStores, id: \.self) { store in
				Marker(item: store)
			}
			.mapItemDetailSelectionAccessory()
		}
		.task {
			do {
				let site = CompanySite.init(
					id: 1000,
					name: "Lafayette (001USLALFT)",
					addressLine1: "2901 Johnston Street",
					addressLine2: "Suite 303",
					city: "Lafayette",
					zip: "70503"
				)
				if #available(macOS 26.0, *) {
					let coordinates = try await site.getCoordinate()
					print(coordinates)
					visitedStores.append(contentsOf: coordinates)
				} else {
						// Fallback on earlier versions
//					visitedStores.append(.init(location: ., address: <#T##MKAddress?#>))
				}
			} catch {
				print(error)
			}
		}
	}
}

#Preview {
	SiteView()
}
