# Engineering validation record

Validated on 9 October 2026 using MATLAB R2026a Update 4, Signal Processing
Toolbox and Audio Toolbox. These checks establish implementation consistency,
not the project's research conclusions.

## Automated checks (`setup_project; run_tests`)

| Check | Observed result |
|---|---|
| Four-channel STFT/ISTFT round trip | Relative error 2.0812e-16 |
| MVDR versus independent constrained KKT solution | Weight error 1.4752e-16 |
| Distortionless response in synthetic integration | Maximum error 1.1977e-14 |
| Nonnegative band matrices, unit row sums, unity interpolation | Passed |
| Constant speech/noise power ratio and common gain floor | Passed for all three variants |
| Input SNR calibration, finite output, common signal length | Passed |
| Synthetic STOI safeguard | Passed: all synthetic STOI scores are NaN |
| MathWorks `mvdrweights` comparison | Not run: Phased Array System Toolbox unavailable |

The quick integration test deliberately uses a low image-source order to finish
quickly. It is an engineering fixture, not a reverberation-performance experiment.

## Full default synthetic demo

`run_demo` also completed with the default automatic image-source order, nominal
RT60 = 0.2 s and input SNR = -5 dB. The measured broadband decay estimate was
0.1888 s. Seven output signals, a target reference, a metric table and a
spectrogram figure were generated successfully.

The [synthetic_demo](synthetic_demo/) folder includes the small reproducible
outputs from that run. All WAV files use one common scale. The run's STOI values
are deliberately blank/NaN because the harmonic fixture is not speech.
The metric values must not be presented as evidence for an ERB advantage.

## Not yet established

- A completed licensed real-speech corpus benchmark across the full grid.
- Paired utterance-level confidence intervals or speaker generalization.
- Perceptual preference or human intelligibility improvements.
- Equivalence to an installed established MVDR toolbox implementation.
- A published, accessible GitHub Pages deployment.

See the root README and FEEDBACK_CHANGES_CN.md for the model assumptions and
remaining research work. Do not replace these limitations with success claims
when uploading the initial repository.
