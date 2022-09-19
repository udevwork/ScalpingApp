//
//  DataLodingStageManager.swift
//  BetaTestApp
//
//  Created by Denis Kotelnikov on 18.09.2022.
//

import Foundation
import Combine

class DataLodingStageManager: ObservableObject {
    
    var totalStageCount: Int
    var currentStage: Int = 0
    
    var completed: Bool = false
    var completedWithError: Bool = false
    
    @Published var inProgress: Bool = false
    
    init(stageCount: Int) {
        self.totalStageCount = stageCount
    }
    
    public func start(){
        currentStage = 0
        completedWithError = false
        completed = false
        inProgress = true
    }
    
    public func finishStep(name: String? = nil){

        self.currentStage += 1
        
        if let name = name {
            print("[Stage \(currentStage)] Finish step /", name, "/")
        }
        
        if self.currentStage == self.totalStageCount{
            self.completed = true
            self.inProgress = false
            print("LoadingStageManager: Finished!")
            objectWillChange.send()
        }
        
        
    }
    
    public func finishWithError(){
        completedWithError = true
        inProgress = false
    }
    
}
