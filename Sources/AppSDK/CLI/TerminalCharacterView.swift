//
//  TerminalCharacterView.swift
//  AppSDK
//
//  Created by Joe Manto on 12/26/25.
//

import AppKit

class TerminalCharacterView: NSView {
    private(set) var content: [[Character]]

    var string: String {
        layoutSubtreeIfNeeded()
        updateContent()
        return content.map { String($0) }.joined(separator: "\n")
    }

    required init(content: String, origin: CGPoint) {
        self.content = content.split(separator: "\n").map { Array($0) }

        let largestWidth = self.content.reduce(0) { max($0, $1.count) }

        for y in 0..<self.content.count {
            if self.content[y].count < largestWidth {
                self.content[y].append(contentsOf: repeatElement(" ", count: largestWidth - self.content[y].count))
            }
        }

        let frame = if !self.content.isEmpty, !self.content[0].isEmpty {
            CGRect(x: Int(origin.x), y: Int(origin.y), width: largestWidth, height: self.content.count)
        } else {
            CGRect(origin: origin, size: .zero)
        }

        super.init(frame: frame)
        self.translatesAutoresizingMaskIntoConstraints = false

        let subView = NSView(frame: frame)
        subView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(subView)

        NSLayoutConstraint.activate([
            subView.widthAnchor.constraint(equalToConstant: frame.width),
            subView.heightAnchor.constraint(equalToConstant: frame.height),
            subView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            subView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            subView.topAnchor.constraint(equalTo: self.topAnchor),
            subView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
        ])
    }

    static func emptyView(origin: CGPoint, size: CGSize) -> TerminalCharacterView {
        self.init(content: .init(repeating: .init(repeating: " ", count: Int(size.width - 1)).appending("\n"), count: Int(size.height)), origin: origin)
    }

    static func emptyCliFullScreenView() -> TerminalCharacterView {
        return Self.emptyView(origin: .zero, size: CLIProperties.shared.displaySize)
    }

    override func layout() {
        if !self.content.isEmpty, !self.content[0].isEmpty {
            self.widthAnchor.constraint(equalToConstant: CGFloat(self.content[0].count)).isActive = true
            self.heightAnchor.constraint(equalToConstant: CGFloat(self.content.count)).isActive = true
        }
        super.layout()
    }

    func updateContent() {
        for subview in self.subviews {
            if let characterSubview = subview as? TerminalCharacterView {
                characterSubview.updateContent()
            }
        }

        for subview in self.subviews {
            if let characterSubview = subview as? TerminalCharacterView {
                let x = Int(characterSubview.frame.origin.x)
                let width = characterSubview.frame.width

                let y = Int(characterSubview.frame.origin.y)
                let height = characterSubview.frame.height

                guard !self.content.isEmpty, !self.content[0].isEmpty else {
                    continue
                }

                for yIndex in 0..<Int(height) {
                    if y + yIndex >= self.content.count {
                        break
                    }

                    for xIndex in 0..<Int(width) {
                        if x + xIndex >= self.content[yIndex].count {
                            break
                        }


                        self.content[y + yIndex][x + xIndex] = characterSubview.content[yIndex][xIndex]
                    }
                }
            }
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
