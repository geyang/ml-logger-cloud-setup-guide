import pandas as pd

machines = pd.read_csv('topology.csv')
print(machines)

# be able to run things on each machine
# read the GPU status of each machine
#
"!ssh nvidia-smi --query-gpu=memory.used,memory.total,memory.free,utilization.gpu,utilization.memory --format=csv"