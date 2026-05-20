import SwiftUI
import CoreData
import Persistence
import AdCards

@MainActor
public struct OnboardingView: View {
    let onComplete: () -> Void

    @Environment(\.managedObjectContext) private var context

    @State private var step: Int = 0
    @State private var name: String = ""
    @State private var roleInput: String = ""
    @State private var desiredRoles: [String] = []
    @State private var city: String = ""
    @State private var country: String = ""

    public init(onComplete: @escaping () -> Void) {
        self.onComplete = onComplete
    }

    public var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                progressBar
                    .padding(.horizontal)
                    .padding(.top)

                TabView(selection: $step) {
                    welcomeStep.tag(0)
                    rolesStep.tag(1)
                    locationStep.tag(2)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut, value: step)
            }
            .navigationTitle(stepTitle)
            .navigationBarTitleDisplayMode(.large)
        }
    }

    // MARK: - Progress

    private var progressBar: some View {
        HStack(spacing: 8) {
            ForEach(0..<3) { i in
                Capsule()
                    .fill(i <= step ? Color.blue : Color(.systemGray4))
                    .frame(height: 4)
                    .animation(.easeInOut, value: step)
            }
        }
    }

    private var stepTitle: String {
        switch step {
        case 0: return "Welcome"
        case 1: return "Target Roles"
        default: return "Your Location"
        }
    }

    // MARK: - Step 0: Name

    private var welcomeStep: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("Let's set up your profile so we can find the right matches.")
                .foregroundStyle(.secondary)

            VStack(alignment: .leading, spacing: 8) {
                Text("Your name").font(.headline)
                TextField("Full name", text: $name)
                    .textFieldStyle(.roundedBorder)
                    .textContentType(.name)
                    .submitLabel(.next)
                    .onSubmit { if !name.trimmingCharacters(in: .whitespaces).isEmpty { step = 1 } }
            }

            Spacer()

            Button("Next") { step = 1 }
                .buttonStyle(PrimaryButtonStyle())
                .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
        }
        .padding()
    }

    // MARK: - Step 1: Roles

    private var rolesStep: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("Add the job titles you're looking for. You can always change these later.")
                .foregroundStyle(.secondary)

            HStack {
                TextField("e.g. iOS Engineer", text: $roleInput)
                    .textFieldStyle(.roundedBorder)
                    .submitLabel(.done)
                    .onSubmit { addRole() }
                Button("Add", action: addRole)
                    .disabled(roleInput.trimmingCharacters(in: .whitespaces).isEmpty)
            }

            if !desiredRoles.isEmpty {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 8) {
                        ForEach(desiredRoles, id: \.self) { role in
                            HStack {
                                Text(role)
                                    .font(.body)
                                Spacer()
                                Button {
                                    desiredRoles.removeAll { $0 == role }
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundStyle(.secondary)
                                }
                                .accessibilityLabel("Remove \(role)")
                            }
                            .padding(.vertical, 4)
                            Divider()
                        }
                    }
                }
                .frame(maxHeight: 200)
            } else {
                Text("No roles added yet")
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            }

            Spacer()

            Button(desiredRoles.isEmpty ? "Skip" : "Next") { step = 2 }
                .buttonStyle(PrimaryButtonStyle())
        }
        .padding()
    }

    // MARK: - Step 2: Location

    private var locationStep: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("Your location helps us score jobs by commute distance and remote compatibility.")
                .foregroundStyle(.secondary)

            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("City").font(.headline)
                    TextField("e.g. San Francisco", text: $city)
                        .textFieldStyle(.roundedBorder)
                        .textContentType(.addressCity)
                }
                VStack(alignment: .leading, spacing: 8) {
                    Text("Country").font(.headline)
                    TextField("e.g. United States", text: $country)
                        .textFieldStyle(.roundedBorder)
                        .textContentType(.countryName)
                }
            }

            Spacer()

            Button("Start Discovering") { completeOnboarding() }
                .buttonStyle(PrimaryButtonStyle())
        }
        .padding()
    }

    // MARK: - Actions

    private func addRole() {
        let trimmed = roleInput.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty, !desiredRoles.contains(trimmed) else { return }
        desiredRoles.append(trimmed)
        roleInput = ""
    }

    private func completeOnboarding() {
        let profile = Persistence.UserProfile.createNew(in: context)
        profile.name = name.trimmingCharacters(in: .whitespaces).isEmpty ? "User" :
                       name.trimmingCharacters(in: .whitespaces)
        profile.email = ""
        profile.desiredRoles = desiredRoles
        profile.primaryLocationCity = city.trimmingCharacters(in: .whitespaces).isEmpty ? nil :
                                      city.trimmingCharacters(in: .whitespaces)
        profile.primaryLocationCountry = country.trimmingCharacters(in: .whitespaces).isEmpty ? nil :
                                         country.trimmingCharacters(in: .whitespaces)

        try? context.save()
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
        // ATT prompt fires after onboarding so users have seen the app value first.
        Task { await ATTConsentManager.shared.requestTrackingAuthorization() }
        onComplete()
    }
}

// MARK: - Button Style

private struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 17, weight: .semibold))
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(configuration.isPressed ? Color.blue.opacity(0.8) : Color.blue)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}
