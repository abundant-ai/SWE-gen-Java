In the WebRTC client API, configuring media track constraints via the builder DSL currently fails to compile for video constraints. For example:

```kotlin
client.createVideoTrack {
    width = 100
    height = 100
}
```

This should compile and apply the provided `MediaTrackConstraints` to the underlying getUserMedia request, but it fails because the properties on `WebRtcMedia.VideoTrackConstraints` (and similarly the audio constraints when configured via the DSL) are not mutable in a way that supports assignment inside the builder block.

Fix the WebRTC client so that `WebRtcClient.createVideoTrack { ... }` and `WebRtcClient.createAudioTrack { ... }` both accept a configuration lambda where constraint fields can be assigned (e.g., `width`, `height`, `frameRate`, `facingMode`, `aspectRatio` for video; `autoGainControl`, `echoCancellation`, `noiseSuppression`, `latency`, `channelCount`, `sampleRate`, `volume` for audio).

The overloads that accept an explicit constraints instance must also continue to work:

```kotlin
val constraints = WebRtcMedia.VideoTrackConstraints(height = 100)
client.createVideoTrack(constraints)

val audioConstraints = WebRtcMedia.AudioTrackConstraints(echoCancellation = true)
client.createAudioTrack(audioConstraints)
```

When these APIs are invoked in an environment without any available media devices (e.g., headless browsers), the call should fail with a DOM `NotFoundError` (as a DOMException name), not with a compilation error or a different runtime failure caused by incorrect constraint handling. The primary goal is to make the constraints DSL compile and ensure the constraints are properly propagated to the underlying WebRTC/JS media APIs.