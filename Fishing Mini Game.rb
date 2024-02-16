#------------------------------------------------------------------------------#
#  Galv's Fishing Mini Game
#------------------------------------------------------------------------------#
#  For: RPGMAKER VX ACE
#  Version 1.5
#------------------------------------------------------------------------------#
#  NOTICE: This script is NOT free for commercial use.
#  Contact Galv via PM at one of the following forums:
#  http://www.rpgmakervxace.net/
#  http://forums.rpgmakerweb.com/
#------------------------------------------------------------------------------#

#------------------------------------------------------------------------------#
#  2015-02-07 - Version 1.5 - rare crash hopefully fixed
#  2013-04-22 - Version 1.4 - added fish statistics scene
#                           - added scripts to use in control variables to use
#                             data in eventing.
#  2013-04-22 - Version 1.3 - fixed a bug with crashing when equipping rod
#  2013-04-22 - Version 1.2 - stopped the fish caught message from ending too
#                             soon. Added controls to HUD image to look nicer.
#  2013-04-21 - Version 1.1 - added ability to run common event when fish caught
#                           - fixed a big image disposing bug (oops!)
#                           - upgraded the fish caught message with custom text
#                             options and image.
#                           - added storing fish data and script calls to use it
#  2013-04-20 - Version 1.0 - release
#------------------------------------------------------------------------------#
#  This script allows the player to play a fishing mini game.
#
#  HOW TO PLAY
#  The player needs a rod item and bait items in order to fish. They choose
#  which rod and bait to equip, each having a different use. Once equipped, the
#  player casts his line into the water and must try to reel the line in to get
#  the bait close enough to a fish to take it. The action key or right arrow
#  will reel the line in.
#  Once a fish as the bait, the player must reel it in, but be careful to not
#  reel in while the fish is pulling to the left, else the line strength will
#  weaken and eventually break. 
#
#  RODS
#  The rod strength of an item detemines how much strain the line can take
#  before it breaks. Also, the higher the rod strength is above a fish's 'pull'
#  will increase the speed the fish is reeled in. If a fish has more pull than
#  a rod's strength, it will break the line much quicker than normal.
#
#  BAIT
#  Baits have 2 attributes - type and weight. Fish can be set up to only eat
#  cetain types of bait. Weight determines how fast the bait sinks in the water.
#
#  FISH
#  Fish can be set up with a bunch of options (see futher down). Note that these
#  options allow you to create "fish" that aren't fish. For example, you could
#  make a crab that can only move on the bottom of the water.
#
#  CONTROLS
#  Press Z at the right time in the power bar to detemine casting distance.
#  Hold the right arrow to reel in.
#------------------------------------------------------------------------------#

#------------------------------------------------------------------------------#
#  SCRIPT CALLS
#------------------------------------------------------------------------------#
#
#  fish_back(w,x,y,z)   # Change background images used in fishing scene. 
#                       # w = over, x = under, y = flow, z = flow opacity
#
#  fish_opt("Music")    # Change fishing options
#
#
#
#  add_fish(x,x,x,x)    # Add these fish_id's into the pond.
#
#  rand_fish(x,min,max) # Add a random amount between min and max of fish with
#                       # fish_id x into the pond. Make min a negative number to
#                       # increase the chance the fish will not appear at all.
#
#  fishing              # Starts the fishing scene (make sure you add fish using
#                       # any amount of the script calls above before you call
#                       # the fishing scene).
#
#  fishing_stats        # Starts the fishing statistics scene.
#
#------------------------------------------------------------------------------#
#  EXAMPLE OF USE
#  fish_back(3,0,2,150)  # fishing will use images from /Graphics/GFish/ folder
#                        # over3, under0 and flow2. flow2 will be at 150 opacity
#                        # Default is fish_back(0,0,0,120)
#  fish_opt("Town1")     # Changes music to Town1
#  add_fish(1,1,2)       # Adds 2 x fish with id1 and 1 x fish with id2 to pond
#  rand_fish(0,2,10)     # Adds 2-10 fish with id0 to pond.
#                        
#------------------------------------------------------------------------------#

#------------------------------------------------------------------------------#
#  Notetag for ITEMS
#------------------------------------------------------------------------------#
#
#  <bait: type,weight>     # Items with this tag can be used as bait.
#                          # type = a number to determine what fish like it
#                          # weight = speed bait sinks in the water (Default 10)
#
#  <bait_img: image>  # The image name of to use a different bait spritesheet
#                     # /Graphics/GFish/ folder. (use same layout as bait.png)
#
#  <rod: x>           # Items with this tag can be used as fishing rods. 
#                     # x = strength of the rod (Minimum 1). The rod strength
#                     # determines how long it takes for the line to snap and
#                     # also decreases the amount of pull a fish has.
#
#  <rod_img: image>   # The image name of a new rod spritesheet to use from
#                     # /Graphics/GFish/ folder. (use same layout as rod.png)
#
#------------------------------------------------------------------------------#
#  EXAMPLES OF USE:
#  <bait: 7,10>       # Fish with bait_type 7 will eat it. 10 weight is default.
#  <bait_img: bait2>  # Uses /Graphics/GFish/Bait2.png for the bait image.
#  <rod_img: rod2>    # Uses /Graphics/GFish/Bait2.png for the held pole image.
#  <rod: 1>           # A rod with strength 1 (weakest)
#------------------------------------------------------------------------------#

#------------------------------------------------------------------------------#
#  SCRIPT for CONTROL VARIABLES
#------------------------------------------------------------------------------#
#  $game_system.fish[id].caught   # get number of that type of fish caught
#  $game_system.fish[id].length   # get the record length of that fish caught
#  $game_system.fish[id].width    # get the record width of that fish caught
#  count_all_fish                 # get the total of all fish caught
#  record_fish(data,id?)   # data can be  :weight  or  :length
#                          # this will return data of your largest fish.
#                          # id? is optional. It will return fish id if true
#                          # if you haven't caught a fish, this will be -1
#------------------------------------------------------------------------------#
#  EXAMPLE
#  record_fish(:length,true)   # gets the id of your longest fish
#  record_fish(:length)        # gets the length of your longest fish
#  record_fish(:weight,true)   # gets the id of your heaviest fish
#  record_fish(:weight)        # gets the weight of your heaviest fish
#------------------------------------------------------------------------------#


($imported ||= {})["Galv_Fishing"] = true
module GFISH
  
#-------------------------------------------------------------------------------
#
#  * SETTINGS
#
#-------------------------------------------------------------------------------

  # Gameplay
  
  FISH_VAR = 1   # The variable used to store the fish_id of the last fish you
                 # have caught. This can be used, for example, in conjunction
                 # with the common event fish setting for conditional branches.

  # Audio
  
  DEFAULT_BGM = "Angevin"   # Default fishing music
  DEFAULT_SE = "Up4"      # SE that plays when you successfully catch a fish
  
  CAST_SE = "Wind4"       # SE when casting line
  SPLASH_SE = "Dive"      # SE when bait lands in water
  BROKE_SE = "Blow5"      # SE when line breaks
  
  # Vocab
  
  POWER = " MEDIDOR "         # Text used for power meter

  CTEXT_BEFORE = " Você pescou um " # Text that appears before caught fish item
  CTEXT_AFTER = " ! "              # Text that appears after caught fish item
  CATCH_ITEM_0 = " Pegou " # Text appears when you catch a fish that has
                                 # item 0 in it's setup and no custom text.
  
  CONTROLS = ""           # Text that appears top right of screen.
  CONTROL_FONT_SIZE = 20  # I added the controls into the HUD instead of using
                          # this text.

  STAT_HEADING = " ESTATÍSTICAS "  # Heading of the fish statistics scene
  TOTAL_FISH = " Total de peixes pegos "  # Text before the total number of fish caught
  FISH_TYPES = " Tipos de peixes "    # Text displayed before how many type of fish
                               # player has caught.
  RECORD_FISH = " Tamanho "  # Text for biggest length fish player has caught
  
  FISH_CAUGHT = " Apanhados "
  FISH_LENGTH = " Comprimento "
  FISH_WEIGHT = " Peso "
  
  
  # Other
  ROD_X = 0  # Offset the rod's x position
  ROD_Y = 0  # Offset the rod's y position
  
  DECIMALS = true    # Use decimal places for weight and height of fish stats.


