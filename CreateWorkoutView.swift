import SwiftUI

struct CreateWorkoutView: View {
    @ObservedObject var workoutTemplateViewModel: WorkoutTemplateViewModel
    @ObservedObject var exerciseLibraryViewModel: ExerciseLibraryViewModel
    @Environment(\.presentationMode) var presentationMode

    @State private var workoutName: String = ""
    @State private var selectedExercises: [Exercise] = []
    @State private var newExerciseName: String = ""

    var body: some View {
        Form {
            Section(header: Text("Workout Details")) {
                TextField("Workout Name", text: $workoutName)
            }

            Section(header: Text("Add New Exercise")) {
                TextField("Exercise Name", text: $newExerciseName)
                Button("Add to Library") {
                    if !newExerciseName.isEmpty {
                        exerciseLibraryViewModel.addExercise(name: newExerciseName)
                        newExerciseName = ""
                    }
                }
            }

            Section(header: Text("Select Exercises")) {
                List {
                    ForEach(exerciseLibraryViewModel.exercises) { exercise in
                        Button(action: {
                            toggleExerciseSelection(exercise: exercise)
                        }) {
                            HStack {
                                Text(exercise.name)
                                Spacer()
                                if selectedExercises.contains(where: { $0.id == exercise.id }) {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                    .onDelete(perform: exerciseLibraryViewModel.removeExercise)  // Swipe-to-delete for exercises
                }
            }

            Section(header: Text("Exercises in Workout")) {
                List {
                    ForEach(selectedExercises) { exercise in
                        Text(exercise.name)
                    }
                    .onDelete(perform: removeExercise)
                }
            }

            Button("Save Workout") {
                saveWorkoutTemplate()
            }
            .disabled(workoutName.isEmpty || selectedExercises.isEmpty)
        }
        .navigationTitle("Create Workout")
    }

    func toggleExerciseSelection(exercise: Exercise) {
        if let index = selectedExercises.firstIndex(where: { $0.id == exercise.id }) {
            selectedExercises.remove(at: index)
        } else {
            selectedExercises.append(exercise)
        }
    }

    func removeExercise(at offsets: IndexSet) {
        selectedExercises.remove(atOffsets: offsets)
    }

    func saveWorkoutTemplate() {
        let newTemplate = WorkoutTemplate(
            name: workoutName,
            exercises: selectedExercises
        )
        workoutTemplateViewModel.addWorkoutTemplate(newTemplate)
        presentationMode.wrappedValue.dismiss()
    }
}
