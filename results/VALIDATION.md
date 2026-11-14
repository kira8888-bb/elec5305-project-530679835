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

Run `run_demo` to regenerate these outputs locally. Synthetic inputs produce
`NaN` STOI scores.

## Real-recording experiment

The [original pair](recording_study/) and the [four-recording comparison](recording_replication/)
report the subsequent speech experiments. MATLAB R2026a Update 4 passed
`setup_project; run_tests` after the follow-up. Component checks verified
that the filtered target and interference reconstruct the mixture output.
