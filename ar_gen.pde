import com.krab.lazy.*;

ArrayList<String> smodes = new ArrayList<String>();

LazyGui gui;
final String 
  G_F_SETTINGS = "Настройки/", G_F_SAVE = "Сохранить/", G_F_SETWEIGHTS = "Веса/",
  G_GENERATE = "Сгенерировать",
  G_SETSETT = "Установить",
  G_W = "Ширина",
  G_H = "Высота",
  G_MODE = "Режим",
  G_SAVEONE = "Сохранить текущий",
  G_SAVEMULT = "Сохранить набор",
  G_SETSNUM = "Количество листов",
  G_BATCHNAME = "Название";

int w, h;
int mode;
String title;
float title_text_size=32, eq_text_size=36, sq_size=36, s111_1zero=0.9, s111_2zero=0.9, s111_3zero=0.9;
float eq_width, cell_w, cell_h;

final String eq_font_name = "Merienda", title_font_name = "Bahnschrift";
PFont eq_font, title_font;

Eq[][] eqset;

void setup() {
  size(210*3, 297*3, P2D);
  background(255);
  gui = new LazyGui(this);
  
  smodes.add("1-1-1");
  smodes.add("1-1-2");
  smodes.add("Сумма 10");
  smodes.add("10-");
  
  initGui();
  setSettings();
  generateSet();
  drawSet();
}

void draw() {
  // Save set
  if (gui.button(G_F_SAVE+G_SAVEONE)) {
    gui.hideGui();
    drawSet();
    save("Image.png");
    gui.showGui();
  }
  else if (gui.button(G_F_SAVE+G_SAVEMULT)) {
    saveMult();
  }
  else if (gui.button(G_GENERATE)) {
    //setSettings();
    generateSet();
  }
  else if (gui.button(G_F_SETTINGS+G_SETSETT)) {
    setSettings();
  }
  
  drawSet();
}

// =============================================================================================================================================================
class Eq {
  String start, end;
  
  boolean sameas(Eq e) {
    return (start.equals(e.start)) && (end.equals(e.end));
  }
}

void initGui() {
  gui.pushFolder(G_F_SAVE);
  int batch_num = gui.sliderInt(G_SETSNUM, 2, 1, 100);
  String batch_name = gui.text(G_BATCHNAME, "task_");
  gui.popFolder();
}

void generateSet() {
  w = gui.sliderInt(G_W, 3, 1, 6);
  h = gui.sliderInt(G_H, 12, 1, 20);
  String smode = gui.radio(G_MODE, smodes);
  mode = smodes.indexOf(smode);
  cell_w = width/w;
  cell_h = height/(h+1);
  
  eqset = new Eq[w][h];
  for (int col = 0; col < w; col++) {
    for (int row = 0; row < h; row++) {
      do {
        switch (mode) {
          case 0:
            eqset[col][row] = mode_111();
            break;
          case 1:
            eqset[col][row] = mode_112();
            break;
          case 2:
            eqset[col][row] = mode_sum10();
            break;
          case 3:
            eqset[col][row] = mode_10minus();
            break;
        }
      } while (row == 0 ? false : eqset[col][row].sameas(eqset[col][row-1]));
    }
  }
}

void setSettings() {
  gui.pushFolder(G_F_SETTINGS);
  title_text_size=gui.slider("title_text_size",title_text_size);
  eq_text_size=gui.slider("eq_text_size",eq_text_size);
  sq_size=gui.slider("sq_size",sq_size);
  gui.pushFolder(G_F_SETWEIGHTS);
  s111_1zero = 1 - gui.slider("111: 1st 0", 1-s111_1zero, 0, 1);
  s111_2zero = 1 - gui.slider("111: 2nd 0", 1-s111_2zero, 0, 1);
  s111_3zero = 1 - gui.slider("111: 3rd 0", 1-s111_3zero, 0, 1);
  gui.popFolder();
  gui.popFolder();
  
  eq_font = createFont(eq_font_name, eq_text_size);
  title_font = createFont(title_font_name, title_text_size);
}

void drawSet() {
  background(255);

  title = gui.text("Заголовок", "");
  // Draw title
  textFont(title_font);
  fill(0);
  textAlign(CENTER, CENTER);
  text(title, width/2, cell_h/2);
  
  // Draw equations
  textFont(eq_font);
  fill(0);
  for (int col = 0; col < w; col++) {
    for (int row = 0; row < h; row++) {
      drawEx(col*cell_w, (row+1.5)*cell_h, eqset[col][row]);
    }
  }
}

