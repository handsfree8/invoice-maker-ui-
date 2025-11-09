import SwiftUI

struct LaunchScreenView: View {
    var body: some View {
        ZStack {
            // Background
            Color(.systemBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Logo
                Image("rl-logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                
                // Company name
                Text("Rose Legacy Home Solutions")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
            }
        }
    }
}

#Preview {
    LaunchScreenView()
}