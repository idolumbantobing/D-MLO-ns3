#%%
import os, glob
from cairo import Path
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
from pathlib import Path as FilePath
#%%
# ---------------- Global Style ----------------
plt.rcParams.update({
    'font.size': 50,
    'axes.labelsize': 50,
    'axes.titlesize': 50,
    'xtick.labelsize': 50,
    'ytick.labelsize': 50,
    'legend.fontsize': 44,
    'axes.linewidth': 2,
    'grid.linewidth': 1,
})
def filter_extreme_values_delay(metric_values, lower_percentile=5, upper_percentile=95):
    if len(metric_values) == 0:
        return np.array([])
    lower = np.percentile(metric_values, lower_percentile)
    upper = np.percentile(metric_values, upper_percentile)
    return np.array([v for v in metric_values if lower <= v <= upper])
    
def filter_extreme_values_rel(metric_values, lower_percentile=5, upper_percentile=100):
    if len(metric_values) == 0:
        return np.array([])
    # Clip all values above 100 to 100
    metric_values = np.clip(metric_values, None, 100)
    
    lower = np.percentile(metric_values, lower_percentile)
    upper = np.percentile(metric_values, upper_percentile)
    return np.array([v for v in metric_values if lower <= v <= upper])


# ------------- Helpers ----------------
def extract_wall_loss_db(filename: str) -> str:
    """
    Find the numeric wall-loss value that precedes a '-dB' token.
    Returns it as string (used directly as x tick label).
    """
    base = os.path.basename(filename)
    parts = base.split('-')
    for i, p in enumerate(parts):
        if p.lower().endswith('db'):
            if i > 0:
                return parts[i-1]
            return p.lower().replace('db','')
    # fallback: second last token
    return parts[-2]

def load_ns3(path: str) -> pd.DataFrame:
    df = pd.read_csv(path, header=None,
                     usecols=range(9),
                     names=['seedNumber','maxMissedBeacons','Throughput',
                            'PacketDropReliability','PacketReceivedReliability',
                            'EndToEndDelay','ChannelAccessDelay',
                            'AssociationDelay','AssociationCount'])
    for col in ['EndToEndDelay','ChannelAccessDelay','AssociationDelay']:
        s = df[col].astype(str)
        s = s.str.replace('ms','', regex=False).str.replace('+','', regex=False)
        df[col] = pd.to_numeric(s, errors='coerce')
    df['AssociationDelay'] = df['AssociationDelay'] / 1000.0
    return df

def collect_metric_dict(files, target_beacons, assoc_delay_filter=True):
    """
    Returns dict of metric_name -> { wall_loss_str : numpy_array }
    """
    metrics = {
        'Throughput': {},
        'Reliability': {},
        'CADelay': {},
        'AssocDelay': {},
        'AssocCount': {}
    }
    for f in files:
        df = load_ns3(f)
        df = df[df['maxMissedBeacons'] == target_beacons]
        if df.empty:
            continue
        wl = extract_wall_loss_db(f)

        metrics['Throughput'][wl] = df['Throughput'].values

        metrics['Reliability'][wl] = df['PacketDropReliability'].values
        
        metrics['CADelay'][wl] = filter_extreme_values_delay(df['ChannelAccessDelay'].values)

        assoc_delay_vals = df['AssociationDelay'].values
        if assoc_delay_filter and len(assoc_delay_vals) > 8:
            # mild trimming to damp extreme outliers
            lo, hi = np.percentile(assoc_delay_vals, [5, 95])
            assoc_delay_vals = assoc_delay_vals[(assoc_delay_vals >= lo) & (assoc_delay_vals <= hi)]
        metrics['AssocDelay'][wl] = assoc_delay_vals
        metrics['AssocCount'][wl] = df['AssociationCount'].values
    return metrics

def unified_wall_loss_keys(*metric_dicts):
    keys = set()
    for md in metric_dicts:
        for per_metric in md.values():
            keys.update(per_metric.keys())
    # numeric sort
    return sorted(list(keys), key=lambda x: int(x))
    
