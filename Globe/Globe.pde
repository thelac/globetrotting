BufferedReader reader;
int rad = 200;
String[] border;
float sx, sy, sz;
float[][] coords;
float b,c,d,e;
Agent a;
boolean watch;

void setup() {
  size(800, 800, P3D);
  background(0);
  
  readCoords();
  generateAgent();
  watch = false;
}

void mouseClicked() {
  generateAgent(); 
}

void keyPressed() {
  switch(key) {
    case '1': zoom(0, 0, 10);
      break;
    case '2': zoom(0, 0, -10);
      break;
    case 'w': zoom(0, 10, 0);
      break;
    case 's': zoom(0, -10, 0);
      break;
    case 'a': zoom(10, 0, 0);
      break;
    case 'd': zoom(-10, 0, 0);
      break;
    case 'z': watch = !watch;
  }
}

void zoom(float x1, float y1, float z1) {
  sx -= x1; sy -= y1; sz -=z1;
}

void generateAgent() {
  b = random(-PI, PI);//-85.67 * PI / 180;//
  c = random(-PI/2, PI/2);//42.96 * PI / 180;//
  d = random(-PI, PI);//121.00 * PI / 180;//
  e = random(-PI/2, PI/2);//31.00 * PI / 180;//
  a = new Agent(b,c,d,e);
  a.follow = true;
  println("lon_s: " + round(degrees(a.lon_s)) + " lat_s: " + round(degrees(a.lat_s)));
  println("lon_n: " + round(degrees(a.lon_n)) + " lat_n: " + round(degrees(a.lat_n)));
  println();

}
 
void draw() {

 background(0);
 float z_rot = map(mouseX, 0, width, 0, 2*TWO_PI);
 float y_rot = map(mouseY, 0, height, 0, 2*TWO_PI);
 stroke(255);
 translate(800 / 2 + sx, 800 / 2 + sy, sz);

 pushMatrix();
 rotateX(PI/2);
 rotateZ(PI/2);
 rotateZ(z_rot);
 a.draw();
 //drawAxes();
 render();
 popMatrix();
 fill(0);

}

void render() {
  for(int i = 0; i < border.length; i++)
    drawCoords(coords[i][0], coords[i][1]);
}

void drawCoords(float lon, float lat) {
  pushStyle();
  stroke(80, 80, 80);
  pushMatrix();
  rotateZ(-lon);
  rotateY(-lat);
  point(rad, 0, 0);
  popMatrix();
  popStyle();
}

void drawLine(float lon, float lat) {
  pushMatrix();
  rotateZ(-lon);
  rotateY(-lat);
  line(0,0,0,rad, 0, 0);
  popMatrix();
}

void drawPathVec() {
  pushStyle();
  strokeWeight(3);
  stroke(255, 255, 0);
  drawLine(a.lon_s, a.lat_s);
  stroke(0, 255, 255);
  drawLine(a.lon_f, a.lat_f);
  stroke(100,180,200);
  drawLine(a.lon_n, a.lat_n);
  strokeWeight(1);
}

float coordX(float lon, float lat) {
  return(rad*cos(lat)*cos(lon));
}

float coordY(float lon, float lat) {
  return(-rad*cos(lat)*sin(lon));
}

float coordZ(float lon, float lat) {
  return(rad*sin(lat)); 
}

void readCoords() {
  border = loadStrings("border.csv");
  coords = new float[border.length][2];
  
  for(int i = 0; i < border.length; i++) {
    int idx = border[i].indexOf(TAB);
    coords[i][0] = float(border[i].substring(0, idx)) * PI / 180;
    coords[i][1] = float(border[i].substring(idx + 1, border[i].length())) * PI / 180;
  }
}
class Agent {

  float lon_s, lat_s, lon_f, lat_f, lon_n, lat_n;
  float angle_sf, angle_zn;
  float pos, speed;
  int step;
  PVector n;
  PVector x;
  PVector y;
  PVector z;
  boolean follow = false;
  boolean arrived = false;
  
  Agent(float lon_s, float lat_s, float lon_f, float lat_f) {
    this.lon_s = lon_s;
    this.lat_s = lat_s;
    this.lon_f = lon_f;
    this.lat_f = lat_f;
    
    PVector s = getV(lon_s, lat_s);
    PVector f = getV(lon_f, lat_f);
    n = s.cross(f);
    n.normalize();
    n.mult(-1);
    
    lat_n = asin(n.z);
    lon_n = atan2(-n.y, n.x);
    
    angle_sf = PVector.angleBetween(s, f);
    println(abs(angle_sf) + " " + pos);
    angle_sf = angle_sf > PI ? angle_sf - TWO_PI : angle_sf;
    println(abs(angle_sf) + " " + pos);
    
    x = new PVector(1, 0, 0);
    y = new PVector(0, 1, 0);
    z = new PVector(0, 0, 1);
    
    y = rotateV(y, z, -lon_s);
    x = rotateV(x, z, -lon_s);
    x = rotateV(x, y, -lat_s);
    z = rotateV(z, y, -lat_s);
    
    angle_zn = PVector.angleBetween(z, n);
    z = rotateV(z, x, -angle_zn);
    
    if(abs(PVector.angleBetween(z, n)) > 0.001) angle_zn *= -1;
    pos = 0;
    step = 0;
  }
  
  void draw() {
    pushStyle();
    stroke(#60dfe5);
    if(follow) {
      if ((pos -= PI / 360) <= -angle_sf) follow = false;
      
      step++;
    }
      if(watch) {
        rotateZ(-pos); 
      }
      pushMatrix();
      if(!watch){
        rotateZ(-lon_s);
        rotateY(-lat_s);
        rotateX(-angle_zn); 
      }
      for(int i = 0; i < step - 1; i++) {
        rotateZ(-PI / 360);
        point(rad, 0, 0);
      }
      
      popMatrix();
      
      if(watch) {
        rotateX(angle_zn);
        rotateY(lat_s);
        rotateZ(lon_s); 
      }
      popStyle();
  }
  
  PVector getV(float lon, float lat) {
    return(new PVector(cos(lat)*cos(lon), -cos(lat)*sin(lon), sin(lat)));
  }
  
  PVector rotateV(PVector vec, PVector axis, float theta) {
    
    vec.normalize();
    axis.normalize();
  
    float x = vec.x;
    float y = vec.y;
    float z = vec.z;
    float u = axis.x;
    float v = axis.y;
    float w = axis.z;
    
    float c = cos(theta);
    float s = sin(theta);
    
    float d = u*x + v*y + w*z;
    
    return(new PVector(
      u*d*(1-c)+x*c+(-w*y+v*z)*s,
      v*d*(1-c)+y*c+(-u*z+w*x)*s,
      w*d*(1-c)+z*c+(-v*x+u*y)*s));
  }
}

void drawAxes() {
 pushStyle();
 //Red is x axis
 stroke(255, 0 ,0);
 line(0, 0, 0, 800 / 2, 0, 0);
 
 //Green is y axis
 stroke(0, 255, 0);
 line(0, 0, 0, 0, 800 / 2, 0);
 
 //Blue is z axis
 stroke(0, 0, 255);
 line(0, 0, 0, 0, 0, 800 / 2);
 popStyle();
}
