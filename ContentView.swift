import SwiftUI
internal import UniformTypeIdentifiers

struct StaffDashboardView: View {
    @State private var athleteManager = AthleteManager.shared
    @State private var isImporting = false
    
    @AppStorage("loggedInTeamDomain") private var loggedInTeamDomain = ""
    
    var teamDisplayName: String {
        guard !loggedInTeamDomain.isEmpty else { return "Unknown Team" }
        let parts = loggedInTeamDomain.components(separatedBy: ".")
        let name = parts.first?.capitalized ?? "Unknown Team"
        return name.isEmpty ? "Unknown Team" : name
    }
    
    // Group athletes by their primary position category
    var groupedAthletes: [(String, [Athlete])] {
        // Filter out athletes in the Medical Bay so they don't appear in the main roster grid
        let activeRoster = athleteManager.roster.filter { $0.status != .injured && $0.status != .rehab }
        let grouped = Dictionary(grouping: activeRoster) { athlete in
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
    
    var medicalBayAthletes: [Athlete] {
        athleteManager.roster.filter { $0.status == .injured || $0.status == .rehab }
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
        @Bindable var am = athleteManager
        
        NavigationStack {
            ScrollView {
                if !am.lastErrorMessage.isEmpty {
                    Text(am.lastErrorMessage)
                        .padding()
                        .background(Color.red.opacity(0.1))
                        .foregroundColor(.red)
                        .cornerRadius(8)
                        .padding(.horizontal, 30)
                        .padding(.top, 20)
                }
                
                VStack(alignment: .leading, spacing: 30) {
                    // Main Header since the window title bar is hidden
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(teamDisplayName)
                                .font(.system(size: 42, weight: .black, design: .rounded))
                            Text("Staff Dashboard")
                                .font(.title3)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                    }
                    .padding(.bottom, 10)
                    
                    if !medicalBayAthletes.isEmpty {
                        VStack(alignment: .leading, spacing: 15) {
                            HStack {
                                Image(systemName: "cross.case.fill")
                                    .foregroundColor(.red)
                                Text("Medical Ward")
                            }
                            .font(.title2)
                            .fontWeight(.bold)
                            
                            LazyVGrid(columns: columns, spacing: 20) {
                                ForEach(medicalBayAthletes) { athlete in
                                    if let index = athleteManager.roster.firstIndex(where: { $0.id == athlete.id }) {
                                        MedicalAthleteCard(athlete: $am.roster[index])
                                    }
                                }
                            }
                        }
                        .padding(20)
                        .background(Color.red.opacity(0.05))
                        .cornerRadius(16)
                        .padding(.bottom, 10)
                    }
                    
                    ForEach(groupedAthletes, id: \.0) { position, athletes in
                        VStack(alignment: .leading, spacing: 15) {
                            Text(position)
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            LazyVGrid(columns: columns, spacing: 20) {
                                ForEach(athletes) { athlete in
                                    if let index = athleteManager.roster.firstIndex(where: { $0.id == athlete.id }) {
                                        NavigationLink(destination: AthleteDetailView(athlete: $am.roster[index])) {
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
                    HStack {
                        Button(action: {
                            Task {
                                for athlete in MockData.shared.squads[0].athletes {
                                    var seededAthlete = athlete
                                    seededAthlete.teamDomain = loggedInTeamDomain
                                    athleteManager.saveAthlete(seededAthlete)
                                }
                            }
                        }) {
                            Label("Seed Data", systemImage: "sparkles")
                        }
                        
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
                                    // STATSportsParser.shared.parse(csvString: csvString, squad: &squad)
                                    print("CSV Import not yet configured for Firestore roster")
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
            .onAppear {
                NotificationManager.shared.requestPermission()
                if !loggedInTeamDomain.isEmpty {
                    athleteManager.fetchTeamRoster(teamDomain: loggedInTeamDomain)
                }
            }
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
    
    struct MedicalAthleteCard: View {
        @Binding var athlete: Athlete
        @State private var isUpdatingStatus = false
        
        var body: some View {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text(athlete.name)
                        .font(.headline)
                    Spacer()
                    Text(athlete.status.rawValue.uppercased())
                        .font(.caption2)
                        .fontWeight(.bold)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(athlete.status == .injured ? Color.red.opacity(0.2) : Color.orange.opacity(0.2))
                        .foregroundColor(athlete.status == .injured ? .red : .orange)
                        .cornerRadius(4)
                }
                
                if let injury = athlete.injuries.first {
                    Text(injury.bodyPart)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                    
                    Divider()
                    
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Expected Return")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                            if let expectedDate = injury.expectedReturnDate {
                                Text(expectedDate, style: .date)
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.primary)
                            } else {
                                Text("TBD")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.secondary)
                            }
                        }
                        Spacer()
                    }
                }
                
                Button(action: {
                    isUpdatingStatus = true
                }) {
                    Text("Update Status")
                        .font(.caption)
                        .fontWeight(.medium)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 6)
                }
                .buttonStyle(.plain)
                .background(Color.red.opacity(0.1))
                .foregroundColor(.red)
                .cornerRadius(6)
                .padding(.top, 4)
            }
            .padding()
            .background(Color(nsColor: .controlBackgroundColor))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.red.opacity(0.3), lineWidth: 1)
            )
            .sheet(isPresented: $isUpdatingStatus) {
                UpdateStatusView(athlete: $athlete)
            }
        }
    }
}
