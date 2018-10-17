import shiffman.box2d.*;
import org.jbox2d.common.*;
import org.jbox2d.dynamics.*;
import org.jbox2d.dynamics.joints.*;
import org.jbox2d.dynamics.contacts.*;
import org.jbox2d.collision.shapes.*;
import org.jbox2d.collision.shapes.Shape;
import org.jbox2d.collision.Manifold;
import org.jbox2d.collision.WorldManifold;

import processing.sound.*;

import java.util.Collection;
import java.util.Enumeration;
import java.util.Hashtable;
import java.util.Set;


// ===== 1) ROOT LIBRARY =====
boolean isScanning, isInConfig;
ptx_inter myPtxInter;
char scanKey = '8';
char configKey = 'h';
// ===== =============== =====


// TODO: HERITAGE CONSTRUCTEUR DANS AREACORE + typeArea : BUMP, WALL,  LAVA ...
/* Todo To
*
*  BrickBreaker : 
*    Sons
*    Fonctions retrecissement
*    
*  PortalBall
*    Gravité + Goal
*    Fonction mur portal et bumper
*
*  Sumo
*    Fin et goal à atteindre
*
*/


Box2DProcessing box2d;
ArrayList<areaCore> myMap;
ArrayList<Object> myObj1, myObj2;
player player1, player2, barPlayer1, barPlayer2;

int ScoreP1 = 0, ScoreP2 = 0;

SoundFile Coin;
SoundFile Tuyau;
SoundFile Bump;


void setup() {

  // ===== 2) INIT LIBRARY =====  
  isScanning = false;
  isInConfig = false;
  myPtxInter = new ptx_inter(this);

  // ===== =============== =====


  fullScreen(P3D);
  //size(1920, 1080);
  noCursor();

  box2d = new Box2DProcessing(this);
  box2d.createWorld();
  box2d.setScaleFactor(30);
  box2d.setGravity(0,0);
  box2d.listenForCollisions();
  
  
  Coin = new SoundFile(this, "piece.wav");
  Tuyau = new SoundFile(this, "tuyau.wav");
  Bump = new SoundFile(this, "saut.wav");
  
  myMap = new ArrayList<areaCore>(); 
  print("pojpoj");
  myObj1 = new ArrayList<Object>();
  myObj2 = new ArrayList<Object>();

  player1 = new player(1);
  player2 = new player(2);
  
  barPlayer1 = new player(3);
  barPlayer2 = new player(4);
}

void reset() {
    player1.reset();
    player2.reset();  
    barPlayer1.reset();  
    barPlayer2.reset();
    
    
    atScan();
}

void draw() {

  // ===== 3) SCANNING & CONFIG DRAW LIBRARY =====  
  if (isScanning) {
    background(0);
    myPtxInter.generalRender(); 

    if (myPtxInter.whiteCtp > 20 && myPtxInter.whiteCtp < 22)
      myPtxInter.myCam.update();

    if (myPtxInter.whiteCtp > 35) {

      myPtxInter.scanCam();
      if (myPtxInter.myGlobState != globState.CAMERA)
        myPtxInter.scanClr();

      myPtxInter.whiteCtp = 0;
      isScanning = false;
      atScan();
    }
    return;
  }

  if (isInConfig) {
    background(0);
    myPtxInter.generalRender();
    return;
  }
  // ===== ================================= =====  



 
  //UPDATE
  player1.updateMe();
  player2.updateMe();
  barPlayer1.updateMe();
  barPlayer2.updateMe();
  box2d.step();
  
  myObj1.clear();
  myObj2.clear();
    
  //DRAW
  background(0);
  myPtxInter.mFbo.beginDraw();
  myPtxInter.mFbo.background(0);
  myPtxInter.mFbo.fill(255);
  myPtxInter.mFbo.stroke(255);

  for (areaCore it : myMap)
        myPtxInter.drawArea(it);
        
  barPlayer1.drawMe();
  barPlayer2.drawMe();
  player1.drawMe();
  player2.drawMe();
  
    //Values
  String ScoreStr = "Player 1 : "  + ScoreP1 + "\n"
  + "Player 2 : "  + ScoreP2 +"\n";
  
  myPtxInter.mFbo.textAlign(LEFT);
  myPtxInter.mFbo.text(ScoreStr, 50, 100);

  myPtxInter.mFbo.endDraw();
  myPtxInter.displayFBO();
  

}



