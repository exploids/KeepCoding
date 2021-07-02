import processing.sound.*; //<>//
import java.util.Collections;
void settings() {
  size(1632, 816);
}

/////////// Timer
int lastTimestamp; 
int duration;
int time;
float sekundenGeschwindigkeit;
int globalMistakes, globalSolved;
int lastMistakes, lastSolved;
int maxMistakes = 8;
int anzahlModuleOhneTimer;

int globalSeed;
String globalSerial;
String globalManufacturer;
String globalCountry;

SoundFile tick;
SoundFile buzzer;
SoundFile solved_sound;

PImage background_img;

ArrayList<String> allGamenames;
ArrayList<Game> games;
Game focusedGame;

int abstand, teileX, raster, gameSize;

void setup() {
  globalSeed = floor(random(1048576, 16777215)); //damit die Serial immer 6 Zeichen hat bei Base16
  println(globalSeed);
  globalSerial = parseSerial(globalSeed, 16);
  globalManufacturer = getManufacturer(globalSeed);
  globalCountry = getCountry(globalSeed);
  tick = new SoundFile(this, "Global/tick.wav");
  buzzer = new SoundFile(this, "Global/buzzer.wav");
  solved_sound = new SoundFile(this, "Global/solved.mp3");
  background_img =  loadImage("Global/Background.png");
  tick.loop();

  duration = 180000;


  
  allGamenames = new ArrayList<String>();

  //Hier könnt ihr bestimmen, welche Spiele im Modul enthalten sein sollen. Aktuell ist es vier mal das Spiel "EasyGame". Das Spiel "LoffelRatsel" (auskommentiert) ist ein Beispiel, wie ihr ein Modul hinzufügen könntet.
  allGamenames.add("EasyGame");
  allGamenames.add(ArrangeShapes.class.getSimpleName());
  //allGamenames.add("LoffelRatsel");

  anzahlModuleOhneTimer = allGamenames.size();

  Collections.shuffle(allGamenames);

  /////////// Timer
  lastTimestamp = millis(); 
  sekundenGeschwindigkeit = 1;
  time = duration;

  abstand = 4;
  teileX = 4;
  raster = width/teileX;
  gameSize= 400;

  games = new ArrayList<Game>();
  Timer timer = new Timer(abstand, abstand, this);
  games.add(timer);

  //HIER MÜSST IHR EUER SPIEL "REGISTRIEREN". Dazu wie im Beispiel von "LoffelRatsel" (auskommentiert) zum einen den String in der If-Abfrage anpassen, und den Klassennamen auf den Namen eurer Klasse ändern.
  for (int i = 1; i<=allGamenames.size(); i++) {
    if (allGamenames.get(i-1).equals("EasyGame")) games.add( new EasyGame((i%teileX)*gameSize+(i%teileX)*abstand*2+abstand, abstand+(i/teileX)*gameSize+(i/teileX)*abstand*2, this));
    if (allGamenames.get(i-1).equals(ArrangeShapes.class.getSimpleName())) games.add( new ArrangeShapes((i%teileX)*gameSize+(i%teileX)*abstand*2+abstand, abstand+(i/teileX)*gameSize+(i/teileX)*abstand*2, this));
    //if (allGamenames.get(i-1).equals("LoffelRatsel")) games.add( new LoffelRatsel((i%teileX)*gameSize+(i%teileX)*abstand*2+abstand, abstand+(i/teileX)*gameSize+(i/teileX)*abstand*2, this));
  }

  focusedGame = timer; //zu Beginn zählt der Timer als fokussiert

  for (int i = 0; i<games.size(); i++) {
    Game current = games.get(i);
    current.seed = globalSeed;
    current.serial = globalSerial;
    current.manufacturer = globalManufacturer;
    current.country = globalCountry;
  }
}

