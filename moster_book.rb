monster_book
By Bento
==============================================================================
# Sistema que permite verificar os parâmetros dos inimigos derrotados,
# o que inclui o battleback e a música de batalha. 
# 
#==============================================================================
# Para chamar o script use o comando abaixo.
#
# monster_book
#
#==============================================================================
module MOG_MONSTER_BOOK
   #Ocultar inimigos especificos da lista de inimigos. 
   HIDE_ENEMIES_ID = []
   #Ativar a música de batalha.
   PLAY_MUSIC = true
   #Definição da palavra Completado.
   COMPLETED_WORD =  "Completado"
   #Ativar o Monster Book no Menu.
   MENU_COMMAND = true
   #Nome do comando apresentado no menu.
   MENU_COMMAND_NAME = "Bestiário"
   #Definição da opacidade da janela
   WINDOW_OPACITY = 255
end

$imported = {} if $imported.nil?
$imported[:mog_monster_book] = true

#==============================================================================
# ■ Game_System
#==============================================================================
class Game_System
  
  attr_accessor :bestiary_defeated
  attr_accessor :bestiary_battleback
  attr_accessor :bestiary_music
  
  #--------------------------------------------------------------------------
  # ● Initialize
  #--------------------------------------------------------------------------    
  alias mog_monster_book_initialize initialize
  def initialize
      @bestiary_defeated = []; @bestiary_battleback = []; @bestiary_music = []
      mog_monster_book_initialize 
  end
  
end  

#==============================================================================
# ■ Game Interpreter
#==============================================================================
class Game_Interpreter
  
 #--------------------------------------------------------------------------
 # ● Monster Book
 #--------------------------------------------------------------------------                          
 def monster_book
     SceneManager.call(Monster_Book)
 end
  
end

#==============================================================================
# ■ Spriteset_Battle
#==============================================================================
class Spriteset_Battle
  #--------------------------------------------------------------------------
  # ● Initialize
  #--------------------------------------------------------------------------
  alias mog_bestiary_initialize initialize
  def initialize
      mog_bestiary_initialize
      $game_system.bestiary_battleback[0] = [battleback1_name,battleback2_name]
  end
  
end

#==============================================================================
# ■ Game_Enemy
#==============================================================================
class Game_Enemy < Game_Battler
  attr_accessor :enemy_id
  
  #--------------------------------------------------------------------------
  # ● Die
  #--------------------------------------------------------------------------
  alias mog_monster_book_die die
  def die
      mog_monster_book_die
      check_monster_book if !MOG_MONSTER_BOOK::HIDE_ENEMIES_ID.include?(@enemy_id)
  end
    
  #--------------------------------------------------------------------------
  # ● Check Monster Book
  #--------------------------------------------------------------------------  
  def check_monster_book
      if $game_system.bestiary_defeated[@enemy_id] == nil
         $game_system.bestiary_defeated[@enemy_id] = 0
         $game_system.bestiary_battleback[@enemy_id] = $game_system.bestiary_battleback[0]
         $game_system.bestiary_music[@enemy_id] = $game_system.battle_bgm
      end   
      $game_system.bestiary_defeated[@enemy_id] += 1
  end  
end  

#==============================================================================
# ■ Window_Monster_Status
#==============================================================================

