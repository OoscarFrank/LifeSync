import SwiftUI

struct HomeView: View {
    @State private var localNom: String = UserDefaults.standard.string(forKey: "nom") ?? ""
    @State private var showingSettings = false
    let gradient = LinearGradient(gradient: Gradient(colors: [Color.purple.opacity(0.6), Color.purple.opacity(0)]), startPoint: .top, endPoint: .center)

    var body: some View {
        NavigationView {
            VStack {
                MapWidget()
                StepsWidget()
                Spacer()
            }
            .navigationTitle("Hi \(localNom),")
            .toolbar {
                Button(action: { showingSettings = true }) {
                    Label("Settings", systemImage: "gear")
                }
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView(isPresented: $showingSettings)
            }
            .background(gradient)
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
