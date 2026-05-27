import SwiftUI

// Shown when there are no pursuits yet. Ported from the Flutter HomeScreen
// empty state.
struct EmptyStateView: View {
  var onCreate: () -> Void

  var body: some View {
    VStack(spacing: 16) {
      Text("10k Hours").font(.system(size: 36, weight: .semibold))
      Text("Pick a pursuit. Run the timer. Watch the ring count down.")
        .font(.system(size: 16))
        .foregroundStyle(.secondary)
        .multilineTextAlignment(.center)
      Button(action: onCreate) {
        Text("Create your first pursuit")
          .font(.system(size: 16, weight: .semibold))
          .padding(.horizontal, 20).padding(.vertical, 12)
      }
      .buttonStyle(.borderedProminent)
      .padding(.top, 16)
    }
    .padding(.horizontal, 32)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
  }
}
