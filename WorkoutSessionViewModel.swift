import Foundation

class WorkoutSessionViewModel: ObservableObject {
    @Published var workoutSessions: [WorkoutSession] = []

    init() {
        loadWorkoutSessions()
    }

    func saveWorkoutSessions() {
        if let encoded = try? JSONEncoder().encode(workoutSessions) {
            UserDefaults.standard.set(encoded, forKey: "workoutSessions")
        }
    }

    func loadWorkoutSessions() {
        if let data = UserDefaults.standard.data(forKey: "workoutSessions"),
           let decoded = try? JSONDecoder().decode([WorkoutSession].self, from: data) {
            workoutSessions = decoded
        }
    }

    func addWorkoutSession(_ session: WorkoutSession) {
        workoutSessions.append(session)
        saveWorkoutSessions()
    }
}
