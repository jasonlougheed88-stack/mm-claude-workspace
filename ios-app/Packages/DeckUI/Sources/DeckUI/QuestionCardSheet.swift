import SwiftUI
import Intelligence
import CoreTaxonomy

/// Career-exploration question sheet.
/// Fires after every 10 job swipes when the user's RIASEC profile has gaps.
/// Phase 8 replaces the question bank with SmartQuestionGenerator (personalized to swipe
/// history + O*NET occupation data). Phase 6 uses static generic questions.
@MainActor
struct QuestionCardSheet: View {
    let question: QuestionCard
    let onAnswer: (String) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var answered: String? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            header
            Spacer().frame(height: SacredUI.Spacing.section)
            questionText
            Spacer().frame(height: SacredUI.Spacing.section)
            optionList
            Spacer()
            skipButton
        }
        .padding(SacredUI.Spacing.standard)
        .background(Color(.systemBackground))
    }

    // MARK: - Components

    private var header: some View {
        HStack(spacing: SacredUI.Spacing.compact) {
            Image(systemName: "sparkles")
                .foregroundStyle(SacredUI.SemanticColor.teal)
                .font(.system(size: 18, weight: .semibold))
            Text("Help us chart your path")
                .font(SacredUI.Typography.caption1)
                .foregroundStyle(SacredUI.SemanticColor.teal)
                .fontWeight(.semibold)
                .textCase(.uppercase)
                .tracking(1.0)
            Spacer()
        }
        .padding(.top, SacredUI.Spacing.standard)
        .accessibilityHidden(true)
    }

    private var questionText: some View {
        Text(question.text)
            .font(SacredUI.Typography.title2)
            .fixedSize(horizontal: false, vertical: true)
    }

    private var optionList: some View {
        VStack(spacing: SacredUI.Spacing.compact) {
            ForEach(question.options.indices, id: \.self) { i in
                let option = question.options[i]
                optionButton(option)
            }
        }
    }

    private func optionButton(_ option: QuestionCard.Option) -> some View {
        let isSelected = answered == option.riasecKey
        return Button {
            answered = option.riasecKey
            onAnswer(option.riasecKey)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                dismiss()
            }
        } label: {
            HStack {
                Text(option.label)
                    .font(SacredUI.Typography.body2)
                    .multilineTextAlignment(.leading)
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(SacredUI.SemanticColor.teal)
                }
            }
            .padding(SacredUI.Spacing.standard)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected
                          ? SacredUI.SemanticColor.teal.opacity(0.12)
                          : Color(.secondarySystemBackground))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(
                        isSelected ? SacredUI.SemanticColor.teal : Color.clear,
                        lineWidth: 1.5
                    )
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel(option.label)
        .disabled(answered != nil)
    }

    private var skipButton: some View {
        Button("Skip for now") {
            dismiss()
        }
        .font(SacredUI.Typography.body2)
        .foregroundStyle(SacredUI.SemanticColor.textSecondary)
        .frame(maxWidth: .infinity)
        .padding(.bottom, SacredUI.Spacing.large)
        .accessibilityLabel("Skip this question")
    }
}
