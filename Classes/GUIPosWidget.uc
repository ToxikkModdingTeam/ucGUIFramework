//================================================================
// ucGUIFramework.GUIPosWidget
// ----------------
// Draggable widget designed for configuring positions of external stuff
// ----------------
// by Chatouille
//================================================================
class GUIPosWidget extends GUIDraggable;

static function GUIPosWidget CreatePosWidget(optional GUIGroup _Parent=None, optional String _Text="drag me")
{
	local GUIPosWidget pw;
	pw = new(None) class'GUIPosWidget';
	if ( _Parent != None )
		_Parent.AddChild(pw);
	pw.Text = _Text;
	return pw;
}

//Override
function InternalOnDraw(GUIGroup elem, Canvas C)
{
    if ( bHover && bActive )
	{
        SetColors(MakeColor(0,0,0,160), MakeColor(128,200,230,255));
		SetTextColor(MakeColor(128,200,230,255));
		SetAlpha(1.0);
	}
    else if ( bHover )
	{
        SetColors(MakeColor(0,0,0,160), MakeColor(160,230,255,255));
		SetTextColor(MakeColor(160,230,255,255));
		SetAlpha(1.0);
	}
    else
	{
        SetColors(MakeColor(0,0,0,160), MakeColor(255,255,255,255));
		SetTextColor(MakeColor(255,255,255,255));
		SetAlpha(0.5);
	}

	Super(GUILabel).InternalOnDraw(elem, C);
}

//Override - custom box
function DrawBox(Canvas C, int X, int Y, int W, int H, Color Col)
{
    SetDrawColor4(C, Col.R, Col.G, Col.B, Col.A / 2);
    C.SetPos(X+1, Y+1);
    C.DrawRect(1, H/4-1);
    C.SetPos(X+1, Y+1);
    C.DrawRect(W/4-1, 1);

    C.SetPos(X+W-W/4, Y+1);
    C.DrawRect(W/4-2, 1);
    C.SetPos(X+W-1, Y+1);
    C.DrawRect(1, H/4-1);

	C.SetPos(X+1, Y+H-H/4);
	C.DrawRect(1, H/4-1);
    C.SetPos(X+1, Y+H-1);
    C.DrawRect(W/4-1, 1);

	C.SetPos(X+W-W/4, Y+H-1);
	C.DrawRect(W/4-1, 1);
	C.SetPos(X+W-1, Y+H-H/4);
	C.DrawRect(1, H/4-1);
    
    SetDrawColor(C, Col);
    C.SetPos(X, Y);
    C.DrawRect(1, H/4);
    C.SetPos(X, Y);
    C.DrawRect(W/4, 1);

    C.SetPos(X+W-W/4, Y);
    C.DrawRect(W/4, 1);
    C.SetPos(X+W, Y);
    C.DrawRect(1, H/4);

	C.SetPos(X, Y+H-H/4);
	C.DrawRect(1, H/4);
    C.SetPos(X, Y+H);
    C.DrawRect(W/4, 1);

	C.SetPos(X+W-W/4,Y+H);
	C.DrawRect(W/4, 1);
	C.SetPos(X+W, Y+H-H/4);
	C.DrawRect(1, H/4);
}

function String GetBestAutoPos()
{
	local float left, top;
	local String hor, ver;

	CalcPos(0);

	left = absX - Parent.absX;
	if ( left+absW >= 0.75*Parent.absW )
		hor = "right:100%-" $ Round(Parent.absW - (left+absW));
	else if ( left <= 0.25*Parent.absW )
		hor = "left:" $ Round(left);
	else if ( left+absW/2 < 0.5*Parent.absW )
		hor = "center-x:50%-" $ Round(0.5*Parent.absW - (left+absW/2));
	else
		hor = "center-x:50%+" $ Round(left+absW/2 - 0.5*Parent.absW);

	top = absY - Parent.absY;
	if ( top+absH >= 0.75*Parent.absH )
		ver = "bottom:100%-" $ Round(Parent.absH - (top+absH));
	else if ( top<= 0.25*Parent.absH )
		ver = "top:" $ Round(top);
	else if ( top+absH/2 < 0.5*Parent.absH )
		ver = "center-y:50%-" $ Round(0.5*Parent.absH - (top+absH/2));
	else
		ver = "center-y:50%+" $ Round(top+absH/2 - 0.5*Parent.absH);

	return (hor $ ";" $ ver);
}

defaultproperties
{
	offW=(Val=128)
	offH=(Val=128)
	zIndex=10
	bAutoColor=false
}
