import processing.sound.*;

class ArrangeShapes extends Game {
  final String PREFIX = "ArrangeShapes/";

  final int THING_COUNT = 2;

  final int X = 0;
  final int Y = 1;

  final int NONE = -1;

  final int SHAPE_RECTANGLE = 0;
  final int SHAPE_SQUARE = 1;
  final int SHAPE_TRIANGLE = 2;
  final int SHAPE_CIRCLE = 3;

  final color PURPLE = #bc4a9b;
  final color YELLOW = #ffd541;
  final color GREEN = #5daf8d;
  final color RED = #df3e23;
  final color[] COLORS = { PURPLE, YELLOW, GREEN, RED };

  final int INNER_MIN_X = 60;
  final int INNER_MIN_Y = 68;
  final int INNER_MAX_X = 339;
  final int INNER_MAX_Y = 334;

  final int OUTER_MIN_X = 55;
  final int OUTER_MIN_Y = 62;
  final int OUTER_MAX_X = 355;
  final int OUTER_MAX_Y = 340;
  final int OUTER_WIDTH = OUTER_MAX_X - OUTER_MIN_X;
  final int OUTER_HEIGHT = OUTER_MAX_Y - OUTER_MIN_Y;

  final color OFF_COLOR = #322b28;
  final color REGULAR_BACKGROUND_COLOR = OFF_COLOR;
  final color FAILED_BACKGROUND_COLOR = #df3e23;
  final color SOLVED_BACKGROUND_COLOR = #5daf8d;

  final float SQUARE_SIZE = 24;
  final float SHAPE_AREA = pow(SQUARE_SIZE, 2);
  final float RECTANGLE_WIDTH = SQUARE_SIZE * 1.5;
  final float RECTANGLE_HEIGHT = SQUARE_SIZE / 1.5;
  //final float TRIANGLE_WIDTH = squareSideLength / tan(radians(60)) * 2;
  final float TRIANGLE_WIDTH = sqrt(4 / sqrt(3) * SHAPE_AREA);
  final float TRIANGLE_HEIGHT = TRIANGLE_WIDTH * sqrt(3) * 0.5;
  final float CIRCLE_DIAMETER = sqrt(pow(SQUARE_SIZE, 2) / PI) * 2;
  final int CIRCLE_VERTICES = 16;

  final float[] shapeDimensions = new float[8];

  boolean debug = false;

  // http://sfxr.me/#111115tERS842cx1fzVL59biUbdKTdPt5y7ZgnpiyhfgAvhJjtVB9FdCc3EJ4LNjLy32fhNxeGPZNSQ16hXk3i3HjjDzYioHyAKkt5SoKAiMn9rCoKLu8PPu
  SoundFile dragSound;

  // http://sfxr.me/#34T6PksgCtRnhnhL4FipSMgvdTs6xqy9cV51hE4hXT8utYZinKUcmEraW7maxJFqAprpL7ey8v93zHyaaXoJPyJ8FhN7GeDF7NSpQqZ5cgLMPiWKMJyP45Ajh
  SoundFile dropSound;

  // http://sfxr.me/#34T6PkoDuHrK2s2itjmVPZMN5cJS7m5GAbH5qYk8PqKfaL9T8J28TPjkeUuEadW5WNG7Mfcqo9gy7kmVnqbrw7nDZgaKo5XWACN1WVLaXeWw7oFKYYyL7bt4P
  SoundFile solveSound;

  // http://sfxr.me/#7BMHBGDL2adeXGUejPTtTeJ8gsWdknZVP75kzvxaZzVy4jF7a3Pip4nB3egi61RiYVcVMtLMLLQLM3FsGHG6PcuHQyqVV5SvwBM9P7rVCQnKunJpzy77oWuY3
  SoundFile collideSound;

  PImage frameImage;
  PImage filterImage;
  PImage glowImage;
  PImage errorIcon;
  PFont titleFont;

  PGraphics sourceBuffer;
  PGraphics maskBuffer;

  int[] thingShapes;
  float[] thingCoordinates;
  color[] thingColors;
  PShape[] thingPolygons;
  
  int dragged = NONE;
  float dragDeltaX;
  float dragDeltaY;
  float dragOriginalX;
  float dragOriginalY;

  boolean[] conditions;
  boolean[] fulfilledA;
  boolean[] fulfilledB;

  int animationTime;

  int animationDuration = 500;
  int animationStart = -animationDuration;
  color primaryColor;

  float collisionX;
  float collisionY;
  int collided = NONE;
  float explosionDuration = 500;
  float explosionStart = -explosionDuration;
  float explosionX;
  float explosionY;
  float explosionDiameter = 140;
  float explosionOffset;
  float explosionAngle;

  float barStart;
  float barDuration;
  float barSize;

  boolean dim = true;
  float dimEnd = 0;

