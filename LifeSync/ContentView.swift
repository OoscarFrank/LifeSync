import SwiftUI

struct ContentView: View {

    var body: some View {
        VStack(spacing: 0) {

            TabView {
                HomeView()
                    .tabItem {
                        Label("Home", systemImage: "house")
                    }

                TodoView()
                    .tabItem {
                        Label("Todo", systemImage: "checklist")
                    }

                HealthView()
                    .tabItem {
                        Label("Life", systemImage: "heart")
                    }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
