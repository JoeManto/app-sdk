//
//  CLILineGraph.swift
//  AppSDK
//
//  Created by Joe Manto on 12/23/25.
//

import Foundation

public struct CLILineGraph {

    // MARK: - Types

    public typealias Entry = (x: Double, y: Double)

    /// Holds pre-calculated layout indices for drawing the graph.
    private struct Layout {
        /// Column index where the graph data area begins.
        let graphStartX: Int
        /// Row index where the graph data area ends (bottom of plot area).
        let graphEndY: Int
        /// Row index for the x-axis boundary line.
        let xAxisLineY: Int
        /// Row index for x-axis value labels.
        let xAxisLabelY: Int
        /// Column index for the y-axis boundary line.
        let yAxisLineX: Int
        /// Column index where y-axis value labels start.
        let yAxisLabelStartX: Int
        /// Maximum character width for y-axis labels.
        let yAxisLabelWidth: Int
    }

    // MARK: - Properties

    public private(set) var content: String

    public let title: String?
    public let xAxisTitle: String?
    public let yAxisTitle: String?

    private let showsXAxisValues = true
    private let showsYAxisValues = true
    private let showsAxisLines = true

    private var maxWidth: Double
    private var maxHeight: Double
    private let minWidth: Double
    private let minHeight: Double

    // MARK: - Initialization

    public init(
        entries: [Entry],
        title: String? = nil,
        xAxisTitle: String? = nil,
        yAxisTitle: String? = nil,
        width: Int = 50,
        height: Int = 10,
        resolution: Double = 1.0
    ) {
        self.content = ""
        self.title = title
        self.xAxisTitle = xAxisTitle
        self.yAxisTitle = yAxisTitle
        self.maxWidth = Double(width)
        self.maxHeight = Double(height)
        self.minWidth = Double(width)
        self.minHeight = Double(height)

        // Filter entries based on resolution.
        var entries = _filterEntriesByResolution(entries, resolution: resolution)

        // Calculate data bounds and scaling.
        let bounds = _calculateBounds(entries: entries)
        let scale = _calculateScale(bounds: bounds)

        // Calculate layout dimensions.
        let yAxisLabelWidth = entries.reduce(0) { max($0, _formatValue($1.y).count) }
        let extraHeight = (title != nil ? 1 : 0) + (showsAxisLines ? 1 : 0) + (showsXAxisValues ? 1 : 0) + (xAxisTitle != nil ? 1 : 0)
        let extraWidth = (yAxisTitle != nil ? 1 : 0) + (showsYAxisValues ? yAxisLabelWidth : 0) + (showsAxisLines ? 1 : 0)

        // Initialize content grid.
        let gridWidth = Int(maxWidth + Double(extraWidth))
        let gridHeight = Int(maxHeight + Double(extraHeight))
        var grid: [[Character]] = Array(
            repeating: Array(repeating: " ", count: gridWidth),
            count: gridHeight
        )

        // Build layout.
        let layout = Layout(
            graphStartX: extraWidth,
            graphEndY: (grid.count - 1) - (extraHeight - (title != nil ? 1 : 0)),
            xAxisLineY: (grid.count - 1) - (extraHeight - (title != nil ? 1 : 0)) + 1,
            xAxisLabelY: (grid.count - 1) - (extraHeight - (title != nil ? 1 : 0)) + 2,
            yAxisLineX: extraWidth - 1,
            yAxisLabelStartX: extraWidth - 1 - yAxisLabelWidth,
            yAxisLabelWidth: yAxisLabelWidth
        )

        // Draw graph components.
        _drawAxes(grid: &grid, layout: layout)
        _drawDataPoints(grid: &grid, layout: layout, entries: &entries, bounds: bounds, scale: scale)
        _drawConnectingLines(grid: &grid, layout: layout)

        if let title {
            _drawTitle(title, grid: &grid)
        }

        // Convert grid to string.
        self.content = grid.map { String($0) }.joined(separator: "\n")
    }

    // MARK: - Bounds & Scale Calculation

    private struct Bounds {
        let minX: Double
        let maxX: Double
        let minY: Double
        let maxY: Double

        var rangeX: Double { maxX - minX }
        var rangeY: Double { maxY - minY }
    }

    private struct Scale {
        let x: Double
        let y: Double
    }

    private func _calculateBounds(entries: [Entry]) -> Bounds {
        guard let first = entries.first else {
            return Bounds(minX: 0, maxX: 0, minY: 0, maxY: 0)
        }

        var minX = first.x, maxX = first.x
        var minY = first.y, maxY = first.y

        for entry in entries {
            minX = min(minX, entry.x)
            maxX = max(maxX, entry.x)
            minY = min(minY, entry.y)
            maxY = max(maxY, entry.y)
        }

        return Bounds(minX: minX, maxX: maxX, minY: minY, maxY: maxY)
    }

