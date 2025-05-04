# Scenario 3
# Batch Scheduling with Dynamic Batch Sizes and Durations
# Gurobi Solver

# Sets and Indices
set T;  # Set of tasks
set S;  # Set of servers
param N integer > 0;  # Number of batches
set K;  # Set of batches

# Parameters
param p {T, S} >= 0;  # Processing time required to complete task i on server j
param d {T} >= 0;     # Resource demand of task i
param r {S} >= 0;     # Resource capacity of server j

# Decision Variables
var x {T, S, K} binary;  # 1 if task i is assigned to server j in batch k
var s {K} >= 0;          # Start time of batch k
var D {K} >= 0;          # Duration of batch k
var C {T} >= 0;          # Completion time of task i

# Objective Function
minimize TotalCompletionTime:
    sum {i in T} C[i];

# Constraints

# 1. Assignment Constraint
subject to Assignment {i in T}:
    sum {j in S, k in K} x[i,j,k] = 1;

# 2. Resource Capacity Constraints
subject to ResourceCapacity {j in S, k in K}:
    sum {i in T} d[i] * x[i,j,k] <= r[j];

# 3. Batch Duration Constraints
subject to BatchDuration {i in T, j in S, k in K}:
    D[k] >= p[i,j] * x[i,j,k];

# 4. Batch Sequencing Constraints
subject to BatchSequencing {k in K: k < N}:
    s[k+1] >= s[k] + D[k]; 

# 5. Batch Start Time
subject to BatchStartTime:
    s[1] >= 0;

# 6. Completion Time Calculation
subject to CompletionTime {i in T}:
    C[i] = sum {j in S, k in K} (s[k] + p[i,j]) * x[i,j,k];
    
