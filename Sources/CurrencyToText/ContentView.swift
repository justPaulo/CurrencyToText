import SwiftUI
import Combine

@MainActor
private final class ConversionModel: ObservableObject {
    @Published var amountInput = "123,45"
    @Published var selectedCurrency: Currency = .eur
    @Published var selectedLanguage: AppLanguage = .portuguese
    @Published var copied = false
}

struct ContentView: View {
    @StateObject private var model = ConversionModel()
    @FocusState private var amountFieldFocused: Bool

    private var amount: MoneyAmount? {
        MoneyAmount.parse(model.amountInput)
    }

    private var result: String? {
        amount?.words(currency: model.selectedCurrency, language: model.selectedLanguage)
    }

    var body: some View {
        VStack(spacing: 0) {
            header
            VStack(alignment: .leading, spacing: 26) {
                configuration
                amountEntry
                resultCard
            }
            .padding(32)
            Spacer(minLength: 0)
            footer
        }
        .background(Color(nsColor: .windowBackgroundColor))
        .preferredColorScheme(.light)
    }

    private var header: some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color.indigo.gradient)
                    .frame(width: 56, height: 56)
                Image(systemName: "textformat.123")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundStyle(.white)
            }
            VStack(alignment: .leading, spacing: 4) {
                Text("Currency in Words")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                Text("Turn an amount into words")
                    .font(.system(size: 14))
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding(.horizontal, 32)
        .padding(.vertical, 24)
        .background(.white.opacity(0.75))
        .overlay(alignment: .bottom) {
            Rectangle().fill(.black.opacity(0.06)).frame(height: 1)
        }
    }

    private var configuration: some View {
        HStack(alignment: .top, spacing: 18) {
            selectionField(title: "CURRENCY", icon: "banknote") {
                Picker("Currency", selection: $model.selectedCurrency) {
                    ForEach(Currency.allCases) { currency in
                        Text(currency.title).tag(currency)
                    }
                }
                .labelsHidden()
                .pickerStyle(.menu)
                .frame(maxWidth: .infinity, alignment: .leading)
            }

            selectionField(title: "LANGUAGE", icon: "globe") {
                Picker("Language", selection: $model.selectedLanguage) {
                    ForEach(AppLanguage.allCases) { language in
                        Text(language.title).tag(language)
                    }
                }
                .labelsHidden()
                .pickerStyle(.menu)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }

    private func selectionField<Content: View>(
        title: String,
        icon: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Label(title, systemImage: icon)
                .font(.system(size: 11, weight: .bold))
                .tracking(0.8)
                .foregroundStyle(.secondary)
            content()
                .font(.system(size: 15, weight: .medium))
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .frame(maxWidth: .infinity, minHeight: 40, alignment: .leading)
                .background(.white)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .overlay {
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(.black.opacity(0.09), lineWidth: 1)
                }
        }
        .frame(maxWidth: .infinity)
    }

    private var amountEntry: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("AMOUNT", systemImage: "number")
                .font(.system(size: 11, weight: .bold))
                .tracking(0.8)
                .foregroundStyle(.secondary)
            HStack(spacing: 12) {
                Text(model.selectedCurrency.symbol)
                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                    .foregroundStyle(.indigo)
                TextField(model.selectedLanguage.amountPlaceholder, text: $model.amountInput)
                    .font(.system(size: 25, weight: .semibold, design: .rounded))
                    .textFieldStyle(.plain)
                    .focused($amountFieldFocused)
                    .onChange(of: model.amountInput) {
                        model.copied = false
                    }
                if !model.amountInput.isEmpty {
                    Button {
                        model.amountInput = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.tertiary)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
            .background(.white)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay {
                RoundedRectangle(cornerRadius: 14)
                    .stroke(amount == nil && !model.amountInput.isEmpty ? .red.opacity(0.5) : .indigo.opacity(0.3), lineWidth: 1)
                    .allowsHitTesting(false)
            }
            Text("Use a comma or period for decimals (up to 2 places).")
                .font(.system(size: 12))
                .foregroundStyle(.tertiary)
        }
        .onAppear {
            amountFieldFocused = true
        }
    }

    private var resultCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Label("IN WORDS", systemImage: "text.alignleft")
                    .font(.system(size: 11, weight: .bold))
                    .tracking(0.8)
                    .foregroundStyle(.secondary)
                Spacer()
                if result != nil {
                    Button {
                        if let result {
                            NSPasteboard.general.clearContents()
                            NSPasteboard.general.setString(capitalized(result), forType: .string)
                            model.copied = true
                        }
                    } label: {
                        Label(model.copied ? "Copied" : "Copy", systemImage: model.copied ? "checkmark" : "doc.on.doc")
                            .font(.system(size: 12, weight: .medium))
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                }
            }
            if let result {
                Text(capitalized(result))
                    .font(.system(size: 22, weight: .medium, design: .rounded))
                    .foregroundStyle(.primary)
                    .fixedSize(horizontal: false, vertical: true)
                    .textSelection(.enabled)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityLabel("Amount in words: \(result)")
            } else {
                Text(errorMessage)
                    .font(.system(size: 15))
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, minHeight: 58, alignment: .leading)
            }
        }
        .padding(22)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.indigo.opacity(0.055))
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .overlay {
            RoundedRectangle(cornerRadius: 18)
                .stroke(Color.indigo.opacity(0.12), lineWidth: 1)
        }
    }

    private var errorMessage: String {
        if model.amountInput.isEmpty { return "Enter an amount to see it written out." }
        return switch model.selectedLanguage {
        case .portuguese: "Insira um valor válido, com até duas casas decimais."
        case .english: "Enter a valid amount with up to two decimal places."
        case .spanish: "Introduce un importe válido con hasta dos decimales."
        }
    }

    private func capitalized(_ value: String) -> String {
        String(value.prefix(1)).uppercased() + String(value.dropFirst())
    }

    private var footer: some View {
        HStack {
            Image(systemName: "info.circle")
            Text("Supports values up to 999,999,999,999.99")
            Spacer()
            Text("Currency to Words")
                .foregroundStyle(.tertiary)
        }
        .font(.system(size: 11))
        .foregroundStyle(.secondary)
        .padding(.horizontal, 32)
        .padding(.vertical, 18)
    }
}

private extension Currency {
    var symbol: String {
        switch self {
        case .eur: "€"
        case .usd: "$"
        case .gbp: "£"
        case .brl: "R$"
        }
    }
}
