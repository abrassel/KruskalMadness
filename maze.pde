import java.util.Collections;
import java.util.Set;
import java.util.HashSet;
import java.util.Iterator;
import java.util.List;
import java.util.LinkedList;
import java.util.Arrays;
import java.util.Map;

  static final PVector up = new PVector(0, 1);
  static final PVector left = new PVector(-1, 0);
  static final PVector right = new PVector(0, -1);
  static final PVector down = new PVector(1, 0);
  static final PVector mazesize = new PVector(25, 15); //25 15
  PImage[] images;
 
  
  Set<Set<PVector>> point_sets;
  Set<Wall> wallImages = new HashSet<Wall>();
  Set<PVector> wallLocations = new HashSet<PVector>();
  
  
  PImage standing;
  PImage forward;
  PImage backwards;
  PImage kruskal;
  
  
  PImage[] movingImgUp = new PImage[3];
  PImage[] movingImgSide = new PImage[2];
  
  PImage floor;
  PVector playerLoc;
  
  PVector direction = new PVector(0,0);
  PFont font;
  PFont font2;
  void setup() {
    font = createFont ("Serif",height/20);
    font2 = createFont ("Serif",height/40);
    textFont (font);
    background(155, 155, 155);
    playerLoc = new PVector(0,0);
    fullScreen();
    floor = loadImage("floor.jpg");
    standing = loadImage("standing.png");
    forward  = loadImage("walkingone.png");
    backwards = loadImage("walkingtwo.png");
    kruskal  = loadImage("clyde.gif");
    PImage left = loadImage("walkingsideone.png");
    PImage right = loadImage("walkingsidetwo.png");
    
    
    floor.resize((int) (width / mazesize.x), (int) (height / mazesize.y));
    
    PImage[] images = { loadImage("papers.png"), loadImage("mdew.jpg"), loadImage("folders.jpg")};
    for (PImage image: images) {
      image.resize((int) (width / mazesize.x), (int) (height / mazesize.y));
    }
    
    kruskal.resize((int) (width / mazesize.x) * 2, (int) (height / mazesize.y) * 3);
    standing.resize((int) (width / mazesize.x), (int) (height / mazesize.y));
    forward.resize((int) (width / mazesize.x), (int) (height / mazesize.y));
    backwards.resize((int) (width / mazesize.x), (int) (height / mazesize.y));
    left.resize((int) (width / mazesize.x), (int) (height / mazesize.y));
    right.resize((int) (width / mazesize.x), (int) (height / mazesize.y));
    
    movingImgUp[0] = forward;
    movingImgUp[1] = standing;
    movingImgUp[2] = backwards;
    movingImgSide[0] = left;
    movingImgSide[1] = right;
    
    curImage = standing;
    
    point_sets = new HashSet<Set<PVector>>();
    Bag<Wall> walls = new Bag<Wall>();
    List<Wall> seenandkept = new LinkedList<Wall>();
    WallFactory f = new WallFactory(images);

    
    for (int x = 0; x < mazesize.x; x++) {
      for (int y = 0; y < mazesize.y; y++) {
        if (mazesize.y - y < 5 && mazesize.x - x < 5)
          continue;
        if (y < 5 && x < 5)
          continue;
        
        if (x % 2 == 1 && y % 2 == 1) {
          Set<PVector> point = new HashSet<PVector>();
          point.add(new PVector(x,y));
          point_sets.add(point);
        }
        else {
          walls.put(f.make(new PVector(x,y)));
        }

      }
    }
    
    walls.shuffle();

    while (point_sets.size() > 3 && walls.size() > 0) { //<>//
      Wall w = walls.pop();
      PVector location = w.location;
      Set<PVector> propegated = new HashSet<PVector>();
      propegated.add(location);
      boolean addedSomething = false;
      boolean addedTwoSomethings = false;
      for (PVector n : w.neighbors()) {

        for (Set<PVector> s : point_sets) {
          if (s.contains(n)) {
            addedSomething = true;
            if (addedSomething) {
              addedTwoSomethings = true;
            }
            propegated.addAll(s);
            point_sets.remove(s);
            break;
          }
        }
      }
      if (!addedTwoSomethings) {
        walls.put(w);
      }
      point_sets.add(propegated);
      
      
    }
    

    
    for (Wall wall: walls) {
      wallImages.add(wall);
      wallLocations.add(wall.location);
    }
    
    for (Wall wall : seenandkept) {
      wallImages.add(wall);
      wallLocations.add(wall.location);
    }
    
    
    
    
  }
  
  boolean gameOver = false;
  int moving = 0;
  PVector saved = null;
  PImage curImage;
  void draw() {
    background(10197915);
    textAlign(CENTER,CENTER);
    for (Wall wall : wallImages) {
      image(wall.image, wall.location.x * width/mazesize.x, wall.location.y * height/mazesize.y);   
    }
    
    image(kruskal, (mazesize.x - 3) * width/mazesize.x, (mazesize.y - 3.5) * height/mazesize.y);
    
    image(curImage, playerLoc.x * width/mazesize.x, playerLoc.y * height/mazesize.y);
    
    if (mazesize.y - playerLoc.y < 5 && mazesize.x - playerLoc.x < 5) {
      fill(255, 255, 255);
      rect(width/mazesize.x * (mazesize.x - 10), height/mazesize.y * (mazesize.y - 5), width, height);
      fill(0x000000);
      image(kruskal, (mazesize.x - 4) * width/mazesize.x, (mazesize.y - 3.5) * height/mazesize.y);
      image(standing, playerLoc.x * width/mazesize.x, playerLoc.y * height/mazesize.y);
      textFont(font);
      delay(500);
      text("Ya gotta be clever",width/mazesize.x * (mazesize.x - 7),height/mazesize.y * ( mazesize.y - 3));
      textFont(font2);
      text("This is my wisdom",width/mazesize.x * (mazesize.x - 6),height/mazesize.y * ( mazesize.y - 2));
      gameOver = true;
      return;
    }
            
  
    if (moving > 0) {
      if (direction.x == 0) {
        curImage = movingImgUp[moving % 3];
      }
      else {
        curImage = movingImgSide[moving % 2];
      }
      playerLoc.add(PVector.mult(direction, .2));
      moving --;
      
      if (moving == 0) {
        playerLoc = saved;
        if (!keyPressed)
          curImage = standing;
      }
      
      delay(70);
    }
    
    
    
    

    

      
      
  }
  
  
  void keyPressed() {
    if (gameOver)
      return;
    
    if (moving != 0)
      return;
    moving = 5;


    if (keyCode == UP) {
       direction = new PVector(0, -1);
    }
    else if(keyCode == DOWN) {
       direction = new PVector(0, 1);
    }
    else if(keyCode == LEFT) {
       direction = new PVector(-1, 0);
    }
    else if(keyCode == RIGHT) {
       direction = new PVector(1, 0);
    }
        PVector dest = PVector.add(playerLoc, direction);
    
    if (dest.x < -1 || dest.y < 0 || dest.x >= mazesize.x || dest.y >= mazesize.y || wallLocations.contains(dest)) {
        direction = new PVector(0,0);
        moving = 0;
        return;
    }
    saved = dest;
  }
  
  
  class Bag<T> implements Iterable<T>{
    private ArrayList<T> contents;
    
    Bag() {
      contents = new ArrayList<T>();
    }
    
    void put(T elm) {
      contents.add(elm);
    }
    
    void shuffle() {
      Collections.shuffle(contents);
    }
    
    T pop() {
      return contents.remove(0);
    }
    
    Iterator<T> iterator() {
      return contents.iterator();
    }
    
    int size() {
      return contents.size();
    }
  }
  

  class WallFactory {
    PImage[] images;
    
    WallFactory(PImage[] init) {
      images = init;
    }
    
    Wall make(PVector p) {
      return new Wall(p, images[int(random(images.length))]);
    }
  }
  
  class Wall {


    
    PVector location;
    PImage image;
    
    Wall(PVector newloc, PImage img) {
      location = newloc;
      image = img;
    }
    
    List<PVector> neighbors() {
      PVector[] potential = { PVector.add(location, up), PVector.add(location, down), PVector.add(location, left), PVector.add(location, right)};
      return Arrays.asList(potential);
    }
    
  }
    
  
