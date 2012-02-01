#import "GameScene.h"


@interface GameScene (PrivateMethods)
-(void) initEnemies;
-(void) resetEnemies;
-(void) enemiesUpdate:(ccTime)delta;
-(void) bulletsUpdate:(ccTime)delta;
-(void) runEnemyMoveSequence:(CCSprite*)enemy;
-(void) enemyDied:(int)g;
-(void) runBulletMoveSequence:(CCSprite*)bullet;
-(void) enemyDidDrop:(id)sender;
-(void) bulletDidDrop:(id)sender;
-(void) initBullets;
-(void) initEnemiesBullets;
-(void) resetBullets;
-(void) checkCollision;
-(void) resetGame;



/*-(void) checkForCollision;
-(void) showGameOver;
-(void) resetGame;*/
@end

@implementation GameScene

+(CCScene *) scene {
	CCScene *scene = [CCScene node];
	
	GameScene *layer = [GameScene node];
	
	[scene addChild: layer];
	
	return scene;
}

-(id) init {
	if( (self=[super init])) {
        
        self.isAccelerometerEnabled = YES;
        self.isTouchEnabled = YES;
        
        gameOver = 0;
        CCParticleSystem* system;
		system = [CCParticleRain node];
        [self addChild:system z:0];
        
		player = [CCSprite spriteWithFile:@"red.png"];
		[self addChild:player z:3 tag:1];
		
		CGSize screenSize = [[CCDirector sharedDirector] winSize];
		float imageHeight = [player texture].contentSize.height;
		player.position = CGPointMake(screenSize.width / 2, imageHeight / 2);
		
        scoreLabel = [CCLabelTTF labelWithString:@"score :" fontName:@"Arial" fontSize:18]; 
        scoreLabel.position = CGPointMake(40, screenSize.height-20);
        [self addChild:scoreLabel z:5];
        
        
        score = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%06d",totalScore] fontName:@"Arial" fontSize:18]; 
        score.position = CGPointMake(105, screenSize.height-20);
        [self addChild:score z:5];
        
		[self scheduleUpdate];
		[self initEnemies];
        [self initBullets];
	}
	return self;
}



-(void) initEnemies {
	CGSize screenSize = [[CCDirector sharedDirector] winSize];
    
	CCSprite* tempSpider = [CCSprite spriteWithFile:@"4.png"];
	float imageWidth = [tempSpider texture].contentSize.width;
	
	int numSpiders = screenSize.width / imageWidth;
    
	NSAssert(enemies == nil, @"%@: spiders array is already initialized!", NSStringFromSelector(_cmd));
	enemies = [[CCArray alloc] initWithCapacity:numSpiders];
	
	for (int i = 0; i < numSpiders; i++){
		CCSprite* enemy = [CCSprite spriteWithFile:@"4.png"];
        enemy.flipY = 180;
		[self addChild:enemy];
		
		[enemies addObject:enemy];
	}
	
	[self resetEnemies];
}

-(void) initBullets {
	bullets = [[CCArray alloc] initWithCapacity:50];
	
	for (int i = 0; i < 10; i++){
		CCSprite* bullet = [CCSprite spriteWithFile:@"bullet.png"];
        [self addChild:bullet];
		
		[bullets addObject:bullet];
	}
	
	[self resetBullets];
}

-(void) initEnemiesBullets {
	bullets = [[CCArray alloc] initWithCapacity:50];
	
	for (int i = 0; i < 50; i++){
		CCSprite* bullet = [CCSprite spriteWithFile:@"bullet.png"];
        [self addChild:bullet];
		
		[enemiesBullets addObject:bullet];
	}
	
	[self resetBullets];
}

-(void) resetBullets {
    CGSize screenSize = [[CCDirector sharedDirector] winSize];
    
    CCSprite* tempBullet = [bullets lastObject];
    CGSize imageSize = [tempBullet texture].contentSize;
    
    for (int i = 0; i < 10; i++){
        CCSprite* bullet = [bullets objectAtIndex:i];
        bullet.position = CGPointMake(imageSize.width * i + imageSize.width * 0.5f, 0 - imageSize.height);
                 
        [bullet stopAllActions];
    }
             
    [self unschedule:@selector(bulletsUpdate:)];
    [self schedule:@selector(bulletsUpdate:) interval:0.6f];
             
    numBulletsMoved = 0;
    
}
         
         
-(void) resetEnemies {
	CGSize screenSize = [[CCDirector sharedDirector] winSize];
    
	CCSprite* tempSpider = [enemies lastObject];
	CGSize imageSize = [tempSpider texture].contentSize;
    
	int numSpiders = [enemies count];
	for (int i = 0; i < numSpiders; i++){
		CCSprite* enemy = [enemies objectAtIndex:i];
		enemy.position = CGPointMake(imageSize.width * i + imageSize.width * 0.5f, screenSize.height + imageSize.height);
		enemy.scale = 1;
		
		[enemy stopAllActions];
	}
	
	[self unschedule:@selector(enemiesUpdate:)];
    [self schedule:@selector(enemiesUpdate:) interval:0.6f];
	
	numEnemiesMoved = 0;
	enemyMoveDuration = 8.0f;
}


