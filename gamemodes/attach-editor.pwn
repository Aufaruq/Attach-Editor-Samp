#include "a_samp"
#include "zcmd"

#define OUTPUT_FILE "SavedAttachments.txt"
#define COLOR_WHITE 		0xFFFFFFFF
main()
{
    printf("\n\t=====================================\n");
    printf("\t|          Coding: Aufa            |\n");
    printf("\t|    GitHub: github.com/Aufaruq    |\n");
    printf("\t|       Discord: Aufaruq#1         |\n");
    printf("\t|        adistia cmiww             |\n");
    printf("\t=====================================\n");
}

enum
{
	DIALOG_MAIN = 7000,
	DIALOG_INDEX_SELECT,
	DIALOG_MODEL_SELECT,
	DIALOG_BONE_SELECT,
	DIALOG_COORD_INPUT
}
enum
{
	Float:COORD_X,
	Float:COORD_Y,
	Float:COORD_Z
}
enum
{
	POS_OFFSET_X,
	POS_OFFSET_Y,
	POS_OFFSET_Z,
	ROT_OFFSET_X,
	ROT_OFFSET_Y,
	ROT_OFFSET_Z,
	SCALE_X,
	SCALE_Y,
	SCALE_Z
}


new
	AttachmentBones[18][16] =
	{
		{"Spine"},
		{"Head"},
		{"Left upper arm"},
		{"Right upper arm"},
		{"Left hand"},
		{"Right hand"},
		{"Left thigh"},
		{"Right thigh"},
		{"Left foot"},
		{"Right foot"},
		{"Right calf"},
		{"Left calf"},
		{"Left forearm"},
		{"Right forearm"},
		{"Left clavicle"},
		{"Right clavicle"},
		{"Neck"},
		{"Jaw"}
	};

new
bool:	gEditingAttachments		[MAX_PLAYERS],
		gCurrentAttachIndex		[MAX_PLAYERS],
bool:	gIndexUsed				[MAX_PLAYERS][MAX_PLAYER_ATTACHED_OBJECTS],
		gIndexModel				[MAX_PLAYERS][MAX_PLAYER_ATTACHED_OBJECTS],
		gIndexBone				[MAX_PLAYERS][MAX_PLAYER_ATTACHED_OBJECTS],
Float:	gIndexPos				[MAX_PLAYERS][MAX_PLAYER_ATTACHED_OBJECTS][3],
Float:	gIndexRot				[MAX_PLAYERS][MAX_PLAYER_ATTACHED_OBJECTS][3],
Float:	gIndexSca				[MAX_PLAYERS][MAX_PLAYER_ATTACHED_OBJECTS][3],
		gCurrentAxisEdit		[MAX_PLAYERS];
	
public OnPlayerConnect(playerid)
{
	GameTextForPlayer(playerid,"~w~Editor Attach Aufa",3000,4);
  	SendClientMessage(playerid,COLOR_WHITE,"Welcome to {88AA88}Attach {88AA88}Editor Aufa");
	SendClientMessage(playerid,COLOR_WHITE,"Press the spawn box below to spawn your character, if your character experiences a crash, then use cmd /spawn");
	SendClientMessage(playerid,COLOR_WHITE,"use cmd /attachedit to start your project");
}

public OnGameModeInit()
{
	for(new i; i < MAX_PLAYERS; i++)
	{
		gCurrentAttachIndex[i] = 0;
		gIndexModel[i][0] = 18636;

		for(new j; j < MAX_PLAYER_ATTACHED_OBJECTS; j++)
		{
			gIndexUsed[i][j] = false;
			gIndexBone[i][j] = 1;
			gIndexSca[i][j][COORD_X] = 1.0;
			gIndexSca[i][j][COORD_Y] = 1.0;
			gIndexSca[i][j][COORD_Z] = 1.0;
		}
	}
}

public OnGameModeExit()
{
	for(new i; i < MAX_PLAYERS; i++)
	{
		if(gEditingAttachments[i])
		{
			for(new j; j < MAX_PLAYER_ATTACHED_OBJECTS; j++)
			{
				if(gIndexUsed[i][j])
					RemovePlayerAttachedObject(i, j);
			}
		}
	}
}


