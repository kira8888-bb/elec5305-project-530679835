# ELEC5305: MVDR and Wiener Post-Filter Frequency Smoothing

Peinan Gu | SID 530679835 | The University of Sydney

## Research question

Does ERB-band smoothing improve Wiener post-filtering after MVDR beyond
bin-wise processing or ordinary uniform-frequency grouping, and under which
SNR and reverberation conditions?

This project studies an established architecture. Auditory/subband Wiener
processing was already investigated by Gui and Kwan (2005) and Li et al. (2008).
The intended contribution is a controlled comparison and an explanation of
estimate stability versus spectral-detail loss, not a new cochlear model.

[Revised proposal (editable)](proposal/Peinan_Gu_Feedback_Two.md) |
[Revised proposal (PDF)](output/pdf/Peinan_Gu_Feedback_Two.pdf) |
[Feedback changes / 中文修改说明](FEEDBACK_CHANGES_CN.md)

## Status and requirements

Initial executable MATLAB prototype, tested using **MATLAB R2026a Update 4**.
Requires **Signal Processing Toolbox and Audio Toolbox**. Room responses use
the established `acousticRoomResponse` image-source simulator (introduced in
R2025a). For R2026b, MathWorks documents the optional Room Acoustics Simulation
feature; follow its installation instructions if this function is unavailable.

Phased Array System Toolbox is optional for comparison with `mvdrweights`.
That comparison is explicitly skipped when the toolbox is unavailable.
No toolbox code or course files are redistributed here.

The default demo generates synthetic harmonic test signals. They are not real
speech, and its scores do not establish speech enhancement or intelligibility.
There is no final real-speech benchmark in this package.

[Validation record](results/VALIDATION.md) and
[synthetic example outputs](results/synthetic_demo/) document what has actually
been checked. Do not use this engineering fixture as a speech-quality result.

## Quick start

Open MATLAB, set the current folder to this repository, then run:

```matlab
setup_project;
run_tests;
r = run_demo;
```

Each demo writes a new folder under `results/runs/` containing seven output WAVs,
the reverberant target WAV, `metrics.csv`, `spectrograms.png`, `run.mat` and
`RUN_INFO.txt`. Metrics use unscaled signals. All listening WAVs use one common
gain to avoid clipping; they are not individually peak-normalized.

For real speech, place your permitted WAV files in `data/`:

```matlab
setup_project;
cfg = default_config();
cfg.targetFile = fullfile(pwd,'data','target.wav');
cfg.interfererFile = fullfile(pwd,'data','interferer.wav');
cfg.noiseType = 'competing_speech';
r = run_demo(cfg);
```

The default target needs at least 4 seconds; the competing source needs at least
5 seconds including the target-absent calibration interval. Both are downmixed
and resampled to 16 kHz. A short file raises an error rather than silently looping.
Record sources and permissions as described in [data/README.md](data/README.md).

## Systems

| Method | Purpose |
|---|---|
| `noisy` | Reference-microphone baseline |
| `single_wiener` | Single-channel bin-wise Wiener |
| `das` | Phase-steered delay-and-sum baseline |
| `mvdr` | Loaded MVDR without a post-filter |
| `mvdr_binwise` | MVDR + independent frequency-bin Wiener |
| `mvdr_uniform` | MVDR + uniformly spaced triangular-band Wiener |
| `mvdr_erb` | MVDR + ERB-spaced triangular-band Wiener |

The last three share exactly the same MVDR output and the same precomputed
speech/noise power estimates. Only the frequency-aggregation matrix changes.

## Shared estimation and fair comparison

1. The target is absent for the first second. Noise/interference is present.
   Covariance estimation uses complete frames between 0.3 s and 1 s, avoiding
   the initial propagation transient and frames overlapping target onset.
2. The resulting noise covariance and MVDR weights remain fixed for the clip.
   The estimated beamformer-output noise PSD is `real(w' * Rn * w)`; it excludes
   diagonal loading, which is numerical regularization rather than actual noise.
3. The mixture power is time-smoothed with `alpha = 0.8`; speech power is
   `max(smoothedMixturePower - noisePSD, 0)`. No decision-directed estimate is used.
4. The identical speech/noise arrays are averaged separately by the chosen
   frequency matrix. Compute `xi = speechPower/noisePower`, then `xi/(1+xi)`.
5. Gains are linearly mapped back to bins with partition-of-unity weights and
   clipped to the common range `[0.05, 1]`. No variant-specific temporal filtering
   or parameter tuning is applied.

Uniform and ERB variants use 24 centres from DC to Nyquist, triangular weights
linear in Hz and the same normalized interpolation. ERB centres are equally
spaced on `21.4*log10(1+0.00437*f)`. This is **ERB-inspired smoothing**, not a
gammatone filterbank or a full cochlear model. Equal counts do not guarantee equal
local bandwidth; evaluate 16/24/32-band sensitivity on separate development data.

The calibration assumption is deliberately explicit. A fixed calibration PSD
may track stationary noise poorly if conditions change and may be inaccurate for
competing speech. An adaptive noise estimator/VAD is a later shared extension,
not a feature claimed by this prototype.