// Function that is triggered at the end of a scan operation
// Use it to update what is meant to be done once you have "new areas"

void atScan() {
  
    // clear Bodies
    for (areaCore it : myMap)
      box2d.destroyBody(it.body);
        
    // clear Map
    myMap.clear();
    
    for (area itArea : myPtxInter.getListArea())
      myMap.add(new areaCore(itArea) );
      
}



void keyPressed() {


  // ===== 4) KEY HANDlING LIBRARY ===== 

  // Forbid any change it you're in the middle of scanning
  if (isScanning) {
    return;
  }

  // Master key #1 / 2, that switch between your project and the configuration interface
  if (key == configKey) {
    isInConfig = !isInConfig;
    return;
  }

  // Master key #2 / 2, that launch the scanning process
  if (key == scanKey && !isScanning) {
    myPtxInter.whiteCtp = 0;
    isScanning = true;
    return;
  }

  // Set of key config in the the input mode
  if (isInConfig) {
    myPtxInter.keyPressed();
    return;
  }

  // ===== ================================= =====    


    switch(key) {
    case 'q': barPlayer2.facing.x = -1; break;
    case 's': player2.body.setLinearVelocity(new Vec2(0, 10)); break; 
    case 'd': barPlayer2.facing.x =  1; break; 
    
    case 'k': barPlayer1.facing.x = -1; break;
    case 'l': player1.body.setLinearVelocity(new Vec2(0, 10)); break; 
    case 'm': barPlayer1.facing.x =  1; break; 
      
    case 'p' : reset();
    }
}
 

void keyReleased() {

  // ===== 5) KEY HANDlING LIBRARY ===== 

  if (isScanning || isInConfig) {
    return;
  }
  // ===== ======================= =====
  
  switch(key) {
  case 'q': barPlayer2.facing.x = max(barPlayer2.facing.x, 0); break;
  case 'd': barPlayer2.facing.x = min(barPlayer2.facing.x, 0); break;

  case 'k': barPlayer1.facing.x = max(barPlayer1.facing.x, 0); break;
  case 'm': barPlayer1.facing.x = min(barPlayer1.facing.x, 0); break;
  }
  
}


void mousePressed() {

  // ===== 6) MOUSE HANDLIND LIBRARY ===== 

  if (isInConfig && myPtxInter.myGlobState == globState.CAMERA && mouseButton == LEFT) {

    if (myPtxInter.myCam.dotIndex == -1)
      myPtxInter.myCam.dotIndex = 0; // Switching toward editing 
    else
      myPtxInter.myCam.ROI[myPtxInter.myCam.dotIndex++  ] =
        new vec2f(mouseX * myPtxInter.myCam.mImg.width / width, 
        mouseY * myPtxInter.myCam.mImg.height / height);

    if ( myPtxInter.myCam.dotIndex == 4)
      myPtxInter.myCam.dotIndex = -1;
  }
  // ===== ========================= =====
}

void mouseMoved() {

  // ===== 7) MOUSE HANDLIND LIBRARY ===== 

  if (isInConfig && myPtxInter.myGlobState == globState.CAMERA && myPtxInter.myCam.dotIndex != -1)
    myPtxInter.myCam.ROI[myPtxInter.myCam.dotIndex] =
      new vec2f(mouseX * myPtxInter.myCam.mImg.width  / width, 
      mouseY * myPtxInter.myCam.mImg.height / height);
  // ===== ========================= =====
}

