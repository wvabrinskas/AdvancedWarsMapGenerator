//
//  Tile.swift
//  AdvanceWarsMapGenerator
//
//  Created by William Vabrinskas on 6/18/22.
//

import Foundation
import SwiftUI

public struct Tile: CustomDebugStringConvertible {
  public var debugDescription: String {
    return "Tile -> type: \(type.rawValue)"
  }
  
  public struct AdjacencyMatrix {
    var east: Set<Tile.LandType>?
    var west: Set<Tile.LandType>?
    var north: Set<Tile.LandType>?
    var south: Set<Tile.LandType>?
    var reversible: Bool = false
    var backup: Tile.LandType
  }
  
  public struct Size {
    var width: Int
    var height: Int
  }
  
  public enum LandType: String, CaseIterable {
    case none,
         sea,
         reef,
         shoal,
         plain,
         building,
         hq,
         base,
         airport,
         port,
         river,
         woods,
         //road, // need to figure out turns
         bridge,
         mountain
    
    var heightRange: Range<Double> {
      switch self {
      case .none:
        return -1..<0
      case .sea:
        return 0..<0.3
      case .reef:
        return 0.3..<0.31
      case .shoal:
        return 0.31..<0.37
      case .plain:
        return 0.37..<0.4
      case .building, .hq, .port, .base, .airport:
        return 0.4..<0.43
      case .river:
        return 0.43..<0.50
      case .bridge:
        return 0.50..<0.58
      case .woods:
        return 0.58..<0.68
      case .mountain:
        return 0.68..<1.5
      }
    }
    
    static func getBuilding() -> LandType {
      let distribution: [Int: LandType] = [8 : .building,
                                           4 : .airport,
                                           6 : .base,
                                           3 : .port,
                                           0 : .hq]
      
      var distributionArray: [LandType] = []
       distribution.forEach { (key: Int, value: LandType) in
           let new = Array(repeating: value, count: key)
           distributionArray.append(contentsOf: new)
       }
      
       let r = Int.random(in: 0..<distributionArray.count)
       return distributionArray[r]
    }
    
    static func type(for number: Double) -> Self {
      let rawType = Tile.LandType.allCases.first(where: { $0.heightRange.contains(number) }) ?? .plain
      
      switch rawType {
        case .building, .hq, .port, .base, .airport:
        return getBuilding()
      default:
        return rawType
      }
    }
    
    var adjencencyRequirement: AdjacencyMatrix? {
      switch self {
      case .port:
        return AdjacencyMatrix(east: [.sea, .shoal, .plain],
                               west: [.shoal, .plain],
                               north: [.sea, .shoal, .plain],
                               south: [.shoal, .plain],
                               reversible: true,
                               backup: .building)
      case .river:
        return AdjacencyMatrix(east: [.plain, .river, .woods, .mountain, .building, .hq, .base, .port, .airport ],
                               west: [.plain, .river, .woods, .mountain, .building, .hq, .base, .port, .airport,],
                               north: [.woods, .building, .hq, .base, .port, .airport, .mountain, .plain],
                               south: [.woods, .building, .hq, .base, .port, .airport, .mountain, .plain],
                               reversible: true,
                               backup: .plain)
      case .bridge:
        return AdjacencyMatrix(east: [.plain, .woods, .building, .hq, .base, .port, .airport, .mountain],
                               west: [.plain, .woods, .building, .hq, .base, .port, .airport,.mountain],
                               north: [.river],
                               south: [.river],
                               reversible: true,
                               backup: .plain)
      case .shoal:
        return AdjacencyMatrix(east: [.sea, .shoal, .plain],
                               west: [.shoal, .plain],
                               north: [.sea, .shoal, .plain],
                               south: [.shoal, .plain],
                               reversible: true,
                               backup: .sea)
      case .building:
        return AdjacencyMatrix(east: [.plain, .woods, .building, .hq, .base, .port, .airport, .mountain, .bridge, .shoal],
                               west: [.plain, .woods, .building,.hq, .base, .port, .airport, .mountain, .bridge, .shoal],
                               north: [.plain, .woods, .building, .hq, .base, .port, .airport, .mountain, .bridge, .shoal],
                               south: [.plain, .woods, .building, .hq, .base, .port, .airport, .mountain, .bridge, .shoal],
                               reversible: true,
                               backup: .plain)
      default:
        return nil
      }
    }
  }

  public enum Orientation {
    case north, south, east, west
  }
  
  var orientation: Orientation = .west
  var type: LandType
  var size: Size = .init(width: 10, height: 10)
}
