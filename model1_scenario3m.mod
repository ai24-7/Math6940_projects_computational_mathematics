# Scenario 3 (modified to 2 sets of variables x[i,j] and y[i,k])
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

param largeM := 100;

# Decision Variables
var x {T, S} binary;  # 1 if task i is assigned to server j
var y {T, K} binary;  # 1 if task i is assigned to batch k
var s_batch {K} >= 0;          # Start time of batch k
var s_task {T} >= 0;	# Start time of task i
var D {K} >= 0;          # Duration of batch k
var C {T} >= 0;          # Completion time of task i

# Objective Function
minimize TotalCompletionTime:
    sum {i in T} C[i];

# Constraints

# 1.1 Assignment Constraint 1
subject to Assignment1 {i in T}:
    sum {j in S} x[i,j] = 1;
    
# 1.2 Assignment Constraint 2
subject to Assignment2 {i in T}:
    sum {k in K} y[i,k] = 1;


# 2. Resource Capacity Constraints
subject to ResourceCapacity {j in S}:
    sum {i in T} d[i] * x[i,j] <= r[j];




# 3. Batch Duration Constraints
subject to BatchDuration {i in T, j in S, k in K}:
    D[k] - p[i,j] >= - largeM * (2 - x[i,j] - y[i,k]);



# 4. Batch Sequencing Constraints
subject to BatchSequencing {k in K: k < N}:
    s_batch[k+1] >= s_batch[k] + D[k]; 

# 5. Batch Start Time
subject to BatchStartTime:
    s_batch[1] >= 0;


# 6. Completion Time Calculation
subject to CompletionTime {i in T}:
    C[i] = sum {k in K} s_batch[k]* y[i,k] + sum {j in S} p[i,j] * x[i,j];
   
 
    
