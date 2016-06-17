//================================================================
// ucGUIFramework.GUIGroup
// ----------------
// Group element - base class for every other elements
// ----------------
// by Chatouille
//================================================================
class GUIGroup extends Object;

// consts
var CONST Color TRANSPARENT;

enum eAnimMode
{
    ANIM_WAIT,
    ANIM_LINEAR,
    ANIM_EASE_IN,
    ANIM_EASE_OUT,
    ANIM_EASE_IN_OUT
};

struct sFloatQueue
{
    var float Target;
    var float TotalDur;
    var eAnimMode Mode;
};
struct sFloatAnim
{
    var float Val;
    var array<sFloatQueue> Queue;
    var float Start;
    var float RemDur;
};

struct sColorQueue
{
    var Color Target;
    var float TotalDur;
    var eAnimMode Mode;
};
struct sColorAnim
{
    var Color Val;
    var array<sColorQueue> Queue;
    var Color Start;
    var float RemDur;
};

enum eHorAlignment
{
    ALIGN_LEFT,
    ALIGN_CENTER,
    ALIGN_RIGHT
};

enum eVerAlignment
{
    ALIGN_TOP,
    ALIGN_MIDDLE,
    ALIGN_BOTTOM
};

// structure
var GUIRoot Root;
var GUIGroup Parent;
var array<GUIGroup> Children;

// positioning: relative (percent) + offset (px)
var sFloatAnim relX;
var sFloatAnim offX;

var sFloatAnim relY;
var sFloatAnim offY;

var sFloatAnim relW;
var sFloatAnim offW;

var sFloatAnim relH;
var sFloatAnim offH;

// alignment
var eHorAlignment AlignX;
var eVerAlignment AlignY;

// box / fill / colors
var sColorAnim BgColor;
var sColorAnim BoxColor;

var Texture2D Texture;

var sFloatAnim Alpha;

// other stuff
var bool bCaptureMouse;

var bool bEnabled;
var bool bGroupEnabled;     // disabled inherited from Parents

var int zIndex;             // defines order to draw the array of Children
                            // an element zIndex is only relevant to its brothers and sisters

var array<String> Data;

// cycle vars
var int absX, absY;			// absolute positions computed every Tick
var int absW, absH;	
var float AlphaMultiplier;  // alpha inherited from Parents

// delegates
var delegate<Draw> OnDraw;
var delegate<Hover> OnHover;
var delegate<LeftMouse> OnLeftMouse;
var delegate<Hold> OnHold;
var delegate<RightMouse> OnRightMouse;

delegate Draw(GUIGroup elem, Canvas C);

delegate Hover(GUIGroup elem, bool bHover);
delegate LeftMouse(GUIGroup elem, bool bDown);
delegate Hold(GUIGroup elem);
delegate RightMouse(GUIGroup elem, bool bDown);

function LeftMousePropagate(GUIGroup elem, bool bDown)
{
	local GUIGroup g;
	for ( g=Parent; g!=None; g=g.Parent )
	{
		if ( g.bCaptureMouse && g.bEnabled && g.bGroupEnabled )
			g.OnLeftMouse(elem, bDown);
	}
}
function RightMousePropagate(GUIGroup elem, bool bDown)
{
	local GUIGroup g;
	for ( g=Parent; g!=None; g=g.Parent )
	{
		if ( g.bCaptureMouse && g.bEnabled && g.bGroupEnabled )
			g.OnRightMouse(elem, bDown);
	}
}

static function GUIGroup CreateGroup(optional GUIGroup _Parent=None)
{
	local GUIGroup g;
	g = new(None) class'GUIGroup';
	if ( _Parent != None )
		_Parent.AddChild(g);
	return g;
}

function AddChild(GUIGroup elem)
{
    if ( elem.Parent != None )
        elem.Parent.RemoveChild(elem);

    Children.AddItem(elem);
    elem.Parent = Self;
	elem.UpdateRoot(Root);
}

function UpdateRoot(GUIRoot newRoot)
{
	local int i;

	Root = newRoot;
	for ( i=0; i<Children.length; i++ )
		Children[i].UpdateRoot(newRoot);
}

