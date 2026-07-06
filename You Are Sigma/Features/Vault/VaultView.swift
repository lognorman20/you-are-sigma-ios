import SwiftUI
import Charts

struct VaultView: View {
    @EnvironmentObject private var store: AppStore
    @State private var selectedRange: RangeKey = .oneYear
    private var series: RangeSeries { NET_WORTH_SERIES[selectedRange]! }

    var body: some View {
        NavigationStack {
            ScrollView { VStack(alignment: .leading, spacing: 24) {
                Text(store.profile.name.isEmpty ? "Welcome back" : "Welcome, \(store.profile.name)").foregroundStyle(Color.sigmaGold)
                Text("$42,845,901").font(.system(size: 44, weight: .bold)).foregroundStyle(.white)
                VStack(alignment: .leading, spacing: 12) {
                    Text("Performance").font(.headline).foregroundStyle(.white)
                    Chart(series.points, id: \.t) { p in LineMark(x: .value("T", p.t), y: .value("V", p.value)).foregroundStyle(Color.sigmaGold) }.frame(height: 160)
                    HStack { ForEach(RangeKey.allCases, id: \.self) { r in Button(r.rawValue) { selectedRange = r }.font(.caption.bold()).foregroundStyle(selectedRange == r ? .black : Color.sigmaSecondary).frame(maxWidth: .infinity).padding(6).background(selectedRange == r ? Color.sigmaGold : .clear, in: RoundedRectangle(cornerRadius: 8)) } }
                }.padding().background(Color.sigmaCard, in: RoundedRectangle(cornerRadius: 16))
                Text("Vaults").font(.title2.bold()).foregroundStyle(.white)
                ForEach(ACCOUNTS) { a in HStack { VStack(alignment: .leading) { Text(a.name).foregroundStyle(.white); Text(a.number).font(.caption).foregroundStyle(Color.sigmaSecondary) }; Spacer(); Text(a.balance).foregroundStyle(.white) }.padding().background(Color.sigmaCard, in: RoundedRectangle(cornerRadius: 12)) }
                Chart(CASH_FLOW_CHART, id: \.month) { m in BarMark(x: .value("M", m.month), y: .value("In", m.inflow)).foregroundStyle(.green); BarMark(x: .value("M", m.month), y: .value("Out", m.outflow)).foregroundStyle(.gray) }.frame(height: 140).padding().background(Color.sigmaCard, in: RoundedRectangle(cornerRadius: 16))
                ForEach(SPENDING_DONUT, id: \.name) { s in HStack { Circle().fill(.yellow).frame(width: 6); Text(s.name).foregroundStyle(Color.sigmaSecondary); Spacer(); Text(fmtCompact(s.value)).foregroundStyle(.white) } }
                Text("Recent Ledger").font(.title2.bold()).foregroundStyle(.white)
                ForEach(TRANSACTIONS) { tx in HStack { VStack(alignment: .leading) { Text(tx.title).foregroundStyle(.white); Text(tx.date).font(.caption).foregroundStyle(Color.sigmaSecondary) }; Spacer(); Text(tx.amount).foregroundStyle(tx.type == "in" ? .green : .white) } }
            }.padding() }.background(Color.sigmaBackground).navigationTitle("Vault")
        }
    }
}
