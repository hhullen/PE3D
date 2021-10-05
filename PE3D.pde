import processing.opengl.*;

//Data
int cols = 50, rows = 50, scl = 6;
float landscape[][] = new float[cols * 2 + 1][rows * 2 + 1];
float xoff, yoff;
float max, min, thrd1, thrd2, alt;
color colr[][] = new color[cols * 2 + 1][rows * 2 + 1];
int colR = 0, colG = 0, colB = 0;
String[] textLines;
String[] currentLine;

//Position
int prevMouseY = 0, prevMouseX = 0, prevMouseZ = 0;
int dy = 0, dx = 0, dz = 0, dzoom = 0;
int angleY = 0, angleX = 0, angleZ = 0, zoom = 0;
int prevMouseMoveY = 0, prevMouseMoveX = 0;
int moveX = 0, moveY = 0;

//Panel
int stroke3D = 0;
int posXpanel = -10;
int btns[] = new int[10];
int btnFlags[] = new int[10];
/* btns, btnsFlags: 0 - 3dmode, 1 - grid, 2 - data, 3 - markup
 4 - save data, 5 - screenshot, 6 - open panel, 7 - isometry, 8 - 2dmode, 9 - noneMode  */
int flag6btn = 0;
color colBTN[] = new color[4];
//colBTN: 0 - usual, 1 - targeted, 2 - pressed, 3 - active;
String screenPath = null;



void setup() {
  smooth(4);
  btns[9] = 1;
  btns[0] = 0;
  size(1000, 600, OPENGL);
  frameRate(100);
  colorMode(RGB, 255, 255, 255);
  createFont("arial", 30);

  colBTN[0] = color(70, 130, 200); //usual
  colBTN[1] = color(100, 160, 230); //targeted
  colBTN[2] = color(50, 120, 180); //pressed
  colBTN[3] = color(255, 165, 0); //active

  loadupDataFromFile();
  println("Got data");

  //getNewData(cols, rows);
  println(min, "min ");
  println(max, "max");
}

void draw() {
  background(250);

  moveX = getMotionX(moveX);
  moveY = getMotionY(moveY);
  zoom = getZoomValue(zoom, dzoom);
  dzoom = 0;
  //translate(width / 2 + 100 + moveX, height / 2 + moveY, zoom - 200);
  translate(width / 2 + 100 + moveX, height / 2 + moveY, zoom);

  if (btns[0] == 1) {
    angleY = getRotateY_Angle(angleY);
    angleX = getRotateX_Angle(angleX, angleY);
    angleZ = getRotateZ_Angle(angleZ, angleY);
    if (btns[7] == 1) {
      angleX = moveFunction(angleX, 60);
      angleY = moveFunction(angleY, 0);
      angleZ = moveFunction(angleZ, 60);
      moveX = moveFunction(moveX, 0);
      moveY = moveFunction(moveY, 0);
      zoom = moveFunction(zoom, 0);
    }

    if (angleX > 58 && angleY < 2 && angleZ > 58 &&
      moveX < 2 && moveY < 2 && zoom < 2) {
      btns[7] = 0;
    }

    rotateY(radians(angleY % 360));
    rotateX(radians(angleX % 360));
    rotateZ(radians(angleZ % 360));

    drawShadow(cols, rows, scl);
    draw3D(cols, rows, scl, btns[1]);
    if (btns[3] == 1) drawMarkup(cols, rows, scl);
    if (btns[2] == 1) {
      //getNewData(cols, rows);
      loadupDataFromFile();
      println(btns[2]);
      btns[2] = 0;
    }
  } else if (btns[8] == 1) {
    rotateY(0);
    rotateX(0);
    draw2Dmap(cols, rows, scl, btns[1]);
    if (btns[3] == 1) drawMarkup(cols, rows, scl);
    if (btns[2] == 1) {
      //getNewData(cols, rows);
      loadupDataFromFile();
      println(btns[2]);
      btns[2] = 0;
    }
  } else if (btns[9] == 1) {
    if (btns[3] == 1) drawMarkup(cols, rows, scl);
    drawShadow(cols, rows, scl);
    if (btns[3] == 1) drawMarkup(cols, rows, scl);
  }

  camera(); //resets viewport to 2D equivalent
  noLights();

  drawPanel(posXpanel);

  if (btns[0] == 1 || btns[8] == 1) {
    printInfo(min, max);
  }
  if (screenPath != null) {
    saveFrame(screenPath);
    posXpanel = -10;
  }
  screenPath = null; //println(mouseX, mouseY);
}