function RemoveChild(GUIGroup elem)
{
    local int i;

	i = Children.Find(elem);
	if ( i != INDEX_NONE )
	{
		Children[i].Parent = None;
		Children.Remove(i,1);
	}
}

function RemoveFromParent()
{
	if ( Parent != None )
	{
		Parent.Children.RemoveItem(Self);
		Parent = None;
	}
}

function SetEnabled(bool newEnabled)
{
    local int i;

    bEnabled = newEnabled;
    for ( i=0; i<Children.length; i++ )
        Children[i].SetGroupEnabled(bGroupEnabled && bEnabled);
}

function SetGroupEnabled(bool newGroupEnabled)
{
    local int i;

    bGroupEnabled = newGroupEnabled;
    for ( i=0; i<Children.length; i++ )
        Children[i].SetGroupEnabled(bGroupEnabled && bEnabled);
}

function SetAlign(eHorAlignment newAlignX, eVerAlignment newAlignY)
{
    AlignX = newAlignX;
    AlignY = newAlignY;
}

// relative: "50%"
// offset: "42"
// relative+offset: "50%+42"
// unchanged: "_"
function SetPos(coerce String strX, coerce String strY, coerce String strW, coerce String strH)
{
	ParsePositionString(strX, relX.Val, offX.Val);
	relX.Queue.Length = 0;
	offX.Queue.Length = 0;

	ParsePositionString(strY, relY.Val, offY.Val);
	relY.Queue.Length = 0;
	offY.Queue.Length = 0;

	ParsePositionString(strW, relW.Val, offW.Val);
	relW.Queue.Length = 0;
	offW.Queue.Length = 0;

	ParsePositionString(strH, relH.Val, offH.Val);
	relH.Queue.Length = 0;
	offH.Queue.Length = 0;
}

static function ParsePositionString(String in, out float pct, out float px)
{
	local int i;

	if ( in ~= "" || in ~= "_" )
		return;

	i = InStr(in, "%");
	if ( i != -1 )
	{
		pct = float(Left(in, i)) / 100.0;
		px = float(Mid(in, i+1));
	}
	else
	{
		pct = 0.0;
		px = float(in);
	}
}

function SetPosAuto(String str)
{
	local array<String> Parts;
	local int i;
	local array<String> KV;

	Parts = SplitString(Caps(Repl(str, " ", "")), ";", true);
	for ( i=0; i<Parts.length; i++ )
	{
		KV.Length = 0;
		KV = SplitString(Parts[i], ":", true);
		if ( KV.length == 2 )
		{
			if ( KV[0] == "LEFT" ) {
				AlignX = ALIGN_LEFT;
				ParsePositionString(KV[1], relX.Val, offX.Val);
			} else if ( KV[0] == "CENTER-X" ) {
				AlignX = ALIGN_CENTER;
				ParsePositionString(KV[1], relX.Val, offX.Val);
			} else if ( KV[0] == "RIGHT" ) {
				AlignX = ALIGN_RIGHT;
				ParsePositionString(KV[1], relX.Val, offX.Val);
			} else if ( KV[0] == "TOP" ) {
				AlignY = ALIGN_TOP;
				ParsePositionString(KV[1], relY.Val, offY.Val);
			} else if ( KV[0] == "CENTER-Y" ) {
				AlignY = ALIGN_MIDDLE;
				ParsePositionString(KV[1], relY.Val, offY.Val);
			} else if ( KV[0] == "BOTTOM" ) {
				AlignY = ALIGN_BOTTOM;
				ParsePositionString(KV[1], relY.Val, offY.Val);
			} else if ( KV[0] == "WIDTH" ) {
				ParsePositionString(KV[1], relW.Val, offW.Val);
			} else if ( KV[0] == "HEIGHT" ) {
				ParsePositionString(KV[1], relH.Val, offH.Val);
			}
		}
	}
	relX.Queue.Length = 0;
	offX.Queue.Length = 0;
	relY.Queue.Length = 0;
	offY.Queue.Length = 0;
	relW.Queue.Length = 0;
	offW.Queue.Length = 0;
	relH.Queue.Length = 0;
	offH.Queue.Length = 0;
}

