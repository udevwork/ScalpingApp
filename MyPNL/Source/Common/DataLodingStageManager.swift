import Foundation
import Combine

public class DataLodingStageManager: ObservableObject {
    
    public var totalStageCount: Int
    public var currentStage: Int = 0
    public var completed: Bool = false
    public var completedWithError: Bool = false
    
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
            DispatchQueue.main.async { [weak self] in
                self?.inProgress = false
            }
            
            print("LoadingStageManager: Finished!")
            objectWillChange.send()
        }
        
        
    }
    
    public func finishWithError(){
        completedWithError = true
        inProgress = false
    }
    
}
