//
//  ContentView.swift
//  AdvanceWarsMapGenerator
//
//  Created by William Vabrinskas on 6/18/22.
//

import SwiftUI

struct ContentView: View {
  private let mapProvider = MapProvider(mapSize: Map.Size(width: 15, height: 15),
                                       tileSize: Tile.Size(width: 30, height: 30))
  
  @State var map: Map = Map(size: Map.Size(width: 10, height: 10))
  @State var amplitude: Double = 0
  @State var octaves: Double = 0
  @State var zHeight: Double = 0
  @State var size: Double = 0

  var body: some View {
    VStack(spacing: 0) {
      if !map.tiles.isEmpty {
        ForEach(0..<map.size.height) { y in
          HStack(spacing: 0) {
            ForEach(0..<map.size.width) { x in
              getImage(x: x, y: y)
            }
          }
        }
        .background(Color.white)
      }
      VStack {
        Spacer()
        Button("Generate") {
          generate()
        }
        .padding()
        Text("Amplitude")
        Slider(value: $amplitude, in: 0.001...1, step: 0.01) { _ in
          self.mapProvider.amplitude = amplitude
          self.generate(static: false)
        }
        .frame(width: 400)
        .padding()
        Text("Octaves")
        Slider(value: $octaves, in: 0...10, step: 1) { _ in
          self.mapProvider.octaves = Int(octaves)
          self.generate(static: false)
        }
        .frame(width: 400)
        .padding()
//
        Text("Z Height")
        Slider(value: $zHeight, in: 0...100, step: 0.01) { _ in
          self.mapProvider.zHeight = zHeight
          self.generate(static: true)
        }
        .frame(width: 400)
        .padding()
        Spacer()
      }
      .frame(maxHeight: 500)
    }
    .onAppear {
      self.amplitude = mapProvider.amplitude
      self.octaves = Double(mapProvider.octaves)
      self.zHeight = mapProvider.zHeight
      self.size = Double(mapProvider.size)
    }
    .onReceive(mapProvider.$map) { newMap in
      self.map = newMap
    }
  }
  
  func generate(static: Bool = false) {
    mapProvider.generate(static: `static`)
  }
  
  func getImage(x: Int, y: Int) -> some View {
    let tile = map.tiles[y][x]
    
    return Image(tile.type.rawValue)
      .resizable()
      .frame(width: Double(map.tileSize.width),
             height: Double(map.tileSize.height))
      .rotationEffect(Angle(degrees: tile.orientation.rotation))
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
