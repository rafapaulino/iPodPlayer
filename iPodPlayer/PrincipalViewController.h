//
//  PrincipalViewController.h
//  iPodPlayer
//
//  Created by Rafael Brigagão Paulino on 20/09/12.
//  Copyright (c) 2012 rafapaulino.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>

@interface PrincipalViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, MPMediaPickerControllerDelegate>

@property (nonatomic, weak) IBOutlet UITableView *tabela;
@property (nonatomic, weak) IBOutlet UIImageView *capa;
@property (nonatomic, weak) IBOutlet UILabel *artista;
@property (nonatomic, weak) IBOutlet UILabel *album;
@property (nonatomic, weak) IBOutlet UILabel *faixa;


-(IBAction)playClicado:(id)sender;
-(IBAction)stopClicado:(id)sender;
-(IBAction)pauseClicado:(id)sender;
-(IBAction)proximaClicado:(id)sender;
-(IBAction)anteriorClicado:(id)sender;
-(IBAction)acessarMusicasBibliotecaUsuario:(id)sender;

@end
