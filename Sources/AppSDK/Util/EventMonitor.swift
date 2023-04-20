//
//  EventMonitor.swift
//  
//
//  Created by Joe Manto on 4/20/23.
//
import Cocoa

public class EventMonitor {
    private var monitor: Any?
    private let mask: NSEvent.EventTypeMask
    private let handler: (NSEvent?) -> Void
    private let isLocal: Bool
    
    public init(mask: NSEvent.EventTypeMask, isLocal: Bool = true, handler: @escaping (NSEvent?) -> Void) {
        self.mask = mask
        self.isLocal = isLocal
        self.handler = handler
    }
    
    deinit {
        stop()
    }
    
    public func start() {
        if isLocal {
            monitor = NSEvent.addLocalMonitorForEvents(matching: mask, handler: { [weak self] event in
                self?.handler(event)
                return event
            })
        }
        else {
            monitor = NSEvent.addGlobalMonitorForEvents(matching: mask, handler: handler)
        }
    }
    
    public func stop() {
        if monitor != nil {
            NSEvent.removeMonitor(monitor!)
            monitor = nil
        }
    }
}
