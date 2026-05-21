import SwiftUI
import JobNormalizer
import CoreTaxonomy

@MainActor
public struct JobCardView: View {
    let job: Job
    let profileBlend: Double
    let dragOffset: CGSize
    let isTop: Bool

    public init(job: Job, profileBlend: Double, dragOffset: CGSize = .zero, isTop: Bool = false) {
        self.job = job
        self.profileBlend = profileBlend
        self.dragOffset = dragOffset
        self.isTop = isTop
    }

    public var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: SacredUI.Card.cornerRadius)
                .fill(Color(.systemBackground))
                .shadow(
                    color: .black.opacity(SacredUI.CardStyle.shadowOpacity),
                    radius: SacredUI.CardStyle.shadowRadius,
                    y: SacredUI.CardStyle.shadowY
                )

            VStack(alignment: .leading, spacing: SacredUI.Spacing.section) {
                headerRow
                locationRow
                if !job.requirements.isEmpty { skillsRow }
                if let salary = job.salary { salaryRow(salary) }
                Spacer(minLength: 0)
                if !job.description.isEmpty { descriptionRow }
            }
            .padding(SacredUI.Spacing.cardPadding)

            if isTop { swipeOverlays }
        }
    }

    // MARK: - Sub-views

    private var headerRow: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: SacredUI.Spacing.xxsmall) {
                Text(job.company)
                    .font(SacredUI.Typography.caption1)
                    .foregroundStyle(SacredUI.SemanticColor.textSecondary)
                Text(job.title)
                    .font(SacredUI.Typography.title1)
                    .foregroundStyle(SacredUI.SemanticColor.text)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer()
            scoreBadge
        }
    }

    private var scoreBadge: some View {
        Group {
            if let score = job.thompsonScore {
                Text("\(Int(score.combinedScore * 100))%")
                    .font(SacredUI.Typography.title2)
                    .foregroundStyle(scoreColor)
                    .padding(.horizontal, SacredUI.Spacing.compact)
                    .padding(.vertical, SacredUI.Spacing.small)
                    .background(scoreColor.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: SacredUI.CardStyle.smallCornerRadius))
                    .accessibilityLabel("Match score \(Int(score.combinedScore * 100)) percent")
            }
        }
    }

    private var locationRow: some View {
        HStack(spacing: SacredUI.Spacing.small) {
            Image(systemName: "mappin.circle.fill")
                .foregroundStyle(SacredUI.SemanticColor.textSecondary)
                .accessibilityHidden(true)
            Text(job.location)
                .font(SacredUI.Typography.body2)
                .foregroundStyle(SacredUI.SemanticColor.textSecondary)
            if job.isRemote {
                Text("Remote")
                    .font(SacredUI.Typography.caption1)
                    .padding(.horizontal, SacredUI.Spacing.small)
                    .padding(.vertical, 2)
                    .background(SacredUI.SemanticColor.teal.opacity(0.15))
                    .foregroundStyle(SacredUI.SemanticColor.teal)
                    .clipShape(Capsule())
            }
            Spacer()
            if let level = job.experienceLevel {
                Text(level)
                    .font(SacredUI.Typography.caption1)
                    .foregroundStyle(SacredUI.SemanticColor.textSecondary)
            }
        }
    }

    private var skillsRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: SacredUI.Spacing.small) {
                ForEach(job.requirements.prefix(6), id: \.self) { skill in
                    Text(skill)
                        .font(SacredUI.Typography.caption1)
                        .padding(.horizontal, SacredUI.Spacing.compact)
                        .padding(.vertical, SacredUI.Spacing.xxsmall)
                        .background(scoreColor.opacity(0.10))
                        .foregroundStyle(scoreColor)
                        .clipShape(Capsule())
                }
            }
        }
        .accessibilityLabel("Required skills: \(job.requirements.prefix(6).joined(separator: ", "))")
    }

    private func salaryRow(_ salary: String) -> some View {
        HStack {
            Image(systemName: "dollarsign.circle")
                .foregroundStyle(SacredUI.SemanticColor.success)
                .accessibilityHidden(true)
            Text(salary)
                .font(SacredUI.Typography.body2)
                .foregroundStyle(SacredUI.SemanticColor.text)
        }
    }

    private var descriptionRow: some View {
        Text(job.description)
            .font(SacredUI.Typography.body2)
            .foregroundStyle(SacredUI.SemanticColor.textSecondary)
            .lineLimit(3)
    }

    // MARK: - Swipe overlays (top card only)

    private var swipeOverlays: some View {
        ZStack {
            if dragOffset.width > 50 {
                interestedOverlay
            }
            if dragOffset.width < -50 {
                passOverlay
            }
            if dragOffset.height < -50 {
                saveOverlay
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: SacredUI.Card.cornerRadius))
    }

    private var interestedOverlay: some View {
        VStack {
            HStack {
                Spacer()
                overlayLabel("INTERESTED", color: .green, rotation: -15,
                             opacity: overlayOpacity(dragOffset.width - 50))
                    .padding()
            }
            Spacer()
        }
    }

    private var passOverlay: some View {
        VStack {
            HStack {
                overlayLabel("PASS", color: .red, rotation: 15,
                             opacity: overlayOpacity(-dragOffset.width - 50))
                    .padding()
                Spacer()
            }
            Spacer()
        }
    }

    private var saveOverlay: some View {
        VStack {
            Spacer()
            overlayLabel("SAVE", color: .blue, rotation: 0,
                         opacity: overlayOpacity(-dragOffset.height - 50))
                .padding()
        }
    }

    private func overlayLabel(_ text: String, color: Color, rotation: Double, opacity: Double) -> some View {
        Text(text)
            .font(.system(size: 28, weight: .black))
            .foregroundStyle(color)
            .padding(.horizontal, SacredUI.Spacing.standard)
            .padding(.vertical, SacredUI.Spacing.compact)
            .overlay(
                RoundedRectangle(cornerRadius: SacredUI.CardStyle.smallCornerRadius)
                    .stroke(color, lineWidth: 3)
            )
            .rotationEffect(.degrees(rotation))
            .opacity(opacity)
    }

    private func overlayOpacity(_ delta: CGFloat) -> Double {
        min(1.0, Double(max(0, delta)) / 50.0)
    }

    // MARK: - Computed

    private var scoreColor: Color {
        // Use the per-job Thompson signal (amber/teal arm blend) as the hue driver,
        // falling back to the slider position only when no score is available.
        let ratio = job.thompsonScore?.personalScore ?? profileBlend
        let hue = SacredUI.DualProfile.amberHue +
                  (SacredUI.DualProfile.tealHue - SacredUI.DualProfile.amberHue) * ratio
        return Color(hue: hue, saturation: SacredUI.DualProfile.saturation,
                     brightness: SacredUI.DualProfile.brightness)
    }
}
