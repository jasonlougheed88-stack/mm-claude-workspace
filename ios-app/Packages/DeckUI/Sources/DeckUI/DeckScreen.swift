import SwiftUI
import CoreData
import JobNormalizer
import JobPipeline
import Persistence
import ScoringEngine
import Intelligence
import CoreTaxonomy
import AdCards

// MARK: - Card Item

/// Union type for the deck. Thompson scoring only fires on .job cards — never .ad.
enum CardItem: Sendable {
    case job(Job)
    case ad

    var asJob: Job? {
        if case .job(let j) = self { return j }
        return nil
    }
}

@MainActor
public struct DeckScreen: View {
    let userProfile: JobNormalizer.UserProfile

    @Environment(\.managedObjectContext) private var context

    @State private var cards: [CardItem] = []
    @State private var currentIndex: Int = 0
    @State private var dragOffset: CGSize = .zero
    @State private var isAnimatingOut: Bool = false
    @State private var profileBlend: Double = 0.5
    @State private var isLoading: Bool = true
    @State private var sessionAdsSeen: Int = 0
    @State private var sessionID = UUID()

    public init(userProfile: JobNormalizer.UserProfile) {
        self.userProfile = userProfile
    }

    // MARK: - Body

    public var body: some View {
        VStack(spacing: 0) {
            Group {
                if isLoading {
                    loadingView
                } else if currentIndex >= cards.count {
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
                    cardView(for: cards[index], width: w, height: h, depth: depth, isTop: isTop)
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

    @ViewBuilder
    private func cardView(for card: CardItem, width: CGFloat, height: CGFloat, depth: Int, isTop: Bool) -> some View {
        switch card {
        case .job(let job):
            JobCardView(
                job: job,
                profileBlend: profileBlend,
                dragOffset: isTop ? dragOffset : .zero,
                isTop: isTop
            )
            .frame(width: width, height: height)
        case .ad:
            AdCardView()
                .frame(width: width)
                .padding(.horizontal, SacredUI.Spacing.standard)
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
        guard currentIndex < cards.count, !isAnimatingOut else { return }
        isAnimatingOut = true
        let currentCard = cards[currentIndex]

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

            switch currentCard {
            case .job(let job):
                let score = job.thompsonScore?.combinedScore ?? 0.5
                await OptimizedThompsonEngine.shared.processInteraction(action: action, thompsonScore: score)
                await ManifestInferenceActor.shared.updateManifestProfile(in: context)
                recordInteraction(job: job, action: action, score: score)

            case .ad:
                // Ad swipe: advance deck only. Thompson must not learn from ad interactions.
                sessionAdsSeen += 1
                await AdCardInjector.shared.recordAdShown(at: currentIndex)
            }

            currentIndex += 1
            dragOffset = .zero
            isAnimatingOut = false

            if currentIndex >= cards.count - 5 {
                await appendMoreJobs()
            }
        }
    }

    // MARK: - Job loading

    private func loadJobs() async {
        isLoading = true
        let fetched = await JobPipelineClient.shared.fetchJobs(for: userProfile.preferences.desiredRoles.first ?? "Software Engineer")
        let batch = fetched.isEmpty ? SyntheticJobs.all : fetched
        let scored = await OptimizedThompsonEngine.shared.scoreJobs(batch, profile: userProfile)
        cards = await buildCards(from: scored)
        isLoading = false
    }

    private func reloadJobs() async {
        isLoading = true
        let fetched = await JobPipelineClient.shared.fetchJobs(for: userProfile.preferences.desiredRoles.first ?? "Software Engineer")
        let batch = fetched.isEmpty ? SyntheticJobs.all : fetched
        let scored = await OptimizedThompsonEngine.shared.scoreJobs(batch, profile: userProfile)
        cards = await buildCards(from: scored)
        currentIndex = 0
        sessionAdsSeen = 0
        await AdCardInjector.shared.resetSession()
        isLoading = false
    }

    private func appendMoreJobs() async {
        let fetched = await JobPipelineClient.shared.fetchJobs(for: userProfile.preferences.desiredRoles.first ?? "Software Engineer")
        let batch = fetched.isEmpty ? SyntheticJobs.all : fetched
        let scored = await OptimizedThompsonEngine.shared.scoreJobs(batch, profile: userProfile)
        let newCards = await buildCards(from: scored)
        cards.append(contentsOf: newCards)
    }

    /// Inserts ad cards at injector-calculated positions within a job batch.
    private func buildCards(from jobs: [Job]) async -> [CardItem] {
        let isNewUser = (currentIndex + sessionAdsSeen) < 50
        let positions = await AdCardInjector.shared.calculateAdPositions(
            totalJobs: jobs.count,
            sessionAdCount: sessionAdsSeen,
            isNewUser: isNewUser
        )
        var result: [CardItem] = jobs.map { .job($0) }
        for pos in positions.sorted().reversed() {
            let clampedPos = min(pos, result.count)
            result.insert(.ad, at: clampedPos)
        }
        return result
    }

    // MARK: - Core Data: record swipe

    private func recordInteraction(job: Job, action: SwipeAction, score: Double) {
        let interaction = JobInteraction(context: context)
        interaction.id = UUID()
        interaction.sessionID = sessionID
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
        guard currentIndex < cards.count else { return [] }
        return Array(currentIndex..<min(currentIndex + 3, cards.count))
    }

    private var blendColor: Color {
        Color(hue: SacredUI.DualProfile.amberHue +
              (SacredUI.DualProfile.tealHue - SacredUI.DualProfile.amberHue) * profileBlend,
              saturation: SacredUI.DualProfile.saturation,
              brightness: SacredUI.DualProfile.brightness)
    }
}
