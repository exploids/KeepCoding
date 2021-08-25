import processing.sound.*;

/**
 * Ein Modul, bei dem Formen so angeordnet werden müssen,
 * dass alle im Handbuch beschriebenen Anforderungen erfüllt werden.
 *
 * @author Luca Selinski
 */
class ArrangeShapes extends Game {
  /**
   * Die Anzahl an Formen, die auf dem Modul platziert werden.
   */
  final int THING_COUNT = 10;

  /**
   * Die Seitenlänge von Quadraten.
   * Die Größen aller anderen Formen basieren ebenfalls auf dieser Größe.
   */
  final float SQUARE_SIZE = 24;

  /**
   * Der Mindestabstand, den Formen zu Beginn voneinander haben müssen.
   */
  final float GENERATION_SPACE = 4;

  /**
   * Der Farbwert für lila Formen.
   */
  final color PURPLE = #bc4a9b;

  /**
   * Der Farbwert für gelbe Formen.
   */
  final color YELLOW = #ffd541;

  /**
   * Der Farbwert für grüne Formen.
   */
  final color GREEN = #5daf8d;

  /**
   * Der Farbwert für rote Formen.
   */
  final color RED = #df3e23;

  /**
   * Die Dauer der Animation beim Lösen des Moduls in Millisekunden.
   */
  final int ANIMATION_DURATION = 500;

  /**
   * Die Dauer der Explosionsanimationen.
   */
  final int EXPLOSION_DURATION = 500;

  /**
   * Der Durchmesser der Explosionen.
   */
  final float EXPLOSION_DIAMETER = 140;

  /**
   * Das Detaillevel von Kreisen.
   */
  final int CIRCLE_VERTICES = 16;

  /**
   * Der Dateipfad, unter dem sich alle Ressourcen des Moduls befinden.
   */
  final String PREFIX = "ArrangeShapes/";

  /**
   * Die Konstante für die x-Achse.
   */
  final int X = 0;

  /**
   * Die Konstante für die y-Achse.
   */
  final int Y = 1;

  /**
   * Die Konstante das Fehlen eines Wertes.
   */
  final int NONE = -1;

  /**
   * Die Konstante, die ein Rechteck, welches kein Quadrat ist, repräsentiert.
   */
  final int SHAPE_RECTANGLE = 0;

  /**
   * Die Konstante, die ein Quadrat repräsentiert.
   */
  final int SHAPE_SQUARE = 1;

  /**
   * Die Konstante, die ein Dreieck repräsentiert.
   */
  final int SHAPE_TRIANGLE = 2;

  /**
   * Die Konstante, die einen Kreis repräsentiert.
   */
  final int SHAPE_CIRCLE = 3;

  /**
   * Ein Array aller vorhandenen Farben.
   */
  final color[] COLORS = { PURPLE, YELLOW, GREEN, RED };

  /**
   * Die x-Koordinate der linken inneren Kante des virtuellen Bildschirms.
   */
  final int INNER_MIN_X = 60;

  /**
   * Die y-Koordinate der oberen inneren Kante des virtuellen Bildschirms.
   */
  final int INNER_MIN_Y = 68;

  /**
   * Die x-Koordinate der rechten inneren Kante des virtuellen Bildschirms.
   */
  final int INNER_MAX_X = 339;

  /**
   * Die y-Koordinate der unteren inneren Kante des virtuellen Bildschirms.
   */
  final int INNER_MAX_Y = 334;

  /**
   * Die x-Koordinate der linken äußeren Kante des virtuellen Bildschirms.
   */
  final int OUTER_MIN_X = 55;

  /**
   * Die y-Koordinate der oberen oberen Kante des virtuellen Bildschirms.
   */
  final int OUTER_MIN_Y = 62;

  /**
   * Die x-Koordinate der rechten äußeren Kante des virtuellen Bildschirms.
   */
  final int OUTER_MAX_X = 355;

  /**
   * Die y-Koordinate der unteren äußeren Kante des virtuellen Bildschirms.
   */
  final int OUTER_MAX_Y = 340;

