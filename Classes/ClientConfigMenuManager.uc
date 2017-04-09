//================================================================
// ClientConfigMenuManager.ClientConfigMenuManager
// ----------------
// Interaction-based menu to gather config menus from various mods
// allowing for binding them all to a single keybind (F8)
// ----------------
// by Chatouille
//================================================================
class ClientConfigMenuManager extends BaseConfigInteraction;

var CONST int VERSION;
CONST HEADWIDTH = 700;
CONST HEADHEIGHT = 100;
CONST BTNPADDING_W = 96;
CONST BTNHEIGHT = 38;
CONST BTNMARGIN = 12;

var CONST Name DEFAULT_KEY;
var CONST String COMMAND;

var CONST Texture2D HEADTEX;
var CONST Color HEADCOLOR_BG;
var CONST Color HEADCOLOR_FG;
var CONST byte HEADFONT;
var CONST String TITLE;

var CONST byte MENUFONT;
var CONST Color BTNCOLOR;

struct sCCMEntry
{
	var delegate<OnCCMButtonClick> Callback;
	var GUIButton btn;
};
var array<sCCMEntry> Entries;

var GUIGroup Container;

var bool bWaitForRelease;


delegate OnCCMButtonClick();


function AddMenuEntry(String ConfName, delegate<OnCCMButtonClick> Callback)
{
	local sCCMEntry entry;
	local int i;

	entry.Callback = Callback;

	// sort by name
	for ( i=0; i<Entries.length; i++ )
	{
		if ( Caps(Entries[i].btn.Text) >= Caps(ConfName) )
			break;
	}

	entry.btn = class'GUIButton'.static.CreateButton(Container, ConfName, OnButtonClick);
	entry.btn.TextFont = class'HUD'.static.GetFontSizeIndex(MENUFONT);
	entry.btn.SetAlign(ALIGN_CENTER, ALIGN_TOP);
	entry.btn.SetPos("50%", ""$(HEADHEIGHT + BTNMARGIN + i*(BTNHEIGHT+BTNMARGIN)), "100%", ""$BTNHEIGHT);
	entry.btn.SetAutoColor(BTNCOLOR);

	Entries.InsertItem(i, entry);

	for ( i=i+1; i<Entries.Length; i++ )
	{
		Entries[i].btn.SetPos("_", ""$(HEADHEIGHT + BTNMARGIN + i*(BTNHEIGHT+BTNMARGIN)), "_", "_");
	}
}


function Interaction AddMenuInteraction(class<Interaction> IntClass, optional bool bReturnExisting=true)
{
	local Interaction newInt;
	local int i;

	if ( bReturnExisting )
	{
		for ( i=0; i<PC.Interactions.length; i++ )
		{
			if ( PC.Interactions[i].class == IntClass )
				return PC.Interactions[i];
		}
	}

	newInt = new(Viewport) IntClass;
	Viewport.InsertInteraction(newInt, 0);
	PC.Interactions.InsertItem(0, newInt);
	return newInt;
}


static function ClientConfigMenuManager FindCCM(PlayerController myPC)
{
	local int i;
	local ClientConfigMenuManager newCCM;

	for ( i=0; i<myPC.Interactions.Length; i++ )
	{
		if ( myPC.Interactions[i].IsA('ClientConfigMenuManager') )
		{
			return ClientConfigMenuManager(myPC.Interactions[i]);
		}
	}

	newCCM = new(LocalPlayer(myPC.Player).ViewportClient) default.class;

	// insert in 0 to make sure we are before PlayerInput interaction
	// so we can override mouse click when menu is active
	LocalPlayer(myPC.Player).ViewportClient.InsertInteraction(newCCM, 0);
	myPC.Interactions.InsertItem(0, newCCM);

	return newCCM;
}


static function int GetVersion() { return default.VERSION; }


