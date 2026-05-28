import SwiftUI

struct NotesSection: View {
    @Binding var athlete: Athlete
    @State private var newNoteContent: String = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Clinical Notes")
                .font(.title2)
                .fontWeight(.semibold)
            
            // New Note Input
            HStack(alignment: .top) {
                TextField("Add a new note...", text: $newNoteContent, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                    .lineLimit(3...6)
                
                Button(action: addNote) {
                    Text("Post")
                        .fontWeight(.bold)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .buttonStyle(.plain)
                .disabled(newNoteContent.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .padding(.bottom, 8)
            
            // Note Timeline
            if athlete.notes.isEmpty {
                Text("No notes recorded yet.")
                    .foregroundColor(.secondary)
                    .italic()
            } else {
                VStack(alignment: .leading, spacing: 12) {
                    // Sort descending by date
                    ForEach(athlete.notes.sorted(by: { $0.date > $1.date })) { note in
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Text(note.author)
                                    .font(.headline)
                                Spacer()
                                Text(note.date.formatted(date: .abbreviated, time: .shortened))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Text(note.content)
                                .font(.body)
                        }
                        .padding()
                        .background(Color(nsColor: .controlBackgroundColor))
                        .cornerRadius(8)
                    }
                }
            }
        }
    }
    
    private func addNote() {
        let content = newNoteContent.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !content.isEmpty else { return }
        
        let newNote = AthleteNote(
            id: UUID(),
            date: Date(),
            author: "Current User", // In a real app, this comes from Auth
            content: content
        )
        
        // Use animation for better UX
        withAnimation {
            athlete.notes.append(newNote)
            newNoteContent = ""
        }
    }
}
