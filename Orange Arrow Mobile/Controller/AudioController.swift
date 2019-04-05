//
//  AudioController.swift
//  Orange Arrow Mobile
//
//  Created by 刘祥 on 4/1/19.
//  Copyright © 2019 xiangliu90. All rights reserved.
//

import AVFoundation

class AudioController {
    private var audio = [String:AVAudioPlayer]()
    
    func preloadAudioEffects(effectFileNames:[String]) {
        for effect in AudioEffectFiles {
            //1 get the file path URL
            let soundPath = Bundle.main.resourceURL!.appendingPathComponent(effect).path
            let soundURL = NSURL.fileURL(withPath: soundPath)
            
            //2 load the file contents
            var loadError:NSError?
            do{
                let player = try AVAudioPlayer(contentsOf: soundURL)
                //3 prepare the play
                player.numberOfLoops = 0
                player.prepareToPlay()
                
                //4 add to the audio dictionary
                audio[effect] = player
            }catch {
                loadError = error as NSError
            }
            assert(loadError == nil, "Load sound failed")
         

        }
    }
    
    func playEffect(name:String) {
        if let player = audio[name] {
            if player.isPlaying {
                player.currentTime = 0
            } else {
                player.play()
            }
        }
    }


    
}


