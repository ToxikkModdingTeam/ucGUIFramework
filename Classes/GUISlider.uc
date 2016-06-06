//================================================================
// ucGUIFramework.GUISlider
// ----------------
// Slider element
// ----------------
// by Chatouille
//================================================================
class GUISlider extends GUIGroup;

var float Value;
var float ValueMin;
var float ValueMax;

var int ShowDigits;

var GUIButton Bar, BarL, BarR;
var GUIButton Cursor;
var GUILabel Label;

var Texture2D BarTex;
var Texture2D LBarTex;
var Texture2D RBarTex;
var int BarHeight;
var int MinWidth;
var Texture2D CursorTex;
var int CursorWidth;
var int CursorHeight;

var delegate<Changing> OnChanging;
var delegate<Changed> OnChanged;

delegate Changing(GUISlider elem);
delegate Changed(GUISlider elem);

static function GUISlider CreateSlider(optional GUIGroup _Parent=None, optional float _Val=50, optional float _ValMin=0, optional float _ValMax=100)
{
	local GUISlider s;
	s = new(None) class'GUISlider';
	if ( _Parent != None )
		_Parent.AddChild(s);

	s.Bar = class'GUIButton'.static.CreateButton(s, "");
	s.Bar.SetAlign(ALIGN_CENTER, ALIGN_MIDDLE);
	s.Bar.SetPos("50%", "50%", "100%-8", ""$s.BarHeight);
	s.Bar.Texture = s.BarTex;
	s.Bar.bAutoColor = false;
	s.Bar.OnDraw = s.SkipDraw;
	s.Bar.OnLeftMouse = s.InternalOnLeftMouse;
	s.Bar.OnHold = s.InternalOnHold;

	s.BarL = class'GUIButton'.static.CreateButton(s, "");
	s.BarL.SetAlign(ALIGN_LEFT, ALIGN_MIDDLE);
	s.BarL.SetPos("0", "50%", "4", ""$s.BarHeight);
	s.BarL.Texture = s.LBarTex;
	s.BarL.bAutoColor = false;
	s.BarL.OnDraw = s.SkipDraw;
	s.BarL.OnLeftMouse = s.InternalOnLeftMouse;
	s.BarL.OnHold = s.InternalOnHold;

	s.BarR = class'GUIButton'.static.CreateButton(s, "");
	s.BarR.SetAlign(ALIGN_RIGHT, ALIGN_MIDDLE);
	s.BarR.SetPos("100%", "50%", "4", ""$s.BarHeight);
	s.BarR.Texture = s.RBarTex;
	s.BarR.bAutoColor = false;
	s.BarR.OnDraw = s.SkipDraw;
	s.BarR.OnLeftMouse = s.InternalOnLeftMouse;
	s.BarR.OnHold = s.InternalOnHold;

	s.Cursor = class'GUIButton'.static.CreateButton(s, "");
	s.Cursor.SetAlign(ALIGN_CENTER, ALIGN_MIDDLE);
	s.Cursor.SetPos("_", "50%", ""$s.CursorWidth, ""$s.CursorHeight);
	s.Cursor.Texture = s.CursorTex;
	s.Cursor.bAutoColor = false;
	s.Cursor.OnDraw = s.SkipDraw;
	s.Cursor.OnLeftMouse = s.InternalOnLeftMouse;
	s.Cursor.OnHold = s.InternalOnHold;

	s.Label = class'GUILabel'.static.CreateLabel(s);
	s.Label.SetPos("0", "0", "100%", "100%");
	s.Label.SetTextAlign(ALIGN_CENTER, ALIGN_TOP);
	s.Label.TextFont = class'HUD'.static.GetFontSizeIndex(0);

	s.ValueMin = _ValMin;
	s.ValueMax = _ValMax;
	s.SetValue(_Val);
	return s;
}

function SetNumDigits(int newNum)
{
    ShowDigits = newNum;
    Update();
}

function SetValue(float newVal)
{
    Value = newVal;
    Update();
}

function InternalOnLeftMouse(GUIGroup elem, bool bDown)
{
    GUIButton(elem).InternalOnLeftMouse(elem, bDown);

    if ( bDown )
        InternalOnHold(elem);
    else
        OnChanged(Self);
}

function InternalOnHold(GUIGroup elem)
{
    Value = ValueMin + FClamp( (Root.MousePos.X - Bar.absX) / Bar.absW, 0.0, 1.0) * (ValueMax - ValueMin);
    Update();
    OnChanging(Self);
}

function Update()
{
    local float DisplayVal;

	Cursor.SetPos((100.0 * (Value - ValueMin) / (ValueMax - ValueMin)) $ "%", "_", "_", "_");

    DisplayVal = float(round(Value*(10**ShowDigits))) / (10**ShowDigits);
    Label.Text = Left(""$DisplayVal, Instr(DisplayVal, ".")+1+ShowDigits);
}

function InternalOnDraw(GUIGroup elem, Canvas C)
{
    local bool bHover, bActive;

    Super.InternalOnDraw(elem, C);

    bHover = (Bar.bHover || BarL.bHover || BarR.bHover);
    bActive = (Bar.bActive || BarL.bActive || BarR.bActive);
    if ( bHover && bActive )
        Bar.SetColors(MakeColor(128,200,230,255), TRANSPARENT);
    else if ( bHover )
        Bar.SetColors(MakeColor(160,230,255,255), TRANSPARENT);
    else
        Bar.SetColors(MakeColor(255,255,255,230), TRANSPARENT);

    BarL.SetColors(Bar.BgColor.Val, TRANSPARENT);
    BarR.SetColors(Bar.BgColor.Val, TRANSPARENT);

    Bar.InternalOnDraw(Bar, C);
    BarL.InternalOnDraw(BarL, C);
    BarR.InternalOnDraw(BarR, C);

    if ( Cursor.bHover && Cursor.bActive )
        Cursor.SetColors(MakeColor(128,200,230,255), TRANSPARENT);
    else if ( Cursor.bHover )
        Cursor.SetColors(MakeColor(160,230,255,255), TRANSPARENT);
    else
        Cursor.SetColors(MakeColor(255,255,255,230), TRANSPARENT);

    Cursor.InternalOnDraw(Cursor, C);
}

function Free()
{
	Super.Free();

	OnChanging = None;
	OnChanged = None;
}

defaultproperties
{
    ShowDigits=1
    BarTex=Texture2D'GUIResources.slider_bar'
    LBarTex=Texture2D'GUIResources.slider_barL'
    RBarTex=Texture2D'GUIResources.slider_barR'
    BarHeight=6
    MinWidth=9
    CursorTex=Texture2D'GUIResources.slider_cursor16'
    CursorWidth=8
    CursorHeight=16

    offH=(Val=44)

    OnChanging=Changing
    OnChanged=Changed
}
