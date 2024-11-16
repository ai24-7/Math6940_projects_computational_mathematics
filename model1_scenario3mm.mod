# Sets and Indices
set T;  # Set of tasks
set S;  # Set of servers
param N integer > 0;  # Number of batches
set K; #:= 1..N;  # Set of batches

# Parameters
param p {T, S} >= 0;  # Processing time required to complete task i on server j
param d {T} >= 0;     # Resource demand of task i
param r {S} >= 0;     # Resource capacity of server j

param largeM := 1000;  # Adjusted largeM to a sufficiently large value

# Decision Variables
var x {T, S} binary;        # 1 if task i is assigned to server j
var y {T, K} binary;        # 1 if task i is assigned to batch k
var w {T, S, K} binary;     # 1 if task i is assigned to server j and batch k
var s_batch {K} >= 0;       # Start time of batch k
var s_task {T} >= 0;        # Start time of task i
var D {K} >= 0;             # Duration of batch k
var C {T} >= 0;             # Completion time of task i

# Objective Function
minimize TotalCompletionTime:
    sum {i in T} C[i];

# Constraints

# 1. Assignment Constraints
subject to Assignment1 {i in T}:
    sum {j in S} x[i,j] = 1;

subject to Assignment2 {i in T}:
    sum {k in K} y[i,k] = 1;

# 1.3 Define w[i,j,k] = x[i,j] * y[i,k]
subject to w_def1 {i in T, j in S, k in K}:
    w[i,j,k] <= x[i,j];

subject to w_def2 {i in T, j in S, k in K}:
    w[i,j,k] <= y[i,k];

subject to w_def3 {i in T, j in S, k in K}:
    w[i,j,k] >= x[i,j] + y[i,k] - 1;

# 2. Resource Capacity Constraints
subject to ResourceCapacity {j in S}:
    sum {i in T} d[i] * x[i,j] <= r[j];

# 3. Batch Duration Constraints
subject to BatchDuration {k in K, i in T, j in S}:
    D[k] >= p[i,j] * w[i,j,k];

# 4. Batch Sequencing Constraints
subject to BatchSequencing {k in K: k < N}:
    s_batch[k+1] >= s_batch[k] + D[k];

# 5. Batch Start Time
subject to BatchStartTime:
    s_batch[1] >= 0;

# 6. Task Start Time Constraints
subject to TaskStartTime {i in T, k in K}:
    s_task[i] >= s_batch[k] - largeM * (1 - y[i,k]);

# 7. Completion Time Calculation
subject to CompletionTime {i in T}:
    C[i] >= s_task[i] + sum {j in S} p[i,j] * x[i,j];

# 8. Synchronization of Task and Batch Durations
subject to TaskCompletionBeforeBatchEnd {i in T, k in K}:
    s_task[i] + sum {j in S} p[i,j] * x[i,j] <= s_batch[k] + D[k] + largeM * (1 - y[i,k]);