  ArrangeShapes(int x, int y, PApplet sketch) {
    super(x, y, sketch);
    shapeDimensions[index(SHAPE_RECTANGLE, X)] = RECTANGLE_WIDTH;
    shapeDimensions[index(SHAPE_RECTANGLE, Y)] = RECTANGLE_HEIGHT;
    shapeDimensions[index(SHAPE_SQUARE, X)] = SQUARE_SIZE;
    shapeDimensions[index(SHAPE_SQUARE, Y)] = SQUARE_SIZE;
    shapeDimensions[index(SHAPE_TRIANGLE, X)] = TRIANGLE_WIDTH;
    shapeDimensions[index(SHAPE_TRIANGLE, Y)] = TRIANGLE_HEIGHT;
    shapeDimensions[index(SHAPE_CIRCLE, X)] = CIRCLE_DIAMETER;
    shapeDimensions[index(SHAPE_CIRCLE, Y)] = CIRCLE_DIAMETER;
    frameImage = loadImage(PREFIX + "frame.png");
    filterImage = loadImage(PREFIX + "filter.png");
    glowImage = loadImage(PREFIX + "glow.png");
    errorIcon = loadImage(PREFIX + "error_icon.png");
    titleFont = createFont(PREFIX + "GlacialIndifference-Bold.otf", 36);
    dragSound = new SoundFile(sketch, PREFIX + "drag.mp3");
    dropSound = new SoundFile(sketch, PREFIX + "drop.mp3");
    solveSound = new SoundFile(sketch, PREFIX + "solve.mp3");
    collideSound = new SoundFile(sketch, PREFIX + "collide.mp3");
    sourceBuffer = createGraphics(OUTER_WIDTH, OUTER_HEIGHT);
    maskBuffer = createGraphics(OUTER_WIDTH, OUTER_HEIGHT);

    thingShapes = new int[THING_COUNT];
    thingCoordinates = new float[THING_COUNT << 1];
    thingColors = new color[THING_COUNT];
    thingPolygons = new PShape[THING_COUNT];

    conditions = new boolean[4];
    fulfilledA = new boolean[conditions.length];
    fulfilledB = new boolean[conditions.length];
    do {
      generateShapes();
    } while (areConditionsMet());
  }

