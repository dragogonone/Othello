//
//  ViewController.m
//  Othello
//
//  Created by USER on 2014/02/21.
//  Copyright (c) 2014年 USER. All rights reserved.
//アニメスピードの調節

#define syubanturn 44
#import "OthelloViewController.h"

@interface OthelloViewController (){
    NSInteger status[8][8]; // 0:無　1:黒　2:白
    float basewid;
    float basehet;
    NSInteger touchx;
    NSInteger touchy;
    NSInteger direcx;
    NSInteger direcy;
    bool touchable;
    bool canPut;
    bool isnpput;
    bool isOppoCPU;
    bool isAnime;
    bool kaihoutest;
    bool isMatta;
    NSInteger colCPU; //1:黒 2:白　3:プレイヤー戦
    NSInteger turncl; //1:黒 2:白
    NSInteger turnpl; //1:1P 2:2p　0CPU 不要説あり
    NSInteger okerubasyo;
    float cphyouka[8][8]; //CPUが置く場所を決める評価関数
    NSInteger kaihoudo[8][8];//開放度を入れたい
    NSInteger cpmax[8][8];//ひっくり返せる数　最も多く取れるもの取得に使用
    NSInteger tesuu;
    NSInteger BanLog[100];
    NSInteger nxcphyouka[8][8];//打った時に次の盤面の評価値を入れる？
    NSInteger kakuseki[3];//1に黒 2に白の確定石
}

@end

@implementation OthelloViewController
@synthesize segm = _segm;

