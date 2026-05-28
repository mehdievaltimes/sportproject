import SwiftUI
internal import UniformTypeIdentifiers

struct ContentView: View {
    @State private var selectedAthleteId: UUID?
    
    // Using @State so it can be updated by the parser
    @State private var squad = MockData.shared.squads[0]
    @State private var isImporting = false
    @State private var isAddingAthlete = false
    
    var body: some View {
        NavigationSplitView {
            List(squad.athletes, selection: $selectedAthleteId) { athlete in
                NavigationLink(value: athlete.id) {
                    Text(athlete.name)
                }
            }
            .navigationTitle(squad.name)
            .listStyle(.sidebar)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    HStack {
                        Button(action: {
                            isAddingAthlete = true
                        }) {
                            Label("Add Athlete", systemImage: "person.badge.plus")
                        }
                        
                        Button(action: {
                            isImporting = true
                        }) {
                            Label("Import CSV", systemImage: "square.and.arrow.down")
                        }
                    }
                    .fileImporter(
                        isPresented: $isImporting,
                        allowedContentTypes: [.commaSeparatedText],
                        allowsMultipleSelection: false
                    ) { result in
                        switch result {
                        case .success(let urls):
                            guard let url = urls.first else { return }
                            let gotAccess = url.startAccessingSecurityScopedResource()
                            if let data = try? Data(contentsOf: url),
                               let csvString = String(data: data, encoding: .utf8) {
                                STATSportsParser.shared.parse(csvString: csvString, squad: &squad)
                            }
                            if gotAccess {
                                url.stopAccessingSecurityScopedResource()
                            }
                        case .failure(let error):
                            print("Error importing: \(error)")
                        }
                    }
                }
            }
            .sheet(isPresented: $isAddingAthlete) {
                AddAthleteView(squad: $squad)
            }
        } detail: {
            if let selectedId = selectedAthleteId,
               let index = squad.athletes.firstIndex(where: { $0.id == selectedId }) {
                AthleteDetailView(athlete: $squad.athletes[index])
            } else {
                Text("Select an athlete")
                    .font(.largeTitle)
                    .foregroundColor(.secondary)
            }
        }
        .frame(minWidth: 1000, minHeight: 700)
    }
}

#Preview {
    ContentView()
}
