import Foundation

struct FakeMessage: Identifiable { let id: String; let sender: String; let text: String; let time: String }
struct FakeConversation: Identifiable { let id: String; let name: String; let avatar: String; let verified: Bool; let time: String; var unread: Int; let messages: [FakeMessage] }
struct NotificationPing: Identifiable { let id: String; let name: String; let avatar: String; let verified: Bool; let text: String }
struct Transaction: Identifiable { let id: String; let title: String; let type: String; let amount: String; let date: String; let time: String; let category: String }
struct Account: Identifiable { let id: String; let name: String; let number: String; let balance: String }
struct FakeContact: Identifiable { let id: String; let name: String; let avatar: String; let verified: Bool; let handle: String }
struct SeriesPoint { let t: String; let value: Double }
struct RangeSeries { let points: [SeriesPoint]; let changeAbs: Double; let changePct: Double }
enum RangeKey: String, CaseIterable { case oneDay = "1D"; case oneWeek = "1W"; case oneMonth = "1M"; case oneYear = "1Y"; case all = "ALL" }
struct SpendingSlice { let name: String; let value: Double; let colorHex: String }
struct CashFlowMonth { let month: String; let inflow: Double; let outflow: Double }

func fmtCompact(_ num: Double) -> String {
    if num >= 1_000_000 { return String(format: "$%.1fM", num / 1_000_000) }
    if num >= 1_000 { return String(format: "$%.1fK", num / 1_000) }
    return String(format: "$%.0f", num)
}

let CURRENT_NET_WORTH: Double = 42_845_901

let NOTIFICATION_POOL: [NotificationPing] = [
    NotificationPing(id: "n1", name: "Elon Musk", avatar: "EM", verified: true, text: "Just wired you the $500M. Let me know when you land."),
    NotificationPing(id: "n3", name: "Drake", avatar: "DR", verified: true, text: "{name}, please let me use that beat. I'll pay whatever."),
    NotificationPing(id: "n4", name: "Zendaya", avatar: "ZN", verified: true, text: "Are we still on for dinner in Paris tonight?"),
]

let CONVERSATIONS: [FakeConversation] = [
    FakeConversation(id: "c1", name: "Elon Musk", avatar: "EM", verified: true, time: "2m", unread: 3, messages: [
        FakeMessage(id: "m1", sender: "them", text: "{name}, you free?", time: "10:00 AM"),
        FakeMessage(id: "m4", sender: "them", text: "Just wired you the $500M. Let me know when you land.", time: "10:06 AM"),
    ]),
    FakeConversation(id: "c2", name: "Zendaya", avatar: "ZN", verified: true, time: "15m", unread: 1, messages: [
        FakeMessage(id: "m1", sender: "them", text: "Are we still on for dinner in Paris tonight?", time: "9:30 AM"),
    ]),
    FakeConversation(id: "c4", name: "Drake", avatar: "DR", verified: true, time: "2h", unread: 2, messages: [
        FakeMessage(id: "m1", sender: "them", text: "{name}, please let me use that beat. I'll pay whatever.", time: "7:00 AM"),
    ]),
    FakeConversation(id: "c7", name: "Jeff Bezos", avatar: "JB", verified: true, time: "1d", unread: 4, messages: [
        FakeMessage(id: "m1", sender: "them", text: "Can you review my new rocket design? Need your eye.", time: "Yesterday"),
    ]),
    FakeConversation(id: "c8", name: "Rihanna", avatar: "RH", verified: true, time: "1d", unread: 1, messages: [
        FakeMessage(id: "m1", sender: "them", text: "Miss you, {name}. Come to the studio.", time: "Yesterday"),
    ]),
    FakeConversation(id: "c11", name: "Taylor Swift", avatar: "TS", verified: true, time: "3d", unread: 5, messages: [
        FakeMessage(id: "m1", sender: "them", text: "Front row tickets are reserved for you every night.", time: "3 days ago"),
    ]),
]

let CONTACTS: [FakeContact] = [
    FakeContact(id: "k1", name: "Adele", avatar: "AD", verified: true, handle: "Singer / Songwriter"),
    FakeContact(id: "k8", name: "Drake", avatar: "DR", verified: true, handle: "OVO Sound"),
    FakeContact(id: "k10", name: "Elon Musk", avatar: "EM", verified: true, handle: "Tesla / SpaceX"),
    FakeContact(id: "k25", name: "Rihanna", avatar: "RH", verified: true, handle: "Fenty / Savage"),
    FakeContact(id: "k29", name: "Taylor Swift", avatar: "TS", verified: true, handle: "Recording Artist"),
    FakeContact(id: "k36", name: "Zendaya", avatar: "ZN", verified: true, handle: "Actor"),
]

