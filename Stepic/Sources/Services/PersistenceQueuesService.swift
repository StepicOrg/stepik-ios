import Foundation

@available(*, deprecated, message: "Legacy code")
protocol PersistenceQueuesServiceProtocol: class {
    func addSendViewTask(stepID: Step.IdType, assignmentID: Assignment.IdType?)
}

final class PersistenceQueuesService: PersistenceQueuesServiceProtocol {
    func addSendViewTask(stepID: Step.IdType, assignmentID: Assignment.IdType?) {
        guard let userId = AuthInfo.shared.userId, let token = AuthInfo.shared.token else {
            return
        }

        let task = PostViewsExecutableTask(stepId: stepID, assignmentId: assignmentID, userId: userId)
        ExecutionQueues.sharedQueues.connectionAvailableExecutionQueue.push(task)

        let userPersistencyManager = PersistentUserTokenRecoveryManager(baseName: "Users")
        userPersistencyManager.writeStepicToken(token, userId: userId)

        let taskPersistencyManager = PersistentTaskRecoveryManager(baseName: "Tasks")
        taskPersistencyManager.writeTask(task, name: task.id)

        let queuePersistencyManager = PersistentQueueRecoveryManager(baseName: "Queues")

        queuePersistencyManager.writeQueue(
            ExecutionQueues.sharedQueues.connectionAvailableExecutionQueue,
            key: ExecutionQueues.sharedQueues.connectionAvailableExecutionQueueKey
        )
    }
}