#-------------------------------------------------------------------------------
#  * FISH SETUP
#-------------------------------------------------------------------------------

  FISH = [] # don't touch
#-------------------------------------------------------------------------------
#  Here is where you set up all the possible fish you can catch and certain
#  attributes about each fish. The number in each FISH[x] below must be unique. 
#  This is the 'fish_id' used to add fish manually to a pond
#-------------------------------------------------------------------------------

    FISH[0] = [    # Purple Fish
                   "fish2",     # graphic
                   5,           # speed
                   0,           # pull
                   1,           # move type
                  [2,8],        # level
                   -1,          # x pos
                   23,          # item
                  [1,2,3],      # bait type
                  "",           # custom se
                  [20,2],       # range
                  0,            # common event
                  [150,310],    # length
                  [23,52],      # weight
                  true,         # stats
                  "",           # custom txt
              ]

#-------------------------------------------------------------------------------

    FISH[1] = [    # Green Fish
                   "fish1",     # graphic
                   8,           # speed
                   0,           # pull
                   1,           # move type
                  [1,9],        # level
                   -1,          # x pos
                   24,          # item
                  [2,4],        # bait type
                  "",           # custom se
                  [20,2],       # range
                  0,            # common event
                  [100,210],    # length
                  [20,45],      # weight
                  true,         # stats
                  "",           # custom txt
              ]
              
#-------------------------------------------------------------------------------

    FISH[2] = [    # Rock
                   "rock",      # graphic
                   0,           # speed
                   99,          # pull
                   -1,          # move type
                  [0,0],        # level
                   200,         # x pos
                   0,           # item
                  [1,2,3,4],    # bait type
                  "",           # custom se
                  [20,20],      # range
                  0,            # common event
                  [400,400],    # length
                  [999,999],    # weight
                  false,        # stats
                  "",           # custom txt
              ]
              
#-------------------------------------------------------------------------------

    FISH[3] = [    # A chest!
                   "chest",     # graphic
                   5,           # speed
                   2,           # pull
                   0,           # move type
                  [0,0],        # level
                   400,         # x pos
                   26,          # item
                  [6],          # bait type
                  "Item3",      # custom se
                  [20,20],      # range
                  0,            # common event
                  [350,350],    # length
                  [200,200],    # weight
                  false,        # stats
                  "",           # custom txt
              ]

#-------------------------------------------------------------------------------

    FISH[4] = [    # A Monster!
                   "jellyfish",   # graphic
                   5,           # speed
                   1,           # pull
                   2,           # move type
                  [0,5],        # level
                   -1,          # x pos
                   0,           # item
                  [1,2,3,4],    # bait type
                  "Item3",      # custom se
                  [40,3],       # range
                  1,            # common event
                  [30,60],      # length
                  [200,200],    # weight
                  false,        # stats
                  "Você pegou um MONSTRO!", # custom txt
              ]
              
#-------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
#  EXPLANATION
#  graphic   = the image used from /Graphics/GFish/ folder.
#  speed     = the swim speed of the fish. 10 is default.
#  pull      = the higher their pull, the more difficult it is to reel in and
#              quicker the line will break.
#  move type = the type of movement. 
#             -1 = unmovable - use for things like rocks to snag the line
#                            - will constantly stress the line when reeling in
#              0 = inanimate - use for things like chests or quest items
#                            - will constantly stress the line when reeling in
#              1 = passive - normal fish movement
#                          - will stress the line only when fish is pulling
#              2 = erratic - fish changes direction more often
#                          - will stress the line only when fish is pulling
#  level     = [lowest,highest] fish swims. 0 = ground, 10 = water surface
#  x pos     = the fish will start in this x position. -1 is random.
#  item      = the item that will be gained if fish is caught (item id)
#  bait type = list of bait types that the fish will eat.
#  custom se = play a different SE instead of DEFAULT_SE when fish caught
#  range     = [detect,take] distance from bait a fish will detect and take it
#              default is detect 20, take 2.
#  common event = When this fish is caught, it will exit and run common event
#  length    = no gameplay effect. For fish stats only. rand between [min,max]
#  weight    = no gameplay effect. For fish stats only. rand between [min,max]
#  stats     = include in the fish-caught stats page? true or false
#  custom txt = text displayed instead of the item name when catching a fish and
#               in the fish stat scene.
#-------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
#
#  * END SETTINGS
#
#-------------------------------------------------------------------------------

end


    #----------------------#
#---|   GAME_INTERPRETER   |----------------------------------------------------
    #----------------------#

class Game_Interpreter
  def fishing
    $game_system.save_bgm
    command_221
    SceneManager.call(Scene_GFish)
    wait(1)
    $game_system.fish_list = []
    command_222
  end
  
  def fishing_stats
    SceneManager.call(Scene_FishStats)
  end
  
  def count_all_fish
    fish_caught = 0
    $game_system.fish.each { |fish|
      next if !fish.stats
      fish_caught += fish.caught
    }
    return fish_caught
  end
  
  def record_fish(data,get_id = false)
    check = 0
    fish_id = -1
    $game_system.fish.each { |fish|
      next if !fish.stats
      if data == :length && check < fish.length
        check = fish.length
        fish_id = fish.id
      elsif data == :weight && check < fish.weight
        check = fish.weight
        fish_id = fish.id
      end
    }
    if get_id
      return fish_id
    else
      return check
    end
  end
  
  
  
  
  def calculate_data
    @fish_caught = 0
    length_check = 0
    @c = 0
    @t = 0
    @longest_fish = nil
    $game_system.fish.each { |fish|
      next if !fish.stats
      @fish_caught += fish.caught
      if length_check < fish.length
        length_check = fish.length
        @longest_fish = fish.id
      end
      @c += 1 if fish.caught > 0
      @t += 1
    }
  end
  
  
  
  
  
  
  
  def fish_back(over,under,flow,flowopacity)
    $game_system.fishb = [over,under,flow,flowopacity]
  end

  def fish_opt(music)
    $game_system.fishs[0] = music
  end
  
  def add_fish(*args)
    $game_system.fish_list += [*args]
  end
  
  def rand_fish(fish_id,min,max)
    amount = (rand(min - max) + min).to_i
    amount.times { |i| $game_system.fish_list << fish_id } if amount > 0
  end
end

    #-----------#
#---|   CACHE   |---------------------------------------------------------------
    #-----------#

module Cache
  def self.gfish(filename)
    load_bitmap("Graphics/GFish/", filename)
  end
end # Cache


    #-----------------#
#---|   GAME_SYSTEM   |---------------------------------------------------------
    #-----------------#

class Game_System
  attr_accessor :fish       # Data of all fish caught
  attr_accessor :fishb      # Fishing scene background images
  attr_accessor :fishs      # Fishing scene settings
  attr_accessor :fish_list  # List of fish that will appear in next scene
  
  alias galv_fish_gs_initialize initialize
  def initialize
    @fishb = [0,0,0,120]  # over, under, flow, opacity
    @fishs = Array.new([GFISH::DEFAULT_BGM])
    @fish_list = []
    @fish = []
    GFISH::FISH.each_with_index { |fish,i|
      if fish.nil?
        @fish << nil
      else
        @fish << Fish_Stats.new(i)
      end
    }
    galv_fish_gs_initialize
  end