class Window_Monster_Status < Window_Selectable
  #--------------------------------------------------------------------------
  # ● Initialize
  #--------------------------------------------------------------------------
  def initialize(enemy)
      super(0, Graphics.height - 128, Graphics.width, 128)
      self.opacity = MOG_MONSTER_BOOK::WINDOW_OPACITY
      self.z = 300; refresh(enemy) ;  activate
  end

  #--------------------------------------------------------------------------
  # ● Refresh
  #--------------------------------------------------------------------------  
  def refresh(enemy)
      self.contents.clear
      if $game_system.bestiary_defeated[enemy.id] == nil
         self.contents.draw_text(0,0 , 180, 24, "Vazio",0)    
       else
         change_color(system_color)
         w_max = 50
         ex = 16
         self.contents.draw_text(0,0 , w_max, 24, Vocab::param(0),0)    
         self.contents.draw_text(0,24 * 1 , w_max, 24, Vocab::param(1),0)
         self.contents.draw_text(0,24 * 2 , w_max, 24, Vocab::param(2),0)
         self.contents.draw_text(0,24 * 3 , w_max, 24, Vocab::param(3),0)
         self.contents.draw_text(128,24 * 0 , w_max, 24, Vocab::param(4),0)
         self.contents.draw_text(128,24 * 1 , w_max, 24, Vocab::param(5),0)
         self.contents.draw_text(128,24 * 2 , w_max, 24, Vocab::param(6),0)         
         self.contents.draw_text(128,24 * 3 , w_max, 24, Vocab::param(7),0)         
         self.contents.draw_text(256,24 * 0 , w_max, 24, "Exp:",0)
         self.contents.draw_text(384,24 * 0 , w_max, 24, Vocab::currency_unit,0)
         self.contents.draw_text(256,24 * 1 , w_max, 24, "Tesouros",0)         
         change_color(normal_color,true)
         w_max2 = 64         
         #HP
         self.contents.draw_text(32 + ex,0 , w_max2, 24, enemy.params[0],2)
         #MP
         self.contents.draw_text(32 + ex,24 * 1 , w_max2, 24, enemy.params[1],2)
         #ATK
         self.contents.draw_text(32 + ex,24 * 2 ,w_max2 , 24, enemy.params[2],2)         
         #Def
         self.contents.draw_text(32 + ex,24 * 3 , w_max2, 24, enemy.params[3],2)         
         #Mag Power
         self.contents.draw_text(160 + ex,24 * 0 , w_max2, 24, enemy.params[4],2)
         #Mag Def
         self.contents.draw_text(160 + ex,24 * 1 , w_max2, 24, enemy.params[5],2)  
         #Agility
         self.contents.draw_text(160 + ex,24 * 2 , w_max2, 24, enemy.params[6],2)
         #Luck
         self.contents.draw_text(160 + ex,24 * 3 , w_max2, 24, enemy.params[7],2)
         #EXP
         self.contents.draw_text(280,24 * 0 , 96, 24, enemy.exp,2)
         #Gold
         self.contents.draw_text(400,24 * 0 , 96, 24, enemy.gold,2)
         #Drop Items
         tr = 0
         for i in enemy.drop_items
            next if i.kind == 0
            tr += 1 
            tr_name = $data_items[i.data_id] if i.kind == 1
            tr_name = $data_weapons[i.data_id] if i.kind == 2
            tr_name = $data_armors [i.data_id] if i.kind == 3
            draw_icon(tr_name.icon_index, 336, 24 * tr)
            self.contents.draw_text(368,24 * tr , 160, 24, tr_name.name.to_s,0)
         end       
      end
  end
end

#==============================================================================
# ■ Window_Monster_List
#==============================================================================
class Window_Monster_List < Window_Selectable
  include MOG_MONSTER_BOOK
 #------------------------------------------------------------------------------
 # ● Initialize
 #------------------------------------------------------------------------------   
  def initialize(data)
      super(Graphics.width - 232, 64, 232, Graphics.height - 192)
      self.opacity = WINDOW_OPACITY
      self.z = 301;  @index = -1;  @data = data; @data_max = 0
      @item_max = @data.size;  refresh(data);  select(0) ; activate
  end

 #------------------------------------------------------------------------------
 # ● Refresh
 #------------------------------------------------------------------------------   
  def refresh(data)
      self.contents.clear
      return if @item_max < 1
      self.contents = Bitmap.new(width - 32, @item_max * 24)
      @item_max.times do |i| draw_item(i) end
  end
  
 #------------------------------------------------------------------------------
 # ● draw_item MAX
 #------------------------------------------------------------------------------     
 def check_item_max
     $data_enemies.compact.each {|i| @data_max += 1 if !HIDE_ENEMIES_ID.include?(i.id)}
 end
      
 #------------------------------------------------------------------------------
 # ● draw_item
 #------------------------------------------------------------------------------   
  def draw_item(index)
      x = 0
      y = index / col_max  * 24
      n_index = index + 1
      if $game_system.bestiary_defeated[@data[index].id] == nil
         monster_name = "Vazio"
         defeated = " ---- "
         change_color(normal_color,false)
      else  
        monster_name = @data[index].name
        change_color(normal_color,true)
      end
      check_item_max
      d = @data_max > 99 ? "%03d" : @data_max > 9 ? "%02d" : "%01d"  
      text = sprintf(d, n_index).to_s  + " - "
      self.contents.draw_text(x,y , 56, 24, text,0) 
      self.contents.draw_text(x + 56,y , 140, 24, monster_name,0) 
  end

 #------------------------------------------------------------------------------
 # ● Item Max
 #------------------------------------------------------------------------------         
  def item_max
      return @item_max == nil ? 0 : @item_max 
  end  
  
