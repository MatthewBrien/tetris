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

#TODO: FIRST ORDER OF BUISINESS - @heap is a 1D array. It's common for blocks to stop in oddplaces, and it is probably a indexing issue, I intend to fix this
use warnings;
use strict;
use Tk;

#initialize globals
my $MAX_COL = 10;
	my $MAX_ROW = 20;
	my $HEAP_SIZE = ($MAX_ROW * $MAX_COL-1);
	my $TILE_DIMENSION = 20; #tile size in pixels (it'@tile_idss a square)
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

#allocate the heap arra@_y,
my @heap = ();											#the heap contains a tile_id if it is filled, otherwise, 0
clear_heap(); #initialize the last element of the heap array to zero

my @patterns = (['110', 	#s1
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
		tick();
	}
}
#when a key is pressed, the function bound with it will execute
sub bind_key{
	my($keychar, $callback) = @_;
	if($keychar eq ' '){
		$keychar = "KeyPress-space";
	}
	$main_frame->bind("<${keychar}>", $callback);
}

sub create_tile{
	my ($tile, $color) = @_; #parameters passed to create_tile
	my ($row, $col); 	 #initialize two scalar variables
	$col = $tile % $MAX_COL;	#is this ever not initialized to Zero?
	$row = int($tile / $MAX_COL);
		#print("creating tile tile, $tile, color, $color, row, $row, col $col \n");
	push (@tile_ids,			#push to the array @tiel_ids, push, the canvas rectangle
				$canvas ->create('rectangle',
												 $col*$TILE_DIMENSION,
												 $row*$TILE_DIMENSION,
												 ($col+1)*$TILE_DIMENSION,
												 ($row+1)*$TILE_DIMENSION,
												 '-fill'=> $color,
												 '-tags'=>'block'));
	}

sub rotate_l{
my ($n, $p) = @_;
my $diff = $n - $p;
if($diff == 0){return 0;}

if($diff > 0){
	if($diff == -1){return 10;}
	elsif($diff == -2){return 20;}
	elsif($diff == -8){return -21;}
	elsif($diff == -9){return -11;}
	elsif($diff == -10){return -1;}
	elsif($diff ==-11){return 9;}
	elsif($diff ==-12){return 19;}
	elsif($diff ==-19){return-12;}
	elsif($diff ==-20){return -2;}
	else{return 8;}
}
else{
	if($diff == 1){return -10;}
	elsif($diff == 2){return 20;}
	elsif($diff == 8){return 21;}
	elsif($diff == 9){return 11;}
	elsif($diff == 10){return 1;}
	elsif($diff == 11){return -9;}
	elsif($diff == 12){return -19;}
	elsif($diff == 19){return 12;}
	elsif($diff == 20){return 2;}
	else {return -8;}
	}
	return 0;
}

