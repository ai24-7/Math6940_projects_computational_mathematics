import random
import math

# Set random seed for reproducibility
random.seed(0)

num_tasks = 60
num_servers = 4
#num_batches = 8
batch_duration = 10


tasks = [f"t{i}" for i in range(1, num_tasks + 1)]
servers = [f"s{j}" for j in range(1, num_servers + 1)]


# Generate processing times
processing_times = {}
for t in tasks:
    processing_times[t] = {}
    for s in servers:
        processing_times[t][s] = random.randint(1, 10)

# Generate resource demands
resource_demands = {t: random.randint(3, 8) for t in tasks}

# Generate resource capacities
resource_capacities = {s: random.randint(20, 30) for s in servers}

# Compute total processing time (minimum across servers for each task)
total_processing_time = 0
for t in tasks:
    min_p = min(processing_times[t][s] for s in servers)
    total_processing_time += min_p
# Compute total processing capacity per batch
processing_capacity_per_batch = len(servers) * batch_duration

# Estimate minimum number of batches based on processing time
min_batches_processing = math.ceil(total_processing_time / processing_capacity_per_batch)

# Compute total resource demand
total_resource_demand = sum(resource_demands[t] for t in tasks)

# Compute total resource capacity per batch
total_resource_capacity_per_batch = sum(resource_capacities[s] for s in servers)

# Estimate minimum number of batches based on resource capacities
min_batches_resource = math.ceil(total_resource_demand / total_resource_capacity_per_batch)

# Compute the overall minimum number of batches required
min_batches_required = max(min_batches_processing, min_batches_resource)

# Print the minimum number of batches required
#print(f"Minimum number of batches required: {min_batches_required}")

batches = [str(k) for k in range(1, min_batches_required + 1)]
# Write data to AMPL data file
with open('data_synthetic_dec1.dat', 'w') as f:
    # Write sets
    f.write('set T := ' + ' '.join(tasks) + ';\n')
    f.write('set S := ' + ' '.join(servers) + ';\n')
    f.write(f'param N := {min_batches_required};\n')
    f.write('set K := ' + ' '.join(batches) + ';\n\n')
    #f.write(f'param D0 := {batch_duration};\n')
    
    # Write processing times
    f.write('param p : ' + ' '.join(servers) + ' :=\n')
    for t in tasks:
        f.write(t + ' ')
        for s in servers:
            f.write(str(processing_times[t][s]) + ' ')
        f.write('\n')
    f.write(';\n\n')
    
    # Write resource demands
    f.write('param d :=\n')
    for t in tasks:
        f.write(t + ' ' + str(resource_demands[t]) + '\n')
    f.write(';\n\n')
    
    # Write resource capacities
    f.write('param r :=\n')
    for s in servers:
        f.write(s + ' ' + str(resource_capacities[s]) + '\n')
    f.write(';\n')


