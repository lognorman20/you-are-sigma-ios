import XCTest
@testable import You_Are_Sigma

final class FakeDataTests: XCTestCase {
    func testConversationsCount() { XCTAssertGreaterThanOrEqual(CONVERSATIONS.count, 15) }
    func testContactsCount() { XCTAssertGreaterThanOrEqual(CONTACTS.count, 30) }
    func testTransactionsNonEmptyWithSignedAmounts() {
        XCTAssertFalse(TRANSACTIONS.isEmpty)
        for txn in TRANSACTIONS { XCTAssertTrue(txn.amount.hasPrefix("+") || txn.amount.hasPrefix("-")) }
    }
    func testNetWorthSeriesHasAllRanges() {
        for key in RangeKey.allCases {
            XCTAssertNotNil(NET_WORTH_SERIES[key])
            XCTAssertFalse(NET_WORTH_SERIES[key]!.points.isEmpty)
        }
    }
}
