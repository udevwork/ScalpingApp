//
//  DataLodingStageManager.swift
//  BetaTestApp
//
//  Created by Denis Kotelnikov on 18.09.2022.
//

import Foundation

class DataLodingStageManager: ObservableObject {
    
    @Published var totalStageCount: Int
    @Published var currentStage: Int = 0
    
    @Published var completed: Bool = false
    @Published var completedWithError: Bool = false
    
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
    
    public func finishStep(){
        currentStage += 1
        if currentStage == totalStageCount{
            completed = true
            inProgress = false
        }
    }
    
    public func finishWithError(){
        completedWithError = true
        inProgress = false
    }
    
}
