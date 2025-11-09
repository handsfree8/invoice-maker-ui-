import SwiftUI

struct SplashView: View {
    // MARK: - Properties
    @State private var logoScale: CGFloat = 0.5
    @State private var logoOpacity: Double = 0
    @State private var companyNameOpacity: Double = 0
    @State private var taglineOpacity: Double = 0
    @State private var isAnimating = false
    
    // Callback when splash is complete
    let onComplete: () -> Void
    
    // MARK: - Animation Constants
    private enum AnimationConstants {
        static let logoAnimationDuration: Double = 0.8
        static let textAnimationDelay: Double = 0.4
        static let textAnimationDuration: Double = 0.6
        static let totalDisplayTime: Double = 2.5
        static let logoFinalScale: CGFloat = 1.0
        static let logoSize: CGSize = CGSize(width: 120, height: 120)
    }
    
    // MARK: - Body
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background gradient
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(.systemBlue).opacity(0.1),
                        Color(.systemBackground)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                VStack(spacing: 30) {
                    Spacer()
                    
                    // Logo with animation
                    logoView
                    
                    // Company information with staggered animation
                    companyInfoView
                    
                    Spacer()
                    
                    // Loading indicator
                    loadingIndicator
                    
                    Spacer()
                        .frame(height: 50)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .onAppear {
            startSplashAnimation()
        }
    }
}

// MARK: - View Components
extension SplashView {
    
    /// Animated logo view
    private var logoView: some View {
        VStack(spacing: 16) {
            // Logo image
            Image("rl-logo")
                .resizable()
                .scaledToFit()
                .frame(
                    width: AnimationConstants.logoSize.width,
                    height: AnimationConstants.logoSize.height
                )
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
                .scaleEffect(logoScale)
                .opacity(logoOpacity)
                .rotation3DEffect(
                    .degrees(isAnimating ? 0 : 180),
                    axis: (x: 0, y: 1, z: 0)
                )
        }
    }
    
    /// Company information section
    private var companyInfoView: some View {
        VStack(spacing: 12) {
            // Company name
            Text("Rose Legacy Home Solutions")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
                .opacity(companyNameOpacity)
            
            // Tagline
            Text("HVAC • Plumbing • Appliances • Remodeling")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .opacity(taglineOpacity)
            
            // Phone number pending
            
           
        }
        .multilineTextAlignment(.center)
    }
    
    /// Loading indicator
    private var loadingIndicator: some View {
        VStack(spacing: 8) {
            ProgressView()
                .scaleEffect(0.8)
                .opacity(companyNameOpacity)
            
            Text("Loading Invoice Manager...")
                .font(.caption)
                .foregroundColor(.secondary)
                .opacity(taglineOpacity)
        }
    }
}

// MARK: - Animations
extension SplashView {
    
    /// Starts the splash screen animation sequence
    private func startSplashAnimation() {
        // Logo entrance animation
        withAnimation(.easeOut(duration: AnimationConstants.logoAnimationDuration)) {
            logoScale = AnimationConstants.logoFinalScale
            logoOpacity = 1.0
            isAnimating = true
        }
        
        // Company name animation (delayed)
        DispatchQueue.main.asyncAfter(deadline: .now() + AnimationConstants.textAnimationDelay) {
            withAnimation(.easeOut(duration: AnimationConstants.textAnimationDuration)) {
                companyNameOpacity = 1.0
            }
        }
        
        // Tagline animation (more delayed)
        DispatchQueue.main.asyncAfter(deadline: .now() + AnimationConstants.textAnimationDelay + 0.2) {
            withAnimation(.easeOut(duration: AnimationConstants.textAnimationDuration)) {
                taglineOpacity = 1.0
            }
        }
        
        // Complete splash after total display time
        DispatchQueue.main.asyncAfter(deadline: .now() + AnimationConstants.totalDisplayTime) {
            onComplete()
        }
    }
}

// MARK: - Preview
#Preview {
    SplashView {
        print("Splash completed")
    }
}
