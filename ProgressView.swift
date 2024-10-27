import SwiftUI

struct ProgressView: View {
    @ObservedObject var workoutSessionViewModel: WorkoutSessionViewModel

    var body: some View {
        NavigationView {
            List {
                ForEach(workoutSessionViewModel.workoutSessions.filter { $0.isCompleted }.reversed()) { session in 
                    Section(header: Text("\(session.name) - \(formattedDate(session.date))")) {
                        VStack(alignment: .leading) {
                            ForEach(session.exerciseEntries) { exerciseEntry in
                                Text(exerciseEntry.exercise.name)
                                    .font(.headline)
                                ForEach(exerciseEntry.sets.indices, id: \.self) { index in
                                    let set = exerciseEntry.sets[index]
                                    Text("Set \(index + 1): \(set.reps) reps at \(set.weight, specifier: "%.2f") lbs")
                                }
                            }
                            Text("Duration: \(Int(session.duration)) seconds")
                                .italic()
                        }
                        .padding()
                    }
                }
                .onDelete(perform: deleteWorkout)
            }
            .navigationTitle("Progress")
            .listStyle(GroupedListStyle())
        }
    }

    func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter.string(from: date)
    }

    func deleteWorkout(at offsets: IndexSet) {
        let reversedOffsets = IndexSet(offsets.map { workoutSessionViewModel.workoutSessions.count - 1 - $0 })
        workoutSessionViewModel.workoutSessions.remove(atOffsets: reversedOffsets)
    }
}
