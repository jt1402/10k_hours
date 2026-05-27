import SwiftUI
import WidgetKit

@main
struct TenKHoursWidgetBundle: WidgetBundle {
  var body: some Widget {
    TenKHoursLiveActivity()
    #if canImport(AlarmKit)
    if #available(iOS 26.0, *) {
      AlarmLiveActivity()
    }
    #endif
  }
}
