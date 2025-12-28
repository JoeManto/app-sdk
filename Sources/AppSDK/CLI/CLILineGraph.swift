//
//  CLILineGraph.swift
//  AppSDK
//
//  Created by Joe Manto on 12/23/25.
//

import Foundation

public struct CLILineGraph {
    public private(set) var content: String

    public let title: String?
    public let xAxisTitle: String?
    public let yAxisTitle: String?
    let showsXAxisValues = true
    let showsYAxisValues = true
    let showsAxisLines = true

    private var _maxXAxisWidth: Double
    private var _maxYAxisHeight: Double
    private var _minXWidth: Double
    private var _minYHeight: Double

    /// Filters entries by removing a percentage of "middle" entries while preserving peaks and valleys.
    ///
    /// - Parameters:
    ///   - entries: The original data points sorted by x value.
    ///   - resolution: A value from 0.0 to 1.0 where 1.0 keeps all entries and 0.0 keeps only peaks/valleys.
    /// - Returns: Filtered entries with peaks and valleys preserved.
    private static func filterByResolution(entries: [(x: Double, y: Double)], resolution: Double) -> [(x: Double, y: Double)] {
        guard entries.count > 2, resolution < 1.0 else {
            return entries
        }

        let resolution = max(0, min(1, resolution))

        // Identify peaks and valleys (local maxima and minima)
        var isPeakOrValley = [Bool](repeating: false, count: entries.count)

        // First and last are always kept
        isPeakOrValley[0] = true
        isPeakOrValley[entries.count - 1] = true

        for i in 1..<(entries.count - 1) {
            let prev = entries[i - 1].y
            let curr = entries[i].y
            let next = entries[i + 1].y

            // Local maximum (peak)
            if curr >= prev && curr >= next && (curr > prev || curr > next) {
                isPeakOrValley[i] = true
            }
            // Local minimum (valley)
            else if curr <= prev && curr <= next && (curr < prev || curr < next) {
                isPeakOrValley[i] = true
            }
        }

        // Collect middle entries (non-peak, non-valley)
        var middleIndices: [Int] = []
        for i in 0..<entries.count {
            if !isPeakOrValley[i] {
                middleIndices.append(i)
            }
        }

        // Calculate how many middle entries to keep
        let middleToKeep = Int(Double(middleIndices.count) * resolution)

        // Select evenly distributed middle entries to keep
        var middleToKeepSet = Set<Int>()
        if middleToKeep > 0 && !middleIndices.isEmpty {
            let step = Double(middleIndices.count) / Double(middleToKeep)
            for i in 0..<middleToKeep {
                let index = Int(Double(i) * step)
                if index < middleIndices.count {
                    middleToKeepSet.insert(middleIndices[index])
                }
            }
        }

        // Build the final filtered array
        var result: [(x: Double, y: Double)] = []
        for i in 0..<entries.count {
            if isPeakOrValley[i] || middleToKeepSet.contains(i) {
                result.append(entries[i])
            }
        }

        return result
    }

