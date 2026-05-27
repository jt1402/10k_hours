import Foundation

#if canImport(AlarmKit)
import AlarmKit

// Per-alarm metadata for the AlarmKit-owned Live Activity. Lives in Shared so
// both the app (scheduling) and the widget (rendering `AlarmAttributes<GoalMetadata>`)
// see the same type. Carries the pursuit name/accent for the templated UI.
//
// NOTE: Shared is compiled into the widget target too, which does not link the
// app's AppConstants — so the default accent is a literal here.
@available(iOS 26.0, *)
struct GoalMetadata: AlarmMetadata {
  var pursuitName: String
  var pursuitColorARGB: Int

  init(pursuitName: String = "", pursuitColorARGB: Int = 0xFF14_B8A6) {
    self.pursuitName = pursuitName
    self.pursuitColorARGB = pursuitColorARGB
  }
}
#endif
