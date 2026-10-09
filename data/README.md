# Audio inputs

No third-party speech recordings are included. Place permitted target/interferer
WAVs here. Record dataset, speaker/utterance IDs, source URL, permission/license,
download date and development/test split before experiments. Do not tune on the
test utterances. Do not redistribute course recordings without permission.

The default demo uses deterministic synthetic harmonic signals solely to check
the pipeline. These do not represent a speech dataset. For a real-speech pilot,
the default target file needs 4 seconds and the interferer needs 5 seconds.

The code checks duration and resamples to 16 kHz, but it cannot verify that a
supplied WAV contains speech or that you have permission to publish it.