    public init(entries: [(x: Double, y: Double)], title: String? = nil, xAxisTitle: String? = nil, yAxisTitle: String? = nil, width: Int = 50, height: Int = 10, resolution: Double = 1.0) {
        self.content = ""
        self.title = title
        self.xAxisTitle = xAxisTitle
        self.yAxisTitle = yAxisTitle
        self._maxXAxisWidth = Double(width)
        self._maxYAxisHeight = Double(height)
        self._minXWidth = Double(width)
        self._minYHeight = Double(height)

        // Apply resolution filtering to reduce middle entries
        var entries = Self.filterByResolution(entries: entries, resolution: resolution)

        // Find min max x and y.
        var maxY = entries.first?.y ?? 0
        var maxX = entries.first?.x ?? 0
        var minY = entries.first?.y ?? 0
        var minX = entries.first?.x ?? 0

        for entry in entries {
            if entry.y > maxY {
                maxY = entry.y
            }
            if entry.y < minY {
                minY = entry.y
            }
            if entry.x > maxX {
                maxX = entry.x
            }
            if entry.x < minX {
                minX = entry.x
            }
        }

        // Determine how many data points are captured in each row.
        var scaleY: Double = 1
        if maxY - minY > _maxYAxisHeight {
            scaleY = (maxY - minY) / Double(_maxYAxisHeight)
        } else {
            if maxY - minY < _minYHeight {
                scaleY = (maxY - minY) / Double(_minYHeight)
            } else {
                _maxYAxisHeight = maxY - minY
            }
        }

        // Determine how many data points are captured in each column.
        var scaleX: Double = 1
        if maxX - minX > _maxXAxisWidth {
            scaleX =  (maxX - minX) / Double(_maxXAxisWidth)
        } else {
            if maxX - minX < _minXWidth {
                scaleX = (maxX - minX) / Double(_minXWidth)
            } else {
                _maxXAxisWidth = maxX - minX
            }
        }

        // Calculate extra height width of the graph, all context excluding the graph data points.
        let largestYAxisValueLength = entries.reduce(0) { max($0, String(format: "%0.f", $1.y).count) }

        let extraHeight = (title != nil ? 1 : 0) + (showsAxisLines ? 1 : 0) + (showsXAxisValues ? 1 : 0) + (xAxisTitle != nil ? 1 : 0) + 1

        let extraWidth = (yAxisTitle != nil ? 1 : 0) + (showsYAxisValues ? largestYAxisValueLength : 0) + (showsAxisLines ? 1 : 0)

        var content: [[Character]] = .init(repeating: .init(repeating: " ", count: Int(_maxXAxisWidth + Double(extraWidth))), count: Int(_maxYAxisHeight + Double(extraHeight)))

        // Where the graph data points start in the 2d array.
        let xAxisStartIndex = Int(extraWidth)
        let yAxisStartIndex = content.count - Int(extraHeight) + 1

        // The x and y data point entry values.
        let initialPositionX = minX
        var entryPositionX = initialPositionX - scaleX
        var entryPositionY = minY

        // The y index where we draw '_'
        let xBoundaryLineYIndex = yAxisStartIndex + 1
        // The y index where we draw the x value numbers. Just under the boundary.
        let xValueLabelYIndex = xBoundaryLineYIndex + 1
        // The y index where we draw the description of the axis. Just under the data point value labels.
        let xAxisLabelYIndex = xValueLabelYIndex + 1

        // The x index where we draw '|'
        let yBoundaryLineXIndex = xAxisStartIndex - 1

        // The x index where we start to draw the y value members. Just before the boundary.
        let yValueLabelXIndex = yBoundaryLineXIndex - largestYAxisValueLength

        // Pre-compute screen positions for all entries to enable line drawing
        var screenPositions: [(screenX: Int, screenY: Int, entry: (x: Double, y: Double))] = []
        for entry in entries {
            // Convert data coordinates to screen coordinates
            let screenX = xAxisStartIndex + Int((entry.x - minX) / scaleX)
            // Y is inverted: higher values = lower row index (closer to top)
            let screenY = yAxisStartIndex - Int((entry.y - minY) / scaleY)
            screenPositions.append((screenX: screenX, screenY: screenY, entry: entry))
        }

        // Sort by x position to ensure we connect points left to right
        screenPositions.sort { $0.screenX < $1.screenX }

        // Draw connecting lines between consecutive points
        for i in 0..<(screenPositions.count - 1) {
            let from = screenPositions[i]
            let to = screenPositions[i + 1]

            let dx = to.screenX - from.screenX
            let dy = to.screenY - from.screenY // Note: negative dy means going up visually

            if dx <= 1 {
                // Vertical line
                let minScreenY = min(from.screenY, to.screenY)
                let maxScreenY = max(from.screenY, to.screenY)
                for y in (minScreenY + 1)..<maxScreenY {
                    if y >= 0 && y <= yAxisStartIndex && from.screenX < content[y].count {
                        content[y][from.screenX] = "|"
                    }
                }
            } else if dy == 0 {
                // Horizontal line
                for x in (from.screenX + 1)..<to.screenX {
                    if from.screenY >= 0 && from.screenY <= yAxisStartIndex && x < content[from.screenY].count {
                        content[from.screenY][x] = "─"
                    }
                }
            } else {
                // Diagonal line - use Bresenham-style stepping
                let steps = max(abs(dx), abs(dy))
                for step in 1..<steps {
                    let t = Double(step) / Double(steps)
                    let x = from.screenX + Int(Double(dx) * t)
                    let y = from.screenY + Int(Double(dy) * t)

                    if y >= 0 && y <= yAxisStartIndex && x >= xAxisStartIndex && x < content[y].count {
                        if content[y][x] == " " {
                            if dy < 0 {
                                // Going up (y decreasing = visually up)
                                content[y][x] = "/"
                            } else {
                                // Going down (y increasing = visually down)
                                content[y][x] = "╲"
                            }
                        }
                    }
                }
            }
        }

        for y in content.indices.reversed() {
            // Keep y 0 empty to leave space for the title.
            if y == 0, title != nil {
                continue
            }

            entryPositionX = initialPositionX

            // While we are draw the label, boundary etc don't increase the entry position.
            if y <= yAxisStartIndex {
                entryPositionY += scaleY
            }

            for x in content[y].indices {
                // Draw the y axis boundary.
                if x < xAxisStartIndex {
                    if x == yBoundaryLineXIndex && showsAxisLines {
                        content[y][x] = "│"
                    }

                    continue
                }

                // Draw the x axis boundary.
                if y > yAxisStartIndex {
                    if y == xBoundaryLineYIndex && showsAxisLines {
                        content[y][x] = "―"
                    }

                    continue
                }

                entryPositionX += scaleX

                // Check if we passed any entries, if show draw a datapoint.
                if let value = entries.first(where: { $0.x <= entryPositionX && $0.y <= entryPositionY }) {
                    content[y][x] = "*"

                    // Draw the y axis value, only if a previous datapoint didn't already write on this row.
                    if showsYAxisValues, content[y][yBoundaryLineXIndex - largestYAxisValueLength] == " " {
                        for (i, valueChar) in Array(String(format: "%0.f", value.y)).enumerated() {
                            content[y][yBoundaryLineXIndex - largestYAxisValueLength + i] = valueChar
                        }
                    }

                    // Draw the x axis value, but if we going to overlap a previous datapoint skip this value.
                    if showsXAxisValues {
                        let valueString = String(format: "%0.f", value.x)

                        // Enough space to write out full value?
                        if x + valueString.count < content[xValueLabelYIndex].count,
                           // Left side is boundary or empty?
                           (content[xValueLabelYIndex][x - 1] == " " || content[xValueLabelYIndex][x - 1] == "│"),
                           // Right side is empty?
                           content[xValueLabelYIndex][x + valueString.count] == " " {

                            // Attempt to draw, if checking for overlap.
                            var contentCopy = content
                            var didOverlap = false
                            for (i, valueChar) in Array(String(format: "%0.f", value.x)).enumerated() {
                                if contentCopy[xValueLabelYIndex][x + i] != " " {
                                    didOverlap = true
                                }
                                contentCopy[xValueLabelYIndex][x + i] = valueChar
                            }

                            if !didOverlap {
                                content = contentCopy
                            }
                        }
                    }

                    // Remove the entry so we don't draw it again.
                    entries.removeAll { $0.x <= entryPositionX && $0.y <= entryPositionY }
                }
            }
        }

        // Fill in the title at the top of the graph.
        if let title {
            var titleArray = Array(title.truncateString(limit: content[0].count))
            if titleArray.count < content[0].count {
                let spaceToAddOnEachSide = (content[0].count - titleArray.count) / 2
                titleArray.insert(contentsOf: [Character].init(repeating: " ", count: spaceToAddOnEachSide), at: 0)
                titleArray.append(contentsOf: [Character].init(repeating: " ", count: spaceToAddOnEachSide))
            }

            content[0] = titleArray
        }


        self.content = content.map {
            String($0)
        }.joined(separator: "\n")
    }

    private func drawConnectingLines() {
        
    }
}
