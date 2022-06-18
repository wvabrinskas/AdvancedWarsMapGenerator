//
//  MapProvider.swift
//  AdvanceWarsMapGenerator
//
//  Created by William Vabrinskas on 6/18/22.
//

import Foundation
import NumSwift
import NumSwiftC

public extension Double {
  func scale(from: ClosedRange<Double>, to: ClosedRange<Double>) -> Self {
    let fromMax = from.upperBound
    let fromMin = from.lowerBound
    
    let toMax = to.upperBound
    let toMin = to.lowerBound
    
    let r = ((self - fromMin) / (fromMax - fromMin)) * (toMax - toMin) + toMin
    return r
  }
}

public class MapProvider {
  @Published var map: Map = Map(size: Map.Size(width: 10, height: 10))
  
  private let mapSize: Map.Size
  private let tileSize: Tile.Size
  private lazy var staticNoise = NoiseC(size: size, amplitude: amplitude)
  public var size: Int = 4095
  public var amplitude: Double = 0.5
  public var octaves = 6
  public var zHeight: Double = 0
  
  public init(mapSize: Map.Size, tileSize: Tile.Size) {
    self.mapSize = mapSize
    self.tileSize = tileSize
  }

  public func generate(static: Bool = false) {
    //new noise each time
    var noise = `static` ? staticNoise : NoiseC(size: size, octaves: octaves, amplitude: amplitude)
    
    var tiles: [[Tile]] = []
    for y in 0..<mapSize.height {
      var tileRows: [Tile] = []
      for x in 0..<mapSize.width {
        let noise = noise.nextPerlin(x: Double(x), y: Double(y), z: zHeight)
        let type = mapNoiseToType(noise, x: x, y: y, tiles: tiles, row: tileRows)
        let tile = Tile(orientation: .east,
                        type: type,
                        size: tileSize)
        
        tileRows.append(tile)
      }
      tiles.append(tileRows)
    }
    
    let newMap = Map(tileSize: tileSize,
                     size: mapSize,
                     tiles: tiles)
    self.map = newMap
    self.staticNoise = noise
  }
  
  private func mapNoiseToType(_ noise: Double, x: Int, y: Int, tiles: [[Tile]], row: [Tile]) -> Tile.LandType {
    let type = Tile.LandType.type(for: noise)
    
    let up = tiles[safe: y - 1, [Tile(type: .none)]][safe: x, Tile(type: .none)]
    let left = row[safe: x - 1, Tile(type: .none)]

    if let upAdjacencyMatrix = up.type.adjencencyRequirement {
      if upAdjacencyMatrix.south?.contains(type) == false {
        return upAdjacencyMatrix.backup
      }
    }
    
    if let leftAdjacencyMatrix = left.type.adjencencyRequirement {
      if leftAdjacencyMatrix.west?.contains(type) == false {
        return leftAdjacencyMatrix.backup
      }
    }

    if let currentAdjencyMatrix = type.adjencencyRequirement {
  
      if left.type != .none, let east = currentAdjencyMatrix.east, east.contains(left.type) == false {
        return currentAdjencyMatrix.backup
      }
      
      if up.type != .none, let north = currentAdjencyMatrix.north, north.contains(up.type) == false {
        return currentAdjencyMatrix.backup
      }
      
      if currentAdjencyMatrix.reversible {
        if left.type != .none, let west = currentAdjencyMatrix.west, west.contains(left.type) == false {
          return currentAdjencyMatrix.backup
        }
        
        if up.type != .none, let south = currentAdjencyMatrix.south, south.contains(up.type) == false {
          return currentAdjencyMatrix.backup
        }
      }
    }
    
    return type
  }
}
