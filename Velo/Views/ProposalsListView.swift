import SwiftUI

struct Propsal: Identifiable, Decodable {
	var id: UUID
	var name: String
}

struct ProposalsListView: View {
	@Environment(AuthenticationManager.self) private var auth
	
	@State private var proposals: [Propsal] = []
	
    var body: some View {
		List {
			ForEach(proposals) { proposal in
				Text(proposal.name)
			}
		}
		.task {
			do {
				self.proposals = try await auth.database.from("new_proposals").select().execute().value
			} catch {
				print(error)
			}
		}
    }
}

#Preview {
    ProposalsListView()
}