    private mutating func _calculateScale(bounds: Bounds) -> Scale {
        var scaleY: Double = 1
        if bounds.rangeY > maxHeight {
            scaleY = bounds.rangeY / maxHeight
        } else if bounds.rangeY < minHeight {
            scaleY = bounds.rangeY / minHeight
        } else {
            maxHeight = bounds.rangeY
        }

        var scaleX: Double = 1
        if bounds.rangeX > maxWidth {
            scaleX = bounds.rangeX / maxWidth
        } else if bounds.rangeX < minWidth {
            scaleX = bounds.rangeX / minWidth
        } else {
            maxWidth = bounds.rangeX
        }

        return Scale(x: scaleX, y: scaleY)
    }

    // MARK: - Drawing: Axes

    private func _drawAxes(grid: inout [[Character]], layout: Layout) {
        for y in grid.indices {
            for x in grid[y].indices {
                // Y-axis vertical line.
                if x == layout.yAxisLineX && y <= layout.graphEndY && showsAxisLines {
                    grid[y][x] = "│"
                }
                // X-axis horizontal line.
                if y == layout.xAxisLineY && x >= layout.graphStartX && showsAxisLines {
                    grid[y][x] = "―"
                }
            }
        }
    }

    // MARK: - Drawing: Data Points

    private func _drawDataPoints(
        grid: inout [[Character]],
        layout: Layout,
        entries: inout [Entry],
        bounds: Bounds,
        scale: Scale
    ) {
        var entryPositionY = bounds.minY

        for y in grid.indices.reversed() {
            // Skip title row.
            if y == 0 && title != nil {
                continue
            }

            // Only increment Y position within the graph area.
            if y <= layout.graphEndY {
                entryPositionY += scale.y
            }

            var entryPositionX = bounds.minX

            for x in grid[y].indices {
                // Skip areas outside the graph.
                if x < layout.graphStartX || y > layout.graphEndY {
                    continue
                }

                entryPositionX += scale.x

                // Check if any entry falls within this cell.
                if let entry = entries.first(where: { $0.x <= entryPositionX && $0.y <= entryPositionY }) {
                    grid[y][x] = "*"

                    _drawYAxisLabel(grid: &grid, layout: layout, row: y, value: entry.y)
                    _drawXAxisLabel(grid: &grid, layout: layout, column: x, value: entry.x)

                    // Remove drawn entry to avoid duplicates.
                    entries.removeAll { $0.x <= entryPositionX && $0.y <= entryPositionY }
                }
            }
        }
    }

    private func _drawYAxisLabel(grid: inout [[Character]], layout: Layout, row: Int, value: Double) {
        guard showsYAxisValues else { return }
        // Only draw if this row doesn't already have a label.
        guard grid[row][layout.yAxisLabelStartX] == " " else { return }

        let label = _formatValue(value)
        for (i, char) in label.enumerated() {
            grid[row][layout.yAxisLabelStartX + i] = char
        }
    }

    private func _drawXAxisLabel(grid: inout [[Character]], layout: Layout, column: Int, value: Double) {
        guard showsXAxisValues else { return }

        let label = _formatValue(value)
        let labelRow = layout.xAxisLabelY

        // Check if there's room and no overlap.
        guard column + label.count < grid[labelRow].count else { return }
        guard grid[labelRow][column - 1] == " " || grid[labelRow][column - 1] == "│" else { return }
        guard grid[labelRow][column + label.count] == " " else { return }

        // Check for overlap before drawing.
        let wouldOverlap = (0..<label.count).contains { grid[labelRow][column + $0] != " " }
        guard !wouldOverlap else { return }

        for (i, char) in label.enumerated() {
            grid[labelRow][column + i] = char
        }
    }

    // MARK: - Drawing: Connecting Lines

    private func _drawConnectingLines(grid: inout [[Character]], layout: Layout) {
        // Find all data point positions.
        var points: [(x: Int, y: Int)] = []
        for y in grid.indices {
            for x in grid[y].indices {
                if grid[y][x] == "*" {
                    points.append((x: x, y: y))
                }
            }
        }

        // Sort left to right.
        points.sort { $0.x < $1.x }

        // Draw lines between consecutive points.
        for i in 0..<(points.count - 1) {
            let from = points[i]
            let to = points[i + 1]
            _drawLineBetween(from: from, to: to, grid: &grid, layout: layout)
        }
    }