end

#==============================================================================
# ■ Window_Monster_Comp
#==============================================================================
class Window_Monster_Comp < Window_Selectable
  include  MOG_MONSTER_BOOK
  
  #--------------------------------------------------------------------------
  # ● Initialize
  #--------------------------------------------------------------------------
  def initialize
      super(Graphics.width - 232 ,0, 232, 64)
      self.opacity = MOG_MONSTER_BOOK::WINDOW_OPACITY
      self.z = 300; @data_max = 0; refresh; activate
  end
  
  #--------------------------------------------------------------------------
  # ● Check Completition
  #--------------------------------------------------------------------------  
  def check_completion
      $data_enemies.compact.each {|i| @data_max += 1 if !HIDE_ENEMIES_ID.include?(i.id)}
      comp = $game_system.bestiary_defeated.compact.size
      @completed = COMPLETED_WORD + " " + comp.to_s + "/" + @data_max.to_s
  end
  
  #--------------------------------------------------------------------------
  # ● Refresh
  #--------------------------------------------------------------------------  
  def refresh
      self.contents.clear  ; check_completion
      self.contents.draw_text(0,0, 160, 24, @completed.to_s,0)
  end
end

#==============================================================================
# ■ Monster_Book
#==============================================================================
class Monster_Book
  include MOG_MONSTER_BOOK
 #--------------------------------------------------------------------------
 # ● Main
 #--------------------------------------------------------------------------          
 def main
     execute_setup
     Graphics.transition(10)
     execute_loop
     execute_dispose
 end   

 #--------------------------------------------------------------------------
 # ● Execute Loop
 #--------------------------------------------------------------------------           
 def execute_loop
     loop do
        Graphics.update ; Input.update ; update
        break if SceneManager.scene != self
     end
 end   
 
 #--------------------------------------------------------------------------
 # ● Execute
 #--------------------------------------------------------------------------          
 def execute_setup
     load_data ; execute_dispose ; create_background ; create_window_guide
     create_enemy_sprite ; create_battleback ; @music = [nil,nil,nil]
     refresh_bgm
 end   
 
 #------------------------------------------------------------------------------
 # ● Initialize
 #------------------------------------------------------------------------------     
 def load_data
     BattleManager.save_bgm_and_bgs ; @data = []
     $data_enemies.compact.each {|i| @data.push(i) if !HIDE_ENEMIES_ID.include?(i.id)}
 end
 
 #--------------------------------------------------------------------------
 # ● Execute Dispose
 #--------------------------------------------------------------------------           
 def execute_dispose
     return if @windows_guide == nil
     Graphics.freeze ; @windows_guide.dispose ; @windows_guide = nil
     @windows_status.dispose
     @enemy_sprite.bitmap.dispose if !@enemy_sprite.bitmap.nil?
     @enemy_sprite.dispose ; dispose_battleback    
     @background.bitmap.dispose ; @background.dispose
     @battleback1.dispose ; @battleback2.dispose
     @window_comp.dispose ; BattleManager.replay_bgm_and_bgs
 end
 
 #--------------------------------------------------------------------------
 # ● Dispose_battleback 
 #--------------------------------------------------------------------------             
 def dispose_battleback 
     if @battleback1.bitmap != nil
        @battleback1.bitmap.dispose ; @battleback1.bitmap = nil
     end
     if @battleback2.bitmap != nil
        @battleback2.bitmap.dispose ; @battleback2.bitmap = nil
     end   
 end
      
 #--------------------------------------------------------------------------
 # ● Create Background
 #--------------------------------------------------------------------------             
 def create_background
     @background = Sprite.new
     @background.bitmap = Cache.system("MB_Background")
     @background.z = -1
 end
 
 #--------------------------------------------------------------------------
 # ● Create Window Guide
 #--------------------------------------------------------------------------            
 def create_window_guide
     @windows_guide = Window_Monster_List.new(@data)
     @enemy = @data[@windows_guide.index]
     @windows_status = Window_Monster_Status.new(@enemy)
     @window_comp = Window_Monster_Comp.new
     @old_index = @windows_guide.index
     @org_pos = [@windows_guide.x,@windows_guide.y]
     @fade_time = 60
 end
   
 #--------------------------------------------------------------------------
 # ● Create Enemy Sprite
 #--------------------------------------------------------------------------             
 def create_enemy_sprite
     @enemy_sprite = Sprite.new ; @enemy_sprite.z = 100
     @enemy_sprite_org =  @enemy_sprite.x ; refresh_enemy_sprite
 end
 
 #--------------------------------------------------------------------------
 # ● Create_Battleback
 #--------------------------------------------------------------------------             
 def create_battleback
     @battleback1 = Sprite.new ; @battleback1.z = 1 ; @battleback1.opacity = 0
     @battleback2 = Sprite.new ; @battleback2.z = 2 ; @battleback2.opacity = 0
     @old_battleback = [nil,nil] ; refresh_batteback
 end
 
 #--------------------------------------------------------------------------
 # ● Update
 #--------------------------------------------------------------------------            
 def update
     @windows_guide.update ; update_command ; update_animation
     refresh if @old_index != @windows_guide.index
 end
 
 #--------------------------------------------------------------------------
 # ● Update Animation
 #--------------------------------------------------------------------------             
 def update_animation
     update_battleback_animation ; update_enemy_sprite_animation
 end  
 
 #--------------------------------------------------------------------------
 # ● Update Enemy Sprite Animation
 #--------------------------------------------------------------------------              
 def update_enemy_sprite_animation
     @enemy_sprite.opacity += 15
     return if  @enemy_sprite.x == @enemy_sprite_org
     @enemy_sprite.x += 15 
     @enemy_sprite.x = @enemy_sprite_org if @enemy_sprite.x >= @enemy_sprite_org 
 end

 #--------------------------------------------------------------------------
 # ● Update Battleback Animation
 #--------------------------------------------------------------------------              
 def update_battleback_animation
     if @old_battleback == nil
        @battleback1.opacity -= 10        
     else
        @battleback1.opacity += 10
     end  
     @battleback2.opacity = @battleback1.opacity
 end
    
 #--------------------------------------------------------------------------
 # ● Update Command
 #--------------------------------------------------------------------------             
 def update_command
     if Input.trigger?(Input::B)
        Sound.play_cancel ; SceneManager.return
     elsif Input.trigger?(Input::C)
        Sound.play_ok   
     end   
 end
 
 #--------------------------------------------------------------------------
 # ● Refresh Animation
 #--------------------------------------------------------------------------              
 def refresh
     @old_index = @windows_guide.index ; @enemy = @data[@windows_guide.index]
     @windows_status.refresh(@enemy)
     refresh_bgm ; refresh_enemy_sprite ; refresh_batteback
 end
   
 #--------------------------------------------------------------------------
 # ● Refresh Animation
 #--------------------------------------------------------------------------               
 def refresh_enemy_sprite
     if @enemy_sprite.bitmap != nil 
        @enemy_sprite.bitmap.dispose ; @enemy_sprite.bitmap = nil
     end
     if $game_system.bestiary_defeated[@enemy.id] != nil 
        @enemy_sprite.bitmap = Cache.battler(@enemy.battler_name, @enemy.battler_hue)         
        sx = [Graphics.width - 232,Graphics.width / 2]
        @enemy_sprite_org =  (sx[0] / 2) - (@enemy_sprite.bitmap.width / 2)
        @enemy_sprite.x = -@enemy_sprite.bitmap.width
        @enemy_sprite.y = sx[1] - @enemy_sprite.bitmap.height
        @enemy_sprite.opacity = 0
     end
 end  

 #--------------------------------------------------------------------------
 # ● BGM Refresh
 #--------------------------------------------------------------------------                
 def refresh_bgm
     return unless MOG_MONSTER_BOOK::PLAY_MUSIC
     if $game_system.bestiary_music[@enemy.id] != nil and 
        (@music[0] != $game_system.bestiary_music[@enemy.id].name or
         @music[1] != $game_system.bestiary_music[@enemy.id].volume or
         @music[2] != $game_system.bestiary_music[@enemy.id].pitch)
         m = $game_system.bestiary_music[@enemy.id]
         @music = [m.name, m.volume, m.pitch] ; RPG::BGM.stop
         Audio.bgm_play("Audio/BGM/" +  m.name, m.volume, m.pitch) rescue nil
     end  
 end
 
 #--------------------------------------------------------------------------
 # ● Refresh Battleback
 #--------------------------------------------------------------------------                
 def refresh_batteback    
     if $game_system.bestiary_battleback[@enemy.id] != nil and 
        (@old_battleback[0] != $game_system.bestiary_battleback[@enemy.id][0] or
         @old_battleback[1] != $game_system.bestiary_battleback[@enemy.id][1])
         @old_battleback = [$game_system.bestiary_battleback[@enemy.id][0], $game_system.bestiary_battleback[@enemy.id][1]]
         dispose_battleback ; @battleback1.opacity = 0 ; @battleback2.opacity = 0 
        if $game_system.bestiary_battleback[@enemy.id][0] != nil
           @battleback1.bitmap = Cache.battleback1($game_system.bestiary_battleback[@enemy.id][0])
        else
           @battleback1.bitmap = Cache.battleback1("")
        end
        if $game_system.bestiary_battleback[@enemy.id][1] != nil
           @battleback2.bitmap = Cache.battleback2($game_system.bestiary_battleback[@enemy.id][1])
        else
           @battleback2.bitmap = Cache.battleback2("")
        end           
     end  
 end
 
end

if MOG_MONSTER_BOOK::MENU_COMMAND
#==============================================================================
# ■ Window Menu Command
#==============================================================================
class Window_MenuCommand < Window_Command  
  
 #------------------------------------------------------------------------------
 # ● Add Main Commands
 #------------------------------------------------------------------------------     
  alias mog_bestiary_add_main_commands add_main_commands
  def add_main_commands
      mog_bestiary_add_main_commands
      add_command(MOG_MONSTER_BOOK::MENU_COMMAND_NAME, :bestiary, main_commands_enabled)
  end
end   

#==============================================================================
# ■ Scene Menu
#==============================================================================
class Scene_Menu < Scene_MenuBase
  
 #------------------------------------------------------------------------------
 # ● Create Command Windows
 #------------------------------------------------------------------------------       
   alias mog_bestiary_create_command_window create_command_window
   def create_command_window
       mog_bestiary_create_command_window
       @command_window.set_handler(:bestiary,     method(:Monster_Book))
   end
   
 #------------------------------------------------------------------------------
 # ● Monster Book
 #------------------------------------------------------------------------------        
   def Monster_Book
       SceneManager.call(Monster_Book)
   end
 
end   
 
end
