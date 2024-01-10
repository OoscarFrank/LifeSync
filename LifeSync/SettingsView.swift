//
//  SettingsView.swift
//  LifeSync
//
//  Created by Oscar Frank on 09/12/2023.
//

import SwiftUI

struct SettingsView: View {
    @Binding var isPresented: Bool
    @State private var localNom: String = UserDefaults.standard.string(forKey: "nom") ?? ""
    @State private var localPrenom: String = UserDefaults.standard.string(forKey: "prenom") ?? ""
    @State private var localEmail: String = UserDefaults.standard.string(forKey: "email") ?? ""
    @State private var localAdresseDomicile: String = UserDefaults.standard.string(forKey: "adresseDomicile") ?? ""
    @State private var localAdresseTravail: String = UserDefaults.standard.string(forKey: "adresseTravail") ?? ""

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("General")) {
                    HStack {
                        Image(systemName: "person.fill")
                        TextField("Name", text: $localNom)
                    }

                    HStack {
                        Image(systemName: "person.fill")
                        TextField("Firstname", text: $localPrenom)
                    }

                    HStack {
                        Image(systemName: "envelope.fill")
                        TextField("Email", text: $localEmail)
                            .keyboardType(.emailAddress)
                    }

                    HStack {
                        Image(systemName: "house.fill")
                        TextField("Home Address", text: $localAdresseDomicile)
                    }

                    HStack {
                        Image(systemName: "briefcase.fill")
                        TextField("Work Address", text: $localAdresseTravail)
                    }
                }
                Button("Save") {
                    UserDefaults.standard.set(localNom, forKey: "nom")
                    UserDefaults.standard.set(localPrenom, forKey: "prenom")
                    UserDefaults.standard.set(localEmail, forKey: "email")
                    UserDefaults.standard.set(localAdresseDomicile, forKey: "adresseDomicile")
                    UserDefaults.standard.set(localAdresseTravail, forKey: "adresseTravail")
                    isPresented = false
                }
                .frame(maxWidth: .infinity)
            }
            .navigationTitle("Settings")
            .toolbar {
                Button("Cancel") {
                    isPresented = false
                }
            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(isPresented: .constant(true))
    }
}
