//
//  ViewController.swift
//  RealtimeSoundProcessing
//
//  Created by Masaki Horimoto on 2023/04/24.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    let audioEngine = AVAudioEngine()               //AudioEngineの生成
    let audioEngine1 = AVAudioEngine()               //AudioEngineの生成
    let session = AVAudioSession.sharedInstance()   //アプリでオーディオをどのように使用するかをシステムに伝えるオブジェクト
    var audioFormat: AVAudioFormat?                 //audioFormat格納変数
    var isEffectActive = false                      //リアルタイムエフェクトがOnかOffかを示す

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //アプリ起動時にマイク入力からiPhoneスピーカーに音声をスルーする
        do {
            try session.setCategory(.playAndRecord, mode:.default, options: [.defaultToSpeaker, .allowBluetooth])                 //カテゴリをplayAndRecord,モードをデフォルトに設定。optionsに何も指定しないと電話の受話口から、本指定で機器のスピーカーから音が出るようになる
            try session.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            assertionFailure("AvAudioSettion setup error: \(error)")
        }
        
        audioFormat = audioEngine.inputNode.inputFormat(forBus: 0)
        audioEngine.connect(audioEngine.inputNode, to: audioEngine.mainMixerNode, format: audioFormat)     //Nodeを接続（inputNode -> outputNode）
        
        audioEngine.prepare()
        
        do {
            try audioEngine.start()
        } catch {
            assertionFailure("AVAudioEngine start error: \(error)")
        }
        
    }
        
    //Onボタンをタップするとエフェクトを有効にする
    @IBAction func pressOnButton(_ sender: Any) {
        if isEffectActive {
            return
        }
        
        isEffectActive = true
        
        if audioEngine.isRunning {
            audioEngine.pause()
        }
        
        //ディレイ
        let delay = AVAudioUnitDelay()
        delay.delayTime = 1
        delay.feedback = 100

        //リバーブ
        let reverb = AVAudioUnitReverb()
        reverb.loadFactoryPreset(.largeHall)

        //ディストーション
        let distortion = AVAudioUnitDistortion()
        distortion.loadFactoryPreset(.speechWaves)
        distortion.preGain = 10


        //audioEngineにディレイとリバーブをアタッチ
        audioEngine.attach(delay)
        audioEngine.attach(reverb)
        audioEngine.attach(distortion)
        
        audioEngine.disconnectNodeInput(audioEngine.mainMixerNode)
        audioEngine.connect(audioEngine.inputNode, to: delay, format: audioFormat)
        audioEngine.connect(delay, to: distortion, format: audioFormat)
        audioEngine.connect(distortion, to: audioEngine.mainMixerNode, format: audioFormat)
        //audioEngine.connect(audioEngine.mainMixerNode, to: audioEngine.outputNode, format: audioFormat)
        
        
        //if !audioEngine.isRunning {
            audioEngine.prepare()
            do {
                try audioEngine.start()
                try session.setActive(true, options: .notifyOthersOnDeactivation)
            } catch {
                assertionFailure("AVAudioEngine start error: \(error)")
            }
        //}
    }
    
    //Offボタンをタップするとエフェクトを無効にする
    @IBAction func pressOffButton(_ sender: Any) {
        if !isEffectActive {
            return
        }
        
        if audioEngine.isRunning {
            audioEngine.pause()
        }
        
        audioEngine.connect(audioEngine.inputNode, to: audioEngine.mainMixerNode, format: audioFormat)     //Nodeを接続（inputNode -> outputNode）
        
        //audioEngine.prepare()
        do {
            try audioEngine.start()
            try session.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            assertionFailure("AVAudioEngine start error: \(error)")
        }
        
        isEffectActive = false
    }
}

