import SwiftUI

struct PracticeModeView: View {
    let displayMode: DisplayMode
    @EnvironmentObject private var settings: AppSettings
    @EnvironmentObject private var viewModel: MagicNumberViewModel

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
                    CardDisplay(firstDigit: viewModel.firstDigit, secondDigit: viewModel.secondDigit)
                        .padding(.horizontal, 22)
                }
            }

            VStack(spacing: 12) {
                HStack(spacing: 12) {
                    Button {
                        viewModel.reset()
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
    let firstDigit: Int
    let secondDigit: Int

    private var rankSymbol: String {
        let ranks = ["2","3","4","5","6","7","8","9","10","J","Q","K","A"]
        let idx = Int((Double(firstDigit).rounded(.toNearestOrAwayFromZero) * 12.0 / 9.0).rounded())
        let clamped = max(0, min(12, idx))
        return ranks[clamped]
    }

    private var suitSymbol: String {
        let suits = ["♠︎","♥︎","♦︎","♣︎"]
        let idx = Int((Double(secondDigit) * 3.0 / 9.0).rounded())
        let clamped = max(0, min(3, idx))
        return suits[clamped]
    }

    private var suitColor: Color {
        switch suitSymbol {
        case "♥︎", "♦︎": return Color(red: 0.98, green: 0.36, blue: 0.44)
        default: return .white
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
        .animation(.spring(response: 0.45, dampingFraction: 0.86), value: firstDigit)
        .animation(.spring(response: 0.45, dampingFraction: 0.86), value: secondDigit)
    }
}

#Preview {
    PracticeModeView(displayMode: .number)
        .environmentObject(AppSettings())
        .environmentObject(MagicNumberViewModel(store: MagicNumberStore()))
        .background(AppBackground())
}
