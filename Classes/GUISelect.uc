//================================================================
// ucGUIFramework.GUISelect
// ----------------
// Select box element
// ----------------
// by Chatouille
//================================================================
class GUISelect extends GUIButton;

var Texture2D ArrowTex;

var GUIGroup OptionsGroup;
var array<GUIButton> Options;

var int BaseHeight;
var bool bOpened;
var bool bClosing;

var int SelectedIndex;

var delegate<Changed> OnChanged;

delegate Changed(GUISelect elem);

static function GUISelect CreateSelect(optional GUIGroup _Parent=None, optional int _BaseHeight=24, optional array<String> _Options)
{
	local GUISelect sel;
	local int i;

	sel = new(None) class'GUISelect';
	if ( _Parent != None )
		_Parent.AddChild(sel);

	sel.BaseHeight = _BaseHeight;
	sel.SetPos("_", "_", "_", ""$sel.BaseHeight);

	sel.OptionsGroup = class'GUIGroup'.static.CreateGroup();
	sel.OptionsGroup.SetAlign(ALIGN_CENTER, ALIGN_TOP);
	sel.OptionsGroup.SetPos("50%", "0", "100%", "0");
	sel.OptionsGroup.SetColors(MakeColor(0,0,0,200), MakeColor(255,255,255,230));

    if ( _Options.Length > 0 )
    {
        for ( i=0; i<_Options.Length; i++ )
            sel.AddOption(_Options[i]);
    }

	return sel;
}

function AddOption(String opt, optional int Index=-1, optional String param="")
{
    local GUIButton btn;

    btn = class'GUIButton'.static.CreateButton(OptionsGroup, opt, OnOptionClicked);
    btn.SetTextAlign(ALIGN_LEFT, ALIGN_MIDDLE);
    btn.Texture = None;
    btn.bAutoColor = false;
    btn.OnDraw = DrawOption;
	btn.Data.AddItem(param);

    if ( Index == -1 )
        Index = Options.Length;
    Options.InsertItem(Index, btn);

    for ( Index=Index; Index<Options.Length; Index++ )
    {
        Options[Index].SetPos("0", ""$(Index*BaseHeight), "100%", ""$BaseHeight);
    }

	if ( bOpened )
	{
		OptionsGroup.MoveTo("_", "_", "_", ""$(Options.Length * BaseHeight), 0.3, ANIM_EASE_IN);
	}
}

function RemoveOption(String opt)
{
    local int i;

    for ( i=0; i<Options.Length; i++ )
    {
        if ( Options[i].Text == opt )
        {
            OptionsGroup.RemoveChild(Options[i]);
            Options.Remove(i,1);
            break;
        }
    }

	if ( bOpened )
	{
		OptionsGroup.MoveTo("_", "_", "_", ""$(Options.Length * BaseHeight), 0.3, ANIM_EASE_IN);
	}
}

function SetIndex(int i)
{
    SelectedIndex = i;
    if ( i >= 0 && i < Options.Length )
        Text = Options[i].Text;
    else
        Text = "ERR_INDEX";
}

function SetOption(String opt)
{
    local int i;

    for ( i=0; i<Options.length; i++ )
    {
        if ( Options[i].Text == opt )
        {
            SelectedIndex = i;
            Text = Options[i].Text;
            return;
        }
    }
    SelectedIndex = -1;
    Text = "ERR_OPT";
}

function InternalOnClick(GUIButton elem)
{
    OpenSelect();
}

function OpenSelect()
{
    local int i;

    if ( Options.Length == 0 )
        return;

	OptionsGroup.SetPos("_", "_", "_", ""$BaseHeight);
	OptionsGroup.MoveTo("_", "_", "_", ""$(Options.Length * BaseHeight), 0.1+Options.Length*0.03, ANIM_EASE_IN);
    OptionsGroup.SetAlpha(1.0);

    for ( i=0; i<Options.Length; i++ )
    {
        Options[i].SetAlpha(0.0);
        Options[i].AlphaTo(0.0, (i+1) * 0.03, ANIM_WAIT);
        Options[i].QueueAlpha(1.0, 0.3, ANIM_EASE_IN);
    }

    if ( !bOpened && !bClosing )
        AddChild(OptionsGroup);

    bClosing = false;
    zIndex = 1000;
    bOpened = true;
}

function CloseSelect()
{
    OptionsGroup.AlphaTo(0.0, 0.3, ANIM_EASE_OUT);

    if ( Options.Length > 0 )
    {
        Options[0].SetAlpha(0.0);
    }
 
    bClosing = true;
    zIndex = 0;
    bOpened = false;
}

function GUITick(float dt)
{
    Super.GUITick(dt);

    if ( bClosing && (Options.Length == 0 || OptionsGroup.Alpha.Val == 0) )
    {
        RemoveChild(OptionsGroup);
        bClosing = false;
    }
}

function OnOptionClicked(GUIButton elem)
{
    local int i;

    for ( i=0; i<Options.Length; i++ )
    {
        if ( Options[i] == elem )
        {
            SelectedIndex = i;
            Text = elem.Text;
            OnChanged(Self);
            CloseSelect();
            break;
        }
    }
}

function InternalOnDraw(GUIGroup elem, Canvas C)
{
    local int ArrowSize;

    if ( !bOpened )
    {
        Super.InternalOnDraw(elem, C);

        ArrowSize = Min(BaseHeight - 8, 16);
        if ( TextAlignX == ALIGN_RIGHT )
            C.SetPos(absX + 6, absY + (absH - ArrowSize) / 2);
        else
            C.SetPos(absX + absW - (ArrowSize + 6), absY + (absH - ArrowSize) / 2);

        SetDrawColor(C, BoxColor.Val);
        C.DrawRect(ArrowSize, ArrowSize, ArrowTex);
    }
}

function DrawOption(GUIGroup elem, Canvas C)
{
    local GUIButton btn;

    btn = GUIButton(elem);
    if ( btn.bHover && !btn.bActive )
        btn.SetColors(MakeColor(128,200,255,40), MakeColor(128,200,255,64));
    else
        btn.SetColors(TRANSPARENT, MakeColor(255,255,255,64));

    btn.TextColor = TextColor;
    btn.TextPaddingX = 6;

    btn.InternalOnDraw(btn, C);
}

function Free()
{
	Super.Free();

	if ( OptionsGroup != None )
		OptionsGroup.Free();

	OnChanged = None;
}

defaultproperties
{
    Text=""
    TextAlignX=ALIGN_LEFT
	TextPaddingX=6
    ArrowTex=Texture2D'GUIResources.arrow_down'
    OnClick=InternalOnClick
    BaseHeight=24
	OnChanged=Changed
}