end # Game_System


    #-----------------#
#---|   GAME_PLAYER   |---------------------------------------------------------
    #-----------------#

class Game_Player < Game_Character
  attr_accessor :equipped_bait
  attr_accessor :equipped_rod
end # Game_Player < Game_Character


    #----------------#
#---|   RPG::ITEMS   |----------------------------------------------------------
    #----------------#

class RPG::Item
  def bait
    if @bait.nil?
      if @note =~ /<bait:[ ](.*)>/i
        @bait = $1.to_s.split(",").map {|i| i.to_i}
      else
        @bait = nil
      end
    end
    @bait
  end
  def rod
    if @rod.nil?
      if @note =~ /<rod:[ ](.*)>/i
        @rod = $1.to_i
      else
        @rod = nil
      end
    end
    @rod
  end
  def rod_img
    if @rod_img.nil?
      if @note =~ /<rod_img:[ ](.*)>/i
        @rod_img = $1
      else
        @rod_img = "rod"
      end
    end
    @rod_img
  end
  def bait_img
    if @bait_img.nil?
      if @note =~ /<bait_img:[ ](.*)>/i
        @bait_img = $1
      else
        @bait_img = "bait"
      end
    end
    @bait_img
  end
end # RPG::Item


    #------------------#
#---|   GAME_FISHING   |--------------------------------------------------------
    #------------------#

class Game_Fishing
  attr_accessor :reeling
  attr_accessor :fishing_pattern
  attr_accessor :fish_phase
  attr_accessor :phase_timer
  attr_accessor :bait_x
  attr_accessor :bait_y
  attr_accessor :fish_hooked
  attr_reader   :surface_y
  attr_reader   :floor_y
  attr_reader   :end_x
  attr_accessor :fish
  
  def initialize
    @fishing_pattern = 1
    @fish_phase = 0
    @bait_x = 0
    @bait_y = 0
    @phase_timer = 0
    @end_x = player_x - 25
    @surface_y = player_y + 20
    @floor_y = Graphics.height - 20
    @reelx = 0
    @reely = 0
  end
  
  def refresh_fish
    @fish = []
    $game_system.fish_list.each_with_index { |id,i|
      next if GFISH::FISH[id].nil?
      @fish.push(Game_Fish.new(i,id))
    }
  end
  
  def player_x
    Graphics.width - 40
  end
  def player_y
    160
  end
  
#---|   UPDATE STUFF   |
  
  def update
    update_phase
  end
  
  def update_phase
    case @fish_phase
    when 0
      update_phase_0
    when 1
      update_phase_1
    when 2
      update_phase_2
    when 3
      update_phase_3
    when 4
      update_phase_4
    when 5
      update_phase_5
    end
    @phase_timer += 1
  end
  
  def update_phase_0
    @fishing_pattern = 1
    @bait_y = 0
    @bait_x = 0
    @fish.each { |fish| fish.update_normal }
  end

  def update_phase_1
    # Determine cast distance
    update_cancel_button
    if Input.trigger?(:C)
      @phase_timer = 0
      @fish_phase = 2
      @bait_y = @surface_y
      @line_strength = 90 + 10 * $game_player.equipped_rod.rod
      SceneManager.scene.casting_set
    end
    @fish.each { |fish| fish.update_normal }
  end

  def update_phase_2
    # Casting rod animation
    RPG::SE.new(GFISH::CAST_SE,70,70).play if @phase_timer == 18
    if @phase_timer >= 30
      RPG::SE.new(GFISH::SPLASH_SE,70,80).play
      SceneManager.scene.spriteset.splash.reset
      @fish_phase = 3
      SceneManager.scene.spriteset.rod.line_in_water
      @phase_timer = 0
    end
    @fish.each { |fish| fish.update_normal }
  end
  
  def update_phase_3
    # Fishing phase
    update_cancel_button
    if Input.press?(:RIGHT) || Input.press?(:C)
      reeling_in
    else
      sinking
    end
    @fish.each { |fish| fish.update_action }
  end
  
  def update_phase_4
    # Fish is on the line!
    update_fish_struggle
    @fish.each { |fish| fish.update_action }
  end
  
  def update_phase_5
    # Victory stuff
    @fish.each { |fish| fish.update_normal }
    cancel_fishing if Input.trigger?(:C)
    update_cancel_button
  end

  def update_cancel_button
    cancel_fishing if Input.press?(:B)
  end
  
#---|   FUNCTIONALITY   |

  def sinking
    if @bait_y < @floor_y
      @bait_y += $game_player.equipped_bait.bait[1].to_f / 10.to_f
    end
    @reeling = false
    @fishing_pattern = 0
  end

  def reeling_in
    @reeling = true
    @fishing_pattern = 2
    @bait_x += 1.5 if @bait_x <= @end_x
    @bait_y -= 1.5 if @bait_y >= @surface_y
    cancel_fishing if @bait_x >= @end_x && @bait_y <= @surface_y
  end

  def cancel_fishing
    @fish_phase = 0
    @fish_hooked = false
    @phase_timer = 0
    @reeling = false
    SceneManager.scene.cancel_fishing
  end
  
  def casting
    @phase_timer = 0
    @fish_phase = 1
  end
  
  def update_fish_struggle
    reeling_in_struggle
    
    if @fish_hooked.move_type < 0
      fish_x = 0; fish_y = 0
    elsif @fish_hooked.move_type == 0
      fish_x = 0; fish_y = 0
      fish_x = @reelx
      fish_y = @reely + 1
    else
      fish_x = @reelx.to_f + (@fish_hooked.dir * 2)
      fish_y = @reely.to_f + (@fish_hooked.vdir * 2)
    end

    if fish_x > 0
      @bait_x += fish_x if @bait_x < @end_x
    elsif fish_x < 0
      @bait_x += fish_x if @bait_x > @fish_hooked.left
    end
    if fish_y > 0
      @bait_y += fish_y if @bait_y < @floor_y
    elsif fish_y < 0
      @bait_y += fish_y if @bait_y > @surface_y
    end
    test_line
    lost_fish if Input.trigger?(:B)
  end

  def test_line
    if @reeling && @fish_hooked.dir < 0 || @reeling && @fish_hooked.move_type <= 0
      @line_strength -= [@fish_hooked.pull - $game_player.equipped_rod.rod,1].max
    end
    lost_fish if @line_strength <= 0
  end
  
  def lose_bait
    item = $game_player.equipped_bait
    $game_party.lose_item(item, 1)
    SceneManager.scene.refresh_menus if SceneManager.scene_is?(Scene_GFish)
  end
  
  def reeling_in_struggle
    if Input.press?(:RIGHT) || Input.press?(:C)
      @reeling = true
      @fishing_pattern = 2
      if @fish_hooked.pull < 0
        @reelx = 0
        @reely = 0
      else
        @reelx = 1 * [$game_player.equipped_rod.rod - @fish_hooked.pull,1].max
        @reely = -1 * [$game_player.equipped_rod.rod - @fish_hooked.pull,1].max
      end
      caught_fish if @bait_x >= @end_x && @bait_y <= @surface_y &&
        @fish_hooked.move_type >= 0
    else
      @reelx = 0
      @reely = 0
      @reeling = false
      @fishing_pattern = 0
    end
  end
  
  def lost_fish
    @fish_hooked.lost
    @fish_hooked.check_dir
    RPG::SE.new(GFISH::BROKE_SE,100,100).play
    cancel_fishing
    lose_bait
  end
  
  def caught_fish
    @fish_phase = 5
    @fish_hooked.caught
    add_fish_data
    if @fish_hooked.se == ""
      RPG::SE.new(GFISH::DEFAULT_SE,70,70).play
    else
      RPG::SE.new(@fish_hooked.se,70,70).play
    end
    lose_bait
    if @fish_hooked.item > 0
      item = $data_items[@fish_hooked.item] 
      $game_party.gain_item(item,1)
    end
    SceneManager.scene.show_victory
  end
  
  def add_fish_data
    $game_variables[GFISH::FISH_VAR] = @fish_hooked.fish_id
    f = $game_system.fish[@fish_hooked.fish_id]
    f.caught += 1
    f.length = @fish_hooked.length if f.length < @fish_hooked.length
    f.weight = @fish_hooked.weight if f.weight < @fish_hooked.weight
    $game_temp.reserve_common_event(@fish_hooked.cevent)
  end