let ACCOUNTS: [Account] = [
    Account(id: "a1", name: "Private Wealth (JP Morgan)", number: "•••• 7701", balance: "$24,900,000"),
    Account(id: "a2", name: "Offshore Holdings (Geneva)", number: "•••• 8829", balance: "$28,450,000"),
    Account(id: "a3", name: "Crypto Vault (Cold Storage)", number: "•••• 1xF9", balance: "$2,275,451"),
    Account(id: "a4", name: "Discretionary Trust (Cayman)", number: "•••• 4410", balance: "$12,120,450"),
]

let CASH_FLOW_CHART: [CashFlowMonth] = [
    CashFlowMonth(month: "May", inflow: 4.2, outflow: 2.1),
    CashFlowMonth(month: "Jun", inflow: 6.8, outflow: 1.5),
    CashFlowMonth(month: "Jul", inflow: 8.5, outflow: 3.2),
    CashFlowMonth(month: "Aug", inflow: 7.1, outflow: 4.0),
    CashFlowMonth(month: "Sep", inflow: 11.2, outflow: 2.8),
    CashFlowMonth(month: "Oct", inflow: 14.5, outflow: 5.6),
]

let SPENDING_DONUT: [SpendingSlice] = [
    SpendingSlice(name: "Luxury Goods", value: 8_500_000, colorHex: "D4AF37"),
    SpendingSlice(name: "Real Estate", value: 4_200_000, colorHex: "8B7355"),
    SpendingSlice(name: "Private Travel", value: 2_800_000, colorHex: "C0A060"),
    SpendingSlice(name: "Investments", value: 12_400_000, colorHex: "E8D48B"),
    SpendingSlice(name: "Charity", value: 1_500_000, colorHex: "6B5B3E"),
]

let TRANSACTIONS: [Transaction] = [
    Transaction(id: "t1", title: "Anonymous Wire (Zurich)", type: "in", amount: "+$4,200,000.00", date: "Today", time: "9:15 AM", category: "Income"),
    Transaction(id: "t2", title: "Cartier (Fifth Avenue)", type: "out", amount: "-$280,000.00", date: "Today", time: "11:42 AM", category: "Luxury"),
    Transaction(id: "t3", title: "Hedge Fund Distribution", type: "in", amount: "+$8,500,000.00", date: "Yesterday", time: "3:00 PM", category: "Income"),
]

private func buildSeries(labels: [String], endValue: Double, startValue: Double, vol: Double, seed: UInt32) -> RangeSeries {
    var s = seed
    var rndSeed = s
    let rnd: () -> Double = {
        rndSeed &+= 0x6D2B79F5
        var t = rndSeed ^ (rndSeed >> 15)
        t &*= 1 | rndSeed
        t ^= t &* ((t &* 61) | 1)
        t ^= t >> 14
        return Double(t) / 4_294_967_296.0
    }
    let n = labels.count
    let drift = log(endValue / startValue) / Double(n - 1)
    var steps = [0.0]
    for i in 1..<n { steps.append(steps[i-1] + drift + (rnd() - 0.5) * 2 * vol) }
    var values = steps.map { startValue * exp($0) }
    let scale = endValue / values[n-1]
    values = values.map { round($0 * scale) }
    let points = zip(labels, values).map { SeriesPoint(t: $0.0, value: $0.1) }
    return RangeSeries(points: points, changeAbs: points[n-1].value - points[0].value, changePct: (points[n-1].value - points[0].value) / points[0].value * 100)
}

let NET_WORTH_SERIES: [RangeKey: RangeSeries] = [
    .oneDay: buildSeries(labels: ["8AM","12PM","4PM","8PM"], endValue: CURRENT_NET_WORTH, startValue: CURRENT_NET_WORTH - 1_240_000, vol: 0.0045, seed: 101),
    .oneWeek: buildSeries(labels: ["Mon","Tue","Wed","Thu","Fri","Sat","Sun"], endValue: CURRENT_NET_WORTH, startValue: CURRENT_NET_WORTH / 1.046, vol: 0.014, seed: 202),
    .oneMonth: buildSeries(labels: (1...30).map(String.init), endValue: CURRENT_NET_WORTH, startValue: CURRENT_NET_WORTH / 1.142, vol: 0.02, seed: 303),
    .oneYear: buildSeries(labels: ["Jul","Aug","Sep","Oct","Nov","Dec","Jan","Feb","Mar","Apr","May","Jun"], endValue: CURRENT_NET_WORTH, startValue: CURRENT_NET_WORTH / 2.35, vol: 0.04, seed: 404),
    .all: buildSeries(labels: (0..<24).map { String(2020 + $0 / 4) }, endValue: CURRENT_NET_WORTH, startValue: CURRENT_NET_WORTH / 11.5, vol: 0.06, seed: 505),
]
