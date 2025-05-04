set FEEDS;
set NUTRIENTS;

param cost {FEEDS} >= 0;
param min_req {NUTRIENTS} >= 0;
param content {NUTRIENTS, FEEDS} >= 0;

var x {FEEDS} >= 0, integer;

minimize Total_Cost:
    sum {f in FEEDS} cost[f] * x[f];

subject to Nutrient_Requirements {n in NUTRIENTS}:
    sum {f in FEEDS} content[n,f] * x[f] >= min_req[n];



