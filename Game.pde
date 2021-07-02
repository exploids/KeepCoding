abstract class Game {

  //Diese Variablen dürfen NICHT verändert werden sondern werden vom Spiel selbst verwaltet  
  PApplet mainclass; //Mainclass muss mit übergeben werden, da SoundFiles die PApplet kennen müssen.
  int deltaX, deltaY; //Fixe Werte, die über den Konstruktor vergeben werden.  
  int globalTime; // Sekunden bis zum Spielende
  int globalMistakes; // Gesamtfehler im ganzen Spiel
  int seed; // Seed um Eigenschaften der Bombe zu nutzen
  String serial;
  String manufacturer;
  String country;
  double focusTimestamp = -1; //wird genutzt um aktuell fokussiertes Game zu identifizieren  
  boolean focus; //hat das Game den Fokus aktuell
  
  //Diese Variablen müssen vom jeweiligen Rätsel verwaltet werden
  boolean solved; //true, wenn das Rätsel gelöst wurde, sonst false  
  int ownMistakes; // Anzahl Fehler die hier gemacht werden. Inkrementieren bei Fehler! Wird vom Gamemanager in jeder draw() abgefragt.
  
  Game(int x, int y, PApplet p) {

    mainclass = p;
    deltaX=x;
    deltaY=y;
    solved = false;
    ownMistakes = 0;
  }

  abstract void update(); // Diese Funktion MUSS implementiert werden 
  abstract void render(); // Diese Funktion MUSS implementiert werden

  // Diese Funktionen KÖNNEN implementiert werden
  void mouseClick() {
  };
  void mouseRelease() {
  };
  void mousePress() {
  };
  void keyType() {
  };
  void keyRelease() {
  };
  void keyPress() {
  };

  //Diese Funktionen KÖNNEN NICHT verändert oder neu implementiert werden
  final void focusTimer() {
    if (mouseX > deltaX && mouseX < deltaX + 400 && mouseY > deltaY && mouseY < deltaY + 400)
      focusTimestamp = millis();
  }
  final void keyTypeIfFocused() {
    if (focus) {
      keyType();
    }
  }
  final void keyReleaseIfFocused() {
    if (focus) {
      keyRelease();
    }
  }
  final void keyPressIfFocused() {
    if (focus) {
      keyPress();
    }
  }
}
