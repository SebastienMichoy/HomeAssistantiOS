import CoreLocation
import PromiseKit
import Shared
import UIKit

/// View model for ``LocationSettingsView`` that manages location permission states.
///
/// This view model observes changes to:
/// - Location authorization status via `CLLocationManagerDelegate`
/// - Location accuracy authorization via `CLLocationManagerDelegate`
/// - Background refresh status via `NotificationCenter`
///
/// All status properties are published as localized strings ready for display.
final class LocationSettingsViewModel: NSObject, ObservableObject {

    // MARK: Public Properties

    /// The current location permission status as a localized string.
    @Published private(set) var locationPermissionStatus: String = ""

    /// The current location accuracy status as a localized string.
    @Published private(set) var locationAccuracyStatus: String = ""

    /// The current background refresh status as a localized string.
    @Published private(set) var backgroundRefreshStatus: String = ""

    /// Whether a location update is currently in progress.
    @Published private(set) var isUpdatingLocation: Bool = false

    /// Whether to show the error alert.
    @Published var showErrorAlert: Bool = false

    /// The error message to display in the alert.
    @Published private(set) var errorMessage: String?

    // MARK: - Private Properties

    private let locationManager = CLLocationManager()

    // MARK: - Initialization

    override init() {
        super.init()

        locationManager.delegate = self

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateBackgroundRefreshStatus),
            name: UIApplication.backgroundRefreshStatusDidChangeNotification,
            object: nil
        )

        updateLocationPermissionStatus()
        updateLocationAccuracyStatus()
        updateBackgroundRefreshStatus()
    }

    // MARK: - Update Permissions

    private func updateLocationPermissionStatus() {
        let status = locationManager.authorizationStatus

        locationPermissionStatus = switch status {
        case .authorizedAlways:
            L10n.SettingsDetails.Location.LocationPermission.always
        case .authorizedWhenInUse:
            L10n.SettingsDetails.Location.LocationPermission.whileInUse
        case .denied, .restricted:
            L10n.SettingsDetails.Location.LocationPermission.never
        case .notDetermined:
            L10n.SettingsDetails.Location.LocationPermission.needsRequest
        @unknown default:
            L10n.SettingsDetails.Location.LocationPermission.never
        }
    }

    private func updateLocationAccuracyStatus() {
        let accuracy = locationManager.accuracyAuthorization

        locationAccuracyStatus = switch accuracy {
        case .fullAccuracy:
            L10n.SettingsDetails.Location.LocationAccuracy.full
        case .reducedAccuracy:
            L10n.SettingsDetails.Location.LocationAccuracy.reduced
        @unknown default:
            L10n.SettingsDetails.Location.LocationAccuracy.reduced
        }
    }

    @objc private func updateBackgroundRefreshStatus() {
        let status = UIApplication.shared.backgroundRefreshStatus

        backgroundRefreshStatus = switch status {
        case .available:
            L10n.SettingsDetails.Location.BackgroundRefresh.enabled
        case .restricted, .denied:
            L10n.SettingsDetails.Location.BackgroundRefresh.disabled
        @unknown default:
            L10n.SettingsDetails.Location.BackgroundRefresh.disabled
        }
    }

    // MARK: - Handle Taps

    /// Handles the user tapping on the location permission row.
    ///
    /// If location permission has not been determined yet, this requests "Always" authorization.
    /// Otherwise, it opens the system Settings app to the location settings page.
    func handleLocationPermissionTap() {
        if locationManager.authorizationStatus == .notDetermined {
            locationManager.requestAlwaysAuthorization()
        } else {
            URLOpener.shared.openSettings(destination: .location, completionHandler: nil)
        }
    }

    /// Triggers a manual location update.
    func updateLocation() {
        isUpdatingLocation = true

        HomeAssistantAPI.manuallyUpdate(
            applicationState: UIApplication.shared.applicationState,
            type: .userRequested
        ).ensure {
            self.isUpdatingLocation = false
        }.catch { error in
            self.errorMessage = error.localizedDescription
            self.showErrorAlert = true
        }
    }
}

// MARK: - CLLocationManagerDelegate

extension LocationSettingsViewModel: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        updateLocationPermissionStatus()
        updateLocationAccuracyStatus()
    }
}