end # Game_Fishing


    #---------------#
#---|   GAME_FISH   |-----------------------------------------------------------
    #---------------#
    
class Game_Fish
  attr_accessor :x
  attr_accessor :y
  attr_accessor :living
  attr_accessor :fish_id  # the fish id to get fish stats
  attr_reader :id         # the id of the fish in the pond
  attr_reader :graphic
  attr_reader :speed
  attr_reader :move_type
  attr_reader :item
  attr_reader :bait_type
  attr_reader :dir
  attr_reader :vdir
  attr_reader :se
  attr_reader :pull
  attr_reader :cevent
  attr_reader :length
  attr_reader :weight
  attr_reader :stats
  attr_reader :ctxt
  
  def initialize(id,fish_id)
    @id = id
    @fish_id = fish_id
    initialize_variables
  end
  
  def surface; $game_fishing.surface_y; end
  def floor;   $game_fishing.floor_y; end
  def left;      10; end
  def right;     $game_fishing.end_x; end
  def moving?;   @movetimer > 0; end
    
  def get_fish_minmax
    if @level[0] <= 0
      @fish_floor = floor
    else
      @fish_floor = floor - (floor - surface) * (@level[0] * 0.1)
    end
    if @level[1] <= 0
      @fish_surface = floor
    else
      @fish_surface = floor - (floor - surface) * (@level[1] * 0.1)
    end
  end

  def initialize_variables
    @living = true
    @movetimer = 0
    @graphic,@speed,@pull,@move_type,@level,@x,@item,@bait_type,@se,@range,
      @cevent,@lengtha,@weighta,@stats,@ctxt = Array.new(GFISH::FISH[@fish_id])
    random_stats
    @speed *= 0.1
    get_fish_minmax
    set_fish_starting
  end
  
  def random_stats
    rand_ratio = ((rand(100) + 1) * 0.01).round(2)
    min = @lengtha[0].to_f
    max = @lengtha[1].to_f
    @length = ((max - min).to_f * rand_ratio + min.to_f).round(1)
    @length = @length.to_i if !GFISH::DECIMALS
    min = @weighta[0].to_f
    max = @weighta[1].to_f
    @weight = ((max - min) * rand_ratio + min).round(1)
    @weight = @weight.to_i if !GFISH::DECIMALS
  end
  
  def set_fish_starting
    if @move_type > 0
      @dir = rand(3) - 1   # -1 = left, 0 = none, 1 = right
      @vdir = rand(3) - 1  # -1 = up, 0 = none, 1 = down
    else
      @dir = 0
      @vdir = 0
    end
    @x = (rand(left - right) + left).to_i if @x < 0
    level = (rand(@level[0] - @level[1]) + @level[0]).to_i
    if level == 0
      @y = floor
    else
      @y = floor - (floor - surface) * (level * 0.1)
    end
  end
  
  def alive?
    @living
  end
  
  def near_bait?
    if @x.between?($game_fishing.bait_x - @range[0],$game_fishing.bait_x + @range[0]) &&
        @y.between?($game_fishing.bait_y - @range[0],$game_fishing.bait_y + @range[0]) &&
        $game_player.equipped_bait &&
        @bait_type.include?($game_player.equipped_bait.bait[0])
      return true
    end
    return false
  end
  
  def update_action
    if @hooked
      update_hooked
    elsif $game_fishing.fish_phase == 4
      update_normal
    elsif $game_fishing.fish_phase == 3 && near_bait?
      update_near_bait
      update_nibble
    else
      update_normal
    end
  end
  
  def update_near_bait
    return if @move_type < 0
    if @x < $game_fishing.bait_x
      @x += @speed * 1.5
      @dir = 1 if @x < $game_fishing.bait_x - 5
    elsif @x > $game_fishing.bait_x
      @x -= @speed * 1.5
      @dir = -1 if @x > $game_fishing.bait_x + 5
    end
    if @y < $game_fishing.bait_y
      @y += @speed * 1.5 if @y < @fish_floor
      @vdir = 1
    elsif @y > $game_fishing.bait_y
      @y -= @speed * 1.5 if @y > @fish_surface
      @vdir = -1
    end
  end
  
  def update_nibble
    if @x.between?($game_fishing.bait_x - @range[1],$game_fishing.bait_x + @range[1]) &&
      @y.between?($game_fishing.bait_y - @range[1],$game_fishing.bait_y + @range[1])
      @hooked = true
      $game_fishing.fish_hooked = self
      RPG::SE.new("Blow5",70,80).play
      SceneManager.scene.spriteset.fish_sprites[@id].flash(Color.new(255,255,255,180), 6) 
      $game_fishing.fish_phase = 4
      @dir = -1 if @move_type > 0
    end
  end

  def check_dir
    if @move_type <= 0
      @dir = 0
      @vdir = 0
    end
  end
  
  def update_hooked
    return if @move_type < 0
    @x = $game_fishing.bait_x
    @y = $game_fishing.bait_y
    determine_struggle if !moving?
    @movetimer -= 1
  end
  
  def determine_struggle
    if @move_type <= 0
      @dir = 0
      @vdir = 0
    else
      @dir = (rand(3) - 1).to_f * @speed.to_f
      @vdir = (rand(3) - 1).to_f * @speed.to_f
      @movetimer = rand(70)
    end
  end
  
  def caught
    @hooked = false
    @living = false
    @x = -1000
    @y = -1000
  end
  
  def lost
    @hooked = false
  end
  
  def update_normal
    return if !@living
    if moving?
      if out_of_position?
        do_move_to_level
      else
        do_move
      end
    else
      determine_action
    end
    @movetimer -= 1
  end
  
  def determine_action
    case @move_type
    when 0
      # Idle
      @movetimer = 10
    when 1
      # Passive
      @dir = (rand(3) - 1) * @speed
      @vdir = ((rand(3) - 1).to_f * 0.5) * @speed.to_f
      @movetimer = 100 + rand(100)
    when 2
      # Erratic
      @dir = (rand(3) - 1) * @speed
      @vdir = ((rand(3) - 1).to_f * 0.8) * @speed.to_f
      @movetimer = rand(100)
    end
  end
  
  def do_move
    if @dir > 0
      @x += @dir if @x < right
    elsif @dir < 0
      @x += @dir if @x > left
    end
    if @vdir > 0
      @y += @vdir if @y < @fish_floor
    elsif @vdir < 0
      @y += @vdir if @y > @fish_surface
    end
  end
  
  def do_move_to_level
    @dir = 0
    @vdir = 0
    @y += 1 if @y < @fish_surface
    @y -= 1 if @y > @fish_floor
  end
  
  def out_of_position?
    return true if @y < (@fish_surface - 5)
    return true if @y > (@fish_floor + 5)
    return false
  end
end # Game_Fish


    #--------------------#
#---|   SCENE_GFISHING   |------------------------------------------------------
    #--------------------#

