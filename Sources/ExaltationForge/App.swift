import TokamakDOM
import JavaScriptKit
import Foundation

@main
struct TokamakApp: App {
    var body: some Scene {
        WindowGroup("Exaltation Forge") {
            ContentView()
        }
    }
}

struct Result {
    var minCost: UInt64
    var expectedCost: Double
}

struct ContentView: View {

    @State private var avgPrice = ""
    @State private var selectedClass = 1
    @State private var selectedTier = 1
    @State private var errorMsg = ""
    @State private var isUsingCores = false
    @State private var corePrice = ""

    var body: some View {
        
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Text("average price:")
                    TextField(
                        "",
                        text: $avgPrice
                    )
            }

            HStack {
                Text("Use Cores:")
                Toggle("", isOn: self.$isUsingCores)
                Text("core price:")
                TextField(
                    "",
                    text: $corePrice
                )
            }

            HStack {
                Picker("Classification", selection: $selectedClass) {
                    ForEach(1..<5) { v in 
                        Text(String(v)).tag(v)
                    }
                }.padding([.trailing], 10)
                Picker("Desired Tier:", selection: $selectedTier) {
                    ForEach(1..<11) { v in 
                        Text(String(v)).tag(v)
                    }
                }
            }

            let result = self.calculateCost()

            HStack {
                Text("Expected Cost:")
                Spacer()
                Text(String(format: "%.0f", result.expectedCost))
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .font(.system(.body, design: .monospaced))
            }.frame(maxWidth: 400)
            HStack {
                Text("Minimum Cost:")
                Spacer()
                Text(String(result.minCost))
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .font(.system(.body, design: .monospaced))
            }.frame(maxWidth: 400)
            Text(self.errorMsg).foregroundColor(.red)
        }.padding()
    }

    private func calculateCost() -> Result {

        //reset errorMsg
        self.errorMsg = ""

        guard avgPrice != "" else {
            return Result(minCost: 0, expectedCost: 0)
        }

        guard UInt64(self.avgPrice) != nil else {
            self.errorMsg = "invalid price"
            return Result(minCost: 0, expectedCost: 0)
        }

        if self.isUsingCores && UInt64(self.corePrice) == nil {
            self.errorMsg = "invalid core price"
            return Result(minCost: 0, expectedCost: 0)
        }

        guard (selectedTier <= selectedClass) || selectedClass == 4 else {
            self.errorMsg = "invalid tier"
            return Result(minCost: 0, expectedCost: 0)
        }


        return self.costOfWeapon(self.selectedClass, self.selectedTier)

        // let formatter = NumberFormatter()
        // formatter.numberStyle = .decimal
        // let a = formatter.string(from: NSNumber(value: result)) ?? "error"
    }

    private func costOfWeapon(_ classification: Int, _ tier: Int) -> Result {
        let avgPrice = UInt64(self.avgPrice)!

        if tier == 0 {
            return Result(minCost: avgPrice, expectedCost: Double(avgPrice))
        }

        let numberItems =  1 << tier
        var numberOfFusions = numberItems / 2

        var expectedLoss: Double = 0
        var minCost: UInt64 = 0

        minCost += UInt64(numberItems) * avgPrice

        // 0 0 0 0 0 0 0 0 
        //  1   1   1   1
        //    2       2
        //        3

        for currentTier in 1...tier {

            var fusionCost = costForTier(
                classification: classification,
                tier: currentTier
            )

            fusionCost += self.isUsingCores ? UInt64(self.corePrice)! : 0

            minCost +=  fusionCost * UInt64(numberOfFusions)

            expectedLoss += Double(fusionCost)  + costOfWeapon(classification, currentTier - 1).expectedCost


            numberOfFusions = numberOfFusions / 2
        }

        let inverseProbability: Double = self.isUsingCores ? 5/2 : 2/1 

        // expected cost for each fusion:
        // lim x->infinity [ integral 0->x [ (1/2)^x * v ] ] = v/log(2)
        let expectedCost = expectedLoss / log(inverseProbability)

        return Result(minCost: minCost, expectedCost: expectedCost)
    }

    private func costForTier(classification: Int, tier: Int) -> UInt64 {
        switch(classification, tier){
            case(1, 1):
                return 25_000
            case(2, 1):
                return 750_000
            case(2, 2):
                return 5_000_000
            case(3, 1):
                return 4_000_000
            case(3, 2):
                return 10_000_000
            case(3, 3):
                return 20_000_000
            case(4, 1):
                return 8_000_000
            case(4, 2):
                return 20_000_000
            case(4, 3):
                return 40_000_000
            case(4, 4):
                return 65_000_000
            case(4, 5):
                return 100_000_000
            case(4, 6):
                return 250_000_000
            case(4, 7):
                return 750_000_000
            case(4, 8):
                return 2_500_000_000
            case(4, 9):
                return 8_000_000_000
            case(4, 10):
                return 15_000_000_000
            default:
                return 0
        }
    }
}