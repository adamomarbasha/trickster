import SwiftUI

enum DisplayMode: String, CaseIterable, Identifiable {
    case number
    case card
    var id: String { rawValue }
    var title: String {
        switch self {
        case .number: return "Number"
        case .card: return "Card"
        }
    }
}

struct ContentView: View {
    @EnvironmentObject private var settings: AppSettings
    @EnvironmentObject private var viewModel: MagicNumberViewModel
    @StateObject private var volumeObserver = VolumeButtonObserver()
    @State private var showingSettings = false
    @State private var displayMode: DisplayMode = .number

    private var headerSection: some View {
        HeaderView(showingSettings: $showingSettings)
            .padding(.horizontal, 22)
            .padding(.top, 18)
    }

    private var displayModeSection: some View {
        DisplayModeSelector(selection: $displayMode)
            .padding(.horizontal, 22)
            .padding(.top, 14)
    }

    private var modePickerSection: some View {
        Picker("Mode", selection: $viewModel.mode) {
            ForEach(AppMode.allCases) { mode in
                Text(mode.title).tag(mode)
            }
        }
        .pickerStyle(.segmented)
        .padding(.horizontal, 22)
        .padding(.top, 18)
    }

    private var mainContent: some View {
        Group {
            if viewModel.mode == .practice {
                PracticeModeView(displayMode: displayMode)
                    .transition(.opacity.combined(with: .scale(scale: 0.98)))
            } else {
                StealthModeView()
                    .transition(.opacity.combined(with: .scale(scale: 1.02)))
            }
        }
    }

    var body: some View {
        ZStack {
            AppBackground()

            VStack(spacing: 0) {
                headerSection

                displayModeSection

                modePickerSection

                mainContent
            }
            .onChange(of: displayMode) { newValue in
                UserDefaults.standard.set(newValue.rawValue, forKey: "displayModePreference")
            }
        }
        .preferredColorScheme(.dark)
        .animation(.spring(response: 0.4, dampingFraction: 0.86), value: viewModel.mode)
        .sheet(isPresented: $showingSettings) {
            SettingsView()
                .environmentObject(settings)
        }
        .onAppear {
            if let raw = UserDefaults.standard.string(forKey: "displayModePreference"),
               let saved = DisplayMode(rawValue: raw) {
                displayMode = saved
            }
            volumeObserver.start(
                onIncrease: { viewModel.incrementFirstDigit(hapticsEnabled: settings.hapticsEnabled) },
                onDecrease: { viewModel.incrementSecondDigit(hapticsEnabled: settings.hapticsEnabled) }
            )
        }
        .onDisappear {
            volumeObserver.stop()
        }
    }
}

private struct HeaderView: View {
    @Binding var showingSettings: Bool

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("MAGIC NUMBER")
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .tracking(2)
                    .foregroundStyle(.white.opacity(0.7))

                Text("Ready")
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.38))
            }

            Spacer()

            Button {
                showingSettings = true
            } label: {
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.82))
                    .frame(width: 44, height: 44)
                    .background(.white.opacity(0.08), in: Circle())
                    .overlay(Circle().stroke(.white.opacity(0.12), lineWidth: 1))
            }
            .accessibilityLabel("Settings")
        }
    }
}

struct AppBackground: View {
    var body: some View {
        LinearGradient(
            colors: [
                Color(red: 0.04, green: 0.05, blue: 0.08),
                Color(red: 0.08, green: 0.10, blue: 0.13),
                Color(red: 0.03, green: 0.03, blue: 0.05)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
        .overlay {
            LinearGradient(
                colors: [
                    Color(red: 0.64, green: 0.82, blue: 0.94).opacity(0.12),
                    .clear,
                    Color(red: 0.92, green: 0.78, blue: 0.48).opacity(0.08)
                ],
                startPoint: .topTrailing,
                endPoint: .bottomLeading
            )
            .ignoresSafeArea()
        }
    }
}

private struct DisplayModeSelector: View {
    @Binding var selection: DisplayMode

    var body: some View {
        HStack(spacing: 8) {
            ForEach(DisplayMode.allCases) { mode in
                DisplayModeButton(
                    title: mode.title,
                    isSelected: selection == mode,
                    action: {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                            selection = mode
                        }
                    }
                )
            }
        }
        .padding(8)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(.white.opacity(0.12), lineWidth: 1)
        )
    }
}

private struct DisplayModeButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundStyle(isSelected ? .black.opacity(0.9) : .white.opacity(0.8))
                .padding(.vertical, 10)
                .frame(maxWidth: .infinity)
                .background {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(buttonBackgroundStyle)
                }
        }
        .buttonStyle(.plain)
    }

    private var buttonBackgroundStyle: AnyShapeStyle {
        if isSelected {
            return AnyShapeStyle(
                LinearGradient(
                    colors: [
                        Color(red: 0.92, green: 0.98, blue: 0.66),
                        Color(red: 0.58, green: 0.92, blue: 0.82)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
        } else {
            return AnyShapeStyle(Color.white.opacity(0.0001))
        }
    }
}

#Preview {
    let store = MagicNumberStore()
    let vm = MagicNumberViewModel(store: store)
    return ContentView()
        .environmentObject(AppSettings())
        .environmentObject(vm)
}