sub create_random_block{
	#choose a random pattern, and random color, position at the top of the canvas
	my $rand_pat = $patterns[(int(rand(scalar(@patterns))))]; #select a random block pattern from @patterns
	my $rand_color = $colors[(int(rand(scalar(@colors))))];   #select a random color from @colors
	my $row = 0;
	my $col = 0;
	my $pattern_width = length($rand_pat->[0]); #width is the lenght of the first element int he array
	#print "Block Width = $pattern_width\n";
	my $pattern_height = scalar(@{$rand_pat});
	#print "Block Height = $pattern_height\n";
	my $center_col = int(($MAX_COL - $pattern_width )/2);
	while(1){
		if($col == $pattern_width){
			$row++; $col=0;
		}
		last if($row == $pattern_height); #novel break statement in perl, no flag, so last refers to the inner most enclosing loop

		if(substr($rand_pat->[$row], $col, 1) ne '0'){     #itterate over the pattern, if the charachter is not zero, push a cell to the @tiles array
			#print("$rand_pat->[$row]  row is $row col is $col \n");
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
	$col = 0; #might not need this
	foreach $tile (@tiles){
		create_tile($tile, $rand_color);
	}
	return 1;
}

sub new_game{
	#clear the canvas, check if you beat the high score, clear score, start the game
	$canvas ->delete('all');
	clear_heap();
	@tiles = ();
	mark_canvas();
}
sub clear_heap{
	my $i;
	for($i = 0; $i < $HEAP_SIZE; $i++)
	{
		$heap[$i]=0;
	}
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

sub move_left{
	if($state == $PAUSED){
		return; #don't move the block if the game is paused....cheater
	}
	else{
		$state = $PAUSED
	}
	my $tile;
	for $tile(@tiles){
		#check to the left of the block
		if((($tile % $MAX_COL) <= 0) || ($heap[$tile-1])){
						$state = $RUNNING;
						return;
					}
				}

		foreach $tile (@tiles){
			$tile--; #update the values in @tiles
		}
		$canvas->move('block', -$TILE_DIMENSION, 0);
		$state = $RUNNING;
}
sub move_right{
		if($state == $PAUSED){
			return; #don't move the block if the game is paused....cheater
		}
		else{
			$state = $PAUSED
		}
	my $tile;
	foreach $tile(@tiles){
		#check right of the block, to not move out of the canvas or over another blocks
		#print("checking at position $heap[$tile] current tile is $tile\n");
		if((($tile%$MAX_COL) == ($MAX_COL-1)) ||  ($heap[$tile+1])){
					$state = $RUNNING;
					return;
				}
			}
		foreach $tile(@tiles){
				$tile++;
			}

	$canvas->move('block', $TILE_DIMENSION, 0);
	$state = $RUNNING;
}

sub move_down{
 my $tile;
 my $first_cell_last_row = ($MAX_ROW - 1)*$MAX_COL; #bottom row of the playing field
 foreach $tile (@tiles){ #check if there is not already a block there
		if(($tile >= $first_cell_last_row) || ($heap[$tile+$MAX_COL])){
			merge_tiles();
			return 0;
		}
 }
 foreach $tile(@tiles){

	 $tile +=$MAX_COL; #remember, it's a 1-d array, to move down, we just add the width, which is the number of columns
	 #print "tile $tile \n";
 }
 $canvas -> move('block', 0, $TILE_DIMENSION ); #all current cells are tagged with 'block'
 return 1;
}

sub rotate {
    # rotates the block counter_clockwise
    return if (!@tiles);
    my $cell;
    # Calculate the pivot position around which to turn
    # The pivot is at (average x, average y) of all cells
    my $row_total = 0; my $col_total = 0;
    my ($row, $col);
    my @cols = map {$_ % $MAX_COL} @tiles;
    my @rows = map {int($_ / $MAX_COL)} @tiles;
    foreach (0 .. $#cols) {
        $row_total += $rows[$_];
        $col_total += $cols[$_];
    }
    my $pivot_row = int ($row_total / @cols + 0.5); # pivot row
    my $pivot_col = int ($col_total / @cols + 0.5); # pivot col
    # To position each cell counter_clockwise, we need to do a small
    # transformation. A row offset from the pivot becomes an equivalent
    # column offset, and a column offset becomes a negative row offset.
    my @new_cells = ();
    my @new_rows = ();
    my @new_cols = ();
    my ($new_row, $new_col);
    while (@rows) {
        $row = shift @rows;
        $col = shift @cols;
        # Calculate new $row and $col
        $new_col = $pivot_col + ($row - $pivot_row);
        $new_row = $pivot_row - ($col - $pivot_col);
        $cell = $new_row * $MAX_COL + $new_col;
        # Check if the new row and col are invalid (is outside or something
        # is already occupying that  cell)
        # If valid, then no-one should be occupying it.
        if (($new_row < 0) || ($new_row > $MAX_ROW) ||
            ($new_col < 0) || ($new_col > $MAX_COL)  ||
            $heap[$cell]) {
            return 0;
        }
        push (@new_rows, $new_row);
        push (@new_cols, $new_col);
        push (@new_cells, $cell);
    }
    # Move the UI tiles to the appropriate coordinates
    my $i= @new_rows-1;
    while ($i >= 0) {
        $new_row = $new_rows[$i];
        $new_col = $new_cols[$i];
        $canvas->coords($tile_ids[$i],
                        $new_col * $TILE_DIMENSION,      #x0
                        $new_row * $TILE_DIMENSION,     #y0
                        ($new_col+1) * $TILE_DIMENSION,  #x1
                        ($new_row+1) * $TILE_DIMENSION);
        $i--;
    }
    @tiles = @new_cells;
    1; # Success
}



sub merge_tiles{
	my $tile;
	foreach $tile (@tiles){
		$heap[$tile] = shift @tile_ids;
	}
	$canvas->dtag('block'); #there is no block, there is only failure
	my $last_cell = $MAX_ROW*$MAX_COL;
	my $filled_cell_count;
	my $rows_to_be_deleted =0;
	my $i;

	for($tile = 0; $tile < $last_cell;){
		$filled_cell_count=0;
		my $first_cell_in_row = $tile;
		for($i = 0; $i < $MAX_COL;$i++){
			$filled_cell_count++ if($heap[$tile++]);
		}
		if($filled_cell_count == $MAX_COL){
			#the row is full. We all know tetris row's are 10 blocks accross, but, this allows for variable size games
			for($i = $first_cell_in_row; $i< $tile; $i++){
				$canvas->addtag('delete', 'withtag'=>$heap[$i]);
			}
			splice(@heap, $first_cell_in_row, $MAX_COL);
			unshift(@heap, (undef) x $MAX_COL);
			$rows_to_be_deleted = 1;
		}
	}
 @tiles = ();
    @tile_ids = ();
    if ($rows_to_be_deleted) {
        $canvas->itemconfigure('delete',
                               '-fill'=> 'white');
        $main_frame->after (300,
                       sub {
                           $canvas->delete('delete');
                           my ($i);
                           my $last = $MAX_COL * $MAX_ROW;
                           for ($i = 0; $i < $last; $i++) {
                               next if !$heap[$i];
                               # get where they are
                               my $col = $i % $MAX_COL;
                               my $row = int($i / $MAX_COL);
                               $canvas->coords(
                                    $heap[$i],
                                    $col * $TILE_DIMENSION,       #x0
                                    $row * $TILE_DIMENSION,      #y0
                                    ($col+1) * $TILE_DIMENSION,   #x1
                                    ($row+1) * $TILE_DIMENSION); #y1

                           }
                       });
    }
}


sub create_screen{
	$main_frame = MainWindow->new(-title=>'Hello, Tetris!', -background=>'#000000'); #creatse a the main window, with a given title and background color
	$canvas = $main_frame->Canvas(-width=>$MAX_COL * $TILE_DIMENSION,
													      -height=>$MAX_ROW *$TILE_DIMENSION,		#this creates a canvas elemetn inside of main_frame
													      -border=>2,
													      -relief=>'ridge',
													      -background=>'#000000');



	$b_start = $main_frame->Button(-text=>'start',
													       -anchor=>'w',
													       -command=>\&start_pause);

	$b_quit = $main_frame->Button(-text=>'quit',
													       -anchor=>'e',
													       -command=>\&quit);
	$canvas->pack();
	$b_start->pack('-side'=> 'left', '-fill' => 'y','-expand' => 'y');
	$b_quit->pack('-side'=> 'left', '-fill' => 'y', '-expand' => 'y'); #TODO pause, anmd prompt if they really want to quit;

#	my $b_clear = $main_frame->Button(-text=>'clear',
	#																	-command=>\&new_game)->pack();
	# my $b_test = $main_frame->Button(-text=>"test_button",-command =>\&create_random_block)->pack();

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
	bind_key('w', \&rotate);
	bind_key('s', \&rotate);
	bind_key('a', \&move_left);
	bind_key('d', \&move_right);
	bind_key(' ', \&print_heap);
	bind_key(' ', \&move_down); #TODO: when looking below, we only need to check agains the tiles on the bottom row of the block
	set_state($START);
	new_game();
}

sub print_heap{
	print int(scalar(@heap));
	print int(scalar(@tiles));
	print "\n";
	my $i; my $j;
	for($i=0;$i<$HEAP_SIZE;$i++){
		print( "$i=$heap[$i] | ");

		if(($i % 9 )== 0){
		print("\n");
		}
	}
}
init();
MainLoop();