  /**
   * Die äußere Breite des virtuellen Bildschirms.
   */
  final int OUTER_WIDTH = OUTER_MAX_X - OUTER_MIN_X;

  /**
   * Die äußere Höhe des virtuellen Bildschirms.
   */
  final int OUTER_HEIGHT = OUTER_MAX_Y - OUTER_MIN_Y;

  /**
   * Die reguläre Hintergrundfarbe des virtuellen Bildschirms.
   */
  final color REGULAR_BACKGROUND_COLOR = #322b28;

  /**
   * Die Hintergrundfarbe des virtuellen Bildschirms, sobald das Modul gelöst wurde.
   */
  final color SOLVED_BACKGROUND_COLOR = #5daf8d;

  /**
   * Der Sound für das Ziehen eines Objektes.
   *
   * @see http://sfxr.me/#111115tERS842cx1fzVL59biUbdKTdPt5y7ZgnpiyhfgAvhJjtVB9FdCc3EJ4LNjLy32fhNxeGPZNSQ16hXk3i3HjjDzYioHyAKkt5SoKAiMn9rCoKLu8PPu
   */
  SoundFile dragSound;

  /**
   * Der Sound für das Loslassen eines Objektes.
   *
   * @see http://sfxr.me/#34T6PksgCtRnhnhL4FipSMgvdTs6xqy9cV51hE4hXT8utYZinKUcmEraW7maxJFqAprpL7ey8v93zHyaaXoJPyJ8FhN7GeDF7NSpQqZ5cgLMPiWKMJyP45Ajh
   */
  SoundFile dropSound;

  /**
   * Der Sound für das Kollidieren von Objekten.
   *
   * @see http://sfxr.me/#7BMHBGDL2adeXGUejPTtTeJ8gsWdknZVP75kzvxaZzVy4jF7a3Pip4nB3egi61RiYVcVMtLMLLQLM3FsGHG6PcuHQyqVV5SvwBM9P7rVCQnKunJpzy77oWuY3
   */
  SoundFile collideSound;

  /**
   * Das Bild, welches den Rahmen des Moduls darstellt.
   */
  PImage frameImage;

  /**
   * Das Bild, welches mit den virtuellen Bildschirminhalt multipliziert wird.
   */
  PImage filterImage;

  /**
   * Das Bild, welches den Leuchteffekt erzeugt.
   */
  PImage glowImage;

  /**
   * Das Hinweis-Icon.
   */
  PImage endImage;

  /**
   * Die genutzte Schriftart.
   */
  PFont titleFont;

  /**
   * Der Framebuffer, welcher zum Zeichnen von Explosionen genutzt wird.
   */
  PGraphics sourceBuffer;

  /**
   * Der Framebuffer, welcher zum Maskieren des ersten Framebuffers genutzt wird.
   */
  PGraphics maskBuffer;

  /**
   * Die Dimensionen der einzelnen Formen.
   */
  final float[][] shapeExtents;

  /**
   * Die Formen der einzelnen Dinge auf dem Modul.
   */
  int[] thingShapes;

  /**
   * Die Positionen der Dinge auf dem Modul.
   */
  float[][] positions;

  /**
   * Die Farben der Dinge auf dem Modul.
   */
  color[] thingColors;

  /**
   * Die Polygone der Dinge auf dem Modul.
   */
  PShape[] thingPolygons;
  
  /**
   * Der Index der Form, die gerade gezogen wird.
   */
  int dragged = NONE;

  /**
   * Der Abstand entlang der x-Achse, um den die gezogene Form vom Mauszeiger verschoben ist.
   */
  float dragDeltaX;

  /**
   * Der Abstand entlang der y-Achse, um den die gezogene Form vom Mauszeiger verschoben ist.
   */
  float dragDeltaY;

  /**
   * Die x-Koordinate, an der sich die Form vor dem Ziehen befunden hat.
   */
  float dragOriginalX;