// Collision event functions!
void beginContact(Contact cp  ) {
    
  // Get manifold
  WorldManifold mp = new WorldManifold();
  cp.getWorldManifold(mp);
  
  PVector normP = new PVector(mp.normal.x, mp.normal.y).normalize();
  PVector contP = box2d.coordWorldToPixelsPVector(mp.points[0]);
  
  // Get both fixtures
  Fixture f1 = cp.getFixtureA();
  Fixture f2 = cp.getFixtureB();
  
  // Get both bodies
  Body b1 = f1.getBody();
  Body b2 = f2.getBody();

  // Check if both bodies have already interact
  boolean getOut = false;
  for(int i = 0; i<myObj1.size(); ++i)
    if( (myObj1.get(i) ==  b1.getUserData() && myObj2.get(i) == b2.getUserData())
     || (myObj1.get(i) ==  b1.getUserData() && myObj2.get(i) == b2.getUserData()) )
       getOut = true;

  if(getOut) {
    return;
  }
    
  // Add to the list
  myObj1.add(b1.getUserData());
  myObj2.add(b2.getUserData());

  // Get our objects that reference these bodies
  Object o1 = b1.getUserData();
  Object o2 = b2.getUserData();
  
  
  System.out.println(">New Contact");

  // 2 Joueurs
  if (o1.getClass() == player.class && o2.getClass() == player.class)
  {
    
    System.out.println("--> Joueur/Joueur");
    
    player p1, p2;
    
    if( ((player) o1).id == 1)
    {
      p1 = (player) o1;  
      p2 = (player) o2;  
    
    }
    
    else
    {
      p1 = (player) o2;  
      p2 = (player) o1;  
    }

    if(p1.id <= 2 && p2.id <= 2)
    {
    PVector dir = box2d.coordWorldToPixelsPVector( p1.body.getPosition() );
    dir.sub(box2d.coordWorldToPixelsPVector( p2.body.getPosition() ) );
    dir.normalize();
    
    // Bump par contact (centre centre)
    p1.s.sub( normP.copy().mult(4) );
    p2.s.add( normP.copy().mult(4) );

    // Bump par vitesse de l'autre (centre centre? Ou direction de vitesse? anti physique)
    p1.s.add( p2.facing.copy().mult( abs(p2.sCom.mag() + p1.s.mag()) ).mult(0.7) );
    p2.s.add( p1.facing.copy().mult( abs(p1.sCom.mag() + p1.s.mag()) ).mult(0.7) );  
    }

    
  } 
  

  // Zone Joueur
  if( (o1.getClass() == areaCore.class && o2.getClass() == player.class) || (o1.getClass() == player.class && o2.getClass() == areaCore.class) )
  {
    
    System.out.println("--> Zone/Joueur");
        
    player myP;
    areaCore myA;

    if(o1.getClass() == areaCore.class)
    {
      myA = (areaCore) o1;
      myP = (player) o2;
    }
    
    else
    {
      myA = (areaCore) o2;
      myP = (player) o1;
    }
    
    if(b1.getUserData() == b2.getUserData());
   
    if(myA.type == areaCoreType.BUMP)
    {     
      System.out.println("----> Bump");
      
      if(myP.id <= 2)
      {
         PVector BumpedVelocity = new PVector();
         BumpedVelocity.x = myP.body.getLinearVelocity().x;
         BumpedVelocity.y = myP.body.getLinearVelocity().y;
         
         BumpedVelocity.mult(1.5);
         
         BumpedVelocity.x = (BumpedVelocity.x < 0 && Math.abs(BumpedVelocity.x) > 30) ? -30 : 30;
         BumpedVelocity.y = (BumpedVelocity.y < 0 && Math.abs(BumpedVelocity.y) > 30) ? -30 : 30;
         
         
         Bump.play();
         
         myP.body.setLinearVelocity(new Vec2(BumpedVelocity.x, BumpedVelocity.y));
      }
      

      
    }
    
    else if(myA.type == areaCoreType.WALL)
    {      
        System.out.println("----> Points");
        
        if(myP.id == 1)
          ScoreP1 += 10;
        
        if(myP.id == 2)
          ScoreP2 += 10;
          
        Coin.play();
    }
    
    else if(myA.type == areaCoreType.LAVA)
    {
        Tuyau.play();
        System.out.println("----> Shrink");
        
        if(myP.id == 1)
        {
          if(barPlayer2.Size >= 1)
          {
             barPlayer2.Size--;
          }
          
          else
          {
             barPlayer2.Size = 4;         
          }
        }
        
        if(myP.id == 2)
        {
          if(barPlayer1.Size >= 1)
          {
             barPlayer1.Size--;
          }
          
          else
          {
             barPlayer1.Size = 4;          
          }

        }
    }
    
  }
  
}
