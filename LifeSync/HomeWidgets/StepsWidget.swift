import SwiftUI
import HealthKit

struct StepsWidget: View {
    @State private var stepCountToday: Int?
    @State private var distanceToday: Double?

    private let healthStore = HKHealthStore()
    private let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
    private let distanceType = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!
    
    let gradient = LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.6), Color.blue.opacity(0.2)]), startPoint: .top, endPoint: .bottom)

    var body: some View {
        HStack {
            VStack {
                Text("\(stepCountToday ?? 0)")
                    .font(.title)
                Text("Steps Today")
            }
            .frame(width: 150, height: 100)
            .background(gradient)
            .cornerRadius(20)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .padding()

            VStack {
                Text(String(format: "%.2f", distanceToday ?? 0.0))
                    .font(.title)
                Text("Distance (Km)")
            }
            .frame(width: 150, height: 100)
            .background(gradient)
            .cornerRadius(20)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .padding()
        }
        .onAppear {
            requestHealthData()
        }
    }

    private func requestHealthData() {
        if HKHealthStore.isHealthDataAvailable() {
            healthStore.requestAuthorization(toShare: [], read: [stepType, distanceType]) { success, _ in
                if success {
                    queryHealthData()
                }
            }
        }
    }

    private func queryHealthData() {
        let calendar = Calendar.current
        let now = Date()
        let startOfDay = calendar.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)

        let stepQuery = HKStatisticsQuery(quantityType: stepType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, _ in
            if let sum = result?.sumQuantity() {
                let stepCount = Int(sum.doubleValue(for: HKUnit.count()))
                DispatchQueue.main.async {
                    self.stepCountToday = stepCount
                }
            }
        }

        let distanceQuery = HKStatisticsQuery(quantityType: distanceType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, _ in
            if let sum = result?.sumQuantity() {
                let distance = sum.doubleValue(for: HKUnit.meter()) / 1000.0
                DispatchQueue.main.async {
                    self.distanceToday = distance
                }
            }
        }

        healthStore.execute(stepQuery)
        healthStore.execute(distanceQuery)
    }
}

struct StepsWidget_Previews: PreviewProvider {
    static var previews: some View {
        StepsWidget()
    }
}
