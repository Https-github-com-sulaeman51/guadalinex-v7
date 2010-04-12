% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%
% Panel boot options selector.
%
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -


/fulloptions.option .undef def

/.fulloptions.expert 0 def


% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% Initialise boot options menu.
%
% ( ) ==> ( )
%
/fulloptions.init {
  /xmenu.fulloptions .xm_size array def
  /xmenu xmenu.fulloptions def

  xmenu .xm_current .fulloptions.expert put

  xmenu .xm_list [ /txt_expert_mode ] put

  xmenu .xm_title /txt_other_options put
  xmenu .xm_check 1 put
  xmenu .xm_allselected xmenu .xm_list get length array put
  0 1 xmenu .xm_list get length 1 sub {
    xmenu .xm_allselected get exch false put
  } for

  pmenu.init
} def


% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% Change boot options status.
%
% ( ) ==> ( )
%
/fulloptions.change {
  /xmenu xmenu.fulloptions def

  /fulloptions.option 0 string def

  xmenu .xm_allselected get
  0 1 xmenu .xm_allselected get length 1 sub {
    over over get {
      .undef
      over .fulloptions.expert eq { pop "priority=low" } if
      dup {
	% append new option string
	dup length fulloptions.option length add 1 add string
	/fulloptions.newoption exch def
	dup fulloptions.option "%s %s" fulloptions.newoption sprintf
	fulloptions.option free
	/fulloptions.option fulloptions.newoption def
      } if
      pop
    } if
    pop
  } for
  pop

  fulloptions.option length {
    /fulloptions.option inc
  } {
    /fulloptions.option .undef def
  } ifelse
} def


% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% Update boot options status.
%
% ( ) ==> ( )
%
/fulloptions.update {
  fulloptions.change
  /window.action actRedrawPanel def
  pmenu.update
} def


% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% Show window.
%
% ( ) => ( )
%
/panel.fulloptions {
  "fulloptions" help.setcontext

  window.xmenu
  dup .xmenu xmenu.fulloptions put
  dup .xmenu.change /fulloptions.change put
  dup .xmenu.update /fulloptions.update put
  dup window.init
      window.show
} def


% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% Return width of panel entry.
%
% ( ) => ( width )
%
/panel.fulloptions.width {
  /xmenu xmenu.fulloptions def

  pmenu.width
} def


% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% Redraw panel entry.
%
% ( panel ) => ( )
%
/panel.fulloptions.update {
  /xmenu xmenu.fulloptions def

  pmenu.panel.update
} def
