pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
-- types
function mag(_p) 
   return sqrt(_p.x*_p.x + _p.y*_p.y)
end

function is_rect_point_coll(_rect, _point)
   local pa,pb = _rect.pa, _rect.pb
   
   left_x = pa.x < pb.x and pa.x or pb.x
   right_x = left_x == pa and pb.x or pa.x
   top_y = pa.y < pb.y and pa.y or pb.y
   bottom_y = top_y == pa and pb.y or pa.y
   
   return _point.p.x >= left_x and
      _point.p.y >= top_y and
      _point.p.x <= right_x and
      _point.p.y <= bottom_y 
end

-- game init

-- custom input system
poke(0x5f2d, 1)

inputs = {}

function register_input(_is_input_down_func)
   local o = {}
   o.update = function ()
      o.f = _is_input_down_func() and o.f + 1 or 0
   end
   o.f = 0
   add(inputs, o)
end

for i=0, 5 do
   register_input(function() return btn(i) end) 
end
register_input(function() return stat(34) & 1 == 1 end) 
register_input(function() return stat(34) & 2 == 2 end)

function btnf(_b)
   --[[
      0 : left
      1 : right
      2 : up
      3 : down
      4 : z
      5 : x
      6 : mouse_left
      7 : mouse_right
   --]]
   
   return inputs[_b].f
end

-- game objects
function gobj(_state, _update, _draw, _init, _destroy)
   return {
      update=_update,
      draw=_draw,
      state=_state,
      init=_init,
      destroy=_destroy
   }
end

cursor = gobj(
   {p={x=0, y=0},
    dragbox = {
       pa = nil,
       pb = nil,
       selected = {},  
    }
   },
   function (_state)
      _state.p.x, _state.p.y = stat(32),stat(33)
      local dragbox = _state.dragbox

      -- dragbox initialize
      if btnf(7) == 1 then	 
	 dragbox.pa = {x=_state.p.x, y=_state.p.y}
	 dragbox.pb = {x=_state.p.x, y=_state.p.y}
	 dragbox.selected = {}
      end

      -- dragbox continue
      if btnf(7) > 1 then
	 dragbox.pb = {x=_state.p.x, y=_state.p.y}
      end
      
      -- select what's in dragbox
      if btnf(7) > 0 then
	 dragbox.selected = {}
	 for friendly in all(friendlys) do
	    if is_rect_point_coll(dragbox, friendly) then
	       add(dragbox.selected, friendly)
	    end
	 end
      end
   end,
   
   function (_state)
      local dragbox = _state.dragbox
      if btnf(7) > 0 then
	 rect(dragbox.pa.x, dragbox.pa.y,
	      dragbox.pb.x, dragbox.pb.y,
	      11)
      end
      
      pset(_state.p.x, _state.p.y, magic.state == "target" and 13 or btnf(6) > 0 and 11 or 3)
      if magic.state == "target" then
	 circ(_state.p.x, _state.p.y,
	      5-((f%30)/30)*5, 13)
      end
      
      for selected in all(_state.dragbox.selected) do
	 circ(selected.p.x, selected.p.y, 3, 11)
      end
   end
)

gobjs = {cursor}

-- cursor 

wizard = {p = {x=63, y=63}, 
          r=2,
          c=13,
          h=1,
          mh=1,
          t="wizard",
          mana=3,
          manaf=0}

knight = {p = {x=40, y=40},
          r=2,
          c=5,
          h=4,
          mh=4,
          t="knight"}

friendlys = {wizard, knight}
wizards = {wizard}

dummy = {p = {x=90, y=30},
         c = 4,
         r = 2,
         h = 3,
         mh = 3,
         t = "dummy"}
enemies = {dummy}

units = {wizard,knight,dummy}

-- nil, cursor, running
magic = {}
magic.state = nil
magic.r = 5
magic.p = nil
magic.f = nil

f = 0

