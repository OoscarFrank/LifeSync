//
//  TodoView.swift
//  LifeSync
//
//  Created by Oscar Frank on 09/12/2023.
//

import SwiftUI

struct TodoItem: Codable, Identifiable {
    var id: UUID
    var name: String
    var icon: String
    var isDone: Bool

    init(id: UUID = UUID(), name: String, icon: String, isDone: Bool) {
        self.id = id
        self.name = name
        self.icon = icon
        self.isDone = isDone
    }
}

class TodoViewModel: ObservableObject {
    @Published var todos: [TodoItem] = [] {
        didSet {
            saveToUserDefaults()
        }
    }
    
    init() {
        loadFromUserDefaults()
    }
    
    func markAsDone(at index: Int) {
        todos[index].isDone.toggle()
    }
    
    func deleteItem(at index: Int) {
        todos.remove(at: index)
    }

    func addItem(name: String, icon: String) {
        let newItem = TodoItem(name: name, icon: icon, isDone: false)
        todos.append(newItem)
    }

    private func saveToUserDefaults() {
        if let encoded = try? JSONEncoder().encode(todos) {
            UserDefaults.standard.set(encoded, forKey: "todos")
        }
    }

    private func loadFromUserDefaults() {
        if let savedItems = UserDefaults.standard.data(forKey: "todos"),
           let decodedItems = try? JSONDecoder().decode([TodoItem].self, from: savedItems) {
            todos = decodedItems
        }
    }
}

struct AddTodoView: View {
    @Binding var isPresented: Bool
    var addTodo: (String, String) -> Void

    @State private var name: String = ""
    @State private var icon: String = "list.bullet"

    let icons = ["list.bullet", "phone", "message", "bell", "star", "calendar"]

    var body: some View {
        NavigationView {
            Form {
                TextField("Todo Name", text: $name)
                Text("Choose an Icon:")
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 40))]) {
                    ForEach(icons, id: \.self) { iconName in
                        Image(systemName: iconName)
                            .onTapGesture {
                                self.icon = iconName
                            }
                            .padding()
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(self.icon == iconName ? Color.blue : Color.clear, lineWidth: 2)
                            )
                    }
                }
                Section {
                    Button("Add Todo") {
                        addTodo(name, icon)
                        isPresented = false
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .navigationTitle("Add Todo")
            .toolbar {
                Button("Cancel") {
                    isPresented = false
                }
            }
        }
    }
}

struct TodoView: View {
    @StateObject private var viewModel = TodoViewModel()
    @State private var showingAddTodo = false

    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.todos) { todo in
                    HStack {
                        Image(systemName: todo.icon)
                            .foregroundColor(todo.isDone ? .blue : .primary)
                        Text(todo.name)
                            .foregroundColor(todo.isDone ? .blue : .primary)
                        Spacer()
                        if todo.isDone {
                            Image(systemName: "checkmark")
                                .foregroundColor(todo.isDone ? .blue : .primary)
                        }
                    }
                    .swipeActions(edge: .trailing) {
                        Button {
                            viewModel.markAsDone(at: viewModel.todos.firstIndex(where: { $0.id == todo.id })!)
                        } label: {
                            Label("Done", systemImage: "checkmark")
                        }
                        .tint(.blue)
                    }
                    .swipeActions(edge: .leading) {
                        Button(role: .destructive) {
                            viewModel.deleteItem(at: viewModel.todos.firstIndex(where: { $0.id == todo.id })!)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
                .onMove(perform: move)
            }
            .padding(.top)
            .navigationTitle("Todos")
            .toolbar {
                Button(action: { showingAddTodo = true }) {
                    Label("Add Todo", systemImage: "plus")
                }
            }
            .sheet(isPresented: $showingAddTodo) {
                AddTodoView(isPresented: $showingAddTodo) { name, icon in
                    viewModel.addItem(name: name, icon: icon)
                }
            }
        }
    }

    func move(from source: IndexSet, to destination: Int) {
        viewModel.todos.move(fromOffsets: source, toOffset: destination)
    }
}

struct TodoView_Previews: PreviewProvider {
    static var previews: some View {
        TodoView()
    }
}
