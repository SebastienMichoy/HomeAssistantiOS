import Shared
import SwiftUI

/// A SwiftUI view that displays location-related settings and permissions.
struct LocationSettingsView: View {

    // MARK: Properties

    @StateObject private var viewModel = LocationSettingsViewModel()

    // MARK: - View

    var body: some View {
        List {
            AppleLikeListTopRowHeader(
                image: .crosshairsGpsIcon,
                title: L10n.SettingsDetails.Location.title,
                subtitle: L10n.SettingsDetails.Location.body
            )

            Section {
                locationPermissionRow
                locationAccuracyRow
                #if !targetEnvironment(macCatalyst)
                backgroundRefreshRow
                #endif
            }
        }
    }

    // MARK: - Permissions

    private var locationPermissionRow: some View {
        Button {
            viewModel.handleLocationPermissionTap()
        } label: {
            HStack {
                Text(L10n.SettingsDetails.Location.LocationPermission.title)
                    .foregroundStyle(.primary)
                Spacer()
                Text(viewModel.locationPermissionStatus)
                    .foregroundStyle(.secondary)
                Image(systemSymbol: .chevronRight)
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.tertiary)
            }
        }
        .buttonStyle(.plain)
    }

    private var locationAccuracyRow: some View {
        Button {
            URLOpener.shared.openSettings(destination: .location, completionHandler: nil)
        } label: {
            HStack {
                Text(L10n.SettingsDetails.Location.LocationAccuracy.title)
                    .foregroundStyle(.primary)
                Spacer()
                Text(viewModel.locationAccuracyStatus)
                    .foregroundStyle(.secondary)
                Image(systemSymbol: .chevronRight)
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.tertiary)
            }
        }
        .buttonStyle(.plain)
    }

    private var backgroundRefreshRow: some View {
        Button {
            URLOpener.shared.openSettings(destination: .backgroundRefresh, completionHandler: nil)
        } label: {
            HStack {
                Text(L10n.SettingsDetails.Location.BackgroundRefresh.title)
                    .foregroundStyle(.primary)
                Spacer()
                Text(viewModel.backgroundRefreshStatus)
                    .foregroundStyle(.secondary)
                Image(systemSymbol: .chevronRight)
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.tertiary)
            }
        }
        .buttonStyle(.plain)
    }
}
