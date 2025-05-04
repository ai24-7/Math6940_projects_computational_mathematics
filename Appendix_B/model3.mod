# ---------------------------------------------------
# Optimization Model3
# Objective: Minimize weighted completion time, energy consumption, and load imbalance
# ---------------------------------------------------

# Sets
set T;      # Set of Tasks
set S;      # Set of Servers
set R;      # Set of Resources

# Parameters
param w {T};                      # Priority weight of task i
param e {S};                      # Energy consumption rate of server j
param p {T, S};                   # Processing time of task i on server j
param S_time {T, S};              # Setup time between task i and server j
param d {T, R};                   # Demand of resource k by task i
param r {S, R};                   # Capacity of resource k on server j
param alpha;                      # Scaling coefficient for energy consumption
param beta;                       # Scaling coefficient for load imbalance
param M;                          # Large constant for server activation constraints

# Precomputed Parameters
param sum_r_k {k in R} := sum {j in S} r[j, k];  # Sum of capacities for each resource

# Decision Variables
var x {T, S} binary;             # Assignment of task i to server j
var y {S} binary;                # Server activation indicator
var C {T} >= 0;                  # Completion time of task i
var E {S} >= 0;                  # Energy consumption of server j
var U {S, R} >= 0;               # Utilization of resource k on server j
var L {S, R} >= 0;               # Load imbalance of resource k on server j

# Objective Function
minimize Z:
    sum {i in T} w[i] * C[i]
    + alpha * sum {j in S} E[j]
    + beta * sum {j in S, k in R} L[j, k];

# Constraints

# 1. Assignment Constraint
subject to Assignment {i in T}:
    sum {j in S} x[i, j] = 1;

# 2. Server Activation Constraint
subject to ServerActivation {j in S}:
    sum {i in T} x[i, j] <= M * y[j];

# 3. Resource Capacity Constraints
subject to ResourceCapacity {j in S, k in R}:
    sum {i in T} d[i, k] * x[i, j] <= r[j, k] * y[j];

# 4. Completion Time Calculation
subject to CompletionTime {i in T}:
    C[i] = sum {j in S} p[i, j] * x[i, j];

# 5. Energy Consumption Calculation
subject to EnergyConsumption {j in S}:
    E[j] = e[j] * sum {i in T} (p[i, j] + S_time[i, j]) * x[i, j];

# 6. Utilization Ratio Calculation
subject to UtilizationRatio {j in S, k in R}:
    U[j, k] = sum {i in T} d[i, k] * x[i, j] / r[j, k];

# 7. Load Imbalance Constraints
subject to LoadImbalanceUpper {j in S, k in R}:
    L[j, k] >= U[j, k] - (sum {j2 in S} sum {i in T} d[i, k] * x[i, j2] / sum_r_k[k]);

subject to LoadImbalanceLower {j in S, k in R}:
    L[j, k] >= (sum {j2 in S} sum {i in T} d[i, k] * x[i, j2] / sum_r_k[k]) - U[j, k];

