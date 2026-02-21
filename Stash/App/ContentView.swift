import ComposableArchitecture
import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "tray.fill")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, World!")
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
