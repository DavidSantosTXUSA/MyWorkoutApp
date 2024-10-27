import SwiftUI

struct WorkoutListView: View {
    @ObservedObject var workoutTemplateViewModel: WorkoutTemplateViewModel
    @ObservedObject var exerciseLibraryViewModel: ExerciseLibraryViewModel
    @ObservedObject var workoutSessionViewModel: WorkoutSessionViewModel

    var body: some View {
        NavigationView {
            List {
                ForEach(workoutTemplateViewModel.workoutTemplates) { template in
                    NavigationLink(destination: WorkoutDetailView(
                        workoutSessionViewModel: workoutSessionViewModel,
                        template: template)
                    ) {
                        Text(template.name)
                    }
                }
                .onDelete(perform: deleteWorkoutTemplate)
            }
            .navigationTitle("Workouts")
            .navigationBarItems(
                leading: EditButton(),
                trailing: NavigationLink(destination: CreateWorkoutView(
                    workoutTemplateViewModel: workoutTemplateViewModel,
                    exerciseLibraryViewModel: exerciseLibraryViewModel)
                ) {
                    Image(systemName: "plus")
                }
            )
        }
    }

    func deleteWorkoutTemplate(at offsets: IndexSet) {
        workoutTemplateViewModel.workoutTemplates.remove(atOffsets: offsets)
        workoutTemplateViewModel.saveWorkoutTemplates()
    }
}
