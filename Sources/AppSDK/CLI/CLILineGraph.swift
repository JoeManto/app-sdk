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

    public init(entries: [(x: Double, y: Double)], title: String? = nil, xAxisTitle: String? = nil, yAxisTitle: String? = nil, width: Int = 50, height: Int = 10) {
        self.content = ""
        self.title = title
        self.xAxisTitle = xAxisTitle
        self.yAxisTitle = yAxisTitle
        self._maxXAxisWidth = Double(width)
        self._maxYAxisHeight = Double(height)
        self._minXWidth = Double(width)
        self._minYHeight = Double(height)
        var entries = entries

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
                    if showsXAxisValues, content[xValueLabelYIndex][x] == " " {
                        for (i, valueChar) in Array(String(format: "%0.f", value.x)).enumerated() {
                            content[xValueLabelYIndex][x + i] = valueChar
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
}
