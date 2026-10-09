# ELEC5305 Project Proposal

## Hybrid Multichannel Speech Enhancement Using MVDR Beamforming: A Controlled Comparison of Wiener Post-Filter Frequency Smoothing

**Student:** Peinan Gu  
**Student ID:** 530679835  
**GitHub Username:** kira8888-bb

## 1. Student Information

| Item | Details |
|---|---|
| Full Name | Peinan Gu |
| Student ID (SID) | 530679835 |
| GitHub Username | kira8888-bb |
| GitHub Repository | https://github.com/kira8888-bb/elec5305-project-530679835 |
| GitHub Pages | https://kira8888-bb.github.io/elec5305-project-530679835/ |

After deployment, the GitHub Pages URL will be opened in a signed-out browser to confirm public access. Until that check passes, the repository README remains the primary public project summary.

## 2. Project Overview

Speech recordings suffer from background noise, competing speakers and room reverberation. This project investigates an established hybrid architecture combining frequency-domain Minimum Variance Distortionless Response (MVDR) beamforming with Wiener post-filtering. It does not claim that adding auditory-band Wiener processing is new.

The main research question is:

> Does ERB-band smoothing provide an advantage beyond conventional frequency-bin or uniformly grouped Wiener post-filtering after MVDR beamforming, and under what input-SNR and reverberation conditions?

A MATLAB simulation will isolate frequency grouping while holding the spatial processing and power-estimation method constant. The intended contribution is a reproducible comparison explaining the trade-off between estimate stability and spectral-detail preservation.

## 3. Background and Motivation

Capon beamforming [1] and multichannel Wiener filtering [2] provide the spatial-filtering foundation. Their combination with post-filtering is established. Gui and Kwan [3] already investigated adaptive Wiener filtering in critical-band gammatone subbands. Li et al. [4] studied microphone-array post-filtering using auditory filtering. These closely related studies motivate replication and comparison rather than an architectural novelty claim.

The ERB scale reflects frequency-dependent auditory-filter bandwidths [5]. Pooling neighbouring frequency bins may reduce estimation variance, but ordinary frequency averaging can also do this. Wider grouping may blur harmonics or over-attenuate speech. Therefore, an ERB advantage must be assessed against both ungrouped and uniform-frequency controls; superiority is not assumed.

Neural mask estimation [7] and learned spatial-covariance estimation [8] place this classical system in a modern context. No state-of-the-art performance claim or neural-network training is planned. The classical approach remains useful because its spatial and spectral operations are interpretable and computationally modest.

## 4. Proposed Methodology

**Controlled simulation.** Fix a four-microphone linear array, room dimensions, target position and interfering-source position. Use an established image-source simulator [6], initially MATLAB acousticRoomResponse. The microphone signals are

$$
x_m[n]=h_{s,m}[n]*s[n]+h_{i,m}[n]*i[n]+v_m[n]. \tag{1}
$$

Test two interference conditions (stationary directional noise and competing speech), three input SNRs {-5, 0, 5} dB, and two nominal RT60 values {0.2, 0.6} s: twelve conditions. Record achieved decay estimates. Use multiple speech utterances and repeated seeds, with identical mixtures across methods. Synthetic signals are reserved for engineering tests.

**Spatial processing.** Apply STFT, delay-and-sum and diagonally loaded MVDR, followed by inverse STFT. Use known direct-path geometry initially; any known full-RIR steering experiment is a separately labelled diagnostic. Cross-check the standard MVDR solution against an established implementation/example and test reconstruction and distortionless constraints before interpreting results.

**Shared estimator.** An explicit target-absent calibration segment estimates interference-plus-noise covariance; the beamformer and noise PSD are then held fixed. At the MVDR output, noise power is w^H R_n w. Recursively smooth mixture power with alpha = 0.8 and estimate speech power by nonnegative subtraction:

$$
Q_{k,l}=\alpha Q_{k,l-1}+(1-\alpha)|Y_{k,l}|^2,\qquad P_{s,k,l}=\max(Q_{k,l}-P_{n,k},0). \tag{2}
$$

This initial estimator is not decision-directed and assumes representative calibration noise. All variants share these estimates, initialization, STFT settings and gain floor. Nonstationary interference exposes this assumption; later estimator changes must apply to every variant.

**Frequency grouping.** Compare identity/bin-wise processing, uniform-Hz bands, and ERB-spaced bands. Both grouped systems use 24 overlapping triangular weights, linear in Hz, covering DC to Nyquist, with identical normalization and interpolation rules. ERB centres are equally spaced on E(f) = 21.4 log10(1 + 0.00437f) [5]. Average speech and noise powers separately within each band, then calculate

$$
\xi_{b,l}=P_{s,b,l}/\max(P_{n,b},\epsilon),\qquad G_{b,l}=\xi_{b,l}/(1+\xi_{b,l}). \tag{3}
$$

Map gains back to STFT bins and apply a common 0.05 floor. This is cochlear-inspired frequency smoothing, not a complete cochlear or gammatone model. Check sensitivity to 16/24/32 bands on development data; equal band counts do not equalize every local bandwidth.

