import Foundation
import Testing
@testable import You_Are_Sigma

struct APIModelsTests {

    @Test func healthResponseRoundTrip() throws {
        let original = HealthResponse(status: "ok")
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(HealthResponse.self, from: data)
        #expect(decoded.status == "ok")
    }

    @Test func chatReplyResponseRoundTrip() throws {
        let original = ChatReplyResponse(reply: "yo king")
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(ChatReplyResponse.self, from: data)
        #expect(decoded.reply == "yo king")
    }

    @Test func chatReplyRequestEncodesAllFields() throws {
        let request = ChatReplyRequest(
            persona: "elon",
            handle: "@elonmusk",
            history: [
                ChatHistoryItem(from: "them", text: "sigma king advice?"),
                ChatHistoryItem(from: "you", text: "stay hard")
            ],
            message: "what should I do?",
            userName: "Chad",
            userPersona: "sigma king"
        )

        let data = try JSONEncoder().encode(request)
        let json = try #require(JSONSerialization.jsonObject(with: data) as? [String: Any])

        #expect(json["persona"] as? String == "elon")
        #expect(json["handle"] as? String == "@elonmusk")
        #expect(json["message"] as? String == "what should I do?")
        #expect(json["userName"] as? String == "Chad")
        #expect(json["userPersona"] as? String == "sigma king")

        let history = try #require(json["history"] as? [[String: String]])
        #expect(history.count == 2)
        #expect(history[0]["from"] == "them")
        #expect(history[0]["text"] == "sigma king advice?")
        #expect(history[1]["from"] == "you")
        #expect(history[1]["text"] == "stay hard")
    }

    @Test func errorJSONDoesNotDecodeAsChatReplyResponse() {
        let data = Data("{\"error\": \"Too many requests\"}".utf8)
        #expect(throws: (any Error).self) {
            _ = try JSONDecoder().decode(ChatReplyResponse.self, from: data)
        }
    }
}
