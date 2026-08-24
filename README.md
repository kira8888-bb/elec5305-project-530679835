# elec5305-project-530679835
ELEC5305 Project: Hybrid Multichannel Speech Enhancement using MVDR Beamforming and Adaptive Wiener Filtering
# ELEC5305 Project

## Hybrid Multichannel Speech Enhancement Using MVDR Beamforming and Adaptive Cochlear-Domain Wiener Filtering

**Student:** Peinan Gu
**Course:** ELEC5305 Acoustics, Speech and Signal Processing
**University:** The University of Sydney

## Project Overview

Speech recorded in realistic environments is often degraded by background noise, interfering sound sources, and room reverberation.

This project investigates a hybrid multichannel speech enhancement system that combines **Minimum Variance Distortionless Response (MVDR) beamforming** with an **adaptive cochlear-domain Wiener post-filter**.

The aim is to determine whether combining spatial filtering and adaptive time-frequency filtering can improve speech enhancement compared with conventional single-channel and beamforming approaches.

## Research Question

**How effectively can a hybrid MVDR beamforming and cochlear-domain adaptive Wiener post-filtering system improve speech enhancement under different noise and reverberation conditions compared with conventional single-channel and spatial filtering methods?**

## Proposed Methods

The project will primarily be implemented in **MATLAB** and will include:

* Short-Time Fourier Transform (STFT) analysis
* Simulated multichannel microphone signals
* Room impulse response and reverberation modelling
* Delay-and-sum beamforming
* MVDR beamforming
* Wiener filtering
* Cochlear-domain adaptive post-filtering
* Inverse STFT and overlap-add reconstruction

The performance of different methods will be compared under multiple signal-to-noise ratio (SNR) and reverberation conditions.

## Evaluation

The planned evaluation will include:

* SNR improvement
* Scale-Invariant Signal-to-Distortion Ratio (SI-SDR)
* Spectrogram comparison
* Waveform comparison
* Comparison between baseline and proposed enhancement methods

## Project Status

This project is currently in the **proposal and initial development stage**.

The repository will be updated throughout Semester 2, 2026 with MATLAB source code, experimental results, figures, documentation, and project demonstrations.

## Repository Structure

```text
elec5305-project-530679835/
├── README.md
├── proposal/
├── src/
├── data/
├── results/
└── docs/
```

## Proposal

The ELEC5305 Project Proposal will be available in the `proposal` folder.

## References

Relevant academic references and detailed methodology are provided in the project proposal and will be expanded throughout the project.
