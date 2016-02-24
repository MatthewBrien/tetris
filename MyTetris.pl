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
	my @tiles = ();
	my @tile_ids = ();
	my $tick_tock = 500;

#widget variables
	my $b_start;		#star button widget
	my $b_quit;
	my $main_frame;	 	#main widget
	my $canvas;		#playing field widget


#game states
	my $START = 0;
	my $PAUSED = 1;
	my $RUNNING = 2;
	my $GAMEOVER = 4;
	my $state = $PAUSED;

#allocate the heap array,
my @heap = ();
$heap[$MAX_COL * $MAX_ROW -1] = undef;

my @patterns = (['110 ', 	#s1
		 						 '011'],
		 					 	['1111'], 	#line
		 						['11',		#block
		  					 '11'],
								['011', #s2
								 '110'],
								 ['10', #L
								 	'10',
									'11'],
								 ['01', #J
								  '01',
									'11'],
								 ['010', #t
								  '111']);

my @colors = ( '#003366',	#dark_teal
		'#006699',	#teal
		'#00ffff',	#baby_blue
		'#003300',	#dark_green
		'#800000',	#maroon
		'#660033',	#violete
		'#ff00ff',	#pink
		'#666699',	#slate_blue
		'#ff9966',	#peach
	#	'#000000',	#black
		'#d9ff66'	#lime_green
	);

sub set_state{	#change the button text to match the came state,it would also be nice, TODO:if the buttons did not change shape
	$state = $_[0];
	if($state == $PAUSED){
		$b_start->configure(-text => 'Resume');
	}elsif ($state == $RUNNING){
		$b_start->configure(-text => 'Pause');
	}elsif($state == $GAMEOVER){
		#TODO make "GAME OVER" apper when the game is over
		#$canvas -> create('new_tk__text', 100, 100, -anchor =>'center', -text => "Game\nOver", -width => 100, -fontcolor=>'#ffffff');
		$b_start->configure(-text=>'Start');
	}elsif($state == $START){
		$b_start->configure(-text=>'Start');
	}
}
sub start_pause{
	if($state == $RUNNING){
		set_state($PAUSED);
	}
	else{
		if($state == $GAMEOVER){
			new_game();
		}
		set_state($RUNNING);
		#tick();
		start();
	}
}
#when a key is pressed, the function bound with it will execute
sub bind_key{
	my($key_char, $callback) = @_;
	if($key_char == ' '){
		$key_char = "KeyPress-space";
	}
	$main_frame->bind("<${key_char}>", $callback);
}

sub create_tile{
	my ($tile, $color) = @_; #parameters passed to create_tile
	my ($row, $col); 	 #initialize two scalar variables
	$col = $tile % $MAX_COL;	#is this ever not initialized to Zero?
	$row = int($tile / $MAX_COL);
	push (@tile_ids,			#push to the array @tiel_ids, push, the canvas rectangle
		$canvas ->create('rectangle',
				 $col*$TILE_DIMENSION,
				 $row*$TILE_DIMENSION,
				 ($col+1)*$TILE_DIMENSION,
				 ($row+1)*$TILE_DIMENSION,
				 '-fill'=> $color,
				 '-tags'=>'block'));
	}

sub create_random_block{
	#choose a random pattern, and random color, position at the top of the canvas
	@tiles = ();
	my $rand_pat = $patterns[(int(rand(scalar(@patterns))))]; #select a random block pattern from @patterns
	my $rand_color = $colors[(int(rand(scalar(@colors))))];   #select a random color from @colors
	my $row = 0;
	my $col = 0;
	my $pattern_width = length($rand_pat->[0]); #width is the lenght of the first element int he array
	my $pattern_height = scalar(@{$rand_pat});

	my $center_col = int(($MAX_COL - $pattern_width )/2);
	while(1){
		if($col == $pattern_width)
		{$row++; $col=0;}
		last if($row == $pattern_height); #novel break statement in perl, no flag, so last refers to the inner most enclosing loop
		if(substr($rand_pat->[$row], $col, 1) != '0'){     #itterate over the pattern, if the charachter is not zero, push a cell to the @tiles array
			push(@tiles, $row*$MAX_COL + $col + $center_col); #this is to get to the right element of the 1d array?
		}
		$col++;
	}
	$col = 0;
	my $tile;
	#first check all the cells, and make suer there are no tiles already there
	foreach $tile (@tiles){
		if($heap[$tile]){return 0;}
	}
	foreach $tile (@tiles){
		create_tile($tile, $rand_color);
	}
	return 1;
}

#start is unfinished
sub start{
	create_random_block();
	tick();
	#create_tile(10, @colors[rand(11)]);  #currently, click the start button to create a random colored square
	}
sub new_game{
	#clear the canvas, check if you beat the high score, clear score, start the game
	$canvas ->delete('all');
	@heap = ();
	@tiles = ();
	mark_canvas();
	#tick?
}
sub game_over{
		set_state($GAMEOVER);
}
sub quit{
	#exit more or less gracefully
	exit(0);
	}