CMD:attachedit(playerid,params[])
{
	ShowMainEditMenu(playerid);
	return 1;
}
CMD:spawn(playerid, params[])
{
    SetPlayerPos(playerid, 318.0528,-127.7363,2.3365);
    SetPlayerFacingAngle(playerid, 275.0638);
    SendClientMessage(playerid, COLOR_WHITE, "You have been spawned!");
    return 1;
}

ShowMainEditMenu(playerid)
{
	new string[312];

	format(string, sizeof(string),
		"Select Index (%d)\n\
		Select Model (%d)\n\
		Select Bone (%d)\n\
		X Position Offset (%.4f)\n\
		Y Position Offset (%.4f)\n\
		Z Position Offset (%.4f)\n\
		X Rotation Offset (%.4f)\n\
		Y Rotation Offset (%.4f)\n\
		Z Rotation Offset (%.4f)\n\
		X Scale (%.4f)\n\
		Y Scale (%.4f)\n\
		Z Scale (%.4f)\n\
		Edit\n\
		Save",
		gCurrentAttachIndex[playerid],
		gIndexModel[playerid][gCurrentAttachIndex[playerid]],
		gIndexBone[playerid][gCurrentAttachIndex[playerid]],
		gIndexPos[playerid][gCurrentAttachIndex[playerid]][COORD_X],
		gIndexPos[playerid][gCurrentAttachIndex[playerid]][COORD_Y],
		gIndexPos[playerid][gCurrentAttachIndex[playerid]][COORD_Z],
		gIndexRot[playerid][gCurrentAttachIndex[playerid]][COORD_X],
		gIndexRot[playerid][gCurrentAttachIndex[playerid]][COORD_Y],
		gIndexRot[playerid][gCurrentAttachIndex[playerid]][COORD_Z],
		gIndexSca[playerid][gCurrentAttachIndex[playerid]][COORD_X],
		gIndexSca[playerid][gCurrentAttachIndex[playerid]][COORD_Y],
		gIndexSca[playerid][gCurrentAttachIndex[playerid]][COORD_Z]);

	ShowPlayerDialog(playerid, DIALOG_MAIN, DIALOG_STYLE_LIST, "Attachment Editor / Main Menu", string, "Accept", "Cancel");

	gEditingAttachments[playerid] = true;
}

ShowIndexList(playerid)
{
	new string[512];
	
	for(new i; i < MAX_PLAYER_ATTACHED_OBJECTS; i++)
	{
		if(IsPlayerAttachedObjectSlotUsed(playerid, i))
		{
			if(gIndexUsed[playerid][i])
				format(string, sizeof(string), "%sSlot %d (%s - %d)\n", string, i, AttachmentBones[gIndexBone[playerid][i]], gIndexModel[playerid][i]);

			else
				format(string, sizeof(string), "%sSlot %d (External)\n", string, i);
		}
		else
		{
			format(string, sizeof(string), "%sSlot %d\n", string, i);
		}
	}

	ShowPlayerDialog(playerid, DIALOG_INDEX_SELECT, DIALOG_STYLE_LIST, "Attachment Editor / Index", string, "Accept", "Cancel");
}

ShowModelInput(playerid)
{
	ShowPlayerDialog(playerid, DIALOG_MODEL_SELECT, DIALOG_STYLE_INPUT, "Attachment Editor / Model", "Enter a model to attach", "Accept", "Cancel");
}

ShowBoneList(playerid)
{
	new string[512];
	
	for(new i; i < sizeof(AttachmentBones); i++)
	{
		format(string, sizeof(string), "%s%s\n", string, AttachmentBones[i]);
	}

	ShowPlayerDialog(playerid, DIALOG_BONE_SELECT, DIALOG_STYLE_LIST, "Attachment Editor / Bone", string, "Accept", "Cancel");
}

EditCoord(playerid, coord)
{
	gCurrentAxisEdit[playerid] = coord;
	ShowPlayerDialog(playerid, DIALOG_COORD_INPUT, DIALOG_STYLE_INPUT, "Attachment Editor / Offset", "Enter a floating point value for the offset:", "Accept", "Cancel");
}

