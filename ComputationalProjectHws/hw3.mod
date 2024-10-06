# Set of player i, total number of players 7 
set Players := 1..7;

# Parameters for abilities
param BallHandling {Players};
param Shooting {Players};
param Rebounding {Players};
param Defense {Players};

# Parameters for positions
param G {Players};  # Guard
param F {Players};  # Forward
param C {Players};  # Center

# Decision variable
var x {Players} binary;

# Objective: Maximize total defensive ability
maximize Total_Defense:
    sum {i in Players} Defense[i] * x[i];

# Constraints

# Team size constraint
subject to Team_Size:
    sum {i in Players} x[i] = 5;

# Position constraints
subject to Guard_Constraint:
    sum {i in Players} G[i] * x[i] >= 3;

subject to Forward_Constraint:
    sum {i in Players} F[i] * x[i] >= 2;

subject to Center_Constraint:
    sum {i in Players} C[i] * x[i] >= 1;

# Skill level constraints
subject to BallHandling_Constraint:
    sum {i in Players} BallHandling[i] * x[i] >= 10;

subject to Shooting_Constraint:
    sum {i in Players} Shooting[i] * x[i] >= 10;

subject to Rebounding_Constraint:
    sum {i in Players} Rebounding[i] * x[i] >= 10;

# Conditional constraints
# if player 3 starts, then player 6 cannot
subject to Player3_Player6:
    x[3] + x[6] <= 1;

# if player 1 starts, then players 4 and 5 must both do
subject to Player1_Player4:
    x[1] - x[4] <= 0;

subject to Player1_Player5:
    x[1] - x[5] <= 0;

# either player 2 or player 3 must start
subject to Player2_or_Player3:
    x[2] + x[3] >= 1;
