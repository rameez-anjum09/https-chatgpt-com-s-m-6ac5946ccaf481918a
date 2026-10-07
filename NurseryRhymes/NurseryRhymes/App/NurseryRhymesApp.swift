import SwiftUI

@main
struct NurseryRhymesApp: App {
    init() {
        // Configure global navigation appearance
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(red: 254/255, green: 249/255, blue: 238/255, alpha: 1.0)
        appearance.titleTextAttributes = [
            .foregroundColor: UIColor(red: 27/255, green: 37/255, blue: 75/255, alpha: 1.0),
            .font: UIFont.systemFont(ofSize: 18, weight: .bold)
        ]
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .preferredColorScheme(.light) // Storybook cheerful bright aesthetic
        }
    }
}
