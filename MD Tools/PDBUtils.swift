//
//  PDBUtils.swift
//  MD Tools
//
//  Created by Stephan Ritchie on 27/07/2024.
//

import Foundation
import simd

struct Atom {
    var position: SIMD3<Float>
    var color: SIMD4<Float>
}

struct SecondaryStructureElement {
    enum StructureType {
        case helix
        case sheet
    }
    var type: StructureType
    var atoms: [Atom]
}

func parsePDBFile(filePath: String) -> ([Atom], [SecondaryStructureElement]) {
    var atoms: [Atom] = []
    var secondaryStructures: [SecondaryStructureElement] = []
    
    do {
        let content = try String(contentsOfFile: filePath)
        let lines = content.components(separatedBy: .newlines)
        
        var currentHelix: [Atom] = []
        var currentSheet: [Atom] = []
        
        for line in lines {
            if line.hasPrefix("ATOM") || line.hasPrefix("HETATM") {
                let x = Float(line[rangeFrom(line: line, start: 30, length: 8)].trimmingCharacters(in: .whitespaces))!
                let y = Float(line[rangeFrom(line: line, start: 38, length: 8)].trimmingCharacters(in: .whitespaces))!
                let z = Float(line[rangeFrom(line: line, start: 46, length: 8)].trimmingCharacters(in: .whitespaces))!
                let atom = Atom(position: SIMD3<Float>(x, y, z), color: SIMD4<Float>(1, 0, 0, 1)) // Simplified color
                
                atoms.append(atom)
                
                if !currentHelix.isEmpty {
                    currentHelix.append(atom)
                } else if !currentSheet.isEmpty {
                    currentSheet.append(atom)
                }
            } else if line.hasPrefix("HELIX") {
                if !currentHelix.isEmpty {
                    secondaryStructures.append(SecondaryStructureElement(type: .helix, atoms: currentHelix))
                    currentHelix = []
                }
                // Start new helix
                currentHelix = []
            } else if line.hasPrefix("SHEET") {
                if !currentSheet.isEmpty {
                    secondaryStructures.append(SecondaryStructureElement(type: .sheet, atoms: currentSheet))
                    currentSheet = []
                }
                // Start new sheet
                currentSheet = []
            }
        }
        
        // Add any remaining structures
        if !currentHelix.isEmpty {
            secondaryStructures.append(SecondaryStructureElement(type: .helix, atoms: currentHelix))
        }
        if !currentSheet.isEmpty {
            secondaryStructures.append(SecondaryStructureElement(type: .sheet, atoms: currentSheet))
        }
        
    } catch {
        print("Error reading PDB file: \(error)")
    }
    
    return (atoms, secondaryStructures)
}

func rangeFrom(line: String, start: Int, length: Int) -> Range<String.Index> {
    let startIndex = line.index(line.startIndex, offsetBy: start)
    let endIndex = line.index(startIndex, offsetBy: length)
    return startIndex..<endIndex
}

func combinePDBFiles(proteinFile: String, ligandFile: String, outputFile: String) throws {
    let proteinLines = try String(contentsOfFile: proteinFile).components(separatedBy: .newlines)
    let ligandLines = try String(contentsOfFile: ligandFile).components(separatedBy: .newlines)
    let combinedLines = proteinLines + ligandLines
    try combinedLines.joined(separator: "\n").write(toFile: outputFile, atomically: true, encoding: .utf8)
}

func checkPDBFormatting(pdbFile: String) throws {
    let lines = try String(contentsOfFile: pdbFile).components(separatedBy: .newlines)
    let validStarts = ["ATOM", "HETATM", "TER", "END", "HEADER", "TITLE", "COMPND", "SOURCE",
                       "KEYWDS", "EXPDTA", "AUTHOR", "REVDAT", "JRNL", "REMARK", "SEQRES", "HET",
                       "FORMUL", "HELIX", "SHEET", "TURN", "SITE", "CRYST1", "ORIGX1", "ORIGX2",
                       "ORIGX3", "SCALE1", "SCALE2", "SCALE3", "MTRIX1", "MTRIX2", "MTRIX3",
                       "MODEL", "ENDMDL", "CONECT", "MASTER", "END"]

    var formatErrors: [(Int, String)] = []
    
    for (i, line) in lines.enumerated() {
        if !validStarts.contains(where: { line.hasPrefix($0) }) {
            formatErrors.append((i + 1, line))
        }
    }
    
    if !formatErrors.isEmpty {
        for error in formatErrors {
            print("Formatting error at line \(error.0): \(error.1)")
        }
    } else {
        print("No formatting errors found.")
    }
}