#pragma mark Initialize

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    UIScreen *sc = [UIScreen mainScreen];
    CGRect rrr = sc.bounds;
    basewid = rrr.size.width/2 - 117;
    basehet = rrr.size.height/2 - 167;
    isAnime = YES;
    kaihoutest = NO;
    isMatta = NO;
    isnpput = NO;
    
    [self initItem];
    
    [self Start];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)initItem{
    _Passbtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    _Passbtn.frame = CGRectMake(basewid, basehet+30*8+10, 50, 30);
    [_Passbtn setTitle:@"Pass" forState:UIControlStateNormal];
    [_Passbtn addTarget:self
                action:@selector(PassBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_Passbtn];
    
    _Restartbtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    _Restartbtn.frame = CGRectMake(basewid, basehet-60, 50, 30);
    [_Restartbtn setTitle:@"Restart" forState:UIControlStateNormal];
    [_Restartbtn addTarget:self
                action:@selector(RestartBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_Restartbtn];
    
    _Animebtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    _Animebtn.frame = CGRectMake(basewid+30*5, basehet+30*8+10, 50, 30);
    [_Animebtn setTitle:@"Anime" forState:UIControlStateNormal];
    [_Animebtn addTarget:self
                   action:@selector(AnimeBtn:) forControlEvents:UIControlEventTouchUpInside];
    _Animebtn.backgroundColor = [UIColor yellowColor];
    [self.view addSubview:_Animebtn];
    
    _Kaihoubtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    _Kaihoubtn.frame = CGRectMake(basewid+30*5, basehet+30*8+50, 100, 30);
    [_Kaihoubtn setTitle:@"開放度:" forState:UIControlStateNormal];
    [_Kaihoubtn addTarget:self
                  action:@selector(KaihouBtn:) forControlEvents:UIControlEventTouchUpInside];
    _Kaihoubtn.backgroundColor = [UIColor grayColor];
    [self.view addSubview:_Kaihoubtn];
    
    _Titlebtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    _Titlebtn.frame = CGRectMake(basewid+30*5, basehet-60, 50, 30);
    [_Titlebtn setTitle:@"Title" forState:UIControlStateNormal];
    [_Titlebtn addTarget:self
                 action:@selector(TitleBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_Titlebtn];
    
    _Mattabtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    _Mattabtn.frame = CGRectMake(basewid+30*5, basehet+30*8+110, 50, 30);
    [_Mattabtn setTitle:@"待った" forState:UIControlStateNormal];
    [_Mattabtn addTarget:self
                    action:@selector(MattaBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_Mattabtn];
    
    _Blacklbl = [[UILabel alloc] initWithFrame:CGRectMake(basewid, basehet+30*8+50, 150, 30)];
    _Blacklbl.text = @"Black: 2";
    _Blacklbl.textAlignment = NSTextAlignmentCenter;
    _Blacklbl.backgroundColor = [UIColor yellowColor];
    [self.view addSubview:_Blacklbl];
    
    _Whitelbl = [[UILabel alloc] initWithFrame:CGRectMake(basewid, basehet+30*8+80, 150, 30)];
    _Whitelbl.text = @"White: 2";
    _Whitelbl.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:_Whitelbl];
    
    _Tesuulbl = [[UILabel alloc] initWithFrame:CGRectMake(basewid, basehet+30*8+110, 100, 30)];
    _Tesuulbl.text = @"Remain:60";
    _Tesuulbl.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:_Tesuulbl];
    
    _Maetelbl = [[UILabel alloc] initWithFrame:CGRectMake(basewid+30*5, basehet+30*8+80, 150, 30)];
    _Maetelbl.text = @"Previous:";
    _Maetelbl.textAlignment = NSTextAlignmentLeft;
    [self.view addSubview:_Maetelbl];
}


-(void)Start{
    tesuu = 0;
    turncl = 1;
    
    switch (_segm) {
        case 0:
            isOppoCPU = YES;
            colCPU = 2; //CPUは白
            break;
        case 1:
            isOppoCPU = YES;
            colCPU = 1; //CPUは黒
            break;
        case 2:
            isOppoCPU = NO;
            colCPU = 3;
            break;
    }
    
    //NSMutableArray *arr = [NSMutableArray array];
    for(NSInteger x=0;x<8;x++){
        for(NSInteger y=0;y<8;y++){
            status[x][y] = 0;
        }
    }
    
    status[3][3] = 2;
    status[3][4] = 1;
    status[4][3] = 1;
    status[4][4] = 2;
    
    NSInteger i;
    for(i=3;i<=4;i++){
        UIImage *img;
        img = [UIImage imageNamed:@"white.png"];
        UIImageView *imgview = [[UIImageView alloc] initWithImage:img];
        imgview.tag = i+8*i+100;
        imgview.frame = CGRectMake(basewid+30*i,basehet+30*i, 24.0, 24.0);
        [self.view addSubview:imgview];
    }
    for(i=3;i<=4;i++){
        NSInteger ii = 7-i;
        UIImage *img;
        img = [UIImage imageNamed:@"black.png"];
        UIImageView *imgview = [[UIImageView alloc] initWithImage:img];
        imgview.tag = i+ii*8+100;
        imgview.frame = CGRectMake(basewid+30*i,basehet+30*ii, 24.0, 24.0);
        [self.view addSubview:imgview];
    }
    if(colCPU == 1 && !isMatta){
        [self performSelector:@selector(CPUTurn)
                   withObject:nil afterDelay:0.5];
    }
    isMatta = NO;
    [self Enabled];
}

#pragma mark -

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{

    
    if (!touchable) {
        return;
    }
    [self DisEnabled];
    
    UITouch *touch = [touches anyObject];
    
    CGPoint location = [touch locationInView:self.view];
    //NSLog(@"began x:%f y:%f", location.x, location.y);
    float lx = location.x;
    float ly = location.y;
    if (lx<basewid-3 || lx>basewid+30*8-3 || ly<basehet-3 || ly>basehet+30*8-3){
        NSLog(@"Out of the board");
        [self TurnEnd];
        return;
    }
    
    NSInteger x = (lx-basewid-3);
    touchx = x / 30;
    NSInteger y = (ly-basehet-3);
    touchy = y / 30;
    //NSLog(@"x:%ld,y:%ld",x,y);
    //NSLog(@"tx:%ld,ty:%ld",touchx,touchy);
    
    if(status[touchx][touchy]!=0){
        NSLog(@"On a piece");
        [self TurnEnd];
        return;
    }
    
    
    /*開放度ボタンが押された場合*/
    for(NSInteger x=0;x<8;x++){
        for(NSInteger y=0;y<8;y++){
            kaihoudo[x][y] = 0;
        }
    }
    if(kaihoutest){
        for(NSInteger i = 0; i < 3; i++) {//八方向に
            direcx = i - 1;
            for(NSInteger j = 0; j < 3; j++) {
                direcy = j - 1;
                if ( direcx != 0 || direcy != 0 ) {
                    [self CalcKaihoudo:touchx andY:touchy];
                }
            }
        }
        if(kaihoudo[touchx][touchy] != 0){
            [_Kaihoubtn setTitle:[NSString stringWithFormat:@"開放度:%d",kaihoudo[touchx][touchy]] forState:UIControlStateNormal];
        }
        [self TurnEnd];
        return;
    }
    /*ここまで開放度*/
    
    
    
    status[touchx][touchy] = turncl;
    
    [self UseJAR:touchx andY:touchy];
    
    if(!canPut){
        status[touchx][touchy] = 0;
        NSLog(@"Can't Reverce");
        [self TurnEnd];
        return;
    }
    turncl = 3 - turncl;
    BanLog[tesuu] = touchx+8*touchy;
    tesuu++;
    _Maetelbl.text = [NSString stringWithFormat:@"Previous:W%ldH%ld",(touchx+1),(touchy+1)];
    [self TurnEnd];
    
    if(isOppoCPU){
        touchable = NO;
        [self CPUTurn];
    }
    
}



-(void)CPUTurn{
    NSLog(@"CPUTurn");
    
    
    
    //評価値初期化
    for(NSInteger x=0;x<8;x++){
        for(NSInteger y=0;y<8;y++){
           //cpcanPut[x][y] = 0;
            cphyouka[x][y] = 0;
        }
    }
    
    [self Pass];//まずパスを判定、同時に置ける場所をチェック
    //この時点でcphyoukaには置ける場所に10置けない場所に０が入っている
    if(okerubasyo == 0){
        return;
    }
    
    
    /*評価値をいじる*/
    
    //角を最優先で取る
    cphyouka[0][0] = cphyouka[0][0] * 1000;
    cphyouka[0][7] = cphyouka[0][7] * 1000;
    cphyouka[7][0] = cphyouka[7][0] * 1000;
    cphyouka[7][7] = cphyouka[7][7] * 1000;
    
    
    //A打ちの評価を1上げる
    cphyouka[0][2] = cphyouka[0][2] * 2;
    cphyouka[2][0] = cphyouka[2][0] * 2;
    cphyouka[5][0] = cphyouka[5][0] * 2;
    cphyouka[7][2] = cphyouka[7][2] * 2;
    cphyouka[0][5] = cphyouka[0][5] * 2;
    cphyouka[2][7] = cphyouka[2][7] * 2;
    cphyouka[5][7] = cphyouka[5][7] * 2;
    cphyouka[7][5] = cphyouka[7][5] * 2;
    
    
    //開放度理論　終盤前まで使用
    if([self CountTotal] <= syubanturn){
        for(NSInteger x=0;x<8;x++){
            for(NSInteger y=0;y<8;y++){
                kaihoudo[x][y] = 0;
    
                for(NSInteger i = 0; i < 3; i++) {//八方向に
                    direcx = i - 1;
                    for(NSInteger j = 0; j < 3; j++) {
                        direcy = j - 1;
                        if ( direcx != 0 || direcy != 0 ) {
                            [self CalcKaihoudo:x andY:y];
                        }
                    }
                }
                if(cphyouka[x][y] !=0){
                    cphyouka[x][y] = cphyouka[x][y] + (30 - kaihoudo[x][y]);
                }
            }
        }
    }
    
    
    
    
    //角が取られていない時のX打ちを避ける
    
    if(status[0][0] == 0){cphyouka[1][1] /= 10;}
    if(status[0][7] == 0){cphyouka[1][6] /= 10;}
    if(status[7][0] == 0){cphyouka[6][1] /= 10;}
    if(status[7][7] == 0){cphyouka[6][6] /= 10;}
    
    //角が取られてない時のC打ちの評価を著しく下げる
    if(status[0][0] == 0){
        cphyouka[0][1] *= 0.2;
        cphyouka[1][0] *= 0.2;
    }
    if(status[7][0] == 0){
        cphyouka[6][0] *= 0.2;
        cphyouka[7][1] *= 0.2;
    }
    if(status[0][7] == 0){
        cphyouka[0][6] *= 0.2;
        cphyouka[1][7] *= 0.2;
    }
    if(status[7][7] == 0){
        cphyouka[6][7] *= 0.2;
        cphyouka[7][6] *= 0.2;
    }
    
    
    
    //WingKill(未完成)
    [self WingKill];
    
    /*一番多く取れるものを取る最終手段*/
    if([self CountTotal] > syubanturn){
        for(NSInteger x=0;x<8;x++){
            for(NSInteger y=0;y<8;y++){
                cpmax[x][y] = 0;
                
                for(NSInteger i = 0; i < 3; i++) {//八方向に
                    direcx = i - 1;
                    for(NSInteger j = 0; j < 3; j++) {
                        direcy = j - 1;
                        if ( direcx != 0 || direcy != 0 ) {
                            [self JudgeMax:x andY:y];
                        }
                    }
                }
                
                if(cphyouka[x][y] !=0){
                    cphyouka[x][y] = cphyouka[x][y] + cpmax[x][y];
                }
            }
        }
    }

    /*評価値いじり終了*/
    
    //評価値をソートし打つ場所を決定
    NSInteger maxp = 0;
    for(NSInteger x=0;x<8;x++){
        
        for(NSInteger y=0;y<8;y++){
            if(cphyouka[x][y]>maxp){
                touchx = x;
                touchy = y;
                maxp = cphyouka[x][y];
            }
        }
    }
    
    
    
    
    //決定後
    status[touchx][touchy] = turncl;
    
    [self UseJAR:touchx andY:touchy];
    
    if(!canPut){
        NSLog(@"%ld,%ld",touchx,touchy);
        //ここにくるのはAIミス
    }
    turncl = 3 - turncl;
    BanLog[tesuu] = touchx+8*touchy;
    tesuu++;
    _Maetelbl.text = [NSString stringWithFormat:@"Previous:W%ldH%ld",(touchx+1),(touchy+1)];
    [self TurnEnd];
    
}

#pragma mark -

-(void)JudgeX:(NSInteger)jx andY:(NSInteger)jy{//パス判定に使用　CPUが使用（予定）　置けるか判定

    NSInteger i = 0;
    NSInteger nowx = jx;
    NSInteger nowy = jy;
    
    
    while( true ) {
        jx = jx + direcx; // 列を進める
        jy = jy + direcy; // 行を進める
        if ( jx < 0 || jx >= 8 || 0 > jy || jy >= 8 ) {
            /* 盤面上でない */
            break; // ループを抜ける　置けない
        }
        
        /* 進めた場所の番号の計算 */
        if (status[jx][jy] == 0 ) {
            /* 石がない */
            break; // ループを抜ける　置けない
        }
        
        i++;
        
        /* 隣の石のとき */
        if(i == 1 && turncl  == status[jx][jy]) {
            /* 隣の石が同じ色なら石は置けない */
            break; // ループを抜ける　置けない
        }
        
          if(turncl  == status[jx][jy]) {//置ける
              okerubasyo++;
              direcx = 10;
              direcy = 10;
              cphyouka[nowx][nowy] = 10;
              break;
          }
    }
}

-(void)UseJAR:(NSInteger)x andY:(NSInteger)y{
    for(NSInteger i = 0; i < 3; i++) {//八方向に
        direcx = i - 1;
        for(NSInteger j = 0; j < 3; j++) {
            direcy = j - 1;
            if ( direcx != 0 || direcy != 0 ) {
                [self JudgeAndRev:x AndY:y];
            }
        }
    }
}

-(void)JudgeAndRev:(NSInteger)nowx AndY:(NSInteger)nowy{//プレイヤー•CPUがひっくり返す時に使用
    
    NSInteger i = 0;
    NSInteger jx = nowx;
    NSInteger jy = nowy;
    
    while( true ) {
        jx = jx + direcx; // 列を進める
        jy = jy + direcy; // 行を進める
        if ( jx < 0 || jx >= 8 || jy < 0 || jy >= 8 ) {
            /* 盤面上でない */
            break; // ループを抜ける　置けない
        }
        
        /* 進めた場所の番号の計算 */
        if (status[jx][jy] == 0 ) {
            /* 石がない */
            break; // ループを抜ける　置けない
        }
        
        i++;
        
        /* 隣の石のとき */
        if(i == 1 && turncl == status[jx][jy]) {
            /* 隣の石が同じ色なら石は置けない */
            break; // ループを抜ける　置けない
        }
        
        if(status[jx][jy]  == turncl) {//置ける
            canPut = YES;
            
            //置いた駒の描写
            if(!isnpput){
                UIImage *img;
                if(turncl == 1){
                    img = [UIImage imageNamed:@"black.png"];
                }else{
                    img = [UIImage imageNamed:@"white.png"];
                }
                UIImageView *imgview = [[UIImageView alloc] initWithImage:img];
                imgview.tag = nowx+nowy*8+100;
                imgview.frame = CGRectMake(basewid+30*nowx,basehet+30*nowy, 24.0, 24.0);
                [self.view addSubview:imgview];
                isnpput = YES;
                if(isAnime){
                    [[NSRunLoop currentRunLoop]
                     runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.25]];
                }
            }
            
            jx = jx - direcx;
            jy = jy - direcy;
            while(jx != nowx || jy != nowy) {
                status[jx][jy] = turncl;
                [self PieceAnime:jx yposi:jy];
                jx = jx - direcx;
                jy = jy - direcy;
            }
            break;
        }
    }
}

-(void)CalcKaihoudo:(NSInteger)nowx andY:(NSInteger)nowy{
    NSInteger i = 0;
    NSInteger jx = nowx;
    NSInteger jy = nowy;
    
    
    while( true ) {
        jx = jx + direcx; // 列を進める
        jy = jy + direcy; // 行を進める
        if ( jx < 0 || jx >= 8 || 0 > jy || jy >= 8 ) {
            /* 盤面上でない */
            break; // ループを抜ける　置けない
        }
        
        /* 進めた場所の番号の計算 */
        if (status[jx][jy] == 0 ) {
            /* 石がない */
            break; // ループを抜ける　置けない
        }
        
        i++;
        
        /* 隣の石のとき */
        if(i == 1 && turncl  == status[jx][jy]) {
            /* 隣の石が同じ色なら石は置けない */
            break; // ループを抜ける　置けない
        }
        
        if(turncl  == status[jx][jy]) {//置ける
            NSInteger kx, ky,kdirecx,kdirecy;
            
            jx = jx - direcx;
            jy = jy - direcy;
            while(jx != nowx || jy != nowy) {
                for(NSInteger m = 0; m < 3; m++) {//八方向を調べ開いていたら開放度プラス
                    kdirecx = m - 1;
                    for(NSInteger n = 0; n < 3; n++) {
                        kdirecy = n - 1;
                        
                        kx = jx + kdirecx;
                        ky = jy + kdirecy;
                        if (status[kx][ky] == 0) {
                            kaihoudo[nowx][nowy]++;
                        }
                    }
                }
                jx = jx - direcx;
                jy = jy - direcy;
            }
            break;
        }
    }
}


-(void)JudgeMax:(NSInteger)nowx andY:(NSInteger)nowy{//プレイヤー•CPUがひっくり返す時に使用
    
    NSInteger i = 0;
    NSInteger jx = nowx;
    NSInteger jy = nowy;
    
    while( true ) {
        jx = jx + direcx; // 列を進める
        jy = jy + direcy; // 行を進める
        if ( jx < 0 || jx >= 8 || jy < 0 || jy >= 8 ) {
            /* 盤面上でない */
            break; // ループを抜ける　置けない
        }
        
        /* 進めた場所の番号の計算 */
        if (status[jx][jy] == 0 ) {
            /* 石がない */
            break; // ループを抜ける　置けない
        }
        
        i++;
        
        /* 隣の石のとき */
        if(i == 1 && status[nowx][nowy]  == status[jx][jy]) {
            /* 隣の石が同じ色なら石は置けない */
            break; // ループを抜ける　置けない
        }
        
        if(status[jx][jy]  == status[nowx][nowy]) {//置ける
            
            jx = jx - direcx;
            jy = jy - direcy;
            while(jx != nowx || jy != nowy) {
                cpmax[nowx][nowy]++;
                jx = jx - direcx;
                jy = jy - direcy;
            }
            break;
        }
    }
}

//↓機能していない…
-(void)WingKill{
    NSInteger maxp = 0;
    NSInteger colMAN = 3-colCPU;
    
    //一回ソートし、角の近く以外がないかを確かめる
    for(NSInteger x=0;x<8;x++){
        
        for(NSInteger y=0;y<8;y++){
            if(cphyouka[x][y]>maxp){
                maxp = cphyouka[x][y];
            }
        }
    }
    
    /*WingKill本番　潜り込み*/
    if (status[0][0] == colMAN) {//左上
        NSInteger i=0;
        while(status[i+2][0] == colMAN){
            if(i==4){
                cphyouka[1][1] *= 50000;
            }
            i++;
        }
        i=0;
        while(status[0][i+2] == colMAN){
            if(i==4){
                cphyouka[1][1] *= 50000;
            }
            i++;
        }
    }
    if (status[7][0] == colMAN) {//右上
        NSInteger i=0;
        while(status[i+1][0] == colMAN){
            if(i==4){
                cphyouka[6][1] *= 50000;
            }
            i++;
        }
        i=0;
        while(status[7][i+2] == colMAN){
            if(i==4){
                cphyouka[6][1] *= 50000;
            }
            i++;
        }
    }
    if (status[7][7] == colMAN) {//右下
        NSInteger i=0;
        while(status[i+1][7] == colMAN){
            if(i==4){
                cphyouka[6][6] *= 50000;
            }
            i++;
        }
        i=0;
        while(status[7][i+1] == colMAN){
            if(i==4){
                cphyouka[6][1] *= 50000;
            }
            i++;
        }
    }
    if (status[0][7] == colMAN) {//左下
        NSInteger i=0;
        while(status[i+2][7] == colMAN){
            if(i==4){
                cphyouka[1][6] *= 50000;
            }
            i++;
        }
        i=0;
        while(status[0][i+1] == colMAN){
            if(i==4){
                cphyouka[6][1] *= 50000;
            }
            i++;
        }
    }
    
    if(maxp<3){//X,C以外が埋まっている
        //①CもXも駒あり
        //②Cあり逆Cなし
        //③Cなし逆Cあり（ウイング）
        if(status[0][0] == 0 && status[0][7] == 0){//左
            if(status[0][1]==0){
                NSInteger i = 0;
                while(status[0][i+2] == colMAN){
                    if(i==4){
                        cphyouka[1][1] *= 500;
                        NSLog(@"Wing");
                    }
                    i++;
                }
            }
            if(status[0][6]==0){
                NSInteger i = 0;
                while(status[0][i+1] == colMAN){
                    if(i==4){
                        cphyouka[1][6] *= 500;
                        NSLog(@"Wing");
                    }
                    i++;
                }
            }
        }
        if(status[7][0] == 0 && status[7][7] == 0){//右
            if(status[7][1]==0){
                NSInteger i = 0;
                while(status[7][i+2] == colMAN){
                     NSLog(@"wingb");
                    if(i==4){
                        cphyouka[6][1] *= 500;
                        NSLog(@"Wing%f",cphyouka[6][1]);
                    }
                    i++;
                }
            }
            if(status[7][6]==0){
                NSInteger i = 0;
                while(status[7][i+1] == colMAN){
                     NSLog(@"wingb");
                    if(i==4){
                        cphyouka[6][6] *= 500;
                        NSLog(@"Wing%f",cphyouka[6][1]);
                    }
                    i++;
                }
            }
        }
        if(status[0][0] == 0 && status[7][0] == 0){//上
            if(status[1][0]==0){
                NSInteger i = 0;
                while(status[i+2][0] == colMAN){
                    if(i==4){
                        cphyouka[1][1] *= 500;
                        NSLog(@"Wing");
                    }
                    i++;
                }
            }
            if(status[6][0]==0){
                NSInteger i = 0;
                while(status[i+1][0] == colMAN){
                    if(i==4){
                        cphyouka[6][1] *= 500;
                        NSLog(@"Wing");
                    }
                    i++;
                }
            }
        }
        if(status[0][7] == 0 && status[7][7] == 0){//下
            if(status[1][7]==0){
                NSInteger i = 0;
                while(status[i+2][7] == colMAN){
                    if(i==4){
                        cphyouka[1][6] *= 500;
                        NSLog(@"Wing");
                    }
                    i++;
                }
            }
            if(status[6][7]==0){
                NSInteger i = 0;
                while(status[i+1][7] == colMAN){
                    if(i==4){
                        cphyouka[6][6] *= 500;
                        NSLog(@"Wing");
                    }
                    i++;
                }
            }
        }
        //④Cなし逆Cなし
    }
    

}

//-(void)CalcKakuseki:(NSInteger)nowx yposi:(NSInteger)nowy{//その盤面でのお互いの確定石を計算
//    
//    
//    
//}

-(void)PieceAnime:(NSInteger)jx yposi:(NSInteger)jy{
    
    
    
        UIImageView *imgview = (UIImageView*)[self.view viewWithTag:jx+jy*8+100];
        [imgview removeFromSuperview];
        UIImage *img;
    if(isAnime){
            //中間アニメーション
        if(turncl == 1){
            img = [UIImage imageNamed:@"kuroue.png"];
        }else{
            img = [UIImage imageNamed:@"siroue.png"];
        }
        imgview = [[UIImageView alloc] initWithImage:img];
        imgview.tag = jx+jy*8+100;
        imgview.frame = CGRectMake(basewid+30*jx,basehet+30*jy, 24.0, 24.0);
        [self.view addSubview:imgview];
    
        [[NSRunLoop currentRunLoop]
         runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.15]];
    }
    
    //本番アニメーション
    [imgview removeFromSuperview];
    
    if(turncl == 1){
        img = [UIImage imageNamed:@"black.png"];
    }else{
        img = [UIImage imageNamed:@"white.png"];
    }
    imgview = [[UIImageView alloc] initWithImage:img];
    imgview.tag = jx+jy*8+100;
    imgview.frame = CGRectMake(basewid+30*jx,basehet+30*jy, 24.0, 24.0);
    [self.view addSubview:imgview];
    
    if(isAnime){
        [[NSRunLoop currentRunLoop]
         runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.15]];
    }
}


