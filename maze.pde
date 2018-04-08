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
  
  
  void setup() {
    fullScreen();
    PImage[] images = { loadImage("papers.png"), loadImage("mdew.jpg"), loadImage("folders.jpg")};
    for (PImage image: images) {
      image.resize((int) (width / mazesize.x), (int) (height / mazesize.y));
    }
    point_sets = new HashSet<Set<PVector>>();
    Bag<Wall> walls = new Bag<Wall>();
    List<Wall> seenandkept = new LinkedList<Wall>();
    WallFactory f = new WallFactory(images);

    
    for (int x = 0; x < mazesize.x; x++) {
      for (int y = 0; y < mazesize.y; y++) {
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

    while (point_sets.size() > 10 && walls.size() > 0) { //<>//
      print("Walls: " + walls.size() + "\n");  
      Wall w = walls.pop();
      PVector location = w.location;
      Set<PVector> propegated = new HashSet<PVector>();
      propegated.add(location);
      boolean addedSomething = false;
      for (PVector n : w.neighbors()) {

        for (Set<PVector> s : point_sets) {
          if (s.contains(n)) {
            addedSomething = true;
            propegated.addAll(s);
            point_sets.remove(s);
            break;
          }
        }
      }
      if (!addedSomething) {
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
  
  
  
  void draw() {
    for (Wall wall : wallImages) {
      image(wall.image, wall.location.x * width/mazesize.x, wall.location.y * height/mazesize.y);
        
        
        
    }
      
      
      
      
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
    
  
