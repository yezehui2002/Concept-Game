//
//  HelloWorldLayer.h
//  GameConcept4
//
//  Created by Joan Gayle Villaneva on 1/23/12.
//  Copyright __MyCompanyName__ 2012. All rights reserved.
//


// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"

// HelloWorldLayer
@interface GameScene : CCLayer {
    CCSprite* player;
	CGPoint playerVelocity;
    CCLabelTTF* scoreLabel;
    CCLabelTTF* score; 
    
    CCArray* enemies;
    CCArray* bullets;
    CCArray* enemiesBullets;
    
    
    float enemyMoveDuration;
    
	int numEnemiesMoved;
    int numBulletsMoved;
    int gameOver;
    int totalScore;
    
    float totaltime;
    float nextshotime;
    
    bool playHit;
}

// returns a CCScene that contains the HelloWorldLayer as the only child
+(CCScene *) scene;

@end
