import SwiftUI

struct PracticeModeView: View {
    let displayMode: DisplayMode
    @EnvironmentObject private var settings: AppSettings
    @EnvironmentObject private var viewModel: MagicNumberViewModel
    
    @State private var cardRankIndex: Int = UserDefaults.standard.integer(forKey: "card.rankIndex") // 0..13 (0 means reset -> "0")
    @State private var cardSuitIndex: Int = UserDefaults.standard.integer(forKey: "card.suitIndex") // 0..4 (0 means reset -> "X")
    @State private var isResetting = false

    var body: some View {
        VStack(spacing: 28) {
            Spacer(minLength: 30)

            VStack(spacing: 18) {
                if displayMode == .number {
                    // Premium number display
                    Text(viewModel.combinedValue)
                        .font(.system(size: 128, weight: .heavy, design: .rounded))
                        .monospacedDigit()
                        .foregroundStyle(.white)
                        .shadow(color: .black.opacity(0.35), radius: 28, y: 16)
                        .padding(.horizontal, 22)
                        .padding(.vertical, 18)
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .stroke(LinearGradient(colors: [
                                    .white.opacity(0.18), .white.opacity(0.04)
                                ], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1)
                        )
                        .contentTransition(.numericText())
                        .animation(.spring(response: 0.4, dampingFraction: 0.85), value: viewModel.combinedValue)

                    HStack(spacing: 12) {
                        DigitTile(title: "LEFT DIGIT", value: viewModel.firstDigit)
                        DigitTile(title: "RIGHT DIGIT", value: viewModel.secondDigit)
                    }
                    .padding(.horizontal, 22)
                } else {
                    // Card mode display
                    CardDisplay(rankIndex: cardRankIndex, suitIndex: cardSuitIndex)
                        .padding(.horizontal, 22)
                }
            }

            VStack(spacing: 12) {
                HStack(spacing: 12) {
                    Button {
                        isResetting = true
                        viewModel.reset()
                        cardRankIndex = 0
                        cardSuitIndex = 0
                        UserDefaults.standard.set(cardRankIndex, forKey: "card.rankIndex")
                        UserDefaults.standard.set(cardSuitIndex, forKey: "card.suitIndex")
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                            isResetting = false
                        }
                    } label: {
                        Label("Reset", systemImage: "arrow.counterclockwise")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(SecondaryButtonStyle())
                }
            }
            .padding(.horizontal, 22)

            Spacer(minLength: 28)
        }
        .onAppear {
            // Initialize indices from defaults or reset state
            if viewModel.firstDigit == 0 && viewModel.secondDigit == 0 {
                cardRankIndex = 0
                cardSuitIndex = 0
            }
        }
        .onChange(of: viewModel.firstDigit) { _ in
            if isResetting || (viewModel.firstDigit == 0 && viewModel.secondDigit == 0) { return }
            // Increment rank cycle: 0 -> 1 (A), then 1..13 -> wrap to 1
            if cardRankIndex == 0 {
                cardRankIndex = 1
            } else {
                cardRankIndex = (cardRankIndex % 13) + 1
            }
            UserDefaults.standard.set(cardRankIndex, forKey: "card.rankIndex")
        }
        .onChange(of: viewModel.secondDigit) { _ in
            if isResetting || (viewModel.firstDigit == 0 && viewModel.secondDigit == 0) { return }
            // Increment suit cycle: 0 -> 1 (♥︎), then 1..4 -> wrap to 1
            if cardSuitIndex == 0 {
                cardSuitIndex = 1
            } else {
                cardSuitIndex = (cardSuitIndex % 4) + 1
            }
            UserDefaults.standard.set(cardSuitIndex, forKey: "card.suitIndex")
        }
    }
}

private struct DigitTile: View {
    let title: String
    let value: Int

    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.system(size: 11, weight: .semibold, design: .rounded))
                .tracking(1.2)
                .foregroundStyle(.white.opacity(0.48))

            Text("\(value)")
                .font(.system(size: 34, weight: .semibold, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(.white.opacity(0.9))
                .contentTransition(.numericText())
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 18)
        .background(.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .stroke(.white.opacity(0.12), lineWidth: 1)
        )
    }
}

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 17, weight: .bold, design: .rounded))
            .foregroundStyle(.black)
            .background(
                LinearGradient(
                    colors: [
                        Color(red: 0.92, green: 0.98, blue: 0.66),
                        Color(red: 0.58, green: 0.92, blue: 0.82)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                in: RoundedRectangle(cornerRadius: 8, style: .continuous)
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .opacity(configuration.isPressed ? 0.88 : 1)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 16, weight: .semibold, design: .rounded))
            .foregroundStyle(.white.opacity(0.88))
            .frame(height: 52)
            .background(.white.opacity(configuration.isPressed ? 0.13 : 0.08), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .stroke(.white.opacity(0.12), lineWidth: 1)
            )
    }
}

private struct CardDisplay: View {
    let rankIndex: Int // 0..13 (0 => "0")
    let suitIndex: Int // 0..4 (0 => "X")

    private var rankSymbol: String {
        if rankIndex == 0 { return "0" }
        let ranks13 = ["A","2","3","4","5","6","7","8","9","10","J","Q","K"]
        let idx = max(1, min(13, rankIndex)) - 1
        return ranks13[idx]
    }

    private var suitSymbol: String {
        if suitIndex == 0 { return "X" }
        let suits4 = ["♥︎","♦︎","♠︎","♣︎"]
        let idx = max(1, min(4, suitIndex)) - 1
        return suits4[idx]
    }

    private var suitColor: Color {
        switch suitSymbol {
        case "♥︎", "♦︎":
            return Color(red: 0.98, green: 0.36, blue: 0.44)
        case "X":
            return .white.opacity(0.82)
        default:
            return .white
        }
    }

    var body: some View {
        ZStack {
            // Glass card
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .stroke(LinearGradient(colors: [
                            .white.opacity(0.22), .white.opacity(0.06)
                        ], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.35), radius: 24, y: 14)

            VStack(spacing: 12) {
                HStack {
                    Text(rankSymbol)
                        .font(.system(size: 24, weight: .semibold, design: .rounded))
                        .foregroundStyle(suitColor.opacity(0.9))
                    Text(suitSymbol)
                        .font(.system(size: 20, weight: .semibold, design: .rounded))
                        .foregroundStyle(suitColor.opacity(0.9))
                    Spacer()
                }
                .opacity(0.8)

                Spacer(minLength: 18)

                Text("\(rankSymbol) \(suitSymbol)")
                    .font(.system(size: 72, weight: .heavy, design: .rounded))
                    .foregroundStyle(suitColor)
                    .contentTransition(.numericText())
                    .minimumScaleFactor(0.6)
                    .lineLimit(1)

                Spacer(minLength: 18)
            }
            .padding(22)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 260)
        .animation(.spring(response: 0.45, dampingFraction: 0.86), value: rankIndex)
        .animation(.spring(response: 0.45, dampingFraction: 0.86), value: suitIndex)
    }
}

#Preview {
    PracticeModeView(displayMode: .number)
        .environmentObject(AppSettings())
        .environmentObject(MagicNumberViewModel(store: MagicNumberStore()))
        .background(AppBackground())
}