function MoveTo(coerce String strX, coerce String strY, coerce String strW, coerce String strH, float Dur, eAnimMode Mode)
{
	relX.Queue.Length = 0;
	offX.Queue.Length = 0;
    relY.Queue.Length = 0;
	offY.Queue.Length = 0;
    relW.Queue.Length = 0;
	offW.Queue.Length = 0;
    relH.Queue.Length = 0;
	offH.Queue.Length = 0;

    QueueMove(strX, strY, strW, strH, Dur, Mode);
}

function QueueMove(coerce String strX, coerce String strY, coerce String strW, coerce String strH, float Dur, eAnimMode Mode)
{
    local int i;

    i = relX.Queue.Length;
	__QueueMove(strX, relX, offX, i, Dur, Mode);
	__QueueMove(strY, relY, offY, i, Dur, Mode);
	__QueueMove(strW, relW, offW, i, Dur, Mode);
	__QueueMove(strH, relH, offH, i, Dur, Mode);
}

static function __QueueMove(String str, out sFloatAnim rel, out sFloatAnim off, int i, float Dur, eAnimMode Mode)
{
	local float parsedRel, parsedOff;

	ParsePositionString_fb(str, parsedRel, parsedOff, rel.Val, off.Val);

	rel.Queue.Length = i+1;
	rel.Queue[i].Target = parsedRel;
    rel.Queue[i].TotalDur = Dur;
	rel.Queue[i].Mode = Mode;

	off.Queue.Length = i+1;
	off.Queue[i].Target = parsedOff;
	off.Queue[i].TotalDur = Dur;
	off.Queue[i].Mode = Mode;

	if ( i == 0 )
	{
		rel.Start = rel.Val;
		rel.RemDur = Dur;
		off.Start = off.Val;
		off.RemDur = Dur;
	}
}

static function ParsePositionString_fb(String in, out float pct, out float px, float fb_pct, float fb_px)
{
	ParsePositionString(in, fb_pct, fb_px);
	pct = fb_pct;
	px = fb_px;
}

function SetColors(Color newBg, Color newBox)
{
    BgColor.Val = newBg;
    BgColor.Queue.Length = 0;
    BoxColor.Val = newBox;
    BoxColor.Queue.Length = 0;
}

function ColorsTo(Color newBg, Color newBox, float Dur, eAnimMode Mode)
{
    BgColor.Queue.Length = 0;
    BoxColor.Queue.Length = 0;

    QueueColors(newBg, newBox, Dur, Mode);
}

function QueueColors(Color newBg, Color newBox, float Dur, eAnimMode Mode)
{
    local int i;

    i = BgColor.Queue.Length;
    BgColor.Queue.Length = i+1;
    BgColor.Queue[i].Target = newBg;
    BgColor.Queue[i].TotalDur = Dur;
    BgColor.Queue[i].Mode = Mode;

    BoxColor.Queue.Length = i+1;
    BoxColor.Queue[i].Target = newBox;
    BoxColor.Queue[i].TotalDur = Dur;
    BoxColor.Queue[i].Mode = Mode;

    if ( i == 0 )
    {
        BgColor.Start = BgColor.Val;
        BgColor.RemDur = Dur;

        BoxColor.Start = BoxColor.Val;
        BoxColor.RemDur = Dur;
    }
}

function SetAlpha(float newVal)
{
    Alpha.Val = newVal;
    Alpha.Queue.Length = 0;
}

function AlphaTo(float Val, float Dur, eAnimMode Mode)
{
    Alpha.Queue.Length = 0;

    QueueAlpha(Val, Dur, Mode);
}

function QueueAlpha(float newVal, float Dur, eAnimMode Mode)
{
    local int i;

    i = Alpha.Queue.Length;
    Alpha.Queue.Length = i+1;
    Alpha.Queue[i].Target = newVal;
    Alpha.Queue[i].TotalDur = Dur;
    Alpha.Queue[i].Mode = Mode;

    if ( i == 0 )
    {
        Alpha.Start = Alpha.Val;
        Alpha.RemDur = Dur;
    }
}

