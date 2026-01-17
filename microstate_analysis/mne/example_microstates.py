
import numpy as np
import mne
from microstate_methods import segment_microstates, smooth_segmentation, calculate_statistics

def create_dummy_data():
    """Create dummy MNE Raw data with structured activity."""
    sfreq = 100
    n_times = 2000 # 20 seconds
    times = np.arange(n_times) / sfreq
    n_ch = 30

    # Create random topographic maps (states)
    rng = np.random.RandomState(42)
    maps = rng.randn(4, n_ch)
    maps /= np.linalg.norm(maps, axis=1, keepdims=True)

    # Create activation sequence
    activations = np.zeros((4, n_times))
    # State 0 active for 0-5s
    activations[0, 0:500] = np.sin(2*np.pi*10*times[0:500])
    # State 1 active for 5-10s
    activations[1, 500:1000] = np.sin(2*np.pi*10*times[500:1000])
    # ...
    activations[2, 1000:1500] = np.sin(2*np.pi*10*times[1000:1500])
    activations[3, 1500:2000] = np.sin(2*np.pi*10*times[1500:2000])

    # Generate data
    data = maps.T @ activations
    # Add noise
    data += 0.1 * rng.randn(n_ch, n_times)

    info = mne.create_info(ch_names=[str(i) for i in range(n_ch)], sfreq=sfreq, ch_types='eeg')
    raw = mne.io.RawArray(data, info)
    return raw

def main():
    print("Creating dummy data...")
    raw = create_dummy_data()

    print("Running Microstate Analysis...")
    try:
        maps, segmentation, gev = segment_microstates(raw, n_states=4, random_state=42)
        print("Analysis complete.")
        print(f"Maps shape: {maps.shape}")
        print(f"Segmentation shape: {segmentation.shape}")
        print(f"GEV: {gev:.4f}")

        # Check if GEV is reasonable (>0.5 for clean data)
        if gev > 0.5:
            print("GEV is good.")
        else:
            print("GEV is low.")

        print("\nStatistics (Raw):")
        stats = calculate_statistics(segmentation, sfreq=raw.info['sfreq'])
        for k in range(4):
            print(f"State {k+1}: Dur={stats['duration'][k]:.1f}ms, Occ={stats['occurrence'][k]:.1f}/s, Cov={stats['coverage'][k]*100:.1f}%")

        print("\nSmoothing...")
        smoothed = smooth_segmentation(segmentation, min_duration=3) # 3 samples = 30ms at 100Hz
        stats_smoothed = calculate_statistics(smoothed, sfreq=raw.info['sfreq'])

        print("Statistics (Smoothed):")
        for k in range(4):
            print(f"State {k+1}: Dur={stats_smoothed['duration'][k]:.1f}ms, Occ={stats_smoothed['occurrence'][k]:.1f}/s, Cov={stats_smoothed['coverage'][k]*100:.1f}%")

    except Exception as e:
        print(f"Analysis failed: {e}")
        raise

if __name__ == "__main__":
    main()
