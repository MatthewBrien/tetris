#!/usr/local/bin/perl
#matthew's tetris attempt
#based mostly off of the code provided by Advanced Perl Programming, 
#O'reilly & associates inc,
#and #Sriram Srinivasan
#and of course, Alexey Pajitnov
#
#          [][]   
#  [][]      []             
#[][]        []           
#               []              
#             [][]           
#             []        
#     [][]                  
#     [][]           []
# []                 []
# []        []       []
# [][]    [][][]     []


use strict;
use Tk;

#initialize globals

my $MAX_COL = 10;
my $MAX_ROW = 20;
my $TILE_DIMENSION = 20; #tile size in pixels (it's a square)

my @cells = ();
my @tile_ids = ();

#widget variables
my $b_start;		#star button widget
my $b_quit;
my $main_frame;	 	#main widget
my $canvas;		#playing field widget

#my $time = 500;

#game states
my $START = 0;
my $PAUSED = 1;
my $RUNNING = 2;
my $GAMEOVER = 4;
my $state = $PAUSED;
	
#allocate the heap array,  
my @heap = ();
$heap[$MAX_COL * $MAX_ROW -1] = undef;	

my @patterns = (['11 ', 	#s1
		 ' 11'],
		 ['1111'], 	#line
		 ['11',		#block
		  '11']);
		  
my @colors = [  '#003366',	#dark_teal
		'#006699',	#teal
		'#00ffff',	#baby_blue
		'#003300',	#dark_green
		'#800000',	#maroon
		'#660033',	#violete
		'#ff00ff',	#pink
		'#666699',	#slate_blue
		'#ff9966',	#peach
		'#000000',	#black
		'#d9ff66'	#lime_green
	];


sub create_tile{
	my ($cell, $color) = @_; #parameters passed to create_tile
	my ($row, $col); 	 #initialize two scalar variables
	$col = $cell % $MAX_COL;	#is this ever not initialized to Zero?
	$row = int($cell / $MAX_COL);
	push (@tile_ids,
		$canvas ->create('rectangle',
				 $col*$TILE_DIMENSION,
				 $row*$TILE_DIMENSION,
				 ($col+1)*$TILE_DIMENSION,
				 ($row+1)*$TILE_DIMENSION,
				 '-fill'=>'#ffffff',
				 '-tags'=>'block'));
				 
	
	}



sub start{
	create_tile(10, '#ffffff');
	}
sub quit{
	#exit more or less gracefully
	exit(0);
	}


sub create_screen { 
	$main_frame = MainWindow->new(-title=>'Hello, Tetris!', -background=>'#000000'); #creatse a the main window, with a given title and background color
	
	$canvas = $main_frame->Canvas(-width=>$MAX_COL * $TILE_DIMENSION,
				      -height=>$MAX_ROW *$TILE_DIMENSION,		#this creates a canvas elemetn inside of main_frame
				      -border=>2, 
				      -relief=>'ridge',
				      -background=>'#000000')
				      ->pack();
				  
				      
	$b_start = $main_frame->Button(-text=>'start', 
				       -anchor=>'w',
				       -command=>\&start)#todo switch text between pause, start, and resume
				 ->pack('-side'=> 'left',
					'-fill' => 'y', 
					'-expand' => 'y');
							    
	$b_quit = $main_frame->Button(-text=>'quit',
				       -anchor=>'e', 
				       -command=>\&quit)
				->pack('-side'=> 'left', 
				       '-fill' => 'y', 
				       '-expand' => 'y'); #to do pause, and prompt if they really want to quit;
				  
	
	
	}

create_screen();
MainLoop();