sub tick {
	return if($state == $PAUSED);
	if(!@tiles){ #if there is the cell array is empty
		if(!create_random_block()){ #if create_random_block cant make a new block,
			game_over();
			return;
		}
	$main_frame->after($tick_tock, \&tick); #restart timer for next drop
	return;
	}
	move_down();
	$main_frame->after($tick_tock, \&tick); #restart timer for next drop
}

sub move_down{
 my $tile;
 my $first_cell_last_row = ($MAX_ROW - 1)*$MAX_COL;
 foreach $tile (@tiles){ #check if there is not already a block there
		if(($tile >= $first_cell_last_row) || ($heap[$tile+$MAX_COL])){
			merge_tiles();
			return 0;
		}
 }
 foreach $tile(@tiles){
	 $tile +=$MAX_COL; #remember, it's a 1-d array, to move down, we just add the width, which is the number of columns
 }
 $canvas -> move('block', 0, $TILE_DIMENSION ); #all current cells are tagged with 'block'
 return 1;
}

sub merge_tiles{
	my $cell;
	foreach $cell (@tiles){
		$heap[$cell] = shift @tile_ids;
	}
	$canvas->dtag('block'); #there is no block, there is only failure
	my $last_cell = $MAX_ROW*$MAX_COL;
	my $filled_cell_count = 0;
	my $rows_to_be_deleted;
	my $i;

	for($cell = 0; $cell < $last_cell;){
		$filled_cell_count=0;
		my $first_cell_in_row = $cell;
		for($i = 0; $i < $MAX_COL;$i++){
			$filled_cell_count++ if($heap[$cell++]);
		}
		if($filled_cell_count == $MAX_COL){
			#the row is full. We all know tetris row's are 10 blocks accross, but, this allows for variable size games
			for($i = $first_cell_in_row; $i< $cell; $i++){
				$canvas->addtag('delete', 'withtag'=>$heap[$i]);
			}
			splice(@heap, $first_cell_in_row, $MAX_COL);
			unshift(@heap, (undef) x $MAX_COL);
			$rows_to_be_deleted = 1;
		}
	}
	@tiles = ();
	@tile_ids = ();
	if($rows_to_be_deleted){#pretty much everything in perl evaluates to true, except 0
		$canvas -> itemconfigure('delete', -fill=>'#ffffff');
		$main_frame->after(300,
											sub{
												  $canvas->delete('delete');
													my($i);
													my $last = $MAX_COL * $MAX_ROW;
													for($i = 0; $i<$last; $i++){
														next if (!$heap[$i]);
														my $col = $i % $MAX_COL;
														my $row = int($i / $MAX_COL);
														$canvas->coords(
																						$heap[$i],
																						$col*$TILE_DIMENSION, #x0,y0,x1, y1
																						$row+$TILE_DIMENSION,
																						($col+1)*$TILE_DIMENSION,
																						($row+1)*$TILE_DIMENSION);
													}
											})
		}
	}

sub create_screen{
	$main_frame = MainWindow->new(-title=>'Hello, Tetris!', -background=>'#000000'); #creatse a the main window, with a given title and background color
	$canvas = $main_frame->Canvas(-width=>$MAX_COL * $TILE_DIMENSION,
				      -height=>$MAX_ROW *$TILE_DIMENSION,		#this creates a canvas elemetn inside of main_frame
				      -border=>2,
				      -relief=>'ridge',
				      -background=>'#000000')
				      ->pack();


	$b_start = $main_frame->Button(-text=>'start',
				       -anchor=>'w',
				       -command=>\&start_pause)
				 ->pack('-side'=> 'left',
							'-fill' => 'y',
							'-expand' => 'y');

	$b_quit = $main_frame->Button(-text=>'quit',
				       -anchor=>'e',
				       -command=>\&quit)
				->pack('-side'=> 'left',
				       '-fill' => 'y',
				       '-expand' => 'y'); #to do pause, and prompt if they really want to quit;

	my $b_clear = $main_frame->Button(-text=>'clear',
																		-command=>\&new_game)->pack();
	my $b_test = $main_frame->Button(-text=>"test_button",
																		-command =>\&create_random_block)->pack();

	}

sub mark_canvas{	#draw horizontal and vertical lines accross the canvas
	my $i;
	foreach $i (1 .. $MAX_ROW){
		$canvas->create('line', 0, $i *$TILE_DIMENSION, $MAX_COL*$TILE_DIMENSION, $i*$TILE_DIMENSION, -fill => '#222222');
	}
	foreach $i (1 .. $MAX_COL){
		$canvas->create('line', $i*$TILE_DIMENSION, 0, $i*$TILE_DIMENSION, $MAX_ROW*$TILE_DIMENSION, -fill=>'#222222');
	}
}

sub init{
	create_screen();
	#bind_key('w', \&rotate);
	#bind_key('s', \&rotate);
	#bind_key('a', \&move_left);
	#bind_key('d', \&move_right);
	#bind_key(' ', \&drop);
	set_state($START);
	new_game();
}

init();
MainLoop();