function CalcSizes(float dt)
{
	AnimFloat(relW, dt);
	AnimFloat(offW, dt);
	absW = (relW.Val * Parent.absW) + offW.Val;

	AnimFloat(relH, dt);
	AnimFloat(offH, dt);
	absH = (relH.Val * Parent.absH) + offH.Val;
}

function CalcPos(float dt)
{
	AnimFloat(relX, dt);
	AnimFloat(offX, dt);
	absX = Parent.absX + (relX.Val * Parent.absW) + offX.Val;
	if ( AlignX == ALIGN_CENTER )
		absX -= absW / 2;
	else if ( AlignX == ALIGN_RIGHT )
		absX -= absW;

	AnimFloat(relY, dt);
	AnimFloat(offY, dt);
	absY = Parent.absY + (relY.Val * Parent.absH) + offY.Val;
	if ( AlignY == ALIGN_MIDDLE )
		absY -= absH / 2;
	else if ( AlignY == ALIGN_BOTTOM )
		absY -= absH;
}

function GUITick(float dt)
{
    AnimColor(BgColor, dt);
    AnimColor(BoxColor, dt);

    AnimFloat(Alpha, dt);

    if ( bCaptureMouse && bEnabled && bGroupEnabled && Root.MouseInBounds(absX, absY, absX+absW, absY+absH) )
        Root.Hovering = Self;
}

function PostTick(float dt)
{
    local int i;

    for ( i=0; i<Children.length; i++ )
    {
        Children[i].AlphaMultiplier = AlphaMultiplier * Alpha.Val;
		Children[i].CalcSizes(dt);
		Children[i].CalcPos(dt);
        Children[i].GUITick(dt);
        Children[i].PostTick(dt);
    }
}

function InternalOnDraw(GUIGroup elem, Canvas C)
{
    if ( BgColor.Val.A > 0 )
    {
        SetDrawColor(C, BgColor.Val);
        C.SetPos(absX, absY);
        if ( Texture != None )
            C.DrawRect(absW, absH, Texture);
        else
            C.DrawRect(absW, absH);
    }
    if ( BoxColor.Val.A > 0 )
    {
        DrawBox(C, absX, absY, absW, absH, BoxColor.Val);
    }
}

function SkipDraw(GUIGroup elem, Canvas C);

function PostDraw(Canvas C)
{
    local int i;

    Children.Sort(CompareZIndex);

    for ( i=0; i<Children.length; i++ )
    {
        if ( Children[i].AlphaMultiplier > 0 )
        {
            Children[i].OnDraw(Children[i], C);
            Children[i].PostDraw(C);
        }
    }
}

function int CompareZIndex(GUIGroup e1, GUIGroup e2) { return (e2.zIndex - e1.zIndex); }

function SetDrawColor(Canvas C, Color Col)
{
    C.SetDrawColor(Col.R, Col.G, Col.B, Col.A * Alpha.Val * AlphaMultiplier);
}

function SetDrawColor4(Canvas C, byte R, byte G, byte B, byte A)
{
    C.SetDrawColor(R, G, B, A * Alpha.Val * AlphaMultiplier);
}

function DrawBox(Canvas C, int X, int Y, int W, int H, Color Col)
{
    SetDrawColor4(C, Col.R, Col.G, Col.B, Col.A / 2);
    C.SetPos(X+1, Y+1);
    C.DrawRect(1, H-2);
    C.SetPos(X+1, Y+1);
    C.DrawRect(W-2, 1);
    C.SetPos(X+W-1, Y+1);
    C.DrawRect(1, H-1);
    C.SetPos(X+1, Y+H-1);
    C.DrawRect(W-1, 1);
    
    SetDrawColor(C, Col);
    C.SetPos(X, Y);
    C.DrawRect(1, H);
    C.SetPos(X, Y);
    C.DrawRect(W, 1);
    C.SetPos(X+W, Y);
    C.DrawRect(1, H+1);
    C.SetPos(X, Y+H);
    C.DrawRect(W+1, 1);
}

