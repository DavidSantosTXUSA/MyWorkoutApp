import SwiftUI

@main
struct WorkoutApp: App {
    @StateObject var workoutTemplateViewModel = WorkoutTemplateViewModel()
    @StateObject var exerciseLibraryViewModel = ExerciseLibraryViewModel()
    @StateObject var workoutSessionViewModel = WorkoutSessionViewModel()

    var body: some Scene {
        WindowGroup {
            TabView {
                WorkoutListView(
                    workoutTemplateViewModel: workoutTemplateViewModel,
                    exerciseLibraryViewModel: exerciseLibraryViewModel,
                    workoutSessionViewModel: workoutSessionViewModel
                )
                .tabItem {
                    Image(systemName: "list.bullet")
                    Text("Workouts")
                }
                ProgressView(workoutSessionViewModel: workoutSessionViewModel)
                    .tabItem {
                        Image(systemName: "chart.bar")
                        Text("Progress")
                    }
            }
        }
    }
}
