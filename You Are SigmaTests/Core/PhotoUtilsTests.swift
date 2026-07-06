import XCTest
import UIKit
@testable import You_Are_Sigma

final class PhotoUtilsTests: XCTestCase {
    func testCompressSelfieRedPixel() {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 1, height: 1))
        let image = renderer.image { ctx in UIColor.red.setFill(); ctx.fill(CGRect(x: 0, y: 0, width: 1, height: 1)) }
        let maxBytes = 7 * 1_024 * 1_024
        let result = compressSelfie(image, maxBytes: maxBytes)
        XCTAssertNotNil(result)
        XCTAssertLessThan(result!.data.count, maxBytes)
        XCTAssertEqual(result!.mimeType, "image/jpeg")
    }

    func testPersonalizeWithName() {
        XCTAssertEqual(personalize("{name} is the GOAT", name: "Logan"), "Logan is the GOAT")
    }

    func testPersonalizeWithoutName() {
        XCTAssertEqual(personalize("{name} is the GOAT", name: nil), "boss is the GOAT")
    }

    func testBuildLooksEmptyBio() {
        XCTAssertEqual(buildLooks(bio: "").map(\.label), BASE_LOOKS.map(\.label))
    }

    func testBuildLooksRapperBioAddsStoryLook() {
        let looks = buildLooks(bio: "I am a rapper")
        XCTAssertEqual(looks.count, BASE_LOOKS.count + 1)
        XCTAssertEqual(looks.last?.label, "Your Story")
    }
}
