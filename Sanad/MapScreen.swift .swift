import SwiftUI
import MapKit

struct MapScreen: View {

    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 21.4858, longitude: 39.1925), // جدة
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )

    var body: some View {
        Map(position: .constant(.region(region)))
            .ignoresSafeArea()
    }
}
