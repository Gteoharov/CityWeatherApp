import SwiftUI
import CityWeatherCore

struct ErrorAlertModifier: ViewModifier {
    @Binding var error: Error?
    
    func body(content: Content) -> some View {
        content
            .alert(isPresented: Binding(
                get: { error != nil },
                set: { _ in error = nil }
            )) {
                if let networkError = error as? RemoteCityDetailLoader.Error, networkError == .noConnection {
                    return Alert(
                        title: Text("Internet connection"),
                        message: Text("Please check your internet connection and try again")
                    )
                } else {
                    return Alert(title: Text("Error"), message: nil)
                }
            }
    }
}

extension View {
    func errorAlert(for error: Binding<Error?>) -> some View {
        self.modifier(ErrorAlertModifier(error: error))
    }
}