function Clear()
{
	local int i;
	for ( i=0; i<Children.Length; i++ )
		Children[i].Free();
	Children.Length = 0;
}

function Free()
{
	Clear();
	OnDraw = None;
	OnHover = None;
	OnLeftMouse = None;
	OnHold = None;
	OnRightMouse = None;
}

static function AnimFloat(out sFloatAnim f, float dt)
{
    local float pct_time;
    local float pct_val;

    if ( f.Queue.Length > 0 )
    {
        if ( dt >= f.RemDur )
        {
            pct_val = AnimProgress(f.Queue[0].Mode, 1.0);
            f.Val = f.Start + pct_val*(f.Queue[0].Target - f.Start);

            f.Queue.Remove(0,1);
            if ( f.Queue.length > 0 )
            {
                f.Start = f.Val;
                f.RemDur = f.Queue[0].TotalDur;
            }
        }
        else
        {
            f.RemDur -= dt;
            pct_time = 1.0 - f.RemDur / f.Queue[0].TotalDur;
            pct_val = AnimProgress(f.Queue[0].Mode, pct_time);
            f.Val = f.Start + pct_val*(f.Queue[0].Target - f.Start);
        }
    }
}

static function AnimColor(out sColorAnim c, float dt)
{
    local float pct_time;
    local float pct_val;

    if ( c.Queue.Length > 0 )
    {
        if ( dt >= c.RemDur )
        {
            pct_val = AnimProgress(c.Queue[0].Mode, 1.0);
            c.Val.R = c.Start.R + pct_val*(c.Queue[0].Target.R - c.Start.R);
            c.Val.G = c.Start.G + pct_val*(c.Queue[0].Target.G - c.Start.G);
            c.Val.B = c.Start.B + pct_val*(c.Queue[0].Target.B - c.Start.B);
            c.Val.A = c.Start.A + pct_val*(c.Queue[0].Target.A - c.Start.A);

            c.Queue.Remove(0,1);
            if ( c.Queue.length > 0 )
            {
                c.Start = c.Val;
                c.RemDur = c.Queue[0].TotalDur;
            }
        }
        else
        {
            c.RemDur -= dt;
            pct_time = 1.0 - c.RemDur / c.Queue[0].TotalDur;
            pct_val = AnimProgress(c.Queue[0].Mode, pct_time);
            c.Val.R = c.Start.R + pct_val*(c.Queue[0].Target.R - c.Start.R);
            c.Val.G = c.Start.G + pct_val*(c.Queue[0].Target.G - c.Start.G);
            c.Val.B = c.Start.B + pct_val*(c.Queue[0].Target.B - c.Start.B);
            c.Val.A = c.Start.A + pct_val*(c.Queue[0].Target.A - c.Start.A);
        }
    }
}

static function float AnimProgress(eAnimMode Mode, float pct_time)
{
    switch (Mode)
    {
        case ANIM_LINEAR:
            return pct_time;

        case ANIM_EASE_IN:
            return Sin(pct_time * Pi / 2.0);

        case ANIM_EASE_OUT:
            return (1.0 - Cos(pct_time * Pi / 2.0));
            
        case ANIM_EASE_IN_OUT:
            return pct_time*Sin(pct_time * Pi / 2.0) + (1.0 - pct_time)*(1.0 - cos(pct_time * Pi / 2.0));

        default:
            return 0.0;
    }
}

static function Color MultColor(Color C, float rgbMult, float alphaMult)
{
    return MakeColor(Min(C.R*rgbMult,255), Min(C.G*rgbMult,255), Min(C.B*rgbMult,255), Min(C.A*alphaMult,255));
}

defaultproperties
{
    TRANSPARENT=(R=0,G=0,B=0,A=0)

    Alpha=(Val=1.0)
    AlphaMultiplier=1.0
    bEnabled=true
    bGroupEnabled=true

    OnDraw=InternalOnDraw
    OnHover=Hover
    OnLeftMouse=LeftMousePropagate
    OnHold=Hold
	OnRightMouse=RightMousePropagate
}
