import XCTest
@testable import You_Are_Sigma

final class ThreadTests: XCTestCase {
    func testResolveThreadElonMusk() { XCTAssertEqual(resolveThread(id: "c1", bio: "")?.name, "Elon Musk") }
    func testResolveThreadNonexistent() { XCTAssertNil(resolveThread(id: "nonexistent", bio: "")) }
    func testPersonalizeNameToken() { XCTAssertEqual(personalize("{name}, please let me use that beat", name: "Logan"), "Logan, please let me use that beat") }
    func testBuildConversationsMusicBio() {
        let top = buildConversations(bio: "I am a rapper").prefix(5).map(\.name)
        let music = ["Drake", "Rihanna", "Taylor Swift", "Beyoncé", "Jay-Z", "Adele", "Kanye West", "Kendrick Lamar"]
        XCTAssertGreaterThanOrEqual(top.filter { music.contains($0) }.count, 2)
    }
}
