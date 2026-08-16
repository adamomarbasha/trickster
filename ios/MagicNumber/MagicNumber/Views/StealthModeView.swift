import SwiftUI

struct StealthModeView: View {
    @EnvironmentObject private var settings: AppSettings
    @EnvironmentObject private var viewModel: MagicNumberViewModel
    @State private var pulse = false

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 18) {
                Text(Date.now, style: .time)
                    .font(.system(size: 62, weight: .thin, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(.white.opacity(0.86))

                Text("Focus")
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.34))
            }
            .scaleEffect(pulse ? 1.01 : 1)
            .animation(.easeInOut(duration: 2.8).repeatForever(autoreverses: true), value: pulse)
            .onAppear { pulse = true }

            Spacer()

            Spacer(minLength: 30)
        }
        .contentShape(Rectangle())
        .onTapGesture(count: 2) {
            // Reserved for future actions; sending is removed.
        }
    }
}

#Preview {
    StealthModeView()
        .environmentObject(AppSettings())
        .environmentObject(MagicNumberViewModel(store: MagicNumberStore()))
        .background(AppBackground())
}
