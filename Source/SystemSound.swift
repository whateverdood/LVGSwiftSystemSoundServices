//
//  SystemsSound.swift
//  Pods
//
//  Created by doof nugget on 4/24/16.
//
//

import AudioToolbox
import LVGUtilities
 
/// A wrapper around AudioToolbox's SystemSoundID

public class SystemSound {

    private struct _SystemSound: SystemSoundType {
        private let soundID: SystemSoundID
    }
    
    private let sound: _SystemSound
    
    private lazy var systemSoundCompletionProc: AudioServicesSystemSoundCompletionProc = {
        
        _, inClientData in
        
        let systemSound: SystemSound = bridgeTransfer(inClientData)
        systemSound.delegate?.didFinishPlaying(systemSound)
    }
    
    public var soundID: SystemSoundID {
        return self.sound.soundID
    }
    
    /**
     
     A `delegate` with a `didFinsishPlaying(_:)` method that is called
     when the system sound finishes playing.
     
     */
    
    public weak var delegate: SystemSoundDelegate? {
        
        didSet {
            
            self.sound.removeCompletion()
            
            if let _ = self.delegate {
                
                do {
                
                    try self.sound.addCompletion(
                        inClientData: bridgeRetained(self),
                        inCompletionRoutine: systemSoundCompletionProc)
                    
                } catch {
                    
                    print("\(error)")
                }
                
            }
        }
    }
    
    /**
     
     Initialize a `SystemSound` using an `NSURL`.
     
     - parameter url: The url of the sound file that will be played.
     
     - throws: `SystemSoundError`
     
     */
    
    public init(url: NSURL) throws {
        let soundID = try SystemSoundID(url: url)
        self.sound = _SystemSound(soundID: soundID)
    }
    
    /// Play the system sound assigned to the `soundID` property.
    public func play() {
        self.sound.play()
    }
    
    /**
     
     Play the system sound assigned to the `soundID` property as an alert.
     
     On `iOS` this may cause the device to vibrate. The actual sound played
     is dependent on the device.
     
     On `OS X` this may cause the screen to flash.
     
     */
    
    public func playAsAlert() {
        self.sound.playAsAlert()
    }
    
    #if os(iOS)
    
    /// Cause the phone to vibrate.
    public static func vibrate() {
        _SystemSound.vibrate()
    }
    
    #endif
    
    #if os(OSX)
    
    /// Play the system-defined alert sound on OS X.
    public static func playSystemAlert() {
        _SystemSound.playSystemAlert()
    }
    
    /// Flash the screen.
    public static func flashScreen() {
        _SystemSound.flashScreen()
    }
    
    #endif
    
    /**
     
     Get the value of the `.IsUISound` property.
     
     If `true`, the system sound respects the user setting in the Sound Effects
     preference and the sound will be silent when the user turns off sound effects.
     
     The default value is `true`.
     
     - throws: `SystemSoundError`
     
     - returns: A `Bool` that indicates whether or not the sound will play
     when the user has turned of sound effects in the Sound Effects preferences.
     
     */
    
    public func isUISound() throws -> Bool {
        return try self.sound.isUISound()
    }
    
    /**
     
     Set the value of the `.IsUISound` property.
     
     If `true`, the system sound respects the user setting in the Sound Effects
     preference and the sound will be silent when the user turns off sound effects.
     
     The default value is `true`.
     
     - parameter value: The `Bool` value that is to be set.
     
     - throws: `SystemSoundError`
     
     */
    
    public func isUISound(value: Bool) throws {
        try self.sound.isUISound(value)
    }
    
    /**
     
     Get the value of the `.CompletePlaybackIfAppDies` property.
     
     If `true`, the system sound will finish playing even if the application
     dies unexpectedly.
     
     The default value is `true`.
     
     - throws: `SystemSoundError`
     
     */
    
    public func completePlaybackIfAppDies() throws -> Bool {
        return try self.sound.completePlaybackIfAppDies()
    }
    
    /**
     
     Set the value of the `.CompletePlaybackIfAppDies` property.
     
     If `true`, the system sound will finish playing even if the application
     dies unexpectedly.
     
     The default value is `true`.
     
     - parameter value: The `Bool` value that is to be set.
     
     - throws: `SystemSoundError`
     
     */
    
    public func completePlaybackIfAppDies(value: Bool) throws {
        try self.sound.completePlaybackIfAppDies(value)
    }
    
    deinit {
        
        do {
            
            try self.sound.dispose()
            
        } catch {
            
            print("\(error)")
        }
    }
}