  void update() {
    animationTime = millis();
    if (dragged != NONE && isActive()) {
      move(dragged, getMouseX() + dragDeltaX, getMouseY() + dragDeltaY);
      for (int other = 0; other < THING_COUNT && dragged != NONE; other++) {
        if (other != dragged && collidesWith(dragged, other)) {
          explosionStart = animationTime;
          collisionX = minX(dragged);
          collisionY = minY(dragged);
          collided = dragged;
          explosionX = (centerX(dragged) + centerX(other)) * 0.5;
          explosionY = (centerY(dragged) + centerY(other)) * 0.5;
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
    float explosionProgress = (animationTime - explosionStart) / explosionDuration;
    if (explosionProgress > 0.25 && explosionProgress < 0.75) {
      float stepX = map(explosionProgress, 0.25, 0.75, collisionX, dragOriginalX);
      float stepY = map(explosionProgress, 0.25, 0.75, collisionY, dragOriginalY);
      move(collided, stepX, stepY);
    } else if (explosionProgress >= 0.75 && collided != NONE) {
      move(collided, dragOriginalX, dragOriginalY);
      collided = NONE;
    }
  }

  void render() {
    push();
    translate(deltaX, deltaY);
    int animationEnd = animationStart + animationDuration;
    if (isActive()) {
      boolean move = false;
      for (int thing = 0; thing < THING_COUNT; thing++) {
        if (collidesWith(thing, getMouseX(), getMouseY())) {
          move = true;
          break;
        }
      }
      cursor(move ? MOVE : ARROW);
    }
    if (isActive() || animationTime < animationEnd) {
      drawShapes();
      primaryColor = REGULAR_BACKGROUND_COLOR;
    }
    float factor = (animationTime - animationStart) / (float) animationDuration;
    if (animationTime >= animationStart && animationTime < animationEnd) {
      float boxWidth = OUTER_WIDTH * factor;
      float boxHeight = OUTER_HEIGHT * factor;
      imageMode(CENTER);
      clip((OUTER_MIN_X + OUTER_MAX_X) * 0.5, (OUTER_MIN_Y + OUTER_MAX_Y) * 0.5, boxWidth, boxHeight);
      imageMode(CORNER);
    }
    renderExplosion();
    if (!isActive()) {
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
      primaryColor = lerpColor(primaryColor, OFF_COLOR, 0.3);
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
    if (debug) {
      fill(255, 0, 0);
      textAlign(LEFT, BASELINE);
      for (int i = 0; i < conditions.length; i++) {
        text((i + 1) + " " + conditions[i] + " " + fulfilledA[i] + " " + fulfilledB[i], 10, (i + 1) * 20);
      }
    }
    pop();
  }

  void renderExplosion() {
    float explosionProgress = (animationTime - explosionStart) / explosionDuration;
    if (explosionProgress > 0 && explosionProgress < 1) {
      float diameter = explosionProgress * explosionDiameter;
      float innerDiameter = max(explosionProgress - 0.5, 0) * 2 * (explosionDiameter + 2 * explosionOffset);
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

  void drawShapes() {
    fill(REGULAR_BACKGROUND_COLOR);
    noStroke();
    rect(OUTER_MIN_X, OUTER_MIN_Y, OUTER_WIDTH, OUTER_HEIGHT);
    for (int thing = 0; thing < THING_COUNT; thing++) {
      shape(thingPolygons[thing]);
    }
    /*if (draggedThing != null) {
    stroke(colors[draggedThing.tint], 63);
    strokeWeight(3);
    line(OUTER_MIN_X, draggedThing.minY(), OUTER_MAX_X, draggedThing.minY());
    line(OUTER_MIN_X, draggedThing.maxY(), OUTER_MAX_X, draggedThing.maxY());
    line(draggedThing.minX(), OUTER_MIN_Y, draggedThing.minX(), OUTER_MAX_Y);
    line(draggedThing.maxX(), OUTER_MIN_Y, draggedThing.maxX(), OUTER_MAX_Y);
    }*/
  }

  void drawEnd() {
    fill(SOLVED_BACKGROUND_COLOR);
    noStroke();
    rect(OUTER_MIN_X, OUTER_MIN_Y, OUTER_WIDTH, OUTER_HEIGHT);
    imageMode(CENTER);
    image(errorIcon, OUTER_MIN_X + OUTER_WIDTH * 0.5, INNER_MIN_Y + 100);
    imageMode(CORNER);
    fill(255);
    textFont(titleFont);
    textAlign(CENTER, TOP);
    text("DEAKTIVIERT", OUTER_MIN_X + OUTER_WIDTH * 0.5, INNER_MIN_Y + 140);
    textAlign(LEFT, BASELINE);
  }

  void mousePress() {
    if (isActive() && animationTime > explosionStart + explosionDuration) {
      for (int thing = 0; thing < THING_COUNT; thing++) {
        if (collidesWith(thing, getMouseX(), getMouseY())) {
          dragged = thing;
          dragOriginalX = minX(thing);
          dragOriginalY = minY(thing);
          dragDeltaX = dragOriginalX - getMouseX();
          dragDeltaY = dragOriginalY - getMouseY();
          playRandom(dragSound);
          break;
        }
      }
    }
  }

  void mouseRelease() {
    if (isActive() && dragged != NONE) {
      dragged = NONE;
      playRandom(dropSound);
      checkSolved();
    }
  }

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
        move(thing, random(INNER_MIN_X, INNER_MAX_X - thingDimension(thing, X)), random(INNER_MIN_Y, INNER_MAX_Y - thingDimension(thing, Y)));
        notFinal = false;
        for (int other = 0; other < thing; other++) {
          if (collidesWithBounds(thing, other, 4)) {
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

  void playRandom(SoundFile sound) {
    sound.play(random(0.9, 1.2));
  }

  void checkSolved() {
    if (areConditionsMet()) {
      cursor(ARROW);
      animationStart = millis();
      solved = true;
    }
  }

  boolean areConditionsMet() {
    fulfilledA[0] = isColorAboveColor(PURPLE, RED);
    fulfilledB[0] = isColorLeftOfColor(YELLOW, PURPLE);
    fulfilledA[1] = isColorLeftOfColor(PURPLE, GREEN);
    fulfilledB[1] = isColorAboveColor(PURPLE, YELLOW);
    fulfilledA[2] = areShapesOnTop(SHAPE_TRIANGLE, SHAPE_CIRCLE);
    fulfilledB[2] = areShapesOnTop(SHAPE_RECTANGLE, SHAPE_SQUARE);
    fulfilledA[3] = isColorLeftOfColor(GREEN, RED);
    fulfilledB[3] = isColorLeftOfColor(RED, YELLOW);
    boolean solved = true;
    for (int i = 0; i < conditions.length; i++) {
      if (conditions[i] ? !fulfilledA[i] : !fulfilledB[i]) {
        solved = false;
      }
    }
    return solved;
  }

  boolean isActive() {
    return !solved;
  }

  boolean isColorLeftOfColor(int left, int right) {
    return isColorCoordinateLess(left, right, X);
  }

  boolean isColorAboveColor(int top, int bottom) {
    return isColorCoordinateLess(top, bottom, Y);
  }

  boolean isColorCoordinateLess(int less, int greater, int axis) {
    for (int a = 0; a < THING_COUNT; a++) {
      for (int b = 0; b < THING_COUNT; b++) {
        if (a != b && thingColors[a] == less && thingColors[b] == greater && midCoordinate(a, axis, 0.5) >= midCoordinate(b, axis, 0.5)) {
          return false;
        }
      }
    }
    return true;
  }

  boolean areShapesOnTop(int shapeA, int shapeB) {
    for (int a = 0; a < THING_COUNT; a++) {
      for (int b = 0; b < THING_COUNT; b++) {
        if (a != b && thingColors[a] == thingColors[b] && (thingShapes[a] == shapeA || thingShapes[a] == shapeB) && thingShapes[b] != shapeA && thingShapes[b] != shapeB && centerY(a) >= centerY(b)) {
          return false;
        }
      }
    }
    return true;
  }

  int index(int position, int axis) {
    return position << 1 | axis;
  }

  float thingDimension(int thing, int axis) {
    return shapeDimensions[index(thingShapes[thing], axis)];
  }

  float midCoordinate(int thing, int axis, float offset) {
    return thingCoordinates[index(thing, axis)] + thingDimension(thing, axis) * offset;
  }

  float minX(int thing) {
    return thingCoordinates[index(thing, X)];
  }

  float minY(int thing) {
    return thingCoordinates[index(thing, Y)];
  }

  float centerX(int thing) {
    return midCoordinate(thing, X, 0.5);
  }

  float centerY(int thing) {
    return midCoordinate(thing, Y, 0.5);
  }

  float maxX(int thing) {
    return midCoordinate(thing, X, 1.0);
  }

  float maxY(int thing) {
    return midCoordinate(thing, Y, 1.0);
  }

  void move(int thing, float targetX, float targetY) {
    thingCoordinates[index(thing, X)] = constrain(targetX, INNER_MIN_X, INNER_MAX_X - thingDimension(thing, X));
    thingCoordinates[index(thing, Y)] = constrain(targetY, INNER_MIN_Y, INNER_MAX_Y - thingDimension(thing, Y));
    thingPolygons[thing] = createPolygon(thing);
  }

  PShape createPolygon(int thing) {
    PShape polygon = createShape();
    polygon.beginShape();
    polygon.fill(thingColors[thing]);
    polygon.noStroke();
    float x = minX(thing);
    float y = minY(thing);
    float w = thingDimension(thing, X);
    float h = thingDimension(thing, Y);
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

  boolean collidesWith(int thing, float targetX, float targetY) {
    if (targetX < minX(thing) || targetX >= maxX(thing) || targetY < minY(thing) || targetY >= maxY(thing)) {
      return false;
    }
    PShape point = createShape();
    point.beginShape();
    point.vertex(targetX, targetY);
    point.endShape();
    return polygonsCollide(thingPolygons[thing], point);
  }

  boolean collidesWith(int thingA, int thingB) {
    if (!collidesWithBounds(thingA, thingB, 0)) {
      return false;
    }
    return polygonsCollide(thingPolygons[thingA], thingPolygons[thingB]);
  }

  boolean collidesWithBounds(int a, int b, float space) {
    return maxX(b) + space >= minX(a) && minX(b) - space < maxX(a) && maxY(b) + space >= minY(a) && minY(b) - space < maxY(a);
  }

  boolean polygonsCollide(PShape shapeA, PShape shapeB) {
    return checkHalfCollision(shapeA, shapeB) && checkHalfCollision(shapeB, shapeA);
  }

  boolean checkHalfCollision(PShape shapeA, PShape shapeB) {
    int countA = shapeA.getVertexCount();
    PVector start = new PVector();
    PVector end = new PVector();
    PVector axis = new PVector();
    PVector minMaxA = new PVector();
    PVector minMaxB = new PVector();

    // Loop through all the edges of polygon A
    for (int i = 0; i < countA; i++) {
      shapeA.getVertex(i, start);
      shapeA.getVertex((i + 1) % countA, end);
      start.sub(end);

      // Find the axis perpendicular to the current edge
      axis.set(-start.y, start.x);
      axis.normalize();

      // Find the projection of the polygon on the current axis
      projectPolygon(axis, shapeA, minMaxA);
      projectPolygon(axis, shapeB, minMaxB);

      // Check if the polygon projections are separated
      if (minMaxB.y < minMaxA.x || minMaxA.y < minMaxB.x) {
        // they are separated, therefore the polygons cannot collide
        return false;
      }
    }
    // looks like the polygons might not be separated, therefore they might be colliding
    return true;
  }

  void projectPolygon(PVector axis, PShape polygon, PVector minMax) {
    PVector vertex = new PVector();
    polygon.getVertex(0, vertex);
    // To project a point on an axis use the dot product
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

  float getMouseX() {
    return mouseX - deltaX;
  }

  float getMouseY() {
    return mouseY - deltaY;
  }
}
