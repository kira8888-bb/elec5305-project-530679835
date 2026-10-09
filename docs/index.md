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

## Repository sections

### [Data](https://github.com/kira8888-bb/elec5305-project-530679835/tree/main/data)

Licensed speech inputs and source/provenance notes. Audio is not bundled unless
its redistribution permission is recorded.

### [Test](https://github.com/kira8888-bb/elec5305-project-530679835/tree/main/test)

STFT reconstruction, filterbank, MVDR constraint and synthetic integration tests.

### [Results](https://github.com/kira8888-bb/elec5305-project-530679835/tree/main/results)

Validation records, metric tables, spectrograms and permitted listening examples.
Synthetic examples are labelled as engineering checks, not research conclusions.

### [Code](https://github.com/kira8888-bb/elec5305-project-530679835/tree/main/code)

Room simulation, beamforming, shared PSD estimation, frequency grouping and metrics.

## Methods

Four microphones, fixed source/array geometry and established room simulation.
Seven systems are compared: noisy input, single-channel Wiener, delay-and-sum,
MVDR, and MVDR with bin-wise, uniform-band or ERB-band Wiener post-filtering.
The three post-filters share one PSD estimator and one MVDR output.

## Planned evaluation

Two interference conditions, three SNRs (-5/0/5 dB), and two nominal RT60 values
(0.2/0.6 s). The target is reverberant target speech at the reference microphone.
Metrics include reference-error SNR improvement, SI-SDR and STOI, interpreted
alongside across-seed gain stability, speech distortion, spectra and listening.

## Current status

Revised proposal and initial MATLAB code. Synthetic engineering validation is
included; real-speech benchmark conclusions are not yet available.

- [Code and reproduction instructions](https://github.com/kira8888-bb/elec5305-project-530679835)
- [Editable proposal and ten references](https://github.com/kira8888-bb/elec5305-project-530679835/blob/main/proposal/Peinan_Gu_Feedback_Two.md)
- [Revised proposal PDF](https://github.com/kira8888-bb/elec5305-project-530679835/blob/main/output/pdf/Peinan_Gu_Feedback_Two.pdf)
- [Changes responding to feedback](https://github.com/kira8888-bb/elec5305-project-530679835/blob/main/FEEDBACK_CHANGES_CN.md)

Report, video and real-speech results will be added when completed.
