//================================================================
// ucGUIFramework.GUIDraggable
// ----------------
// Draggable widget
// ----------------
// by Chatouille
//================================================================
class GUIDraggable extends GUIButton;

var GUIGroup LockedInside;
var bool X_percent, Y_percent;
var bool W_percent, H_percent;

var Vector2D ClickPos;

var delegate<Moving> OnMoving;
var delegate<Moved> OnMoved;

delegate Moving(GUIDraggable elem);
delegate Moved(GUIDraggable elem);

static function GUIDraggable CreateDraggable(optional GUIGroup _Parent=None, optional GUIGroup _Lock)
{
	local GUIDraggable dr;
	dr = new(None) class'GUIDraggable';
	if ( _Parent != None )
		_Parent.AddChild(dr);
	dr.SetLock(_Lock);
	return dr;
}

function SetLock(GUIGroup elem)
{
	LockedInside = elem;
}

function SetPosMode(bool X_pct, bool Y_pct, bool W_pct, bool H_pct)
{
	X_percent = X_pct;
	Y_percent = Y_pct;
	W_percent = W_pct;
	H_percent = H_pct;
}

function InternalOnLeftMouse(GUIGroup elem, bool bDown)
{
	bActive = bDown;

	if ( bActive )
	{
		AlignX = ALIGN_LEFT;
		AlignY = ALIGN_TOP;
		RecalcPosition();

		ClickPos.X = Root.MousePos.X - absX;
		ClickPos.Y = Root.MousePos.Y - absY;
	}
	else
	{
		OnMoved(Self);
	}
}

function RecalcPosition()
{
	if ( LockedInside != None )
	{
		absX = FClamp(absX, LockedInside.absX, LockedInside.absX + LockedInside.absW - absW);
		absY = FClamp(absY, LockedInside.absY, LockedInside.absY + LockedInside.absH - absH);
	}

	if ( Parent == None )
		return;

	SetPos( ( X_percent ? ((100.0 * (absX - Parent.absX) / Parent.absW) $ "%") : (""$(absX - parent.absX)) ),
			( Y_percent ? ((100.0 * (absY - Parent.absY) / Parent.absH) $ "%") : (""$(absY - parent.absY)) ),
			( W_percent ? ((100.0 * absW / Parent.absW) $ "%") : (""$absW) ),
			( H_percent ? ((100.0 * absH / Parent.absH) $ "%") : (""$absH) ) );
}

function InternalOnHold(GUIGroup elem)
{
	absX = Root.MousePos.X - ClickPos.X;
	absY = Root.MousePos.Y - ClickPos.Y;

	RecalcPosition();

	OnMoving(Self);
}

function Free()
{
	Super.Free();

	OnMoving = None;
	OnMoved = None;
}

defaultproperties
{
	X_percent=true
	Y_percent=true
	Texture=None
	Text="drag me"
	OnHold=InternalOnHold
	OnMoving=Moving
	OnMoved=Moved
}
