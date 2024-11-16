set WAREHOUSES;
set REGIONS;

param FixedCost{WAREHOUSES};
param Capacity{WAREHOUSES};
param Demand{REGIONS};
param ShippingCost{WAREHOUSES, REGIONS};

var y{WAREHOUSES} binary;
var x{WAREHOUSES, REGIONS} >= 0;

minimize TotalCost:
    sum {i in WAREHOUSES} FixedCost[i] * y[i]
    + sum {i in WAREHOUSES, j in REGIONS} ShippingCost[i,j] * x[i,j];

subject to Demand_Satisfaction {j in REGIONS}:
    sum {i in WAREHOUSES} x[i,j] = Demand[j];

subject to Capacity_Constraints {i in WAREHOUSES}:
    sum {j in REGIONS} x[i,j] <= Capacity[i] * y[i];

subject to Warehouse_Dependency:
    y["New York"] <= y["Los Angeles"];

subject to Warehouse_Limit:
    sum {i in WAREHOUSES} y[i] <= 3;

subject to Either_Atlanta_or_LA:
    y["Atlanta"] + y["Los Angeles"] >= 1;
