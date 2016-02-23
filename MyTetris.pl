#!/usr/local/bin/perl
#matthew's tetris attempt,
#based mostly off of the code provided by Advanced Perl Programming, 
#O'reilly & associates inc,
#and #Sriram Srinivasan


use strict;
use Tk;

#initialize globals

my $MAX_COL = 10;
my $MAX_ROW = 20;
my $TILE_DIMENSION = 20; #tile size in pixels (it's a square)

#my @cells = ();
#my @tile_ids = ();
#my @head = ();

#widget variables
my $b_start; 
my $b_pause;
my $main_frame;	
my $canvas;

my $time = 500;

#allocate the heap array,  
#$heap = [$MAX_COL * $MAX_ROW -1] = undef;


#game states
#my $START = 0;
#my $PAUSED = 1;
#my $RUNNING = 2;
#my $GAMEOVER = 4;
#my $state = $PAUSED;




sub create_screen { 
	$main_frame = MainWindow->new(-title=>'Hello, Tetris!', -background=>'#ffffff'); #creatse a the main window, with a given title and background color	
	$canvas = $main_frame->Canvas(-width=>$MAX_COL * $TILE_DIMENSION, -height=>$MAX_ROW *$TILE_DIMENSION,		#this creates a canvas elemetn inside of main_frame					-border=>2, -relief=>'ridge', -background=>'#000000')->pack();
	$b_start = $main_frame->Button(-text=>'start', -anchor=>'w')->pack('-side'=> 'left', '-fill' => 'y', '-expand' => 'y');
	$b_pause = $main_frame->Button(-text=>'quit', -anchor=>'e', -command=>sub{exit(0)})->pack('-side'=> 'left', '-fill' => 'y', '-expand' => 'y'); #to do pause, and prompt if they really want to quit
	
	
	
	
	}

create_screen();
MainLoop();
