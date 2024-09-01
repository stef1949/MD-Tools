//
//  ContentView.swift
//  MD Tools
//
//  Created by Stephan Ritchie on 27/07/2024.
//

import SwiftUI
import UniformTypeIdentifiers
import MetalKit

struct ContentView: View {
    @StateObject private var viewModel = PDBViewModel()
   // @State private var mdtoolViewId: mdtoolView.ID? // Single selection.
    
    var body: some View {
        NavigationSplitView {
            // Sidebar with Navigation Links
            List {
                NavigationLink(destination: ProteinLigandMergeView(viewModel: viewModel)) {
                    Text("Protein-ligand Merge")
                }
                NavigationLink(destination: Text("Destination 2")) {
                    Text("Item 2")
                }
            }
            .navigationTitle("Sidebar")
            .background(.ultraThinMaterial)
            .listStyle(.automatic)
            .accentColor(.purple)
            
        } detail: {
            // Default detail view when the app launches
            ProteinLigandMergeView(viewModel: viewModel)
        }
    }
}

// The view used for Protein-Ligand Merge functionality
struct ProteinLigandMergeView: View {
    @ObservedObject var viewModel: PDBViewModel
    
    var body: some View {
        
        VStack {
            VStack {
                ZStack (alignment: Alignment( horizontal: .center, vertical: .bottom), content: {
                    
                    if let renderer = viewModel.renderer {
                        MetalKitViewRepresentable(renderer: renderer)
                            .frame(minWidth: 300, idealWidth: 400, minHeight: 300, idealHeight: 400)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .padding(.top)
                        
                    } else {
                        
                        Text("Renderer failed to initialize")
                            .frame(minWidth: 400, minHeight: 400)
                            .background(Color.red)
                            .padding()
                        
                    }
                    
                    // Output logs
                    
                    VStack {
                        HStack {
                            Text("Logs")
                                .foregroundStyle(.gray)
                            Spacer()
                        }
                        Text(viewModel.outputMessage)
                            .frame(maxWidth: .infinity, idealHeight: 20, alignment: .bottom)
                            .padding()
                            .background(.ultraThinMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: 5))
                    }
                    .offset(CGSize(width: 0.0, height: -5.0))
                    .padding()
                })
            }
            
            HStack {
                
                //Protein Selector
                VStack {
                    TextField("Protein PDB Path", text: $viewModel.proteinFilePath)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                    Button(action: {
                        viewModel.selectPDBFile { path in
                            viewModel.proteinFilePath = path
                        }
                    }) {
                        Text("Select Protein File")
                            .padding()
                            .frame(maxWidth: .infinity)
                            .cornerRadius(5)
                    }
                    .padding(.top)
                    .buttonStyle(.bordered)
                }
                
                //Ligand selector
                VStack {
                    TextField("Ligand PDB Path", text: $viewModel.ligandFilePath)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                    Button(action: {
                        viewModel.selectPDBFile { path in
                            viewModel.ligandFilePath = path
                        }
                    }) {
                        Text("Select Ligand File")
                            .padding()
                            .frame(maxWidth: .infinity)
                            .cornerRadius(5)
                    }
                    .padding(.top)
                    .buttonStyle(.bordered)
                }
            }
             
            //Combine file button
            Button(action: {
                viewModel.combineAndCheckFiles()
            }) {
                Text("Combine and Check Files")
                    .foregroundStyle(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .padding(.vertical)
        }
        .padding()

    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
