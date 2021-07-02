import processing.sound.*;
public class Timer extends Game {
  PImage img, lampOn, lampOff;
  PFont andale, digit, sansc;
  SoundFile tick;
  SoundFile buzzer;



  Timer(int x, int y, PApplet p) { 
    super(x, y, p);
    //solved = true;

    sansc = createFont("Timer//SANSC.TTF", 28);
    andale = createFont("Timer//Mew.otf", 16);
    digit = createFont("Timer//Digit.TTF", 64);
    lampOn = loadImage("Timer//LampOn.png");
    lampOff = loadImage("Timer//LampOff.png");
    img =  loadImage("Timer//Platte_04.png");

    focusTimestamp = 0; //nur für Timer
  }

  void update() {
    //if (focus) println("Timer: " + frameCount); //just for debug
  }

  void render() {

    image(img, deltaX, deltaY);

    ////////// Darstellung der Fehler-LEDs
    for (int i = 0; i<8; i++) {
      if (i<globalMistakes) {

        image(lampOn, 361+deltaX, 320-i*30+deltaY);
      } else {

        image(lampOff, 361+deltaX, 320-i*30+deltaY);
      }
    } 

    //////////// Zettel mit Code
    fill(0, 0, 0, 200);
    textFont(andale);
    String s = "Serial:\n   " + formatSerial(serial);
    //if (seed % 2 == 0) s+= "05145-52145-55";
    //if (seed % 2 != 0) s+= "123-52145-55";
    text(s, 55+deltaX, 130+deltaY);

    fill(0, 0, 0, 200);
    textFont(sansc);
    String s2 = manufacturer + " - " + country;
    //if (seed % 3 == 0) s2+= "Heckler & Koch";
    //if (seed % 3 == 1) s2+= "Thyssen Krupp";
    //if (seed % 3 == 2) s2+= "Ares";
    text(s2, 20+deltaX, 380+deltaY);



    //////////// Uhranzeige
    textFont(digit);
    fill(250, 0, 0, 200);
    if (globalTime > 0) {  
      String timerDarstellung = "";
      if (globalTime/60<10) timerDarstellung += "0";
      timerDarstellung += globalTime/60+":";
      if (globalTime%60<10) timerDarstellung += "0";
      timerDarstellung +=globalTime%60;
      text(timerDarstellung, 112+deltaX, 324+deltaY);
    }
  }

  String formatSerial(String s) {
    String r = "";

    if (s != null) {
      for (int i = 0; i < s.length(); i++) {
        r += s.charAt(i);
        if (seed % (i+1) == 0 && i != s.length()-1) {
          r += "-";
        }
      }
    }

    return r;
  }
}
