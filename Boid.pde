final int N = 400;
final float NDist = 30;
final float CConst = 1;
final float AConst = 1;
final float SConst = 1;
final float OConst = 1;
final float AvoidDist = 30;
final float MaxVel = 2;


boolean visible(boid b1, boid b2) {
  PVector v = PVector.sub(b2.pos, b1.pos).normalize();
  PVector nv = b1.vel.copy().normalize();
  float dot = v.dot(nv);
  float dist = b1.pos.dist(b2.pos);
  
  if(dist < NDist) {
    return true;
  }
  else {
    return false;
  }
}


class boid {
  PVector pos;
  PVector vel;
  PVector acc;
  ArrayList<boid> visibleboids;
  color col;
  
  boid() {
    pos = new PVector(random(0, width), random(0, height));
    vel = new PVector(random(-1, 1), random(-1, 1));
    acc = new PVector(0, 0);
    visibleboids = new ArrayList<boid>();
    col = color(random(0, 255), random(0, 255), random(0, 255));
  }
  
  
  void update() {
    pos.add(vel);
    vel.add(acc);
    vel.limit(MaxVel);
    
    if(pos.x < 0) {
      pos.x = width;
    }
    if(pos.x > width) {
      pos.x = 0;
    }
    if(pos.y < 0) {
      pos.y = height;
    }
    if(pos.y > height) {
      pos.y = 0;
    }
    
    visibleboids.clear();
  }
  
  
  void draw() {
    fill(col);
    stroke(col);
    ellipse(pos.x, pos.y, 10, 10);
    stroke(color(255));
    line(pos.x, pos.y, pos.x + vel.x*5, pos.y + vel.y*5);
  }
}


class obstacle {
  PVector pos;
  
  obstacle(PVector _pos) {
    pos = _pos.copy();
  }
  
  
  void draw() {
    stroke(color(255));
    fill(color(255));
    rect(pos.x, pos.y, 10, 10);
  }
}


class boidsystem {
  boid[] boids;
  ArrayList<obstacle> obstacles;
  
  boidsystem() {
    boids = new boid[N];
    for(int i = 0; i < N; i++) {
      boids[i] = new boid();
    }
    
    obstacles = new ArrayList<obstacle>();
  }
  
  
  void update() {
    for(boid b : boids) {
      b.update();
      
      //Update Visible Boids
      for(boid b2 : boids) {
        if(b != b2) {
          if(visible(b, b2)) {
            b.visibleboids.add(b2);
          }
        }
      }
      
      //Calculate Velocity
      int size = b.visibleboids.size();
      PVector center = new PVector(0, 0);
      PVector averageVel = new PVector(0, 0);
      PVector separationAcc = new PVector(0, 0);
      for(boid b2 : b.visibleboids) {
        PVector pdif = PVector.sub(b2.pos, b.pos).normalize();
        center.add(PVector.div(b2.pos, size));
        averageVel.add(PVector.div(b2.vel, size));
        separationAcc.add(PVector.mult(pdif, -1));
      }
      
      PVector avoidAcc = new PVector(0, 0);
      for(obstacle o : obstacles) {
        float dist = o.pos.dist(b.pos);
        if(dist < AvoidDist) {
         avoidAcc.add(PVector.sub(b.pos, o.pos).normalize());
        }
      }
      
      PVector CAcc = PVector.mult(PVector.sub(center, b.pos).normalize(), CConst);
      PVector AAcc = PVector.mult(averageVel, AConst);
      PVector SAcc = PVector.mult(separationAcc, SConst);
      PVector OAcc = PVector.mult(avoidAcc, OConst);
      PVector nextAcc = new PVector(0, 0);
      if(size > 0) {
        nextAcc.add(CAcc);
        nextAcc.add(AAcc);
        nextAcc.add(SAcc);
        nextAcc.add(OAcc);
      }
      
      b.acc = nextAcc.copy();
    }
  }
  
  
  void draw() {
    for(boid b : boids) {
      b.draw();
    }
    
    for(obstacle o : obstacles) {
      o.draw();
    }
  }
  
  
  void add_obstacle(PVector _pos) {
    obstacles.add(new obstacle(_pos));
  }
}


boidsystem bsys;


void setup() {
  size(1600, 900);
  background(0);
  bsys = new boidsystem();
}


void draw() {
  background(0);
  bsys.update();
  bsys.draw();
}


void mouseDragged() {
  bsys.add_obstacle(new PVector(mouseX, mouseY));
}