-(void)TurnEnd{
    
    NSLog(@"tesuu:%ld",tesuu);
    canPut = NO;
    isnpput = NO;
    [self Enabled];
    _Blacklbl.text = [NSString stringWithFormat:@"Black:%2ld",[self CountBlack]];
    _Whitelbl.text = [NSString stringWithFormat:@"White:%2ld",[self CountWhite]];
    _Tesuulbl.text = [NSString stringWithFormat:@"Remain:%2ld",(64 - [self CountTotal])];
    if(turncl == 1){
        _Blacklbl.backgroundColor = [UIColor yellowColor];
        _Whitelbl.backgroundColor = [UIColor whiteColor];
    }else{
        _Blacklbl.backgroundColor = [UIColor whiteColor];
        _Whitelbl.backgroundColor = [UIColor yellowColor];
    }
    
    if ([self CountTotal] == 64 || [self CountWhite] == 0 || [self CountBlack] == 0){
        [self GameEnd];
        return;
    }
}


-(void)GameEnd{
    NSLog(@"GameEnd");
    NSInteger x = [self CountBlack];
    NSInteger y = [self CountWhite];
    if(x>y){
    _Blacklbl.text = [NSString stringWithFormat:@"Win! Black:%d",x];
    _Whitelbl.text = [NSString stringWithFormat:@"Lose… White:%2ld",y];
    }else if(x<y){
        _Blacklbl.text = [NSString stringWithFormat:@"Lose… Black:%2ld",x];
        _Whitelbl.text = [NSString stringWithFormat:@"Win! White:%2ld",y];
    }else{//同点
        _Blacklbl.text = [NSString stringWithFormat:@"Draw Black:%2ld",x];
        _Whitelbl.text = [NSString stringWithFormat:@"Draw White:%2ld",y];
    }
}




