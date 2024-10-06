set FEEDS;
set NUTRIENTS;

param cost {FEEDS} >= 0;
param min_req {NUTRIENTS} >= 0;
param content {NUTRIENTS, FEEDS} >= 0;

param M := 1000;

var x {FEEDS} >= 0, integer;
var y {FEEDS} binary;

minimize Total_Cost:
    sum {f in FEEDS} cost[f] * x[f];

subject to Nutrient_Requirements {n in NUTRIENTS}:
    sum {f in FEEDS} content[n,f] * x[f] >= min_req[n];

subject to Use_Feed_Link {f in FEEDS}:
    x[f] <= M * y[f];

subject to Max_Two_Feeds:
    sum {f in FEEDS} y[f] <= 2;