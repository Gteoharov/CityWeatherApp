import Foundation

public extension String {
    var flagEmoji: String {
        let base: UInt32 = 127397
        var scalarView = String.UnicodeScalarView()
        for i in self.utf16 {
            if let scalar = UnicodeScalar(base + UInt32(i)) {
                scalarView.append(scalar)
            }
        }
        return String(scalarView)
    }
}
