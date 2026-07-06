import SwiftUI
import Foundation

extension Data {
    var base64EncodedString: String {
        self.base64EncodedString()
    }
}

extension String {
    var isBlank: Bool {
        trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}

extension View {
    func sigmaCard() -> some View {
        self
            .padding()
            .background(Color.sigmaCard)
            .cornerRadius(12)
    }
    
    func sigmaButton() -> some View {
        self
            .font(.system(size: 16, weight: .semibold))
            .foregroundStyle(Color.sigmaBackground)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(Color.sigmaGold)
            .cornerRadius(10)
    }
}

extension Color {
    static func fromHex(_ hex: String) -> Color {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r = Double((int & 0xFF0000) >> 16) / 255
        let g = Double((int & 0x00FF00) >> 8) / 255
        let b = Double(int & 0x0000FF) / 255
        return Color(red: r, green: g, blue: b)
    }
}
