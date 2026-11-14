---
title: ELEC5305 - MVDR and Wiener Frequency Smoothing
---

# MVDR Beamforming and Wiener Post-Filter Frequency Smoothing

Peinan Gu | SID 530679835 | ELEC5305, The University of Sydney

## Research question

Does ERB-band smoothing offer a benefit beyond bin-wise or uniformly grouped
Wiener post-filtering after MVDR, and under which SNR and reverberation conditions?

The project studies an established architecture. Its contribution is a controlled
comparison of frequency grouping and its stability/distortion trade-off.

[GitHub repository](https://github.com/kira8888-bb/elec5305-project-530679835) · [Reproduce the experiment](https://github.com/kira8888-bb/elec5305-project-530679835#reproduce-the-four-recording-study) · [Source recordings](https://github.com/kira8888-bb/elec5305-project-530679835/tree/main/data)

## Methods

Four microphones, fixed source/array geometry and established room simulation.
Seven systems are compared: noisy input, single-channel Wiener, delay-and-sum,
MVDR, and MVDR with bin-wise, uniform-band or ERB-band Wiener post-filtering.
The three post-filters share one PSD estimator and one MVDR output.

## Four-recording comparison

The MATLAB study uses six non-overlapping excerpts from each of four recordings
as source signals for a simulated four-microphone array. Recordings 1 and 2
contain female speech. Recordings 3 and 4 contain male speech. Each pair was
tested separately, so voice group and recording pair coincide. The study compares two
interference conditions, three input SNRs (-5/0/5 dB), and two nominal RT60 values
(0.2/0.6 s). The target is reverberant target speech at the reference microphone.
The score tables pair the methods on identical mixtures and average the three
simulation seeds within each excerpt.

Both recording pairs showed higher mean SI-SDR for ERB than uniform grouping
in stationary noise, with differences of 0.71 to 1.75 dB for the two pairs
combined. For competing speech the differences depended more on the recording
pair. In high-reverberation competing speech at −5 dB, both pairs showed a trade-off
between interference suppression and target error relative to bin-wise Wiener.

- [Four-recording comparison and input sensitivity](https://github.com/kira8888-bb/elec5305-project-530679835/tree/main/results/recording_replication)
- [Original paired experiment](https://github.com/kira8888-bb/elec5305-project-530679835/tree/main/results/recording_study)
- [MATLAB study runner](https://github.com/kira8888-bb/elec5305-project-530679835/blob/main/run_recording_study.m)

## Listening examples

Both examples use competing speech at −5 dB input SNR and nominal RT60 0.6 s.
Within each example, all clips use the same playback gain.

- Female-voice pair · [Noisy input](https://raw.githubusercontent.com/kira8888-bb/elec5305-project-530679835/main/results/recording_study/listening_example/noisy.wav) · [Bin-wise Wiener](https://raw.githubusercontent.com/kira8888-bb/elec5305-project-530679835/main/results/recording_study/listening_example/mvdr_binwise.wav) · [ERB Wiener](https://raw.githubusercontent.com/kira8888-bb/elec5305-project-530679835/main/results/recording_study/listening_example/mvdr_erb.wav) · [All outputs](https://github.com/kira8888-bb/elec5305-project-530679835/tree/main/results/recording_study/listening_example)
- Male-voice pair · [Noisy input](https://raw.githubusercontent.com/kira8888-bb/elec5305-project-530679835/main/results/recording_replication/listening_example/noisy.wav) · [Bin-wise Wiener](https://raw.githubusercontent.com/kira8888-bb/elec5305-project-530679835/main/results/recording_replication/listening_example/mvdr_binwise.wav) · [ERB Wiener](https://raw.githubusercontent.com/kira8888-bb/elec5305-project-530679835/main/results/recording_replication/listening_example/mvdr_erb.wav) · [All outputs](https://github.com/kira8888-bb/elec5305-project-530679835/tree/main/results/recording_replication/listening_example)

## References and validation

- [Research references](https://github.com/kira8888-bb/elec5305-project-530679835/blob/main/docs/references.md)
- [Engineering validation](https://github.com/kira8888-bb/elec5305-project-530679835/blob/main/results/VALIDATION.md)