int moveFunction(int curr, int targ) {
  curr = curr + (targ - curr) / 2;
  return curr;
}

/*
void draw3D(int cls, int rws, int sc, int strCol) {
 stroke(0);
 strokeWeight(strCol);
 for (int y = -cls; y < cls; y++) {
 beginShape(TRIANGLE_STRIP);
 for (int x = -rws; x < rws + 1; x++) {
 fill(colr[x + rws][y + cls]);
 vertex(x * sc, y * sc, landscape[x + rws][y + cls]);
 vertex(x * sc, (y + 1)*sc, landscape[x + rws][y + cls + 1]);
 }
 endShape();
 }
 }
 */

void draw3D(int cls, int rws, int sc, int strCol) {
  stroke(0);
  strokeWeight(strCol);
  for (int y = -cls / 2; y < (cls - 1) / 2; y++) {
    beginShape(TRIANGLE_STRIP);
    for (int x = -rws / 2; x < rws / 2; x++) {
      fill(colr[x + rws / 2][y + cls / 2]);
      vertex(x * sc, y * sc, landscape[x + rws / 2][y + cls / 2] - min);
      vertex(x * sc, (y + 1) * sc, landscape[x + rws / 2][y + cls / 2 + 1] - min);
    }
    endShape();
  }
}

/*
void draw2Dmap(int cls, int rws, int sc, int strCol) {
 stroke(0);
 strokeWeight(strCol);
 for (int y = -cls; y < cls; y++) {
 beginShape(TRIANGLE_STRIP);
 for (int x = -rws; x < rws + 1; x++) {
 fill(colr[x + rws][y + cls]);
 vertex(x * sc, y * sc);
 vertex(x * sc, (y + 1)*sc);
 }
 endShape();
 }
 }
 */

void draw2Dmap(int cls, int rws, int sc, int strCol) {
  stroke(0);
  strokeWeight(strCol);
  for (int y = -cls / 2; y < cls / 2; y++) {
    beginShape(TRIANGLE_STRIP);
    for (int x = -rws / 2; x < (rws + 2) / 2; x++) {
      fill(colr[x + rws / 2][y + cls / 2]);
      vertex(x * sc, y * sc);
      vertex(x * sc, (y + 1)*sc);
    }
    endShape();
  }
}

/*
void  drawMarkup(int cls, int rws, int sc) {
  int counter1 = 1;
  int counter2 = 1;
  for (int y = -cls; y < cls + 1; y++) {
    for (int x = -rws; x < rws + 1; x++) {
      stroke(50);
      strokeWeight(2);
      fill(0);
      textSize(36);
      if (y % 10 == 0) {
        line(x * sc - 50, y * sc, rws * sc + 50, y * sc);
        if (x == -rws && counter1 < 11) {
          text(counter1, x * sc - 70, y * sc + 40);
          counter1++;
        }
      }
      if (x % 10 == 0) {
        line(x * sc, y * sc - 50, x * sc, cls * sc + 50);
        if (y == -cls && counter2 < 11) {
          text(counter2, x * sc + 20, y * sc - 60);
          counter2++;
        }
      }
    }
  }
}
*/

void  drawMarkup(int cls, int rws, int sc) {
  int counter1 = 1;
  int counter2 = 1;
  for (int y = -cls / 2; y < cls / 2 + 1; y++) {
    for (int x = -rws / 2; x < rws / 2 + 1; x++) {
      stroke(50);
      strokeWeight(2);
      fill(0);
      textSize(20);
      if (y % 5 == 0) {
        line(x * sc - 20, y * sc, rws / 2 * sc + 20, y * sc);
        if (x == -rws / 2 && counter1 < 11) {
          text(counter1, x * sc - 30, y * sc + 20);
          counter1++;
        }
      }
      if (x % 5 == 0) {
        line(x * sc, y * sc - 20, x * sc, cls / 2 * sc + 20);
        if (y == -cls / 2 && counter2 < 11) {
          text(counter2, x * sc + 5, y * sc - 25);
          counter2++;
        }
      }
    }
  }
}

