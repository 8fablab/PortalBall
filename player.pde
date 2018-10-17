class player {
 int id;
 int r;
 PVector facing, sCom;
 PVector s, a;
 Body body;
 int CurrentSize;
 int Size;
 
 ptx_color col;
 
 public PVector getP() {
   return body == null ? new PVector() : box2d.coordWorldToPixelsPVector( body.getPosition() );
 }
 
 player() {
  id = -1;
  s = new PVector();
  a = new PVector();
  facing = new PVector();
  sCom = new PVector();
  CurrentSize = 4;
  Size = 4;

  r = 40;
  
  makeBody();
  reset();  
  col = new ptx_color();
 }

 player(int _id) {
  id = _id; 
  s = new PVector();
  a = new PVector();
  facing = new PVector();
  sCom = new PVector();
  Size = 4;
  CurrentSize = 4;

  r = 60;
    
  switch(id) {
  case 1: col = new ptx_color(255, 255, 0); break;
  case 2: col = new ptx_color(255, 0, 255); break;
  case 3: col = new ptx_color(255, 255, 0); break;
  case 4: col = new ptx_color(255, 0, 255); break;
  }
 
  makeBody();
  reset();
 }
 
 void updateMe()
 {
   
    
   // Check if dead
   if(0 > getP().x || getP().x > myPtxInter.mFbo.width
   || 0 > getP().y || getP().y > myPtxInter.mFbo.height) 
   { // Outside of the square game field
   
    if(id == 1 ||id == 3)
      ScoreP1 -= 5; 
    if(id == 2 ||id == 4)
      ScoreP2 -= 5; 
      
    reset();
   }
   
   if(id <= 2)
   {
      Vec2 Velocity = body.getLinearVelocity();
      
      if(Math.abs(Velocity.x) < 10.0 && Velocity.x < 0)
      {
        Velocity.x = -10.0;         
      }
      
      if(Math.abs(Velocity.x) < 10.0 && Velocity.x > 0)
      {
        Velocity.x = 10.0;         
      }
      
      if(Math.abs(Velocity.y) < 10.0 && Velocity.y < 0)
      {
        Velocity.y = -10.0;         
      }
      
      if(Math.abs(Velocity.y) < 10.0 && Velocity.y > 0)
      {
        Velocity.y = 10.0;         
      }
      
      body.setLinearVelocity(Velocity);
      
   }
   
   if(id > 2)
   {
     // Moving
     int k = 32;
        
     if(facing.x != 0) sCom.x = facing.x * k; else sCom.x *= 0.9;
     if(facing.y != 0) sCom.y = facing.y * k; else sCom.y *= 0.9;
     
     //friction
     a.set( - (s.x) / 10, 0);
     s.add( a );      

     body.setLinearVelocity(new Vec2(s.x + sCom.x, 0));
   }
   
   if(CurrentSize != Size)
   {
      box2d.destroyBody(body);
      makeBody(getP());
      CurrentSize = Size;
   }
 }
 
 void drawMe() {
   
   if(id == 1 || id == 2)
   {
      myPtxInter.mFbo.noStroke();
      myPtxInter.mFbo.fill(col.r, col.g, col.b);
      myPtxInter.mFbo.ellipse(getP().x, getP().y, r, r);
   }
   
   else
   {
      myPtxInter.mFbo.noStroke();
      myPtxInter.mFbo.rectMode(CENTER);
      myPtxInter.mFbo.fill(col.r, col.g, col.b);
      myPtxInter.mFbo.rect(getP().x, getP().y, Size*25, 30);
   }
   
 }
 
void reset() {

  s.set(0,0);
  
  a.set(0,0);
     
  facing.set(0,0);
  sCom.set(0,0);
  
  box2d.destroyBody(body);
  makeBody();
 
  
 } 
void reset(PVector p) {

  s.set(0,0);
  
  a.set(0,0);
     
  facing.set(0,0);
  sCom.set(0,0);
  
  box2d.destroyBody(body);
  makeBody(p);
 
  
 }
 
 
  // This function adds the rectangle to the box2d world
  void makeBody() {
    
    // Define the body and make it from the shape
    BodyDef bd = new BodyDef();    
    // Define a fixture
    FixtureDef fd = new FixtureDef();

    if(id <= 2)
    {
      
      // Define a polygon (this is what we use for a rectangle)
      CircleShape sd = new CircleShape();
      sd.setRadius(box2d.scalarPixelsToWorld(r/2));
      
      fd.shape = sd;
      // Parameters that affect physics
      fd.density = 0.001;
      fd.friction = 0.0;
      fd.restitution = 0.9;
      
      bd.type = BodyType.DYNAMIC;
      
      fd.filter.groupIndex = 1;

    }
    
    else
    {
      // Define a polygon (this is what we use for a rectangle)
      PolygonShape sd = new PolygonShape();
      sd.setAsBox(box2d.scalarPixelsToWorld(25*Size/2), box2d.scalarPixelsToWorld(15));
  
      fd.shape = sd;
      // Parameters that affect physics
      fd.density = 100;
      fd.friction = 0.0;
      fd.restitution = 0.9;
  
      bd.type = BodyType.DYNAMIC;
      
      fd.filter.groupIndex = -1;
    }
         
    if(id == 1 || id == 4)
    {
      fd.filter.categoryBits = 0x1;
      fd.filter.maskBits = 0x6;
    }
    
    if(id == 2 || id == 3)
    {
      fd.filter.categoryBits = 0x2;
      fd.filter.maskBits = 0x05;        
    }

    PVector p = new PVector();
    switch(id) {
    case 2: p.set(myPtxInter.mFbo.width/2+50, myPtxInter.mFbo.height-myPtxInter.mFbo.height/9 -30); break;
    case 1: p.set(myPtxInter.mFbo.width/4+50, myPtxInter.mFbo.height-myPtxInter.mFbo.height/9 -30); break;
    case 3: p.set(myPtxInter.mFbo.width/2, myPtxInter.mFbo.height-myPtxInter.mFbo.height/9); break;
    case 4: p.set(myPtxInter.mFbo.width/4, myPtxInter.mFbo.height-myPtxInter.mFbo.height/9); break;
    }
    
    bd.position.set(box2d.coordPixelsToWorld(p));

    body = box2d.createBody(bd);
    body.createFixture(fd);

    body.setUserData(this);
  }
  
    // This function adds the rectangle to the box2d world
  void makeBody(PVector p) {
    
    // Define the body and make it from the shape
    BodyDef bd = new BodyDef();    
    // Define a fixture
    FixtureDef fd = new FixtureDef();

    if(id <= 2)
    {
      
      // Define a polygon (this is what we use for a rectangle)
      CircleShape sd = new CircleShape();
      sd.setRadius(box2d.scalarPixelsToWorld(r/2));
      
      fd.shape = sd;
      // Parameters that affect physics
      fd.density = 0.001;
      fd.friction = 0.0;
      fd.restitution = 0.9;
      
      bd.type = BodyType.DYNAMIC;
      
      fd.filter.groupIndex = 1;

    }
    
    else
    {
      // Define a polygon (this is what we use for a rectangle)
      PolygonShape sd = new PolygonShape();
      sd.setAsBox(box2d.scalarPixelsToWorld(25*Size/2), box2d.scalarPixelsToWorld(15));
  
      fd.shape = sd;
      // Parameters that affect physics
      fd.density = 100;
      fd.friction = 0.0;
      fd.restitution = 0.9;
  
      bd.type = BodyType.DYNAMIC;
      
      fd.filter.groupIndex = -1;
    }
         
    if(id == 1 || id == 4)
    {
      fd.filter.categoryBits = 0x1;
      fd.filter.maskBits = 0x6;
    }
    
    if(id == 2 || id == 3)
    {
      fd.filter.categoryBits = 0x2;
      fd.filter.maskBits = 0x05;        
    }
    
    bd.position.set(box2d.coordPixelsToWorld(p));

    body = box2d.createBody(bd);
    body.createFixture(fd);

    body.setUserData(this);
  }

}