## Acoustic and evaluation conventions

The room is 5 x 4 x 3 m. Four microphones have 4 cm spacing. Target, interferer
and array positions are fixed in `config/default_config.m`. Nominal RT60 is
converted to uniform absorption using Sabine's relation; image order is derived
from RT60 and mean free path. Actual broadband Schroeder T20 (extrapolated to
60 dB) is recorded. Nominal RT60 is not presented as a measured result.

Default MVDR steering uses direct-path distances and amplitudes relative to the
reference microphone. This can mismatch the reverberant transfer function.
`cfg.steering='known_rtf'` uses full simulated RIRs as a **privileged diagnostic**;
keep its results separate. Neither setting claims explicit dereverberation.

All signals preserve common sample timing. The metric target is the **desired
reverberant target component at reference microphone 2**, not the anechoic source.
The initial calibration interval is excluded from evaluation; the target tail
is retained. Metrics are:

- `ReferenceErrorSNR_dB = 10*log10(sum(ref.^2)/sum((ref-output).^2))`.
- `DeltaReferenceErrorSNR_dB`: difference from the noisy reference-mic score.
- Zero-mean SI-SDR using the projection of the output onto the reference.
- MATLAB STOI for real speech if available; synthetic tests deliberately store
  `NaN`. STOI with a reverberant reference measures relative preservation and
  is not a claim of absolute human intelligibility.

Reference-error SNR includes residual noise AND target distortion. It is not a
component-separated output noise-power SNR. `score_signals.m` makes this explicit.

## Experiments and variance analysis

Supply a list of different target/interferer recordings:

```matlab
[scores,folder] = run_experiments( ...
    {fullfile(pwd,'data','target.wav')}, ...
    {fullfile(pwd,'data','interferer.wav')});
```

The runner uses 2 interference types x 3 SNRs (-5/0/5 dB) x 2 nominal RT60s
(0.2/0.6 s), with 3 noise seeds per utterance: 36 runs per pair. It requires real
audio and saves every paired observation, configuration, achieved T20 and gain
map. Start with one pair as a pilot, then expand the corpus and speaker coverage.
For competing speech, seeds vary background noise only; multiple competing
utterances are needed to vary that source. Seeds are not independent speakers.

```matlab
cfg = default_config();
[diagnostics,folder] = run_variance_probe(cfg);
```

This stationary-noise probe fixes the target and room and measures gain variance
across five noise realizations at the same time-frequency points. It does not
mislabel temporal gain fluctuations as statistical variance. Lower variance
alone is not better enhancement: compare speech distortion, SI-SDR and spectra.
Paired utterance-level aggregation/confidence intervals and formal real-speech
conclusions remain follow-up work. Angular separation is optional after the main
comparison. Synthetic signals must not be used as evidence for the research claim.

## Repository layout

```text
config/default_config.m       shared scene and estimator settings
code/                         simulation, STFT, MVDR, grouping, metrics, plots
test/run_tests.m              reconstruction, covariance and end-to-end checks
run_demo.m                    one reproducible example
run_experiments.m             controlled real-speech pilot grid
run_variance_probe.m          repeated-noise diagnostic
proposal/                     editable revised proposal
output/pdf/                   revised proposal PDF
docs/                         GitHub Pages entry and publishing notes
results/                      validation record and generated run folders
data/                         audio provenance instructions
```

The four main working sections are:

| Section | Contents |
|---|---|
| [`data/`](data/) | Permitted target/interferer WAV files and provenance records |
| [`test/`](test/) | Reconstruction, gain, MVDR and end-to-end validation |
| [`results/`](results/) | Validation record, generated metrics, figures and listening examples |
| [`code/`](code/) | Core simulation and enhancement functions |

## GitHub and Pages

Upload these files into the root of `elec5305-project-530679835`, preserving the
existing original proposal as history. The prepared Pages entry is `docs/index.md`.
See [docs/GITHUB_UPLOAD_CN.md](docs/GITHUB_UPLOAD_CN.md) for exact upload/publishing
steps. Having this file locally does not mean the remote site has been deployed.

## Literature and implementation sources

The [proposal references](proposal/Peinan_Gu_Feedback_Two.md#7-references)
contain ten relevant papers, including the two specifically identified in the
feedback. Established MATLAB APIs used or targeted for validation:

- [Room impulse response](https://www.mathworks.com/help/audio/ref/acousticroomresponse.html)
- [STFT](https://www.mathworks.com/help/signal/ref/stft.html) and
  [inverse STFT](https://www.mathworks.com/help/signal/ref/istft.html)
- [Standard MVDR solution/example](https://www.mathworks.com/help/phased/ug/rectangular-array-mvdr-beamformer.html)
- [Optional MVDR weight cross-check](https://www.mathworks.com/help/phased/ref/mvdrweights.html)
- [STOI](https://www.mathworks.com/help/audio/ref/stoi.html)

Classical MVDR and Wiener filtering are interpretable baselines. Neural mask and
covariance estimation are discussed in the proposal, not implemented or trained.