void printInfo(float mn, float mx) {
  textSize(20);
  fill(0);
  text("max: ", width - 150, height - 70);
  text(mx, width - 100, height - 70);
  text("min: ", width - 150, height - 50);
  text(mn, width - 100, height - 50);
}

int getZoomValue(int z, int dzoom) {
  if (mouseX > 200) z -= dzoom * 20;
  return z;
}

int getRotateX_Angle(int ang, int angY) {
  dx = mouseY - prevMouseX;
  if (mousePressed && (mouseButton == RIGHT) && mouseX > 200) {
    ang -= dx * cos(radians(angY));
  }
  prevMouseX = mouseY;
  return  ang;
}

int getRotateY_Angle(int ang) {
  dy = mouseX - prevMouseY;
  if (mousePressed && (mouseButton == RIGHT) && mouseX > 200) {
    ang += dy;
  }
  prevMouseY = mouseX;
  return  ang;
}

int getRotateZ_Angle(int ang, int angY) {
  dz = mouseY - prevMouseZ;
  if (mousePressed && (mouseButton == RIGHT) && mouseX > 200) {
    ang -= dz * sin(radians(angY));
  }
  prevMouseZ = mouseY;
  return  ang;
}

int getMotionX(int x) {
  dx = mouseX - prevMouseMoveX;
  if (mousePressed && (mouseButton == LEFT) && mouseX > posXpanel + 210) {
    x += dx;
  }
  prevMouseMoveX = mouseX;
  return x;
}

int getMotionY(int y) {
  dy = mouseY - prevMouseMoveY;
  if (mousePressed && (mouseButton == LEFT) && mouseX > posXpanel + 210) {
    y += dy;
  }
  prevMouseMoveY = mouseY;
  return y;
}

/*
void getNewData(int cls, int rws) {
 yoff = 0;
 for (int y = 0; y < cls * 2 + 1; y++) {
 xoff = 0;
 for (int x = 0; x < rws * 2 + 1; x++) {
 landscape[x][y] = map(noise(xoff, yoff), 0, 0.6, 0, 120);
 //println(landscape[x][y]);
 xoff += 0.025;
 
 if (x == 0 && y == 0) {
 min = landscape[x][y];
 max = landscape[x][y];
 }
 
 if (landscape[x][y] < min) {
 min = landscape[x][y];
 }
 if (landscape[x][y] > max) {
 max = landscape[x][y];
 }
 }
 yoff += 0.025;
 }
 
 thrd1 = (max - min) / 3;
 thrd2 = (max - min) * 2 / 3;
 
 for (int y = 0; y < cls * 2 + 1; y++) {
 for (int x = 0; x < rws * 2 + 1; x++) {
 alt = landscape[x][y] - min;
 if (alt < thrd1) {
 colG = (int)(alt / thrd1 * 255);
 colr[x][y] = color(0, colG, 255);
 } else if (alt >= thrd1 && alt <= thrd2) {
 colR = (int)((alt - thrd1) / (thrd2 - thrd1) * 255);
 colB = (int)(255 - colR);
 colr[x][y] = color(colR, 255, colB);
 } else if (alt >= thrd2) {
 colG = (int)((1 - ((alt - thrd2) / (max - thrd2))) * 255);
 colr[x][y] = color(255, colG, 0);
 }
 }
 }
 }
 */

void loadupDataFromFile() {
  textLines = loadStrings("data.txt");
  for (int i = 0; i < textLines.length; i++) {
    currentLine = split(textLines[i], ",");

    for (int j = 0; j < textLines.length; j++) {
      landscape[i][j % 50] = int(currentLine[j]);

      if (i == 0 && j % 50 == 0) {
        min = landscape[i][j % 50];
        max = landscape[i][j % 50];
      }

      if (landscape[i][j % 50] < min) {
        min = landscape[i][j % 50];
      }
      if (landscape[i][j % 50] > max) {
        max = landscape[i][j % 50];
      }
    }

    thrd1 = (max - min) / 3;
    thrd2 = (max - min) * 2 / 3;

    for (int y = 0; y < 50; y++) {
      for (int x = 0; x < 50; x++) {
        alt = landscape[x][y] - min;
        if (alt < thrd1) {
          colG = (int)(alt / thrd1 * 255);
          colr[x][y] = color(0, colG, 255);
        } else if (alt >= thrd1 && alt <= thrd2) {
          colR = (int)((alt - thrd1) / (thrd2 - thrd1) * 255);
          colB = (int)(255 - colR);
          colr[x][y] = color(colR, 255, colB);
        } else if (alt >= thrd2) {
          //println("get RED");
          colG = (int)((1 - ((alt - thrd2) / (max - thrd2))) * 255);
          colr[x][y] = color(255, colG, 0);
        }
      }
    }
  }
}