EditAttachment(playerid)
{
	SetPlayerAttachedObject(playerid,
		gCurrentAttachIndex[playerid],
		gIndexModel[playerid][gCurrentAttachIndex[playerid]],
		gIndexBone[playerid][gCurrentAttachIndex[playerid]],
		gIndexPos[playerid][gCurrentAttachIndex[playerid]][COORD_X],
		gIndexPos[playerid][gCurrentAttachIndex[playerid]][COORD_Y],
		gIndexPos[playerid][gCurrentAttachIndex[playerid]][COORD_Z],
		gIndexRot[playerid][gCurrentAttachIndex[playerid]][COORD_X],
		gIndexRot[playerid][gCurrentAttachIndex[playerid]][COORD_Y],
		gIndexRot[playerid][gCurrentAttachIndex[playerid]][COORD_Z],
		gIndexSca[playerid][gCurrentAttachIndex[playerid]][COORD_X],
		gIndexSca[playerid][gCurrentAttachIndex[playerid]][COORD_Y],
		gIndexSca[playerid][gCurrentAttachIndex[playerid]][COORD_Z]);

	EditAttachedObject(playerid, gCurrentAttachIndex[playerid]);

	gIndexUsed[playerid][gCurrentAttachIndex[playerid]] = true;
}

SaveAttachedObjects(playerid)
{
	new
		str[256],
		File:file;

	if(!fexist(OUTPUT_FILE))
		file = fopen(OUTPUT_FILE, io_write);

	else
		file = fopen(OUTPUT_FILE, io_append);

	if(!file)
	{
		print("ERROR: Opening file "OUTPUT_FILE"");
		return 0;
	}

	format(str, 256, "SetPlayerAttachedObject(playerid, %d, %d, %d,  %f, %f, %f,  %f, %f, %f,  %f, %f, %f); // %d\r\n",
		gCurrentAttachIndex[playerid],
		gIndexModel[playerid][gCurrentAttachIndex[playerid]],
		gIndexBone[playerid][gCurrentAttachIndex[playerid]],
		gIndexPos[playerid][gCurrentAttachIndex[playerid]][COORD_X],
		gIndexPos[playerid][gCurrentAttachIndex[playerid]][COORD_Y],
		gIndexPos[playerid][gCurrentAttachIndex[playerid]][COORD_Z],
		gIndexRot[playerid][gCurrentAttachIndex[playerid]][COORD_X],
		gIndexRot[playerid][gCurrentAttachIndex[playerid]][COORD_Y],
		gIndexRot[playerid][gCurrentAttachIndex[playerid]][COORD_Z],
		gIndexSca[playerid][gCurrentAttachIndex[playerid]][COORD_X],
		gIndexSca[playerid][gCurrentAttachIndex[playerid]][COORD_Y],
		gIndexSca[playerid][gCurrentAttachIndex[playerid]][COORD_Z],
		GetPlayerSkin(playerid));

	fwrite(file, str);
	fclose(file);

	ShowMainEditMenu(playerid);

	return 1;
}