-(void) enemiesUpdate:(ccTime)delta{
    if (gameOver != 1) {
    	for (int i = 0; i < 10; i++) {
			int randomEnemyIndex = CCRANDOM_0_1() * [enemies count];
			CCSprite* enemy = [enemies objectAtIndex:randomEnemyIndex];
		
			if ([enemy numberOfRunningActions] == 0) {
            	[self runEnemyMoveSequence:enemy];
                break;
			}
		}
    }
}

-(void) bulletsUpdate:(ccTime)delta{
    if (gameOver != 1) {
    	totaltime += delta;
    
    	if(totaltime > nextshotime) {
        
    		nextshotime = totaltime + .5f;
    		for (int i = 0; i < 10; i++) {
    			int randomBulletIndex = CCRANDOM_0_1() * [bullets count];
        		CCSprite* bullet = [bullets objectAtIndex:randomBulletIndex];
                 
        		if ([bullet numberOfRunningActions] == 0) {
                	CGPoint pos = player.position;
                	pos.y = 10;
                	bullet.position = pos;
                	[self runBulletMoveSequence:bullet];
            		break;
        		}
    		}
        
    	}
    }
}
         
-(void) runEnemyMoveSequence:(CCSprite*)enemy {
	numEnemiesMoved++;
	if (numEnemiesMoved % 4 == 0 && enemyMoveDuration > 2.0f) {
		enemyMoveDuration -= 0.1f;
	}
	
	//enemy.visible = YES;
	CGPoint belowScreenPosition = CGPointMake(enemy.position.x, -[enemy texture].contentSize.height);
	CCMoveTo* move = [CCMoveTo actionWithDuration:enemyMoveDuration position:belowScreenPosition];
	CCCallFuncN* callDidDrop = [CCCallFuncN actionWithTarget:self selector:@selector(enemyDidDrop:)];
	CCSequence* sequence = [CCSequence actions:move, callDidDrop, nil];
	[enemy runAction:sequence];
}

-(void) runBulletMoveSequence:(CCSprite*)bullet {
    CGSize screenSize = [[CCDirector sharedDirector] winSize];
    CCSprite* tempBullet = [bullets lastObject];
    CGSize imageSize = [tempBullet texture].contentSize;
    
    CGPoint aboveScreenPosition = CGPointMake(player.position.x, screenSize.height + imageSize.height);
    CCMoveTo* move = [CCMoveTo actionWithDuration:3 position:aboveScreenPosition];
    CCCallFuncN* callDidDrop = [CCCallFuncN actionWithTarget:self selector:@selector(bulletDidDrop:)];
    CCSequence* sequence = [CCSequence actions:move, callDidDrop, nil];
	[bullet runAction:sequence];
}
         
-(void) enemyDidDrop:(id)sender {
	NSAssert([sender isKindOfClass:[CCSprite class]], @"sender is not of class CCSprite!");
	CCSprite* enemy = (CCSprite*)sender;
	
	// move the spider back up outside the top of the screen
	CGPoint pos = enemy.position;
	CGSize screenSize = [[CCDirector sharedDirector] winSize];
	pos.y = screenSize.height + [enemy texture].contentSize.height;
	enemy.position = pos;
}

-(void) enemyDied:(int)g {
	CCSprite* enemy = [enemies objectAtIndex:g];
    //NSLog(@"%i", g);
    //enemy.visible = NO;
    [enemy stopAllActions];
    //[self removeChild:enemy cleanup:YES];
    
    // move the spider back up outside the top of the screen
	CGPoint pos = enemy.position;
	CGSize screenSize = [[CCDirector sharedDirector] winSize];
	pos.y = screenSize.height + [enemy texture].contentSize.height;
	enemy.position = pos;
}

