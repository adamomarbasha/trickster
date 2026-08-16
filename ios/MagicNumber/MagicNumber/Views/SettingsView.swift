import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var settings: AppSettings

    var body: some View {
        NavigationStack {
            Form {
                Section("Behavior") {
                    Toggle("Stealth double-tap gesture", isOn: $settings.stealthDoubleTapEnabled)
                    Toggle("Haptics", isOn: $settings.hapticsEnabled)
                }
                Button("Reset") {
                    settings.stealthDoubleTapEnabled = false
                    settings.hapticsEnabled = false
                }
                .foregroundColor(.red)
            }
            .scrollContentBackground(.hidden)
            .background(Color(red: 0.05, green: 0.06, blue: 0.09))
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}

#Preview {
    SettingsView()
        .environmentObject(AppSettings())
}
