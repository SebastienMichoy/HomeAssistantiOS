import Shared
import SwiftUI

struct LocationSettingsView: View {
    var body: some View {
        List {
            AppleLikeListTopRowHeader(
                image: .crosshairsGpsIcon,
                title: L10n.SettingsDetails.Location.title,
                subtitle: L10n.SettingsDetails.Location.body
            )
        }
    }
}
