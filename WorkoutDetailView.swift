import SwiftUI

struct WorkoutDetailView: View {
    @ObservedObject var workoutSessionViewModel: WorkoutSessionViewModel
    var template: WorkoutTemplate
    @Environment(\.presentationMode) var presentationMode

    @State private var workoutSession: WorkoutSession
    @State private var timer: Timer?
    @State private var timerRunning = false
    @State private var timeElapsed: TimeInterval = 0

    let integerFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .none
        return formatter
    }()

    let decimalFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter
    }()

    init(workoutSessionViewModel: WorkoutSessionViewModel, template: WorkoutTemplate) {
        self.workoutSessionViewModel = workoutSessionViewModel
        self.template = template
        let exerciseEntries = template.exercises.map { exercise in
            ExerciseEntry(exercise: exercise, sets: [])
        }
        self._workoutSession = State(initialValue: WorkoutSession(
            templateID: template.id,
            name: template.name,
            date: Date(),
            exerciseEntries: exerciseEntries,
            duration: 0
        ))
    }

    var body: some View {
        VStack {
            List {
                ForEach(workoutSession.exerciseEntries.indices, id: \.self) { exerciseIndex in
                    Section(header: Text(workoutSession.exerciseEntries[exerciseIndex].exercise.name)) {
                        ForEach(workoutSession.exerciseEntries[exerciseIndex].sets.indices, id: \.self) { setIndex in
                            VStack(alignment: .leading) {
                                HStack {
                                    Text("Set \(setIndex + 1)")
                                        .font(.headline)
                                    Spacer()
                                    Button(action: {
                                        deleteSet(at: setIndex, from: exerciseIndex)
                                    }) {
                                        Image(systemName: "trash")
                                            .foregroundColor(.red)
                                            .frame(width: 24, height: 24)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                                HStack {
                                    Text("Reps:")
                                    TextField("Enter reps", text: Binding(
                                        get: {
                                            if exerciseIndex < workoutSession.exerciseEntries.count,
                                               setIndex < workoutSession.exerciseEntries[exerciseIndex].sets.count {
                                                return workoutSession.exerciseEntries[exerciseIndex].sets[setIndex].reps == 0 ? "" : String(workoutSession.exerciseEntries[exerciseIndex].sets[setIndex].reps)
                                            } else {
                                                return ""
                                            }
                                        },
                                        set: { newValue in
                                            if exerciseIndex < workoutSession.exerciseEntries.count,
                                               setIndex < workoutSession.exerciseEntries[exerciseIndex].sets.count {
                                                workoutSession.exerciseEntries[exerciseIndex].sets[setIndex].reps = Int(newValue) ?? 0
                                            }
                                        }
                                    ))
                                    .keyboardType(.numberPad)
                                }


                                HStack {
                                    Text("Weight:")
                                    TextField("Enter weight", text: Binding(
                                        get: {
                                            workoutSession.exerciseEntries[exerciseIndex].sets[setIndex].weight == 0.0 ? "" : String(workoutSession.exerciseEntries[exerciseIndex].sets[setIndex].weight)
                                        },
                                        set: { newValue in
                                            workoutSession.exerciseEntries[exerciseIndex].sets[setIndex].weight = Double(newValue) ?? 0.0
                                        }
                                    ))
                                    .keyboardType(.decimalPad)
                                }
                            }
                        }
                        Button(action: {
                            addSet(to: exerciseIndex)
                        }) {
                            Text("Add Set")
                                .foregroundColor(.blue)
                                .padding()
                        }
                        .disabled(!timerRunning)
                    }
                }
            }
            Text("Time Elapsed: \(Int(timeElapsed)) seconds")
                .padding()

            Button(timerRunning ? "Stop Workout" : "Start Workout") {
                toggleTimer()
            }
            .font(.title)
            .padding()
        }
        
        .navigationTitle(workoutSession.name)
        .onDisappear {
            if timerRunning {
                stopTimer()
            }
            saveWorkout()
        }
    }
    
    func bindingForSet(at setIndex: Int, in exerciseIndex: Int) -> Binding<SetEntry> {
        return Binding(
            get: {
                self.workoutSession.exerciseEntries[exerciseIndex].sets[setIndex]
            },
            set: {
                self.workoutSession.exerciseEntries[exerciseIndex].sets[setIndex] = $0
            }
        )
    }
    
    func toggleTimer() {
        timerRunning.toggle()
        if timerRunning {
            startTimer()
        } else {
            stopTimer()
        }
    }

    func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            timeElapsed += 1
        }
    }

    func stopTimer() {
        timer?.invalidate()
        timer = nil
        workoutSession.duration += timeElapsed
        workoutSession.isCompleted = true
        timeElapsed = 0
    }
    
    func saveWorkout() {
        workoutSession.duration += timeElapsed
        workoutSessionViewModel.addWorkoutSession(workoutSession)
        presentationMode.wrappedValue.dismiss()
    }
    
    func addSet(to exerciseIndex: Int) {
        var updatedExerciseEntries = workoutSession.exerciseEntries
        updatedExerciseEntries[exerciseIndex].sets.append(SetEntry(reps: 0, weight: 0.0))
        workoutSession.exerciseEntries = updatedExerciseEntries
    }
    
    func deleteSet(at setIndex: Int, from exerciseIndex: Int) {
        var updatedExerciseEntries = workoutSession.exerciseEntries
        guard setIndex < updatedExerciseEntries[exerciseIndex].sets.count else { return }
        updatedExerciseEntries[exerciseIndex].sets.remove(at: setIndex)
        workoutSession.exerciseEntries = updatedExerciseEntries
    }

    func deleteSets(at offsets: IndexSet, from exerciseIndex: Int) {
        var updatedExerciseEntries = workoutSession.exerciseEntries
        updatedExerciseEntries[exerciseIndex].sets.remove(atOffsets: offsets)
        workoutSession.exerciseEntries = updatedExerciseEntries
    }
}
