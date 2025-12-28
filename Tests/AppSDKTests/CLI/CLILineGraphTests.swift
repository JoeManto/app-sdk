//
//  CLILineGraphTests.swift
//  AppSDK
//
//  Created by Joe Manto on 12/28/25.
//

import Foundation
import Testing
@testable import AppSDK

@Suite("CLILineGraph Tests")
struct CLILineGraphTests {

    @Test("Basic graph with simple ascending data")
    func basicAscendingGraph() {
        let entries: [(x: Double, y: Double)] = [
            (0, 1), (1, 2), (2, 3), (3, 4), (4, 5), (5, 6)
        ]

        let graph = CLILineGraph(entries: entries, width: 20, height: 6)

        let expected = """
        6│                   *
        5│               */// 
        4│           *///     
        3│       *///         
        2│   *///             
        1│*//                 
         │――――――――――――――――――――
         │0  1   2   3   4    
        """

        #expect(graph.content == expected)
    }

    @Test("Graph with title centered")
    func graphWithTitle() {
        let entries: [(x: Double, y: Double)] = [
            (0, 0), (5, 5)
        ]

        let graph = CLILineGraph(entries: entries, title: "Test", width: 20, height: 5)

        let expected = """
                 Test         
        5│                   *
         │               //// 
         │          /////     
         │     /////          
        0│*////               
         │――――――――――――――――――――
         │0                   
        """

        #expect(graph.content == expected)
    }

    @Test("Graph with peak and valley pattern")
    func peakAndValleyGraph() {
        let entries: [(x: Double, y: Double)] = [
            (0, 5), (2, 0), (4, 5)
        ]

        let graph = CLILineGraph(entries: entries, width: 20, height: 5)

        let expected = """
            5│*╲╲                *
             │   ╲╲            // 
             │     ╲╲╲       //   
             │        ╲╲   //     
            0│          *//       
             │――――――――――――――――――――
             │0         2         
            """

        #expect(graph.content == expected)
    }

    @Test("Graph with horizontal segment")
    func horizontalSegmentGraph() {
        let entries: [(x: Double, y: Double)] = [
            (0, 3), (2, 3), (4, 3)
        ]

        let graph = CLILineGraph(entries: entries, width: 20, height: 5)

        let expected = """
            │                    
            │                    
            │                    
            │                    
           3│*─────────*────────*
            │――――――――――――――――――――
            │0         2         
           """

        #expect(graph.content == expected)
    }

    @Test("Graph with single point")
    func singlePointGraph() {
        let entries: [(x: Double, y: Double)] = [
            (5, 10)
        ]

        let graph = CLILineGraph(entries: entries, width: 20, height: 5)

        let expected = """
          │                    
          │                    
          │                    
          │                    
        10│*                   
          │――――――――――――――――――――
          │5                   
        """

        #expect(graph.content == expected)
    }

    @Test("Resolution 0.0 keeps only peaks and valleys")
    func resolutionZeroKeepsPeaksAndValleys() {
        // Data with clear peaks and valleys, plus middle points
        let entries: [(x: Double, y: Double)] = [
            (0, 0),  // start (kept)
            (1, 2),  // middle (removed)
            (2, 4),  // middle (removed)
            (3, 6),  // peak (kept)
            (4, 4),  // middle (removed)
            (5, 2),  // valley (kept)
            (6, 4),  // middle (removed)
            (7, 6),  // end (kept)
        ]

        let graphFull = CLILineGraph(entries: entries, width: 30, height: 6, resolution: 1.0)
        let graphHalfReduced = CLILineGraph(entries: entries, width: 30, height: 6, resolution: 0.5)
        let graphFullReduced = CLILineGraph(entries: entries, width: 30, height: 6, resolution: 0.0)

        let expectedFull = """
        6│            *╲╲              *
         │          //   ╲╲          // 
        4│        */       *╲      */   
         │      //           ╲╲  //     
        2│    */               */       
        0│*///                          
         │――――――――――――――――――――――――――――――
         │0   1   2   3    4   5   6    
        """

        let expectedHalfReduced = """
        6│            *╲╲              *
         │          //   ╲╲          // 
        4│        //       *╲      //   
         │      //           ╲╲  //     
        2│    */               */       
        0│*///                          
         │――――――――――――――――――――――――――――――
         │0   1       3    4   5        
        """

        let expectedFullReduced = """
        6│            *╲╲              *
         │          //   ╲╲          // 
         │        //       ╲╲      //   
         │     ///           ╲╲  //     
        2│   //                */       
        0│*//                           
         │――――――――――――――――――――――――――――――
         │0           3        5        
        """

        #expect(graphFull.content == expectedFull)
        #expect(graphHalfReduced.content == expectedHalfReduced)
        #expect(graphFullReduced.content == expectedFullReduced)
    }
}
