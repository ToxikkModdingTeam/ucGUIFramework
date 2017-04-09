//================================================================
// ClientConfigMenuManager.BaseConfigInteraction
// ----------------
// Base class for Interaction-based config menus
// ----------------
// by Chatouille
//================================================================
class BaseConfigInteraction extends Interaction;

// defined in defaultproperties
var String ConfigName;
var bool bForceMouse;

// defined at initialization
var GameViewportClient Viewport;
var PlayerController PC;
var GUIRoot MenuRoot;

// variables
var bool bShow;
var String CurrentURL;

function ResetConfig();

function Initialized()
{
    Viewport = GameViewportClient(Outer);
    PC = Viewport.GetPlayerOwner(0).Actor;
    class'ClientConfigMenuManager'.static.FindCCM(PC).AddMenuEntry(ConfigName, OpenMenu);

	MenuRoot = class'GUIRoot'.static.Create(Self, Viewport);
    MenuRoot.SetAlpha(0.0);
    CreateMenuElements(MenuRoot);
    // propagate initial alpha
    MenuRoot.PostTick(0.01);
}

// this is just an example, don't call Super
function CreateMenuElements(GUIRoot Root)
{
    local GUIGroup cont;
    local GUILabel lbl;
    local GUIGroup grp;
    local GUIButton btn;

    cont = new(Self) class'GUIGroup';
	cont.SetPosAuto("center-x:50%; center-y:50%; width:400; height:200");
    cont.SetColors(MakeColor(0,0,0,128), MakeColor(255,64,64,200));
    Root.AddChild(cont);

    lbl = new(Self) class'GUILabel';
    lbl.Text = "Config menu not implemented yet!";
    lbl.SetTextColor(MakeColor(255,64,64,255));
	lbl.SetPosAuto("top:30%; width:100%; height:32");
    lbl.SetTextAlign(ALIGN_CENTER, ALIGN_TOP);
    cont.AddChild(lbl);

    grp = new(Self) class'GUIGroup';
	grp.SetPosAuto("center-x:50%; bottom:100%-16; width:80%; height:32");
    cont.AddChild(grp);

    btn = new(Self) class'GUIButton';
    btn.Text = "Save";
    btn.SetAutoColor(MakeColor(32,200,32,255));
	btn.SetPosAuto("left:0; width:40%; height:100%");
    btn.OnClick = OnClickSave;
    grp.AddChild(btn);

    btn = new(Self) class'GUIButton';
    btn.Text = "Close";
    btn.SetAutoColor(MakeColor(255,64,64,255));
	btn.SetPosAuto("right:100%; width:40%; height:100%");
    btn.OnClick = OnClickClose;
    grp.AddChild(btn);
}

function OpenMenu()
{
    if ( !Viewport.bDisplayHardwareMouseCursor )
    {
        bShow = true;
        Viewport.SetHardwareMouseCursorVisibility(true);
        MenuRoot.AlphaTo(1.0, 0.5, ANIM_EASE_IN);
    }
}

function OnClickSave(GUIButton elem)
{
    SaveOptions();
    CloseMenu();
}

function OnClickClose(GUIButton elem)
{
    CloseMenu();
}

function SaveOptions();

function CloseMenu()
{
    MenuRoot.SetAlpha(0.0);
    bShow = false;
    Viewport.SetHardwareMouseCursorVisibility(false);
}

function ForceCloseMenu()
{
    MenuRoot.SetAlpha(0.0);
    bShow = false;
    Viewport.SetHardwareMouseCursorVisibility(false);
}

event Tick(float dt)
{
    if ( !bShow )
        return;

    // restore mouse if it's gone (caused by respawn...)
    if ( bForceMouse && !Viewport.bDisplayHardwareMouseCursor )
        Viewport.SetHardwareMouseCursorVisibility(true);

	MenuRoot.Tick(dt);
}

event PostRender(Canvas C)
{
    if ( !bShow )
        return;

	// detect travel/seamless/disconnect, and close menu
	if ( Viewport.Outer.TransitionType != TT_None )
	{
		ForceCloseMenu();
		return;
	}

	MenuRoot.PostRender(C);
}

//TODO: MouseScrollDown , MouseScrollUp
function bool OnKey(int ControllerId, name Key, EInputEvent EventType, optional float AmountDepressed=1.0, optional bool bGamepad)
{
    if ( bShow )
    {
        if ( Key == 'Escape' && EventType == IE_Pressed )
        {
            CloseMenu();
            return true;
        }

		return MenuRoot.KeyEvent(Key, EventType);
    }
    return false;
}


/* Used to crash clients on disconnect, but not anymore it seems.
	Also, breaks menus on Seamless Travels, so it's better out I guess...

function NotifyGameSessionEnded()
{
	`Log("[BaseConfigInteraction:" $ String(default.class) $ "] Freeing widgets...");
	if ( MenuRoot != None )
		MenuRoot.Free();
}
*/

function NotifyGameSessionEnded()
{
	Super.NotifyGameSessionEnded();

	if ( bShow) 
		ForceCloseMenu();
}


defaultproperties
{
    ConfigName="Default Config Name"
	bForceMouse=true
    
    OnReceivedNativeInputKey=OnKey
}
