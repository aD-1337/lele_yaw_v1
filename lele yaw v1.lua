--[[
    MIT License
-- file:         mm aa lua
-- desc:         anti brutefoce,logic,legit anti aim etc...
-- author:       FiveFive#1337
-- version:      2
-- last update:  10.3.2021

    Copyright (c) Essential™ 2021
    Permission is hereby granted, paid and private, to any person obtaining a copy
    of this software and associated documentation files (the 'Software'), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy,leak, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:
    The above copyright notice and this permission notice shall be included in all
    copies or substantial portions of the Software.
    THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
    SOFTWARE.

    版權（c）唐乐™ 2021
    特此授予獲得副本的任何人許可，付費和私人許可
    軟件和相關文檔文件（以下簡稱“軟件”）的交易
    在軟件中不受限制，包括但不限於權利
    使用，複製，洩漏，修改，合併，發布，分發，再許可和/或出售
    本軟件的副本，並允許本軟件所針對的人
    未经本人同意泄露或者破解会采取相关版权法律行动
    具備以下條件：
    上述版權聲明和此許可聲明應包含在所有
    複製本軟件或本軟件的實質部分。
    本軟件按“原樣”提供，不提供任何形式的明示或明示保證。
    暗示（包括但不限於適銷性的保證），
    適用於特定目的和非侵權。在任何情況下都不會
    作者或版權持有人對任何索賠，損害或其他責任
    無論是由於合同，侵權或其他原因而引起的責任，
    與軟件或軟件的使用或其他交易無關或與之有關
    軟件。

    此版本于 8.7.2021 发布
    
]]--


local xyz1,xyz2 = client.screen_size()
-- localize vars
local me = entity.get_local_player( )
local math_pi   = math.pi;
local math_min  = math.min;
local math_max  = math.max;
local math_deg  = math.deg;
local math_rad  = math.rad;
local math_sqrt = math.sqrt;
local math_sin  = math.sin;
local math_cos  = math.cos;
local math_atan = math.atan;
local math_acos = math.acos;
local math_fmod = math.fmod;
-- set up vector3 metatable
local _V3_MT   = {};
_V3_MT.__index = _V3_MT;
--
-- create Vector3 object
--
local function Vector3( x, y, z )
    -- check args
    if( type( x ) ~= "number" ) then
        x = 0.0;
    end
    if( type( y ) ~= "number" ) then
        y = 0.0;
    end
    if( type( z ) ~= "number" ) then
        z = 0.0;
    end
    x = x or 0.0;
    y = y or 0.0;
    z = z or 0.0;
    return setmetatable(
        {
            x = x,
            y = y,
            z = z
        },
        _V3_MT
    );
end
    function _V3_MT.__sub( a, b ) -- subtract another vector or number
        local a_type = type( a );
        local b_type = type( b );
        if( a_type == "table" and b_type == "table" ) then
            return Vector3(
                a.x - b.x,
                a.y - b.y,
                a.z - b.z
            );
        elseif( a_type == "table" and b_type == "number" ) then
            return Vector3(
                a.x - b,
                a.y - b,
                a.z - b
            );
        elseif( a_type == "number" and b_type == "table" ) then
            return Vector3(
                a - b.x,
                a - b.y,
                a - b.z
            );
        end
    end
    function _V3_MT:length_sqr() -- squared 3D length
        return ( self.x * self.x ) + ( self.y * self.y ) + ( self.z * self.z );
    end
    function _V3_MT:length() -- 3D length
        return math_sqrt( self:length_sqr() );
    end
    function _V3_MT:dot( other ) -- dot product
        return ( self.x * other.x ) + ( self.y * other.y ) + ( self.z * other.z );
    end
    function _V3_MT:cross( other ) -- cross product
        return Vector3(
            ( self.y * other.z ) - ( self.z * other.y ),
            ( self.z * other.x ) - ( self.x * other.z ),
            ( self.x * other.y ) - ( self.y * other.x )
        );
    end
    function _V3_MT:dist_to( other ) -- 3D length to another vector
        return ( other - self ):length();
    end
    function _V3_MT:normalize() -- normalizes this vector and returns the length
        local l = self:length();
        if( l <= 0.0 ) then
            return 0.0;
        end
        self.x = self.x / l;
        self.y = self.y / l;
        self.z = self.z / l;
        return l;
    end
    function _V3_MT:normalized() -- returns a normalized unit vector
        local l = self:length();
        if( l <= 0.0 ) then
            return Vector3();
        end
        return Vector3(
            self.x / l,
            self.y / l,
            self.z / l
        );
    end
function round(num, numDecimalPlaces)
	local mult = 10^(numDecimalPlaces or 0)
	return math.floor(num * mult + 0.5) / mult
end
local function angle_forward( angle ) -- angle -> direction vector (forward)
    local sin_pitch = math_sin( math_rad( angle.x ) );
    local cos_pitch = math_cos( math_rad( angle.x ) );
    local sin_yaw   = math_sin( math_rad( angle.y ) );
    local cos_yaw   = math_cos( math_rad( angle.y ) );
    return Vector3(
        cos_pitch * cos_yaw,
        cos_pitch * sin_yaw,
        -sin_pitch
    );
end
local function get_FOV( view_angles, start_pos, end_pos ) -- get fov to a vector (needs client view angles, start position (or client eye position for example) and the end position)
    local type_str;
    local fwd;
    local delta;
    local fov;
    fwd   = angle_forward( view_angles );
    delta = ( end_pos - start_pos ):normalized();
    fov   = math_acos( fwd:dot( delta ) / delta:length() );
    return math_max( 0.0, math_deg( fov ) );
end
local ffi = require("ffi")
local vector = require 'vector'
local line_goes_through_smoke
do
    local success, match = client.find_signature("client_panorama.dll", "\x55\x8B\xEC\x83\xEC\x08\x8B\x15\xCC\xCC\xCC\xCC\x0F\x57")
    if success and match ~= nil then
        local lgts_type = ffi.typeof("bool(__thiscall*)(float, float, float, float, float, float, short);")
        line_goes_through_smoke = ffi.cast(lgts_type, match)
    end
end
--endregion
--region math
function math.round(number, precision)
    local mult = 10 ^ (precision or 0)
    return math.floor(number * mult + 0.5) / mult
end
--endregion
--region angle
--- @class angle_c
--- @field public p number Angle pitch.
--- @field public y number Angle yaw.
--- @field public r number Angle roll.
local angle_c = {}
local angle_mt = {
    __index = angle_c
}
--- Create a new vector object.
--- @param p number
--- @param y number
--- @param r number
--- @return angle_c
local function angle(p, y, r)
    return setmetatable(
        {
            p = p or 0,
            y = y or 0,
            r = r or 0
        },
        angle_mt
    )
