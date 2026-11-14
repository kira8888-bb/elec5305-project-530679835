# Source recordings

The project author supplied these recordings and identified the voice groups.
Files are listed in the order expected by `run_recording_study`.

| ID | Original audio | Voice | Experiment |
|---|---|---|---|
| 1 | [Recording1.m4a](recordings/Recording1.m4a) | Female | Original pair |
| 2 | [Recording2.m4a](recordings/Recording2.m4a) | Female | Original pair |
| 3 | [Recording 3.m4a](recordings/Recording%203.m4a) | Male | Follow-up pair |
| 4 | [Recording4.m4a](recordings/Recording4.m4a) | Male | Follow-up pair |

The runner reads each original file, averages its two channels to mono and
resamples to 16 kHz before simulation. The [original input checks](../results/recording_study/inputs.csv)
and [follow-up input checks](../results/recording_replication/inputs.csv) list
the excerpt times and levels. The default demo uses synthetic harmonic inputs
to check implementation behaviour.