-(NSInteger) CountBlack {
    NSInteger num = 0;
    for(NSInteger x=0;x<8;x++){
        for(NSInteger y=0;y<8;y++){
            if(status[x][y] == 1) num++;
        }
    }
    return num; // 黒の石の数を返す
}

-(NSInteger) CountWhite {
    NSInteger num = 0;
    for(NSInteger x=0;x<8;x++){
        for(NSInteger y=0;y<8;y++){
            if(status[x][y] == 2) num++;
        }
    }
    return num; // 白の石の数を返す
}

-(NSInteger) CountTotal{
    NSInteger num = 0;
    for(NSInteger x=0;x<8;x++){
        for(NSInteger y=0;y<8;y++){
            if(status[x][y] != 0) num++;
        }
    }
    return num; // 合計の石の数を返す
}


-(void)Pass{
    
    NSInteger x,y;
    okerubasyo = 0;
    
    for(x=0;x<8;x++){//全てのマスを
        for(y=0;y<8;y++){
            if(status[x][y] == 0){
                for(NSInteger i = 0; i < 3; i++) {//八方向に
                    direcx = i - 1;
                    for(NSInteger j = 0; j < 3; j++) {
                        direcy = j - 1;
                        if ( direcx != 0 || direcy != 0 ) {
                            [self JudgeX:(x) andY:(y)];//調査
                        }
                    }
                }
            }
            
        }
    }
    
    NSLog(@"okerubasyo:%ld",okerubasyo);
    
    if(okerubasyo == 0){
        turncl = 3 - turncl;
        NSLog(@"Pass");
        BanLog[tesuu] = 1000;//パスは1000
        tesuu++;
        [self TurnEnd];
        _Maetelbl.text = @"Previous:Pass";
        if(colCPU == turncl){
            [self CPUTurn];
        }
    }
    
}