-(void) bulletDidDrop:(id)sender {
    NSAssert([sender isKindOfClass:[CCSprite class]], @"sender is not of class CCSprite!");
    CCSprite* bullet = (CCSprite*)sender;
             
    CGPoint pos = bullet.position;
    CGSize screenSize = [[CCDirector sharedDirector] winSize];
    
    CGSize imageSize = [bullet texture].contentSize;
    
    pos.y = 0 - imageSize.height;
    bullet.position = pos;
}
         
-(void) accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration {
	float deceleration = 0.4f;
	float sensitivity = 6.0f;
	float maxVelocity = 100;
    
	playerVelocity.x = playerVelocity.x * deceleration + acceleration.x * sensitivity;
	
	if (playerVelocity.x > maxVelocity) {
		playerVelocity.x = maxVelocity;
	}
	else if (playerVelocity.x < -maxVelocity) {
		playerVelocity.x = -maxVelocity;
	}    
}

-(void) update:(ccTime)delta {

    if (gameOver != 1) {
    	[self checkCollision];
		CGPoint pos = player.position;
		pos.x += playerVelocity.x;
	
		CGSize screenSize = [[CCDirector sharedDirector] winSize];
		float imageWidthHalved = [player texture].contentSize.width * 0.5f;
		float leftBorderLimit = imageWidthHalved;
		float rightBorderLimit = screenSize.width - imageWidthHalved;

		if (pos.x < leftBorderLimit){
			pos.x = leftBorderLimit;        
			playerVelocity = CGPointZero;
		}
		else if (pos.x > rightBorderLimit) {
			pos.x = rightBorderLimit;        
			playerVelocity = CGPointZero;
		}
    
		player.position = pos;
    }
   
}


-(void)checkCollision {
    
    for (int i = 0; i < 10; i++){
        CCSprite* projectile = [bullets objectAtIndex:i];
        CGRect projectileRect = CGRectMake(
                                           projectile.position.x - (projectile.contentSize.width/2), 
                                           projectile.position.y - (projectile.contentSize.height/2), 
                                           projectile.contentSize.width, 
                                           projectile.contentSize.height);  
        
        
        int numSpiders = [enemies count];
        for (int g = 0; g < numSpiders; g++){
            CCSprite* targets = [enemies objectAtIndex:g];
            
            
            CGRect targetRect = CGRectMake(
                                           targets.position.x - (targets.contentSize.width/2), 
                                           targets.position.y - (targets.contentSize.height/2), 
                                           targets.contentSize.width, 
                                           targets.contentSize.height);
            
            CGRect playerRect = CGRectMake(
                                           player.position.x - (player.contentSize.width/2), 
                                           player.position.y - (player.contentSize.height/2), 
                                           player.contentSize.width, 
                                           player.contentSize.height-20);

            if (CGRectIntersectsRect(playerRect, targetRect)) {
             	player.visible = NO;
                
                CCParticleSystem* emitter;
             	emitter = [CCParticleExplosion node];
             	emitter.life = 0.1f;
             	emitter.duration = 0.1f;
             	emitter.position =player.position;
             	emitter.totalParticles = 50;
             	emitter.positionType = kCCPositionTypeFree;
             	emitter.autoRemoveOnFinish = YES;
             	
                [self addChild:emitter];
                [self resetBullets];
                
                CCNode* node;
             	CCARRAY_FOREACH([self children], node){
             		[node stopAllActions];
             	}
                
                
                gameOver = 1;
            }
            
            
            if (CGRectIntersectsRect(targetRect, projectileRect)) {
                totalScore=totalScore + 1;
                [score setString:[NSString stringWithFormat:@"%06d", totalScore]];
            
                CCParticleSystem* system;
                
                system = [ARCH_OPTIMAL_PARTICLE_SYSTEM particleWithFile:@"fx-explosion.plist"];
                
                // Set some parameters that can't be set in Particle Designer
                system.positionType = kCCPositionTypeFree;
                system.life = 0.1f;
                system.duration = 0.1f;
                system.position = targets.position;
                system.totalParticles = 100;
                
                system.autoRemoveOnFinish = YES;
                
                [self addChild:system];
                [self enemyDied:g];
                      
               	
            }
            
            
        }
        
        
    }
    

}

-(void) resetGame
{
    gameOver = 0; 
    [self resetEnemies];
    player.visible = YES;
    totalScore = 0;
    [score setString:[NSString stringWithFormat:@"%06d", totalScore]];
}


-(void) ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	[self resetGame];
}

- (void) dealloc {
	[super dealloc];
}
@end