Compare seven systems: unprocessed reference microphone; single-channel Wiener; delay-and-sum; MVDR; and MVDR plus bin-wise, uniform-band or ERB-band Wiener. The last three are the primary comparison.

**Evaluation.** Use the desired reverberant target component at the reference microphone, s_ref, with common timing and no output-specific normalization. Define reference-error SNR and its improvement explicitly:

$$
\mathrm{SNR}_{e}(y)=10\log_{10}\frac{\|s_{ref}\|^2}{\|s_{ref}-y\|^2},\qquad \Delta\mathrm{SNR}_{e}=\mathrm{SNR}_{e}(y)-\mathrm{SNR}_{e}(x_{ref}). \tag{4}
$$

This includes speech distortion, unlike a pure output noise-power ratio. Also report SI-SDR [9] and STOI [10]; with a reverberant reference, STOI describes preservation relative to that reference. Analyse paired utterance-level differences and uncertainty, across-seed gain variance, spectrograms and listening examples. Lower gain variance alone does not imply better speech quality.

## 5. Expected Outcomes

The outcome will be a reproducible MATLAB prototype and evidence showing whether auditory frequency organization adds value beyond generic smoothing. Low-SNR stability benefits and high-SNR detail loss are hypotheses, not promised results. Null or negative ERB findings remain informative.

Deliverables include source code, configurations, quantitative comparisons, figures, permitted audio examples, a report and video. The README and verified GitHub Pages site will explain reproduction, prior work, calibration assumptions and limitations. Angular-separation experiments remain optional.

## 6. Timeline

The original week-based structure is retained as a planned sequence, not a completion record.

| Weeks | Task |
|---|---|
| Weeks 1-3 | Review literature, revise research positioning and verify GitHub Pages. |
| Weeks 4-5 | Reuse room/STFT tools; validate geometry, mixtures and reverberant reference. |
| Weeks 6-7 | Validate MVDR and establish the shared PSD estimator and bin-wise baseline. |
| Weeks 8-9 | Add uniform and ERB grouping; check fairness and development parameters. |
| Weeks 10-11 | Run the twelve-condition paired speech experiments and stability analysis. |
| Week 12 | Interpret scores, distortion, spectrograms and listening examples. |
| Week 13 | Complete report, video, reproducibility documentation and website checks. |

## 7. References

1. J. Capon, "High-resolution frequency-wavenumber spectrum analysis," Proceedings of the IEEE, 57(8), 1408-1418, 1969. https://doi.org/10.1109/PROC.1969.7278

2. M. Souden, J. Benesty, and S. Affes, "On optimal frequency-domain multichannel linear filtering for noise reduction," IEEE Transactions on Audio, Speech, and Language Processing, 18(2), 260-276, 2010. https://doi.org/10.1109/TASL.2009.2025790

3. Y. Gui and H. K. Kwan, "Adaptive subband Wiener filtering for speech enhancement using critical-band gammatone filterbank," IEEE Midwest Symposium on Circuits and Systems, vol. 1, 732-735, 2005. https://doi.org/10.1109/MWSCAS.2005.1594205

4. P. Li, F.-C. Liao, N. Cheng, B. Xu, and W.-J. Liu, "Microphone array post-filter based on auditory filtering," ISCSLP, 374-377, 2008. https://www.isca-archive.org/iscslp_2008/li08c_iscslp.html

5. B. R. Glasberg and B. C. J. Moore, "Derivation of auditory filter shapes from notched-noise data," Hearing Research, 47(1-2), 103-138, 1990. https://doi.org/10.1016/0378-5955(90)90170-T

6. J. B. Allen and D. A. Berkley, "Image method for efficiently simulating small-room acoustics," Journal of the Acoustical Society of America, 65(4), 943-950, 1979. https://doi.org/10.1121/1.382599

7. J. Heymann, L. Drude, and R. Haeb-Umbach, "Neural network based spectral mask estimation for acoustic beamforming," ICASSP, 196-200, 2016. https://groups.uni-paderborn.de/nt/pubs/2016/icassp_2016_heymann_paper.pdf

8. M. Kim, S. Cheong, H. Song, and J. W. Shin, "Improved speech spatial covariance matrix estimation for online multi-microphone speech enhancement," Sensors, 23(1), 111, 2023. https://doi.org/10.3390/s23010111

9. J. Le Roux, S. Wisdom, H. Erdogan, and J. R. Hershey, "SDR - Half-baked or well done?" ICASSP, 626-630, 2019. https://www.merl.com/publications/TR2019-013

10. C. H. Taal, R. C. Hendriks, R. Heusdens, and J. Jensen, "An algorithm for intelligibility prediction of time-frequency weighted noisy speech," IEEE Transactions on Audio, Speech, and Language Processing, 19(7), 2125-2136, 2011. https://doi.org/10.1109/TASL.2011.2114881

---

ELEC5305 Acoustics, Speech and Signal Processing  
The University of Sydney