-(void)DisEnabled{
    touchable = NO;
    _Animebtn.enabled = NO;
    _Passbtn.enabled = NO;
    _Mattabtn.enabled = NO;
}

-(void)Enabled{
    touchable = YES;
    _Animebtn.enabled = YES;
    _Passbtn.enabled = YES;
    _Mattabtn.enabled = YES;
}

#pragma mark Button

-(void)PassBtn:(UIButton*)button{
    [self DisEnabled];
    [self Pass];
    [self Enabled];
}

-(void)RestartBtn:(UIButton*)button{
    for (UIView* subview in self.view.subviews) {
        [subview removeFromSuperview];
    }
    [self initItem];
    [self Start];
}

-(void)AnimeBtn:(UIButton*)button{
    isAnime = 1 - isAnime;
    if(isAnime){
        _Animebtn.backgroundColor = [UIColor yellowColor];
    }else{
        _Animebtn.backgroundColor = [UIColor grayColor];
    }
}

-(void)KaihouBtn:(UIButton*)button{
    kaihoutest = 1 - kaihoutest;
    if(kaihoutest){
        _Kaihoubtn.backgroundColor = [UIColor yellowColor];
    }else{
        _Kaihoubtn.backgroundColor = [UIColor grayColor];
    }
    
//    //確定石のチェック 全マスに対し
//    for(NSInteger x=0;x<8;x++){//全てのマスを
//        for(NSInteger y=0;y<8;y++){
//            if(status[x][y]!=0){
//                for(NSInteger i = 0; i < 3; i++) {//八方向に
//                    direcx = i - 1;
//                    for(NSInteger j = 0; j < 3; j++) {
//                        direcy = j - 1;
//                        if ( direcx != 0 || direcy != 0 ) {
//                            [self CalcKakuseki:x yposi:y];//調査
//                        }
//                    }
//                }
//            }
//        }
//    }
}

