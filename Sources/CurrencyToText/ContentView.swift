import SwiftUI
import Combine
import AppKit

@MainActor
private final class ConversionModel: ObservableObject {
    @Published var amountInput = "123.45"
    @Published var selectedCurrency: Currency = .eur
    @Published var selectedLanguage: AppLanguage = .portuguese
    @Published var copied = false
    @Published var amountFieldFocused = false
}

struct ContentView: View {
    @StateObject private var model = ConversionModel()

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
                Text("Currency in Text")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                Text("Turn an amount into text")
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
                LocalizedAmountField(
                    text: $model.amountInput,
                    language: model.selectedLanguage,
                    placeholder: model.selectedLanguage.amountPlaceholder,
                    isFocused: $model.amountFieldFocused
                )
                    .frame(height: 32)
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
            Text("Uses your selected language's number separators (up to 2 decimal places).")
                .font(.system(size: 12))
                .foregroundStyle(.tertiary)
        }
        .onAppear {
            model.amountFieldFocused = true
        }
    }

    private var resultCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Label("IN TEXT", systemImage: "text.alignleft")
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
                    .accessibilityLabel("Amount in text: \(result)")
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
        case .german: "Geben Sie einen gültigen Betrag mit höchstens zwei Dezimalstellen ein."
        case .japanese: "小数点以下2桁までの有効な金額を入力してください。"
        case .russian: "Введите корректную сумму не более чем с двумя знаками после запятой."
        case .french: "Saisissez un montant valide avec au maximum deux décimales."
        case .korean: "소수점 이하 두 자리까지의 올바른 금액을 입력하세요."
        case .chineseSimplified: "请输入有效金额，小数点后最多两位。"
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
            Text("Currency to Text")
                .foregroundStyle(.tertiary)
        }
        .font(.system(size: 11))
        .foregroundStyle(.secondary)
        .padding(.horizontal, 32)
        .padding(.vertical, 18)
    }
}

private struct LocalizedAmountField: NSViewRepresentable {
    @Binding var text: String
    let language: AppLanguage
    let placeholder: String
    @Binding var isFocused: Bool

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func makeNSView(context: Context) -> NSTextField {
        let textField = NSTextField(string: language.formattedAmountInput(text))
        textField.isBezeled = false
        textField.drawsBackground = false
        textField.focusRingType = .none
        textField.font = .systemFont(ofSize: 25, weight: .semibold)
        textField.textColor = .labelColor
        textField.placeholderString = placeholder
        textField.delegate = context.coordinator
        return textField
    }

    func updateNSView(_ textField: NSTextField, context: Context) {
        context.coordinator.parent = self
        textField.placeholderString = placeholder

        let formatted = language.formattedAmountInput(text)
        if textField.stringValue != formatted {
            let selection = textField.currentEditor()?.selectedRange ?? NSRange(
                location: (textField.stringValue as NSString).length,
                length: 0
            )
            let start = Coordinator.semanticPosition(selection.location, in: textField.stringValue, language: language)
            let end = Coordinator.semanticPosition(NSMaxRange(selection), in: textField.stringValue, language: language)
            textField.stringValue = formatted
            Coordinator.restoreSelection(start: start, end: end, in: textField, language: language)
        }

        if isFocused, textField.currentEditor() == nil {
            textField.window?.makeFirstResponder(textField)
        }
    }

    @MainActor
    final class Coordinator: NSObject, NSTextFieldDelegate {
        var parent: LocalizedAmountField

        init(parent: LocalizedAmountField) {
            self.parent = parent
        }

        func controlTextDidBeginEditing(_ notification: Notification) {
            parent.isFocused = true
        }

        func controlTextDidEndEditing(_ notification: Notification) {
            parent.isFocused = false
        }

        func controlTextDidChange(_ notification: Notification) {
            guard let textField = notification.object as? NSTextField else { return }
            let current = textField.stringValue
            let selection = textField.currentEditor()?.selectedRange ?? NSRange(
                location: (current as NSString).length,
                length: 0
            )
            let start = Self.semanticPosition(selection.location, in: current, language: parent.language)
            let end = Self.semanticPosition(NSMaxRange(selection), in: current, language: parent.language)
            let wasGrouped = parent.language.formattedAmountInput(parent.text)
                .contains(parent.language.groupingSeparator)
            parent.text = parent.language.normalizedAmountInput(current, allowAlternateDecimal: !wasGrouped)

            let formatted = parent.language.formattedAmountInput(parent.text)
            guard formatted != current else { return }
            textField.stringValue = formatted
            Self.restoreSelection(start: start, end: end, in: textField, language: parent.language)
        }

        static func semanticPosition(_ offset: Int, in string: String, language: AppLanguage) -> Int {
            let source = string as NSString
            let end = min(offset, source.length)
            let decimalSeparator: unichar = language.decimalSeparator == "." ? 46 : 44
            var position = 0
            for index in 0..<end {
                let character = source.character(at: index)
                if (48...57).contains(character)
                    || character == 45
                    || character == 43
                    || character == decimalSeparator {
                    position += 1
                }
            }
            return position
        }

        static func restoreSelection(start: Int, end: Int, in textField: NSTextField, language: AppLanguage) {
            guard let editor = textField.currentEditor() as? NSTextView else { return }
            let startOffset = visualOffset(for: start, in: textField.stringValue, language: language)
            let endOffset = visualOffset(for: end, in: textField.stringValue, language: language)
            editor.setSelectedRange(NSRange(location: startOffset, length: max(0, endOffset - startOffset)))
        }

        private static func visualOffset(for position: Int, in string: String, language: AppLanguage) -> Int {
            guard position > 0 else { return 0 }
            let decimalSeparator: unichar = language.decimalSeparator == "." ? 46 : 44
            var semanticPosition = 0
            for (index, character) in string.utf16.enumerated() {
                if (48...57).contains(character)
                    || character == 45
                    || character == 43
                    || character == decimalSeparator {
                    semanticPosition += 1
                    if semanticPosition == position {
                        return index + 1
                    }
                }
            }
            return (string as NSString).length
        }
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
