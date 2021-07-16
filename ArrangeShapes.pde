import processing.sound.*;

class ArrangeShapes extends Game {
  final String PREFIX = "ArrangeShapes/";

  final int SHAPE_RECTANGLE = 0;
  final int SHAPE_SQUARE = 1;
  final int SHAPE_TRIANGLE = 2;
  final int SHAPE_CIRCLE = 3;

  final int PURPLE = 0;
  final int YELLOW = 1;
  final int GREEN = 2;
  final int RED = 3;

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

  final color[] colors = new color[4];

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

  Thing[] things;
  Thing draggedThing;
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
  Thing collidedThing;
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
    colors[PURPLE] = #bc4a9b;
    colors[YELLOW] = #ffd541;
    colors[GREEN] = #5daf8d;
    colors[RED] = #df3e23;
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
    things = new Thing[10];
    conditions = new boolean[4];
    fulfilledA = new boolean[conditions.length];
    fulfilledB = new boolean[conditions.length];
    do {
      generateShapes();
    } while (areConditionsMet());
  }

  void update() {
    animationTime = millis();
    if (draggedThing != null && isActive()) {
      draggedThing.move(getMouseX() + dragDeltaX, getMouseY() + dragDeltaY);
      for (int i = 0; i < things.length && draggedThing != null; i++) {
        Thing collided = things[i];
        if (collided != draggedThing && draggedThing.collidesWith(collided)) {
          explosionStart = animationTime;
          collisionX = draggedThing.x;
          collisionY = draggedThing.y;
          collidedThing = draggedThing;
          explosionX = (draggedThing.x + collided.x) * 0.5;
          explosionY = (draggedThing.y + collided.y) * 0.5;
          explosionOffset = random(5) + 5;
          explosionAngle = random(TWO_PI);
          draggedThing = null;
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
      collidedThing.move(stepX, stepY);
    } else if (explosionProgress >= 0.75 && collidedThing != null) {
      collidedThing.move(dragOriginalX, dragOriginalY);
      collidedThing = null;
    }
  }

  void render() {
    push();
    translate(deltaX, deltaY);
    int animationEnd = animationStart + animationDuration;
    if (isActive()) {
      boolean move = false;
      for (int i = 0; i < things.length; i++) {
        if (things[i].collidesWith(getMouseX(), getMouseY())) {
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
    for (int i = 0; i < things.length; i++) {
      things[i].draw();
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
      for (int i = 0; i < things.length; i++) {
        if (things[i].collidesWith(getMouseX(), getMouseY())) {
          draggedThing = things[i];
          dragOriginalX = draggedThing.x;
          dragOriginalY = draggedThing.y;
          dragDeltaX = draggedThing.x - getMouseX();
          dragDeltaY = draggedThing.y - getMouseY();
          playRandom(dragSound);
          break;
        }
      }
    }
  }

  void mouseRelease() {
    if (isActive() && draggedThing != null) {
      draggedThing = null;
      playRandom(dropSound);
      checkSolved();
    }
  }

  void generateShapes() {
    int[] shapeCount = new int[4];
    int circleColorSum = 0;
    boolean yellowTriangle = false;
    for (int i = 0; i < things.length; i++) {
      Thing thing = new Thing();
      thing.shape = int(random(4));
      thing.tint = int(random(4));
      shapeCount[thing.shape]++;
      if (thing.shape == SHAPE_CIRCLE) {
        circleColorSum += thing.tint + 1;
      }
      if (thing.shape == SHAPE_TRIANGLE && thing.tint == YELLOW) {
        yellowTriangle = true;
      }
      boolean notFinal = true;
      while (notFinal) {
        thing.move(random(INNER_MIN_X, INNER_MAX_X - thing.width()), random(INNER_MIN_Y, INNER_MAX_Y - thing.height()));
        notFinal = false;
        for (int j = 0; j < i; j++) {
          if (thing.collidesWithBounds(things[j], 4)) {
            notFinal = true;
            break;
          }
        }
      }
      things[i] = thing;
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
    for (int i = 0; i < things.length; i++) {
      for (int j = 0; j < things.length; j++) {
        Thing a = things[i];
        Thing b = things[j];
        if (i != j && a.tint == left && b.tint == right && a.centerX() >= b.centerX()) {
          return false;
        }
      }
    }
    return true;
  }

  boolean isColorAboveColor(int top, int bottom) {
    for (int i = 0; i < things.length; i++) {
      for (int j = 0; j < things.length; j++) {
        Thing a = things[i];
        Thing b = things[j];
        if (i != j && a.tint == top && b.tint == bottom && a.centerY() >= b.centerY()) {
          return false;
        }
      }
    }
    return true;
  }

  boolean areShapesOnTop(int shapeA, int shapeB) {
    for (int i = 0; i < things.length; i++) {
      for (int j = 0; j < things.length; j++) {
        Thing a = things[i];
        Thing b = things[j];
        if (i != j && a.tint == b.tint && (a.shape == shapeA || a.shape == shapeB) && b.shape != shapeA && b.shape != shapeB && a.centerY() >= b.centerY()) {
          return false;
        }
      }
    }
    return true;
  }

  class Thing {
    int shape;
    float x;
    float y;
    int tint;
    PShape polygon;

    float width() {
      switch (shape) {
      case SHAPE_RECTANGLE:
        return RECTANGLE_WIDTH;
      case SHAPE_TRIANGLE:
        return TRIANGLE_WIDTH;
      case SHAPE_CIRCLE:
        return CIRCLE_DIAMETER;
      default:
        return SQUARE_SIZE;
      }
    }

    float height() {
      switch (shape) {
      case SHAPE_RECTANGLE:
        return RECTANGLE_HEIGHT;
      case SHAPE_TRIANGLE:
        return TRIANGLE_HEIGHT;
      case SHAPE_CIRCLE:
        return CIRCLE_DIAMETER;
      default:
        return SQUARE_SIZE;
      }
    }

    float minX() {
      return x;
    }

    float minY() {
      return y;
    }

    float maxX() {
      return x + width();
    }

    float maxY() {
      return y + height();
    }
    
    float centerX() {
      return (minX() + maxX()) * 0.5;
    }
    
    float centerY() {
      return (minY() + maxY()) * 0.5;
    }

    void move(float targetX, float targetY) {
      x = constrain(targetX, INNER_MIN_X, INNER_MAX_X - width());
      y = constrain(targetY, INNER_MIN_Y, INNER_MAX_Y - height());
      polygon = createPolygon();
    }

    void draw() {
      shape(polygon);
    }

    boolean collidesWith(float targetX, float targetY) {
      if (!(targetX >= minX() && targetX < maxX() && targetY >= minY() && targetY < maxY())) {
        return false;
      }
      PShape point = createShape();
      point.beginShape();
      point.vertex(targetX, targetY);
      point.endShape();
      return polygonsCollide(polygon, point);
    }

    boolean collidesWith(Thing other) {
      if (!collidesWithBounds(other, 0)) {
        return false;
      }
      return polygonsCollide(polygon, other.polygon);
    }

    boolean collidesWithBounds(Thing other, float space) {
      return other.maxX() + space >= minX() && other.minX() - space < maxX() && other.maxY() + space >= minY() && other.minY() - space < maxY();
    }

    PShape createPolygon() {
      PShape polygon = createShape();
      polygon.beginShape();
      polygon.fill(colors[tint]);
      polygon.noStroke();
      switch (shape) {
      case SHAPE_TRIANGLE:
        polygon.vertex(minX(), maxY());
        polygon.vertex(minX() + width() * 0.5, minY());
        polygon.vertex(maxX(), maxY());
        break;
      case SHAPE_CIRCLE:
        float radius = width() * 0.5;
        for (int i = 0; i < CIRCLE_VERTICES; i++) {
          float angle = i * TWO_PI / CIRCLE_VERTICES;
          float x = (cos(angle) + 1) * radius + minX();
          float y = (sin(angle) + 1) * radius + minY();
          polygon.vertex(x, y);
        }
        break;
      default:
        polygon.vertex(minX(), minY());
        polygon.vertex(maxX(), minY());
        polygon.vertex(maxX(), maxY());
        polygon.vertex(minX(), maxY());
        break;
      }
      polygon.endShape(CLOSE);
      return polygon;
    }
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
