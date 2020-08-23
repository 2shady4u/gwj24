The AudioEngine provided in this template

It's undocumented but the most important lines are:

```python

    AudioEngine.reset()
    # with audio track the string to the audio. Might be worth investigating loading this as a resource
    # at some point when and if audio engine gets expanded.
    AudioEngine.play_sound(audio_track)

```

