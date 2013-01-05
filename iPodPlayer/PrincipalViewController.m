//
//  PrincipalViewController.m
//  iPodPlayer
//
//  Created by Rafael Brigagão Paulino on 20/09/12.
//  Copyright (c) 2012 rafapaulino.com. All rights reserved.
//

#import "PrincipalViewController.h"

@interface PrincipalViewController ()
{
    //armazenar a selecao de musicas do usuario
    NSMutableArray *listaMusicas;
    
    //ponteiro para o player ipod
    MPMusicPlayerController *meuPlayer;
    
    int qualFaixaEstaTocando;
}

@end

@implementation PrincipalViewController

#pragma mark Tabela DataSource/Delegate

-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
   [meuPlayer setNowPlayingItem:[listaMusicas objectAtIndex:indexPath.row]];
    //executa o player quando for clicado na tabela
    [self playClicado:nil];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return listaMusicas.count;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *idCelula = @"minhaCelula";
    UITableViewCell *celula =[tableView dequeueReusableCellWithIdentifier:idCelula];
    
    if (celula == nil)
    {
        celula = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:idCelula];
    }
    
    //recuperando uma faixa para exibir suas informacoes nesta celula
    MPMediaItem *itemParaEstaCelula = [listaMusicas objectAtIndex:indexPath.row];
    
    celula.textLabel.text = [NSString stringWithFormat:@"%d - %@", indexPath.row + 1, [itemParaEstaCelula valueForProperty:MPMediaItemPropertyTitle]];
    
    celula.detailTextLabel.text = [itemParaEstaCelula valueForProperty:MPMediaItemPropertyArtist];
    
    return celula;
}

#pragma mark Media Picker Delegate
//done
-(void)mediaPicker: (MPMediaPickerController *)mediaPicker didPickMediaItems:(MPMediaItemCollection *)mediaItemCollection
{
    //armazenando a selecao do usuario no array datasoucer da tabela
    listaMusicas = [NSMutableArray arrayWithArray:mediaItemCollection.items];
    
    //atualiza a tabela
    [_tabela reloadData];
    
    //passando a selecao do usuario para o player
    [meuPlayer setQueueWithItemCollection:mediaItemCollection];
    
    qualFaixaEstaTocando = 0;
    
    //fecha a controladora
    [self dismissModalViewControllerAnimated:YES];
}

//cancel
- (void)mediaPickerDidCancel:(MPMediaPickerController *)mediaPicker
{
    //fecha a controladora
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark Metodos IBAction

-(IBAction)playClicado:(id)sender
{
    //se esta tocando
    if (meuPlayer.playbackState == MPMusicPlaybackStatePlaying)
    {
        //volta para o comeco
        [meuPlayer skipToBeginning];
    }
    //se estava parado
    else
    {
        //toca
        [meuPlayer play];
    }
}

-(IBAction)stopClicado:(id)sender
{
    [meuPlayer skipToBeginning];
    [meuPlayer stop];
}

-(IBAction)pauseClicado:(id)sender
{
    [meuPlayer pause];
}

-(IBAction)proximaClicado:(id)sender
{
    //ir para o prox
    if (qualFaixaEstaTocando < listaMusicas.count -1)
    {
        [meuPlayer skipToNextItem];
    }
    //voltar para a primeira faixa
    else
    {
        [meuPlayer setNowPlayingItem:[listaMusicas objectAtIndex:0]];
    }
}

-(IBAction)anteriorClicado:(id)sender
{
    //ir para a anterior
    if (qualFaixaEstaTocando > 0)
    {
        [meuPlayer skipToPreviousItem];
    }
    //ultima faixa
    else
    {
        [meuPlayer setNowPlayingItem:[listaMusicas objectAtIndex:listaMusicas.count-1]];

    }
}

-(IBAction)acessarMusicasBibliotecaUsuario:(id)sender
{
    //abrindo a controladora que exibe as musicas do usuario (permitindo uma selecao)
    MPMediaPickerController *selecionarMusicas = [[MPMediaPickerController alloc] init];
    selecionarMusicas.delegate = self;
    
    //permitir que picker selecione mais de uma faixa (usuario selecionar varias musicas)
    selecionarMusicas.allowsPickingMultipleItems = YES;
    
    [self presentModalViewController:selecionarMusicas animated:YES];
}

-(void)atualizarDadosMusica:(NSNotification*)notificacao
{
    //atualizar a variavel de controle
    qualFaixaEstaTocando = [listaMusicas indexOfObject:meuPlayer.nowPlayingItem];
    
    //atualizar a tabela visualmente
    NSIndexPath *indiceMusica = [NSIndexPath indexPathForRow:qualFaixaEstaTocando inSection:0];
    
    [_tabela selectRowAtIndexPath:indiceMusica animated:YES scrollPosition:UITableViewScrollPositionTop];
    
    //recuperar as informacoes da musica que esta tocando agora e atualizar a interface
    MPMediaItem *faixaAtual = meuPlayer.nowPlayingItem;
    
    //acessar as propriedades desta faixa e alterar o texto das labels
    _artista.text = [faixaAtual valueForProperty:MPMediaItemPropertyArtist];
    _faixa.text = [faixaAtual valueForProperty:MPMediaItemPropertyTitle];
    _album.text = [faixaAtual valueForProperty:MPMediaItemPropertyAlbumTitle];
    
    //recuperar a imagem de capa
    MPMediaItemArtwork *arteCapa = [faixaAtual valueForProperty:MPMediaItemPropertyArtwork];
    
    //criar um UIImge e associar ao imageView
    UIImage *imagemCapa = [arteCapa imageWithSize:_capa.frame.size];
    _capa.image = imagemCapa;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    //inicalizando o array que ira receber a selecao do usuario
    listaMusicas = [[NSMutableArray alloc] init];
    
    //recuperar uma instancia do player do device
    meuPlayer = [MPMusicPlayerController iPodMusicPlayer];
    
    //as configuracaoes feitas pelo usuario na ultima vez que ele usou o player permanecem
    //caso vc precise garantir que as config estejam de acordo, precisamos setar usando os metodos abaixo:
    [meuPlayer setShuffleMode:MPMusicShuffleModeOff];
    [meuPlayer setRepeatMode:MPMusicRepeatModeNone];
    
    //esta hamada pede ao plaeyr que ele envie mensagens acerca dos eventos que acontecerem durante a execucao ou troca de faixa
    [meuPlayer beginGeneratingPlaybackNotifications];
    
    //cadastrar a viewController como sendo observadora dos eventos do player
    
    //quando o usuario interagir com o player
    [[NSNotificationCenter defaultCenter] addObserver:self  selector:@selector(atualizarDadosMusica:) name:MPMusicPlayerControllerPlaybackStateDidChangeNotification object:nil];
    
    //quando as coisas aconteceream na ordem correta
    [[NSNotificationCenter defaultCenter] addObserver:self  selector:@selector(atualizarDadosMusica:) name:MPMusicPlayerControllerNowPlayingItemDidChangeNotification object:nil];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

@end
