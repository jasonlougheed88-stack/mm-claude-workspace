import SwiftUI
import CoreData
import JobNormalizer
import Persistence
import ScoringEngine
import Intelligence
import CoreTaxonomy

@MainActor
public struct DeckScreen: View {
    // Both Persistence and JobNormalizer define UserProfile. This stored property uses only
    // JobNormalizer.UserProfile — the fully-qualified name eliminates ambiguity.
    let userProfile: JobNormalizer.UserProfile

    @Environment(\.managedObjectContext) private var context

    @State private var jobs: [Job] = []
    @State private var currentIndex: Int = 0
    @State private var dragOffset: CGSize = .zero
    @State private var isAnimatingOut: Bool = false
    @State private var profileBlend: Double = 0.5
    @State private var isLoading: Bool = true

    public init(userProfile: JobNormalizer.UserProfile) {
        self.userProfile = userProfile
    }

    // MARK: - Body

    public var body: some View {
        VStack(spacing: 0) {
            Group {
                if isLoading {
                    loadingView
                } else if currentIndex >= jobs.count {
                    emptyView
                } else {
                    cardStack
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            controlPanel
        }
        .task { await loadJobs() }
        .onChange(of: profileBlend) { _, newValue in
            Task { await OptimizedThompsonEngine.shared.setProfileBlend(newValue) }
        }
    }

    // MARK: - Loading view

    private var loadingView: some View {
        VStack(spacing: SacredUI.Spacing.section) {
            ProgressView()
            Text("Scoring your matches…")
                .font(SacredUI.Typography.body2)
                .foregroundStyle(SacredUI.SemanticColor.textSecondary)
        }
    }

    // MARK: - Empty view

    private var emptyView: some View {
        VStack(spacing: SacredUI.Spacing.section) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: SacredUI.Icon.hero))
                .foregroundStyle(SacredUI.SemanticColor.teal)
            Text("All caught up!")
                .font(SacredUI.Typography.title2)
            Text("You've seen every job in this batch.")
                .font(SacredUI.Typography.body2)
                .foregroundStyle(SacredUI.SemanticColor.textSecondary)
            Button("Find More") {
                Task { await reloadJobs() }
            }
            .font(SacredUI.Typography.buttonPrimary)
            .foregroundStyle(.white)
            .padding(.horizontal, SacredUI.Spacing.large)
            .padding(.vertical, SacredUI.Spacing.compact)
            .background(SacredUI.SemanticColor.teal)
            .clipShape(Capsule())
        }
    }

    // MARK: - Card stack

    private var cardStack: some View {
        GeometryReader { geo in
            let w = min(geo.size.width * SacredUI.Card.widthRatio, SacredUI.Card.maxWidth)
            let h = min(geo.size.height * 0.95, SacredUI.Card.maxHeight)

            ZStack {
                ForEach(visibleIndices, id: \.self) { index in
                    let depth = index - currentIndex
                    let isTop = depth == 0
                    JobCardView(
                        job: jobs[index],
                        profileBlend: profileBlend,
                        dragOffset: isTop ? dragOffset : .zero,
                        isTop: isTop
                    )
                    .frame(width: w, height: h)
                    .scaleEffect(isTop ? 1.0 : max(0.90, 1.0 - Double(depth) * 0.04))
                    .offset(y: isTop ? 0 : CGFloat(depth) * 10)
                    .offset(isTop ? dragOffset : .zero)
                    .rotationEffect(
                        isTop ? .degrees(Double(dragOffset.width) / SacredUI.Swipe.rotationDivisor) : .zero
                    )
                    .zIndex(isTop ? 100 : Double(50 - depth))
                    .gesture(isTop && !isAnimatingOut ? dragGesture : nil)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    // MARK: - Control panel

    private var controlPanel: some View {
        VStack(spacing: SacredUI.Spacing.compact) {
            HStack(spacing: SacredUI.Spacing.compact) {
                Image(systemName: "briefcase.fill")
                    .foregroundStyle(SacredUI.SemanticColor.amber)
                    .accessibilityHidden(true)
                Slider(value: $profileBlend, in: 0...1)
                    .tint(blendColor)
                    .accessibilityLabel("Balance between current role match and career exploration")
                Image(systemName: "sparkles")
                    .foregroundStyle(SacredUI.SemanticColor.teal)
                    .accessibilityHidden(true)
            }
            .padding(.horizontal, SacredUI.Spacing.standard)

            HStack(spacing: SacredUI.Spacing.large) {
                actionButton(image: "xmark", color: .red, label: "Pass") {
                    triggerSwipe(.pass)
                }
                actionButton(image: "bookmark.fill", color: .blue, label: "Save") {
                    triggerSwipe(.save)
                }
                actionButton(image: "heart.fill", color: .green, label: "Interested") {
                    triggerSwipe(.interested)
                }
            }
            .padding(.bottom, SacredUI.Spacing.large)
        }
        .background(Color(.systemBackground))
    }

    private func actionButton(image: String, color: Color, label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: image)
                .font(.system(size: 24, weight: .medium))
                .foregroundStyle(color)
                .frame(width: 64, height: 64)
                .background(color.opacity(0.12))
                .clipShape(Circle())
        }
        .accessibilityLabel(label)
    }

    // MARK: - Gesture

    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                dragOffset = value.translation
            }
            .onEnded { value in
                let h = value.translation.width
                let v = value.translation.height
                if h > SacredUI.Swipe.rightThreshold {
                    triggerSwipe(.interested)
                } else if h < SacredUI.Swipe.leftThreshold {
                    triggerSwipe(.pass)
                } else if v < SacredUI.Swipe.upThreshold {
                    triggerSwipe(.save)
                } else {
                    withAnimation(.spring(response: SacredUI.Animation.springResponse,
                                          dampingFraction: SacredUI.Animation.springDamping)) {
                        dragOffset = .zero
                    }
                }
            }
    }

    // MARK: - Swipe action

    private func triggerSwipe(_ action: SwipeAction) {
        guard currentIndex < jobs.count, !isAnimatingOut else { return }
        isAnimatingOut = true
        let job = jobs[currentIndex]
        let score = job.thompsonScore?.combinedScore ?? 0.5

        let targetOffset: CGSize
        switch action {
        case .interested, .applied: targetOffset = CGSize(width: 650, height: 0)
        case .pass:                  targetOffset = CGSize(width: -650, height: 0)
        case .save:                  targetOffset = CGSize(width: 0, height: -800)
        }

        withAnimation(.spring(response: SacredUI.Animation.springResponse,
                               dampingFraction: SacredUI.Animation.springDamping)) {
            dragOffset = targetOffset
        }

        Task {
            try? await Task.sleep(nanoseconds: 350_000_000)
            await OptimizedThompsonEngine.shared.processInteraction(action: action, thompsonScore: score)
            await ManifestInferenceActor.shared.updateManifestProfile(in: context)
            recordInteraction(job: job, action: action, score: score)
            currentIndex += 1
            dragOffset = .zero
            isAnimatingOut = false
            if currentIndex >= jobs.count - 5 {
                await appendMoreJobs()
            }
        }
    }

    // MARK: - Job loading

    private func loadJobs() async {
        isLoading = true
        let scored = await OptimizedThompsonEngine.shared.scoreJobs(SyntheticJobs.all, profile: userProfile)
        jobs = scored
        isLoading = false
    }

    private func reloadJobs() async {
        isLoading = true
        let scored = await OptimizedThompsonEngine.shared.scoreJobs(SyntheticJobs.all, profile: userProfile)
        jobs = scored
        currentIndex = 0
        isLoading = false
    }

    private func appendMoreJobs() async {
        let scored = await OptimizedThompsonEngine.shared.scoreJobs(SyntheticJobs.all, profile: userProfile)
        jobs.append(contentsOf: scored)
    }

    // MARK: - Core Data: record swipe

    private func recordInteraction(job: Job, action: SwipeAction, score: Double) {
        let interaction = JobInteraction(context: context)
        interaction.id = UUID()
        interaction.timestamp = Date()
        interaction.jobID = job.id
        interaction.jobTitle = job.title
        interaction.jobCompany = job.company
        interaction.jobRole = job.title
        interaction.action = action.rawValue
        interaction.thompsonScore = score
        interaction.amberTealPosition = profileBlend
        interaction.actionWeight = (action == .interested || action == .applied) ? 2.0 :
                                   (action == .save ? 1.0 : 0.0)
        interaction.isAspirationSignal = profileBlend > 0.5
        if let data = try? JSONEncoder().encode(job.requirements) {
            interaction.jobSkillsData = data
        }
        try? context.save()
    }

    // MARK: - Helpers

    private var visibleIndices: [Int] {
        guard currentIndex < jobs.count else { return [] }
        return Array(currentIndex..<min(currentIndex + 3, jobs.count))
    }

    private var blendColor: Color {
        Color(hue: SacredUI.DualProfile.amberHue +
              (SacredUI.DualProfile.tealHue - SacredUI.DualProfile.amberHue) * profileBlend,
              saturation: SacredUI.DualProfile.saturation,
              brightness: SacredUI.DualProfile.brightness)
    }
}
