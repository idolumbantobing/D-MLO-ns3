import matplotlib as mpl
import matplotlib.pyplot as plt
from matplotlib.patches import Rectangle
import matplotlib.patches as mpatches
import os
import numpy as np
import glob
import sys

# Set global style parameters
plt.rcParams.update({
    'font.size': 12,
    'axes.labelsize': 12,
    'axes.titlesize': 12,
    'xtick.labelsize': 12,
    'ytick.labelsize': 12,
    'legend.fontsize': 10,
    'axes.linewidth': 2,
    'grid.linewidth': 1,
    'lines.markersize': 9,
    'lines.markeredgewidth': 1.5
})

# --- Global Parameters ---
W = 20
L = 20
cell_size = 0.4

# --- Define AP Positions and Colors ---
ap_coords = {
    "AP1": (5, 5),
    "AP2": (15, 5),
    "AP3": (15, 15),
    "AP4": (5, 15),
}
ap_colors = {
    "AP1": '#90EE90',
    "AP2": 'green',
    "AP3": 'blue',
    "AP4": 'skyblue',
    "Unknown": 'black'
}

# --- Load Waypoints ---
waypoints_file = os.path.expanduser(
    '../wifi-dmlo34/random-human-waypoints.txt'
)


waypoints = []
with open(waypoints_file, 'r') as f:
    for line in f:
        x, y, _ = map(float, line.strip().split())
        waypoints.append((x, y))

# --- Plot Interior Walls ---
walls_file = os.path.expanduser(
    '../wifi-dmlo34/walls-assignment.txt'
)

if len(sys.argv) != 3:
    print("Usage: python3 plot.py <scenario> <wall_loss>")
    print("Example: python3 plot_assoc.py dmlo12 7")
    sys.exit(1)

scenario = sys.argv[1]
wall_loss = sys.argv[2]

file_prefix = 'eht'
if 'dmlo' in scenario:
    file_prefix = 'ehr'

# Build pattern dynamically
log_pattern = os.path.expanduser(
    f'../'
    f'wifi-{scenario}/assoc-rxpower-logs/'
    f'wifi-{file_prefix}-roaming-assoc-unsaturated-beacons-4-wall-loss-{wall_loss}-*.txt'
)

print(f"Searching files:")
print(log_pattern)

# Get all matching files
log_files = glob.glob(log_pattern)

if not log_files:
    print("No matching files found.")
    sys.exit(1)

print(f"Found {len(log_files)} file(s).")

# Get all matching files
log_files = glob.glob(log_pattern)

