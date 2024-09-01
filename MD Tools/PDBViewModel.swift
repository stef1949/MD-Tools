//
//  PDBViewModel.swift
//  MD Tools
//
//  Created by Stephan Ritchie on 27/07/2024.
//

import SwiftUI
import Combine
import MetalKit
import UniformTypeIdentifiers

class PDBViewModel: ObservableObject {
    @Published var proteinFilePath: String = ""
    @Published var ligandFilePath: String = ""
    @Published var outputMessage: String = ""
    @Published var renderer: Renderer?

    init() {
        let mtkView = MTKView()
        if let renderer = Renderer(metalKitView: mtkView) {
            self.renderer = renderer
        } else {
            outputMessage = "Metal is not supported on this device"
        }
        
        cleanUpSavedState()
    }

    func selectPDBFile(completion: @escaping (String) -> Void) {
        let dialog = NSOpenPanel()
        dialog.title = "Choose a .pdb file"
        dialog.allowedContentTypes = [UTType(filenameExtension: "pdb")!]
        dialog.allowsMultipleSelection = false

        if dialog.runModal() == .OK, let path = dialog.url?.path {
            completion(path)
        } else {
            completion("")
        }
    }

    func combineAndCheckFiles() {
        guard !proteinFilePath.isEmpty && !ligandFilePath.isEmpty else {
            outputMessage = "Please select both protein and ligand PDB files."
            return
        }

        let outputPath = FileManager.default.temporaryDirectory.appendingPathComponent("combined.pdb").path

        do {
            try combinePDBFiles(proteinFile: proteinFilePath, ligandFile: ligandFilePath, outputFile: outputPath)
            try checkPDBFormatting(pdbFile: outputPath)
            outputMessage = "Combined PDB file saved to \(outputPath)"
            
            let (atoms, _) = parsePDBFile(filePath: outputPath)
            renderer?.loadPDBData(atoms: atoms)
        } catch {
            outputMessage = "An error occurred: \(error.localizedDescription)"
        }
    }
    
    private func cleanUpSavedState() {
        let savedStateURL = URL(fileURLWithPath: NSHomeDirectory()).appendingPathComponent("Library/Containers/com.richies3d.MD-Tools/Data/Library/Saved Application State/com.richies3d.MD-Tools.savedState")
        let restoreCountFileURL = savedStateURL.appendingPathComponent("restorecount.plist")
        
        do {
            try FileHelper.deleteFile(at: restoreCountFileURL)
        } catch {
            print("Failed to delete file at \(restoreCountFileURL): \(error)")
        }
    }
}
