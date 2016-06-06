//================================================================
// ucGUIFramework.GUILabel
// ----------------
// Label element
// ----------------
// by Chatouille
//================================================================
class GUILabel extends GUIGroup;

var String Text;
var Font TextFont;
var eHorAlignment TextAlignX;
var eVerAlignment TextAlignY;
var int TextPaddingX;
var int TextPaddingY;

var sColorAnim TextColor;
var sFloatAnim Scale;

static function GUILabel CreateLabel(optional GUIGroup _Parent=None, optional String _Text="label")
{
	local GUILabel lbl;
	lbl = new(None) class'GUILabel';
	if ( _Parent != None )
		_Parent.AddChild(lbl);
	lbl.Text = _Text;
	return lbl;
}

//HACK: TODO: BETTER FUCKING ACCESS FOR CANVAS !!!
function Vector2D GetIntrinsicSize(Canvas C)
{
	local Font backupFont;
	local Vector2D Size;

	backupFont = C.Font;
	C.Font = TextFont;
	C.TextSize(Text, Size.X, Size.Y, Scale.Val, Scale.Val);
	C.Font = backupFont;

	Size.X = FCeil(Size.X);
	Size.Y = FCeil(Size.Y);
	return Size;
}

function SizeToFit(Canvas C)
{
	local Vector2D Size;
	Size = GetIntrinsicSize(C);

	relW.Val = 0;
	offW.Val = Size.X;
	relW.Queue.Length = 0;
	offW.Queue.Length = 0;

	relH.Val = 0;
	offH.Val = Size.Y;
	relH.Queue.Length = 0;
	offH.Queue.Length = 0;
}

function SetTextAlign(eHorAlignment newAlignX, eVerAlignment newAlignY)
{
    TextAlignX = newAlignX;
    TextAlignY = newAlignY;
}

function SetTextColor(Color newColor)
{
    TextColor.Val = newColor;
    TextColor.Queue.Length = 0;
}

function TextColorTo(Color newColor, float Dur, eAnimMode Mode)
{
    TextColor.Queue.Length = 0;

    QueueTextColor(newColor, Dur, Mode);
}

function QueueTextColor(Color newColor, float Dur, eAnimMode Mode)
{
    local int i;

    i = TextColor.Queue.Length;
    TextColor.Queue.Length = i+1;
    TextColor.Queue[i].Target = newColor;
    TextColor.Queue[i].TotalDur = Dur;
    TextColor.Queue[i].Mode = Mode;

    if ( i == 0 )
    {
        TextColor.Start = TextColor.Val;
        TextColor.RemDur = Dur;
    }
}

function SetScale(float newScale)
{
    Scale.Val = newScale;
    Scale.Queue.Length = 0;
}

function ScaleTo(float newScale, float Dur, eAnimMode Mode)
{
    Scale.Queue.Length = 0;

    QueueScale(newScale, Dur, Mode);
}

function QueueScale(float newScale, float Dur, eAnimMode Mode)
{
    local int i;

    i = Scale.Queue.Length;
    Scale.Queue.Length = i+1;
    Scale.Queue[i].Target = newScale;
    Scale.Queue[i].TotalDur = Dur;
    Scale.Queue[i].Mode = Mode;

    if ( i == 0 )
    {
        Scale.Start = Scale.Val;
        Scale.RemDur = Dur;
    }
}

function GUITick(float dt)
{
    Super.GUITick(dt);

    AnimColor(TextColor, dt);
	AnimFloat(Scale, dt);
}

function InternalOnDraw(GUIGroup elem, Canvas C)
{
    local Vector2D TextSize;
    local Vector2D TextPos;

    Super.InternalOnDraw(elem, C);

    if ( Text == "" )
        return;

    C.Font = TextFont;
    C.TextSize(Text, TextSize.X, TextSize.Y, Scale.Val, Scale.Val);

    Switch (TextAlignX)
    {
        case ALIGN_LEFT:
            TextPos.X = absX + TextPaddingX;
            break;
        case ALIGN_CENTER:
            TextPos.X = absX + (absW - TextSize.X) / 2;
            break;
        case ALIGN_RIGHT:
            TextPos.X = absX + absW - (TextPaddingX + TextSize.X);
            break;
    }
    switch (TextAlignY)
    {
        case ALIGN_TOP:
            TextPos.Y = absY + TextPaddingY;
            break;
        case ALIGN_MIDDLE:
            TextPos.Y = absY + (absH - TextSize.Y) / 2;
            break;
        case ALIGN_BOTTOM:
            TextPos.Y = absY + absH - (TextPaddingY + TextSize.Y);
            break;
    }

    C.SetPos(TextPos.X, TextPos.Y);
    SetDrawColor(C, TextColor.Val);
    C.DrawText(Text, false, Scale.Val, Scale.Val);
}

defaultproperties
{
    Text="label"
    TextFont=Font'EngineFonts.SmallFont'
    TextColor=(Val=(R=255,G=255,B=255,A=255))
	Scale=(Val=1.0)
}
