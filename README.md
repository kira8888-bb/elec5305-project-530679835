# ELEC5305 — MVDR and Wiener Post-Filter Frequency Smoothing

Peinan Gu · The University of Sydney

This project compares bin-wise, uniform-band and ERB-band Wiener post-filters
after the same MVDR beamformer. It tests how input SNR, reverberation and
interference affect the balance between noise suppression and speech preservation.

[Project website](https://kira8888-bb.github.io/elec5305-project-530679835/) ·
[Results](results/) · [Source recordings](data/) · [References](docs/references.md)

## Findings

The study uses four real speech recordings as sources for a simulated
four-microphone array. Recordings 1 and 2 form the female-voice pair, and
Recordings 3 and 4 form the male-voice pair. Six windows per recording, 12
acoustic conditions and three seeds per target window yield 864 mixtures.
Voice group and recording pair coincide in this design.

In stationary noise, ERB improved mean SI-SDR over uniform grouping by
0.71–1.75 dB across the six conditions, averaging both recording pairs. In
competing speech, the difference depended more on the recording pair. At
−5 dB in the higher-reverberation room, ERB suppressed more interference
than bin-wise Wiener and increased target error on both pairs.

[Four-recording comparison and sensitivity analysis](results/recording_replication/) ·
[Condition-level comparison CSV](results/recording_replication/comparison_with_original.csv)

## Run the demo

Use MATLAB R2026a Update 4 with Signal Processing Toolbox and Audio Toolbox.
The room simulator requires `acousticRoomResponse`. On releases where it
requires the Room Acoustics Simulation feature, install that feature.
The optional MVDR toolbox comparison uses Phased Array System Toolbox.

From the repository root, run the tests and demo:

```matlab
setup_project
run_tests
run_demo
```

The default demo is a synthetic engineering check. It writes audio, metrics
and spectrograms to a new folder under `results/runs/`.
[Validation record](results/VALIDATION.md)

## Reproduce the four-recording study

Run these commands from the repository root. MATLAB must support M4A decoding.
If the system cannot decode M4A, convert the original recordings to PCM WAV
at 48 kHz and update the paths. The runner uses MATLAB STOI.

```matlab
setup_project
firstPair = run_recording_study({"data/recordings/Recording1.m4a", ...
    "data/recordings/Recording2.m4a"});
secondPair = run_recording_study({"data/recordings/Recording 3.m4a", ...
    "data/recordings/Recording4.m4a"}, [3 4]);

firstSummary = fullfile(firstPair, "summary");
secondSummary = fullfile(secondPair, "summary");
summarize_recording_study(firstPair, firstSummary);
summarize_recording_study(secondPair, secondSummary);
compare_recording_studies(firstSummary, secondSummary);
```

The runner writes scores and listening examples to a new experiment folder under
`results/experiments/`. Each example uses a common playback gain across its WAVs.

## Methods

The seven outputs are the noisy reference microphone, single-channel Wiener,
delay-and-sum, MVDR, and MVDR followed by bin-wise, uniform-band or ERB-band
Wiener filtering. The three MVDR post-filters share the same beamformer output
and the same speech and noise power estimates.

The array uses four microphones spaced 4 cm apart in a 5 × 4 × 3 m shoebox room.
The simulator tests stationary directional noise and competing speech at
−5, 0 and +5 dB input SNR and nominal RT60 values of 0.2 and 0.6 s.
The published runs use image-source orders 24 and 36 with measured
broadband T20 extrapolations of 0.1888 and 0.5662 s.

MVDR uses direct-path steering and estimates noise covariance from complete
STFT frames between 0.3 and 1 s while the target is absent. Beamformer weights
and the resulting noise PSD are fixed over each clip. The Wiener estimator
smooths mixture power with `alpha = 0.8` and subtracts the noise PSD, flooring
the speech estimate at zero. The two grouped variants average PSDs with
24 triangular bands, then linearly interpolate the Wiener gains back to the
STFT bins. The gain floor is 0.05 for all variants.

The evaluation uses the isolated reverberant target at reference microphone 2.
The calibration interval is excluded and the reverberation tail is included.
The results report reference-error SNR improvement, SI-SDR and STOI. The
component analysis applies the mixture-derived weights and gains to the
simulated target and interference to measure their contributions to output
error. The study averages the three seeds within each excerpt before
comparing methods. [Analysis and experimental design](results/recording_replication/)

## Repository layout

| Path | Contents |
|---|---|
| [`code/`](code/) and [`config/`](config/) | Simulation, beamforming, post-filters and default settings |
| [`data/`](data/) | Original recordings and voice labels |
| [`test/`](test/) | STFT reconstruction, MVDR and integration tests |
| [`results/`](results/) | Published analysis, CSVs, figures and audio examples |
| [`docs/`](docs/) | GitHub Pages source and references |
