
import sys

eval_log_file = sys.argv[1]

with open(eval_log_file, "r") as f:
    for line in f:
        if "clock time" in line:
            clock_time = float(line.split("-")[-1].split(":")[1].replace("min", "").strip())
        elif "cpu time" in line:
            cpu_time = float(line.split("-")[-1].split(":")[1].replace("min", "").strip())

# clock_time = round(clock_time/60, 1)
# cpu_time = round(cpu_time/60, 1)

print(f"clock time: {round(clock_time, 1)} min, cpu time: {round(cpu_time, 1)} min")
print(f"{round(clock_time, 1)} & {round(cpu_time, 1)}")