import SwiftUI
import AuthenticationServices
import Supabase
import Auth
import LocalAuthentication

struct LoginView: View {
    var context = LAContext()
    @Environment(AuthenticationManager.self) private var athena
    
    var body: some View {
        Form {
            VStack(spacing: 15) {
                Image("velo-favicon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50, height: 50)
                    .padding()
                    .foregroundStyle(.black)
                    .background(.white, in: RoundedRectangle(cornerRadius: 20))
                    .shadow(color: .black.opacity(0.06), radius: 3, x: -1, y: -3)
                    .shadow(color: .black.opacity(0.06), radius: 2, x: 1, y: 3)
                    .overlay(alignment: .bottomTrailing) {
                        Image(systemName: "touchid")
                            .font(.system(size: 30))
                            .symbolRenderingMode(.multicolor)
                            .padding(2)
                            .background(.black, in: Circle())
                            .offset(x: 15, y: 10)
                    }
                
                Text("Athena Is Locked")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.top, 5)
                
                Text("Touch ID or enter the password for the user \"Nick Black\" to unlock")
                    .multilineTextAlignment(.center)
                
                SecureField("Enter password", text: .constant(""), prompt: Text("Enter password"))
                    .textFieldStyle(.roundedBorder)
                    .multilineTextAlignment(.center)
                    .labelsHidden()
                    .padding(.horizontal)
                
                Button("Login With Touch ID") {
                    SwiftUI.Task {
                        do {
                            if let session = athena.session {
                                print(session)
								await authenticateWithBiometrics()
                            } else {
								try await athena.signInWithOAuth()
        //                        try await athena.refreshToken()
                            }
                        } catch {
                            print("Logging in failed: \(error)")
                        }
                    }
                }
//                .buttonStyle(.custom())
            }
            .frame(maxWidth: 250)
        }
		.task {
			guard let _ = athena.session else { return }
			await authenticateWithBiometrics()
		}
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .zIndex(1_000_000)
        .padding()
        .background(.ultraThinMaterial, ignoresSafeAreaEdges: .all)
        .onSubmit {
            SwiftUI.Task {
                do {
                    try await athena.signInWithOAuth()
//                    if let session = athena.session, !session.isExpired {
//                    } else {
////                        try await athena.refreshToken()
//                        await authenticateWithBiometrics()
//                    }
                } catch {
                    print("Logging in failed: \(error)")
                }
            }
        }
    }
    
    func authenticateWithBiometrics() async {
        let reason = "Log into your account"
        
        do {
            let success = try await context.evaluatePolicy(
                .deviceOwnerAuthenticationWithBiometrics,
                localizedReason: reason
            )
            
            print(success)
            
            if success {
                try await athena.refreshToken()
                print("successfully refreshed token")
            }
        } catch {
            print(error.localizedDescription)
//            self.errorDescription = error.localizedDescription
//            self.showAlert = true
//            self.biometryType = .none
        }
    }
}

#Preview {
    LoginView()
        .presentedWindowStyle(.hiddenTitleBar)
        .frame(width: 700, height: 500)
}
