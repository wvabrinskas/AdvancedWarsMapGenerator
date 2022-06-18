//
//  Map.swift
//  AdvanceWarsMapGenerator
//
//  Created by William Vabrinskas on 6/18/22.
//

import Foundation

public struct Map {
  public struct Size {
    var width: Int
    var height: Int
  }
  
  var tileSize: Tile.Size = Tile.Size(width: 10, height: 10)
  var size: Size
  var tiles: [[Tile]] = []
}
