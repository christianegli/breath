import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "lungs")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Breath Training App")
                .font(.title)
                .padding()
            
            Text("🚧 Project in Development")
                .font(.headline)
                .foregroundColor(.orange)
                .padding()
            
            Text("This is a minimal version to test the project structure.")
                .multilineTextAlignment(.center)
                .padding()
            
            Button("Test Button") {
                print("Button tapped!")
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
