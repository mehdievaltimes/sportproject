import SwiftUI
internal import UniformTypeIdentifiers

struct StaffDashboardView: View {
    // Using @State so it can be updated by the parser
    @State private var squad = MockData.shared.squads[0]
    @State private var isImporting = false
    
    @AppStorage("loggedInTeamDomain") private var loggedInTeamDomain = ""
    
    var teamDisplayName: String {
        let parts = loggedInTeamDomain.components(separatedBy: ".")
        return parts.first?.capitalized ?? squad.name
    }
    
    // Group athletes by their primary position category
    var groupedAthletes: [(String, [Athlete])] {
        let grouped = Dictionary(grouping: squad.athletes) { athlete in
            let primary = athlete.positions.first ?? "Unspecified"
            return category(for: primary)
        }
        
        let order = ["Goalkeepers", "Defenders", "Midfielders", "Attackers", "Unspecified"]
        return grouped.map { ($0.key, $0.value) }.sorted { 
            let index1 = order.firstIndex(of: $0.0) ?? 99
            let index2 = order.firstIndex(of: $1.0) ?? 99
            return index1 < index2
        }
    }
    
    func category(for position: String) -> String {
        let pos = position.lowercased()
        if pos.contains("goalkeeper") || pos == "gk" {
            return "Goalkeepers"
        } else if pos.contains("back") || pos.contains("defender") || pos == "cb" || pos == "rb" || pos == "lb" {
            return "Defenders"
        } else if pos.contains("mid") || pos == "cm" || pos == "cdm" || pos == "cam" {
            return "Midfielders"
        } else if pos.contains("forward") || pos.contains("striker") || pos.contains("winger") {
            return "Attackers"
        }
        return "Unspecified"
    }
    
    let columns = [
        GridItem(.adaptive(minimum: 250, maximum: 300), spacing: 20)
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 30) {
                    ForEach(groupedAthletes, id: \.0) { position, athletes in
                        VStack(alignment: .leading, spacing: 15) {
                            Text(position)
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            LazyVGrid(columns: columns, spacing: 20) {
                                ForEach(athletes) { athlete in
                                    if let index = squad.athletes.firstIndex(where: { $0.id == athlete.id }) {
                                        NavigationLink(destination: AthleteDetailView(athlete: $squad.athletes[index])) {
                                            AthleteSummaryCard(athlete: athlete)
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                            }
                        }
                    }
                }
                .padding(30)
            }
            .navigationTitle(teamDisplayName)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: {
                        isImporting = true
                    }) {
                        Label("Import CSV", systemImage: "square.and.arrow.down")
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
        }
        .frame(minWidth: 1000, minHeight: 700)
    }
}

struct AthleteSummaryCard: View {
    var athlete: Athlete
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(athlete.name)
                    .font(.headline)
                Spacer()
                if athlete.status != .available {
                    Circle()
                        .fill(athlete.status == .injured ? Color.red : Color.orange)
                        .frame(width: 10, height: 10)
                }
            }
            
            Text(athlete.positions.joined(separator: ", "))
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(1)
            
            Divider()
            
            HStack {
                VStack(alignment: .leading) {
                    Text("Acute Load")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text(String(format: "%.0f", athlete.acuteLoad))
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }
                Spacer()
                if athlete.isTrackingCycle, let log = athlete.cycleLogs.last {
                    VStack(alignment: .trailing) {
                        Text("Readiness")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        Text("\(log.readinessScore)/10")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(log.readinessScore >= 7 ? .green : (log.readinessScore >= 4 ? .orange : .red))
                    }
                }
            }
        }
        .padding()
        .background(Color(nsColor: .controlBackgroundColor))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
        )
    }
}

#Preview {
    StaffDashboardView()
}
