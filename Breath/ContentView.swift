import SwiftUI

/**
 * ContentView: Main application interface
 * 
 * RATIONALE: Simple welcome screen for MVP to test basic functionality.
 * This will be expanded to include the full safety-first architecture
 * and comprehensive breath training features in subsequent iterations.
 * 
 * ARCHITECTURE DECISION: Starting with basic SwiftUI view to verify
 * project setup works, then will add the complete safety education
 * and training system we designed.
 */
struct ContentView: View {
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                
                // MARK: - App Header
                VStack(spacing: 10) {
                    Image(systemName: "lungs.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)
                    
                    Text("Breath Training")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Safe & Effective Breath Hold Training")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 50)
                
                Spacer()
                
                // MARK: - Welcome Message
                VStack(spacing: 20) {
                    Text("Welcome to Your Breath Training Journey")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.center)
                    
                    Text("This app will help you safely improve your breath-holding capacity through scientifically-backed training methods.")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                
                Spacer()
                
                // MARK: - Action Buttons
                VStack(spacing: 15) {
                    Button(action: {
                        // TODO: Navigate to safety education
                        print("Safety Education - Coming Soon!")
                    }) {
                        HStack {
                            Image(systemName: "shield.checkered")
                            Text("Start with Safety Education")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(12)
                    }
                    
                    Button(action: {
                        // TODO: Navigate to breathing techniques
                        print("Breathing Techniques - Coming Soon!")
                    }) {
                        HStack {
                            Image(systemName: "wind")
                            Text("Learn Breathing Techniques")
                        }
                        .font(.headline)
                        .foregroundColor(.blue)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(12)
                    }
                    
                    Button(action: {
                        // TODO: Navigate to progress tracking
                        print("Progress Tracking - Coming Soon!")
                    }) {
                        HStack {
                            Image(systemName: "chart.line.uptrend.xyaxis")
                            Text("View Progress")
                        }
                        .font(.headline)
                        .foregroundColor(.blue)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(12)
                    }
                }
                .padding(.horizontal)
                
                Spacer()
                
                // MARK: - Safety Notice
                VStack(spacing: 10) {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.orange)
                        Text("Safety First")
                            .font(.headline)
                            .fontWeight(.semibold)
                    }
                    
                    Text("Always complete safety education before training. Never practice breath-holding underwater or while driving.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .padding(.bottom, 30)
            }
            .navigationBarHidden(true)
        }
    }
}

/**
 * ContentView_Previews: SwiftUI preview provider
 * 
 * RATIONALE: Provides live preview for development and testing.
 * Essential for rapid UI iteration and visual verification.
 */
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
} 