def grouped_three_variant_plot(keys, dict_dmlo_rel, dict_dmlo_thro, dict_w7, dict_jt_mlo, dict_jt_mlo_thro,
                               metric_name, ylabel, ylim, out_path,
                               order=('dmlo_thro','dmlo_rel','w7','jt_mlo','jt_mlo_thro'),
                               colors=None):
    """
    order: tuple specifying order of the variants on each x position.
    Colors are fixed to variants (not position in order).
    """

    if colors is None:
        colors = {
            'dmlo_thro': '#5DADE2',
            'dmlo_rel': '#58D68D',
            'w7': '#F5B041',
            'jt_mlo': '#AF7AC5',
            'jt_mlo_thro': '#E74C3C'
        }

    data_map = {
        'dmlo_rel': dict_dmlo_rel,
        'dmlo_thro': dict_dmlo_thro,
        'w7': dict_w7,
        'jt_mlo': dict_jt_mlo,
        'jt_mlo_thro': dict_jt_mlo_thro
    }

    labels_map = {
        'dmlo_thro': 'D-MLO Mode 1',
        'dmlo_rel': 'D-MLO Mode 2',
        'w7': 'WiFi 7 MLO-STR',
        'jt_mlo': 'D-MLO Mode 4',
        'jt_mlo_thro': 'D-MLO Mode 3'
    }

    plt.figure(figsize=(26,16))

    n_groups = len(keys)
    n_series = len(order)
    width_total = 0.75
    single_width = width_total / n_series

    x_base = np.arange(n_groups)

    legend_handles = []

    for idx, variant in enumerate(order):

        dataset = data_map[variant][metric_name]
        xs = x_base + (idx - (n_series - 1)/2) * single_width

        arrays = [np.asarray(dataset.get(k, []), dtype=float) for k in keys]

        vp = plt.violinplot(
            arrays,
            positions=xs,
            widths=single_width * 0.95,
            showmeans=False,
            showmedians=True,
            showextrema=True
        )

        color = colors[variant]

        for b in vp['bodies']:
            b.set_facecolor(color)
            b.set_edgecolor('black')
            b.set_alpha(0.55)
            b.set_linewidth(0.9)

        for k in ('cbars', 'cmins', 'cmaxes', 'cmedians'):
            vp[k].set_color('black')

        for x, arr in zip(xs, arrays):
            if len(arr) == 0:
                continue
            med = np.median(arr)
            plt.plot(x, med, marker='o', color='black', ms=6, zorder=4)

        legend_handles.append(
            mpatches.Patch(facecolor=color, edgecolor='black', label=labels_map[variant])
        )

    wanted = ['0', '3', '6', '9', '12']
    keys = [k for k in keys if k in wanted]

    plt.xticks(x_base, keys)
    plt.xlabel('Wall Loss (dB)')
    plt.ylabel(ylabel)

    if ylim:
        plt.ylim(*ylim)

    plt.grid(alpha=0.4, linestyle='--')
    plt.legend(handles=legend_handles, ncol=1, frameon=True)

    plt.tight_layout()

    os.makedirs(os.path.dirname(out_path), exist_ok=True)

    plt.savefig(out_path + '_revised.pdf', dpi=600)
    plt.savefig(out_path + '_revised.png', dpi=300)

    print('Saved:', out_path + '_revised.pdf')

    plt.close()

