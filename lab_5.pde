// State System 
int state = 0; // 0: Start, 1: Play, 2: Game Over, 3: Win

// Player Physics Variables 
float px, py;      // Position
float vx, vy;      // Velocity
float accel = 0.8; 
float friction = 0.9;
float gravity = 0.5;
float jumpForce = -12;
float pR = 20;     // Player Radius

// Enemy Arrays (8 Enemies) 
int numEnemies = 8;
float[] ex = new float[numEnemies];
float[] ey = new float[numEnemies];
float[] evx = new float[numEnemies];
float[] evy = new float[numEnemies];
float eR = 15;     // Enemy Radius

// Timer & Health [cite: 2, 5, 6]
int startTime;
int duration = 30; // Seconds to survive
int lives = 3;
boolean canHit = true;
int lastHitTime = 0;
int hitCooldownMs = 800;

void setup() {
  size(800, 600);
  resetGame();
}

void draw() {
  background(20);
  
  if (state == 0) drawStart();
  else if (state == 1) updateGame();
  else if (state == 2) drawGameOver();
  else if (state == 3) drawWin();
}

void resetGame() {
  px = width/2;
  py = height - 50;
  vx = 0; vy = 0;
  lives = 3;
  state = 0;
  
  // Initialize Enemies 
  for (int i=0; i < numEnemies; i++) {
    ex[i] = random(width);
    ey[i] = random(height/2);
    evx[i] = random(-4, 4);
    evy[i] = random(-4, 4);
  }
}

void updateGame() {
  // 1. Timer Logic [cite: 2]
  int elapsed = (millis() - startTime) / 1000;
  int remaining = duration - elapsed;
  if (remaining <= 0) state = 3;

  // 2. Player Movement (Accel + Friction) 
  if (keyPressed) {
    if (keyCode == LEFT) vx -= accel;
    if (keyCode == RIGHT) vx += accel;
  }
  vx *= friction;
  px += vx;
  
  // 3. Jump Physics (Gravity) 
  vy += gravity;
  py += vy;
  if (py > height - pR) {
    py = height - pR;
    vy = 0;
  }
  
  // 4. Enemy Movement & Collision [cite: 4, 5]
  for (int i=0; i < numEnemies; i++) {
    ex[i] += evx[i];
    ey[i] += evy[i];
    
    // Bouncing logic
    if (ex[i] < 0 || ex[i] > width) evx[i] *= -1;
    if (ey[i] < 0 || ey[i] > height) evy[i] *= -1;
    
    // Collision Detection 
    float d = dist(px, py, ex[i], ey[i]);
    if (d < pR + eR && canHit) {
      lives--;
      canHit = false;
      lastHitTime = millis();
      if (lives <= 0) state = 2;
    }
  }
  
  // Hit Cooldown Reset 
  if (!canHit && millis() - lastHitTime > hitCooldownMs) {
    canHit = true;
  }

  // Draw Everything
  fill(0, 255, 100);
  ellipse(px, py, pR*2, pR*2); // Player
  
  fill(255, 50, 50);
  for (int i=0; i<numEnemies; i++) ellipse(ex[i], ey[i], eR*2, eR*2); // Enemies
  
  fill(255);
  textSize(20);
  text("Lives: " + lives, 20, 30);
  text("Time: " + remaining, 20, 60);
}

// UI Screens
void drawStart() {
  textAlign(CENTER);
  text("DODGE & SURVIVE\nPress ENTER to Start", width/2, height/2);
}

void drawGameOver() {
  background(150, 0, 0);
  text("GAME OVER\nPress R to Restart", width/2, height/2);
}

void drawWin() {
  background(0, 150, 50);
  text("YOU WIN!\nPress R to Restart", width/2, height/2);
}

void keyPressed() {
  if (state == 0 && keyCode == ENTER) {
    state = 1;
    startTime = millis();
  }
  if (key == ' ' && py >= height - pR) vy = jumpForce; // Jump
  if ((state == 2 || state == 3) && (key == 'r' || key == 'R')) resetGame();
}
