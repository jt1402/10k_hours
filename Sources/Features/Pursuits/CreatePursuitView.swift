import SwiftData
import SwiftUI

// Create a pursuit: name (required), accent, and a target — default 10,000 h,
// a short HH:MM:SS timer, or a custom hour goal. Ported from the Flutter
// CreatePursuitScreen (with an added accent palette the data model supports).
struct CreatePursuitView: View {
  var onCreated: (Int) -> Void

  @Environment(\.modelContext) private var context

  private enum TargetMode: String, CaseIterable, Identifiable {
    case defaultGoal = "10,000 h"
    case short = "Short"
    case custom = "Custom"
    var id: String { rawValue }
  }

  @State private var name = ""
  @State private var mode: TargetMode = .defaultGoal
  @State private var accentARGB = AccentPalette.colors[0]
  @State private var shortHours = 0
  @State private var shortMinutes = 30
  @State private var shortSeconds = 0
  @State private var customHours = "\(AppConstants.defaultTargetMinutes / 60)"

  private var trimmedName: String { name.trimmingCharacters(in: .whitespacesAndNewlines) }

  private var resolvedTargetSeconds: Int {
    switch mode {
    case .defaultGoal: return AppConstants.defaultTargetMinutes * 60
    case .short: return shortHours * 3600 + shortMinutes * 60 + shortSeconds  // sub-minute OK
    case .custom: return (Int(customHours) ?? 0) * 3600
    }
  }

  private var canSubmit: Bool { !trimmedName.isEmpty && resolvedTargetSeconds > 0 }

  var body: some View {
    Form {
      Section("What are you mastering?") {
        TextField("e.g. learning guitar", text: $name)
          .textInputAutocapitalization(.sentences)
      }

      Section("Accent") {
        ScrollView(.horizontal, showsIndicators: false) {
          HStack(spacing: 14) {
            ForEach(AccentPalette.colors, id: \.self) { argb in
              Circle()
                .fill(Color(argb: argb))
                .frame(width: 34, height: 34)
                .overlay {
                  if argb == accentARGB {
                    Image(systemName: "checkmark").font(.system(size: 14, weight: .bold)).foregroundStyle(.white)
                  }
                }
                .onTapGesture { accentARGB = argb }
            }
          }
          .padding(.vertical, 4)
        }
      }

      Section("Target") {
        Picker("Target", selection: $mode) {
          ForEach(TargetMode.allCases) { Text($0.rawValue).tag($0) }
        }
        .pickerStyle(.segmented)

        switch mode {
        case .defaultGoal:
          Text("The classic 10,000-hour goal. Best for long-term mastery.")
            .font(.footnote).foregroundStyle(.secondary)
        case .short:
          Text("Pick hours, minutes, seconds. Max 23:59:59.")
            .font(.caption).foregroundStyle(.secondary)
          HStack(spacing: 0) {
            wheel($shortHours, range: 0..<24, label: "h")
            wheel($shortMinutes, range: 0..<60, label: "m")
            wheel($shortSeconds, range: 0..<60, label: "s")
          }
          .frame(height: 140)
        case .custom:
          TextField("Target hours", text: $customHours)
            .keyboardType(.numberPad)
        }
      }

      Section {
        Button("Start tracking") { submit() }
          .frame(maxWidth: .infinity)
          .disabled(!canSubmit)
      }
    }
    .navigationTitle("New pursuit")
    .navigationBarTitleDisplayMode(.inline)
  }

  private func wheel(_ value: Binding<Int>, range: Range<Int>, label: String) -> some View {
    HStack(spacing: 2) {
      Picker(label, selection: value) {
        ForEach(range, id: \.self) { Text(String(format: "%02d", $0)).tag($0) }
      }
      .pickerStyle(.wheel)
      .frame(maxWidth: .infinity)
      Text(label).font(.caption).foregroundStyle(.secondary)
    }
  }

  private func submit() {
    guard canSubmit else { return }
    let pursuit = PursuitStore(context: context).create(
      name: trimmedName,
      accentColor: accentARGB,
      targetSeconds: resolvedTargetSeconds
    )
    onCreated(pursuit.id)
  }
}
