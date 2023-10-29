import ddf.minim.*;
import controlP5.*;

Minim minim;
AudioPlayer player;

ArrayList<Particle> particles;

ControlP5 cp5;
Slider slider;

float borderSize = 20; // Adjust the size of the border

void setup() {
  size(800, 400);
  background(255); // Set background to white
  ellipseMode(CENTER);

  minim = new Minim(this);
  player = minim.loadFile("myRecording.wav"); // Replace with your audio file path
  player.play();

  particles = new ArrayList<Particle>();
  particles.add(new Particle());

  cp5 = new ControlP5(this);
  slider = cp5.addSlider("particleCount")
              .setPosition(borderSize, height - borderSize - 20) // Align slider to the outer black border line
              .setRange(2, 50)
              .setValue(1)
              .setWidth(200)
              .setColorForeground(color(0)) // Set the slider foreground color to black
              .setColorBackground(color(255)) // Set the slider background color to white
              .setColorCaptionLabel(color(0)) // Set the font color to black
              .setColorValueLabel(color(0)); // Set the value label color to black
}

void draw() {
  background(255); // Clear the background to white
  noFill();
  stroke(0); // Set stroke color to black

  // Draw the thicker outer border line
  rect(borderSize, borderSize, width - 2 * borderSize, height - 2 * borderSize);

  for (int i = 0; i < particles.size(); i++) {
    Particle p1 = particles.get(i);
    for (int j = i + 1; j < particles.size(); j++) {
      Particle p2 = particles.get(j);
      p1.sound(p2);
      float d = dist(p1.x, p1.y, p2.x, p2.y);
      // Draw a black line if particles are within a certain distance
      if (d < 200) {
        stroke(0, 50); // Adjust line opacity
        line(p1.x, p1.y, p2.x, p2.y);
      }
    }
    p1.update();
    p1.show();
  }

  int newLength = int(slider.getValue());

  while (particles.size() > newLength) {
    Particle removed = particles.remove(particles.size() - 1);
    removed.stop();
  }

  while (particles.size() < newLength) {
    particles.add(new Particle());
  }
  
  cp5.show(); // Show ControlP5 elements to make the slider movable
}

void particleCount(float value) {
  // This function is called when the slider value changes
}

class Particle {
  float x, y;
  float radius;
  PVector velocity;
  boolean audioOn;
  int audioFrame;

  Particle() {
    // Initialize particles inside the border area
    x = random(borderSize, width - borderSize);
    y = random(borderSize, height - borderSize);
    radius = 10;
    velocity = PVector.random2D();
    velocity.mult(5);
    audioOn = false;
    audioFrame = 0;
  }

  void sound(Particle other) {
    float d = dist(x, y, other.x, other.y);

    if (d < 200 && !audioOn) {
      player.rewind();
      player.play();
      audioOn = true;
      audioFrame = frameCount;
    } else if (audioOn && frameCount - audioFrame > 60) {
      player.pause();
      audioOn = false;
    }
  }

  void update() {
    // Make particles roam inside and around the border
    x += velocity.x;
    y += velocity.y;

    if (x < borderSize || x > width - borderSize || y < borderSize || y > height - borderSize) {
      // If a particle goes out of bounds, wrap it back inside the border
      x = constrain(x, borderSize, width - borderSize);
      y = constrain(y, borderSize, height - borderSize);
      // Reverse the particle's velocity to keep it inside
      velocity.mult(-1);
    }
  }

  void show() {
    fill(0); // Set fill color to black
    ellipse(x, y, radius * 2, radius * 2);
  }

  void stop() {
    // No need to stop audio here since it's managed within the `sound` function
  }
}