    private func _drawLineBetween(
        from: (x: Int, y: Int),
        to: (x: Int, y: Int),
        grid: inout [[Character]],
        layout: Layout
    ) {
        let dx = to.x - from.x
        let dy = to.y - from.y

        if dx <= 1 {
            // Vertical or nearly vertical line.
            _drawVerticalLine(from: from, to: to, grid: &grid, layout: layout)
        } else if dy == 0 {
            // Horizontal line.
            _drawHorizontalLine(from: from, to: to, grid: &grid, layout: layout)
        } else {
            // Diagonal line.
            _drawDiagonalLine(from: from, to: to, grid: &grid, layout: layout)
        }
    }

    private func _drawVerticalLine(
        from: (x: Int, y: Int),
        to: (x: Int, y: Int),
        grid: inout [[Character]],
        layout: Layout
    ) {
        let minY = min(from.y, to.y)
        let maxY = max(from.y, to.y)

        for y in (minY + 1)..<maxY {
            if _isValidGraphPosition(x: from.x, y: y, grid: grid, layout: layout) {
                grid[y][from.x] = "|"
            }
        }
    }

    private func _drawHorizontalLine(
        from: (x: Int, y: Int),
        to: (x: Int, y: Int),
        grid: inout [[Character]],
        layout: Layout
    ) {
        for x in (from.x + 1)..<to.x {
            if _isValidGraphPosition(x: x, y: from.y, grid: grid, layout: layout) {
                grid[from.y][x] = "─"
            }
        }
    }

    private func _drawDiagonalLine(
        from: (x: Int, y: Int),
        to: (x: Int, y: Int),
        grid: inout [[Character]],
        layout: Layout
    ) {
        let dx = to.x - from.x
        let dy = to.y - from.y
        let steps = max(abs(dx), abs(dy))
        let lineChar: Character = dy < 0 ? "/" : "╲"

        for step in 1..<steps {
            let t = Double(step) / Double(steps)
            let x = from.x + Int(Double(dx) * t)
            let y = from.y + Int(Double(dy) * t)

            if _isValidGraphPosition(x: x, y: y, grid: grid, layout: layout) && grid[y][x] == " " {
                grid[y][x] = lineChar
            }
        }
    }

    private func _isValidGraphPosition(x: Int, y: Int, grid: [[Character]], layout: Layout) -> Bool {
        y >= 0 && y <= layout.graphEndY && x >= layout.graphStartX && x < grid[y].count
    }

    // MARK: - Drawing: Title

    private func _drawTitle(_ title: String, grid: inout [[Character]]) {
        let maxWidth = grid[0].count
        var titleChars = Array(title.truncateString(limit: maxWidth))

        // Center the title.
        if titleChars.count < maxWidth {
            let padding = (maxWidth - titleChars.count) / 2
            titleChars.insert(contentsOf: Array(repeating: " ", count: padding), at: 0)
            titleChars.append(contentsOf: Array(repeating: " ", count: padding))
        }

        grid[0] = titleChars
    }

    // MARK: - Resolution Filtering

    private func _filterEntriesByResolution(_ entries: [Entry], resolution: Double) -> [Entry] {
        guard entries.count > 2, resolution < 1.0 else {
            return entries
        }

        let resolution = max(0, min(1, resolution))

        // Identify peaks and valleys.
        var isSignificant = [Bool](repeating: false, count: entries.count)
        isSignificant[0] = true
        isSignificant[entries.count - 1] = true

        for i in 1..<(entries.count - 1) {
            let prev = entries[i - 1].y
            let curr = entries[i].y
            let next = entries[i + 1].y

            let isPeak = curr >= prev && curr >= next && (curr > prev || curr > next)
            let isValley = curr <= prev && curr <= next && (curr < prev || curr < next)

            isSignificant[i] = isPeak || isValley
        }

        // Collect non-significant (middle) indices.
        let middleIndices = entries.indices.filter { !isSignificant[$0] }

        // Calculate how many middle entries to keep.
        let keepCount = Int(Double(middleIndices.count) * resolution)
        var keepSet = Set<Int>()

        if keepCount > 0 && !middleIndices.isEmpty {
            let step = Double(middleIndices.count) / Double(keepCount)
            for i in 0..<keepCount {
                let index = Int(Double(i) * step)
                if index < middleIndices.count {
                    keepSet.insert(middleIndices[index])
                }
            }
        }

        // Build filtered result.
        return entries.enumerated().compactMap { index, entry in
            (isSignificant[index] || keepSet.contains(index)) ? entry : nil
        }
    }

    // MARK: - Helpers

    private func _formatValue(_ value: Double) -> String {
        String(format: "%0.f", value)
    }
}