  /**
   * Die y-Koordinate, an der sich die Form vor dem Ziehen befunden hat.
   */
  float dragOriginalY;

  /**
   * Welche der Bedingungen erfüllt sind.
   */
  boolean[] conditions;

  /**
   * Der aktuelle Zeitpunkt aller Animationen.
   */
  int animationTime;

  /**
   * Der Startzeitpunkt der Übergangsanimation zum Endbildschirm.
   */
  int animationStart = -ANIMATION_DURATION;

  /**
   * Die x-Koordinate der gezogenen Form, als diese mit einer anderen Form kollidiert ist.
   */
  float collisionX;

  /**
   * Die y-Koordinate der gezogenen Form, als diese mit einer anderen Form kollidiert ist.
   */
  float collisionY;

  /**
   * Der Index der letzten Form, die beim Ziehen mit einer anderen Form kollidiert ist.
   */
  int collided = NONE;

  /**
   * Der Startzeitpunkt der Explosionsanimation.
   */
  int explosionStart = -EXPLOSION_DURATION;

  /**
   * Die x-Koordinate der Explosion.
   */
  float explosionX;

  /**
   * Die y-Koordinate der Explosion.
   */
  float explosionY;

  /**
   * Der Abstand, um den der innere Kreis der Explosion vom äußeren Kreis verschoben ist.
   */
  float explosionOffset;

  /**
   * Der Winkel, um den der innere Kreis der Explosion vom äußeren Kreis verschoben ist.
   */
  float explosionAngle;

  /**
   * Der Startzeitpunkt der Balkenanimation.
   */
  float barStart;

  /**
   * Die Dauer der Balkenanimation.
   */
  float barDuration;

  /**
   * Die Höhe des Balkens.
   */
  float barSize;

  /**
   * Ob der Bildschirm aktuell gedimmt ist.
   */
  boolean dim = true;

  /**
   * Der Zeitpunkt, an dem der Dimmstatus umgeschaltet wird.
   */
  float dimEnd = 0;

  /**
   * Erzeugt eine neue Instanz des Moduls.
   *
   * @param x      der Versatz des Moduls entlang der x-Achse
   * @param x      der Versatz des Moduls entlang der y-Achse
   * @param sketch eine Referenz zum ausführenden PApplet
   */
  ArrangeShapes(int x, int y, PApplet sketch) {
    super(x, y, sketch);
    float shapeArea = pow(SQUARE_SIZE, 2);
    float rectangleWidth = SQUARE_SIZE * 1.5;
    float rectangleHeight = SQUARE_SIZE / 1.5;
    float triangleWidth = sqrt(4 / sqrt(3) * shapeArea);
    float triangleHeight = triangleWidth * sqrt(3) * 0.5;
    float circleDiameter = sqrt(pow(SQUARE_SIZE, 2) / PI) * 2;
    shapeExtents = new float[][] {
      {rectangleWidth, rectangleHeight},
      {SQUARE_SIZE, SQUARE_SIZE},
      {triangleWidth, triangleHeight},
      {circleDiameter, circleDiameter}
    };
    frameImage = loadImage(PREFIX + "frame.png");
    filterImage = loadImage(PREFIX + "filter.png");
    glowImage = loadImage(PREFIX + "glow.png");
    endImage = loadImage(PREFIX + "end.png");
    titleFont = createFont(PREFIX + "GlacialIndifference-Bold.otf", 36);
    dragSound = new SoundFile(sketch, PREFIX + "drag.mp3");
    dropSound = new SoundFile(sketch, PREFIX + "drop.mp3");
    collideSound = new SoundFile(sketch, PREFIX + "collide.mp3");
    sourceBuffer = createGraphics(OUTER_WIDTH, OUTER_HEIGHT);
    maskBuffer = createGraphics(OUTER_WIDTH, OUTER_HEIGHT);
    thingShapes = new int[THING_COUNT];
    positions = new float[THING_COUNT][2];
    thingColors = new color[THING_COUNT];
    thingPolygons = new PShape[THING_COUNT];
    conditions = new boolean[4];
    do {
      generateShapes();
    } while (conditionsAreFulfilled());
  }

