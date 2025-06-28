//
//  ScrollManager.swift
//  Maus
//  Gordon.H Apex Mac Workshop 2025/6/27
//
import Foundation
import CoreGraphics
import QuartzCore
import AppKit

class ScrollManager: ObservableObject {
    // MARK: - Configuration (Hardcoded optimal values)
    // - Higher = Faster snap to target (more responsive)
    // - Lower = Slower, more relaxed scroll
    private let stiffness: Double = 80.0
    // - Higher = Quicker slowdown (more friction)
    // - Lower = Longer coasting (more momentum)
    private let damping: Double = 12.0
    // - Higher = Longer fling when you release wheel
    // - Lower = More immediate stopping
    private let momentumFactor: Double = 1.8
    // - Theoretical mass of the scrolling system
    // - Changing requires rebalancing stiffness/damping
    private let mass: Double = 1.0
    // - 1.0 = Natural scrolling (like trackpad)
    // - -1.0 = Reverse scrolling (like old mice)
    private let directionMultiplier: Double = 1.0
    // - Higher = Faster maximum scroll speed
    // - Lower = More controlled, slower max speed
    private let maxVelocity: Double = 3000.0
    // - Higher = More scroll distance per wheel tick
    // - Lower = Finer precision scrolling
    // - Directly scales input events
    private let scrollDistanceMultiplier: Double = 1.5
    private let modifierKeyFlags: NSEvent.ModifierFlags = [.command]
    
    // MARK: - State (Disabled by default)
    @Published var isEnabled: Bool = false {
        didSet {
            if isEnabled {
                setupEventTap()
            } else {
                stopSystem()
            }
        }
    }
    @Published var needsAccessibility: Bool = false
    
    private var scrollPosition: Double = 0.0
    private var scrollTarget: Double = 0.0
    private var velocity: Double = 0.0
    private var eventTap: CFMachPort?
    private var displayLink: CVDisplayLink?
    private var lastInputTime: Double = 0

    init() {
        setupDisplayLink()
        checkAccessibility()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appDidBecomeActive),
            name: NSApplication.didBecomeActiveNotification,
            object: nil
        )
    }
    
    deinit {
        stopSystem()
    }
    
    // MARK: - System Control
    private func setupEventTap() {
        checkAccessibility()
        guard !needsAccessibility else { return }
        
        stopSystem()
        
        let eventMask = CGEventMask(1 << CGEventType.scrollWheel.rawValue)
        eventTap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: eventMask,
            callback: { (proxy, type, event, refcon) -> Unmanaged<CGEvent>? in
                guard let refcon = refcon else { return Unmanaged.passUnretained(event) }
                let manager = Unmanaged<ScrollManager>.fromOpaque(refcon).takeUnretainedValue()
                return manager.handleEvent(event: event)
            },
            userInfo: Unmanaged.passUnretained(self).toOpaque()
        )
        
        if let tap = eventTap {
            let runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, tap, 0)
            CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)
            CGEvent.tapEnable(tap: tap, enable: true)
            startDisplayLink()
        }
    }
    
    private func handleEvent(event: CGEvent) -> Unmanaged<CGEvent>? {
        guard isEnabled else { return Unmanaged.passUnretained(event) }
        if event.getIntegerValueField(.scrollWheelEventIsContinuous) != 0 {
            return Unmanaged.passUnretained(event)
        }
        if NSEvent.modifierFlags.contains(modifierKeyFlags) {
            return Unmanaged.passUnretained(event)
        }
        
        let delta = Double(event.getIntegerValueField(.scrollWheelEventPointDeltaAxis1))
        guard delta != 0 else { return Unmanaged.passUnretained(event) }
        
        let now = CACurrentMediaTime()
        lastInputTime = now
        
        scrollTarget += delta * scrollDistanceMultiplier * momentumFactor
        startDisplayLink()
        
        return nil
    }
    
    private func processFrame() {
        guard isEnabled, let _ = eventTap else { return }
        
        let now = CACurrentMediaTime()
        let deltaTime = min(now - lastInputTime, 1.0/60.0)
        lastInputTime = now
        
        let displacement = scrollTarget - scrollPosition
        let springForce = stiffness * displacement
        let dampingForce = -damping * velocity
        let acceleration = (springForce + dampingForce) / mass
        
        velocity += acceleration * deltaTime
        velocity = max(min(velocity, maxVelocity), -maxVelocity)
        scrollPosition += velocity * deltaTime
        
        let pixelsToScroll = scrollPosition.rounded(.towardZero)
        if abs(pixelsToScroll) >= 1 {
            postScrollEvent(pixels: pixelsToScroll * directionMultiplier)
            scrollPosition -= pixelsToScroll
            scrollTarget -= pixelsToScroll
        }
        
        if abs(velocity) < 0.1 && abs(displacement) < 0.1 {
            resetScrollState()
        }
    }
    
    private func postScrollEvent(pixels: Double) {
        let event = CGEvent(scrollWheelEvent2Source: nil,
                          units: .pixel,
                          wheelCount: 1,
                          wheel1: Int32(pixels),
                          wheel2: 0,
                          wheel3: 0)
        event?.post(tap: .cghidEventTap)
    }
    
    private func resetScrollState() {
        velocity = 0
        scrollPosition = 0
        scrollTarget = 0
        stopDisplayLink()
    }
    
    func stopSystem() {
        stopDisplayLink()
        if let tap = eventTap {
            CGEvent.tapEnable(tap: tap, enable: false)
        }
        eventTap = nil
        resetScrollState()
    }
    
    // MARK: - Display Link
    private func setupDisplayLink() {
        CVDisplayLinkCreateWithActiveCGDisplays(&displayLink)
        guard let link = displayLink else { return }
        
        CVDisplayLinkSetOutputCallback(link, { (_, _, _, _, _, context) -> CVReturn in
            guard let context = context else { return kCVReturnSuccess }
            let manager = Unmanaged<ScrollManager>.fromOpaque(context).takeUnretainedValue()
            DispatchQueue.main.async {
                manager.processFrame()
            }
            return kCVReturnSuccess
        }, Unmanaged.passUnretained(self).toOpaque())
    }
    
    private func startDisplayLink() {
        guard let link = displayLink, !CVDisplayLinkIsRunning(link) else { return }
        CVDisplayLinkStart(link)
        lastInputTime = CACurrentMediaTime()
    }
    
    private func stopDisplayLink() {
        guard let link = displayLink, CVDisplayLinkIsRunning(link) else { return }
        CVDisplayLinkStop(link)
    }
    
    // MARK: - Accessibility
    @objc private func appDidBecomeActive() {
        checkAccessibility()
    }
    
    func checkAccessibility() {
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: false] as CFDictionary
        let trusted = AXIsProcessTrustedWithOptions(options)
        
        DispatchQueue.main.async {
            self.needsAccessibility = !trusted
        }
    }
    
    func requestAccessibility() {
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true] as CFDictionary
        AXIsProcessTrustedWithOptions(options)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.checkAccessibility()
        }
    }
    
    // MARK: - Utility
    func checkForConflictingApps() {
        let runningApps = NSWorkspace.shared.runningApplications
        for app in runningApps {
            if let bundleId = app.bundleIdentifier, bundleId.contains("mos") {
                isEnabled = false
                break
            }
        }
    }
}
