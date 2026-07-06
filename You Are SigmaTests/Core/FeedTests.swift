import XCTest
@testable import You_Are_Sigma

final class FeedTests: XCTestCase {
    func testDefaultBioReturnsScriptedConversations() {
        let result = buildConversations(bio: "")
        XCTAssertEqual(result.count, CONVERSATIONS.count)
        XCTAssertEqual(result.map(\.id), CONVERSATIONS.map(\.id))
    }

    func testBasketballBioFloatsPlayersToTop() {
        let result = buildConversations(bio: "I love NBA basketball and hoops")
        let names = result.prefix(5).map(\.name)
        XCTAssertTrue(names.contains("LeBron James") || names.contains("Stephen Curry"))
    }

    func testBuildContactsFeaturedList() {
        let feed = buildContacts(bio: "rapper and music producer")
        XCTAssertFalse(feed.featured.isEmpty)
        XCTAssertGreaterThanOrEqual(feed.all.count, CONTACTS.count)
    }
}