# Process ALL matching log files
for log_file in log_files:

    print(f"Processing: {log_file}")

    base_name = os.path.basename(log_file)

    if "ehr" in log_file:
        out_prefix = "wifi8-roaming"
    elif "eht" in log_file:
        out_prefix = "wifi7-roaming"
    else:
        out_prefix = "wifi-roaming"

    if "wifi-ehr-roaming-assoc-" in base_name:
        scenario_part = base_name.split("wifi-ehr-roaming-assoc-")[1].replace(".txt", "")
    else:
        scenario_part = base_name.replace(".txt", "")

    position_to_aps = {}

    with open(log_file, 'r') as f:
        lines = f.readlines()

    i = 0

    while i < len(lines):

        line = lines[i].strip()

        if line.startswith("New position:"):

            # Parse position
            pos = tuple(map(float, line.split(":")[1:4]))  # (x, y, z)

            i += 1

            # Always prepare 3 links
            aps = ["Unknown", "Unknown", "Unknown"]

            while i < len(lines):

                current = lines[i].strip()

                # Stop if next position begins
                if current.startswith("New position:"):
                    break

                # Parse association line
                if "is associated with" in current:

                    try:
                        # Extract link index
                        link_idx = int(
                            current.split("STA(link")[1]
                                   .split(")")[0]
                                   .strip()
                        )

                        # Extract AP name
                        ap = current.split("with")[-1].strip()

                        # Store in correct slot
                        if 0 <= link_idx < 3:
                            aps[link_idx] = ap

                    except Exception as e:
                        print(f"Failed parsing line: {current}")
                        print(e)

                i += 1

            # Store only x,y
            position_to_aps[pos[:2]] = aps

        else:
            i += 1

    # --- Create new figure for EACH file ---
    plt.figure(figsize=(8, 8))

    plt.grid(True, which='both', linestyle='--', alpha=0.5)
    plt.xlabel('X Coordinate (meters)', fontweight='bold')
    plt.ylabel('Y Coordinate (meters)', fontweight='bold')
    plt.xlim(-2.5, L + 2.5)
    plt.ylim(-2.5, W + 2.5)
    plt.gca().set_aspect('equal', adjustable='box')

    # BSS
    ap1 = [(5, 5)]
    ap2 = [(15, 5)]
    ap3 = [(15, 15)]
    ap4 = [(5, 15)]

    # Plot APs
    plt.scatter(*zip(*ap1), marker='D', s=75, c='#90EE90',
                edgecolor='black', linewidths=1.5, label='AP 1')
    plt.scatter(*zip(*ap2), marker='D', s=75, c='green',
                edgecolor='black', linewidths=1.5, label='AP 2')
    plt.scatter(*zip(*ap3), marker='D', s=75, c='blue',
                edgecolor='black', linewidths=1.5, label='AP 3')
    plt.scatter(*zip(*ap4), marker='D', s=75, c='skyblue',
                edgecolor='black', linewidths=1.5, label='AP 4')

    legend = plt.legend(
        loc='lower left',
        bbox_to_anchor=(-0.02, -0.02),
        ncol=4,
        handletextpad=0.1,
        handlelength=1.5,
        borderaxespad=0.8,
        labelspacing=0.6,
        columnspacing=0.1,
        framealpha=1,
        edgecolor='black'
    )

    # --- Plot Building Walls ---
    building_wall_thickness = 0.1
    wall_color = 'gray'

    plt.gca().add_patch(Rectangle((0, 0), building_wall_thickness, W, color=wall_color))
    plt.gca().add_patch(Rectangle((L - building_wall_thickness, 0), building_wall_thickness, W, color=wall_color))
    plt.gca().add_patch(Rectangle((0, 0), L, building_wall_thickness, color=wall_color))
    plt.gca().add_patch(Rectangle((0, W - building_wall_thickness), L, building_wall_thickness, color=wall_color))

    # --- Plot Interior Walls ---
    room_wall_thickness = 0.05

    with open(walls_file, 'r') as f:
        for line in f:
            if line.strip() == "" or line.startswith("roomX"):
                continue

            parts = line.split()

            xMin, xMax = float(parts[2]), float(parts[3])
            yMin, yMax = float(parts[4]), float(parts[5])

            # Draw vertical wall
            if abs(xMin - xMax) < 1e-4:
                x = xMin - room_wall_thickness / 2
                y = min(yMin, yMax)
                height = abs(yMax - yMin)

                plt.gca().add_patch(
                    Rectangle((x, y), room_wall_thickness,
                              height, color=wall_color, alpha=0.7)
                )

            # Draw horizontal wall
            elif abs(yMin - yMax) < 1e-4:
                x = min(xMin, xMax)
                y = yMin - room_wall_thickness / 2
                width = abs(xMax - xMin)

                plt.gca().add_patch(
                    Rectangle((x, y), width,
                              room_wall_thickness,
                              color=wall_color,
                              alpha=0.7)
                )

    ax = plt.gca()

    for (x, y), aps in position_to_aps.items():

        x0, y0 = x - cell_size / 3, y - cell_size / 3

        colored_aps = [ap for ap in aps if ap in ap_colors]

        if not colored_aps:
            ax.add_patch(
                Rectangle((x0, y0),
                          cell_size,
                          cell_size,
                          color='gray')
            )

        else:
            m = len(colored_aps)
            strip_width = cell_size / m

            for i, ap in enumerate(colored_aps):

                left = x0 + i * strip_width

                ax.add_patch(
                    Rectangle((left, y0),
                              strip_width,
                              cell_size,
                              color=ap_colors[ap])
                )

        ax.add_patch(
            Rectangle((x0, y0),
                      cell_size,
                      cell_size,
                      fill=False,
                      edgecolor=None,
                      linewidth=0)
        )

    plt.tight_layout()

    # Create output directory if needed
    os.makedirs(out_prefix, exist_ok=True)

    # Save PDF
    plot_filename = f'{out_prefix}/{out_prefix}-{scenario_part}-assocmap-dev.pdf'

    plt.savefig(
        plot_filename,
        bbox_inches='tight',
        dpi=1200,
        format='pdf'
    )

    print(f"Saved: {plot_filename}")

    # IMPORTANT: close figure to avoid memory buildup
    plt.close()