class Scene_GFish < Scene_Base
  attr_accessor :spriteset
  
  def start
    super
    $game_fishing = Game_Fishing.new
    $game_fishing.refresh_fish
    setup_scene
    init_variables
  end
  
  def setup_scene
    create_spriteset
    create_command_window
    create_item_window
    create_hud_window
    create_cast_window
    @command_window.refresh
    RPG::BGM.new($game_system.fishs[0]).play
  end
  
  def init_variables
    $game_fishing.fish_phase = 0
    $game_fishing.reeling = false
    $game_fishing.phase_timer = 0
    # 0 = idle   1 = casting   2 = line in water   3 = fish hooked
  end

#---|   CREATE STUFF   |

  def create_spriteset
    @spriteset = Spriteset_GFishing.new
  end

  def create_command_window
    @command_window = Window_FishCommand.new
    @command_window.set_handler(:cast,       method(:command_cast))
    @command_window.set_handler(:equip_bait, method(:command_equipb))
    @command_window.set_handler(:equip_rod,  method(:command_equipr))
    @command_window.set_handler(:exit,       method(:return_scene))
  end

  def create_item_window
    @item_window = Window_FishItems.new
    @item_window.set_handler(:ok,     method(:on_item_ok))
    @item_window.set_handler(:cancel,    method(:cancel_bait))
    @item_window.hide.deactivate
  end

  def create_hud_window
    @hud_window = Window_FishHud.new
  end

  def create_cast_window
    @cast_window = Window_CastWindow.new
    @cast_window.hide
  end

#---|   WINDOW FUNCTIONALITY   |

  def command_cast
    @command_window.hide.deactivate
    @cast_window.dispose
    create_cast_window
    @cast_window.reset_power
    @cast_window.show
    $game_fishing.casting
  end
  
  def command_equipb; command_equip(:bait); end
  def command_equipr; command_equip(:rod); end
  
  def command_equip(category)
    @item_window.category = category
    @command_window.hide.deactivate
    @item_window.show.activate
    @item_window.select(0)
    @item_window.refresh
  end
  
  def cancel_command
    @command_window.hide.deactivate
  end
  
  def return_scene
    SceneManager.return
    $game_system.replay_bgm
  end

  def on_item_ok
    Sound.play_equip
    case @item_window.category
    when :bait
      $game_player.equipped_bait = @item_window.item
    when :rod
      $game_player.equipped_rod = @item_window.item
    end
    @hud_window.refresh
    @command_window.refresh
    cancel_bait
  end

  def cancel_bait
    @item_window.hide.deactivate
    @command_window.show.activate
  end

#---|   UPDATE STUFF   |

  def update
    super
    @spriteset.update
    $game_timer.update
    $game_fishing.update
  end
  
#---|   FUNCTIONALITY   |

  def casting_set
    @cast_window.set_distance
    @cast_window.hide
    @cast_window.dispose_sprite
    spriteset.rod.cast_line
  end

  def cancel_fishing
    @cast_window.hide
    @cast_window.dispose_sprite
    spriteset.rod.idle
    return return_scene if $game_temp.common_event_id > 0
    @command_window.show.activate
  end
  
  def show_victory
    @cast_window.dispose
    create_cast_window
    @cast_window.show
  end
  
  def refresh_menus
    @hud_window.refresh
    @command_window.refresh
  end

#---|   DISPOSE STUFF   |

  def terminate
    super
    dispose_spriteset
  end
  
  def dispose_spriteset
    @spriteset.dispose
  end 
end # Scene_GFish < Scene_Base


    #------------------------#
#---|   WINDOW_FISHCOMMAND   |--------------------------------------------------
    #------------------------#

class Window_FishCommand < Window_Command
  def initialize
    super(Graphics.width / 2 - window_width / 2,
      Graphics.height / 2 - line_height * 1.5)
  end

  def window_width
    return 160
  end

  def visible_line_number
    item_max
  end

  def make_command_list
    add_command(" Arremessar.",   :cast, cast_possible)
    add_command(" Equipar Isca.",  :equip_bait)
    add_command(" Equipar Vara.",   :equip_rod)
    add_command(" Parar de Pescar.",:exit)
  end
  
  def cast_possible
    $game_player.equipped_bait && $game_player.equipped_rod
  end

  def process_ok
    @@last_command_symbol = current_symbol
    super
  end
end # Window_FishCommand < Window_Command


    #-----------------#
#---|   WINDOW_BAIT   |---------------------------------------------------------
    #-----------------#

class Window_FishItems < Window_ItemList
  attr_reader :category
  
  def initialize
    super(Graphics.width / 4, Graphics.height / 4, Graphics.width / 2,
      Graphics.height / 2)
  end
  
  def col_max
    return 1
  end
  
  def include?(item)
    case @category
    when :bait
      return true if item && item.is_a?(RPG::Item) && item.bait
    when :rod
      return true if item && item.is_a?(RPG::Item) && item.rod
    end
    return false
  end

  def enable?(item)
    return true if item
    return false
  end
end # Window_FishItems < Window_ItemList


    #--------------------#
#---|   WINDOW_FISHHUD   |------------------------------------------------------
    #--------------------#

class Window_FishHud < Window_Base
  def initialize
    super(0, 0, Graphics.width, 80)
    self.opacity = 0
    refresh
  end
  
  def standard_padding
    0
  end
  
  def bait
    $game_player.equipped_bait
  end
  def rod
    $game_player.equipped_rod
  end
  
  def refresh
    if bait && $game_party.item_number(bait) == 0
      $game_player.equipped_bait = nil
    end
    if rod && $game_party.item_number(rod) == 0
      $game_player.equipped_rod = nil
    end
    contents.clear
    draw_bait
    draw_rod
    draw_controls
  end
  
  def draw_controls
    fsize = contents.font.size
    contents.font.size = GFISH::CONTROL_FONT_SIZE
    draw_text(0, 5, contents.width - 7, line_height, GFISH::CONTROLS,2)
    contents.font.size = fsize
  end

  def draw_bait
    if !bait.nil?
      draw_icon(bait.icon_index, 33, 5, true)
      draw_text(26, 28, 40, line_height, $game_party.item_number(bait),1)
    else
      draw_text(26, 15, 40, line_height, "Isca",1)
    end
  end
  def draw_rod
    if !rod.nil?
      draw_icon(rod.icon_index, 93, 15, true)
    else
      draw_text(86, 15, 40, line_height, "Vara",1)
    end
  end

  def open
    refresh
    super
  end
end # Window_FishHud < Window_Base


    #-----------------------#     Used for cast bar and caught fish stats.
#---|   WINDOW_CASTWINDOW   |---------------------------------------------------
    #-----------------------#

