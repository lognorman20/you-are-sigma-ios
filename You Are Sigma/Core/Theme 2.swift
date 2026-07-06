import SwiftUI

extension Color {
    static let sigmaGold = Color(red: 212/255, green: 175/255, blue: 55/255)
    static let sigmaBlack = Color.black
    static let sigmaBackground = Color(red: 10/255, green: 10/255, blue: 10/255)
    static let sigmaCard = Color(red: 25/255, green: 25/255, blue: 25/255)
    static let sigmaText = Color.white
    static let sigmaSecondary = Color(white: 0.6)
}

extension Font {
    static let sigmaTitle: Font = .system(size: 28, weight: .bold)
    static let sigmaHeadline: Font = .system(size: 18, weight: .semibold)
    static let sigmaBody: Font = .system(size: 15, weight: .regular)
    static let sigmaCaption: Font = .system(size: 12, weight: .regular)
}
