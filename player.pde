class player {
 int id;
 int r;
 PVector facing, sCom;
 PVector s, a;
 Body body;
 int CurrentSize;
 int Size;
 
 boolean AutoLaunch;
 
 Vec2 Teleport;
 Vec2 TeleportForce;
 
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
  AutoLaunch = false;
  
  Teleport = new Vec2(0, 0);
  TeleportForce = new Vec2(0, 0);

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
  AutoLaunch = false;

  Teleport = new Vec2(0, 0);
  TeleportForce = new Vec2(0, 0);

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
   
    if(AutoLaunch)
      reset();

      
   }
   
   if(Teleport.x != 0 && Teleport.y != 0)
   {
      Vec2 Velocity = body.getLinearVelocity();
      float VelocityNorme = sqrt(Velocity.x*Velocity.x + Velocity.y*Velocity.y)*6;
      body.setLinearVelocity(new Vec2(0, 0));
      
      System.out.println("Force x:" + TeleportForce.x + " y :" + TeleportForce.y);
      body.applyLinearImpulse(new Vec2(VelocityNorme*TeleportForce.x, VelocityNorme*TeleportForce.y), body.getWorldCenter(), true);
      body.setTransform(Teleport, 0);
      Teleport = new Vec2(0, 0);
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
  
  
  ScoreP1 = 0;
  
  body.applyLinearImpulse(new Vec2(100*body.getMass()/3.14, 0.0), body.getWorldCenter(), true);
 } 
 
  // This function adds the rectangle to the box2d world
  void makeBody()
  {
    
    // Define the body and make it from the shape
    BodyDef bd = new BodyDef();    
    // Define a fixture
    FixtureDef fd = new FixtureDef();
      
    // Define a polygon (this is what we use for a rectangle)
    CircleShape sd = new CircleShape();
    sd.setRadius(box2d.scalarPixelsToWorld(r/2));
    
    fd.shape = sd;
    // Parameters that affect physics
    fd.density = 1;
    fd.friction = 0.0;
    fd.restitution = 0.5;
    
    bd.type = BodyType.DYNAMIC;
    bd.linearDamping = 0.0;
    
    fd.filter.groupIndex = -4;
     

    PVector p = new PVector();
    switch(id)
    {
      case 1: p.set(0, myPtxInter.mFbo.height/8); break;
    }
    
    bd.position.set(box2d.coordPixelsToWorld(p));

    body = box2d.createBody(bd);
    body.createFixture(fd);

    body.setUserData(this);
  }

}
