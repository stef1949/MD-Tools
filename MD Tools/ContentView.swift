//
//  ContentView.swift
//  MD Tools
//
//  Created by Stephan Ritchie on 27/07/2024.
//

import SwiftUI
import UniformTypeIdentifiers
import MetalKit
import WebKit // For WKWebView



struct ContentView: View {
    @StateObject private var viewModel = PDBViewModel()
    
    var body: some View {
        NavigationSplitView {
            // Sidebar with Navigation Links
            List {
                NavigationLink(destination: ProteinLigandMergeView(viewModel: viewModel)) {
                    Text("Protein-ligand Merge")
                }
                NavigationLink(destination: PDBViewerView()) {
                    Text("PDB Viewer")
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
                ZStack (alignment: Alignment(horizontal: .center, vertical: .bottom)) {
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
                }
            }
            
            HStack {
                // Protein Selector
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
                
                // Ligand Selector
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
             
            // Combine file button
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

struct PDBViewerView: View {
    @State private var pdbContent: String = ""
    @State private var isLoading: Bool = false
    @State private var errorMessage: String?
    
    var body: some View {
        VStack {
            ZStack {
                PDBViewer(pdbContent: pdbContent)
                    .frame(maxWidth: CGFloat.infinity, maxHeight: CGFloat.infinity)
                
                if isLoading {
                    ProgressView()
                        .scaleEffect(1.5)
                        .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                }
            }
            
            if let error = errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .padding()
            }
            
            HStack {
                Button("Load Sample PDB") {
                    loadSamplePDB()
                }
                .padding()
                
                Button("Load PDB File") {
                    loadPDBFile()
                }
                .padding()
            }
        }
        .navigationTitle("PDB Viewer")
    }
    
    func loadSamplePDB() {
        isLoading = true
        errorMessage = nil
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            // This is a small part of a PDB file for demonstration
            pdbContent = """
            ATOM      1  N   MET A   1      27.340  24.430   2.614  1.00  9.67      A    N
            ATOM      2  CA  MET A   1      26.266  25.413   2.842  1.00 10.38      A    C
            ATOM      3  C   MET A   1      26.913  26.679   3.371  1.00  9.62      A    C
            ATOM      4  O   MET A   1      27.886  26.633   4.126  1.00  9.62      A    O
            ATOM      5  CB  MET A   1      25.112  24.880   3.649  1.00 13.77      A    C
            ATOM      6  CG  MET A   1      25.353  24.860   5.134  1.00 16.29      A    C
            ATOM      7  SD  MET A   1      23.930  23.959   5.904  1.00 17.17      A    S
            ATOM      8  CE  MET A   1      24.447  23.984   7.620  1.00 16.11      A    C
            """
            isLoading = false
        }
    }
    
    func loadPDBFile() {
        let openPanel = NSOpenPanel()
        openPanel.allowedContentTypes = [UTType.text]
        openPanel.allowsMultipleSelection = false
        openPanel.canChooseDirectories = false
        openPanel.canChooseFiles = true
        
        openPanel.begin { response in
            if response == .OK, let url = openPanel.url {
                isLoading = true
                errorMessage = nil
                
                DispatchQueue.global(qos: .userInitiated).async {
                    do {
                        let content = try String(contentsOf: url)
                        DispatchQueue.main.async {
                            pdbContent = content
                            isLoading = false
                        }
                    } catch {
                        DispatchQueue.main.async {
                            errorMessage = "Error loading file: \(error.localizedDescription)"
                            isLoading = false
                        }
                    }
                }
            }
        }
    }
}

// Ensure that you are on macOS or a platform that supports AppKit
#if canImport(AppKit)
struct PDBViewer: NSViewRepresentable {
    // Specify the type of NSView to represent
    typealias NSViewType = WKWebView
    
    let pdbContent: String

    func makeNSView(context: Context) -> WKWebView {
        let webView = WKWebView(frame: .zero)
        webView.navigationDelegate = context.coordinator
        return webView
    }

    func updateNSView(_ nsView: WKWebView, context: Context) {
        let htmlString = """
        <html>
        <head>
            <script type="text/javascript" src="https://chemapps.stolaf.edu/jmol/jsmol/JSmol.min.js"></script>
            <script type="text/javascript">
                var Info = {
                    width: "100%",
                    height: "100%",
                    color: "0xFFFFFF",
                    j2sPath: "https://chemapps.stolaf.edu/jmol/jsmol/j2s",
                    serverURL: "https://chemapps.stolaf.edu/jmol/jsmol/php/jsmol.php",
                    use: "HTML5",
                    readyFunction: null
                };
                
                var jsmolApplet;
                
                function initJmol() {
                    Jmol.getApplet("jsmolApplet", Info);
                    Jmol.script(jsmolApplet, `load data "${pdbContent}";`);
                }
            </script>
        </head>
        <body onload="initJmol();">
            <div id="jsmolApplet" style="width:100%; height:100%;"></div>
        </body>
        </html>
        """
        
        nsView.loadHTMLString(htmlString, baseURL: nil)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: PDBViewer

        init(_ parent: PDBViewer) {
            self.parent = parent
        }
    }
}
#endif

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