void mouseWheel(MouseEvent event) {
  dzoom = event.getCount();
}

/*
void drawShadow(int cls, int rws, int sc) {
 noStroke();
 fill(200);
 rect(-cls * sc, -rws * sc, cls * sc * 2, rws * sc * 2);
 }
 */

void drawShadow(int cls, int rws, int sc) {
  noStroke();
  fill(200);
  rect(-cls / 2 * sc, -rws / 2 * sc, cls * sc, rws * sc);
}

void drawPanel(int xpos) {
  fill(105, 105, 105, 240);
  stroke(47, 79, 79);
  rect(xpos, -10, 210, height, 10);

  panelLockBTN(xpos);

  mode3dBTN(xpos);
  mode2dBTN(xpos);
  modeNoneBTN(xpos);

  gridSwitcherBTN(xpos);
  dataRenewerBTN(xpos);
  markupSwitcherBTN(xpos);
  isometryBTN(xpos);
  screenShoterBTN(xpos);
  //dataSaverBTN(xpos);
  //dataUploaderBTN(xpos);
}

void panelLockBTN(int xpos) {
  btns[6] = buttonSpec(xpos + 220, 10, 30, 30, btns[6], 6);
  openPanel(xpos);
  closePanel(xpos);

  rect(xpos + 220, 10, 30, 30);
  textSize(25);
  fill(255);
  if (xpos == -10) {
    text("<<", xpos + 223, 32);
  } else {
    text(">>", xpos + 223, 32);
  }
}

void openPanel(int xpos) {
  if (btns[6] == 1 && flag6btn == 0) {
    posXpanel = moveFunction(xpos, -212);
    if (xpos == -211) {
      btns[6] = 0;
      flag6btn = 1;
    }
  }
}

void closePanel(int xpos) {
  if (btns[6] == 1 && flag6btn == 1) {
    posXpanel = moveFunction(xpos, -9);
    if (posXpanel == -10) {
      btns[6] = 0;
      flag6btn = 0;
    }
  }
}

void mode3dBTN(int xpos) {
  btns[0] = buttonSpecStiky(xpos + 20, 10, 60, 60, btns[0], 0);
  if (btns[0] == 1) {
    btns[8] = 0;
    btns[9] = 0;
  }
  rect(xpos + 20, 10, 60, 60);
  textSize(30);
  fill(255);
  text("3D", xpos + 35, 50);
}

void mode2dBTN(int xpos) {
  btns[8] = buttonSpecStiky(xpos + 81, 10, 58, 60, btns[8], 8);
  if (btns[8] == 1) {
    btns[0] = 0;
    btns[9] = 0;
  }
  rect(xpos + 81, 10, 58, 60);
  textSize(30);
  fill(255);
  text("2D", xpos + 96, 50);
}

void modeNoneBTN(int xpos) {
  btns[9] = buttonSpecStiky(xpos + 140, 10, 60, 60, btns[9], 9);
  if (btns[9] == 1) {
    btns[8] = 0;
    btns[0] = 0;
  } else if ( btns[0] == 0 && btns[8] == 0 && btns[9] == 0) {
    btns[9] = 1;
  }
  rect(xpos + 140, 10, 60, 60);
  textSize(20);
  fill(255);
  text("поле", xpos + 147, 45);
}

void dataRenewerBTN(int xpos) {
  if (btns[9] == 1) {
    fill(140, 140, 140);
    noStroke();
  } else {
    btns[2] = buttonSpec(xpos + 30, 90, 160, 80, btns[2], 2);
  }

  rect(xpos + 30, 90, 160, 60);
  textSize(20);
  fill(255);
  text("Новые данные", xpos + 45, 125);
  //text("пока не работает!", xpos + 30, 145);
}