  /**
   * Führt einen Schritt der Spiellogik aus.
   */
  void update() {
    animationTime = millis();
    if (dragged != NONE && !solved) {
      move(dragged, getMouseX() + dragDeltaX, getMouseY() + dragDeltaY);
      for (int other = 0; other < THING_COUNT && dragged != NONE; other++) {
        if (other != dragged && thingsCollide(dragged, other)) {
          explosionStart = animationTime;
          collisionX = positions[dragged][X];
          collisionY = positions[dragged][Y];
          collided = dragged;
          explosionX = lerp(center(dragged, X), center(other, X), 0.5);
          explosionY = lerp(center(dragged, Y), center(other, Y), 0.5);
          explosionOffset = random(5) + 5;
          explosionAngle = random(TWO_PI);
          dragged = NONE;
          ownMistakes++;
          collideSound.play();
          cursor(ARROW);
        }
      }
    }
    if (animationTime >= barStart + barDuration) {
      barStart = animationTime;
      barDuration = random(5000) + 5000;
      barSize = pow(random(6), 2) + 6;
    }
    if (animationTime >= dimEnd) {
      dim = !dim;
      int duration = dim ? 2000 : 8000;
      dimEnd = animationTime + random(duration) + 500;
    }
    float explosionProgress = float(animationTime - explosionStart) / EXPLOSION_DURATION;
    if (explosionProgress > 0.25 && explosionProgress < 0.75) {
      float stepX = map(explosionProgress, 0.25, 0.75, collisionX, dragOriginalX);
      float stepY = map(explosionProgress, 0.25, 0.75, collisionY, dragOriginalY);
      move(collided, stepX, stepY);
    } else if (explosionProgress >= 0.75 && collided != NONE) {
      move(collided, dragOriginalX, dragOriginalY);
      collided = NONE;
    }
  }

