import ddf.minim.*;

Minim minim;
AudioInput in;
AudioRecorder recorder;
AudioSample recordedSample;

boolean isRecording = false;
boolean isProcessing = false;
boolean isPlaying = false;
boolean removeText = false;

int recordingTimeout = 600; // Timeout in frames (adjust as needed)
int recordingTimer = 0; // Recording timer
int processingTimer = 0; // Processing timer
int playbackTimeout = 600; // Timeout for playback (adjust as needed)
int playbackTimer = 0; // Playback timer

void setup() {
  size(800, 400);
  minim = new Minim(this);

  // Get audio input from the microphone
  in = minim.getLineIn(Minim.MONO, width, 44100, 16);
}

void draw() {
  background(0);

  if (isPlaying) {
    // Display playback text
    fill(255);
    textAlign(CENTER, CENTER);
    text("Playing...", width / 2, height / 2);

    // Check if playback timeout has been reached
    if (playbackTimer >= playbackTimeout) {
      // Playback is complete, reset the timer and return to recording screen
      playbackTimer = 0;
      isPlaying = false;
      removeText = false;
    } else {
      playbackTimer++;
    }
  } else if (isProcessing) {
    // Display processing bar while processing the recorded data
    processingTimer++;
    float barWidth = map(processingTimer, 0, 300, 0, width);
    fill(0, 255, 0); // Green color for the bar
    rect(0, height / 2 - 10, barWidth, 20);

    if (processingTimer >= 300) {
      // Processing is complete, reset the timer
      processingTimer = 0;
      isProcessing = false;

      // Start playback of the recorded audio
      recordedSample.trigger();
      isPlaying = true;

      // Remove the "Press 'r' to record" text
      removeText = true;
    }
  } else {
    // Display text based on recording status
    fill(255);
    textAlign(LEFT, TOP);
    if (!removeText) {
      String recordText = "";
      if (isRecording) {
        recordText = "Recording...";
        recordingTimer = 0; // Reset the timer if sound is being recorded
      } else if (!isRecording) {
        recordingTimer++;
        if (recordingTimer < recordingTimeout) {
          recordText = "Press 'r' to record";
        } else {
          recordText = "Try again";
          recordingTimer = 0; // Reset the timer and return to the main screen
        }
      }
      text(recordText, 10, 10); // Display text in the top-left corner
    }
  }
}

void keyPressed() {
  if (key == 'r' || key == 'R') {
    // Start or stop recording
    if (!isRecording && !isPlaying) {
      // Start a new recording
      recorder = minim.createRecorder(in, "myRecording.wav");
      recorder.beginRecord();
      isRecording = true;
      println("Recording started.");
    } else if (isRecording && !isPlaying) {
      // Stop and save the recording
      recorder.endRecord();
      recorder.save();
      recorder = null; // Dispose of the recorder instance
      isRecording = false;
      println("Recording finished.");

      // Load the recorded audio for processing and playback
      recordedSample = minim.loadSample("myRecording.wav");
      isProcessing = true;
    }
  }
}

void stop() {
  // Close Minim audio resources when the sketch is stopped
  if (isRecording) {
    recorder.endRecord();
    recorder.save();
    recorder = null; // Dispose of the recorder instance
  }
  if (isPlaying) {
    recordedSample.close();
  }
  minim.stop();
  super.stop();
}