class Window_CastWindow < Window_Base
  def initialize
    @line_number = $game_fishing.fish_phase <= 1 ? 1 : 5
    super(Graphics.width / 4, 80, Graphics.width / 2, window_height)
    @power = 0.to_f
    refresh
  end

  def open; refresh; super; end
  def standard_padding; 16; end
  def window_height; fitting_height(@line_number); end
  def update; refresh if self.visible; end
  def fish; $game_fishing.fish_hooked; end
  
  def set_distance
    $game_fishing.bait_x = Graphics.width - 80 - ((Graphics.width - 100) * @power)
  end
  def reset_power
    @power = 0
  end
  
  def refresh
    @img.dispose if @img
    contents.clear
    if $game_fishing.fish_phase == 1
      draw_powbar
    elsif $game_fishing.fish_phase == 5
      draw_fishcaught
    end
  end
  
  def draw_powbar
    @power = 0 if @power > 1
    @power += 0.02
    draw_text(0, 0, 80, line_height, GFISH::POWER,0)
    draw_gauge(80, -5, 190, @power, hp_gauge_color1, hp_gauge_color2)
  end
  
  def draw_fishcaught
    if fish.item <= 0 && fish.ctxt == ""
      draw_generic_text
    elsif fish.ctxt != ""
      draw_custom_text
    else
      item = $data_items[fish.item]
      draw_item_name(item)
    end
    draw_stats
    draw_fish
  end
  
  def draw_fish
    setup_fish
    @img.x = Graphics.width / 4 + 240
    @img.y = 165
  end
  
  def setup_fish
    @img = Sprite.new
    @img.bitmap = Cache.gfish(fish.graphic)
    @cw = @img.bitmap.width / 4
    @ch = @img.bitmap.height
    @img.src_rect.set(@cw, 0, @cw, @ch)
    @img.ox = @cw / 2
    @img.oy = @ch / 2
    @img.z = 999
  end
  
  def draw_generic_text
    draw_text(0, 0, contents.width, line_height, GFISH::CATCH_ITEM_0,1)
  end
  def draw_custom_text
    draw_text(0, 0, contents.width, line_height,fish.ctxt,1)
  end
  
  def draw_item_name(item)
    return unless item
    draw_icon(item.icon_index, 0, 0, true)
    draw_text(30, 0, contents.width, line_height, GFISH::CTEXT_BEFORE + 
      item.name + GFISH::CTEXT_AFTER )
  end
    
  def draw_stats
    change_color(system_color)
    draw_text(0, line_height * 2, contents.width, line_height, "Length",0)
    draw_text(0, line_height * 3, contents.width, line_height, "Weight",0)
    change_color(normal_color)
    draw_text(80, line_height * 2, 60, line_height, fish.length.to_s,0)
    draw_text(80, line_height * 3, 60, line_height, fish.weight.to_s,0)
  end
  
  def dispose_sprite
    @img.dispose if @img
  end
  
  def dispose
    super
  end
end # Window_CastWindow < Window_Base


    #------------------------#
#---|   SPRITESET_GFISHING   |--------------------------------------------------
    #------------------------#

class Spriteset_GFishing
  attr_accessor :rod
  attr_accessor :splash
  attr_accessor :fish_sprites
  
  def initialize
    create_backgrounds
    create_viewports
    create_sprites
    create_weather
    create_timer
    update
  end

  def create_viewports
    @viewport1 = Viewport.new
    @viewport2 = Viewport.new
    @viewport2.rect = Rect.new(0,0,Graphics.width,@over.bitmap.height - 20)
    @viewport3 = Viewport.new
    @brightness = 255
    @viewport1.z = 0
    @viewport2.z = 100
    @viewport3.z = 250
  end

#---|   CREATE GRAPHICS   |

  def create_backgrounds
    create_over
    create_hud_bg
    create_under
    create_flow
  end

  def create_hud_bg
    @hud = Sprite.new(@viewport1)
    @hud.bitmap = Cache.gfish("hud_bg")
  end

  def create_over
    @over = Sprite.new(@viewport1)
    @over.bitmap = Cache.gfish("over" + $game_system.fishb[0].to_s)
    @over.x = Graphics.width - @over.bitmap.width
    @over.z = 0
  end
  def create_under
    @under = Sprite.new(@viewport1)
    @under.bitmap = Cache.gfish("under" + $game_system.fishb[1].to_s)
    @under.wave_amp = 2
    @under.x = Graphics.width - @under.bitmap.width + 65
    @under.y = Graphics.height - @under.bitmap.height
    @under.z = -4
  end
  def create_flow
    @flow = Plane.new(@viewport2)
    @flow.bitmap = Cache.gfish("flow" + $game_system.fishb[2].to_s)
    @flowx = 0.5
    @flow.z = -2
    @flow.opacity = $game_system.fishb[3]
  end
  
  def create_weather
    @weather = Spriteset_FishWeather.new(@viewport2)
  end
  
  def create_timer
    @timer_sprite = Sprite_Timer.new(@viewport2)
  end  
  
  def create_sprites
    @rod = Sprite_Rod.new(@viewport1)
    @fisher = Sprite_Fisher.new(@viewport1)
    @splash = Sprite_Splash.new(@viewport1)
    @fish_sprites = []
    $game_fishing.fish.each do |fish|
      if fish.alive?
        @fish_sprites.push(Sprite_Fish.new(@viewport1,fish))
      end
    end
    @bait = Sprite_Bait.new(@viewport1)
  end
  
#---|   UPDATE STUFF   |
  
  def update
    update_flow
    update_sprites
    update_weather
    update_timer
    update_viewports
    @brightness -= 15 if @brightness > 0
  end
  
  def update_flow
    @flow.ox += @flowx
    @under.update
    @flowx >= 1 ? @flowx = 0.5 : @flowx += 0.5
  end

  def update_sprites
    @fish_sprites.each {|sprite| sprite.update }
    @fisher.update
    @rod.update
    @bait.update
    @splash.update
  end
  
  def update_weather
    @weather.type = $game_map.screen.weather_type
    @weather.power = $game_map.screen.weather_power
    @weather.ox = $game_map.display_x * 32
    @weather.oy = $game_map.display_y * 32
    @weather.update
  end

  def update_timer
    @timer_sprite.update
  end
  
  def update_viewports
    @viewport1.tone.set($game_map.screen.tone)
    @viewport1.ox = $game_map.screen.shake
    @viewport2.color.set($game_map.screen.flash_color)
    @viewport3.color.set(0, 0, 0, @brightness)
    @viewport1.update
    @viewport2.update
    @viewport3.update
  end
  
#---|   DISPOSE GRAPHICS   |

  def dispose
    dispose_backgrounds
    dispose_sprites
    dispose_weather
    dispose_timer
    dispose_viewports
  end
  
  def dispose_backgrounds
    @hud.dispose
    @over.dispose
    @under.dispose
    @flow.dispose
  end

  def dispose_sprites
    @fish_sprites.each {|sprite| sprite.dispose }
    @fisher.dispose
    @rod.dispose
    @bait.dispose
    @splash.dispose
  end

  def dispose_weather
    @weather.dispose
  end

  def dispose_timer
    @timer_sprite.dispose
  end

  def dispose_viewports
    @viewport1.dispose
    @viewport2.dispose
    @viewport3.dispose
  end

  def refresh_sprites
    dispose_sprites
    create_sprites
  end
end # Spriteset_GFishing


    #---------------------------#
#---|   SPRITESET_FISHWEATHER   |-----------------------------------------------
    #---------------------------#

class Spriteset_FishWeather < Spriteset_Weather
  def initialize(viewport = nil)
    super
  end
  def update; super; end
  def update_screen; end
  def dispose; super; end
end # Spriteset_FishWeather < Spriteset_Weather


    #-------------------#
#---|   SPRITE_FISHER   |-------------------------------------------------------
    #-------------------#

class Sprite_Fisher < Sprite_Base
  def initialize(viewport)
    super(viewport)
    @character = $game_player
    setup_character
    update
  end
  
  def dispose
    super
  end

  def update
    super
    update_src_rect
  end

  def setup_character
    self.x = Graphics.width - 40
    self.y = 160
    @character_name = @character.character_name
    @character_index = @character.character_index
    @direction = 4
    set_character_bitmap
  end
  
  def set_character_bitmap
    self.bitmap = Cache.character(@character_name)
    sign = @character_name[/^[\!\$]./]
    if sign && sign.include?('$')
      @cw = bitmap.width / 3
      @ch = bitmap.height / 4
    else
      @cw = bitmap.width / 12
      @ch = bitmap.height / 8
    end
    self.ox = @cw / 2
    self.oy = @ch
  end

  def update_src_rect
    index = @character.character_index
    pattern = $game_fishing.fishing_pattern
    sx = (index % 4 * 3 + pattern) * @cw
    sy = (index / 4 * 4 + (@direction - 2) / 2) * @ch
    self.src_rect.set(sx, sy, @cw, @ch)
  end
