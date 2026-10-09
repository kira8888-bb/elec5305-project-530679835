# ELEC5305 Project Proposal

> **Version note:** This file preserves the original project proposal for submission history. The current feedback-two revision, updated methodology, executable MATLAB implementation, and validation scope are documented in [Peinan_Gu_Feedback_Two.md](Peinan_Gu_Feedback_Two.md) and the repository [README](../README.md).

## Hybrid Multichannel Speech Enhancement Using MVDR Beamforming and Adaptive Cochlear-Domain Wiener Filtering

**Student:** Peinan Gu  
**Student ID:** 530679835  
**GitHub Username:** [kira8888-bb](https://github.com/kira8888-bb)

---

## 1. Student Information

| Item | Details |
|---|---|
| Full Name | Peinan Gu |
| Student ID (SID) | 530679835 |
| GitHub Username | [kira8888-bb](https://github.com/kira8888-bb) |
| GitHub Repository | [elec5305-project-530679835](https://github.com/kira8888-bb/elec5305-project-530679835) |
| GitHub Pages | [Project website](https://kira8888-bb.github.io/elec5305-project-530679835/) |

## 2. Project Overview

Speech recorded in realistic environments is often degraded by background noise, competing sound sources, and room reverberation. Conventional single-channel noise-reduction methods can suppress some forms of noise, but they cannot exploit spatial information when multiple microphones are available.

This project proposes a hybrid multichannel speech-enhancement system combining frequency-domain Minimum Variance Distortionless Response (MVDR) beamforming with an adaptive Wiener post-filter operating on perceptually motivated cochlear frequency bands.

The main research question is:

> **How effectively can a hybrid MVDR beamforming and cochlear-domain adaptive Wiener post-filtering system improve speech enhancement under different noise and reverberation conditions compared with conventional single-channel and spatial filtering methods?**

The system will be implemented primarily in MATLAB and evaluated using controlled simulated multichannel recordings. The project will investigate not only the overall enhancement performance, but also how system behaviour changes with signal-to-noise ratio (SNR), reverberation, and spatial separation between sources.

## 3. Background and Motivation

Speech enhancement is an important signal-processing problem in applications such as teleconferencing, hearing devices, smart speakers, hands-free communication systems, and voice-controlled interfaces. A microphone signal recorded in a practical environment may contain the desired speech together with interfering speakers, environmental noise, and acoustic reflections.

When multiple microphones are available, differences in phase and amplitude between microphone signals provide spatial information about the sound field. Beamforming techniques can exploit this information to enhance sounds arriving from a desired direction while suppressing interference.

MVDR beamforming is a spatial filtering technique that attempts to minimise the output power while maintaining a distortionless response in the direction of the desired source. However, residual noise may remain after beamforming, particularly in highly reverberant environments or when the target and interfering sources have limited spatial separation.

Time-frequency spectral enhancement can therefore be applied after beamforming. Wiener filtering estimates a gain for each time-frequency region according to the estimated ratio between desired-signal and noise power. In this project, conventional frequency-bin Wiener filtering will be compared with a smoothed approach based on cochlear-inspired frequency bands.

The motivation for cochlear-domain processing is that neighbouring frequency components can be grouped into perceptually meaningful bands. This may produce more stable signal and noise estimates than processing each Fourier bin independently, particularly at low SNR.

The proposed system therefore combines spatial and spectral processing rather than relying on either approach individually.

## 4. Proposed Methodology

The project will primarily use MATLAB. A simulated four-channel microphone array will initially be used instead of requiring a physical microphone array. Simulation allows the clean reference signals, source positions, SNR, and reverberation to be controlled accurately.

Clean target speech will be combined with an interfering source and background noise. Acoustic propagation from each source to each microphone will be modelled using impulse responses. The signal received by microphone $m$ can be represented as

$$
x_m[n] = h_{s,m}[n] \ast s[n] + h_{i,m}[n] \ast i[n] + v_m[n]. \tag{1}
$$

where $s[n]$ represents the desired speech, $i[n]$ represents the interfering source, $v_m[n]$ represents background noise, and $h_{s,m}[n]$ and $h_{i,m}[n]$ are the corresponding acoustic impulse responses.

The multichannel signals will then be divided into overlapping frames and transformed into the time-frequency domain using the Short-Time Fourier Transform (STFT). Processing in the STFT domain allows frequency-dependent spatial filters to be applied.

A delay-and-sum beamformer will first be implemented as a basic spatial-processing baseline. MVDR beamforming will then be applied using an estimated spatial covariance matrix and a steering vector corresponding to the known target direction.

The MVDR output will subsequently be processed by an adaptive spectral post-filter. A conventional Wiener filter will first be implemented as a comparison method. The proposed extension will estimate signal and noise power within cochlear-inspired frequency bands.

For cochlear band $b$ and time frame $l$, an a priori SNR estimate $\xi_b(l)$ will be used to calculate the Wiener gain

$$
G_b(l) = \frac{\xi_b(l)}{1 + \xi_b(l)}. \tag{2}
$$

The band-domain gains will then be mapped back onto STFT frequency bins. The enhanced time-domain speech signal will finally be reconstructed using the inverse STFT and overlap-add processing.

The following systems will initially be compared:

1. Unprocessed noisy speech
2. Single-channel Wiener filtering
3. Delay-and-sum beamforming
4. MVDR beamforming
5. MVDR beamforming with adaptive cochlear-domain Wiener post-filtering

Experiments will be conducted under several input SNR conditions, for example

$$
\mathrm{SNR}_{\mathrm{in}} \in \{-5, 0, 5, 10\}\ \mathrm{dB}. \tag{3}
$$

Different levels of reverberation will also be investigated. If time permits, the angular separation between the desired and interfering sources will be varied to examine how spatial separation affects enhancement performance.

Performance will primarily be evaluated using SNR improvement,

$$
\Delta \mathrm{SNR} = \mathrm{SNR}_{\mathrm{out}} - \mathrm{SNR}_{\mathrm{in}}, \tag{4}
$$

together with scale-invariant signal-to-distortion ratio (SI-SDR). Spectrograms and waveform comparisons will also be used to analyse how different processing methods modify the speech signal. Additional perceptual metrics may be investigated if implementation time permits.

## 5. Expected Outcomes

The expected outcome is a working MATLAB prototype capable of processing simulated multichannel microphone recordings and producing an enhanced single-channel speech signal.

It is expected that MVDR beamforming will outperform single-channel processing when sufficient spatial separation exists between the target and interfering sources. The addition of an adaptive Wiener post-filter is expected to further suppress residual noise after spatial filtering.

A major research outcome will be determining whether cochlear-domain smoothing provides a measurable advantage over conventional frequency-bin Wiener filtering, particularly under low-SNR and reverberant conditions.

The final project will provide quantitative comparisons between different enhancement methods rather than relying only on subjective listening. Results will include SNR and SI-SDR measurements, spectrogram comparisons, waveform visualisations, and performance trends across different experimental conditions.

The GitHub repository will contain MATLAB source code, example signals, experimental results, figures, documentation, and instructions for reproducing the experiments.

## 6. Timeline

| Weeks | Task |
|---|---|
| Weeks 1-3 | Literature review, project planning, GitHub setup, and review of fundamental audio signal-processing concepts. |
| Weeks 4-5 | Development of the STFT processing framework, multichannel signal simulation, and room impulse-response processing. |
| Weeks 6-7 | Implementation and testing of noise estimation and Wiener filtering methods. |
| Weeks 8-9 | Implementation and evaluation of delay-and-sum and MVDR beamforming. |
| Weeks 10-11 | Development of the adaptive cochlear-domain Wiener post-filter and controlled experiments under different SNR and reverberation conditions. |
| Week 12 | Performance evaluation, parameter comparison, production of figures, and preparation of audio demonstrations. |
| Week 13 | Final report, video demonstration, code cleanup, documentation, and completion of the GitHub Pages project site. |

## 7. References

1. Y. Ephraim and D. Malah, “Speech Enhancement Using a Minimum Mean-Square Error Short-Time Spectral Amplitude Estimator,” *IEEE Transactions on Acoustics, Speech, and Signal Processing*, vol. 32, no. 6, pp. 1109-1121, 1984.

2. M. Souden, J. Benesty, and S. Affes, “On Optimal Frequency-Domain Multichannel Linear Filtering for Noise Reduction,” *IEEE Transactions on Audio, Speech, and Language Processing*, vol. 18, no. 2, pp. 260-276, 2010.

3. H. Kim, K. Kang, and J. W. Shin, “Factorized MVDR Deep Beamforming for Multi-Channel Speech Enhancement,” *IEEE Signal Processing Letters*, vol. 29, pp. 1898-1902, 2022.

4. M. Kim, S. Cheong, H. Song, and J. W. Shin, “Improved Speech Spatial Covariance Matrix Estimation for Online Multi-Microphone Speech Enhancement,” *Sensors*, vol. 23, no. 1, Art. no. 111, 2023.

5. S. Cheong, M. Kim, and J. W. Shin, “Postfilter for Dual Channel Speech Enhancement Using Coherence and Statistical Model-Based Noise Estimation,” *Sensors*, vol. 24, no. 12, Art. no. 3979, 2024.

---

**ELEC5305 Acoustics, Speech and Signal Processing**  
The University of Sydney