function _update60()
   -- input initialize per frame
   for input in all(inputs) do
      input.update()
   end

   for gobj in all(gobjs) do
      gobj.update(gobj.state)
   end

   -- cursor initialize

   
 
   


   -- -- begin move action
   -- if btnf(8) == 1 then
   --    avg = {x=0, y=0}
      
   --    for friendly in all(dragbox.selected) do
   -- 	 avg.x += friendly.p.x
   -- 	 avg.y += friendly.p.y     
   --    end

   --    avg.x = avg.x/#dragbox.selected
   --    avg.y = avg.y/#dragbox.selected
      
   --    for friendly in all(dragbox.selected) do
   -- 	 friendly.offset 
   -- 	    = point(avg.x-friendly.p.x,
   -- 		    avg.y-friendly.p.y)
   --    end
   --    local move_action = {}      
   --    move_action.p = 
   -- 	 point(cursor.p.x,
   -- 	       cursor.p.y)
   --    move_action.selected = dragbox.selected
   --    add(move_actions, move_action)
   -- end

   -- for move_action in all(move_actions) do
   --    if move_action.p then
   -- 	 all_moved = true
   -- 	 for friendly in 
   -- 	    all(move_action.selected) do
   -- 	    delta 
   -- 	       = point(
   -- 		  move_action.p.x
   -- 		  -friendly.p.x-friendly.offset.x,
   -- 		  move_action.p.y
   -- 		  -friendly.p.y-friendly.offset.y)

   -- 	    local a = atan2(delta.x, delta.y)
   -- 	    if not (
   -- 	       abs(move_action.p.x
   -- 		   -friendly.offset.x
   -- 		   -friendly.p.x) < 1 
   -- 	       and
   -- 	       abs(move_action.p.y
   -- 		   -friendly.offset.y
   -- 		   -friendly.p.y) < 1) 
   -- 	    then
   -- 	       all_moved = false
   -- 	       -- if coll move around
   -- 	       local displace = 
   -- 		  point(friendly.p.x + cos(a),
   -- 			friendly.p.y + sin(a))
	       
   -- 	       for o_friendly in all(friendlys) do
   -- 		  local diff = 
   -- 		     point(o_friendly.p.x - friendly.p.x,
   -- 			   o_friendly.p.y - friendly.p.y)
   -- 		  if mag(diff)	<= 3 then
		     
   -- 		  else
   -- 		  end						                   
   -- 	       end
	       
   -- 	       all_moved = false
   -- 	       friendly.p.x = displace.x
   -- 	       friendly.p.y = displace.y
   -- 	    end     
   -- 	 end
   -- 	 if all_moved then
   -- 	    move_action.p = nil
   -- 	    move_action.selected = {}     
   -- 	 end
   --    end
   -- end
   -- -- end move action
   
   -- -- selected loop
   -- for selected 
   --    in all(dragbox.selected) do
   --    if selected.t == "wizard" then
   -- 	 if magic.state == nil     
   -- 	    and btnp(4) then
   -- 	    magic.state = "target"
   -- 	 end
	 
   -- 	 if magic.state == "target" 
   -- 	    and not btn(4) then
   -- 	    magic.state = "active"
   -- 	    magic.p = {x=cursor.p.x, y= cursor.p.y}
   -- 	    magic.f = 0
   -- 	 end
   --    end	
   -- end
   
   if magic.state == "active" then
      if magic.f > 40 then
	 magic.state = nil
      end
      for unit in all(units) do
	 if mag(point(unit.p.x-magic.p.x,
		      unit.p.y-magic.p.y)) 
	    <= (unit.r + magic.r) then
	    if magic.f % 10 then
	       unit.h -= 1
	    end
	 end
      end   
      magic.f += 1
   end
   
   for wizard in all(wizards) do
      wizard.manaf += 1
      if wizard.manaf % 30 then
	 wizard.mana = 
	    min(wizard.mana+1,3)
      end	
   end
   
   f += 1
end

function _draw()
   cls()

   for gobj in all(gobjs) do
      gobj.draw(gobj.state)
   end
   
   for unit in all(units) do
      circfill(unit.p.x, unit.p.y, 2, unit.c)
   end     
   
   
   -- draw health bar
   for unit in all(units) do

      offset = (unit.mh-1)/2
      rectfill(unit.p.x - offset, 
	       unit.p.y - 4,
	       unit.p.x - offset + unit.mh-1,
	       unit.p.y - 4,
	       2)		 
      if unit.h > 0 then			         
	 rectfill(unit.p.x - offset, 
		  unit.p.y - 4,
		  unit.p.x - offset + (unit.h-1),
		  unit.p.y - 4,
		  8)
      end
      
      offset = (unit.mh-1)/2
      rectfill(unit.p.x - offset, 
	       unit.p.y - 4,
	       unit.p.x - offset + unit.mh-1,
	       unit.p.y - 4,
	       2)		 
      if unit.h > 0 then			         
	 rectfill(unit.p.x - offset, 
		  unit.p.y - 4,
		  unit.p.x - offset + (unit.h-1),
		  unit.p.y - 4,
		  8)
      end
   end   
   
   if magic.state == "active" then
      circfill(magic.p.x, magic.p.y,
	       magic.r, 13)
   end
end
__gfx__
0c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
d0000c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000d0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000d0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0d000c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