end # Sprite_Fisher < Sprite_Base


    #----------------#
#---|   SPRITE_ROD   |----------------------------------------------------------
    #----------------#

class Sprite_Rod < Sprite_Base
  def initialize(viewport)
    super
    @pattern = 0
    @speed_timer = 0
    @action = 0
    setup_rod
    update
  end
  
  def cast_line
    @speed_timer = 0
    @pattern = 0
    @action = 3
  end
  
  def line_in_water
    @action = 2
  end
  
  def idle
    @action = 0
  end
  
  def update_action
    if $game_fishing.reeling
      @action = 1
    elsif $game_fishing.fish_phase == 3 || $game_fishing.fish_phase == 4
      @action = 2
    end
  end
  
  def dispose
    super
  end

  def update
    super
    update_bitmap
    update_anim
    update_src_rect
    update_action
  end
  
  def rod
    $game_player.equipped_rod
  end
  
  def update_bitmap
    if graphic_changed?
      setup_rod
    end
  end

  def graphic_changed?
    rod && @rod_name != rod.rod_img
  end
  
  def setup_rod
    self.x = Graphics.width - 48 + GFISH::ROD_X
    self.y = 195 + GFISH::ROD_Y
    if rod.nil?
      self.bitmap = Cache.gfish("")
      @rod_name = ""
    else
      self.bitmap = Cache.gfish(rod.rod_img)
      @rod_name = rod.rod_img
    end
    @cw = bitmap.width / 4
    @ch = bitmap.height / 4
    self.ox = @cw / 2
    self.oy = @ch
  end

  def update_anim
    @speed_timer += 1
    if @speed_timer > 8
      @pattern += 1
      @speed_timer = 0
    end
  end
  
  def update_src_rect
    if @pattern >= 4
      @pattern = 0
    end
    sx = @pattern * @cw
    sy = @action * @ch
    self.src_rect.set(sx, sy, @cw, @ch)
  end
end # Sprite_Rod < Sprite_Base


    #-----------------#
#---|   SPRITE_BAIT   |---------------------------------------------------------
    #-----------------#

class Sprite_Bait < Sprite_Base
  def initialize(viewport)
    super
    @pattern = 0
    @speed_timer = 0
    self.x = 0
    self.y = -100
    setup_bait
    update
  end
  
  def dispose
    super
  end

  def update
    super
    update_bitmap
    update_anim
    update_src_rect
    update_movement
  end
  
  def bait
    $game_player.equipped_bait
  end
  
  def update_bitmap
    if graphic_changed?
      setup_bait
    end
  end

  def graphic_changed?
    bait && @bait_name != bait.bait_img
  end
  
  def setup_bait
    if bait.nil?
      self.bitmap = Cache.gfish("")
      @bait_name = ""
    else
      self.bitmap = Cache.gfish(bait.bait_img)
      @bait_name = bait.bait_img
    end
    @cw = bitmap.width / 4
    @ch = bitmap.height
    self.ox = @cw / 2
    self.oy = @ch / 2
  end

  def update_anim
    @speed_timer += 1
    if @speed_timer > 8
      @pattern += 1
      @speed_timer = 0
    end
  end
  
  def update_src_rect
    if @pattern >= 4
      @pattern = 0
    end
    sx = @pattern * @cw
    sy = 0 * @ch
    self.src_rect.set(sx, sy, @cw, @ch)
  end
  
  def update_movement
    self.x = $game_fishing.bait_x
    self.y = $game_fishing.bait_y
    self.opacity = $game_fishing.fish_phase == 3 ? 255 : 0
  end
end # Sprite_Bait < Sprite_Base


    #-------------------#
#---|   SPRITE_Splash   |-------------------------------------------------------
    #-------------------#

class Sprite_Splash < Sprite_Base
  def initialize(viewport)
    super
    @pattern = 0
    @speed_timer = 0
    @active = false
    setup_splash
    update
  end
  
  def reset
    self.x = $game_fishing.bait_x
    @pattern = 0
    @speed_timer = 0
    @active = true
  end
  
  def dispose
    super
  end

  def update
    super
    if @active
      update_anim
      update_src_rect
      update_movement
    else
      self.opacity = 0
    end
  end
  
  def setup_splash
    self.bitmap = Cache.gfish("splash")
    @cw = bitmap.width / 4
    @ch = bitmap.height
    self.ox = @cw / 2
    self.oy = @ch
  end

  def update_anim
    @speed_timer += 1
    if @speed_timer > 8
      @pattern += 1
      @speed_timer = 0
    end
  end
  
  def update_src_rect
    if @pattern >= 4
      @active = false
    end
    sx = @pattern * @cw
    sy = 0 * @ch
    self.src_rect.set(sx, sy, @cw, @ch)
  end
  
  def update_movement
    self.y = $game_fishing.surface_y
    self.opacity = 255
  end
end # Sprite_Splash < Sprite_Base


    #-----------------#
#---|   SPRITE_FISH   |---------------------------------------------------------
    #-----------------#

class Sprite_Fish < Sprite_Base
  def initialize(viewport,fish)
    super(viewport)
    @pattern = 0
    @speed_timer = 0
    @fish = fish
    setup_fish
    update
  end
  
  def dispose
    super
  end

  def update
    super
    update_anim
    update_src_rect
    update_movement
  end
  
  def setup_fish
    self.bitmap = Cache.gfish(@fish.graphic)
    @cw = bitmap.width / 4
    @ch = bitmap.height
    self.ox = @cw / 2
    self.oy = @ch / 2
    self.z = @fish.id
  end

  def update_anim
    @speed_timer += 1
    if @speed_timer > 8
      @pattern += 1
      @speed_timer = 0
    end
  end
  
  def update_src_rect
    if @pattern >= 4
      @pattern = 0
    end
    sx = @pattern * @cw
    sy = 0 * @ch
    self.src_rect.set(sx, sy, @cw, @ch)
  end
  
  def update_movement
    self.x = @fish.x
    self.y = @fish.y
    if @fish.dir > 0
      self.mirror = true
    elsif @fish.dir < 0
      self.mirror = false
    end
  end
end # Sprite_Fish < Sprite_Base


    #----------------#
#---|   FISH_STATS   |----------------------------------------------------------
    #----------------#

class Fish_Stats
  attr_accessor :caught   # number of fish caught
  attr_accessor :length   # record length caught
  attr_accessor :weight   # record weight caught
  
  attr_reader :id
  attr_reader :graphic
  attr_reader :speed
  attr_reader :item
  attr_reader :stats
  attr_reader :ctxt
  
  def initialize(fish_id)
    @id = fish_id
    @caught = 0
    @length = 0
    @weight = 0
    @graphic,@speed,@pull,@move_type,@level,@x,@item,@bait_type,@se,@range,
      @cevent,@lengtha,@weighta,@stats,@ctxt = Array.new(GFISH::FISH[@id])
  end
end # Fish_Stats


    #---------------------#
#---|   SCENE_FISHSTATS   |-----------------------------------------------------
    #---------------------#