void draw() {
  //background(0);
  image(background_img, 0, 0);
  // Berechnung des Timers //
  /*sekundenGeschwindigkeit = 1000-globalMistakes*100; // Wie schnell die Bombe tickt ist abhängig von der Anzahl der Fehler
   if (sekundenGeschwindigkeit<=0)sekundenGeschwindigkeit=1;
   
   if (anzahlModuleOhneTimer != globalSolved && time > 0 ) {
   time = (duration) - (millis() /sekundenGeschwindigkeit); //// NOCH NICHT RICHTIG
   } else {
   tick.stop(); // Sound stopt wenn alles gelöst ist
   }*/

  if (globalMistakes >= maxMistakes) {
    time = 0;
    noLoop();
  }

  if (anzahlModuleOhneTimer != globalSolved && time > 0 ) {
    time -= ((millis() - lastTimestamp)*(1+globalMistakes*0.2));
    lastTimestamp = millis();
  } else {
    tick.stop(); // Sound stopt wenn alles gelöst ist
  }


  // Sound vom Timer, Buzzer und Rätsel gelöst //
  if (lastSolved!=globalSolved) {
    solved_sound.play();
    lastSolved = globalSolved;
  }
  if (lastMistakes!=globalMistakes) {
    buzzer.play();
    lastMistakes = globalMistakes;
    tick.rate(1+0.1*globalMistakes);
  }
  if (time <= 0) {
    tick.stop();
  }  

  // Updates aller Daten und Aufruf der Update und Render-Funktion der Games //
  for (int i = 0; i<games.size(); i++) {
    Game current = games.get(i);
    current.globalMistakes = globalMistakes;
    current.globalTime = time/1000;    
    current.update();
    current.render();
    current.focus = false;

    focusedGame = current.focusTimestamp > focusedGame.focusTimestamp ? current : focusedGame;
  }

  focusedGame.focus = true;

  globalMistakes= 0;
  globalSolved = 0;
  for (int i = 0; i<games.size(); i++) {
    globalMistakes += games.get(i).ownMistakes;
    if (games.get(i).solved == true) globalSolved++;
  }
}

String parseSerial(int seed, int base) {
  char alphabet[] = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ".toCharArray();
  String serial = "";

  while (seed > 0) {
    serial += alphabet[seed%base];
    seed /= base;
  }

  return new String(reverse(serial.toCharArray()));
}

Integer parseSeed(String serial, int base) {
  String alphabet = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ";

  int seed = 0;

  for (int i = 0; i < serial.length(); i++) {
    seed += alphabet.indexOf(serial.charAt(i))*pow(base, serial.length()-1-i);
  }

  return seed;
}

String getManufacturer(int seed) {
  switch (seed%6) {
  case 0: 
    return "SHRAPNAL";
  case 1: 
    return "Attentatum";
  case 2: 
    return "uberBomb";
  case 3: 
    return "Steel Fuse";
  case 4: 
    return "ICV";
  case 5: 
    return "Meng's Silver Production";
  }

  return "";
}

String getCountry(int seed) {
  switch (seed%3) {
  case 0: 
    return "USA";
  case 1: 
    return "DEU";
  case 2: 
    return "CHN";
  }

  return "";
}

// Durchreichen der Mausfunktionen //
void mouseClicked() {
  for (int i = 0; i<games.size(); i++) {
    games.get(i).mouseClick();
  }
}
void mousePressed() {
  for (int i = 0; i<games.size(); i++) {
    games.get(i).mousePress();
    games.get(i).focusTimer();
  }
}
void mouseReleased() {
  for (int i = 0; i<games.size(); i++) {
    games.get(i).mouseRelease();
  }
}
void keyTyped() {
  for (int i = 0; i<games.size(); i++) {
    games.get(i).keyTypeIfFocused();
  }
}
void keyPressed() {
  for (int i = 0; i<games.size(); i++) {
    games.get(i).keyPressIfFocused();
  }
}
void keyReleased() {
  for (int i = 0; i<games.size(); i++) {
    games.get(i).keyReleaseIfFocused();
  }
}