end
-- VECTOR LIBRARY ABOVE --
-- reference library
local ui_set, ui_get, ui_ref, ui_callback, ui_visibile = ui.set, ui.get, ui.reference, ui.set_callback
local ui_new_checkbox, ui_new_color_picker, ui_new_slider =  ui.new_checkbox, ui.new_color_picker, ui.new_slider
local entity_get_player_name, entity_get_bounding_box, entity_is_alive, entity_get_prop, entity_get_local_player, entity_get_player_weapon, entity_get_players = entity.get_player_name, entity.get_bounding_box, entity.is_alive, entity.get_prop, entity.get_local_player, entity.get_player_weapon, entity.get_players
local client_set_event_callback, client_unset_event_callback, client_log, client_color_log, client_screensize, client_draw_indicator, client_draw_text = client.set_event_callback, client.unset_event_callback, client.log, client.color_log, client.screen_size, client.draw_indicator, client.draw_text
local string_format, math_floor, bit_band = string.format, math.floor, bit.band
local renderer_text, renderer_measure_text = renderer.text, renderer.measure_text
-- endregion
local ffi = require( "ffi" )
local js = panorama[ 'open' ]( )
local MyPersonaAPI, LobbyAPI, PartyListAPI, FriendsListAPI, GameStateAPI = js[ 'MyPersonaAPI' ], js[ 'LobbyAPI' ], js[ 'PartyListAPI' ], js[ 'FriendsListAPI' ], js[ 'GameStateAPI' ]
local android_notify=( function( )local a={ callback_registered = false, maximum_count= 7,data={ } }function a:register_callback( )if self.callback_registered then return end; client.set_event_callback( 'paint_ui', function( ) local b={ client.screen_size( ) } local c = { 56, 56, 57 }local d=5;local e=self.data;for f=#e,1,-1 do self.data[f].time=self.data[f].time-globals.frametime()local g,h=150,0;local i=e[f]if i.time<0 then table.remove(self.data,f)else local j=i.def_time-i.time;local j=j>1 and 1 or j;if i.time<0.5 or j<0.5 then h=(j<1 and j or i.time)/0.5;g=h*150;if h<0.2 then d=d+15*(1.0-h/0.2)end end;local k={renderer.measure_text(nil,i.draw)}local l={b[1]/2-k[1]/2+3,b[2]-b[2]/100*17.4+d}renderer.circle(l[1],l[2],c[1],c[2],c[3],g,20,180,0.5)renderer.circle(l[1]+k[1],l[2],c[1],c[2],c[3],g,20,0,0.5)renderer.rectangle(l[1],l[2]-20,k[1],40,c[1],c[2],c[3],g)renderer.text(l[1]+k[1]/2,l[2],255,255,255,255,'c',nil,i.draw)d=d-50 end end;self.callback_registered=true end)end;function a:paint(m,n)local o=tonumber(m)+1;for f=self.maximum_count,2,-1 do self.data[f]=self.data[f-1]end;self.data[1]={time=o,def_time=o,draw=n}self:register_callback()end;return a end)()
-- lua / console
--lua_log("707error")
-- end of lua / console logs
local function get_hardware_id()
    local ffi = require("ffi")
	ffi.cdef [[
	typedef int(__thiscall* get_clipboard_text_count)(void*);
	typedef void(__thiscall* set_clipboard_text)(void*, const char*, int);
	typedef void(__thiscall* get_clipboard_text)(void*, int, const char*, int);
	typedef long(__thiscall* get_file_time_t)(void* this, const char* pFileName, const char* pPathID);
	typedef bool(__thiscall* file_exists_t)(void* this, const char* pFileName, const char* pPathID);
	]]
	local VGUI_System010 = client.create_interface("vgui2.dll", "VGUI_System010") or print("Error finding VGUI_System010")
	local VGUI_System = ffi.cast(ffi.typeof("void***"), VGUI_System010)
	local get_clipboard_text_count = ffi.cast("get_clipboard_text_count", VGUI_System[0][7]) or print("get_clipboard_text_count Invalid")
	local set_clipboard_text = ffi.cast("set_clipboard_text", VGUI_System[0][9]) or print("set_clipboard_text Invalid")
	local get_clipboard_text = ffi.cast("get_clipboard_text", VGUI_System[0][11]) or print("get_clipboard_text Invalid")
	local _debug = false
	local class_ptr = ffi.typeof("void***")
	local rawfilesystem = client.create_interface("filesystem_stdio.dll", "VBaseFileSystem011") or error(_debug and "Failed to get VBaseFileSystem011 interface" or "error", 2)
	local filesystem = ffi.cast(class_ptr, rawfilesystem) or error(_debug and "Failed to cast rawfilesystem to filesystem" or "error", 2)
	local file_exists = ffi.cast("file_exists_t", filesystem[0][10]) or error(_debug and "Failed to cast file_exists_t" or "error", 2)
	local get_file_time = ffi.cast("get_file_time_t", filesystem[0][13]) or error(_debug and "Failed to cast get_file_time_t" or "error", 2)
	local function system_dir()
		for i = 67, 90 do -- C->Z
			local directory = string.char(i) .. ":\\Windows\\Setup\\State\\State.ini"
			if _debug then
				print("Current attempt:" .. directory)
			end
			if file_exists(filesystem, directory, "ROOT") then
				return directory
			end
		end
		return nil
	end
	local directory = system_dir() or error(_debug and "Failed get system directory" or "error", 2)
	local install_time = get_file_time(filesystem, directory, "ROOT") or error(_debug and "get_file_time failed" or "error", 2)
	local HWID = install_time
	return HWID
end
local extended_dt_user_info ={
	can_use = false,
}

-- èå® reference
local aatab = { "AA", "Anti-aimbot angles" }
local luatab = { "LUA", "B" }
local CUR_BUILD             = "2021.8.5"
-- This is what I log

    
local checkbox_reference, hotkey_reference = ui.reference("AA", "Other", "Slow motion")
local aa = {
    labelnew34 = ui.new_label( luatab[1], luatab[2], "\n" ),
    unhide_checkbox = ui.new_checkbox( luatab[1], luatab[2], "    " ),
    labelnew = ui.new_label( luatab[1], luatab[2], "<---------------------AA EXTEND--------------------->" ),
    enable_checkbox = ui.new_checkbox( luatab[1], luatab[2], "Enable AA Extend" ),
    
    configure_combobox = ui.new_combobox( luatab[1], luatab[2], "AA Extend Settings:",  
    "-",
    "Anti-aim",
    "Others.",
    "Indicator",
    "Configuration"),
    labelnew377 = ui.new_label( luatab[1], luatab[2], "!! * means this function may drop your fps !!" ),
    labelnew3 = ui.new_label( luatab[1], luatab[2], "<------------------------------------------------------->" ),
    -- Dynamic anti-aim options ui
    jitter_checkbox = ui.new_checkbox( luatab[1], luatab[2], "AA Extend Anti-Aim" ),
    ext = ui.new_multiselect(luatab[1], luatab[2], "Extra Functions", "In air Anti-Aim","Slow Motion Anti-Aim","Legit AA on E","Manual AA","Leg Movement","Freestanding On Key","Edge Yaw On Key","* Smart Yaw Base","Better Fakelag","Slow Motion Speed","AWP/SCOUT Freestanding Always on"),
    -- Body yaw freestand ui
    -- Edge yaw options ui
    limit_reference = ui.new_slider( luatab[1], luatab[2], "- Slow Motion Speed", 10, 57, 50, 57, "", 1, {[57] = "Max"}),
    smart_yaw_base_slider = ui.new_slider( luatab[1], luatab[2], "- Distance of Smart Yaw Base *", 100, 2000, 390 ),
    -- in air anti aim
    -- manual anti-aim ui
    -- basics
    -- anti-aim keys ui
    labelnew4 = ui.new_label( luatab[1], luatab[2], "<------------------------------------------------------->" ),
    legit_aa_hotkey = ui.new_hotkey( luatab[1], luatab[2], "      -> Legit AA", false ),
    fl_max = ui.new_hotkey( luatab[1], luatab[2], "      -> Max Fakelag", false ),
    edge_yaw_checkbox = ui.new_hotkey( luatab[1], luatab[2], "      -> EdgeYaw On Key", false ),
    free_checkbox = ui.new_hotkey( luatab[1], luatab[2], "      -> FreeStanding On Key", false ),
    manual_left_hotkey = ui.new_hotkey( luatab[1], luatab[2], "      -> Left", false ),
    manual_right_hotkey = ui.new_hotkey( luatab[1], luatab[2], "      -> Right", false ),
    manual_back_hotkey = ui.new_hotkey( luatab[1], luatab[2], "      -> Back", false ),
    
    manual_state = ui.new_slider("AA", "Other", "1", 0, 2, 0),
    
    menu_bar_label = ui.new_label( luatab[1], luatab[2], "      - menu1" ),
    menu_bar_colourpicker = ui.new_color_picker( luatab[1], luatab[2], "mtr", 72 ,61 ,139,255 ),
    menu_bar_two_label = ui.new_label( luatab[1], luatab[2], "      - menu2" ),
    menu_bar_two_colourpicker = ui.new_color_picker( luatab[1], luatab[2], "mr", 132, 112 ,255, 255 ),
}
local dt = {
    ideal_tick = ui.new_checkbox(luatab[1], luatab[2], "      - Ideal tick"),
    ideal_tick_key = ui.new_hotkey(luatab[1], luatab[2], "      - Ideal tick key", true),
    ideal_tick_weps = ui.new_multiselect(luatab[1], luatab[2], "      - Ideal tick Weapons", "AWP", "SSG 08", "R8 Revolver"),
    dt_switcher = ui.new_checkbox(luatab[1], luatab[2], "      - Smart DT switcher *"),
    dt_enable = ui.new_checkbox(luatab[1], luatab[2], "      - DT Tick Changer"),
    dt_tick = ui.new_slider(luatab[1],luatab[2],"      - DT Max Ticks",12,25,17),
}
local ind = {
    somehotkey = ui.new_multiselect(luatab[1], luatab[2], "      - Skeet Hotkeys", "Hide Shots","Freestanding","Edge Yaw","Manual AA","Force Safe Point","Force Baim","Slow Motion","Min DMG"),
    watermark = ui.new_checkbox(luatab[1],luatab[2],"      - Enable Watermark"),
    watermarkx = ui.new_slider(luatab[1], luatab[2], "      -> Watermark X", 0, xyz1, 1632, true, "x"),
    watermarky = ui.new_slider(luatab[1], luatab[2], "      -> Watermark y", 0, xyz2, 5, true, "y"),
    dmg_vis = ui.new_checkbox(luatab[1],luatab[2],"      - Enable Min Damage Indicator"),
    arrow = ui.new_checkbox(luatab[1],luatab[2],"      - Enable AA Arrow"),
    label_c_1 = ui.new_label( luatab[1], luatab[2] ,"       -> Manual Color"),
    indicator_color = ui.new_color_picker(luatab[1], luatab[2], "       -> Manual Color", 130, 156, 212, 255),
    label_c_2 = ui.new_label( luatab[1], luatab[2] ,"       -> Manual Inactive Color"),
    manual_inactive_color = ui.new_color_picker(luatab[1], luatab[2], "       -> Manual Inactive Color",168,168,168, 155),
    indicator_dist = ui.new_slider(luatab[1], luatab[2], "       -> Distance Between Arrows", 1, 100, 15, true, "px"),
    flash = ui.new_checkbox(luatab[1], luatab[2], "       -> Peeking Arrow"),
    aaind = ui.new_checkbox(luatab[1],luatab[2],"      - AA Inds  "),
    desync_text = ui.new_checkbox(luatab[1],luatab[2],"       -> Desync text"),
    desync_text_colourpicker = ui.new_color_picker( luatab[1],luatab[2],245, 245 ,245,255 ),
    shake_ = ui.new_label(luatab[1],luatab[2],"         -> Flashing text"),   
    shake_colorpicker = ui.new_color_picker( luatab[1],luatab[2], 130,156,212	,255 ),
    barind = ui.new_checkbox(luatab[1], luatab[2], "       -> AA Ind Bar"),
    infoind = ui.new_checkbox(luatab[1], luatab[2], "       -> AA Ind Fake Limit"),
    infoind_2 = ui.new_checkbox(luatab[1], luatab[2], "       -> AA Mode"),
    infoind_3 = ui.new_checkbox(luatab[1], luatab[2], "       -> Bruteforce info"),
    fakelags = ui.new_checkbox(luatab[1], luatab[2], "      - Fakelag Indicator"),
    
}
local cfg = {
    labelcfg = ui.new_checkbox(luatab[1],luatab[2],"Load Preset Values"),
    presets = ui.new_combobox( luatab[1], luatab[2], "Preset Mode", "Ideal","Steady","FL hvh","Pure" ),
    defaults = ui.new_label(luatab[1],luatab[2],"Default"),
    fake_value_dormant1 =  ui.new_slider( luatab[1], luatab[2], "Fake yaw limit Default(1)(random)", 0, 60,35  ),
    fake_value_dormant2 =  ui.new_slider( luatab[1], luatab[2], "Fake yaw limit Default(2)(random)", 0, 60,50  ),
    fake_value_sw1 =  ui.new_slider( luatab[1], luatab[2], "Fake yaw limit Slow Motion(1)(random)", 0, 60,7  ),
    fake_value_sw2 =  ui.new_slider( luatab[1], luatab[2], "Fake yaw limit Slow Motion(2)(random)", 0, 60,15  ),
    peeks = ui.new_label(luatab[1],luatab[2],"Peeking"),
    left_peek_body_yaw =  ui.new_slider( luatab[1], luatab[2], "Left Peeking Body Yaw", -180, 180,-105  ),
    left_peek_yaw_jitter_mode =  ui.new_combobox( luatab[1], luatab[2], "Left Peeking Yaw Jitter", "Off","Offset","Center","Random"),
    left_peek_yaw_jitter_value =  ui.new_slider( luatab[1], luatab[2], "Left Peeking Yaw Jitter Value", -20,20,2),
    left_peek_body_yaw_after =  ui.new_slider( luatab[1], luatab[2], "Left After Peeking Body Yaw(static)", -180, 180,-116  ),
    left_peek_yaw_safe =  ui.new_slider( luatab[1], luatab[2], "Left Peeking Peek Yaw(safe)", -30, 30,-5  ),
    left_peek_yaw_danger =  ui.new_slider( luatab[1], luatab[2], "Left Peeking Peek Yaw(dangerous)", -30, 30,-14  ),
    right_peek_body_yaw =  ui.new_slider( luatab[1], luatab[2], "Right Peeking Body Yaw", -180, 180,102  ),
    right_peek_yaw_jitter_mode =  ui.new_combobox( luatab[1], luatab[2], "Right Peeking Yaw Jitter", "Off","Offset","Center","Random"),
    right_peek_yaw_jitter_value =  ui.new_slider( luatab[1], luatab[2], "Right Peeking Yaw Jitter Value", -20,20,2),
    right_peek_body_yaw_after =  ui.new_slider( luatab[1], luatab[2], "Right After Peeking Body Yaw(static)", -180, 180,126  ),
    right_peek_yaw_safe =  ui.new_slider( luatab[1], luatab[2], "Right Peeking Peek Yaw(safe)", -30, 30,-5  ),
    right_peek_yaw_danger =  ui.new_slider( luatab[1], luatab[2], "Right Peeking Peek Yaw(dangerous)", -30, 30,17  ),
    dangerhealth = ui.new_slider( luatab[1], luatab[2], "Dangerous mode Health(<)", 5, 50, 24  ),
    d_d = ui.new_label(luatab[1],luatab[2],"Dynamic & Dormant"),
    back_jitter_mode =  ui.new_combobox( luatab[1], luatab[2], "Back Jitter Mode(In ESP)", "Off","Offset","Center","Random"),
    back_jitter_value =  ui.new_slider( luatab[1], luatab[2], "Back Jitter Value(In ESP)", -50, 50,14  ),
    back_jitter_value_2 = ui.new_slider( luatab[1], luatab[2], "Off Jitter(In ESP)", -50, 50,14  ),
    dormants_mode =  ui.new_combobox( luatab[1], luatab[2], "Back Jitter Mode(Out ESP)", "Off","Offset","Center","Random"),
    dormants_value =  ui.new_slider( luatab[1], luatab[2], "Back Jitter Value(Out ESP)", -50, 50,14  ),
    dormants_value_2 = ui.new_slider( luatab[1], luatab[2], "Off Jitter(Out ESP)", -50, 50,14  ),
    air_air = ui.new_label(luatab[1],luatab[2],"In air functions(nodt)"),
    in_air_value_nodt_f =  ui.new_combobox( luatab[1], luatab[2], "In air body yaw mode(no dt)", "Off","Opposite","Jitter","Static"  ),
    in_air_value_nodt_1 =  ui.new_slider( luatab[1], luatab[2], "In air body yaw(no dt)", -50, 50,0  ),
    in_air_value_nodt_2 =  ui.new_combobox( luatab[1], luatab[2], "In air Jitter Mode(no dt)", "Off","Offset","Center","Random"  ),
    in_air_value_nodt_3 =  ui.new_slider( luatab[1], luatab[2], "In air Jitter Yaw(no dt)", -50, 50,14  ),
    air_air2 = ui.new_label(luatab[1],luatab[2],"In air functions(dt)"),
    in_air_value_dt_f =  ui.new_combobox( luatab[1], luatab[2], "In air body yaw mode(dt)", "Off","Opposite","Jitter","Static"  ),
    in_air_value_dt_1 =  ui.new_slider( luatab[1], luatab[2], "In air body yaw(dt)", -50, 50,0  ),
    in_air_value_dt_2 =  ui.new_combobox( luatab[1], luatab[2], "In air Jitter Mode(dt)", "Off","Offset","Center","Random"  ),
    in_air_value_dt_3 =  ui.new_slider( luatab[1], luatab[2], "In air Jitter Yaw(dt)", -50, 50,14  ),
}
function preset_cfg()
    if ui.get(cfg.presets) == "Pure" then
    ui.set(cfg.dangerhealth,29)
    ui.set(cfg.fake_value_dormant1,35)
    ui.set(cfg.fake_value_dormant2,50)
    ui.set(cfg.fake_value_sw1,7)
    ui.set(cfg.fake_value_sw2,15)
    ui.set(cfg.right_peek_body_yaw,105)
    ui.set(cfg.right_peek_yaw_jitter_mode,"Random")
    ui.set(cfg.right_peek_yaw_jitter_value,2)
    ui.set(cfg.right_peek_body_yaw_after,116)
    ui.set(cfg.right_peek_yaw_safe,-5)
    ui.set(cfg.right_peek_yaw_danger,14)
    
    ui.set(cfg.left_peek_body_yaw,-102)
    ui.set(cfg.left_peek_yaw_jitter_mode,"Random")
    ui.set(cfg.left_peek_yaw_jitter_value,2)
    ui.set(cfg.left_peek_body_yaw_after,-126)
    ui.set(cfg.left_peek_yaw_safe,-5)
    ui.set(cfg.left_peek_yaw_danger,17)
    ui.set(cfg.back_jitter_mode,"Offset")
    ui.set(cfg.back_jitter_value,14)
    ui.set(cfg.dormants_mode,"Offset")
    ui.set(cfg.dormants_value,14)
    ui.set(cfg.in_air_value_nodt_1,0)
    ui.set(cfg.in_air_value_dt_1,15)
    ui.set(cfg.in_air_value_nodt_f,"Static")
    ui.set(cfg.in_air_value_dt_f,"Jitter")
    ui.set(cfg.in_air_value_nodt_2,"Offset")
    ui.set(cfg.in_air_value_dt_2,"Off")
    ui.set(cfg.in_air_value_nodt_3,19)
    ui.set(cfg.in_air_value_dt_3,0)
    ui.set(cfg.back_jitter_value_2,-14)
    ui.set(cfg.dormants_value_2,-14)
    elseif  ui.get(cfg.presets) == "FL hvh" then
        ui.set(cfg.dangerhealth,29)
        ui.set(cfg.fake_value_dormant1,7)
        ui.set(cfg.fake_value_dormant2,50)
        ui.set(cfg.fake_value_sw1,7)
        ui.set(cfg.fake_value_sw2,10)
        ui.set(cfg.left_peek_body_yaw,90)
        ui.set(cfg.left_peek_yaw_jitter_mode,"Random")
        ui.set(cfg.left_peek_yaw_jitter_value,10)
        ui.set(cfg.left_peek_body_yaw_after,70)
        ui.set(cfg.left_peek_yaw_safe,-5)
        ui.set(cfg.left_peek_yaw_danger,-14)
        ui.set(cfg.right_peek_body_yaw,-90)
        ui.set(cfg.right_peek_yaw_jitter_mode,"Random")
        ui.set(cfg.right_peek_yaw_jitter_value,-10)
        ui.set(cfg.right_peek_body_yaw_after,-70)
        ui.set(cfg.right_peek_yaw_safe,-5)
        ui.set(cfg.right_peek_yaw_danger,25)
        ui.set(cfg.back_jitter_mode,"Offset")
        ui.set(cfg.back_jitter_value,4)
        ui.set(cfg.dormants_mode,"Offset")
        ui.set(cfg.dormants_value,14)
        ui.set(cfg.in_air_value_nodt_1,0)
        ui.set(cfg.in_air_value_dt_1,15)
        ui.set(cfg.in_air_value_nodt_f,"Static")
        ui.set(cfg.in_air_value_dt_f,"Jitter")
        ui.set(cfg.in_air_value_nodt_2,"Offset")
        ui.set(cfg.in_air_value_dt_2,"Off")
        ui.set(cfg.in_air_value_nodt_3,19)
        ui.set(cfg.in_air_value_dt_3,0)
        ui.set(cfg.back_jitter_value_2,-14)
        ui.set(cfg.dormants_value_2,-14)
    elseif  ui.get(cfg.presets) == "Steady" then
        ui.set(cfg.dangerhealth,35)
        ui.set(cfg.fake_value_dormant1,25)
        ui.set(cfg.fake_value_dormant2,35)
        ui.set(cfg.fake_value_sw1,7)
        ui.set(cfg.fake_value_sw2,15)
        ui.set(cfg.left_peek_body_yaw,105)
        ui.set(cfg.left_peek_yaw_jitter_mode,"Off")
        ui.set(cfg.left_peek_yaw_jitter_value,2)
        ui.set(cfg.left_peek_body_yaw_after,116)
        ui.set(cfg.left_peek_yaw_safe,-5)
        ui.set(cfg.left_peek_yaw_danger,-14)
        ui.set(cfg.right_peek_body_yaw,-102)
        ui.set(cfg.right_peek_yaw_jitter_mode,"Off")
        ui.set(cfg.right_peek_yaw_jitter_value,2)
        ui.set(cfg.right_peek_body_yaw_after,-126)
        ui.set(cfg.right_peek_yaw_safe,-5)
        ui.set(cfg.right_peek_yaw_danger,20)
        ui.set(cfg.back_jitter_mode,"Offset")
        ui.set(cfg.back_jitter_value,7)
        ui.set(cfg.dormants_mode,"Offset")
        ui.set(cfg.dormants_value,14)
        ui.set(cfg.in_air_value_nodt_1,0)
        ui.set(cfg.in_air_value_dt_1,15)
        ui.set(cfg.in_air_value_nodt_f,"Static")
        ui.set(cfg.in_air_value_dt_f,"Static")
        ui.set(cfg.in_air_value_nodt_2,"Offset")
        ui.set(cfg.in_air_value_dt_2,"Offset")
        ui.set(cfg.in_air_value_nodt_3,0)
        ui.set(cfg.in_air_value_dt_3,0)
        ui.set(cfg.back_jitter_value_2,-14)
        ui.set(cfg.dormants_value_2,-14)
    elseif ui.get(cfg.presets) == "Ideal" then
        ui.set(cfg.dangerhealth,35)
        ui.set(cfg.fake_value_dormant1,25)
        ui.set(cfg.fake_value_dormant2,35)
        ui.set(cfg.fake_value_sw1,7)
        ui.set(cfg.fake_value_sw2,15)
        ui.set(cfg.left_peek_body_yaw,180)
        ui.set(cfg.left_peek_yaw_jitter_mode,"Off")
        ui.set(cfg.left_peek_yaw_jitter_value,0)
        ui.set(cfg.left_peek_body_yaw_after,165)
        ui.set(cfg.left_peek_yaw_safe,-5)
        ui.set(cfg.left_peek_yaw_danger,-14)
        ui.set(cfg.right_peek_body_yaw,-180)
        ui.set(cfg.right_peek_yaw_jitter_mode,"Off")
        ui.set(cfg.right_peek_yaw_jitter_value,0)
        ui.set(cfg.right_peek_body_yaw_after,-170)
        ui.set(cfg.right_peek_yaw_safe,-5)
        ui.set(cfg.right_peek_yaw_danger,20)
        ui.set(cfg.back_jitter_mode,"Offset")
        ui.set(cfg.back_jitter_value,0)
        ui.set(cfg.dormants_mode,"Offset")
        ui.set(cfg.dormants_value,14)
        ui.set(cfg.in_air_value_nodt_1,0)
        ui.set(cfg.in_air_value_dt_1,15)
        ui.set(cfg.in_air_value_nodt_f,"Static")
        ui.set(cfg.in_air_value_dt_f,"Static")
        ui.set(cfg.in_air_value_nodt_2,"Offset")
        ui.set(cfg.in_air_value_dt_2,"Offset")
        ui.set(cfg.in_air_value_nodt_3,0)
        ui.set(cfg.in_air_value_dt_3,0)
        ui.set(cfg.back_jitter_value_2,0)
        ui.set(cfg.dormants_value_2,0)
    end
end
local vars = {
    ideal_tick_charge = 0,
    ideal_tick_enabled = false
}
local function includes(table, key)
    for i=1, #table do
        if table[i] == key then
            return true
        end
    end
    return false
end
local refs = {
    fl_limit = ui.reference("AA", "Fake lag", "Limit"),
    dt = { ui.reference("RAGE", "Other", "Double tap") },
    dt2 = ui.reference("RAGE", "Other", "Double tap"),
    fd = ui.reference("RAGE", "Other", "Duck peek assist"),
    hs = { ui.reference("AA", "Other", "On shot anti-aim") },
    quickpeek = { ui.reference("RAGE", "Other", "Quick peek assist") },
}
local fontstyle = "b-"
local function idealdraw()
    local screen_w, screen_h = client.screen_size()
    if me == nil or not entity.is_alive(me) then return end
    if vars.ideal_tick_enabled then
        if vars.ideal_tick_charge == 100 then
           
            renderer.text(screen_w / 2  + 57, screen_h / 2+5 , 185, 185, 255, 255, fontstyle, 0, "IDEAL TICK : CHARGED")
        else
            local text_w2, text_h2 = renderer.measure_text(fontstyle, "IDEAL TICK")
            renderer.text(screen_w / 2 + 57, screen_h / 2+5 , 255 - vars.ideal_tick_charge * 0.9, 165, 165 + vars.ideal_tick_charge * 0.9, 255, fontstyle, 0, "IDEAL TICK")
            renderer.circle_outline(screen_w / 2  + 52, screen_h / 2+5, 0, 0, 0, 125, 5, 0, 1, 2)
            renderer.circle_outline(screen_w / 2  + 52, screen_h / 2+5, 255 - vars.ideal_tick_charge * 0.9, 165, 165 + vars.ideal_tick_charge * 0.9, 255, 5, 270, vars.ideal_tick_charge / 100, 2)
        end
    end
end
local function doubletap_charged()
    if not ui.get(refs.dt[1]) or not ui.get(refs.dt[2]) or ui.get(refs.fd)  then return false end
    local me = entity.get_local_player()
    if me == nil or not entity.is_alive(me) then return false end
    local weapon = entity.get_prop(me, "m_hActiveWeapon")
    if weapon == nil then return false end
    local next_attack = entity.get_prop(me, "m_flNextAttack") + 0.25
    local next_primary_attack = entity.get_prop(weapon, "m_flNextPrimaryAttack") + 0.5
    if next_attack == nil or next_primaryattack == nil then return false end
    return next_attack - globals.curtime() < 0 and next_primary_attack - globals.curtime() < 0
end
local function ideal_tick()
    vars.ideal_tick_enabled = false
    if not ui.get(dt.ideal_tick) or not ui.get(dt.ideal_tick_key) or ui.get(refs.fd) or ui.get(refs.hs[2]) and ui.get(refs.hs[1]) then
        ui.set(refs.quickpeek[2], "On hotkey")
        ui.set(refs.dt[2], "Toggle")
        vars.ideal_tick_charge = 0
    else
        local me = entity.get_local_player()
        local weapon_idx = entity.get_player_weapon(me)
        local weapon = entity.get_prop(weapon_idx, "m_iItemDefinitionIndex")
        if weapon == nil then return end
        local weapon_name = entity.get_classname(weapon_idx)
        if weapon_name == "CWeaponAWP" and includes(ui.get(dt.ideal_tick_weps), "AWP") or
        weapon_name == "CDEagle" and includes(ui.get(dt.ideal_tick_weps), "R8 Revolver") or
        weapon_name == "CWeaponSSG08" and includes(ui.get(dt.ideal_tick_weps), "SSG 08") then
            ui.set(refs.quickpeek[1], true)
            ui.set(refs.quickpeek[2], "Always on")
            ui.set(refs.dt[2], "Always on")
            ui.set(refs.fl_limit, 1)
            local weapon = entity.get_prop(me, "m_hActiveWeapon")
            local next_primary_attack = entity.get_prop(weapon, "m_flNextPrimaryAttack") + 0.5
            if doubletap_charged() then
                vars.ideal_tick_charge = math.floor(100 - (globals.chokedcommands() == 1 and 0 or globals.chokedcommands() * 7.15))
            else
                local charge_time = math.max(0, 100 - ((next_primary_attack - globals.curtime()) * 100))
                vars.ideal_tick_charge = math.floor(math_min(100, charge_time))
            end
            vars.ideal_tick_enabled = true
        end
end
end
local dtmode = ui.reference("RAGE", "Other", "Double tap mode")
client.set_event_callback("setup_command", function (cmd)
    me = Vector3( entity.get_prop( entity.get_local_player( ), "m_vecOrigin" ) )
    for _, player in ipairs( entity.get_players( true ) ) do
         target = Vector3( entity.get_prop( player, "m_vecOrigin") )
         _distance = me:dist_to( target )
    end
    --client.log(_distance)
    if ui.get(dt.dt_switcher) then
    if _distance ~= nil then
        if cmd.forwardmove==0 or _distance>=650 then
            ui_set(dtmode, "Offensive")
        end
        if cmd.sidemove==0 and _distance<650 then
            ui_set(dtmode,"Defensive")
        end
    else
        ui_set(dtmode, cmd.forwardmove ==0 and cmd.sidemove ==0 and "Offensive" or "Defensive")
    end
    
    end
end)
client_set_event_callback("paint", idealdraw)
client_set_event_callback("run_command", ideal_tick)
local ref_aa_enabled = ui.reference( "AA", "Anti-aimbot angles", "Enabled" )
local ref_body_freestanding = ui.reference( "AA", "Anti-aimbot angles", "Freestanding body yaw" )
local ref_pitch = ui.reference( "AA", "Anti-aimbot angles", "Pitch" )
local ref_yaw, ref_yaw_offset = ui.reference( "AA", "Anti-aimbot angles", "Yaw" )
local ref_body_yaw, ref_body_yaw_offset = ui.reference( "AA", "Anti-aimbot angles", "Body yaw" )
local ref_yaw_base = ui.reference( "AA", "Anti-aimbot angles", "Yaw base" )
local ref_jitter, ref_jitter_slider = ui.reference( "AA", "Anti-aimbot angles", "Yaw jitter" )
local ref_fake_limit = ui.reference( "AA", "Anti-aimbot angles", "Fake yaw limit" )
local ref_edge_yaw = ui.reference( "AA", "Anti-aimbot angles", "Edge yaw" )
local ref_freestanding, ref_freestanding_key = ui.reference( "AA", "Anti-aimbot angles", "Freestanding" )
local ref_fake_lag = ui.reference ( "AA", "Fake lag", "Amount" )
local ref_fake_lag_limit = ui.reference ( "AA", "Fake lag", "Limit" )
local ref_fakeduck = ui.reference ( "RAGE", "Other", "Duck peek assist" )
local ref_legmovement = ui.reference ( "AA", "Other", "Leg movement" )
local ref_slow_walk, ref_slow_walk_key = ui.reference ( "AA", "Other", "Slow motion" )
local ref_doubletap = { ui.reference( "RAGE", "Other", "Double Tap" ) }
local ref_doubletaptwo = ui.reference( "RAGE", "Other", "Double Tap" )
local ref_dt_hit_chance = ui.reference( "RAGE", "Other", "Double tap hit chance" )
local ref_osaa, ref_osaa_hkey = ui.reference( "AA", "Other", "On shot anti-aim" )
local ref_mindmg = ui.reference( "RAGE", "Aimbot", "Minimum damage" )
local ref_sp = ui.reference( "RAGE", "Aimbot", "Prefer safe point" )
local ref_fba_key = ui.reference( "RAGE", "Other", "Force body aim" )
local ref_fsp_key = ui.reference( "RAGE", "Aimbot", "Force safe point" )
local ref_ap = ui.reference( "RAGE", "Other", "Delay shot" )
local sv_maxusrcmdprocessticks = ui.reference( "MISC", "Settings", "sv_maxusrcmdprocessticks" )
local predict_ticks         = 17
local in_yaw                = -5
local out_yaw               = -3
local randomiser_allowed    = true
local aa_yaw                = -5
local allow_reset_hit       = true
local static_yaw            = 0
local shooting_low_delta    = false
local low_delta_hit         = false
local should_swap           = false
local last_time_peeked      = nil
local dtState_y             = 0
local hsState_y             = 0
local freestandState_y      = 0
local cur_alpha             = 255
local target_alpha          = 0
local max_alpha             = 255
local min_alpha             = 0
local speed                 = 0.04
local AASTATE_INFO          = "UNRESOLVED"
local hitchance             = 0
local vel                   = 0
local spread_compensation   = 0
local next_attack           = 0
local next_shot_secondary   = 0
local next_shot             = 0
local data = {
    side = 1,
    last_side = 0,
    last_hit = 0,
    hit_side = 0
}
-- end of table
-- start of FUNCTIONS
local function draw_circle( ctx, x, y, r, g, b, a, radius, start_degrees, percentage )
    client.draw_circle( ctx,  x, y, r, g, b, a, radius, start_degrees, percentage )
end
local function draw_rectangle(x, y, w, h, r, g, b, a)
    renderer.rectangle(x, y, w, h, r, g, b, a)
end
local function draw_gradient( ctx, x, y, w, h, r1, g1, b1, a1, r2, g2, b2, a2, ltr )
    client.draw_gradient( ctx, x, y, w, h, r1, g1, b1, a1, r2, g2, b2, a2, ltr )
end
local function draw_circle_outline( ctx, x, y, r, g, b, a, radius, start_degrees, percentage, thickness )
    client.draw_circle_outline( ctx, x, y, r, g, b, a, radius, start_degrees, percentage, thickness )
end
local function contains( tab, val )
    for index, value in ipairs( tab ) do
        if value == val then return true end
    end
    return false
end
local function units_to_meters( units )
    return math.floor( ( units*0.0254 )+0.5)
end
local function units_to_feet( units )
    return math.floor( ( units_to_meters( units )*3.281 )+0.5 )
end
local function get_nearest( )
    local me = Vector3( entity.get_prop( entity.get_local_player( ), "m_vecOrigin" ) )
    
    local nearest_distance
    local nearest_entity
    for _, player in ipairs( entity.get_players( true ) ) do
        local target = Vector3( entity.get_prop( player, "m_vecOrigin") )
        local _distance = me:dist_to( target )
        if ( nearest_distance == nil or _distance < nearest_distance ) then
            nearest_entity = player
            nearest_distance = _distance
        end  
    end
    if ( nearest_distance ~= nil and nearest_entity ~= nil ) then
        return ( { target = nearest_entity, distance = units_to_feet( nearest_distance ) } )
    end
end
local function is_dt( )
    local dt = false
    local local_player = entity.get_local_player()
    if local_player == nil then
        return
    end
    if not entity.is_alive( local_player ) then
        return
    end
    local active_weapon = entity.get_prop( local_player, "m_hActiveWeapon" )
    if active_weapon == nil then
        return
    end
    next_attack = entity.get_prop( local_player,"m_flNextAttack" )
    next_shot = entity.get_prop( active_weapon,"m_flNextPrimaryAttack" )
    next_shot_secondary = entity.get_prop( active_weapon,"m_flNextSecondaryAttack" )
    if next_attack == nil or next_shot == nil or next_shot_secondary == nil then
        return
    end
    next_attack = next_attack+0.5
    next_shot = next_shot+0.5
    next_shot_secondary = next_shot_secondary+0.5
    if ui.get( ref_doubletap[ 1 ] ) and ui.get( ref_doubletap[ 2 ] ) then
        if math.max( next_shot, next_shot_secondary ) < next_attack then
            if next_attack-globals.curtime( ) > 0.00 then
                dt = false
            else
                dt = true
            end
        else -- shooting or just shot
            if math.max( next_shot, next_shot_secondary )-globals.curtime( ) > 0.00  then
                dt = false
            else
                if math.max( next_shot, next_shot_secondary )-globals.curtime( ) < 0.00  then
                    dt = true
                else
                    dt = true
                end
            end
        end
    end
    return dt
end
local function get_near_target( )
    local enemy_players = entity.get_players( true )
    if #enemy_players ~= 0 then
        local own_x, own_y, own_z = client.eye_position( )
        local own_pitch, own_yaw = client.camera_angles( )
        local closest_enemy = nil
        local closest_distance = 999999999
        for i = 1, #enemy_players do
            local enemy = enemy_players[i]
            local enemy_x, enemy_y, enemy_z = entity.get_prop( enemy, "m_vecOrigin" )
            local x = enemy_x - own_x
            local y = enemy_y - own_y
            local z = enemy_z - own_z
            local yaw = ( ( math.atan2( y, x )*180/math.pi ) )
            local pitch = -( math.atan2( z, math.sqrt( math.pow( x, 2 ) + math.pow( y, 2 ) ) )*180/math.pi )
            local yaw_dif = math.abs( own_yaw%360-yaw%360 )%360
            local pitch_dif = math.abs( own_pitch-pitch )%360
            if yaw_dif > 180 then yaw_dif = 360-yaw_dif end
            local real_dif = math.sqrt( math.pow( yaw_dif, 2)+math.pow( pitch_dif, 2 ) )
            if closest_distance > real_dif then
                closest_distance = real_dif
                closest_enemy = enemy
            end
        end
        if closest_enemy ~= nil then
            return closest_enemy, closest_distance
        end
    end
    return nil, nil
end
local function distance_3d( x1, y1, z1, x2, y2, z2 )
        return math.sqrt( ( x1-x2 )*( x1-x2 )+( y1-y2 )*( y1-y2 ) )
end
-- function for extrapolating player
local function extrapolate( player , ticks , x, y, z )
    local xv, yv, zv =  entity.get_prop( player, "m_vecVelocity" )
    local new_x = x+globals.tickinterval( )*xv*ticks
    local new_y = y+globals.tickinterval( )*yv*ticks
    local new_z = z+globals.tickinterval( )*zv*ticks
    return new_x, new_y, new_z
end
local function is_enemy_peeking( player )
    local vx,vy,vz = entity.get_prop( player, "m_vecVelocity" )
    local speed = math.sqrt( vx*vx+vy*vy+vz*vz )
    if speed < 5 then
        return false
    end
    local ex, ey, ez = entity.get_origin( player ) 
    local lx, ly, lz = entity.get_origin( entity.get_local_player ( ) )
    local start_distance = math.abs( distance_3d( ex, ey, ez, lx, ly, lz ) )
    local smallest_distance = 999999
    for ticks = 1, predict_ticks do
        local tex,tey,tez = extrapolate( player, ticks, ex, ey, ez )
        local distance = math.abs( distance_3d( tex, tey, tez, lx, ly, lz ) )
        if distance < smallest_distance then
            smallest_distance = distance
        end
        if smallest_distance < start_distance then
            return true
        end
    end
    return smallest_distance < start_distance
end
local function is_local_peeking_enemy( player )
    local vx,vy,vz = entity.get_prop( entity.get_local_player(), "m_vecVelocity")
    local speed = math.sqrt( vx*vx+vy*vy+vz*vz )
    if speed < 5 then
        return false
    end
    local ex,ey,ez = entity.get_origin( player )
    local lx,ly,lz = entity.get_origin( entity.get_local_player() )
    local start_distance = math.abs( distance_3d( ex, ey, ez, lx, ly, lz ) )
    local smallest_distance = 999999
    if ticks ~= nil then
        TICKS_INFO = ticks
    else
    end
    for ticks = 1, predict_ticks do
        local tex,tey,tez = extrapolate( entity.get_local_player(), ticks, lx, ly, lz )
        local distance = distance_3d( ex, ey, ez, tex, tey, tez )
        if distance < smallest_distance then
            smallest_distance = math.abs(distance)
        end
    if smallest_distance < start_distance then
            return true
        end
    end
    return smallest_distance < start_distance
end
function in_air( )
    return ( bit.band( entity.get_prop( entity.get_local_player( ), "m_fFlags" ), 1 ) == 0 )
end
local function get_closest_point(A, B, P)
   local a_to_p = { P[1] - A[1], P[2] - A[2] }
   local a_to_b = { B[1] - A[1], B[2] - A[2] }
   local ab = a_to_b[1]^2 + a_to_b[2]^2
   local dots = a_to_p[1]*a_to_b[1] + a_to_p[2]*a_to_b[2]
   local t = dots / ab
    
   return { A[1] + a_to_b[1]*t, A[2] + a_to_b[2]*t }
end
local function vec3_dot(ax, ay, az, bx, by, bz)
    return ax*bx + ay*by + az*bz
end
local function vec3_normalize(x, y, z)
    local len = math.sqrt(x * x + y * y + z * z)
    if len == 0 then
        return 0, 0, 0
    end
    local r = 1 / len
    return x*r, y*r, z*r
end
local function angle_to_vec(pitch, yaw)
    local p, y = math.rad(pitch), math.rad(yaw)
    local sp, cp, sy, cy = math.sin(p), math.cos(p), math.sin(y), math.cos(y)
    return cp*cy, cp*sy, -sp
end
local function get_fov_cos(ent, vx,vy,vz, lx,ly,lz)
    local ox,oy,oz = entity.get_prop(ent, "m_vecOrigin")
    if ox == nil then
        return -1
    end
    local dx,dy,dz = vec3_normalize(ox-lx, oy-ly, oz-lz)
    return vec3_dot(dx,dy,dz, vx,vy,vz)
end
local function Angle_Vector(angle_x, angle_y)
    local sp, sy, cp, cy = nil
    sy = math.sin(math.rad(angle_y));
    cy = math.cos(math.rad(angle_y));
    sp = math.sin(math.rad(angle_x));
    cp = math.cos(math.rad(angle_x));
    return cp * cy, cp * sy, -sp;
end
function can_enemy_hit_head( ent )
    if ent == nil then return end
    if in_air( ent ) then return false end
    
    local origin_x, origin_y, origin_z = entity_get_prop( ent, "m_vecOrigin" )
    if origin_z == nil then return end
    origin_z = origin_z + 64
    local hx,hy,hz = entity.hitbox_position( entity.get_local_player( ), 0 ) 
    local _, head_dmg = client.trace_bullet( ent, origin_x, origin_y, origin_z, hx, hy, hz, true )
        
    return head_dmg ~= nil and head_dmg > 25
end
-- this gets the current bomb time if planted
local function get_bomb_time( )
    local bomb = entity.get_all( "CPlantedC4" )[1]
    if bomb == nil then 
        return 0  
    end
    local bomb_time = entity.get_prop( bomb, "m_flC4Blow" )-globals.curtime( ) 
    if bomb_time == nil then 
        return 0
    end
    if bomb_time > 0 then
        return bomb_time
    end
    return 0
end
-- end of function for getting bomb time
-- checks if the local player has a defuser
local function has_defuser( player )
    return entity.get_prop( player, "m_bHasDefuser" ) == 1
end
-- end of checking if the local player has a defuser
local function side_freestanding( cmd )
    -- gets the local player
    local local_player = entity.get_local_player( )
    -- checks if our local player is dead
    if ( not local_player or entity.get_prop( local_player, "m_lifeState" ) ~= 0 ) or not ui.get( aa.enable_checkbox ) == true then
        return
    end
    
    local server_time = globals.curtime( )
    -- check if we have invert desync on side is done
    if data.hit_side ~= 0 and server_time - data.last_hit > 5 then
        -- if so set the last side to '0' so the anti-aim updates
        data.last_side = 0
        -- And reset the smart mode info
        data.last_hit = 0
        data.hit_side = 0
    end
    -- Get what mode our freestanding is using
    -- Get some properties
    local x, y, z = client.eye_position( )
    local _, yaw = client.camera_angles( )
    -- Create a table where the trace data will be stored
    local trace_data = { left = 0, right = 0 }
    for i = yaw-120, yaw+120, 30 do
        if i ~= yaw then
            -- Convert our yaw to radians in order to do further calculations
            local rad = math.rad( i )
            -- Calculate our destination point
            local px, py, pz = x+256*math.cos( rad ), y+256*math.sin( rad ), z
            -- Trace a line from our eye position to the previously calculated point
            local fraction = client.trace_line( local_player, x, y, z, px, py, pz )
            local side = i < yaw and "left" or "right"
            -- Add the trace's fraction to the trace table
            trace_data[ side ] = trace_data[ side ]+fraction
        end
    end
    -- Get which side has the lowest fraction amount, which means that it is closer to us.
    data.side = trace_data.left < trace_data.right and 1 or 2
    -- If our side didn't change from the last tick then there's no need to update our anti-aim
    if data.side == data.last_side then
        return
    end
    -- If it did change, then update our cached side to do further checks
    data.last_side = data.side
    -- Check if we should override our side due to the smart mode
    if data.hit_side ~= 0 then
        data.side = data.hit_side == 1 and 2 or 1
    end
    _mode = "Peeking real"
    -- Get the fake angle's maximum length and calculate what our next body offset should be
    local limit = 90
    local lby = _mode == "Peeking real" and ( data.side == 1 and limit or -limit ) or ( data.side == 1 and -limit or limit )
    static_yaw = lby
    
    -- Update our body yaw settings
    ui.set( ref_body_yaw_offset, limit )
end
-- this is the check for checking if we should use eye yaw or opposite
local multi_exec = function(func, list)
    if func == nil then
        return
    end
    
    for ref, val in pairs(list) do
        func(ref, val)
    end
end
local compare = function(tab, val)
    for i = 1, #tab do
        if tab[i] == val then
            return true
        end
    end
    
    return false
end
--#endregion /helpers
local bind_system = {
    left = false,
    right = false,
    back = false,
}
function bind_system:update()
    ui.set( aa.manual_left_hotkey, "On hotkey" )
    ui.set( aa.manual_right_hotkey , "On hotkey" )
    ui.set( aa.manual_back_hotkey, "On hotkey" )
    tablegg = {m_state = ui.get( aa.manual_state )}
    local left_state, right_state, backward_state = 
        ui.get( aa.manual_left_hotkey ), 
        ui.get( aa.manual_right_hotkey ),
        ui.get( aa.manual_back_hotkey )
    if  left_state == self.left and 
        right_state == self.right and
        backward_state == self.back then
        return
    end
    self.left, self.right, self.back = 
        left_state, 
        right_state, 
        backward_state
    if (left_state and tablegg.m_state == 1) or (right_state and tablegg.m_state == 2)then
        ui.set( aa.manual_state , 0)
        return
    end
    if left_state and tablegg.m_state ~= 1 then
        ui.set( aa.manual_state , 1)
    end
    if right_state and tablegg.m_state ~= 2 then
        ui.set( aa.manual_state , 2)
    end
    if backward_state and tablegg.m_state ~= 0 then
        ui.set( aa.manual_state , 0)
    end
end
local menu_callback = function(e, menu_call)
    local state = not includes(ui.get(aa.ext),"Manual AA") -- or (e == nil and menu_call == nil)
    multi_exec(ui.set_visible, {
        [ aa.manual_state ] = false,
    })
end
ui.set_callback( aa.ext , menu_callback)
function handle_manual_anti_aim()
    direction = ui.get( aa.manual_state )
    if includes(ui.get(aa.ext),"Manual AA")   then
        manual_yaw = {
            [0] = 0,
            [1] = -90, [2] = 90,
            [3] = 0,
        }
    end
    if includes(ui.get(aa.ext),"Manual AA")  then
        if direction == 1 or direction == 2 then
            ui.set( ref_yaw_base, "Local view" )
        else
            ui.set( ref_yaw_base, "At targets" )
        end
    end
    if includes(ui.get(aa.ext),"Manual AA")  then
        ui.set( ref_yaw_offset, manual_yaw[direction] )
    end
    local callback = enabled and client.set_event_callback or client.unset_event_callback
end
-- start of setup_command
local function on_setup_command( cmd )
    if includes(ui.get(aa.ext),"Legit AA on E") then
        local gun = entity.get_player_weapon( entity.get_local_player( ) )
        if gun ~= nil and entity.get_classname( gun ) == "CC4" then
            if cmd.in_attack == 1 then
                cmd.in_attack = 0 
                cmd.in_use = 1
            end
        else
            if cmd.chokedcommands == 0 then
                cmd.in_use = 0
            end
        end
    end
    -- this gets the desync angle of the local player
    if cmd.chokedcommands == 0 then
        angle = cmd.in_use == 0 and ui.get( ref_aa_enabled ) and ui.get( ref_body_yaw ) ~= "Off" and math.min( 57, math.abs( entity.get_prop( entity.get_local_player( ), "m_flPoseParameter", 11 )*120-60 ) ) or 0
    end
    --fakelag
    choked_commands = cmd.chokedcommands
    -- start of closest to crosshair checkd
    local entindex = entity_get_local_player( )
    if entindex == nil then return end
    local lx,ly,lz = entity_get_prop( entindex, "m_vecOrigin" )
    if lx == nil then return end
    -- get closest player to crosshair
    local players = entity.get_players( true )    
    local pitch, yaw = client.camera_angles( )
    local vx, vy, vz = angle_to_vec( pitch, yaw )
    local closest_fov_cos = -1
    enemyclosesttocrosshair = nil
    for i=1, #players do
        local idx = players[ i ]
        if entity_is_alive( idx ) then
            local fov_cos = get_fov_cos( idx, vx, vy, vz, lx, ly, lz )
            if fov_cos > closest_fov_cos then
                closest_fov_cos = fov_cos
                enemyclosesttocrosshair = idx
            end
        end
    end
    -- end of closest to crosshair
end
-- end of setup command
-- start of on bullet impact function
-- this is for anti-bruteforcing ( detecting whether an enemy shot near you )
local function on_bullet_impact( c )
    if entity.is_alive( entity.get_local_player( ) ) then
        local ent = client.userid_to_entindex( c.userid )
        if not entity.is_dormant( ent ) and entity.is_enemy( ent ) then
            local ent_shoot = { entity.get_prop( ent, "m_vecOrigin" ) }
            ent_shoot[ 3 ] = ent_shoot[ 3 ]+entity.get_prop( ent, "m_vecViewOffset[2]" )
            local player_head = { entity.hitbox_position( entity.get_local_player( ), 0 ) }
            local closest = get_closest_point( ent_shoot, { c.x, c.y, c.z }, player_head )
            local delta = { player_head[ 1 ]-closest[ 1 ], player_head[ 2 ]-closest[ 2 ] }
            local delta_2d = math.sqrt( delta[ 1 ]^2+delta[ 2 ]^2 )
            if math.abs( delta_2d ) < 32 then
                should_swap = true
            end
        end
    end
end
-- end of on bullet impact function
function resethit( )
    allow_reset_hit = true
    low_delta_hit = false
end
function on_hit_low_delta( )
    if should_swap == true then
        low_delta_hit = true
        if not in_air() then
        if is_in_range == true then
            if data.side == 1 then
                ui.set( ref_fake_limit, ( math.random( 23, 38 ) ) )
            elseif data.side == 2 then
                ui.set( ref_fake_limit, ( math.random( 22, 35 ) ) )
            end
        elseif is_in_range == false then
            if data.side == 1  then
                ui.set( ref_fake_limit, ( math.random( 28, 39 ) ) )
             elseif data.side == 2 then
                ui.set( ref_fake_limit, ( math.random( 40, 50 ) ) )
            end
        end
    elseif in_air() then
        ui.set( ref_fake_limit, ( math.random( 20, 40 ) ) )
    end
        allow_reset_hit = false
        local reset = 58
        client.delay_call( 2, resethit )
        client.delay_call( 2, ui_set, ref_fake_limit, reset )
    end
end
function in_air_anti( )
    if in_air( ) then
        randomiser_allowed = true
        if choked_commands >= 2  then
            ui.set( ref_yaw_offset, 7 )
            ui.set( ref_body_yaw, ui.get(cfg.in_air_value_nodt_f) )
            ui.set( ref_body_yaw_offset, ui.get(cfg.in_air_value_nodt_1)   )
            ui.set( ref_jitter, ui.get(cfg.in_air_value_nodt_2) )
            ui.set( ref_jitter_slider, ui.get(cfg.in_air_value_nodt_3) )
        elseif choked_commands < 2  then
            ui.set( ref_yaw_offset, 7 )
            ui.set( ref_body_yaw, ui.get(cfg.in_air_value_dt_f) )
            ui.set( ref_body_yaw_offset, ui.get(cfg.in_air_value_dt_1) )
            ui.set( ref_jitter, ui.get(cfg.in_air_value_dt_2) )
            ui.set( ref_jitter_slider, ui.get(cfg.in_air_value_dt_3) )
        end
        AASTATE_INFO = "AIR"
    else
        if AASTATE_INFO == "AIR" then
        AASTATE_INFO = "UNRESOLVED"
        end
    end
end
-- this is what stops the client_delay_call function from overlapping and causing fps issues
-- this gets called back when the aimbot fires
function legitaa( )
    randomiser_allowed = false
    ui.set( ref_yaw_base, "Local view" )
    ui.set( ref_yaw_offset, 180 )
    ui.set( ref_pitch, "Off" )
    ui.set( ref_body_yaw, "Static" )
    ui.set( ref_jitter, "Off" )
    ui.set( ref_jitter_slider, 0 )
    ui.set( ref_fake_limit, 58 )
    sj_r, sj_g, sj_b = 255, 0, 0
    ePeeking = true
    once_change = true
    if data.side == 1 then
        ui.set( ref_body_yaw_offset, 60 )
    else
    end
    if data.side == 2 then
        ui.set( ref_body_yaw_offset, -60 )
    else
    end
    AASTATE_INFO = "LEGIT AA "
    -- this checks if you havent got the legit aakey pressed and sets data.side
    if ui.get( aa.legit_aa_hotkey ) == false and once_change == true and ui.get( aa.enable_checkbox ) == true then
            
            if data.side == 1 then
                ui.set( ref_body_yaw_offset, 60 )
            end
            if data.side == 2 then
                ui.set( ref_body_yaw_offset, -60 )
            end
        once_change = false
    end
    -- end of check
end
slidewalk = ui.reference("AA", "other", "leg movement")
local callback = client.set_event_callback or client.unset_event_callback
callback("net_update_end", function( )
    if  includes(ui.get(aa.ext),"Leg Movement") then
        entity.set_prop(entity.get_local_player(), "m_flPoseParameter", 1, 0)
    end
end)
client.set_event_callback("run_command", function(ctx)
    if  includes(ui.get(aa.ext),"Leg Movement") then
	p = client.random_int(1, 3)
	if p == 1 then
		ui.set(slidewalk, "Off")
	elseif p == 2 then
       ui.set(slidewalk, "Always slide")
    elseif p == 3 then
		ui.set(slidewalk, "Off")
    end
    ui.set_visible(slidewalk, false)
else
    ui.set_visible(slidewalk, true)
end
end)
function is_slow_walking( )
    local slow_walking = false
    if not ui.get(ref_slow_walk_key) then
        slow_walking = false
    elseif ui.get(ref_slow_walk_key) then
        slow_walking = true
    end
    return slow_walking
end
function low_delta_slow_walk( )
    if is_slow_walking( ) then
        AASTATE_INFO = "SLOW WALKING"
        randomiser_allowed = true
        anti_bruteforce()
        ui.set(ref_fake_limit, math.random( 7,15  ) ) 
        if force_left == 1 then
            data.side = 1
        end
    end
end
function dormancy_fix( )
    if enemy_dormant == true then
        ui.set( ref_yaw_offset, in_yaw )
        ui.set( ref_body_yaw, "Static" )  
    end
end
function handle_basics( )
    -- basic checkboxes and anti_aims
    if includes(ui.get(aa.ext),"Legit AA on E") then
        if client.key_state( 0x45 ) then
            ePeeking = true
            ui.set( ref_body_yaw, "Static" )
            if data.side == 1 then 
                ui.set( ref_body_yaw_offset, -58 )
            elseif data.side == 2 then
                ui.set( ref_body_yaw_offset, 58 )
            end
        elseif not client.key_state( 0x45 ) then
            ePeeking = false
        end
    elseif not includes(ui.get(aa.ext),"Legit AA on E") then
        ePeeking = false
    end
    -- updates our anti-aim for after legit aa on key
    if ui.get(aa.enable_checkbox) then
        ui.set( ref_pitch, "Minimal" )
        end
    -- end of check
    -- checks if the enemy is dormant
    if not entity.is_dormant( player ) and entity.is_alive( player ) then
        enemy_dormant = false
    else
        enemy_dormant = true
    end
    -- end of dormancy check
    -- checks if the smart jitter is on and if you are dormant it forces your yaw bac to inrange yaw so the e-peeking still works
    if includes and enemy_dormant == true and not includes(ui.get(aa.ext),"Manual AA")   then
        dormancy_fix( )
    else
    end
    -- end of check
    -- this checks if you have the legmovement option on and what it should do
    -- end of check
    -- this checks if you have pressed the legit aa key and if you have it sets your aa to a "legit aa" format
    if ui.get( aa.legit_aa_hotkey ) == true and includes(ui.get(aa.ext),"Legit AA on E") and ui.get( aa.enable_checkbox ) == true then
        legitaa( )
    else
    end
    -- end of legit aa check
end
function handle_indicator_colours( )
    -- this changes the colour of the ç®­å¤´ depending on what delta you have
    if allow_reset_hit == true then
        dr, dg, db, da = cac_r, cac_g, cac_b, cac_a
    else
        if ui.get( ref_fake_limit ) <= 37 then
            dr, dg, db, da = cac_r, cac_g, cac_b, alpha
        elseif ui.get( ref_fake_limit ) > 37 then
            dr, dg, db, da = cac_r, cac_g, cac_b, alpha
        end
    end
    -- end of check
end
local function is_under_health( )
    under_health = false
    if ( entity_get_prop( entity.get_local_player( ), "m_iHealth" ) <= ui.get(cfg.dangerhealth) ) then
        under_health = true
    else
        under_health = false
    end
    return under_health
end
local function compensate_spread( )
    -- this gets your velocity and if your velocity is < 0 (aka going forwards) it will convert your velocity back to positive
    vel = entity.get_prop( entity.get_local_player( ), "m_vecVelocity" )
    if vel < 0 then
        vel = vel*-1
    end
    -- spread compensation calculation for dt_hitchance
    spread_compensation = ( vel * 0.037 )
    if spread_compensation < 1 then
        spread_compensation = 1
    end
    return spread_compensation
end
function handle_anti_aims( )
    -- checks if the smart jitter is off and if not it forces your yaw to in range yaw so after epeeking anywhere your yaw changes back
    if not ui.get( aa.jitter_checkbox ) then
        ui.set( ref_yaw_offset, in_yaw )
        AASTATE_INFO = "NIL"
    else
    end
    -- end of check
    if includes(ui.get(aa.ext),"In air Anti-Aim") then
        in_air_anti( )
    end
    if 	includes(ui.get(aa.ext),"Slow Motion Anti-Aim") then
        if is_slow_walking( ) then
            AASTATE_INFO = "SLOW WALKING"
            ui.set(ref_body_yaw_offset, 95)
        end
    end
    -- if you are out of range of the enemy it sets your yaw to the out of range yaw
    if is_in_range == false and ui.get( aa.jitter_checkbox ) then
        if not includes(ui.get(aa.ext),"Manual AA")  then
            if ePeeking == false then
                ui.set( ref_yaw_offset, out_yaw )
            end
        else
        end
    end
    -- end of check
    if ePeeking == true then
        AASTATE_INFO = "LEGIT AA"
    end
    -- checks if you have safeyaw enabled and if you are under under health
    -- it also checks if you have peek out or safe head on
    if is_under_health( ) then
        safe_yaw = 15
    elseif data.side == 2 then
        safe_yaw = -15
    end
    -- end of safe yaw check
end
function smart_yaw_base()
    local me = Vector3( entity.get_prop( entity.get_local_player( ), "m_vecOrigin" ) )
    for _, player in ipairs( entity.get_players( true ) ) do
         local target = Vector3( entity.get_prop( player, "m_vecOrigin") )
         local _distance = me:dist_to( target )
    end
    
    if ui.get(aa.enable_checkbox) then
    
    if not in_air() and not is_slow_walking() and _distance ~= nil then
        if _distance <= ui.get(aa.smart_yaw_base_slider)    then
            ui.set(ref_yaw_base,"At targets")
        else
            ui.set(ref_yaw_base,"Local view")
        end
    end
    end
end
function anti_bruteforce( )
    if should_swap == true then
        AA_BR = "BRUTEFORCING"
        ui.set( ref_body_yaw_offset, ui.get( ref_body_yaw_offset )* -1 )
        if ref_fake_limit < 57 then
        ui.set (ref_fake_limit , ui.get(ref_fake_limit) + 3)
        else
        ui.set (ref_fake_limit , ui.get(ref_fake_limit) - 3)
        end
        randomiser_allowed = true
    end
end
-- start of on run command
local on_run_command = function( cmd )
    should_swap = false
    AA_BR = ""
    -- Checks if the local player is alive
    local local_player = entity.get_local_player( )
    if ( not entity.is_alive( local_player ) ) then
        return     
    end
    -- This applies the fake_limit_randomisation 
    if ui.get( aa.jitter_checkbox ) then
        if randomiser_allowed == true then
        fake_limit_randomisation( )
        end
    end
    -- Slow walk anti-aim
    if is_slow_walking( ) then -- If slow walking and anti-aim right hybrid is not enabled
        slow_walking_aa( )
    end
    if ePeeking == true then ui.set( ref_freestanding, "-" ) else ui.set( ref_freestanding, "Default" ) end
    if includes(ui.get(aa.ext),"Slow Motion Anti-Aim") then low_delta_slow_walk( ) end
    handle_manual_anti_aim()
    if includes(ui.get(aa.ext),"* Smart Yaw Base") then
    smart_yaw_base()
    end
    -- handle functions
    side_freestanding( )
    handle_indicator_colours( )
    handle_anti_aims( )
    handle_basics( )
   
    data2 = get_nearest( )
    if ( data2 == nil ) then
        return
    end
    if ( data2.distance < 120 ) then
        is_in_range = true
    else
        is_in_range = false
    end
end
function fake_randomisation( )
    if in_air() and not is_slow_walking() then
        ui.set(ref_fake_limit, math.random( 20,40  ) ) 
    elseif is_slow_walking() then
        ui.set(ref_fake_limit, math.random( ui.get(cfg.fake_value_sw1),ui.get(cfg.fake_value_sw2)  ) ) 
    else
        ui.set(ref_fake_limit, math.random( ui.get(cfg.fake_value_dormant1),ui.get(cfg.fake_value_dormant2)  ) ) 
    end
end
function fake_limit_randomisation( )
    if ui.get( aa.jitter_checkbox ) then
        if randomiser_allowed == true then
            client.delay_call( 0.02, fake_randomisation ) randomiser_allowed = false
        end
    end
end
function slow_walking_aa( )
    ui.set( ref_yaw_offset, 7 )
    ui.set( ref_jitter, "Offset" )
    ui.set( ref_jitter_slider, 7 )
    ui.set( ref_body_yaw, "jitter" )
end
function right_static( )
    -- Actual anti-aim
    ui.set( ref_body_freestanding,  false)
        body_yaw = ui.get(cfg.left_peek_body_yaw)
    -- Changes yaw if safe yaw combobox is enabled
    if is_under_health( ) then
        peek_yaw = ui.get(cfg.left_peek_yaw_danger)
        AASTATE_INFO = "DANGEROUS PEEK"
        randomiser_allowed = true
    else
        peek_yaw = ( ui.get(cfg.left_peek_yaw_safe) + 1 )
        AASTATE_INFO = "PEEKING"
    end
    anti_bruteforce()
    -- If you should anti-bruteforce it will change your body yaw to the opposite side.
    -- Sets your yaw to the correct yaw
    ui.set( ref_yaw_offset, peek_yaw )
    ui.set( ref_body_yaw_offset, body_yaw )
    ui.set( ref_body_yaw, "Static" )
    ui.set( ref_jitter, ui.get(cfg.left_peek_yaw_jitter_mode) )
    ui.set( ref_jitter_slider, ui.get(cfg.left_peek_yaw_jitter_value) )
    peeksok = "right"
end
function right_static_alternative( )
    -- Actual anti-aim
    ui.set( ref_body_freestanding,  true)
        body_yaw = ui.get(cfg.left_peek_body_yaw_after)
    -- Changes yaw if safe yaw combobox is enabled
    if is_under_health( ) then
        randomiser_allowed = true
        peek_yaw = ui.get(cfg.left_peek_yaw_danger)
        AASTATE_INFO = "DANGEROUS(ALT) PEEK"
    else
        peek_yaw = ( ui.get(cfg.left_peek_yaw_safe)  )
        AASTATE_INFO = "ALT PEEKING"
        randomiser_allowed = false
    end
    -- If you should anti-bruteforce it will change your body yaw to the opposite side.
    anti_bruteforce()
    -- Sets your yaw to the correct yaw 
    ui.set( ref_yaw_offset, peek_yaw )
    ui.set( ref_body_yaw_offset, body_yaw )
    ui.set( ref_body_yaw, "Static" )
    ui.set( ref_jitter, "Off" )
    ui.set( ref_jitter_slider, 0 )
    peeksok = "off"
end
function left_static( )
    -- Actual anti-aim
    ui.set( ref_body_freestanding,  false)
        body_yaw = ui.get(cfg.right_peek_body_yaw)
    -- Changes yaw if safe yaw combobox is enabled
    if is_under_health( ) then
        peek_yaw = ui.get(cfg.right_peek_yaw_danger)
        AASTATE_INFO = "DANGEROUS PEEK"
        randomiser_allowed = true
    else
        peek_yaw = ( ui.get(cfg.right_peek_yaw_safe)-1 )
        AASTATE_INFO = "PEEKING"
    end
    anti_bruteforce()
    ui.set( ref_yaw_offset, peek_yaw )
    ui.set( ref_body_yaw_offset, body_yaw )
    ui.set( ref_body_yaw, "Static" )
    ui.set( ref_jitter, ui.get(cfg.right_peek_yaw_jitter_mode) )
    ui.set( ref_jitter_slider, ui.get(cfg.right_peek_yaw_jitter_value) )
    peeksok = "left"
end
function left_static_alternative( )
    -- Actual anti-aim
    ui.set( ref_body_freestanding,  true)
        body_yaw =  ui.get(cfg.right_peek_body_yaw_after)
    -- Changes yaw if safe yaw combobox is enabled
    if is_under_health( ) then
        randomiser_allowed = true
        peek_yaw = ui.get(cfg.right_peek_yaw_danger)
        AASTATE_INFO = "DANGEROUS(ALT) PEEK"
    else
        peek_yaw = ( ui.get(cfg.right_peek_yaw_safe) )
        AASTATE_INFO = "ALT PEEKING"
        randomiser_allowed = false
    end
    anti_bruteforce()
    ui.set( ref_yaw_offset, peek_yaw )
    ui.set( ref_body_yaw_offset, body_yaw )
    ui.set( ref_body_yaw, "Static" )
    ui.set( ref_jitter, "Off" )
    ui.set( ref_jitter_slider, 0 )
    peeksok = "off"
end
-- useless, just for testing new offsets
-- jittertestrj = ui.new_slider( luatab[1], luatab[2], "test side jitters", 0, 180, 0, true, ""  ) -- ui.get( jittertestrj )
-- backtestjt = ui.new_slider( luatab[1], luatab[2], "test back jitters", 0, 180, 0, true, "" ) -- ui.get( backtestjt )
function back_jitter( )
    if is_in_range == true then
        ui.set( ref_body_freestanding,  true)
        randomiser_allowed = true
        if is_under_health( ) then
            if data.side == 1 then
                local yaw_offset = -ui.get(cfg.back_jitter_value_2)
                ui.set( ref_yaw_offset, yaw_offset )
                AASTATE_INFO = "DYNAMIC"
            elseif data.side == 2 then
                local yaw_offset = ui.get(cfg.back_jitter_value_2)
                ui.set( ref_yaw_offset, yaw_offset )
                AASTATE_INFO = "DYNAMIC"
            end
        else
            ui.set( ref_yaw_offset, in_yaw )
            AASTATE_INFO = "DYNAMIC"
        end
        AASTATE_INFO = "DYNAMIC"
    elseif is_in_range == false and ePeeking == false then
        ui.set( ref_yaw_offset, out_yaw )
        AASTATE_INFO = "DYNAMIC"
    end
    ui.set( ref_body_yaw, "Jitter" )
    ui.set( ref_jitter, ui.get(cfg.back_jitter_mode) )
    ui.set( ref_jitter_slider, ui.get(cfg.back_jitter_value) )
    peeksok = "off"
end
function static_freestanding( )
    -- Actual anti-aim
    peeksok = "off"
    if is_in_range == true then
        ui.set( ref_body_freestanding,  true)
        randomiser_allowed = true
        ui.set(ref_body_yaw, "Static")
        if data.side == 1 then
            ui.set(ref_body_yaw_offset, static_yaw)
            AASTATE_INFO = "DORMANT"
        elseif data.side == 2 then
            ui.set(ref_body_yaw_offset, static_yaw)
            AASTATE_INFO = "DORMANT"
        end
    end
    if is_in_range == true then
        if is_under_health( ) then
            if data.side == 1 then
                local yaw_offset = -ui.get(cfg.dormants_value_2)
                ui.set( ref_yaw_offset, yaw_offset )
                AASTATE_INFO = "DORMANT"
            elseif data.side == 2 then
                local yaw_offset = ui.get(cfg.dormants_value_2)
                ui.set( ref_yaw_offset, yaw_offset )
                AASTATE_INFO = "DORMANT"
            end
        else
            AASTATE_INFO = "DORMANT"
            ui.set( ref_yaw_offset, in_yaw )
        end
    elseif is_in_range == false and ePeeking == false then
        AASTATE_INFO = "DORMANT"
        ui.set( ref_yaw_offset, out_yaw )
    end
    ui.set( ref_body_yaw, "Jitter" )
    ui.set( ref_jitter, ui.get(cfg.dormants_mode) )
    ui.set( ref_jitter_slider, ui.get(cfg.dormants_value) )
end
function handle_colours_and_alpha( )
    -- these are the colours for each indicator
    mt_r, mt_g, mt_b, mt_a = ui.get( aa.menu_bar_colourpicker ) -- Colour of èå® bar ( text & middle )
    m_r, m_g, m_b, m_a = ui.get( aa.menu_bar_two_colourpicker ) -- Colour of èå® bar ( outside )
    --end
    
    -- pulsating alpha ( yoinked from sigmas lua )
    if ( cur_alpha < min_alpha+2 ) then
        target_alpha = max_alpha
    elseif ( cur_alpha > max_alpha-2 ) then
        target_alpha = min_alpha
    end
    cur_alpha = cur_alpha+( target_alpha-cur_alpha )*speed*( globals.absoluteframetime( )*100 )
    alpha = math.min( 255, cur_alpha )
    -- flashing ç®­å¤´
end
function ind_watermark()
    local x_water, y_water = client.screen_size()
    renderer.text( ui.get(ind.watermarkx), ui.get(ind.watermarky), 	255,255,255 ,200, "d",0, "       yaw - aa extend - build:"..CUR_BUILD)
    renderer.text( ui.get(ind.watermarkx), ui.get(ind.watermarky), 	100 ,149, 237	,255, "d",0, "lele.")
end
function ind_mindmg()
    local x_water2, y_water2 = client.screen_size()
    renderer.text( x_water2/2+5, y_water2/2+5, 255, 255, 255,210, fontstyle,555 , ui.get(ref_mindmg) )
end
marcel = 0
function fake_lags()
    local fake_lag_type = ui.reference("AA", "Fake lag", "Amount")
    local fake_variance = ui.reference("AA", "Fake lag", "Variance")
    local fake_lag = ui.reference("AA", "Fake lag", "Limit")
    
    marcel = marcel + 1
	
    if marcel > 50 then
        marcel = 0
    end
    if includes(ui.get(aa.ext),"Better Fakelag") then
        if not ui.get(aa.fl_max) then
        ui.set(fake_lag, 15)
        ui.set(fake_lag_type, marcel >= 25 and "Dynamic" or "Maximum")
        ui.set(fake_variance, marcel >= 25 and 14 or 0)
        end
    end
        if ui.get(aa.fl_max) and includes(ui.get(aa.ext),"Better Fakelag") then 
            ui.set(fake_lag,15)
            ui.set(fake_lag_type, "Maximum")
            ui.set(fake_variance, 0)
         end
end
local OldChoke = 0
local toDraw4 = 0
local toDraw3 = 0
local toDraw2 = 0
local toDraw1 = 0
local toDraw0 = 0
function fakelag_on_paint(ctx)
    local fake_lag_type = ui.reference("AA", "Fake lag", "Amount")
    client.draw_indicator(ctx ,220,220,220,255, string.format('%i-%i-%i-%i-%i',toDraw4,toDraw3,toDraw2,toDraw1,toDraw0))
end
function flsetup_command(cmd)
	if cmd.chokedcommands < OldChoke then --sent
		toDraw0 = toDraw1
		toDraw1 = toDraw2
		toDraw2 = toDraw3
		toDraw3 = toDraw4
		toDraw4 = OldChoke
	end
	
	OldChoke = cmd.chokedcommands
end
function may_free()
    if includes(ui.get(aa.ext),"Freestanding On Key") and ui.get(aa.free_checkbox) and not can_enemy_hit_head( enemyclosesttocrosshair ) and not in_air() and not ui.get( ref_fakeduck ) and ePeeking == false then
        ui.set( ref_freestanding, "Default")
        ui.set( ref_freestanding_key,"always on")
    else
        ui.set( ref_freestanding, "Default")
        ui.set( ref_freestanding_key,"Toggle")
    end
end
function awp_free()
    local me = entity.get_local_player()
    local weapon_idx = entity.get_player_weapon(me)
    local weapon = entity.get_prop(weapon_idx, "m_iItemDefinitionIndex")
    if weapon == nil then return end
    weapon_name = entity.get_classname(weapon_idx)
    if includes(ui.get(aa.ext),"AWP/SCOUT Freestanding Always on") then
        if weapon_name == "CWeaponAWP" or weapon_name == "CWeaponSSG08" then
            ui.set( ref_freestanding, "Default")
            ui.set( ref_freestanding_key,"always on")
        else
            may_free()
        end
    else
        may_free()
    end
end
function hotkeyslist(ctx)
    local hotkeylist = ui.get(ind.somehotkey)
    if includes(hotkeylist,"Hide Shots") and (ui.get(refs.hs[1]) and ui.get(refs.hs[2])) then
        client.draw_indicator(ctx ,220,220,220,255, string.format("HS"))
    end
    if includes(hotkeylist,"Freestanding") and ui.get(ref_freestanding_key) then
        client.draw_indicator(ctx ,220,220,220,255, string.format("FS"))
    end
    if includes(hotkeylist,"Edge Yaw") and ui.get(ref_edge_yaw) then
        client.draw_indicator(ctx ,220,220,220,255, string.format("ED"))
    end
    if includes(hotkeylist,"Manual AA") and tablegg.m_state ~= 0   then
        if tablegg.m_state == 1 then
        client.draw_indicator(ctx ,220,220,220,255, string.format("LEFT"))
        elseif tablegg.m_state == 2 then
        client.draw_indicator(ctx ,220,220,220,255, string.format("RIGHT"))
        end
    end
    if includes(hotkeylist,"Force Baim") and ui.get(ref_fba_key) then
        client.draw_indicator(ctx ,220,220,220,255, string.format("FB"))
    end
    if includes(hotkeylist,"Force Safe Point") and ui.get(ref_fsp_key) then
        client.draw_indicator(ctx ,220,220,220,255, string.format("FS"))
    end
    if includes(hotkeylist,"Slow Motion") and ui.get(ref_slow_walk_key) and ui.get(ref_slow_walk) then
        client.draw_indicator(ctx ,220,220,220,255, string.format("SW"))
    end
    
    if includes(hotkeylist,"Min DMG") then
        client.draw_indicator(ctx ,220,220,220,255, string.format(ui.get(ref_mindmg)))
    end
end
client.set_event_callback('setup_command', flsetup_command)
function ind_arrow()
    if ui.get(ind.arrow) then
        local w, h = client.screen_size()
        local r, g, b, a = ui.get(ind.indicator_color)
        local r1, g1, b1, a1 = ui.get(ind.manual_inactive_color)
            
    
        local realtime = globals.realtime() % 3
        local distance = (w/2) / 210 * ui.get(ind.indicator_dist)
        local alpha = math.floor(math.sin(realtime * 4) * (a/2-1) + a/2) or a
        -- â¯ â¯ â¯ â¯
    
        renderer.text(w/2 - distance, h / 2 - 1, r1, g1, b1, a1, "+c", 0, "<")
        renderer.text(w/2 + distance, h / 2 - 1, r1, g1, b1, a1, "+c", 0, ">")
        renderer.text(w/2, h / 2 + distance, r1, g1, b1, a1, "+c", 0, "")
    
        if tablegg.m_state == 1 then
             renderer.text(w/2 - distance, h / 2 - 1, r, g, b, a, "+c", 0, "<") 
        end
        if tablegg.m_state == 2 then 
            renderer.text(w/2 + distance, h / 2 - 1, r, g, b, a, "+c", 0, ">") 
        end
        if tablegg.m_state == 3 or m_state == 0 then
             renderer.text(w/2, h / 2 + distance, r, g, b, a, "+c", 0, "") 
            end
      if ui.get(ind.flash) then
        if peeksok == "right" then renderer.text(w/2 - distance-15, h / 2 - 1, r, g, b, a, "+c", 0, "<") end
        if peeksok == "rightalt" then renderer.text(w/2 - distance-15, h / 2 - 1, r1, g1, b1, a1, "+c", 0, "<") end
        if peeksok == "left" then  renderer.text(w/2 + distance+15, h / 2 - 1, r, g, b, a, "+c", 0, ">") end
        if peeksok == "leftalt" then  renderer.text(w/2 + distance+15, h / 2 - 1, r1, g1, b1, a1, "+c", 0, ">") end
      end
    end
    end
    function fon_paint()
        local width, height = client.screen_size()
        local center_width = width/2
        local center_height = height/2
        local local_player = entity.get_local_player()
        if not entity.is_alive(local_player) then return end
        local body_yaw = math.max(-60, math.min(60, round((entity.get_prop(local_player, "m_flPoseParameter", 11) or 0)*120-60+0.5, 1)))
        r, g, b, a =  130, 156, 212, 255
        if ui.get(ind.infoind_2) then
        client_draw_text(c,center_width, center_height+38, 255, 255, 255, 155,"dc-", 0, "AA MODE: "..AASTATE_INFO)
        end
        if ui.get(ind.infoind_3) then
        client_draw_text(c,center_width, center_height+45, 255, 255, 255, 155,"dc-", 0, AA_BR)
        end
        if ui.get(ind.infoind) then
            if not is_under_health() then
            client_draw_text(c,center_width+26, center_height+21, 255, 255, 255, 155,"d-", 0, body_yaw.."Â°")
            else
            client_draw_text(c,center_width+26, center_height+21, 			255,218,185, 155,"d-", 0, body_yaw.."Â°")
            end
        end
        if ui.get(ind.barind) then
        renderer.gradient(center_width, center_height+32, -body_yaw*1.5, 1, r, g, b, a, 0, 0, 0, 0, true)
        renderer.gradient(center_width, center_height+32, body_yaw*1.5, 1, r, g, b, a, 0, 0, 0, 0, true)
        end
    end
local marcel = 0
function handle_main_anti_aim( )
    awp_free()
        local scrsize_x, scrsize_y = client_screensize( )
        local center_x, center_y = scrsize_x/2, scrsize_y/2
        local scrleft_x, scrleft_y = (( scrsize_x-scrsize_x ) +1 ), (( scrsize_y-scrsize_y ) +1 )
        if includes(ui.get(aa.ext),"Edge Yaw On Key") and ui.get(aa.edge_yaw_checkbox) and not can_enemy_hit_head( enemyclosesttocrosshair ) and not in_air() and ePeeking == false then
            ui_set( ref_edge_yaw, true )
        else
            ui_set( ref_edge_yaw, false )
        end
        local fake_lag_type = ui.reference("AA", "Fake lag", "Amount")
        local fake_variance = ui.reference("AA", "Fake lag", "Variance")
	    local fake_lag = ui.reference("AA", "Fake lag", "Limit")
        if ui.get( aa.jitter_checkbox ) and ui.get( aa.enable_checkbox ) == true then
            
            local inverter_enemy        = { }
            local old_inverter_enemy    = { }
            for i = 1 , 66 do
                inverter_enemy[i]       = 1
                old_inverter_enemy[i]   = 1
            end
            local current_inverter      = 1
            local current_old_inverter  = 1
            local closest_fov           = 100000
            local needed_player         = -1
            local player_list           = entity.get_players( true )
            local x,y,z                 = client.eye_position( )
            local eye_pos               = Vector3( x, y, z )
            x,y,z                       = client.camera_angles( )
            local cam_angles            = Vector3( x, y, z )
            local is_local_alive        = entity.is_alive( entity.get_local_player( ) )
            for i = 1 , #player_list do
                player                  = player_list[ i ]
                if not entity.is_dormant( player ) and entity.is_alive( player ) then
                    if is_enemy_peeking( player ) or is_local_peeking_enemy( player ) then
                        last_time_peeked        = globals.curtime( )
                        local enemy_head_pos    = Vector3( entity.hitbox_position( player, 0 ) )
                        local current_fov       = get_FOV( cam_angles,eye_pos, enemy_head_pos )
                        --client.log(current_fov)
                        if current_fov < closest_fov then
                            closest_fov         = current_fov
                            needed_player       = player
                        end
                    end
                end
            end
            if best_player ~= nil and entity.is_alive( best_player ) and entity.is_enemy( best_player ) and not entity.is_dormant( best_player ) then
                needed_player   = best_player
            else
                best_player     = nil
            end
            
            if needed_player ~= -1 and is_local_alive then
                current_inverter        = inverter_enemy[ needed_player ]
                current_old_inverter    = old_inverter_enemy[ needed_player ]
                --change_aa(needed_player)
                local color_left = data.side == 2
                local color_right = not color_left
                if not entity.is_dormant( player ) and entity.is_alive( player ) and ePeeking == false then
                    if ui.get( aa.jitter_checkbox) and ( ( is_enemy_peeking( player ) or is_local_peeking_enemy( player ) ) ) == true and is_in_range == true and not in_air( ) then
                        if color_right then
                            right_static( )    
                        else
                           
                            left_static( )
                        end
                    else
                        if ui.get( aa.enable_checkbox ) and is_in_range == true and ePeeking == false and not in_air( ) then
                            if color_right then
                             
                                right_static_alternative( )
                            else
                              
                                
                                left_static_alternative( )
                            end
                        elseif ePeeking == false and not in_air( ) then
                            back_jitter( )
                        end
                    end
                end
            else
                if ePeeking == false and not in_air( ) then
                    static_freestanding( )
                end
            end
        end
end
local function draw_container(x, y, w, h, header, a)
    local c = {10, 60, 40, 40, 40, 60, 20}
    for i = 0,6,1 do
        renderer.rectangle(x+i, y+i, w-(i*2), h-(i*2), c[i+1], c[i+1], c[i+1], a)
    end
    if header then
        local x_inner, y_inner = x+7, y+7
        local w_inner = w-14
        renderer.gradient(x_inner, y_inner, math.floor(w_inner/2), 1, m_r, m_g, m_b, a, mt_r, mt_g, mt_b, a, true)
        renderer.gradient(x_inner+math.floor(w_inner/2), y_inner, math.ceil(w_inner/2), 1, mt_r, mt_g, mt_b, a, m_r, m_g, m_b, a, true)
        local a_lower = a*0.2
        renderer.gradient(x_inner, y_inner+1, math_floor(w_inner/2), 1, 59, 175, 222, a_lower, 202, 70, 205, a_lower, true)
        renderer.gradient(x_inner+math.floor(w_inner/2), y_inner+1, math.ceil(w_inner/2), 1, 202, 70, 205, a_lower, 201, 227, 58, a_lower, true)
    end
end
function banepa_menu_additions( )
    local scrsize_x, scrsize_y = client_screensize( )
    local center_x, center_y = scrsize_x/2, scrsize_y/2
    local scrleft_x, scrleft_y = (( scrsize_x-scrsize_x ) +1 ), (( scrsize_y-scrsize_y ) +1 )
    local c = {10, 60, 40, 40, 40, 60, 20}
    local menu_x, menu_y = ui.menu_position()
    local mouse_x, mouse_y = ui.mouse_position()
    local menu_w, menu_h = ui.menu_size()
    local h = 54
    local conmid_x, conmid_y = (menu_x + (menu_w/2)), menu_y - h/2 -- this gets the middle of the èå®
    if ui.is_menu_open() then -- checks if the èå® is open
        -- this draws the box above the èå®
        draw_container(menu_x, menu_y - h, menu_w, h - 4,true, 255)
        client_draw_text( c, conmid_x, conmid_y - 2, mt_r, mt_g, mt_b, mt_a, "bc+", 0, "LELEYAW" )
        client_draw_text( c, (menu_x) + 90, conmid_y + 6, 255, 255, 255, 255, "bc-", 0, " update: " .. CUR_BUILD .. " coder:ggg" )
        -- end of drawing box and draws text inside the box
    end
end
local function gradient_text(r1, g1, b1, a1, r2, g2, b2, a2, text)
	local output = ''
	local len = #text-1
	local rinc = (r2 - r1) / len
	local ginc = (g2 - g1) / len
	local binc = (b2 - b1) / len
	local ainc = (a2 - a1) / len
	for i=1, len+1 do
		output = output .. ('\a%02x%02x%02x%02x%s'):format(r1, g1, b1, a1, text:sub(i, i))
		r1 = r1 + rinc
		g1 = g1 + ginc
		b1 = b1 + binc
		a1 = a1 + ainc
	end
	return output
end
local ind_alpha = 255
local ind_flip = 1
client.set_event_callback("paint", function()
    if ui.get(ind.desync_text) and ui.get(ind.aaind) then
    cac_r, cac_g, cac_b, cac_a = ui.get( ind.desync_text_colourpicker )
    shake_1,shake_2,shake_3,shake_4 = ui.get( ind.shake_colorpicker )
    function round(a,b)local c=1^(b or 0)return math.floor(a*c)/c end
    local fake_yaw = math.max(-60, math.min(60, round((entity.get_prop(entity.get_local_player(), "m_flPoseParameter", 11) or 0)*120-60+0.5, 1)))
    improv = gradient_text(55, 177, 218, ind_alpha, 255, 255, 255, cac_a, 'improv')
    ements = gradient_text(204, 84, 192, ind_alpha, 255, 255, 255, cac_a, 'ements')
    improv1 = gradient_text(255, 255, 255, ind_alpha, shake_1,shake_2,shake_3, cac_a, '        LELE')
    ements1 = gradient_text(shake_1,shake_2,shake_3, ind_alpha, 255, 255, 255, cac_a, 'YAW     ')
    spacer_scale = 25
	changer1 = "cb"
    local x,y = client.screen_size()
    if ui.get(ind.desync_text) then
        local side_arrow = fake_yaw < 0 and -60 or 60
				if side_arrow == -60 then
                renderer.text(x/2 - string.len(improv)/2 + 8.5, y/2 + spacer_scale, cac_r, cac_g, cac_b, cac_a, changer1, nil, improv1)
                renderer.text(x/2 + string.len(ements)/2 - 8.5, y/2 + spacer_scale, cac_r, cac_g, cac_b, cac_a, changer1, nil, "YAW     ")
            elseif side_arrow == 60 then
                renderer.text(x/2 - string.len(improv)/2 + 8.5, y/2 + spacer_scale, cac_r, cac_g, cac_b, cac_a, changer1, nil, "        LELE	")
                renderer.text(x/2 + string.len(ements)/2 - 8.5, y/2 + spacer_scale, cac_r, cac_g, cac_b, cac_a, changer1, nil, ements1)
            end
	end
	        spacer_scale = spacer_scale + 5
end
end)
function handle_dt()
    if ui.get(dt.dt_enable) then
        ui.set(sv_maxusrcmdprocessticks, ui.get(dt.dt_tick) )
    end
end
-- this is the paint function
local on_paint = function( )
    if ui.get( aa.configure_combobox ) == "Anti-aim" then
        menu_callback( true, true )
    end
    bind_system:update( )
    -- this is for low delta changing
    if ui.get( aa.enable_checkbox ) and ui.get( aa.jitter_checkbox ) and allow_reset_hit == true then
        on_hit_low_delta( )
    end
    -- end of low delta change
    banepa_menu_additions( )
    handle_colours_and_alpha( )
    handle_main_anti_aim( )
    handle_dt()
    if ui.get(ind.watermark) then
    ind_watermark()
    end
    if ui.get(ind.dmg_vis) then
    ind_mindmg()
    end
    
    ind_arrow()
    if ui.get(ind.aaind) then
        fon_paint()
    end
    if ui.get(ind.fakelags) then
        fakelag_on_paint()
    end
    hotkeyslist()
    fake_lags()
end
local function modify_velocity(cmd, goalspeed)
	if goalspeed <= 0 then
		return
	end
	
	local minimalspeed = math_sqrt((cmd.forwardmove * cmd.forwardmove) + (cmd.sidemove * cmd.sidemove))
	
	if minimalspeed <= 0 then
		return
	end
	
	if cmd.in_duck == 1 then
		goalspeed = goalspeed * 2.94117647 -- wooo cool magic number
	end
	
	if minimalspeed <= goalspeed then
		return
	end
	
	local speedfactor = goalspeed / minimalspeed
	cmd.forwardmove = cmd.forwardmove * speedfactor
	cmd.sidemove = cmd.sidemove * speedfactor
end
local function on_setup_cmd(cmd)	
	local checkbox = ui.get(checkbox_reference)
	local hotkey = ui.get(hotkey_reference)
	local limit = ui.get(aa.limit_reference)
	
	if limit >= 57 then
		return
	end
	
	if checkbox and hotkey then
		modify_velocity(cmd, limit)
	end
end
client.set_event_callback('setup_command', on_setup_cmd)
ui.set(ind.watermark,true)
function preset_r()
    if ui.get(cfg.labelcfg) then
        preset_cfg()
    end
end
local labelnew2 = ui.new_label( luatab[1], luatab[2], "<------------------------------------------------------->" )
local labelnew24444 = ui.new_label( luatab[1], luatab[2], "\n" )
function menu_update()
    ui.set_visible( aa.manual_state, false )
    ui.set_visible( aa.unhide_checkbox, false )
    -- Get if the anti-aim script is enabled and determine if we should set or unset the callbacks
    enabled = true
    local callback = enabled and client.set_event_callback or client.unset_event_callback
    -- Update the anti-aim elements visibility
   
    if ui.get( aa.configure_combobox ) == "Anti-aim" and ui.get( aa.enable_checkbox ) then
        ui.set_visible( aa.jitter_checkbox,enabled )
        ui.set_visible( aa.ext,enabled)
        ui.set_visible(aa.labelnew4,enabled)
        if includes(ui.get(aa.ext),"Manual AA") then
        ui.set_visible( aa.manual_right_hotkey, enabled )
        ui.set_visible( aa.manual_back_hotkey, enabled )
        ui.set_visible( aa.manual_left_hotkey, enabled )
        else
            ui.set_visible( aa.manual_right_hotkey, not enabled )
            ui.set_visible( aa.manual_back_hotkey, not enabled )
            ui.set_visible( aa.manual_left_hotkey, not enabled )
        end
        if includes(ui.get(aa.ext),"Better Fakelag") then
            ui.set_visible( aa.fl_max,enabled)
        else
            ui.set_visible( aa.fl_max,not enabled)
        end
        if includes(ui.get(aa.ext),"Legit AA on E") then
        ui.set_visible( aa.legit_aa_hotkey, enabled )
        else
            ui.set_visible( aa.legit_aa_hotkey, not enabled )
        end
        if includes(ui.get(aa.ext),"Edge Yaw On Key") then
            ui.set_visible( aa.edge_yaw_checkbox, enabled )
        else
            ui.set_visible( aa.edge_yaw_checkbox,not enabled )
        end
        if includes(ui.get(aa.ext),"Freestanding On Key") then
        ui.set_visible( aa.free_checkbox,enabled)
        else
            ui.set_visible( aa.free_checkbox,not enabled)
        end
    else
        ui.set_visible( aa.fl_max,not enabled)
        ui.set_visible(aa.labelnew4,not enabled)
        ui.set_visible( aa.ext,not enabled)
        ui.set_visible( aa.jitter_checkbox, not enabled )
        
        ui.set_visible( aa.manual_right_hotkey, not enabled )
        ui.set_visible( aa.manual_back_hotkey, not enabled )
        ui.set_visible( aa.manual_left_hotkey, not enabled )
        ui.set_visible( aa.legit_aa_hotkey, not enabled )
        ui.set_visible( aa.edge_yaw_checkbox, not enabled )
        ui.set_visible( aa.free_checkbox,not enabled)
    end
    if ui.get( aa.configure_combobox ) == "Others." and ui.get( aa.enable_checkbox ) then
        ui.set_visible( dt.ideal_tick, enabled )
        if ui.get(dt.ideal_tick) then
        ui.set_visible( dt.ideal_tick_key, enabled )
        ui.set_visible( dt.ideal_tick_weps, enabled )
        else
        ui.set_visible( dt.ideal_tick_key, not enabled )
        ui.set_visible( dt.ideal_tick_weps, not enabled )
        end   
        ui.set_visible( dt.dt_switcher, enabled )
        if ui.get(dt.dt_enable) then
        ui.set_visible( dt.dt_tick , enabled)
        else
        ui.set_visible( dt.dt_tick,not enabled)
        end
        ui.set_visible( dt.dt_enable , enabled)
    else
        ui.set_visible( dt.ideal_tick, not enabled )
        ui.set_visible( dt.ideal_tick_key, not enabled )
        ui.set_visible( dt.ideal_tick_weps, not enabled )
        ui.set_visible( dt.dt_switcher, not enabled )
        ui.set_visible( dt.dt_tick , not enabled)
        ui.set_visible( dt.dt_enable ,not enabled)
    end
   
    if ui.get( aa.configure_combobox ) == "Indicator" and ui.get( aa.enable_checkbox ) then
        if ui.get(ind.watermark) then
            ui.set_visible( ind.watermarkx, enabled )
            ui.set_visible( ind.watermarky, enabled )
        else
            ui.set_visible( ind.watermarkx, not enabled )
            ui.set_visible( ind.watermarky,not enabled )
        end
        ui.set_visible( ind.watermark, enabled )
        ui.set_visible( ind.somehotkey,enabled )
        ui.set_visible( ind.dmg_vis, enabled )
        ui.set_visible( aa.menu_bar_colourpicker, enabled)
        ui.set_visible( aa.menu_bar_label, enabled)
        ui.set_visible( aa.menu_bar_two_colourpicker, enabled)
        ui.set_visible( aa.menu_bar_two_label, enabled)
        ui.set_visible(ind.arrow,enabled)
        if ui.get(ind.arrow) then
        ui.set_visible(ind.label_c_1,enabled)
        ui.set_visible(ind.label_c_2,enabled)
        ui.set_visible(ind.indicator_color,enabled)
        ui.set_visible(ind.indicator_dist,enabled)
        ui.set_visible(ind.manual_inactive_color,enabled)
        ui.set_visible(ind.flash,enabled)
        else
            
            ui.set_visible(ind.label_c_1,not enabled)
            ui.set_visible(ind.label_c_2,not enabled)
            ui.set_visible(ind.indicator_color,not enabled)
            ui.set_visible(ind.indicator_dist,not enabled)
            ui.set_visible(ind.manual_inactive_color,not enabled)
            ui.set_visible(ind.flash,not enabled)
        end
        ui.set_visible(ind.aaind,enabled)
        if ui.get(ind.aaind) then
            ui.set_visible(ind.infoind_2,enabled)
            ui.set_visible(ind.infoind_3,enabled)
            ui.set_visible(ind.infoind,enabled)
            ui.set_visible(ind.barind,enabled)
            ui.set_visible(ind.desync_text,enabled)
            if ui.get(ind.desync_text) then
                ui.set_visible(ind.shake_,enabled)
                ui.set_visible(ind.shake_colorpicker,enabled)
            else
                ui.set_visible(ind.shake_,not enabled)
                ui.set_visible(ind.shake_colorpicker,not enabled)
            end
            ui.set_visible(ind.desync_text_colourpicker,enabled)
        else
            
            ui.set_visible(ind.infoind,not enabled)
            ui.set_visible(ind.infoind_2,not enabled)
            ui.set_visible(ind.infoind_3,not enabled)
            ui.set_visible(ind.barind,not enabled)
            
            ui.set_visible(ind.desync_text,not enabled)
            ui.set_visible(ind.desync_text_colourpicker,not enabled)
            ui.set_visible(ind.shake_,not enabled)
            ui.set_visible(ind.shake_colorpicker,not enabled)
        end
        ui.set_visible(ind.fakelags,enabled)
    else
        ui.set_visible(ind.infoind_2,not enabled)
        ui.set_visible(ind.infoind_3,not enabled)
        ui.set_visible(ind.desync_text,not enabled)
        ui.set_visible(ind.desync_text_colourpicker,not enabled)
        ui.set_visible(ind.shake_,not enabled)
        ui.set_visible(ind.shake_colorpicker,not enabled)
        ui.set_visible( ind.watermarkx, not enabled )
        ui.set_visible( ind.watermarky,not enabled )
        ui.set_visible(ind.flash,not enabled)
        ui.set_visible(ind.fakelags,not enabled)
        ui.set_visible(ind.infoind,not enabled)
        ui.set_visible(ind.barind,not enabled)
        ui.set_visible( ind.watermark, not enabled )
        ui.set_visible( ind.somehotkey, not enabled )
        ui.set_visible( ind.dmg_vis, not enabled )
        ui.set_visible( aa.menu_bar_colourpicker,not enabled)
        ui.set_visible( aa.menu_bar_label,not enabled)
        ui.set_visible( aa.menu_bar_two_colourpicker,not enabled)
        ui.set_visible( aa.menu_bar_two_label,not enabled)
        ui.set_visible(ind.arrow,not enabled)
        ui.set_visible(ind.label_c_1,not enabled)
        ui.set_visible(ind.indicator_color,not enabled)
        ui.set_visible(ind.indicator_dist,not enabled)
        ui.set_visible(ind.label_c_2,not enabled)
        ui.set_visible(ind.manual_inactive_color,not enabled)
        ui.set_visible(ind.aaind,not enabled)
    end
    
    
    
    if not ui.get( aa.enable_checkbox ) then
        ui.set_visible(aa.labelnew4,not enabled)
        ui.set_visible( aa.limit_reference, not enabled )
        ui.set_visible( aa.legit_aa_hotkey, not enabled )
        ui.set_visible( aa.jitter_checkbox, not enabled )
        ui.set_visible( aa.unhide_checkbox, not enabled )
        ui.set_visible( aa.edge_yaw_checkbox, not enabled )
        ui.set_visible( aa.free_checkbox,not enabled)   
    end
    if ui.get( aa.configure_combobox ) == "Configuration" then
        if includes(ui.get(aa.ext),"Slow Motion Speed") then
            ui.set_visible( aa.limit_reference, enabled )
            else
                ui.set_visible( aa.limit_reference, not enabled )
            end
            if includes(ui.get(aa.ext),"* Smart Yaw Base") then
                ui.set_visible( aa.smart_yaw_base_slider , enabled)
                else
                ui.set_visible( aa.smart_yaw_base_slider , not enabled)
                end
        ui.set_visible(cfg.labelcfg,true)
        if ui.get(cfg.labelcfg) then
            ui.set_visible(cfg.presets,true)
        else
            ui.set_visible(cfg.presets,false)
        end
        ui.set_visible(cfg.defaults,true)
        ui.set_visible(cfg.fake_value_dormant1,true)
        ui.set_visible(cfg.fake_value_dormant2,true)
        ui.set_visible(cfg.fake_value_sw1,true)
        ui.set_visible(cfg.fake_value_sw2,true)
        ui.set_visible(cfg.peeks,true)
        ui.set_visible(cfg.left_peek_body_yaw,true)
        ui.set_visible(cfg.left_peek_yaw_jitter_mode,true)
        ui.set_visible(cfg.left_peek_yaw_jitter_value,true)
        ui.set_visible(cfg.left_peek_body_yaw_after,true)
        ui.set_visible(cfg.left_peek_yaw_danger,true)
        ui.set_visible(cfg.left_peek_yaw_safe,true)
        ui.set_visible(cfg.right_peek_body_yaw,true)
        ui.set_visible(cfg.right_peek_yaw_jitter_mode,true)
        ui.set_visible(cfg.right_peek_yaw_jitter_value,true)
        ui.set_visible(cfg.right_peek_body_yaw_after,true)
        ui.set_visible(cfg.right_peek_yaw_danger,true)
        ui.set_visible(cfg.right_peek_yaw_safe,true)
        ui.set_visible(cfg.dangerhealth,true)
        ui.set_visible(cfg.d_d,true)
        ui.set_visible(cfg.back_jitter_mode,true)
        ui.set_visible(cfg.back_jitter_value,true)
        ui.set_visible(cfg.back_jitter_value_2,true)
        ui.set_visible(cfg.dormants_value_2,true)
        ui.set_visible(cfg.dormants_mode,true)
        ui.set_visible(cfg.dormants_value,true)
        ui.set_visible(cfg.air_air,true)
        ui.set_visible(cfg.air_air2,true)
        ui.set_visible(cfg.in_air_value_dt_1,true)
        ui.set_visible(cfg.in_air_value_dt_2,true)
        ui.set_visible(cfg.in_air_value_dt_3,true)
        ui.set_visible(cfg.in_air_value_dt_f,true)
        ui.set_visible(cfg.in_air_value_nodt_1,true)
        ui.set_visible(cfg.in_air_value_nodt_2,true)
        ui.set_visible(cfg.in_air_value_nodt_3,true)
        ui.set_visible(cfg.in_air_value_nodt_f,true)
    else
        ui.set_visible(cfg.back_jitter_value_2,false)
        ui.set_visible(cfg.dormants_value_2,false)
        ui.set_visible(cfg.air_air2,false)
        ui.set_visible(cfg.presets,false)
        ui.set_visible( aa.smart_yaw_base_slider ,not enabled)
        ui.set_visible(cfg.labelcfg,false)
        ui.set_visible(cfg.defaults,false)
        ui.set_visible(cfg.fake_value_dormant1,false)
        ui.set_visible(cfg.fake_value_dormant2,false)
        ui.set_visible(cfg.fake_value_sw1,false)
        ui.set_visible(cfg.fake_value_sw2,false)
        ui.set_visible(cfg.peeks,false)
        ui.set_visible(cfg.left_peek_body_yaw,false)
        ui.set_visible(cfg.left_peek_yaw_jitter_mode,false)
        ui.set_visible(cfg.left_peek_yaw_jitter_value,false)
        ui.set_visible(cfg.left_peek_body_yaw_after,false)
        ui.set_visible(cfg.left_peek_yaw_danger,false)
        ui.set_visible(cfg.left_peek_yaw_safe,false)
        ui.set_visible(cfg.right_peek_body_yaw,false)
        ui.set_visible(cfg.right_peek_yaw_jitter_mode,false)
        ui.set_visible(cfg.right_peek_yaw_jitter_value,false)
        ui.set_visible(cfg.right_peek_body_yaw_after,false)
        ui.set_visible(cfg.right_peek_yaw_danger,false)
        ui.set_visible(cfg.right_peek_yaw_safe,false)
        ui.set_visible(cfg.dangerhealth,false)
        ui.set_visible(cfg.d_d,false)
        ui.set_visible(cfg.back_jitter_mode,false)
        ui.set_visible(cfg.back_jitter_value,false)
        ui.set_visible(cfg.dormants_mode,false)
        ui.set_visible(cfg.dormants_value,false)
        ui.set_visible(cfg.air_air,false)
        ui.set_visible(cfg.in_air_value_dt_1,false)
        ui.set_visible(cfg.in_air_value_dt_2,false)
        ui.set_visible(cfg.in_air_value_dt_3,false)
        ui.set_visible(cfg.in_air_value_dt_f,false)
        ui.set_visible(cfg.in_air_value_nodt_1,false)
        ui.set_visible(cfg.in_air_value_nodt_2,false)
        ui.set_visible(cfg.in_air_value_nodt_3,false)
        ui.set_visible(cfg.in_air_value_nodt_f,false)
        ui.set_visible( aa.limit_reference, not enabled )
    end
end
-- callback variable
local callback = client.set_event_callback or client.unset_event_callback
-- register / unregister our callbacks
client.set_event_callback( "setup_command", on_setup_command )
client.set_event_callback( "run_command", on_run_command )
client.set_event_callback( "paint", on_paint )
client.set_event_callback( "paint", preset_r )
client.set_event_callback( "bullet_impact", on_bullet_impact )
ui.set_callback(aa.configure_combobox,menu_update)
ui.set_callback(aa.enable_checkbox,menu_update)
ui.set_callback(aa.ext,menu_update)
ui.set_callback(ind.aaind,menu_update)
ui.set_callback(ind.arrow,menu_update)
ui.set_callback(dt.dt_enable,menu_update)
ui.set_callback(dt.ideal_tick,menu_update)
ui.set_callback(ind.desync_text,menu_update)
ui.set_callback(cfg.labelcfg,preset_r)  
client.set_event_callback( "paint", menu_update )
menu_update()
preset_cfg()



 