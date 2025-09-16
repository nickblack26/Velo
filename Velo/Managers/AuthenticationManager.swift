import Foundation
import AuthenticationServices
import Supabase

let SUPABASE_URL = URL(string: "https://qqfkxhqzsbqgydssvfss.supabase.co")
let SUPABASE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFxZmt4aHF6c2JxZ3lkc3N2ZnNzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MDQ5MjM1MDUsImV4cCI6MjAyMDQ5OTUwNX0.Tikmsl2leC8S9T0xqA5wfnnRbu2NqKo0xdVSlqNbifs"

@Observable
@MainActor
final class AuthenticationManager: NSObject {
	var isAuthenticated: Bool
	let database: SupabaseClient
	var session: Session?
	var attributes: UserAttributes?
	
	init(
		isAuthenticated: Bool = false,
		database: SupabaseClient? = .init(
			supabaseURL: SUPABASE_URL!,
			supabaseKey: SUPABASE_KEY
		),
		session: Session? = nil
	) {
		self.isAuthenticated = isAuthenticated
		guard let supabaseURL = SUPABASE_URL else { fatalError("Error creating URL for Supabase") }
		if let database {
			self.database = database
		} else {
			self.database = .init(
				supabaseURL: supabaseURL,
				supabaseKey: SUPABASE_KEY
			)
		}
		self.session = self.database.auth.currentSession
	}
	
	func setSessionData(_ session: Session) throws {
		self.session = session
		self.isAuthenticated = true
		let decoder = JSONDecoder()
		decoder.keyDecodingStrategy = .convertFromSnakeCase
		
		let encoder = JSONEncoder()
		
		let encodedValue = try encoder.encode(session.user.userMetadata)
				
		self.attributes = try decoder.decode(UserAttributes.self, from: encodedValue)
		
		print(attributes)
	}
}

extension AuthenticationManager: ASWebAuthenticationPresentationContextProviding, Sendable {
	typealias ASPresentationAnchor = NSWindow
	
	func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
		
		return ASPresentationAnchor()
	}
	
	func signInWithOAuth(
		provider: Provider = .azure,
		scopes: String? = "openid profile email User.Read Calendars.ReadBasic Calendars.Read Calendars.ReadWrite"
	) async throws {
		let session = try await database.auth.signInWithOAuth(
			provider: provider,
			redirectTo: URL(string: "service://login"),
			scopes: scopes
		) { (session: ASWebAuthenticationSession) in
				// customize session
			session.presentationContextProvider = self
				//			session.prefersEphemeralWebBrowserSession = true
			session.start()
		}
		
		try setSessionData(session)
		self.isAuthenticated = true
		self.session = session
	}
	
	func refreshToken() async throws {
		guard let session = self.session else { return }

		try setSessionData(session)
		self.isAuthenticated = true
		self.session = try await database.auth.refreshSession(refreshToken: session.refreshToken)
	}
}