-(void)TitleBtn:(UIButton*)button{
    [self dismissViewControllerAnimated:YES completion:nil];
}


-(void)MattaBtn:(UIButton*)button{
    if (!touchable){
        return;
    }
    [self DisEnabled];
    for (UIView* subview in self.view.subviews) {
        [subview removeFromSuperview];
    }
    if((tesuu-isOppoCPU)<=1){
        [self initItem];
        [self Start];
        return;
    }
    
    [self initItem];
    
    isMatta = YES;
    NSInteger mtesuu;
    if(isOppoCPU){
    mtesuu = tesuu-2;
    }else{
        mtesuu = tesuu-1;
    }
    [self Start];
    
    isMatta = NO;
    NSLog(@"tesuu:%ld",mtesuu);
    bool ia = isAnime;
    isAnime = NO;
    
    NSInteger i;
    for(i=0;i<mtesuu;i++){
        if(BanLog[i] == 1000){//パス
            [self Pass];
        }else{
            touchx = BanLog[i]%8;
            touchy = BanLog[i]/8;
            NSLog(@"%ld",BanLog[i]);
        
            status[touchx][touchy] = turncl;
        
            [self UseJAR:touchx andY:touchy];
            isnpput = NO;
        turncl = 3 - turncl;
        }
    }
    tesuu = mtesuu;
    
    isAnime = ia;
    [self TurnEnd];
}


















@end