def main():
    # -------------- Configuration --------------
    target_beacons = 4
    # Directory where plotting_paper.py is located
    SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
    
    # Paths (adjust if needed)
    # WiFi 8 D-MLO Thr. Mode (AP @ 1 link)
    wifi8_dmlo_thro_glob = os.path.join(
    SCRIPT_DIR,
    'dmlo_mode1/result-logs/wifi-ehr-roaming-results-unsaturated-*-dB.txt'
    )

    # WiFi 8 D-MLO Rel. mode (AP @ 1 link)
    wifi8_dmlo_rel_glob = os.path.join(
    SCRIPT_DIR,
    'dmlo_mode2/result-logs/wifi-ehr-roaming-results-unsaturated-*-dB-reliability.txt'
    )
   
    # Wifi 8 MLO Thr. Mode (AP @ 3 links)
    wifi8_jt_MLO_thro_glob  = os.path.join(
    SCRIPT_DIR,
    'dmlo_mode3/result-logs/wifi-ehr-roaming-results-unsaturated-*-dB.txt'
    )
    
    # WiFi 8 MLO Rel. Mode (AP @ 3 links)
    wifi8_jt_MLO_glob  = os.path.join(
    SCRIPT_DIR,
    'dmlo_mode4/result-logs/wifi-ehr-roaming-results-unsaturated-*-dB-reliability.txt'
    )
    
    # WiFi 7 (EHT / MLO-STR)
    wifi7_glob     = os.path.join(
    SCRIPT_DIR,
    'mlo7/result-logs/wifi-eht-roaming-results-unsaturated-*-dB.txt'
    )

    wifi8_dmlo_thro_files  = glob.glob(wifi8_dmlo_thro_glob)
    wifi8_dmlo_rel_files = glob.glob(wifi8_dmlo_rel_glob)
    wifi7_files     = glob.glob(wifi7_glob)
    wifi8_jt_mlo_files  = glob.glob(wifi8_jt_MLO_glob)
    wifi8_jt_mlo_thro_files = glob.glob(wifi8_jt_MLO_thro_glob)

    if not wifi8_dmlo_thro_files:  print("WARNING: No WiFi 8 D-MLO Thr. Mode files matched.")
    if not wifi8_dmlo_rel_files: print("WARNING: No WiFi 8 D-MLO Rel. Mode files matched.")
    if not wifi7_files:     print("WARNING: No WiFi 7 files matched.")
    if not wifi8_jt_mlo_files:  print("WARNING: No WiFi 8 MLO Rel. Mode files matched.")
    if not wifi8_jt_mlo_thro_files:  print("WARNING: No WiFi 8 MLO Thr. Mode files matched.")

    # -------------- Collect Metrics --------------
    wifi8_dmlo_thro_metrics  = collect_metric_dict(wifi8_dmlo_thro_files,  target_beacons)
    wifi8_dmlo_rel_metrics = collect_metric_dict(wifi8_dmlo_rel_files, target_beacons)
    wifi7_metrics     = collect_metric_dict(wifi7_files,     target_beacons)
    wifi8_jt_mlo_metrics = collect_metric_dict(wifi8_jt_mlo_files, target_beacons)
    wifi8_jt_mlo_thro_metrics = collect_metric_dict(wifi8_jt_mlo_thro_files, target_beacons)
    
    # unify wall-loss keys present in ANY variant
    keys = unified_wall_loss_keys(wifi8_dmlo_rel_metrics,
                               wifi8_dmlo_thro_metrics,
                               wifi7_metrics,
                               wifi8_jt_mlo_metrics)
    print(keys)
    # wanted = ['0', '3', '6', '9']
    wanted = ['0', '3', '6', '9', '12']
    keys = [k for k in keys if k in wanted]

    # -------------- Output directory --------------
    # number of wall-loss points actually plotted
    n_keys = len(keys)

    # -------------- Output directory --------------
    OUT_DIR = os.path.join(
        SCRIPT_DIR,
        'Graphs',
        f'roaming-combined-{n_keys}-data'
    )

    os.makedirs(OUT_DIR, exist_ok=True)
    
    orders = ( 'dmlo_thro', 'dmlo_rel','jt_mlo_thro', 'jt_mlo',  'w7')
    
    # -------------- Generate All Triple Plots --------------
    grouped_three_variant_plot(keys,
                               wifi8_dmlo_rel_metrics, wifi8_dmlo_thro_metrics, wifi7_metrics, wifi8_jt_mlo_metrics, wifi8_jt_mlo_thro_metrics,
                               metric_name='Throughput',
                               ylabel='Throughput (Mbps)',
                               ylim=(0, 20),
                               out_path=os.path.join(OUT_DIR, f'throughput_triple_beacon{target_beacons}'),
                               order=orders)
    
    # orders = ('jt_mlo', 'dmlo_rel', 'dmlo_thro', 'jt_mlo_thro', 'w7')
    grouped_three_variant_plot(keys,
                               wifi8_dmlo_rel_metrics, wifi8_dmlo_thro_metrics, wifi7_metrics, wifi8_jt_mlo_metrics, wifi8_jt_mlo_thro_metrics,
                               metric_name='Reliability',
                               ylabel='Reliability (%)',
                               ylim=(0, 102),
                               out_path=os.path.join(OUT_DIR, f'reliability_triple_beacon{target_beacons}'),
                               order=orders)

    grouped_three_variant_plot(keys,
                               wifi8_dmlo_rel_metrics, wifi8_dmlo_thro_metrics, wifi7_metrics, wifi8_jt_mlo_metrics, wifi8_jt_mlo_thro_metrics,
                               metric_name='CADelay',
                               ylabel='Channel Access Delay (ms)',
                               ylim=(0, 3),
                               out_path=os.path.join(OUT_DIR, f'chDelay_triple_beacon{target_beacons}'),
                               order=orders)

    grouped_three_variant_plot(keys,
                               wifi8_dmlo_rel_metrics, wifi8_dmlo_thro_metrics, wifi7_metrics, wifi8_jt_mlo_metrics, wifi8_jt_mlo_thro_metrics,
                               metric_name='AssocDelay',
                               ylabel='Association Delay (s)',
                               ylim=(0, 20),
                               out_path=os.path.join(OUT_DIR, f'assocDelay_triple_beacon{target_beacons}'),
                               order=orders)

    grouped_three_variant_plot(keys,
                               wifi8_dmlo_rel_metrics, wifi8_dmlo_thro_metrics, wifi7_metrics, wifi8_jt_mlo_metrics, wifi8_jt_mlo_thro_metrics,
                               metric_name='AssocCount',
                               ylabel='(Re)Association Count',
                               ylim=(0, 10),
                               out_path=os.path.join(OUT_DIR, f'assocCount_triple_beacon{target_beacons}'),
                               order=orders)

    print("Completed. Figures in:", OUT_DIR)

if __name__ == "__main__":
    main()
# %%