void gridSwitcherBTN(int xpos) {
  if (btns[9] == 1) {
    fill(140, 140, 140);
    noStroke();
  } else {
    btns[1] = buttonSpecStiky(xpos + 110, 160, 80, 50, btns[1], 1);
  }
  rect(xpos + 111, 160, 79, 60);
  textSize(20);
  fill(255);
  text("сетка", xpos + 127, 195);
}

void markupSwitcherBTN(int xpos) {
  btns[3] = buttonSpecStiky(xpos + 30, 160, 80, 50, btns[3], 3);
  rect(xpos + 30, 160, 79, 60);
  textSize(18);
  fill(255);
  text("разметка", xpos + 33, 195);
}

void isometryBTN(int xpos) {
  if (btns[8] == 1 || btns[9] == 1) {
    fill(140, 140, 140);
    noStroke();
  } else {
    btns[7] = buttonSpec(xpos + 30, 230, 160, 60, btns[7], 7);
  }
  rect(xpos + 30, 230, 160, 60);
  textSize(18);
  fill(255);
  text("изометрия 3D", xpos + 55, 265);
}

void screenShoterBTN(int xpos) {
  btns[5] = buttonSpec(xpos + 30, 300, 160, 60, btns[5], 5);
  if (btns[5] == 1) {
    btns[5] = 0;
    posXpanel = -212;
    selectOutput("Select a file to write to:", "fileSelected");
  }
  rect(xpos + 30, 300, 160, 60);
  textSize(18);
  fill(255);
  text("Снимок", xpos + 75, 335);
}

void fileSelected(File selection) {
  if (selection == null) {
    println("Window was closed or the user hit cancel.");
  } else {
    screenPath = (selection.getAbsolutePath() + ".jpg");
  }
}

int buttonSpec(int btnX, int btnY, int btnW, int btnH, int stat, int n) {
  fill(colBTN[0]);
  noStroke();
  if (mouseX >= btnX && mouseX <= btnX + btnW &&
    mouseY >= btnY && mouseY <= btnY + btnH) {
    fill(colBTN[1]);
    noStroke();
  }
  if (mouseX >= btnX && mouseX <= btnX + btnW
    && mouseY >= btnY && mouseY <= btnY + btnH
    && mousePressed && (mouseButton == LEFT) && btnFlags[n] == 0) {
    fill(colBTN[2]);
    noStroke();
    btnFlags[n] = 1;
  } else if (btnFlags[n] == 1 && mousePressed == false) {
    stat = stat * (-1) + 1;
    btnFlags[n] = 0;
  }
  if (mouseX >= btnX && mouseX <= btnX + btnW
    && mouseY >= btnY && mouseY <= btnY + btnH
    && mousePressed && (mouseButton == LEFT)) {
    fill(colBTN[2]);
    noStroke();
  }
  return stat;
}

int buttonSpecStiky(int btnX, int btnY, int btnW, int btnH, int stat, int n) {
  fill(colBTN[0]);
  noStroke();
  if (mouseX >= btnX && mouseX <= btnX + btnW &&
    mouseY >= btnY && mouseY <= btnY + btnH) {
    fill(colBTN[1]);
    noStroke();
  }
  if (mouseX >= btnX && mouseX <= btnX + btnW
    && mouseY >= btnY && mouseY <= btnY + btnH
    && mousePressed && (mouseButton == LEFT) && btnFlags[n] == 0) {
    fill(colBTN[2]);
    noStroke();
    btnFlags[n] = 1;
  } else if (btnFlags[n] == 1 && mousePressed == false) {
    stat = stat * (-1) + 1;
    btnFlags[n] = 0;
  }
  if (stat == 1) {
    fill(colBTN[3]);
    strokeWeight(2);
    stroke(255);
  }
  if (mouseX >= btnX && mouseX <= btnX + btnW
    && mouseY >= btnY && mouseY <= btnY + btnH
    && mousePressed && (mouseButton == LEFT)) {
    fill(colBTN[2]);
    noStroke();
  }
  return stat;
}
