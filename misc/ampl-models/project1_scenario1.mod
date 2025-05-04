# Sets
set T;  # Tasks
set S;  # Servers

# Parameters
param p {T,S} >= 0;      # Processing time of task i on server j
param d {T} >= 0;        # Resource demand of task i
param r {S} >= 0;        # Resource capacity of server j

# Variables
var x {T,S} binary;      # 1 if task i is assigned to server j
var C {T} >= 0;          # Completion time of task i

# Objective
minimize Total_Completion_Time:
    sum {i in T} C[i];

# Constraints
subject to Assignment {i in T}:
    sum {j in S} x[i,j] = 1;

subject to Resource_Capacity {j in S}:
    sum {i in T} d[i] * x[i,j] <= r[j];

subject to Completion_Time {i in T}:
    C[i] = sum {j in S} p[i,j] * x[i,j];
