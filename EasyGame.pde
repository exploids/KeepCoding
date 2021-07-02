class EasyGame extends Game {
  PImage background_img, solved_img, unsolved_img;

  EasyGame(int x, int y, PApplet p) {
    super(x, y, p);
    background_img =  loadImage("EasyGame//PlatteEasyGame.png"); // Eigene Bilder, Sounds oder Schriften kommen in den Ordner "Data/YourGame" (Data muss nicht als Pfad mitangegeben werden)
    unsolved_img=  loadImage("Global//Unsolved.png"); // Natürlich darf man auch auf die Global-Dateien zugreifen
    solved_img=  loadImage("Global//Solved.png");
  }

   void update() {
  }
  
  void render() {
    image(background_img, deltaX, deltaY);
    if (!solved) {
      image(unsolved_img, deltaX, deltaY);
    } else {
      image(solved_img, deltaX, deltaY);
    }
  }
  
  void mouseClick() {
  }
  void mousePress() {
    if (mouseX  > 60+deltaX && mouseX < 185+deltaX && mouseY > 182+deltaY && mouseY < 305+deltaY) {

      if (seed % 2 != 0) {
        if (!solved) {
          ownMistakes++;
        }
      } else {
        solved = true;
      }
    }
    if (mouseX  > 225+deltaX && mouseX < 350+deltaX && mouseY > 182+deltaY && mouseY < 305+deltaY) {


      if (seed % 2 == 0) {
        if (!solved) {
          ownMistakes++;
        }
      } else {
        solved = true;
      }
    }
  }
  void mouseRelease() {
  }
  void keyPress() {
    solved = true;
  };
}