public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{	
	if(dialogid == DIALOG_MAIN)
	{
		if(response)
		{
			switch(listitem)
			{
				case 00:ShowIndexList(playerid);
				case 01:ShowModelInput(playerid);
				case 02:ShowBoneList(playerid);
				case 03:EditCoord(playerid, POS_OFFSET_X);
				case 04:EditCoord(playerid, POS_OFFSET_Y);
				case 05:EditCoord(playerid, POS_OFFSET_Z);
				case 06:EditCoord(playerid, ROT_OFFSET_X);
				case 07:EditCoord(playerid, ROT_OFFSET_Y);
				case 08:EditCoord(playerid, ROT_OFFSET_Z);
				case 09:EditCoord(playerid, SCALE_X);
				case 10:EditCoord(playerid, SCALE_Y);
				case 11:EditCoord(playerid, SCALE_Z);
				case 12:EditAttachment(playerid);
				// case 13:ClearCurrentIndex(playerid);
				case 13:SaveAttachedObjects(playerid);
			}
		}
	}
	if(dialogid == DIALOG_INDEX_SELECT)
	{
		if(response)
		{
			gCurrentAttachIndex[playerid] = listitem;
			ShowMainEditMenu(playerid);
		}
		else
		{
			ShowMainEditMenu(playerid);
		}

		return 1;
	}
	if(dialogid == DIALOG_MODEL_SELECT)
	{
		if(response)
		{
			gIndexModel[playerid][gCurrentAttachIndex[playerid]] = strval(inputtext);
			ShowMainEditMenu(playerid);
		}
		else
		{
			ShowMainEditMenu(playerid);
		}
	}

	if(dialogid == DIALOG_BONE_SELECT)
	{
		if(response)
		{
			gIndexBone[playerid][gCurrentAttachIndex[playerid]] = listitem + 1;
			ShowMainEditMenu(playerid);
		}
		else
		{
			ShowMainEditMenu(playerid);
		}
	}
	if(dialogid == DIALOG_COORD_INPUT)
	{
		if(response)
		{
			new Float:value = floatstr(inputtext);

			switch(gCurrentAxisEdit[playerid])
			{
				case POS_OFFSET_X:  gIndexPos[playerid][gCurrentAttachIndex[playerid]][COORD_X] = value;
				case POS_OFFSET_Y:  gIndexPos[playerid][gCurrentAttachIndex[playerid]][COORD_Y] = value;
				case POS_OFFSET_Z:  gIndexPos[playerid][gCurrentAttachIndex[playerid]][COORD_Z] = value;
				case ROT_OFFSET_X:  gIndexRot[playerid][gCurrentAttachIndex[playerid]][COORD_X] = value;
				case ROT_OFFSET_Y:  gIndexRot[playerid][gCurrentAttachIndex[playerid]][COORD_Y] = value;
				case ROT_OFFSET_Z:  gIndexRot[playerid][gCurrentAttachIndex[playerid]][COORD_Z] = value;
				case SCALE_X:       gIndexSca[playerid][gCurrentAttachIndex[playerid]][COORD_X] = value;
				case SCALE_Y:       gIndexSca[playerid][gCurrentAttachIndex[playerid]][COORD_Y] = value;
				case SCALE_Z:       gIndexSca[playerid][gCurrentAttachIndex[playerid]][COORD_Z] = value;
			}

			SetPlayerAttachedObject(playerid,
				gCurrentAttachIndex[playerid],
				gIndexModel[playerid][gCurrentAttachIndex[playerid]],
				gIndexBone[playerid][gCurrentAttachIndex[playerid]],
				gIndexPos[playerid][gCurrentAttachIndex[playerid]][COORD_X],
				gIndexPos[playerid][gCurrentAttachIndex[playerid]][COORD_Y],
				gIndexPos[playerid][gCurrentAttachIndex[playerid]][COORD_Z],
				gIndexRot[playerid][gCurrentAttachIndex[playerid]][COORD_X],
				gIndexRot[playerid][gCurrentAttachIndex[playerid]][COORD_Y],
				gIndexRot[playerid][gCurrentAttachIndex[playerid]][COORD_Z],
				gIndexSca[playerid][gCurrentAttachIndex[playerid]][COORD_X],
				gIndexSca[playerid][gCurrentAttachIndex[playerid]][COORD_Y],
				gIndexSca[playerid][gCurrentAttachIndex[playerid]][COORD_Z]);
		}
		ShowMainEditMenu(playerid);
	}
	return 1;
}

public OnPlayerEditAttachedObject(playerid, response, index, modelid, boneid, Float:fOffsetX, Float:fOffsetY, Float:fOffsetZ, Float:fRotX, Float:fRotY, Float:fRotZ, Float:fScaleX, Float:fScaleY, Float:fScaleZ)
{
	gIndexPos[playerid][gCurrentAttachIndex[playerid]][COORD_X] = fOffsetX;
	gIndexPos[playerid][gCurrentAttachIndex[playerid]][COORD_Y] = fOffsetY;
	gIndexPos[playerid][gCurrentAttachIndex[playerid]][COORD_Z] = fOffsetZ;
	gIndexRot[playerid][gCurrentAttachIndex[playerid]][COORD_X] = fRotX;
	gIndexRot[playerid][gCurrentAttachIndex[playerid]][COORD_Y] = fRotY;
	gIndexRot[playerid][gCurrentAttachIndex[playerid]][COORD_Z] = fRotZ;
	gIndexSca[playerid][gCurrentAttachIndex[playerid]][COORD_X] = fScaleX;
	gIndexSca[playerid][gCurrentAttachIndex[playerid]][COORD_Y] = fScaleY;
	gIndexSca[playerid][gCurrentAttachIndex[playerid]][COORD_Z] = fScaleZ;

	ShowMainEditMenu(playerid);

	SetPlayerAttachedObject(playerid, index, modelid, boneid, fOffsetX, fOffsetY, fOffsetZ, fRotX, fRotY, fRotZ, fScaleX, fScaleY, fScaleZ);

	return 1;
}