  /**
   * Zeichnet das Modul auf den Bildschirm.
   */
  void render() {
    push();
    translate(deltaX, deltaY);
    int animationEnd = animationStart + ANIMATION_DURATION;
    if (!solved) {
      boolean move = false;
      for (int thing = 0; thing < THING_COUNT; thing++) {
        if (thingsCollide(thing, getMouseX(), getMouseY())) {
          move = true;
          break;
        }
      }
      cursor(move ? MOVE : ARROW);
    }
    color primaryColor = #000000;
    if (!solved || animationTime < animationEnd) {
      drawShapes();
      primaryColor = REGULAR_BACKGROUND_COLOR;
    }
    float factor = float(animationTime - animationStart) / ANIMATION_DURATION;
    if (animationTime >= animationStart && animationTime < animationEnd) {
      float boxWidth = OUTER_WIDTH * factor;
      float boxHeight = OUTER_HEIGHT * factor;
      imageMode(CENTER);
      clip((OUTER_MIN_X + OUTER_MAX_X) * 0.5, (OUTER_MIN_Y + OUTER_MAX_Y) * 0.5, boxWidth, boxHeight);
      imageMode(CORNER);
    }
    renderExplosion();
    if (solved) {
      drawEnd();
      primaryColor = SOLVED_BACKGROUND_COLOR;
    }
    noClip();
    if (animationTime >= animationStart && animationTime < animationEnd) {
      primaryColor = lerpColor(REGULAR_BACKGROUND_COLOR, SOLVED_BACKGROUND_COLOR, factor);
    }
    fill(0, 31);
    noStroke();
    rect(OUTER_MIN_X, map(animationTime - barStart, 0, barDuration, OUTER_MIN_Y - barSize, OUTER_MAX_Y), OUTER_MAX_X - OUTER_MIN_X, barSize);
    if (dim) {
      fill(0, 31);
      rectMode(CORNERS);
      rect(OUTER_MIN_X, OUTER_MIN_Y, OUTER_MAX_X, OUTER_MAX_Y);
      rectMode(CORNER);
      primaryColor = lerpColor(primaryColor, #000000, 0.3);
    }
    blendMode(MULTIPLY);
    image(filterImage, 0, 0);
    blendMode(BLEND);
    image(frameImage, 0, 0);
    tint(primaryColor);
    blendMode(ADD);
    image(glowImage, 0, 0);
    blendMode(BLEND);
    noTint();
    pop();
  }

  /**
   * Zeichnet die Explosionsanimation, falls diese gerade läuft.
   */
  void renderExplosion() {
    float explosionProgress = float(animationTime - explosionStart) / EXPLOSION_DURATION;
    if (explosionProgress > 0 && explosionProgress < 1) {
      float diameter = explosionProgress * EXPLOSION_DIAMETER;
      float innerDiameter = max(explosionProgress - 0.5, 0) * 2 * (EXPLOSION_DIAMETER + 2 * explosionOffset);
      float innerX = explosionX + cos(explosionAngle) * explosionOffset;
      float innerY = explosionY + sin(explosionAngle) * explosionOffset;
      sourceBuffer.beginDraw();
      sourceBuffer.background(255);
      sourceBuffer.endDraw();
      maskBuffer.beginDraw();
      maskBuffer.translate(-OUTER_MIN_X, -OUTER_MIN_Y);
      maskBuffer.background(0);
      maskBuffer.fill(255);
      maskBuffer.noStroke();
      maskBuffer.ellipseMode(CENTER);
      maskBuffer.circle(explosionX, explosionY, diameter);
      maskBuffer.fill(0);
      maskBuffer.circle(innerX, innerY, innerDiameter);
      maskBuffer.endDraw();
      sourceBuffer.mask(maskBuffer);
      image(sourceBuffer, OUTER_MIN_X, OUTER_MIN_Y);
    }
  }

  /**
   * Zeichnet die Formen auf dem Modul.
   */ 
  void drawShapes() {
    fill(REGULAR_BACKGROUND_COLOR);
    noStroke();
    rect(OUTER_MIN_X, OUTER_MIN_Y, OUTER_WIDTH, OUTER_HEIGHT);
    for (int thing = 0; thing < THING_COUNT; thing++) {
      shape(thingPolygons[thing]);
    }
  }

  /**
   * Zeichnet den „Deaktiviert“-Bildschirm.
   */
  void drawEnd() {
    fill(SOLVED_BACKGROUND_COLOR);
    noStroke();
    rect(OUTER_MIN_X, OUTER_MIN_Y, OUTER_WIDTH, OUTER_HEIGHT);
    image(endImage, 0, 0);
  }

  /**
   * Behandelt das Drücken einer Maustaste.
   */
  void mousePress() {
    if (!solved && animationTime > explosionStart + EXPLOSION_DURATION) {
      for (int thing = 0; thing < THING_COUNT; thing++) {
        if (thingsCollide(thing, getMouseX(), getMouseY())) {
          dragged = thing;
          dragOriginalX = positions[thing][X];
          dragOriginalY = positions[thing][Y];
          dragDeltaX = dragOriginalX - getMouseX();
          dragDeltaY = dragOriginalY - getMouseY();
          playRandom(dragSound);
          break;
        }
      }
    }
  }

  /**
   * Behandelt das Loslassen einer Maustaste.
   */
  void mouseRelease() {
    if (!solved && dragged != NONE) {
      dragged = NONE;
      playRandom(dropSound);
      if (conditionsAreFulfilled()) {
        cursor(ARROW);
        animationStart = millis();
        solved = true;
      }
    }
  }

  /**
   * Erzeugt die einzelnen Formen und platziert sie auf dem Modul.
   */
  void generateShapes() {
    int[] shapeCount = new int[4];
    int circleColorSum = 0;
    boolean yellowTriangle = false;
    for (int thing = 0; thing < THING_COUNT; thing++) {
      int shape = int(random(4));
      int colorIndex = int(random(4));
      color thingColor = COLORS[colorIndex];
      thingShapes[thing] = shape;
      thingColors[thing] = thingColor;
      shapeCount[shape]++;
      if (shape == SHAPE_CIRCLE) {
        circleColorSum += colorIndex + 1;
      }
      if (shape == SHAPE_TRIANGLE && thingColor == YELLOW) {
        yellowTriangle = true;
      }
      boolean notFinal = true;
      while (notFinal) {
        move(thing, random(INNER_MIN_X, INNER_MAX_X - extent(thing, X)), random(INNER_MIN_Y, INNER_MAX_Y - extent(thing, Y)));
        notFinal = false;
        for (int other = 0; other < thing; other++) {
          if (boundsCollide(thing, other, GENERATION_SPACE)) {
            notFinal = true;
            break;
          }
        }
      }
    }
    conditions[0] = shapeCount[SHAPE_TRIANGLE] % 2 == 0;
    conditions[1] = shapeCount[SHAPE_SQUARE] > shapeCount[SHAPE_RECTANGLE];
    conditions[2] = yellowTriangle;
    conditions[3] = circleColorSum % 2 != 0;
  }

  /**
   * Spielt einen Sound leicht zufällig verzerrt ab.
   *
   * @param sound der abzuspieldende Sound
   */
  void playRandom(SoundFile sound) {
    sound.play(random(0.9, 1.2));
  }

  /**
   * Prüft, ob alle im Handbuch festgelegten Anforderungen erfüllt sind.
   *
   * @return true, falls alle Anforderungen erfüllt sind
   */
  boolean conditionsAreFulfilled() {
    return (conditions[0] ? colorIsLeftOrAboveColor(PURPLE, RED, Y)
                          : colorIsLeftOrAboveColor(YELLOW, PURPLE, X))
        && (conditions[1] ? colorIsLeftOrAboveColor(PURPLE, GREEN, X)
                          : colorIsLeftOrAboveColor(PURPLE, YELLOW, Y))
        && (conditions[2] ? shapesAreOnTop(1 << SHAPE_TRIANGLE | 1 << SHAPE_CIRCLE)
                          : shapesAreOnTop(1 << SHAPE_RECTANGLE | 1 << SHAPE_SQUARE))
        && (conditions[3] ? colorIsLeftOrAboveColor(GREEN, RED, X)
                          : colorIsLeftOrAboveColor(RED, YELLOW, X));
  }

  /**
   * Prüft, ob alle Formen einer Farbe links von, beziehungsweise über allen Formen
   * einer anderen Farbe liegen.
   *
   * @param less    die Farbe, die links, beziehungsweise oben liegen soll
   * @param greater die Farbe, die rechts, beziehungsweise unten liegen soll
   * @param axis    die Achse, um die geprüft werden soll
   * @return true, falls die Anforderung erfüllt ist
   */
  boolean colorIsLeftOrAboveColor(int less, int greater, int axis) {
    for (int a = 0; a < THING_COUNT; a++) {
      for (int b = 0; b < THING_COUNT; b++) {
        if (a != b && thingColors[a] == less && thingColors[b] == greater && center(a, axis) >= center(b, axis)) {
          return false;
        }
      }
    }
    return true;
  }

  /**
   * Prüft, ob bestimmte Formen jeweils über allen anderen Formen der selben Farbe liegen.
   *
   * @param shapes eine Bitmaske aller Formen, die oben liegen sollen
   * @return true, falls die Anforderung erfüllt ist
   */
  boolean shapesAreOnTop(int shapes) {
    for (int a = 0; a < THING_COUNT; a++) {
      for (int b = 0; b < THING_COUNT; b++) {
        if (a != b && thingColors[a] == thingColors[b] && (1 << thingShapes[a] & shapes) != 0 && (1 << thingShapes[b] & shapes) == 0 && center(a, Y) >= center(b, Y)) {
          return false;
        }
      }
    }
    return true;
  }

  /**
   * Gibt eine Dimension einer Form zurück.
   *
   * @param thing der Index der Form
   * @param axis  die Achse der Dimension
   * @return die Dimension
   */
  float extent(int thing, int axis) {
    return shapeExtents[thingShapes[thing]][axis];
  }

  /**
   * Gibt die Mittelkoordinate einer Form zurück.
   *
   * @param thing der Index der Form
   * @param axis  die Achse der Mittelkoordinate
   * @return die Mittelkoordinate
   */
  float center(int thing, int axis) {
    return positions[thing][axis] + extent(thing, axis) * 0.5;
  }

  /**
   * Bewegt eine Form möglichst nah an eine Zielkoordinate, ohne das Modul zu verlassen.
   *
   * @param thing   der Index der Form
   * @param targetX die x-Koordinate des Ziels
   * @param targetY die y-Koordinate des Ziels
   */
  void move(int thing, float targetX, float targetY) {
    positions[thing][X] = constrain(targetX, INNER_MIN_X, INNER_MAX_X - extent(thing, X));
    positions[thing][Y] = constrain(targetY, INNER_MIN_Y, INNER_MAX_Y - extent(thing, Y));
    thingPolygons[thing] = createPolygon(thing);
  }

  /**
   * Erzeugt ein Polygon für eine Form.
   *
   * @param thing der Index der Form
   * @return das Polygon
   */
  PShape createPolygon(int thing) {
    PShape polygon = createShape();
    polygon.beginShape();
    polygon.fill(thingColors[thing]);
    polygon.noStroke();
    float x = positions[thing][X];
    float y = positions[thing][Y];
    float w = extent(thing, X);
    float h = extent(thing, Y);
    switch (thingShapes[thing]) {
    case SHAPE_TRIANGLE:
      polygon.vertex(x, y + h);
      polygon.vertex(x + 0.5 * w, y);
      polygon.vertex(x + w, y + h);
      break;
    case SHAPE_CIRCLE:
      float radius = w * 0.5;
      for (int i = 0; i < CIRCLE_VERTICES; i++) {
        float a = i * TWO_PI / CIRCLE_VERTICES;
        polygon.vertex((cos(a) + 1) * radius + x, (sin(a) + 1) * radius + y);
      }
      break;
    default:
      polygon.vertex(x, y);
      polygon.vertex(x + w, y);
      polygon.vertex(x + w, y + h);
      polygon.vertex(x, y + h);
      break;
    }
    polygon.endShape(CLOSE);
    return polygon;
  }

  /**
   * Prüft, ob eine Form mit einem Punkt kollidiert.
   *
   * @param thing der Index der Form
   * @param x     die x-Koordinate des Punktes
   * @param y     die y-Koordinate des Punktes
   * @return true, falls eine Kollision vorliegt
   */
  boolean thingsCollide(int thing, float x, float y) {
    if (!boundsCollide(positions[thing][X], positions[thing][Y], extent(thing, X), extent(thing, Y), x, y, 0, 0, 0)) {
      return false;
    }
    PShape point = createShape();
    point.beginShape();
    point.vertex(x, y);
    point.endShape();
    return polygonsCollide(thingPolygons[thing], point);
  }

  /**
   * Prüft, ob zwei Formen miteinander kollidieren.
   *
   * @param a der Index der ersten Form
   * @param b der Index der zweiten Form
   * @return true, falls eine Kollision vorliegt
   */
  boolean thingsCollide(int a, int b) {
    return boundsCollide(a, b, 0) && polygonsCollide(thingPolygons[a], thingPolygons[b]);
  }

  /**
   * Prüft, ob die AABBs von zwei Formen miteinander kollidieren.
   * Eine Kollision wird erkannt, wenn beide AABBs einen gewählten Mindestabstand unterschreiten.
   *
   * @param a     der Index der ersten Form
   * @param b     der Index der zweiten Form
   * @param space der Mindestabstand
   * @return true, falls eine Kollision vorliegt
   */
  boolean boundsCollide(int a, int b, float space) {
    return boundsCollide(positions[a][X], positions[a][Y], extent(a, X), extent(a, Y), positions[b][X], positions[b][Y], extent(b, X), extent(b, Y), space);
  }

  /**
   * Prüft, ob zwei AABBs kollidieren.
   * Eine Kollision wird erkannt, wenn beide AABBs einen gewählten Mindestabstand unterschreiten.
   *
   * @param x1 die x-Koordinate der linken Kante der ersten AABB
   * @param y1 die y-Koordinate der oberen Kante der ersten AABB
   * @param w1 die Breite der ersten AABB
   * @param h1 die Höhe der ersten AABB
   * @param x2 die x-Koordinate der linken Kante der zweiten AABB
   * @param y2 die y-Koordinate der oberen Kante der zweiten AABB
   * @param w2 die Breite der zweiten AABB
   * @param h2 die Höhe der zweiten AABB
   * @param s  der Mindestabstand
   * @return true, falls eine Kollision vorliegt
   */
  boolean boundsCollide(float x1, float y1, float w1, float h1, float x2, float y2, float w2, float h2, float s) {
    return x2 + w2 + s >= x1 && x2 - s < x1 + w1 && y2 + h2 + s >= y1 && y2 - s < y1 + h1;
  }

  /**
   * Prüft, ob zwei Polygone kollidieren.
   *
   * @param shapeA das erste Polygon
   * @param shapeB das zweite Polygon
   * @return true, falls eine Kollision vorliegt
   */
  boolean polygonsCollide(PShape shapeA, PShape shapeB) {
    return checkHalfCollision(shapeA, shapeB) && checkHalfCollision(shapeB, shapeA);
  }

  /**
   * Führt eine halbe Kollisionsprüfung für zwei Polygone durch.
   *
   * @param shapeA das erste Polygon
   * @param shapeB das zweite Polygon
   * @return true, falls eine Kollision nicht ausgeschlossen werden kann
   */
  boolean checkHalfCollision(PShape shapeA, PShape shapeB) {
    int countA = shapeA.getVertexCount();
    PVector start = new PVector();
    PVector end = new PVector();
    PVector axis = new PVector();
    PVector minMaxA = new PVector();
    PVector minMaxB = new PVector();
    for (int i = 0; i < countA; i++) {
      shapeA.getVertex(i, start);
      shapeA.getVertex((i + 1) % countA, end);
      start.sub(end);
      axis.set(-start.y, start.x);
      axis.normalize();
      projectPolygon(axis, shapeA, minMaxA);
      projectPolygon(axis, shapeB, minMaxB);
      if (minMaxB.y < minMaxA.x || minMaxA.y < minMaxB.x) {
        return false;
      }
    }
    return true;
  }

  /**
   * Projiziert ein Polygon auf eine Achse und berechnet die kleinste und höchste
   * Koordinate des Polygons entlang der Achse.
   *
   * @param axis    die Achse
   * @param polygon das Polygon
   * @param minMax  der Vektor, in den die kleine und höchste Koodinate geschrieben werden soll
   */
  void projectPolygon(PVector axis, PShape polygon, PVector minMax) {
    PVector vertex = new PVector();
    polygon.getVertex(0, vertex);
    float dotProduct = axis.dot(vertex);
    minMax.x = dotProduct;
    minMax.y = dotProduct;
    for (int i = 1; i < polygon.getVertexCount(); i++) {
      polygon.getVertex(i, vertex);
      dotProduct = vertex.dot(axis);
      if (dotProduct < minMax.x) {
        minMax.x = dotProduct;
      } else if (dotProduct > minMax.y) {
        minMax.y = dotProduct;
      }
    }
  }

  /**
   * Gibt die x-Koordinate der Maus innerhalb des Moduls zurück.
   *
   * @return die x-Koordinate der Maus
   */
  float getMouseX() {
    return mouseX - deltaX;
  }

  /**
   * Gibt die y-Koordinate der Maus innerhalb des Moduls zurück.
   *
   * @return die y-Koordinate der Maus
   */
  float getMouseY() {
    return mouseY - deltaY;
  }
}
