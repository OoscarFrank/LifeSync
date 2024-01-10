import SwiftUI
import HealthKit

struct HealthView: View {
    @State private var stepCountToday: Int?
    @State private var distanceToday: Double?
    @State private var stepCountThisMonth: Int?
    @State private var distanceThisMonth: Double?
    @State private var stepCountThisYear: Int?
    @State private var distanceThisYear: Double?
    @State private var lastUpdateDate: Date?

    private let healthStore = HKHealthStore()
    private let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
    private let distanceType = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!
    
    let gradient = LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0), Color.blue.opacity(0.6)]), startPoint: .top, endPoint: .bottom)
    let gradientOrange = LinearGradient(gradient: Gradient(colors: [Color.orange.opacity(0), Color.orange.opacity(0.6)]), startPoint: .top, endPoint: .bottom)
    let gradientRed = LinearGradient(gradient: Gradient(colors: [Color.red.opacity(0), Color.red.opacity(0.6)]), startPoint: .top, endPoint: .bottom)

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Today")) {
                    Section {
                        VStack {
                            HStack {
                                Text("\(stepCountToday ?? 0)")
                                    .font(.title)
                                Text("Steps")
                                Spacer()
                                Text("\((Double(stepCountToday ?? 0) / 10000.0) * 100, specifier: "%.1f")%")
                                    .font(.title)
                            }
                            .padding(5)
                        }
                        VStack {
                            HStack {
                                Text("\(String(format: "%.2f", distanceToday ?? 0.0))")
                                    .font(.title)
                                Text("Km")
                            }
                            .padding(5)
                        }
                    }
                }
                Section(header: Text("This month")) {
                    Section {
                        VStack {
                            HStack {
                                Text("\(stepCountThisMonth ?? 0)")
                                    .font(.title)
                                Text("Steps")
                                Spacer()
                                Text("\((Double(stepCountThisMonth ?? 0) / 304000.0) * 100, specifier: "%.1f")%")
                                    .font(.title)
                            }
                            .padding(5)
                        }
                        VStack {
                            HStack {
                                Text("\(String(format: "%.2f", distanceThisMonth ?? 0.0))")
                                    .font(.title)
                                Text("Km")
                            }
                            .padding(5)
                        }
                    }
                }
                Section(header: Text("This year")) {
                    Section {
                        VStack {
                            HStack {
                                Text("\(stepCountThisYear ?? 0)")
                                    .font(.title)
                                Text("Steps")
                                Spacer()
                                Text("\((Double(stepCountThisYear ?? 0) / 3650000.0) * 100, specifier: "%.1f")%")
                                    .font(.title)
                            }
                            .padding(5)
                        }
                        VStack {
                            HStack {
                                Text("\(String(format: "%.2f", distanceThisYear ?? 0.0))")
                                    .font(.title)
                                Text("Km")
                            }
                            .padding(5)
                        }
                    }
                }
            }
            .navigationTitle("Health")
            .toolbar {
                Button(action: { requestHealthData() }) {
                    Label("Update data", systemImage: "arrow.up.heart")
                }
            }
        }
        .onAppear {
            requestHealthData()
        }
    }

    private func requestHealthData() {
        if HKHealthStore.isHealthDataAvailable() {
            healthStore.requestAuthorization(toShare: [], read: [stepType, distanceType]) { success, error in
                if success {
                    queryHealthData()
                } else {
                    print("Access denied or error: \(error?.localizedDescription ?? "")")
                }
            }
        } else {
            print("HealthKit is not available on this device.")
        }
    }

    private func queryHealthData() {
        let calendar = Calendar.current
        let now = Date()
        let startOfDay = calendar.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)
        
        let query = HKStatisticsQuery(quantityType: stepType, quantitySamplePredicate: predicate, options: .cumulativeSum) { query, result, error in
            guard let result = result, let sum = result.sumQuantity() else {
                print("Unable to retrieve step count today: \(error?.localizedDescription ?? "")")
                return
            }
            let stepCount = Int(sum.doubleValue(for: HKUnit.count()))
            self.stepCountToday = stepCount
            self.lastUpdateDate = Date()
        }

        healthStore.execute(query)

        let queryDistance = HKStatisticsQuery(quantityType: distanceType, quantitySamplePredicate: predicate, options: .cumulativeSum) { query, result, error in
            guard let result = result, let sum = result.sumQuantity() else {
                print("Unable to retrieve distance today: \(error?.localizedDescription ?? "")")
                return
            }
            let distance = sum.doubleValue(for: HKUnit.meter()) / 1000.0
            self.distanceToday = distance
        }

        healthStore.execute(queryDistance)

        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: now))!
        let predicateThisMonth = HKQuery.predicateForSamples(withStart: startOfMonth, end: now, options: .strictStartDate)
        let queryThisMonth = HKStatisticsQuery(quantityType: stepType, quantitySamplePredicate: predicateThisMonth, options: .cumulativeSum) { query, result, error in
            guard let result = result, let sum = result.sumQuantity() else {
                print("Unable to retrieve step count this month: \(error?.localizedDescription ?? "")")
                return
            }
            let stepCount = Int(sum.doubleValue(for: HKUnit.count()))
            self.stepCountThisMonth = stepCount
        }

        healthStore.execute(queryThisMonth)

        let queryDistanceThisMonth = HKStatisticsQuery(quantityType: distanceType, quantitySamplePredicate: predicateThisMonth, options: .cumulativeSum) { query, result, error in
            guard let result = result, let sum = result.sumQuantity() else {
                print("Unable to retrieve distance this month: \(error?.localizedDescription ?? "")")
                return
            }
            let distance = sum.doubleValue(for: HKUnit.meter()) / 1000.0
            self.distanceThisMonth = distance
        }

        healthStore.execute(queryDistanceThisMonth)
        
        let startOfYear = calendar.date(from: calendar.dateComponents([.year], from: now))!
        let predicateThisYear = HKQuery.predicateForSamples(withStart: startOfYear, end: now, options: .strictStartDate)
        let queryThisYear = HKStatisticsQuery(quantityType: stepType, quantitySamplePredicate: predicateThisYear, options: .cumulativeSum) { query, result, error in
            guard let result = result, let sum = result.sumQuantity() else {
                print("Unable to retrieve step count this year: \(error?.localizedDescription ?? "")")
                return
            }
            let stepCount = Int(sum.doubleValue(for: HKUnit.count()))
            self.stepCountThisYear = stepCount
        }

        healthStore.execute(queryThisYear)

        let queryDistanceThisYear = HKStatisticsQuery(quantityType: distanceType, quantitySamplePredicate: predicateThisYear, options: .cumulativeSum) { query, result, error in
            guard let result = result, let sum = result.sumQuantity() else {
                print("Unable to retrieve distance this year: \(error?.localizedDescription ?? "")")
                return
            }
            let distance = sum.doubleValue(for: HKUnit.meter()) / 1000.0
            self.distanceThisYear = distance
        }

        healthStore.execute(queryDistanceThisYear)
    }

    private func formattedDate(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .medium
        return dateFormatter.string(from: date)
    }
}

struct HealthView_Previews: PreviewProvider {
    static var previews: some View {
        HealthView()
    }
}
