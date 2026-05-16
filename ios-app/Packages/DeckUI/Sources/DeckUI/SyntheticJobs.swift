import JobNormalizer

// PHASE4-SYNTHETIC: This is the ONLY source of job data for Phase 4.
// Phase 5: Remove this file. Wire DeckScreen.loadJobs() → JobPipeline.fetchJobs(userProfile:).
enum SyntheticJobs {
    static let all: [Job] = [
        // iOS / Mobile
        Job(title: "iOS Engineer", company: "Apex Mobile", location: "San Francisco, CA",
            description: "Build production iOS apps with Swift and SwiftUI. Own features end-to-end.",
            requirements: ["Swift", "SwiftUI", "UIKit", "Xcode", "REST APIs", "Core Data"],
            isRemote: false, workLocationType: .onsite),

        Job(title: "Senior iOS Developer", company: "FinTech Co", location: "New York, NY",
            description: "Lead iOS development for our consumer financial platform. 5M+ users.",
            requirements: ["Swift", "Core Data", "XCTest", "CI/CD", "Combine"],
            isRemote: false, workLocationType: .hybrid),

        Job(title: "iOS Software Engineer", company: "HealthTrack", location: "Remote",
            description: "Remote-first team building iOS health monitoring apps.",
            requirements: ["Swift", "HealthKit", "SwiftUI", "CloudKit"],
            isRemote: true, workLocationType: .remote),

        // Backend / Full-Stack
        Job(title: "Backend Engineer", company: "CloudStream", location: "Remote",
            description: "Design and build scalable REST APIs using Python and Go.",
            requirements: ["Python", "Go", "PostgreSQL", "Docker", "Kubernetes"],
            isRemote: true, workLocationType: .remote),

        Job(title: "Full Stack Developer", company: "Acme SaaS", location: "Austin, TX",
            description: "Build features across our React frontend and Node.js backend.",
            requirements: ["React", "TypeScript", "Node.js", "PostgreSQL", "AWS"],
            isRemote: false, workLocationType: .hybrid),

        // Data / ML
        Job(title: "Data Scientist", company: "Insight Analytics", location: "Seattle, WA",
            description: "Build ML models to predict customer churn and drive product decisions.",
            requirements: ["Python", "PyTorch", "SQL", "Statistics", "A/B Testing"],
            isRemote: false, workLocationType: .hybrid),

        Job(title: "Machine Learning Engineer", company: "NeuralCo", location: "Remote",
            description: "Deploy production ML models serving 50M requests per day.",
            requirements: ["Python", "PyTorch", "MLOps", "Kubernetes", "SQL"],
            isRemote: true, workLocationType: .remote),

        // Product / Design
        Job(title: "Product Manager", company: "GrowthLabs", location: "San Francisco, CA",
            description: "Drive product strategy for our B2B SaaS platform.",
            requirements: ["Product Strategy", "SQL", "User Research", "Agile", "Roadmapping"],
            isRemote: false, workLocationType: .onsite),

        Job(title: "Senior Product Designer", company: "Designify", location: "Remote",
            description: "Own end-to-end design for mobile and web products.",
            requirements: ["Figma", "User Research", "Prototyping", "Design Systems"],
            isRemote: true, workLocationType: .remote),

        // DevOps / Platform
        Job(title: "DevOps Engineer", company: "Infra Inc", location: "Remote",
            description: "Build and maintain CI/CD pipelines and cloud infrastructure.",
            requirements: ["AWS", "Terraform", "Kubernetes", "Docker", "Python"],
            isRemote: true, workLocationType: .remote),

        Job(title: "Platform Engineer", company: "ScaleUp", location: "Chicago, IL",
            description: "Build developer tooling and internal platforms for 200+ engineers.",
            requirements: ["Go", "Kubernetes", "AWS", "CI/CD", "Linux"],
            isRemote: false, workLocationType: .hybrid),

        // Software General
        Job(title: "Software Engineer", company: "TechCorp", location: "Seattle, WA",
            description: "Join a cross-functional team building distributed systems.",
            requirements: ["Python", "Distributed Systems", "SQL", "REST APIs", "Testing"],
            isRemote: false, workLocationType: .hybrid),

        Job(title: "Staff Software Engineer", company: "ScaleHQ", location: "Remote",
            description: "Technical leadership across multiple teams. IC track, no direct reports.",
            requirements: ["System Design", "Python", "Go", "Mentoring", "Architecture"],
            isRemote: true, workLocationType: .remote),

        // Mobile (other platforms / cross-platform)
        Job(title: "React Native Developer", company: "Mobility Labs", location: "Austin, TX",
            description: "Build cross-platform mobile apps for Android and iOS.",
            requirements: ["React Native", "TypeScript", "React", "REST APIs"],
            isRemote: false, workLocationType: .hybrid),

        // Security
        Job(title: "Security Engineer", company: "ShieldCo", location: "Remote",
            description: "Build and maintain security infrastructure, conduct threat modeling.",
            requirements: ["Python", "Security", "Penetration Testing", "AWS", "Networking"],
            isRemote: true, workLocationType: .remote),

        // QA / Testing
        Job(title: "QA Engineer", company: "QualityFirst", location: "Denver, CO",
            description: "Own automated testing strategy for iOS and Android apps.",
            requirements: ["XCTest", "Espresso", "Python", "CI/CD", "Test Planning"],
            isRemote: false, workLocationType: .hybrid),

        // Leadership
        Job(title: "Engineering Manager", company: "TeamBuilder", location: "Remote",
            description: "Lead a team of 6 engineers. 70% technical, 30% people management.",
            requirements: ["Leadership", "Swift", "System Design", "Hiring", "Agile"],
            isRemote: true, workLocationType: .remote),

        // Analytics / Growth
        Job(title: "Growth Engineer", company: "Rocketship", location: "New York, NY",
            description: "Build experimentation infrastructure and growth features.",
            requirements: ["Python", "SQL", "A/B Testing", "Analytics", "React"],
            isRemote: false, workLocationType: .hybrid),

        // Startup catch-all
        Job(title: "Software Engineer (Early Stage)", company: "Founding Team", location: "Remote",
            description: "First engineering hire at a pre-seed startup. Own the entire stack.",
            requirements: ["Swift", "Python", "PostgreSQL", "AWS", "Full Stack"],
            isRemote: true, workLocationType: .remote),

        Job(title: "macOS & iOS Engineer", company: "Desktop Plus", location: "San Francisco, CA",
            description: "Build native macOS and iOS apps with shared Swift codebase.",
            requirements: ["Swift", "SwiftUI", "AppKit", "Core Data", "iCloud"],
            isRemote: false, workLocationType: .onsite),
    ]
}