function Initialized()
{
	Viewport = GameViewportClient(Outer);
	PC = Viewport.GetPlayerOwner(0).Actor;

	PC.PlayerInput.SetBind(DEFAULT_KEY, COMMAND);

	MenuRoot = class'GUIRoot'.static.Create(Self, Viewport);
	MenuRoot.SetAlpha(0.0);
	CreateMenuElements(MenuRoot);
	// propagate initial alpha
	MenuRoot.PostTick(0.01);
}


function CreateMenuElements(GUIRoot Root)
{
	local GUIGroup Head;
	local GUILabel HeadTitle;

	Container = class'GUIGroup'.static.CreateGroup(Root);
	Container.SetAlign(ALIGN_CENTER, ALIGN_MIDDLE);
	Container.SetPos("50%", "50%", "32", "80%");

	Head = class'GUIGroup'.static.CreateGroup(Container);
	Head.Texture = HEADTEX;
	Head.SetColors(HEADCOLOR_BG, Head.BoxColor.Val);
	Head.SetAlign(ALIGN_CENTER, ALIGN_TOP);
	Head.SetPos("50%", "0", ""$HEADWIDTH, ""$HEADHEIGHT);

	HeadTitle = class'GUILabel'.static.CreateLabel(Head, TITLE);
	HeadTitle.TextFont = class'HUD'.static.GetFontSizeIndex(HEADFONT);
	HeadTitle.SetTextColor(HEADCOLOR_FG);
	HeadTitle.SetTextAlign(ALIGN_CENTER, ALIGN_BOTTOM);
	HeadTitle.SetAlign(ALIGN_CENTER, ALIGN_BOTTOM);
	HeadTitle.SetPos("50%", "100%-18", "100%", "100%");
}


event PostRender(Canvas C)
{
	local int i;
	local Vector2D TextSize;
	local int ButtonWidth;

	if ( !bShow )
		return;

	for ( i=0; i<Entries.length; i++ )
	{
		C.Font = Entries[i].btn.TextFont;
		C.TextSize(Entries[i].btn.Text, TextSize.X, TextSize.Y);
		ButtonWidth = Max(TextSize.X + 2*BTNPADDING_W, ButtonWidth);
	}
	Container.SetPos("_", "_", ""$ButtonWidth, "_");

	Super.PostRender(C);
}


exec function CCMOpen()
{
	if ( !bWaitForRelease )
	{
		OpenMenu();
		bWaitForRelease = true;
	}
}


exec function CCMClose()
{
	if ( bShow )
		CloseMenu();

	bWaitForRelease = false;
}


exec function CCMToggle()
{
	if ( bShow )
		OpenMenu();
	else
		CloseMenu();
}


function OnButtonClick(GUIButton btn)
{
	local int i;

	for ( i=0; i<Entries.length; i++ )
	{
		if ( Entries[i].btn == btn )
		{
			CloseMenu();
			CallCallback(Entries[i].Callback);
			return;
		}
	}
}


function CallCallback(delegate<OnCCMButtonClick> d) { d(); }


/* Used to crash clients on disconnect, but not anymore it seems.
	Also, breaks menus on Seamless Travels, so it's better out I guess...

function NotifyGameSessionEnded()
{
	Super.NotifyGameSessionEnded();

	while ( Entries.Length > 0 )
	{
		Entries[0].Callback = None;
		Entries.Remove(0,1);
	}
}
*/


defaultproperties
{
	VERSION=1

	DEFAULT_KEY="F8"
	COMMAND="CCMOpen | OnRelease CCMClose"

	HEADTEX=Texture2D'JW_LightEffects.Lensflares.Material.T_GEN_Skydome_LF_Ring'
	HEADCOLOR_BG=(R=0,G=0,B=0,A=128)
	HEADCOLOR_FG=(R=255,G=160,B=0,A=220)
	HEADFONT=2
	TITLE="- Mod Config Menus Manager -"
	MENUFONT=1
	BTNCOLOR=(R=180,G=220,B=255,A=230)
}