class Scene_FishStats < Scene_ItemBase
  def start
    super
    create_heading_window
    create_type_window
    create_item_window
    create_footer_left_window
    create_footer_right_window
    create_help_window
  end
  
  def bwidth
    return 544
  end
  
  def bheight
    return 416
  end
  
  def create_heading_window
    wx = (Graphics.width - bwidth) / 2
    wy = (Graphics.height - bheight) / 2
    @header_window = Window_FishInfo.new(wx,wy,bwidth,1,0)
  end
  
  def create_type_window
    wx = @header_window.x
    wy = @header_window.y + @header_window.height
    ww = @header_window.width / 2
    @type_window = Window_FishInfo.new(wx,wy,ww,1,2)
  end

  def create_item_window
    wy = @type_window.y + @type_window.height
    wx = @header_window.x
    ww = @header_window.width / 2
    wh = 296 - @type_window.height
    @item_window = Window_FishList.new(wx, wy, ww, wh)
    @item_window.viewport = @viewport
    @item_window.set_handler(:cancel, method(:return_scene))
    @item_window.activate
    @item_window.select(0)
  end
  
  def create_footer_left_window
    wx = @header_window.x
    wy = @item_window.y + @item_window.height
    ww = bwidth / 2
    @footer_left_window = Window_FishInfo.new(wx,wy,ww,2,1)
  end
  
  def create_footer_right_window
    wx = @footer_left_window.x + @footer_left_window.width
    wy = @item_window.y + @item_window.height
    ww = bwidth / 2
    @footer_right_window = Window_FishInfo.new(wx,wy,ww,2,3)
  end
  
  def create_help_window
    wx = @type_window.x + @item_window.width
    wy = @type_window.y
    ww = @item_window.width
    wh = @item_window.height + @type_window.height
    @help_window = Window_FishHelp.new(wx,wy,ww,wh)
    @item_window.help_window = @help_window
  end
end


    #-----------------#
#---|   WINDOW_INFO   |---------------------------------------------------------
    #-----------------#

class Window_FishInfo < Window_Base
  def initialize(x,y,width,lines,window)
    @window = window
    super(x, y, width, fitting_height(lines))
    calculate_data
    refresh
  end

  def refresh
    contents.clear
    case @window
    when 0  # Heading
      draw_text(0,0,contents.width,line_height, GFISH::STAT_HEADING,1)
    when 1  # Total fish caught
      draw_total_caught
    when 2  # Types of fish
      draw_types
    when 3
      draw_biggest_fish
    end
  end
  
  def draw_total_caught
    change_color(system_color)
    draw_text(0,0,contents.width,line_height, GFISH::TOTAL_FISH,0)
    change_color(normal_color)
    draw_text(0,0,contents.width,line_height,@fish_caught,2)
  end
  
  def draw_types
    change_color(system_color)
    draw_text(0,0,contents.width,line_height, GFISH::FISH_TYPES,0)
    change_color(normal_color)
    draw_text(0,0,contents.width,line_height,@c.to_s + "/" + @t.to_s ,2)
  end
  
  def draw_biggest_fish
    change_color(system_color)
    draw_text(0,0,contents.width,line_height, GFISH::RECORD_FISH,0)
    change_color(normal_color)
    draw_fish_name(@longest_fish)
  end
  
  def calculate_data
    @fish_caught = 0
    length_check = 0
    @c = 0
    @t = 0
    @longest_fish = nil
    $game_system.fish.each { |fish|
      next if !fish.stats
      @fish_caught += fish.caught
      if length_check < fish.length
        length_check = fish.length
        @longest_fish = fish.id
      end
      @c += 1 if fish.caught > 0
      @t += 1
    }
  end
  
  def draw_fish_name(id)
    return if id.nil?
    fish = $game_system.fish[id]
    if fish.ctxt == ""
      item = $data_items[fish.item]
      draw_item_name(item, 0, line_height, true, contents.width)
    else
      draw_ctxt(fish, 0, line_height)
    end
  end
  
  def draw_ctxt(item, x, y)
    return unless item
    change_color(normal_color)
    draw_text(x, y, contents.width, line_height, item.ctxt)
  end

  def open
    refresh
    super
  end
end


    #---------------------#
#---|   WINDOW_FISHHELP   |-----------------------------------------------------
    #---------------------#

class Window_FishHelp < Window_Base
  def initialize(x,y,width,height)
    super(x,y,width,height)
    @pattern = 0
    @speed_timer = 0
  end

  def set_item(fish)
    @fish = fish
    refresh
  end
  
  def draw_fish_details
    return if @fish.nil?
    draw_fish_name
    draw_fish_stats
    draw_fish
  end

  def draw_fish_name
    if @fish.ctxt == ""
      item = $data_items[@fish.item]
      draw_item_name(item, 0, 0, true, contents.width)
    else
      draw_ctxt(@fish, 0, 0)
    end
  end
  
  def draw_fish_stats
    change_color(system_color)
    draw_text(0,line_height * 8,contents.width,line_height,GFISH::FISH_CAUGHT,0)
    draw_text(0,line_height * 9,contents.width,line_height,GFISH::FISH_LENGTH,0)
    draw_text(0,line_height * 10,contents.width,line_height,GFISH::FISH_WEIGHT,0)
    change_color(normal_color)
    draw_text(0,line_height * 8,contents.width,line_height,@fish.caught,2)
    draw_text(0,line_height * 9,contents.width,line_height,@fish.length,2)
    draw_text(0,line_height * 10,contents.width,line_height,@fish.weight,2)
  end
  
  def draw_fish
    @img.dispose if @img
    setup_fish
    @img.x = self.x + self.width / 2
    @img.y = self.y + 120
  end
  
  def setup_fish
    @img = Sprite.new
    @img.bitmap = Cache.gfish(@fish.graphic)
    @cw = @img.bitmap.width / 4
    @ch = @img.bitmap.height
    @img.src_rect.set(@cw, 0, @cw, @ch)
    @img.ox = @cw / 2
    @img.oy = @ch / 2
    @img.z = 999
  end
  
  def draw_ctxt(item, x, y)
    return unless item
    change_color(normal_color)
    draw_text(x, y, contents.width, line_height, item.ctxt)
  end
  
  def refresh
    contents.clear
    draw_fish_details
  end
  
  def update_anim
    @speed_timer += 1
    if @speed_timer > 8
      @pattern += 1
      @speed_timer = 0
    end
  end
  
  def update_src_rect
    if @pattern >= 4
      @pattern = 0
    end
    sx = @pattern * @cw
    sy = 0 * @ch
    @img.src_rect.set(sx, sy, @cw, @ch)
  end
  
  def update
    super
    if @img
      update_anim
      update_src_rect
    end
  end
  
  def dispose
    super
    @img.dispose if @img
  end
end


    #--------------------#
#---|   WINDOW_FISHLIST  |------------------------------------------------------
    #--------------------#

class Window_FishList < Window_Selectable
  def initialize(x, y, width, height)
    super
    @data = []
    refresh
  end

  def col_max; return 1; end
  def item_max; @data ? @data.size : 1; end
  def item; @data && index >= 0 ? @data[index] : nil; end
  def current_item_enabled?; false; end
  def enable?(item); true; end

  def include?(item)
    return false if item.nil?
    return false if item.item == 0 && item.ctxt == ""
    return false if !item.stats
    return false if item.caught <= 0
    return true
  end

  def make_item_list
    @data = $game_system.fish.select {|item| include?(item) }
    @data.push(nil) if include?(nil)
  end
  
  def select_last
    select(@data.index($game_party.last_item.object) || 0)
  end
  
  def draw_item(index)
    fish = @data[index]
    rect = item_rect(index)
    rect.width -= 4
    if fish.ctxt == ""
      item = $data_items[fish.item]
      draw_item_name(item, rect.x, rect.y, true, contents.width)
    else
      draw_ctxt(fish, rect.x, rect.y)
    end
  end
  
  def draw_ctxt(item, x, y)
    return unless item
    change_color(normal_color)
    draw_text(x, y, contents.width, line_height, item.ctxt)
  end

  def update_help
    @help_window.set_item(item)
  end

  def refresh
    make_item_list
    create_contents
    draw_all_items
  end
end
