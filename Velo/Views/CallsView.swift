import SwiftUI

struct CallsView: View {
	var body: some View {
		Grid {
			GridRow {
				VStack(alignment: .leading) {
					
				}
			}
		}
	}
}

struct DialerView: View {
	@State private var input: String = ""
	
	var body: some View {
		TextField(
			"name",
			text: $input,
			prompt: Text(
				"Type a name or number"
			)
		)
		.textFieldStyle(.roundedBorder)
		
		Button {
			
		} label: {
			Label(
				"Call",
				systemImage: "phone.fill"
			)
			.frame(maxWidth: .infinity)
		}
	}
}

#Preview("Dialer View") {
	DialerView()
}

#Preview("Calls View") {
	CallsView()
}
