import Foundation

/// A single career-exploration question with RIASEC-mapped answer options.
/// Phase 6: static bank of 6 generic questions.
/// Phase 8: SmartQuestionGenerator replaces this with questions personalized to
/// the user's actual skill profile, swipe history, and O*NET occupation data.
public struct QuestionCard: Sendable {
    public struct Option: Sendable {
        public let label: String
        /// Matches InferredManifestProfile riasecXxxDirect field keys:
        /// "realistic" | "investigative" | "artistic" | "social" | "enterprising" | "conventional"
        public let riasecKey: String
    }
    public let text: String
    public let options: [Option]
}

// PHASE8-UPGRADE: QuestionBank — replace static questions with SmartQuestionGenerator.
// SmartQuestionGenerator reads InferredManifestProfile + swipe history to ask only where
// RIASEC confidence is low. It also generates role-specific questions ("You've swiped right
// on 8 data roles — how open are you to Data Science Manager?") using O*NET occupation data
// from Phase 7. QuestionBank.all stays as the fallback when no personalization is possible.
// Reference: V7/V8 SmartQuestionGenerator.swift, ManifestAwareQuestionGenerator.swift,
// FallbackQuestionCoordinator.swift, CareerQuestionsSeed.swift
/// Static question bank for Phase 6.
/// Questions are framed as career-exploration prompts, not personality test items.
/// The RIASEC mapping is invisible to the user — they're answering "what kind of work
/// energizes me" not "am I an Investigative type."
public enum QuestionBank {
    public static let all: [QuestionCard] = [
        QuestionCard(
            text: "Which challenge at work gives you the most energy?",
            options: [
                .init(label: "Solving a complex technical or analytical problem", riasecKey: "investigative"),
                .init(label: "Leading a team to deliver a big outcome",           riasecKey: "enterprising"),
                .init(label: "Building or designing something from scratch",        riasecKey: "realistic"),
                .init(label: "Helping someone navigate something difficult",        riasecKey: "social")
            ]
        ),
        QuestionCard(
            text: "If you could build one skill over the next year, what would move the needle most?",
            options: [
                .init(label: "Advanced technical depth in your domain",        riasecKey: "investigative"),
                .init(label: "Leadership and managing people effectively",      riasecKey: "enterprising"),
                .init(label: "Creative thinking and product design",            riasecKey: "artistic"),
                .init(label: "Systems thinking and operational efficiency",     riasecKey: "conventional")
            ]
        ),
        QuestionCard(
            text: "Which adjacent path interests you most, given where you've been heading?",
            options: [
                .init(label: "Analyst or specialist track — go deeper in your domain",  riasecKey: "investigative"),
                .init(label: "Manager or leadership track — own outcomes and people",   riasecKey: "enterprising"),
                .init(label: "Design or product track — shape the user experience",     riasecKey: "artistic"),
                .init(label: "Operations or program management — keep the machine running", riasecKey: "conventional")
            ]
        ),
        QuestionCard(
            text: "When you imagine your ideal work day, which feels most true?",
            options: [
                .init(label: "Long focused blocks solving hard problems alone",     riasecKey: "investigative"),
                .init(label: "Running meetings, driving decisions, unblocking people", riasecKey: "enterprising"),
                .init(label: "Creating things that didn't exist before",             riasecKey: "artistic"),
                .init(label: "A reliable rhythm with clear goals and outcomes",      riasecKey: "conventional")
            ]
        ),
        QuestionCard(
            text: "What would make you feel most valued at work?",
            options: [
                .init(label: "Being recognized as the expert others come to",     riasecKey: "investigative"),
                .init(label: "Having real ownership over strategy and direction",  riasecKey: "enterprising"),
                .init(label: "Seeing your creative work actually shipped and used", riasecKey: "artistic"),
                .init(label: "Knowing the team runs smoothly because of your work", riasecKey: "conventional")
            ]
        ),
        QuestionCard(
            text: "A friend with your background asks for career advice. You'd most likely tell them to...",
            options: [
                .init(label: "Go deep — become the technical specialist in your niche", riasecKey: "investigative"),
                .init(label: "Level up into leadership as fast as you can",              riasecKey: "enterprising"),
                .init(label: "Explore cross-functional or creative roles",               riasecKey: "artistic"),
                .init(label: "Find a high-leverage operations or program role",          riasecKey: "conventional")
            ]
        )
    ]
}