void drawEx(float lx, float cy, Eq eq) {
  float s_eq_width = textWidth(eq.start) + sq_size + textWidth(eq.end);
  textAlign(LEFT, CENTER);
  text(eq.start, lx + cell_w/2 - s_eq_width/2, cy);
  // Square
  rectMode(CENTER);
  fill(255);
  stroke(0);
  square(lx + cell_w/2 - s_eq_width/2 + textWidth(eq.start) + sq_size/2, cy, sq_size);
  fill(0);
  textAlign(RIGHT, CENTER);
  text(eq.end, lx + cell_w/2 + s_eq_width/2, cy);
}

void saveMult() {
  gui.pushFolder(G_F_SAVE);
  int batch_num = gui.sliderInt(G_SETSNUM, 2, 1, 100);
  String batch_name = gui.text(G_BATCHNAME, "task_");
  gui.popFolder();
  
  gui.hideGui();
  for (int i = 0; i < batch_num; i++) {
    generateSet();
    drawSet();
    save(batch_name + str(i) + ".png");
  }
  gui.showGui();
}

// Equation generators
int x,y,z,qpos;
boolean plus;
char sign;

// All 1-digit combinations
Eq mode_111() {
  z = floor(random(0+s111_3zero, 10));
  plus = random(2) >= 1;
  if (plus) {
    x = floor(random(max(z-9, 0+s111_1zero), z-s111_2zero + 1));
    y = z-x;
    sign = '+';
  } else {
    x = floor(random(z+s111_2zero, 10));
    y = x-z;
    sign = '-';
  }
  
  qpos = floor(random(3));
  Eq neq = new Eq();
  switch (qpos) {
    case 0:  // x
      neq.start = "";
      neq.end = String.format(" %c %d = %d", sign, y, z);
      break;
    case 1:  // y
      neq.start = String.format("%d %c ", x, sign);
      neq.end = String.format(" = %d", z);
      break;
    case 2:  // z
      neq.start = String.format("%d %c %d = ", x, sign, y, z);
      neq.end = "";
      break;
  }
  
  return neq;
}

// All combinations with one 2-digit number
int pos2;
Eq mode_112() {
  plus = random(2) >= 1;
  // "+" => z > 9, "-" => x > 9
  z = plus ? 10+floor(random(9)) : floor(random(1, 10));
  if (plus) {
    x = floor(random(max(z-9, 0), min(9, z) + 1));
    y = z-x;
    sign = '+';
  } else {
    x = plus ? floor(random(z, 10)) : floor(random(10, 9+z + 1));
    y = x-z;
    sign = '-';
  }
  
  qpos = floor(random(3));
  Eq neq = new Eq();
  switch (qpos) {
    case 0:  // x
      neq.start = "";
      neq.end = String.format(" %c %d = %d", sign, y, z);
      break;
    case 1:  // y
      neq.start = String.format("%d %c ", x, sign);
      neq.end = String.format(" = %d", z);
      break;
    case 2:  // z
      neq.start = String.format("%d %c %d = ", x, sign, y, z);
      neq.end = "";
      break;
  }
  
  return neq;
}

// Sum = 10
Eq mode_sum10() {
  sign = '+';
  z = 10;
  x = floor(random(1, 10));
  y = z - x;
  
  qpos = floor(random(3));
  Eq neq = new Eq();
  switch (qpos) {
    case 0:  // x
      neq.start = "";
      neq.end = String.format(" %c %d = %d", sign, y, z);
      break;
    case 1:  // y
      neq.start = String.format("%d %c ", x, sign);
      neq.end = String.format(" = %d", z);
      break;
    case 2:  // z
      neq.start = String.format("%d %c %d = ", x, sign, y, z);
      neq.end = "";
      break;
  }
  return neq;
}

// 10-
Eq mode_10minus() {
  sign = '-';
  x = 10;
  
  y = floor(random(1, 10));
  qpos = floor(random(2));
  
  Eq neq = new Eq();
  switch (qpos) {
    case 0:  // y
      neq.start = "10 - ";
      neq.end = String.format(" = %d", z);
      break;
    case 1:  // z
      neq.start = String.format("10 - %d = ", y, z);
      neq.end = "";
      break;
  }
  return neq;
}
