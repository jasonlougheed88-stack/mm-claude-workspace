import SwiftUI
import CareerGrowth
import CoreTaxonomy

@MainActor
struct CourseCardView: View {
    let course: RecommendedCourse
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: SacredUI.Spacing.compact) {
                providerIcon
                courseInfo
                Spacer()
                matchBadge
            }
            .padding(SacredUI.Spacing.compact)
            .background(SacredUI.SemanticColor.surface)
            .clipShape(RoundedRectangle(cornerRadius: SacredUI.CardStyle.mediumCornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: SacredUI.CardStyle.mediumCornerRadius)
                    .stroke(Color(hex: course.provider.brandColor).opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(course.title) from \(course.provider.displayName), \(course.price.displayText)")
        .accessibilityHint("Double-tap to open course")
    }

    private var providerIcon: some View {
        ZStack {
            Circle()
                .fill(Color(hex: course.provider.brandColor).opacity(0.15))
                .frame(width: 44, height: 44)
            Image(systemName: course.provider.logoSystemImage)
                .font(.system(size: 20))
                .foregroundStyle(Color(hex: course.provider.brandColor))
        }
    }

    private var courseInfo: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(course.title)
                .font(SacredUI.Typography.body1)
                .lineLimit(2)
                .foregroundStyle(SacredUI.SemanticColor.text)

            Text(course.provider.displayName)
                .font(SacredUI.Typography.caption1)
                .foregroundStyle(SacredUI.SemanticColor.textSecondary)

            HStack(spacing: SacredUI.Spacing.small) {
                Label(course.difficulty.displayName, systemImage: "chart.bar.fill")
                    .font(SacredUI.Typography.caption1)
                    .foregroundStyle(SacredUI.SemanticColor.textSecondary)

                Text("·")
                    .foregroundStyle(SacredUI.SemanticColor.textSecondary)

                Text(course.formattedDuration)
                    .font(SacredUI.Typography.caption1)
                    .foregroundStyle(SacredUI.SemanticColor.textSecondary)

                Text("·")
                    .foregroundStyle(SacredUI.SemanticColor.textSecondary)

                Text(course.price.displayText)
                    .font(SacredUI.Typography.caption1)
                    .foregroundStyle(course.price == .free ? SacredUI.SemanticColor.teal : SacredUI.SemanticColor.textSecondary)
            }
        }
    }

    private var matchBadge: some View {
        VStack(spacing: 2) {
            if course.skillMatchPercentage > 0 {
                Text("\(Int(course.skillMatchPercentage * 100))%")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(SacredUI.SemanticColor.teal)
                Text("match")
                    .font(SacredUI.Typography.caption1)
                    .foregroundStyle(SacredUI.SemanticColor.textSecondary)
            } else {
                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundStyle(SacredUI.SemanticColor.textSecondary)
            }
        }
    }
}
