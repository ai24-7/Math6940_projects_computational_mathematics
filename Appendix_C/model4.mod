#                 MERGED MODEL:  BATCH SCHEDULING + MULTI-RESOURCE
# Sets
set T;                     # Set of tasks
set S;                     # Set of servers
param N integer > 0;       # Number of batches
set K := 1..N;             # Batches
set R;                     # Set of resources

###############################################################################
# Parameters
#----------------------------
# Scheduling / Processing
#----------------------------
param p {T, S} >= 0;       # Processing time of task i on server j
param S_time {T, S} >= 0;  # Setup time for task i on server j (used in energy)

#----------------------------
# Resource Demands / Capacity
#----------------------------
param d {T, R} >= 0;       # Demand of resource r by task i
param r {S, R} >= 0;       # Capacity of resource r on server j

#----------------------------
# Server Activation / Energy
#----------------------------
param e {S} >= 0;          # Energy consumption rate of server j
param M >= 0;              # Large constant for big-M constraints

#----------------------------
# Load Imbalance
#----------------------------
param sum_r_k {res in R} := sum {j in S} r[j, res];
  
  # Total capacity across all servers for resource r

#----------------------------
# Objective Coefficients
#----------------------------
param w {T} >= 0;          # Priority weight of task i
param alpha >= 0;          # Scaling coefficient for energy consumption
param beta  >= 0;          # Scaling coefficient for load imbalance
param gamma >= 0;          # Scaling coefficient for total completion time

###############################################################################
# Decision Variables
###############################################################################
#----------------------------
# Batch Scheduling Variables
#----------------------------
var x {T, S, K} binary;    # 1 if task i is assigned to server j in batch k
#var x {T, S, K} >= 0, <= 1; # relax variable to see if there is any solution

var s {K} >= 0;            # Start time of batch k
var D {K} >= 0;            # Duration (length) of batch k
var C {T} >= 0;            # Completion time of task i
var C_batch {T, K} >= 0;   # Captures the start time (within batch k) for task i

#----------------------------
# Server On/Off
#----------------------------
var y {S} binary;          # Server activation indicator (1 if server j is used)

#----------------------------
# Energy
#----------------------------
var E {S} >= 0;            # Energy consumption of server j

#----------------------------
# Load Imbalance
#----------------------------
var U {S, R} >= 0;         # Utilization ratio for resource r on server j
var L {S, R} >= 0;         # Load imbalance for resource r on server j

###############################################################################
# Objective: Weighted Completion + Energy + Load Imbalance
###############################################################################
minimize Z:
      gamma * sum {i in T} ( w[i] * C[i] )
    + alpha * sum {j in S} E[j]
    + beta  * sum {j in S, r2 in R} L[j, r2];

###############################################################################
# Constraints
###############################################################################

#----------------------------------------------------------------------------
# 1) Assignment: each task i must appear exactly once (on exactly one server
#    and in exactly one batch).
#----------------------------------------------------------------------------
subject to Assignment {i in T}:
    sum {j in S, k in K} x[i,j,k] = 1;

#----------------------------------------------------------------------------
# 2) Batch Duration: the duration D[k] must be at least the processing time
#    of any task assigned in batch k.
#----------------------------------------------------------------------------
subject to BatchDuration {i in T, j in S, k in K}:
    D[k] >= p[i,j] * x[i,j,k];

#----------------------------------------------------------------------------
# 3) Batch Sequencing: batches occur in chronological order.
#    s[k+1] >= s[k] + D[k].
#----------------------------------------------------------------------------
subject to BatchSequencing {k in K: k < N}:
    s[k+1] >= s[k] + D[k];

#----------------------------------------------------------------------------
# 4) Batch Start Time: the first batch starts at or after time 0.
#----------------------------------------------------------------------------
subject to BatchStartTime:
    s[1] >= 0;

#----------------------------------------------------------------------------
# 5) Capture Start Time for each Task:
#    If task i is in batch k on server j, then
#    C_batch[i,k] >= s[k].  (We use big-M to turn off if x[i,j,k]=0)
#----------------------------------------------------------------------------
subject to CaptureStartTime {i in T, j in S, k in K}:
    C_batch[i,k] >= s[k] - M*(1 - x[i,j,k]);

#----------------------------------------------------------------------------
# 6) Completion Time: for each task i,
#    C[i] >= C_batch[i,k] + p[i,j]*x[i,j,k].
#----------------------------------------------------------------------------
subject to CompletionTime {i in T, j in S, k in K}:
    C[i] >= C_batch[i,k] + p[i,j]*x[i,j,k];

#----------------------------------------------------------------------------
# 7) Unified Multi-Resource Capacity *Per Batch*:
#    For each resource r, each server j, each batch k,
#    total demand by tasks in that batch cannot exceed capacity (and server
#    must be on if used).
#----------------------------------------------------------------------------
subject to ResourceCapacity {j in S, r2 in R, k in K}:
    sum {i in T} d[i, r2] * x[i,j,k] <= r[j, r2] * y[j];

#----------------------------------------------------------------------------
# 8) Server Activation: if server j is used by any task in any batch,
#    then y[j] must be 1.  (sum_{i,k} x[i,j,k] <= M*y[j])
#----------------------------------------------------------------------------
subject to ServerActivation {j in S}:
    sum {i in T, k in K} x[i,j,k] <= M * y[j];

#----------------------------------------------------------------------------
# 9) Energy Consumption:
#    E[j] = e[j] * sum of (processing + setup) for tasks assigned to j
#----------------------------------------------------------------------------
subject to EnergyConsumption {j in S}:
    E[j] = e[j] * sum {i in T, k in K} (p[i,j] + S_time[i,j]) * x[i,j,k];

#----------------------------------------------------------------------------
# 10) Utilization Ratio:
#     For each server j, resource r2,
#     U[j, r2] = ( total usage ) / ( capacity ), using the entire schedule
#----------------------------------------------------------------------------
subject to UtilizationRatio {j in S, r2 in R}:
    U[j, r2] = ( sum {i in T, k in K} d[i,r2] * x[i,j,k] ) / r[j, r2];

#----------------------------------------------------------------------------
# 11) Load Imbalance:
#     For each server j, resource r2, L[j,r2] is the difference from the mean.
#     Let "mean" = (sum_{j2} sum_{i,k} d[i,r2]*x[i,j2,k]) / sum_r_k[r2].
#----------------------------------------------------------------------------
subject to LoadImbalanceUpper {j in S, r2 in R}:
    L[j, r2] 
      >= U[j, r2]
         - ( ( sum {j2 in S, i in T, k in K} d[i,r2]* x[i,j2,k] )
             / sum_r_k[r2] );

subject to LoadImbalanceLower {j in S, r2 in R}:
    L[j, r2] 
      >= ( ( sum {j2 in S, i in T, k in K} d[i,r2]* x[i,j2,k] )
           / sum_r_k[r2] )
         - U[j, r2];



