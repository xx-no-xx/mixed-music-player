.386
.model flat, stdcall
option casemap:none

include windows.inc
include user32.inc
include kernel32.inc
include masm32.inc
include comctl32.inc
include comdlg32.inc ; �ļ�����
include winmm.inc
include gdi32.inc

; irvine32.inc

includelib masm32.lib
includelib user32.lib
includelib kernel32.lib
includelib comdlg32.lib
includelib Winmm.lib
includelib gdi32.lib

.const

;---------------- control -------------
IDD_DIALOG 						equ	101 ; �����ŶԻ���
IDD_DIALOG_ADD_NEW_GROUP		equ 105 ; �����¸赥�ĶԻ���

IDC_FILE_SYSTEM 				equ	1001 ; ����赥�İ�ť
IDC_MAIN_GROUP				    equ 1017 ; չʾ��ǰѡ��赥�����и���
IDC_GROUPS						equ 1009 ; ѡ��ǰ�赥
IDC_ADD_NEW_GROUP				equ 1023 ; �����µĸ赥
IDC_NEW_GROUP_NAME				equ 1025 ; �����¸赥������
IDC_BUTTON_ADD_NEW_GROUP		equ 1026 ; ȷ�ϼ����µĸ赥
IDC_DELETE_CURRENT_GROUP		equ 1027 ; ɾ����ǰ�赥�İ�ť
IDC_DELETE_CURRENT_SONG			equ 1028 ; ɾ����ǰ�����İ�ť
IDC_DELETE_INVALID_SONGS		equ 1029 ; ɾ�����зǷ��ĸ���
IDC_PLAY_BUTTON                 equ 1030 ; ����/��ͣ��ť
IDC_PRE_BUTTON                  equ 1031 ; ��һ��
IDC_NEXT_BUTTON                 equ 1032 ; ��һ��

IDC_SOUND						equ 1038 ; ����������
IDC_FAST_FORWARD				equ 1041 ; �����ť
IDC_FAST_BACKWARD				equ 1042 ; ���˰�ť
IDC_MUTE_SONG                   equ 1043 ; ��ȫ������ť
IDC_CHANGE_MODE                 equ 1044 ; �л�����˳��ť
IDC_SONG_LOCATE                 equ 1045 ; ���Ž�����
IDC_COMPLETE_TIME_TEXT          equ 1047 ; һ����Ҫ���Ŷ���ʱ��
IDC_PLAY_TIME_TEXT              equ 1048 ; �Ѿ������˶���ʱ��
IDC_SOUND_TEXT                  equ 1049 ; ������С������
IDC_CURRENT_STATIC              equ 1050 ; "��ǰ���ŵĸ�����"title
IDC_CURRENT_PLAY_SONG_TEXT      equ 1051 ; ��ǰ���ŵĸ�����չʾ

IDC_BACKGROUND					equ 2001 ; ����ͼ��
IDC_BACKGROUND_ORANGE           equ 2002 ; ��ɫ����ͼ��
;--------------- image & icon ----------------
IDB_BACKGROUND_BLUE             equ 3001
IDB_BACKGROUND_ORANGE           equ 3002
IDB_ADD_SONG_BLUE               equ 138
IDB_ADD_SONG_ORANGE             equ 139
IDB_CLEAN_SONG                  equ 140
IDB_NEW_LIST                    equ 141
IDB_REMOVE_LIST                 equ 142
IDB_REMOVE_SONG                 equ 143

IDI_PLAY_BLUE                   equ 146

IDI_BACKWARD_BLUE				equ 147
IDI_BACKWARD_ORANGE             equ 175
IDI_FORWARD_BLUE                equ 149
IDI_FORWARD_ORANGE              equ 150
IDI_LOOP_BLUE                   equ 151
IDI_LOOP_ORANGE                 equ 152
IDI_MUTE_BLUE                   equ 153
IDI_MUTE_ORANGE                 equ 154
IDI_NEXT_BLUE                   equ 155
IDI_NEXT_ORANGE                 equ 156
IDI_PLAY_ORANGE                 equ 158
IDI_PRE_BLUE                    equ 159
IDI_PRE_ORANGE                  equ 160
IDI_RANDOM_BLUE                 equ 161
IDI_RANDOM_ORANGE               equ 162
IDI_SINGLE_BLUE                 equ 163
IDI_SINGLE_ORANGE               equ 164
IDI_SUSPEND_BLUE                equ 165
IDI_SUSPEND_ORANGE              equ 166
IDI_VOLUM_BLUE                  equ 167
IDI_VOLUM_ORANGE                equ 168
IDI_CLEAN_SONG					equ	176
IDI_ADD_SONG_BLUE               equ	177
IDI_ADD_SONG_ORANGE             equ	178
IDI_NEW_LIST                    equ	179
IDI_REMOVE_LIST                 equ	180
IDI_REMOVE_SONG                 equ	181

WINDOW_WIDTH					equ 1080 ; ���ڿ��
WINDOW_HEIGHT					equ 675  ; ���ڸ߶�
PLAY_WIDTH						equ 40	 ; ���ż����
NEXT_WIDTH						equ 30	 ; ��һ�׼����
;---------------- process --------------------
DO_NOTHING			equ 0 ; �ض��ķ���ֵ��ʶ
DEFAULT_SONG_GROUP  equ 99824 ; Ĭ����𱻷��䵽�ı�� ; todo : change 99824 to 0
DEFAULT_PLAY_SONG   equ 21474 ; Ĭ�ϵĵ�index�׸� ; todo : change 21474 to a larger num

FILE_DO_EXIST		equ 0 ; �ļ�����
FILE_NOT_EXIST		equ 1 ; �ļ�������

STATE_PAUSE equ 0 ; ��ͣ����
STATE_PLAY equ 1 ; ���ڲ���
STATE_STOP equ 2 ; ֹͣ����


DELETE_ALL_SONGS_IN_GROUP	equ 0 ;ɾ��songGroup(dword)������и�
DELETE_CURRENT_PLAY_SONG	equ 1 ;ɾ��ѡ�е����׸裨current play song��
DELETE_INVALID				equ 2 ;ɾ�����в����ڵ�·����Ӧ�ĸ�

MAX_FILE_LEN equ 1000 ; ��ļ�����
MAX_GROUP_DETAIL_LEN equ 32 ; ����ŵ������
MAX_GROUP_NAME_LEN equ 20 ; �赥���Ƶ������
MAX_GROUP_SONG equ 30 ; �赥�ڸ����������
MAX_GROUP_NUM equ 10 ; ���ĸ赥����
MAX_SONG_NAME_LEN equ 100; �����������ֵĳ��� ;todotodotodo

MAX_ALL_SONG_NUM equ 300 ; ȫ������������Ŀ��=MAX_GROUP_SONG * MAX_GROUP_NUM��

; ʵ�����LENӦ��-1�� ������Ϊstr�����ҪΪ0���������ʱ���Խ����Ĵ洢����

SAVE_TO_MAIN_DIALOG_GROUP		equ 1 ; ������չʾ�ã���������ǰ�赥
SAVE_TO_TARGET_GROUP		equ 2 ; ���������ã�����������ҳ�ĵ�ǰ�赥
SAVE_TO_DEFAULT_GROUP		equ 3 ; �赥�����ã�����������ҳ��Ĭ�ϸ赥


; +++++++++++++++++ function ++++++++++++++++
DialogMain proto, ; �Ի������߼�
	hWin : dword,
	uMsg : dword,
	wParam : dword,
	lParam : dword

ImportSingleFile proto, ; ���뵥���ļ�����ǰ�赥
	hWin : dword

AddSingleSongOFN proto,  ; ���ImportSingleFile���Ѹոն�����ļ�����songGroup
	songGroup : dword

GetGroupDetailInStr proto, ; ��ȡcurrentPlayGroup��str��ʽ
	songGroup : dword

GetCurrentGroupSong proto ; ��data.txt�ж�ȡ��ǰ��ĸ���

GetTargetGroupSong proto, ; ��ȡ��������Ϊ1. SAVE_T_MAIN_DIALOG_GROUP ��������songGroup�ĸ�������currentGroupSongs
	songGroup : dword,
	saveTo: dword

song struct ; ������Ϣ�ṹ��
	path byte MAX_FILE_LEN dup(0)
	groupid dword DEFAULT_SONG_GROUP ; ����������groupid
; TODO : ����������Ϣ
song ends

songgroup struct ; �赥��Ϣ�ṹ��
	groupid dword DEFAULT_SONG_GROUP
	groupname byte MAX_GROUP_NAME_LEN dup(0)
songgroup ends

CollectSongPath proto, ; ��songPath���Ƶ���Ӧ��targetPath��ȥ
	songPath : dword,
	targetPath : dword

CollectSongName proto, ; ��songName���Ƶ�targetName��
	songName : dword,
	targetName : dword


ShowMainDialogView proto, ; ˢ����ҳd��list box
	hWin : dword

SelectGroup proto, ; ѡ�е�ǰGroup
	hWin : dword

GetAllGroups proto, ; ��ѯ���е�group, ����Ĭ�����õ�0���赥Ϊ����赥
	hWin : dword

AddNewGroup proto, ; ����һ���µ�group
	hWin : dword

DeleteCurrentGroup proto, ; ɾ����ǰgroup
	hWin : dword

SelectSong proto, ; ѡ�е�ǰ���ŵĸ���
	hWin : dword
; todo
	
DeleteTargetSong proto, ; ɾ��Ŀ�����
	hWin : dword,
	method : dword, 
	songGroup : dword
; ��Ϊ����ɾ����method: 
; DELETE_ALL_SONGS_IN_GROUP	:ɾ��songGroup(dword)������и�, ��Ҫָ��songGroup
; DELETE_CURRENT_PLAY_SONG	:ɾ��ѡ�е����׸裨current play song��
; DELETE_INVALID			:ɾ�����в����ڵ�·����Ӧ�ĸ�

GetAllSongInData proto ; �����еĸ����洢��delAllSongs,

DeleteCurrentPlaySong proto, 
	hWin : dword 

StartAddNewGroup proto ; ��ʼ�����¸赥�ĳ���

NewGroupMain proto, ; �����赥�ĶԻ���������
	hWin: dword,
	uMsg : dword,
	wParam : dword,
	lParam : dword

CheckFileExist proto, ; ��ȡһ���ַ���targetPath(pointer)���ж϶�Ӧ���ļ��Ƿ���ڣ���������eax��
	targetPath : dword


DeleteInvalidSongs proto,
	hWin : dword
	

ChangeTheme proto,	; ����Ƥ��
	hWin : dword

; �������¼�
LButtonDown proto, 
	hWin : dword, 
	wParam : dword, 
	lParam : dword

KeyDown proto, 
	hWin : dword, 
	wParam : dword, 
	lParam : dword

; ���沼��
InitUI proto, 
	hWin : dword, 
	wParam : dword,
	lParam : dword

PlayMusic proto, ; ����/��ͣ����	
	hWin : dword

PauseCurrentSong proto ; ��ͣ��ǰ����

PlayCurrentSong proto, ; ��ͷ���ŵ�ǰ����
	hWin : dword 

ResumeCurrentSong proto ; ������ǰ����

AlterVolume proto, ; ����������С
	hWin : dword

CheckPlayCurrentSong proto, ; ��ͼ���ŵ�ǰ�ĸ���currentPlaySingleSongPath
	hWin : dword
; eax = 0 �����ܹ����ţ�1.ûѡ�и�����2.���������ڣ�
; eax = 1 ����ǰѡ���˸����Ҹ�������



Paint proto, 
	hWin :dword
; +++++++++++++++++++ data +++++++++++++++++++++
.data

;--------mci����--------
cmd_open BYTE 'open "%s" alias mySong type mpegvideo',0
cmd_close BYTE "close mySong",0
cmd_play BYTE "play mySong", 0	
cmd_pause BYTE "pause mySong",0
cmd_resume BYTE "resume mySong",0
cmd_getLen BYTE "status mySong length", 0
cmd_getPos BYTE "status mySong position", 0
cmd_setPos BYTE "seek mySong to %d", 0
cmd_setStart BYTE "seek mySong to start", 0	
cmd_setVol BYTE "setaudio mySong volume to %d",0
;----------------------

rect RECT <0, 0, 1080, 675>

mciCommand BYTE 200 DUP(0)
playState BYTE 2
volume DWORD 100
isMuted BYTE 0

intFormat BYTE "%d", 0

handler HANDLE ? ; �ļ����
divideLine byte 0ah ; ����divideLine

currentPlaySingleSongIndex dword DEFAULT_PLAY_SONG; Ŀǰ���ڲ��ŵĸ�����Ϣ
currentPlaySingleSongPath byte MAX_FILE_LEN dup(0); Ŀǰ���ڲ��Ÿ�����·��

currentPlayGroup dword DEFAULT_SONG_GROUP ; Ŀǰ���ڲ��ŵĸ赥���
groupDetailStr byte MAX_GROUP_DETAIL_LEN dup("a") ; Ŀǰ���ڲ��ŵĸ赥��ŵ�str��ʽ�� ��Ҫ����GetGroupDetailInStr�Ը���

; �赥��Ϊ�Զ���赥��Ĭ�ϸ赥��Ĭ�ϸ赥����ȫ��������

numCurrentGroupSongs dword 0 ; ��ǰ���Ÿ赥�ĸ�������
currentGroupSongs song MAX_GROUP_SONG dup(<,>) ; ��ǰ���Ÿ赥�����и�����Ϣ

maxGroupId dword 0

; ++++++++++++++ɾ�������������ʱ�洢����++++++++++++++
; ++++ �㲻Ӧ�ڳ���ɾ������֮��ĺ���������Щ���� +++++++
delAllGroups songgroup MAX_GROUP_NUM dup(<,>)
delAllSongs song MAX_ALL_SONG_NUM dup(<,>)

; ++++++++++++++�����ļ�OPpenFileName�ṹ++++++++++++++
ofn OPENFILENAME <>
ofnTitle BYTE '��������', 0	
ofnFilter byte "Media Files(*mp3, *wav)", 0, "*.mp3;*.wav", 0, 0

; ++++++++++++++Message Box ��ʾ��Ϣ++++++++++++++++++
deleteNone byte "��û��ѡ�и赥������ɾ����",0
addNone byte "��û��ѡ�и赥�����ܵ��������", 0
deleteSongNone byte "��û��ѡ�и���������ɾ����", 0
playSongNone byte "��û��ѡ�и��������ܲ��š�", 0
playSongInvalid byte "��ѡ�еĸ��������ڣ����Զ�Ϊ��ɾ�������ڵĸ�����"


; +++++++++++++++�������貿�ִ��ڱ���+++++++++++++++
hInstance dword ?
hMainDialog dword ?
hNewGroup dword ?

; +++++++++++++++������Ϣ+++++++++++(��Ϊ���Զ�ע��)
;songData BYTE ".\data.txt", 0
;ofnInitialDir BYTE "C:", 0 ; default open C
;groupData byte ".\groupdata.txt", 0

; +++++++++++++������������++++++++++++�����ܿ��Ա�local�����

readGroupDetailStr byte MAX_GROUP_DETAIL_LEN   dup(0)
currentSongNameOFN byte MAX_FILE_LEN dup(0)
readFilePathStr byte MAX_FILE_LEN  dup(0)
readSongNameStr byte MAX_SONG_NAME_LEN dup(0)
buffer byte 0

readGroupNameStr byte MAX_GROUP_NAME_LEN dup(0)

inputGroupNameStr byte MAX_GROUP_NAME_LEN dup("1")
; to change "1" -> 0

; ++++++++++++++����ר��+++++++++++++ 
; ++++++++������Լ��Ļ���·���޸�+++++++++
; TODO-TODO-TODO-TODO-TODO-TODO-TODO
simpleText byte "somethingrighthere", 0ah, 0
ofnInitialDir BYTE "D:\music", 0 ; default open C only for test
songData BYTE "C:\Users\dell\Desktop\data\data.txt", 0 
testint byte "TEST INT: %d", 0ah, 0dh, 0
groupData byte "C:\Users\dell\Desktop\data\groupdata.txt", 0

; ͼ����Դ����
bmp_Theme_Blue			dword	?	; ��ɫ���ⱳ��
bmp_Theme_Orange		dword	?	; ��ɫ���ⱳ��
bmp_Add_Song_Blue		dword	?	; ��ɫ��Ӹ���
bmp_Add_Song_Orange		dword	?	; ��ɫ��Ӹ���
bmp_Clean_Song			dword	?	; �����Ч����
bmp_New_List			dword	?	; �½��赥
bmp_Remove_List			dword	?	; ɾ���赥
bmp_Remove_Song			dword	?	; ɾ������
ico_Play_Blue			dword	?	; ��ɫ����ͼ��
ico_Play_Orange         dword	?	; ��ɫ����ͼ��
ico_Backward_Blue		dword	?	; ��ɫ����ͼ��
ico_Backward_Orange		dword	?	; ��ɫ����ͼ��
ico_Forward_Blue		dword	?	; ��ɫ���ͼ��
ico_Forward_Orange		dword	?	; ��ɫ���ͼ��
ico_Loop_Blue			dword	?	; ��ɫѭ��ͼ��
ico_Loop_Orange			dword	?	; ��ɫѭ��ͼ��
ico_Mute_Blue			dword	?	; ��ɫ����ͼ��
ico_Mute_Orange			dword	?	; ��ɫ����ͼ��
ico_Next_Blue			dword	?	; ��ɫ��һ��ͼ��
ico_Next_Orange			dword	?	; ��ɫ��һ��ͼ��
ico_Pre_Blue			dword	?	; ��ɫ��һ��ͼ��
ico_Pre_Orange			dword	?	; ��ɫ��һ��ͼ��
ico_Random_Blue			dword	?	; ��ɫ�������
ico_Random_Orange		dword	?	; ��ɫ�������
ico_Single_Blue			dword	?	; ��ɫ����ѭ��
ico_Single_Orange		dword	?	; ��ɫ����ѭ��
ico_Suspend_Blue		dword	?	; ��ɫ��ͣ
ico_Suspend_Orange		dword	?	; ��ɫ��ͣ
ico_Volum_Blue			dword	?	; ��ɫ����
ico_Volum_Orange		dword	?	; ��ɫ����
ico_Clean_Song			dword	?	; �������
ico_Add_Song_Blue		dword	?	; ��ɫ��Ӹ���
ico_Add_Song_Orange		dword	?	; ��ɫ��Ӹ���
ico_New_List			dword	?	; �½��赥
ico_Remove_List			dword	?	; ɾ���赥
ico_Remove_Song			dword	?	; ɾ������
curTheme	word	0	; ��ǰ������
; +++++++++++++++code++++++++++++++++++
.code

WinMain PROC
	INVOKE GetModuleHandle, NULL
	mov hInstance, eax
	invoke DialogBoxParam, hInstance, IDD_DIALOG, 0, addr DialogMain, 0
	invoke ExitProcess, 0
WinMain ENDP

DialogMain proc,
	hWin : dword,
	uMsg : dword,
	wParam : dword,
	lParam : dword

	local loword : word
	local hiword : word
	local currentSlider : dword

	mov	eax, wParam ; WParam = (hiword, lowrd) : ���notification code
	mov	loword, ax
;	mov	hiword, 
	shrd eax, ebx, 16
	mov	hiword, ax

	.if	uMsg == WM_INITDIALOG
		; invoke SetWindowPos, hWin, HWND_TOPMOST, 200, 100, 1080, 675, 0
		invoke InitUI, hWin, wParam, lParam
;		invoke MoveWindow, hWin, 100, 100, 1080, 600, 0

		invoke GetWindowRect, hWin, addr rect
		;invoke 
		invoke GetDlgItem, hWin, IDC_BACKGROUND ; �̶�����
;		invoke GetWindowRect, eax, addr rect

		mov	ecx, rect.right
		sub ecx, rect.left
		mov ebx, rect.bottom
		sub ebx, rect.top

		invoke MoveWindow, eax, 0, 0, ecx, ebx, 0

;		invoke GetDlgItem, hWin, IDC_MAIN_GROUP 
;		invoke MoveWindow, eax, 260, 236 + 20, 662, 296, 0 ; ����maingroup�����Ͻ�����+����ڸ߶�

;		invoke GetDlgItem, hWin, IDC_SOUND
;		invoke MoveWindow, eax, 850, 560 + 40, 200, 22, 0 ; ����maingroup�����Ͻ�����+����ڸ߶�
		; ����test.rc�����꣪2�õ�����dialog����������
		; ���һ��ƫ������Ӧ������Ŀؼ�Ʈ��

		; todo
		push hWin
		pop hMainDialog
		invoke GetAllGroups, hWin
		invoke ShowMainDialogView, hWin

		;��ʼ��������
		invoke SendDlgItemMessage, hWin, IDC_SOUND, TBM_SETRANGEMIN, 0, 0
		invoke SendDlgItemMessage, hWin, IDC_SOUND, TBM_SETRANGEMAX, 0, 1000
		invoke SendDlgItemMessage, hWin, IDC_SOUND, TBM_SETPOS, 1, 1000
		;��ʼ������ֵ
		mov volume, 1000
		invoke wsprintf, addr mciCommand, addr intFormat, 100
		invoke SendDlgItemMessage, hWin, IDC_SOUND_TEXT, WM_SETTEXT, 0, addr mciCommand
		; do something
	.elseif uMsg == WM_KEYDOWN
		; DEBUG: ���¿ո�󱻰�ť�ػ�
		invoke KeyDown, hWin, wParam, lParam
	.elseif	uMsg == WM_COMMAND
		.if loword == IDC_FILE_SYSTEM
			invoke ImportSingleFile, hWin
			invoke ShowMainDialogView, hWin
		.elseif loword == IDC_GROUPS
			.if hiword == CBN_SELCHANGE
				invoke SelectGroup, hWin ; TODO
				invoke ShowMainDialogView, hWin
			.endif
		.elseif loword == IDC_ADD_NEW_GROUP
			invoke StartAddNewGroup
			invoke ShowMainDialogView, hWin
		.elseif loword == IDC_DELETE_CURRENT_GROUP	
			.if hiword == BN_CLICKED
				invoke DeleteCurrentGroup, hWin
				invoke ShowMainDialogView, hWin
			.endif
		.elseif loword == IDC_MAIN_GROUP
			.if hiword == LBN_SELCHANGE
				invoke SelectSong, hWin
			.endif
		.elseif loword == IDC_DELETE_CURRENT_SONG
			.if hiword == BN_CLICKED
				invoke DeleteCurrentPlaySong, hWin
				invoke ShowMainDialogView, hWin
			.endif
		.elseif loword == IDC_DELETE_INVALID_SONGS
			.if hiword == BN_CLICKED
				invoke DeleteInvalidSongs, hWin
				invoke ShowMainDialogView, hWin
			.endif
		.elseif loword == IDC_PLAY_BUTTON
			.if hiword == BN_CLICKED
				invoke PlayMusic, hWin
			.endif
		.elseif loword == IDC_MUTE_SONG
			.if hiword == BN_CLICKED
				xor isMuted, 1
				invoke AlterVolume, hWin
			.endif
		.else
			; do something
		.endif
	.elseif uMsg == WM_LBUTTONDOWN	; �������
		invoke LButtonDown, hWin, wParam, lParam
	.elseif	uMsg == WM_CLOSE
		invoke EndDialog,hWin,0
		.if hNewGroup != 0
			invoke EndDialog, hNewGroup, 0
		.endif
	.elseif uMsg == WM_HSCROLL
		invoke GetDlgCtrlID, lParam
		mov currentSlider, eax ; ��ȡ�ؼ�ID

		.if currentSlider == IDC_SOUND
			.if loword == SB_THUMBTRACK
				invoke AlterVolume, hWin
			.endif
		.endif
	.endif

	xor eax, eax ; eax = 0
	ret
DialogMain endp

ImportSingleFile proc,
	hWin : dword

	.if currentPlayGroup == DEFAULT_SONG_GROUP ; �����ǰδѡ��赥����ʾ����
		invoke MessageBox, hWin, addr addNone, 0, MB_OK
		ret
	.endif

	invoke  RtlZeroMemory, addr ofn, sizeof ofn ; ��OpenFileName�ṹ����0

	mov ofn.lStructSize, sizeof OPENFILENAME

	push hWin
	pop ofn.hwndOwner ; hwndOwner = hWin

	mov ofn.lpstrTitle, OFFSET ofnTitle ; ���ô��ļ��е�Tirle
	mov ofn.lpstrInitialDir, OFFSET ofnInitialDir ; ����Ĭ�ϴ��ļ���
	mov	ofn.nMaxFile, MAX_FILE_LEN ; �����ļ����ĳ���
	mov	ofn.lpstrFile, OFFSET currentSongNameOFN  ; ������Ҫ�򿪵��ļ������Ƶ�ָ��
	mov	ofn.lpstrFilter, offset ofnFilter ; ���ô��ļ���������
	mov ofn.Flags, OFN_HIDEREADONLY ; ������ֻ��ģʽ�򿪵İ�ť

	invoke GetOpenFileName, addr ofn ; ���ô��ļ���ϵͳ�Ի���

	.if eax == DO_NOTHING ;  todo: ���û��, ֱ��ret
		jmp EXIT_IMPORT
	.endif

	invoke AddSingleSongOFN, currentPlayGroup ; ����򿪳ɹ�����ô���ø������뵱ǰ�赥

EXIT_IMPORT:
	xor eax, eax ; eax = 0
	ret
ImportSingleFile endp

AddSingleSongOFN proc,
	songGroup : dword

	LOCAL BytesWritten : dword ; �����ļ�д���ָ��
	LOCAL handler_saved : dword ; ����handler
	LOCAL lpstrLength : dword ; ���Ƴ���


	invoke GetGroupDetailInStr, songGroup ; ��ȡdword songGroup������д���ļ���strģʽ

    INVOKE  CreateFile,offset songData,GENERIC_WRITE, 0, 0,OPEN_ALWAYS,FILE_ATTRIBUTE_NORMAL,0 ; ���ļ�
	mov		handler, eax
	mov		handler_saved, eax

	invoke SetFilePointer, handler, 0, 0, FILE_END ; ��ָ���ƶ���ĩβ

	invoke lstrlen, ofn.lpstrFile
	mov	 lpstrLength, eax ; ����openfilename���ļ����Ƴ���

	invoke WriteFile, handler, addr divideLine, length divideLine,  addr BytesWritten, NULL ; д���з�
	invoke WriteFile, handler, addr groupDetailStr, MAX_GROUP_DETAIL_LEN , addr BytesWritten, NULL ; дsong Group��strģʽ

	invoke WriteFile, handler, addr divideLine, length divideLine,  addr BytesWritten, NULL ; д���з�
	invoke WriteFile, handler, ofn.lpstrFile, MAX_FILE_LEN, addr BytesWritten, NULL ;д��ǰ�ļ���·��

	invoke CloseHandle, handler_saved ; �رյ�ǰ���ļ����

	ret
AddSingleSongOFN endp

GetGroupDetailInStr proc,
	songGroup : dword
	invoke  RtlZeroMemory, addr groupDetailStr, sizeof groupDetailStr ; clear groupDetailStr
	invoke dw2a, songGroup, addr groupDetailStr ; ��dword songGroup��str��ʽ�洢��groupDetailStr��
	ret
GetGroupDetailInStr endp

GetCurrentGroupSong proc
	invoke GetTargetGroupSong, currentPlayGroup, SAVE_TO_MAIN_DIALOG_GROUP ; ��ȡ��ǰ���ŵĸ赥�ĸ�����Ϣ
	ret
GetCurrentGroupSong endp

GetTargetGroupSong proc,
	songGroup : dword, ; ��ȡ��һ���赥
	saveTo : dword ; ��Ӧ����һ�ֻ�ȡģʽ
	; SAVE_TO_MAIN_DIALOG_GROUP : ��ȡ��ǰ���ŵĸ赥

	LOCAL BytesRead : dword ; ---
	LOCAL handler_saved : dword ; ---
	LOCAL lpstrLength : dword

	LOCAL counter : dword

    invoke  CreateFile,offset songData,GENERIC_READ, 0, 0,OPEN_ALWAYS,FILE_ATTRIBUTE_NORMAL,0 ; �򿪸赥�����ļ�
	mov		handler, eax

	.if saveTo == SAVE_TO_MAIN_DIALOG_GROUP ; �����Ҫ��ȡ��ǰ���ŵĸ赥
		mov	 esi, offset currentGroupSongs
	.endif

	mov	counter, 0
REPEAT_READ:
	invoke ReadFile, handler, addr buffer, length divideLine,  addr BytesRead, NULL ; �����з�
	.if BytesRead == 0 ; �����ļ�ĩβ������
		jmp END_READ
	.endif
	invoke ReadFile, handler, addr readGroupDetailStr, MAX_GROUP_DETAIL_LEN , addr BytesRead, NULL ; ��group��Ϣ

	invoke ReadFile, handler, addr buffer, length divideLine,  addr BytesRead, NULL ; �����з�
	invoke ReadFile, handler, addr readFilePathStr, MAX_FILE_LEN, addr BytesRead, NULL ; ���ļ�·��

	invoke atol, addr readGroupDetailStr ;ת���ַ�����ʽ��group��Ϣ��dword
	.if eax > maxGroupId ; ���õ�ǰ����maxGroupId
		mov maxGroupId, eax
	.endif
	.if eax == songGroup ; ������������׸�����������Ҫ���ŵĸ赥
		push esi
		invoke CollectSongPath, addr readFilePathStr, addr (song ptr [esi]).path ;��readFilePathStr��������·�����Ƶ�currentGroupSongs����һ���ṹ����
		push songGroup
		pop	(song ptr [esi]).groupid ; �洢��Ӧ��group id
		pop esi
		add	esi, SIZE song ; ��ַ�Ƶ�currentPlaySong����һ��struct
		inc counter ; ������+1
	.endif
	

	jmp REPEAT_READ
END_READ:
	invoke CloseHandle, handler

	.if saveTo == SAVE_TO_MAIN_DIALOG_GROUP  
		push counter
		pop numCurrentGroupSongs ; ����������ֵ�洢����ǰ�赥������
	.endif

	ret
GetTargetGroupSong endp

CollectSongPath proc,
	songPath : dword,
	targetPath : dword ; ��songPath���Ƶ�targetPath���临�Ƶ��������ļ�����-1
	
	mov	esi, songPath
	mov	edi, targetPath
	mov	ecx, MAX_FILE_LEN - 1
	cld
	rep movsb
	ret

CollectSongPath endp

ShowMainDialogView proc,
	hWin : dword
	LOCAL	counter : dword

	invoke SendDlgItemMessage, hWin, IDC_MAIN_GROUP, LB_RESETCONTENT, 0, 0 ; clear listbox�������
	invoke GetCurrentGroupSong ; ��ȡ��ǰ�赥�ĸ���

	push numCurrentGroupSongs
	pop	 counter ; ���ü�����

	mov	esi, offset currentGroupSongs ; ����ָ��

PRINT_LIST:
	.if counter == 0
		jmp END_PRINT
	.endif

	push esi
	invoke GetFileTitle, addr (song ptr [esi]).path, addr readSongNameStr, MAX_SONG_NAME_LEN - 1
	invoke SendDlgItemMessage, hWin, IDC_MAIN_GROUP, LB_ADDSTRING, 0, addr readSongNameStr  ;�����Ƽ���listbox
	pop esi
	add	esi, size song
	dec counter ; ������-1
	jmp PRINT_LIST

END_PRINT:
	ret
ShowMainDialogView endp

SelectGroup proc,
	hWin : dword
	local indexToSet : dword ; ��ѡ���index
	local BytesRead : dword ; ������ָ��
	local handler_saved : dword ; ����handler
	local counter : dword ; ������

	invoke SendDlgItemMessage, hWin, IDC_GROUPS, CB_GETCURSEL, 0, 0 
	mov	indexToSet, eax ; ��ȡ��ǰ��ѡ�е�group index

	.if eax == CB_ERR ; ���û��ѡ��group
		mov currentPlayGroup, DEFAULT_SONG_GROUP ; ��ô��������û��ѡ�и赥
		invoke SelectSong, hWin ; ͬʱ��������ѡ��ĸ���
		ret
	.endif

    invoke  CreateFile,offset groupData,GENERIC_READ, 0, 0,OPEN_ALWAYS,FILE_ATTRIBUTE_NORMAL,0 ; ��groupdata.txt��ȡgroup��ص���Ϣ
	mov		handler, eax

	mov		esi, 0 ; ��������0

REPEAT_READ:
	push esi ; ����esi
	invoke ReadFile, handler, addr buffer, length divideLine,  addr BytesRead, NULL ; �����з�
	.if BytesRead == 0 ; �����ļ�ĩβ
		jmp END_READ
	.endif
	invoke ReadFile, handler, addr readGroupDetailStr, MAX_GROUP_DETAIL_LEN , addr BytesRead, NULL ; ��songGroup��str��ʽ

	invoke ReadFile, handler, addr buffer, length divideLine,  addr BytesRead, NULL ; �����з�
	invoke ReadFile, handler, addr readGroupNameStr, MAX_GROUP_NAME_LEN, addr BytesRead, NULL ; ��songGroup��name
	pop esi ; �ָ�esi

	.if esi == indexToSet ; �ҵ��˵�esi�������Ϣ
		invoke atol, addr readGroupDetailStr ; ��songGroup�ı�Ŵ�strת��Ϊeax
		mov currentPlayGroup, eax ; ����currentPlayGroup���
		jmp END_READ ;����
	.endif
	inc esi
	jmp REPEAT_READ
END_READ:
	invoke CloseHandle, handler ; �ر�handler

	invoke SendDlgItemMessage, hWin, IDC_MAIN_GROUP, LB_SETCURSEL, -1, 0 ;Ĭ��ѡ��song0
	invoke SelectSong, hWin ; ѡ���Ӧ��song
	xor eax, eax ; eax = 0
	ret
SelectGroup endp

AddNewGroup proc,
	hWin : dword

	local handler_saved : dword ; ---
	local BytesWritten : dword ; ����д��ָ��

    invoke  CreateFile,offset groupData,GENERIC_WRITE, 0, 0,OPEN_ALWAYS,FILE_ATTRIBUTE_NORMAL,0 ; ��groupdata.txt��ȡ�����Ϣ
	mov		handler, eax
	mov		handler_saved, eax

	invoke SetFilePointer, handler, 0, 0, FILE_END ; ���ļ�ָ�����õ�ĩβ

	invoke RtlZeroMemory, addr readGroupNameStr, sizeof readGroupNameStr ; ��readGroupNameStr������0
	mov	readGroupNameStr, MAX_GROUP_NAME_LEN - 1 ;Ϊ��ʹ��EM_GELINE,��readGroupNameStr�ĵ�һ��λ����ΪҪ��ȡ�ĳ���
	invoke SendDlgItemMessage, hWin, IDC_NEW_GROUP_NAME, EM_GETLINE, 0, addr readGroupNameStr ;��ȡedit control���û����������

	add		maxGroupId, 1; ����maxGroupId
	invoke GetGroupDetailInStr, maxGroupId ; ����������ظ���maxGroupId������µ�group

	invoke WriteFile, handler, addr divideLine, length divideLine,  addr BytesWritten, NULL ; д���з�
	invoke WriteFile, handler, addr groupDetailStr, MAX_GROUP_DETAIL_LEN, addr BytesWritten, NULL ; дgroup��id��str��ʽ

	invoke WriteFile, handler, addr divideLine, length divideLine,  addr BytesWritten, NULL ; д���з�
	invoke WriteFile, handler, addr readGroupNameStr, MAX_GROUP_NAME_LEN, addr BytesWritten, NULL ; дgroup��name

	invoke CloseHandle, handler_saved ; �ر�handler

	invoke SendDlgItemMessage, hMainDialog, IDC_GROUPS, CB_ADDSTRING, 0, addr readGroupNameStr ; ��������赥ѡ��������

	invoke SendDlgItemMessage, hMainDialog, IDC_GROUPS, CB_GETCOUNT, 0, 0 ; ��ȡ�����ж��ٸ��赥
	dec eax
	invoke SendDlgItemMessage, hMainDialog, IDC_GROUPS, CB_SETCURSEL, eax, 0 ; ����ǰѡ��ĸ赥����Ϊ�¼���������index = numGroup - 1��

	invoke SelectGroup, hMainDialog ; ѡ��ǰ��
	ret
AddNewGroup endp

GetAllGroups proc,
	hWin : dword

	local BytesRead : dword ; �����ָ��

    invoke  CreateFile,offset groupData,GENERIC_READ, 0, 0,OPEN_ALWAYS,FILE_ATTRIBUTE_NORMAL,0 ; ��groupData.txt��ȡ�����Ϣ
	mov		handler, eax

	invoke SendDlgItemMessage, hWin, IDC_GROUPS, CB_RESETCONTENT, 0, 0 ; ���group������
REPEAT_READ:
	invoke ReadFile, handler, addr buffer, length divideLine,  addr BytesRead, NULL ; �����з�
	.if BytesRead == 0 ; �����ļ�ĩβ������
		jmp END_READ
	.endif
	invoke ReadFile, handler, addr readGroupDetailStr, MAX_GROUP_DETAIL_LEN , addr BytesRead, NULL ;������id

	invoke ReadFile, handler, addr buffer, length divideLine,  addr BytesRead, NULL ; �����з�
	invoke ReadFile, handler, addr readGroupNameStr, MAX_GROUP_NAME_LEN, addr BytesRead, NULL; ��group��name

	invoke SendDlgItemMessage, hWin, IDC_GROUPS, CB_ADDSTRING, 0, addr readGroupNameStr ; ��group��name����������

	jmp REPEAT_READ
END_READ:
	invoke CloseHandle, handler ; �ر�handler

	invoke SendDlgItemMessage, hWin, IDC_GROUPS, CB_SETCURSEL, 0, 0 ;Ĭ��ѡ���0��group
	invoke SelectGroup, hWin; ѡ���group

	ret
GetAllGroups endp

StartAddNewGroup proc
	invoke DialogBoxParam, hInstance, IDD_DIALOG_ADD_NEW_GROUP, 0, addr NewGroupMain, 0 ; �������½��赥���ƵĶԻ���
	ret
StartAddNewGroup endp

NewGroupMain proc,
	hWin : dword, 
	uMsg : dword,
	wParam : dword,
	lParam : dword

	.if	uMsg == WM_INITDIALOG
		push hWin
		pop hNewGroup ; �洢��ǰ�Ի���ľ�����Ա��ڸ����ڹر�ʱ�ر�
		invoke SendDlgItemMessage, hWin, IDC_NEW_GROUP_NAME, EM_LIMITTEXT, MAX_GROUP_NAME_LEN - 1, 0 ; ��������赥���Ƶ�edit control�ĳ�������
	.elseif	uMsg == WM_COMMAND
		.if wParam == IDC_BUTTON_ADD_NEW_GROUP ; ���ȷ�ϼ���赥
			invoke AddNewGroup, hWin ; ����赥
			invoke EndDialog, hWin, 0 ; ������ϣ��رմ���
		.endif
	.elseif	uMsg == WM_CLOSE
		mov hNewGroup, 0 ; �رմ��ڣ�������ǰ�����Ϊ0�����ⱻ�������ظ��ر�
		invoke EndDialog,hWin,0
	.else
	.endif

	xor eax, eax ; eax = 0
	ret
NewGroupMain endp

DeleteCurrentGroup proc, ; ɾ����ǰѡ��ĸ赥
	hWin : dword

	local BytesRead : dword ; ���ڶ���ָ��
	local BytesWritten : dword ; ����д��ָ��
	local currentSelect : dword ; ��ǰѡ�����Ҫ��ɾ����group
	local counter : dword ; ������

	invoke SelectGroup, hWin ;���µ�ǰѡ���group��Ϣ
	.if currentPlayGroup == DEFAULT_SONG_GROUP ; �����ǰû��ѡ��赥����ô��ʾ����
		invoke MessageBox, hWin, addr deleteNone, 0, MB_OK
		ret
	.endif

	invoke DeleteTargetSong, hWin, DELETE_ALL_SONGS_IN_GROUP, currentPlayGroup 
	; ����DeleteTargetSong, ָ��method��ɾ���ڵ�ǰ����ڵ����и�����
	; ���ú��������ڸ���ĸ�����data.txt�б�ɾ����

    invoke  CreateFile,offset groupData,GENERIC_READ, 0, 0,OPEN_ALWAYS,FILE_ATTRIBUTE_NORMAL,0 ; ���ļ�
	mov		handler, eax ; ����handler
	mov		esi, offset delAllGroups ; ����esi��delAllGroups��ʼд

	mov		counter, 0 ; ��������0
REPEAT_READ:
	invoke ReadFile, handler, addr buffer, length divideLine,  addr BytesRead, NULL ; �����з�
	.if BytesRead == 0;����ĩβ
		jmp END_READ
	.endif
	invoke ReadFile, handler, addr readGroupDetailStr, MAX_GROUP_DETAIL_LEN , addr BytesRead, NULL ; ��groupid��str��ʽ

	invoke atol, addr readGroupDetailStr ;��group idת��Ϊdword
	mov (songgroup ptr [esi]).groupid, eax ;��dword��ʽ��group id���delAllGroups[]�Ķ�Ӧλ��

	invoke ReadFile, handler, addr buffer, length divideLine,  addr BytesRead, NULL ; �����з�
	invoke ReadFile, handler, addr (songgroup ptr [esi]).groupname, MAX_GROUP_NAME_LEN, addr BytesRead, NULL ; ��group��name

	add esi, size songgroup ; �ƶ�����һ��songgroup�ṹ����delAllGroups�����е�λ��
	add counter, 1 ; ������+1
	jmp REPEAT_READ
END_READ:
	invoke CloseHandle, handler

	mov		esi, offset delAllGroups ;��������esi��ָ����delAllGroups�Ŀ�ͷ

	invoke SendDlgItemMessage, hWin, IDC_GROUPS, CB_RESETCONTENT, 0, 0 ; �������ѡ�������������
    invoke  CreateFile,offset groupData,GENERIC_WRITE, 0, 0,CREATE_ALWAYS,FILE_ATTRIBUTE_NORMAL,0 ; ��groupdata.txt�ļ�
	; ����ѡ��create_always��ģʽ�����Ը���֮ǰ�¾ɵ�groupdata��Ϣ
	mov		handler, eax
	invoke SetFilePointer, handler, 0, 0, FILE_BEGIN ; ���ļ�ָ���ƶ�����ͷ

REPEAT_WRITE:
	mov	ebx, (songgroup ptr [esi]).groupid ; �жϵ�ǰ�Ľṹ���Ƿ�Ϊ������Ҫɾ����groupid
	.if ebx != currentPlayGroup ; �����������Ҫɾ����, ����д��groupdata
		invoke WriteFile, handler, addr divideLine, length divideLine,  addr BytesWritten, NULL 

		invoke GetGroupDetailInStr, (songgroup ptr [esi]).groupid
		invoke WriteFile, handler, addr groupDetailStr, MAX_GROUP_DETAIL_LEN, addr BytesWritten, NULL

		invoke WriteFile, handler, addr divideLine, length divideLine,  addr BytesWritten, NULL
		invoke WriteFile, handler, addr (songgroup ptr [esi]).groupname, MAX_GROUP_NAME_LEN, addr BytesWritten, NULL

		invoke SendDlgItemMessage, hWin, IDC_GROUPS, CB_ADDSTRING, 0, addr (songgroup ptr [esi]).groupname ; �������½�group��������
	.endif

	sub counter, 1 ; ������-1
	add	esi, size songgroup ; �ƶ�esi��delAllGroups�е�λ��
	.if counter ==  0
		jmp END_WRITE
	.endif
	jmp REPEAT_WRITE
END_WRITE:
	invoke CloseHandle, handler

	invoke SendDlgItemMessage, hWin, IDC_GROUPS, CB_SETCURSEL, 0, 0 ; Ĭ��ѡ���0��group
	invoke SelectGroup, hWin ; ����group��������Ϣ

	ret
DeleteCurrentGroup endp

SelectSong proc, ; ���õ�ǰ���ŵĸ���
	hWin : dword

	local indexToPlay : dword ; ��ǰӦ�ò��Ÿ�����index

	invoke SendDlgItemMessage, hWin, IDC_MAIN_GROUP, LB_GETCURSEL, 0, 0 ; ��ȡ��ǰѡ�еĸ���
	.if eax == LB_ERR ; ���û��ѡ�У���ô����
		mov currentPlaySingleSongIndex, DEFAULT_PLAY_SONG
		ret
	.endif

	mov	currentPlaySingleSongIndex, eax ; ��index��¼��currentPlaySingleSongIndex��

	mov	ebx, size song 
	mul	ebx ;����Ŀ��song��currentGroupSongs�е�ƫ����

	mov	esi, offset currentGroupSongs ; ����songGroup��ָ��
	add	esi, eax

	invoke CollectSongPath, addr (song ptr [esi]).path, addr currentPlaySingleSongPath ;���Ƶ�ǰ������·����currentPlaySingleSongPath
	ret
SelectSong endp

DeleteTargetSong proc,
	hWin : dword, 
	method : dword, ; ֧�ּ���ɾ����method
	songGroup : dword ; ָ��DELETE_ALL_SONGS_IN_GROUP������ɾ����һ��group

	local counter : dword
	local BytesWrite : dword
;	index : dword

; ��Ϊ����ɾ����method: 
; DELETE_ALL_SONGS_IN_GROUP	:ɾ��songGroup(dword)������и�, ��Ҫָ��songGroup
; DELETE_CURRENT_PLAY_SONG	:ɾ��ѡ�е����׸裨current play song��
; DELETE_INVALID			:ɾ�����в����ڵ�·����Ӧ�ĸ�

	.if method == DELETE_CURRENT_PLAY_SONG ; 
		.if currentPlaySingleSongIndex == DEFAULT_PLAY_SONG
			invoke MessageBox, hWin, addr deleteSongNone, 0, MB_OK ;���ɾ����ǰ���ŵĸ������ҵ�ǰû�в��ŵĸ���������
			ret
		.endif
	.endif

	.if method == DELETE_ALL_SONGS_IN_GROUP
		.if songGroup == DEFAULT_SONG_GROUP
			ret ; ���ɾ��һ���飬������鲻���ڣ�����
		.endif
	.endif

	invoke GetAllSongInData ; ��ȡ����data.txt�еĸ�����Ϣ���洢��delAllSongs֮��
	mov		counter, eax

    invoke  CreateFile,offset songData,GENERIC_WRITE, 0, 0,CREATE_ALWAYS,FILE_ATTRIBUTE_NORMAL,0 ; ��ȡ���еĸ���
	mov		handler, eax
	mov		esi, offset delAllSongs

	invoke SetFilePointer, handler, 0, 0, FILE_BEGIN ; ���ļ�ָ���ƶ�����ͷ
	mov		ecx, 0 ; ecx��¼Ŀǰ��songGroup�ĵ�ecx�׸�

REPEAT_WRITE:
	.if counter == 0
		jmp END_WRITE
	.endif
	dec counter

	mov edx, (song ptr [esi]).groupid ; ��ȡ��ǰ������group
	
	.if edx == currentPlayGroup 
		.if method == DELETE_CURRENT_PLAY_SONG  ; �����ǰ��������currentPlayGroup, ��methodʱDELETE_CURRENT_PLAY_SONG
			.if ecx == currentPlaySingleSongIndex ; ����ǵ�ǰ���ŵĸ���
				add	esi, size song 
				inc ecx ; ������+1
				jmp REPEAT_WRITE
			.endif
			inc ecx ; ������+1
		.endif
	.endif

	.if edx == songGroup  
		.if method == DELETE_ALL_SONGS_IN_GROUP ; �����ǰ��������songGroup����method��DELETE_ALL_SONGS_IN_GROUP
			add esi, size song
			jmp REPEAT_WRITE
		.endif
	.endif

	push ecx ; ����ecx
	.if method == DELETE_INVALID
		push eax
		invoke CheckFileExist, addr (song ptr [esi]).path
		.if eax == FILE_NOT_EXIST ; ���method��DELETE_INVALID�ҵ�ǰ�ļ�������
			pop eax
			add esi, size song
			jmp REPEAT_WRITE
		.endif
		pop eax
	.endif

	;����������������������������ô��������data.txt��Ҳ���ǲ�ɾ����
	invoke WriteFile, handler, addr buffer, length divideLine,  addr BytesWrite, NULL
	invoke GetGroupDetailInStr, (song ptr [esi]).groupid
	invoke WriteFile, handler, addr groupDetailStr, MAX_GROUP_DETAIL_LEN , addr BytesWrite, NULL

	invoke WriteFile, handler, addr buffer, length divideLine,  addr BytesWrite, NULL
	invoke WriteFile, handler, addr (song ptr [esi]).path, MAX_FILE_LEN, addr BytesWrite, NULL
	pop ecx ; �ָ�ecx

	add	esi, size song
	jmp REPEAT_WRITE
END_WRITE:
	invoke CloseHandle, handler
	ret
DeleteTargetSong endp

GetAllSongInData proc ; ��ȡ���е�data.txt�еĸ���

	local BytesRead : dword ; ���õ�ָ��
	local counter : dword ; ������
    invoke  CreateFile,offset songData,GENERIC_READ, 0, 0,OPEN_ALWAYS,FILE_ATTRIBUTE_NORMAL,0 ; ��data.txt�ļ���ȡ���и�������Ϣ
	mov		handler, eax
	mov		esi, offset delAllSongs ; ����delAllSongs��ƫ����esi

	mov	counter, 0 ; ������=0
REPEAT_READ:
	invoke ReadFile, handler, addr buffer, length divideLine,  addr BytesRead, NULL  ; �����з�
	.if BytesRead == 0
		jmp END_READ
	.endif
	invoke ReadFile, handler, addr readGroupDetailStr, MAX_GROUP_DETAIL_LEN , addr BytesRead, NULL ; ��groupid
	invoke atol, addr readGroupDetailStr
	mov	(song ptr [esi]).groupid, eax

	invoke ReadFile, handler, addr buffer, length divideLine,  addr BytesRead, NULL ; �����з�
	invoke ReadFile, handler, addr readFilePathStr, MAX_FILE_LEN, addr BytesRead, NULL ; ���ļ���path

	push esi
	invoke CollectSongPath, addr readFilePathStr, addr (song ptr [esi]).path ; ���ļ���path���Ƶ�delAllSongs��
	pop esi

	add	esi, size song ; �ƶ�����һ��delAllSongs�еĽṹ��
	inc counter ; ������+1
	jmp REPEAT_READ
END_READ:
	invoke CloseHandle, handler

	mov	eax, counter ;��counter����eax������ʾcaller�ж��ٸ���Ч��data.txt
	ret
GetAllSongInData endp

DeleteCurrentPlaySong proc,
	hWin : dword
	invoke DeleteTargetSong, hWin, DELETE_CURRENT_PLAY_SONG, 0 ; ɾ����ǰ���ŵĸ���
	ret
DeleteCurrentPlaySong endp

CheckFileExist proc,
	targetPath : dword

	invoke GetFileAttributes, targetPath ; �ж��ļ��Ƿ����
	.if eax == INVALID_FILE_ATTRIBUTES
		mov eax, FILE_NOT_EXIST
	.else
		mov eax, FILE_DO_EXIST
	.endif

	ret
CheckFileExist endp

DeleteInvalidSongs proc,
	hWin : dword
	invoke DeleteTargetSong, hWin, DELETE_INVALID, 0 ; ɾ��������Ч�ĸ���
	ret
DeleteInvalidSongs endp

; �����������¼�
LButtonDown proc, 
	hWin : dword, 
	wParam : dword, 
	lParam : dword

	local @mouseX : word
	local @mouseY : word
	
	mov eax, lParam
;	mov	hiword, 
	mov @mouseX, ax
	shrd eax, ebx, 16
	mov @mouseY, ax
	; ���ϰ벿���϶�����
	.if @mouseY < 70
		invoke SendMessage, hWin, WM_NCLBUTTONDOWN, HTCAPTION, 0
	.endif
	; ����ť
	.if @mouseX > 771 && @mouseX < 791 && @mouseY > 19 && @mouseY < 39
		invoke EndDialog,hWin,0
		.if hNewGroup != 0
			invoke EndDialog, hNewGroup, 0
		.endif
	.elseif @mouseX > 739 && @mouseX < 759 && @mouseY > 19 && @mouseY < 39
		invoke ChangeTheme, hWin
	.endif
	ret
LButtonDown endp
;// �����������¼�������
;void LButtonDown(HWND hWnd, WPARAM wParam, LPARAM lParam) {
; mouseX = LOWORD(lParam);
; mouseY = HIWORD(lParam);
; mouseDown = true;

; ���̰����¼�����
KeyDown proc, 
	hWin : dword, 
	wParam : dword, 
	lParam : dword
	.if wParam == VK_SPACE
		ret
	.endif
	ret
KeyDown endp
;// ���̰����¼�������
;void KeyDown(HWND hWnd, WPARAM wParam, LPARAM lParam) {
; switch (wParam) {
; case VK_UP:
;  keyUpDown = true;
;  break;

; ���沼�ֺ���
InitUI proc, 
	hWin : dword, 
	wParam : dword, 
	lParam : dword
	; �������ⱳ��ͼƬ
	invoke LoadBitmap, hInstance, IDB_BACKGROUND_BLUE
	mov bmp_Theme_Blue, eax
	invoke LoadBitmap, hInstance, IDB_BACKGROUND_ORANGE
	mov bmp_Theme_Orange, eax
	; ����ͼ��
	invoke LoadBitmap, hInstance, IDB_ADD_SONG_BLUE
	mov bmp_Add_Song_Blue, eax
	invoke LoadBitmap, hInstance, IDB_ADD_SONG_ORANGE
	mov bmp_Add_Song_Orange, eax
	invoke LoadBitmap, hInstance, IDB_NEW_LIST
	mov bmp_New_List, eax
	invoke LoadBitmap, hInstance, IDB_REMOVE_LIST
	mov bmp_Remove_List, eax
	invoke LoadBitmap, hInstance, IDB_REMOVE_SONG
	mov bmp_Remove_Song, eax

	invoke LoadIcon, hInstance, IDI_PLAY_BLUE
	mov ico_Play_Blue, eax
	invoke LoadIcon, hInstance, IDI_PLAY_ORANGE
	mov ico_Play_Orange, eax
	invoke LoadIcon, hInstance, IDI_SUSPEND_BLUE
	mov ico_Suspend_Blue, eax
	invoke LoadIcon, hInstance, IDI_SUSPEND_ORANGE
	mov ico_Suspend_Orange, eax
	invoke LoadImage, hInstance, IDI_FORWARD_BLUE, IMAGE_ICON, 23, 23, NULL
	mov ico_Forward_Blue, eax
	invoke LoadImage, hInstance, IDI_FORWARD_ORANGE, IMAGE_ICON, 23, 23, NULL
	mov ico_Forward_Orange, eax
	invoke LoadImage, hInstance, IDI_BACKWARD_BLUE, IMAGE_ICON, 23, 23, NULL
	mov ico_Backward_Blue, eax
	invoke LoadImage, hInstance, IDI_BACKWARD_ORANGE, IMAGE_ICON, 23, 23, NULL
	mov ico_Backward_Orange, eax
	invoke LoadImage, hInstance, IDI_NEXT_BLUE, IMAGE_ICON, 20, 20, NULL
	mov ico_Next_Blue, eax
	invoke LoadImage, hInstance, IDI_NEXT_ORANGE, IMAGE_ICON, 20, 20, NULL
	mov ico_Next_Orange, eax
	invoke LoadImage, hInstance, IDI_PRE_BLUE, IMAGE_ICON, 20, 20, NULL
	mov ico_Pre_Blue, eax
	invoke LoadImage, hInstance, IDI_PRE_ORANGE, IMAGE_ICON, 20, 20, NULL
	mov ico_Pre_Orange, eax
	invoke LoadImage, hInstance, IDI_VOLUM_BLUE, IMAGE_ICON, 20, 20, NULL
	mov ico_Volum_Blue, eax
	invoke LoadImage, hInstance, IDI_VOLUM_ORANGE, IMAGE_ICON, 20, 20, NULL
	mov ico_Volum_Orange, eax
	invoke LoadImage, hInstance, IDI_MUTE_BLUE, IMAGE_ICON, 20, 20, NULL
	mov ico_Mute_Blue, eax
	invoke LoadImage, hInstance, IDI_MUTE_ORANGE, IMAGE_ICON, 20, 20, NULL
	mov ico_Mute_Orange, eax
	invoke LoadImage, hInstance, IDI_RANDOM_BLUE, IMAGE_ICON, 20, 20, NULL
	mov ico_Random_Blue, eax
	invoke LoadImage, hInstance, IDI_RANDOM_ORANGE, IMAGE_ICON, 20, 20, NULL
	mov ico_Random_Orange, eax
	invoke LoadImage, hInstance, IDI_SINGLE_BLUE, IMAGE_ICON, 20, 20, NULL
	mov ico_Single_Blue, eax
	invoke LoadImage, hInstance, IDI_SINGLE_ORANGE, IMAGE_ICON, 20, 20, NULL
	mov ico_Single_Orange, eax
	invoke LoadImage, hInstance, IDI_LOOP_BLUE, IMAGE_ICON, 20, 20, NULL
	mov ico_Loop_Blue, eax
	invoke LoadImage, hInstance, IDI_LOOP_ORANGE, IMAGE_ICON, 20, 20, NULL
	mov ico_Loop_Orange, eax
	invoke LoadImage, hInstance, IDI_ADD_SONG_BLUE, IMAGE_ICON, 90, 25, NULL
	mov ico_Add_Song_Blue, eax
	invoke LoadImage, hInstance, IDI_ADD_SONG_ORANGE, IMAGE_ICON, 90, 25, NULL
	mov ico_Add_Song_Orange, eax
	invoke LoadImage, hInstance, IDI_NEW_LIST, IMAGE_ICON, 85, 22, NULL
	mov ico_New_List, eax
	invoke LoadImage, hInstance, IDI_REMOVE_LIST, IMAGE_ICON, 85, 22, NULL
	mov ico_Remove_List, eax
	invoke LoadImage, hInstance, IDI_REMOVE_SONG, IMAGE_ICON, 95, 25, NULL
	mov ico_Remove_Song, eax
	invoke LoadImage, hInstance, IDI_CLEAN_SONG, IMAGE_ICON, 120, 25, NULL
	mov ico_Clean_Song, eax
	; ����ͼƬ���õ�����Ԫ��
	invoke SendDlgItemMessage, hWin, IDC_BACKGROUND, STM_SETIMAGE, IMAGE_BITMAP, bmp_Theme_Blue
	invoke SendDlgItemMessage, hWin, IDC_ADD_NEW_GROUP, BM_SETIMAGE, IMAGE_ICON, ico_New_List
	invoke SendDlgItemMessage, hWin, IDC_DELETE_CURRENT_GROUP, BM_SETIMAGE, IMAGE_ICON, ico_Remove_List
	invoke SendDlgItemMessage, hWin, IDC_DELETE_INVALID_SONGS, BM_SETIMAGE, IMAGE_ICON, ico_Clean_Song
	invoke SendDlgItemMessage, hWin, IDC_FILE_SYSTEM, BM_SETIMAGE, IMAGE_ICON, ico_Add_Song_Blue
	invoke SendDlgItemMessage, hWin, IDC_DELETE_CURRENT_SONG, BM_SETIMAGE, IMAGE_ICON, ico_Remove_Song

	invoke SendDlgItemMessage, hWin, IDC_PLAY_BUTTON, BM_SETIMAGE, IMAGE_ICON, ico_Play_Blue
	invoke SendDlgItemMessage, hWin, IDC_NEXT_BUTTON, BM_SETIMAGE, IMAGE_ICON, ico_Next_Blue
	invoke SendDlgItemMessage, hWin, IDC_PRE_BUTTON, BM_SETIMAGE, IMAGE_ICON, ico_Pre_Blue
	invoke SendDlgItemMessage, hWin, IDC_FAST_BACKWARD, BM_SETIMAGE, IMAGE_ICON, ico_Backward_Blue
	invoke SendDlgItemMessage, hWin, IDC_FAST_FORWARD, BM_SETIMAGE, IMAGE_ICON, ico_Forward_Blue
	invoke SendDlgItemMessage, hWin, IDC_MUTE_SONG, BM_SETIMAGE, IMAGE_ICON, ico_Mute_Blue
	invoke SendDlgItemMessage, hWin, IDC_CHANGE_MODE, BM_SETIMAGE, IMAGE_ICON, ico_Loop_Blue
;	mov eax, IMG_START
;	invoke LoadImage, hInstance, eax,IMAGE_ICON,32,32,NULL
;	invoke SendDlgItemMessage,hWin,IDC_paly_btn, BM_SETIMAGE, IMAGE_ICON, eax
	ret
InitUI endp

; �������
ChangeTheme proc, 
	hWin : dword
	ret
;	tochange-tochange-tochange-tochange
	mov ax, curTheme
	inc ax
	mov	bl, 2
	div	bl
	movzx ax, ah
	mov curTheme, ax
	.if curTheme == 1
		invoke SendDlgItemMessage, hWin, IDC_BACKGROUND, STM_SETIMAGE, IMAGE_BITMAP, bmp_Theme_Orange
	.else
		invoke SendDlgItemMessage, hWin, IDC_BACKGROUND, STM_SETIMAGE, IMAGE_BITMAP, bmp_Theme_Blue
	.endif
	ret
ChangeTheme endp

; ��ͼ����
Paint proc, 
	hWin : dword
	local @ps : PAINTSTRUCT
	local @hdc_window : HDC
	local @hdc_memBuffer : HDC
	local @hdc_loadBmp : HDC
	local @blankBmp : HBITMAP
	
	; ׼�����Һͻ���
	invoke RtlZeroMemory, addr @ps, sizeof @ps ; ��@ps�ṹ����0
	invoke BeginPaint, hWin, addr @ps
	mov @hdc_window, eax
	invoke CreateCompatibleDC, @hdc_window
	mov @hdc_memBuffer, eax
	invoke CreateCompatibleDC, @hdc_window
	mov @hdc_loadBmp, eax

	; ��ʼ������
	invoke CreateCompatibleBitmap, @hdc_window, WINDOW_WIDTH, WINDOW_HEIGHT
	mov @blankBmp, eax
	invoke SelectObject, @hdc_memBuffer, @blankBmp

	; ���Ƹ�����Դ������
	; invoke SelectObject, @hdc_loadBmp, <target Bitmap>
	; invoke BitBlt, @hdc_memBuffer, posX, posY, width, height, @hdc_loadBmp, 0, 0, SRCCOPY
	
	; ��������Ϣ���Ƶ���Ļ
	invoke BitBlt, @hdc_window, 0, 0, WINDOW_WIDTH, WINDOW_HEIGHT, @hdc_memBuffer, 0, 0, SRCCOPY

	; ������Դ��ռ�ڴ�
	invoke DeleteObject, @blankBmp
	invoke DeleteDC, @hdc_memBuffer
	invoke DeleteDC, @hdc_loadBmp

	; ��������
	invoke EndPaint, hWin, addr @ps
	ret
Paint endp

PauseCurrentMusic proc
	.if playState == STATE_PAUSE ; ������ͣ�򷵻�
		ret
	.endif 

	mov playState, STATE_PAUSE ; ת��Ϊ��̬ͣ
	invoke mciExecute, ADDR cmd_pause
	ret
	;�޸�ͼ��
PauseCurrentMusic endp 

ResumeCurrentSong proc
	.if playState == STATE_PLAY ; �����ڲ����򷵻�
		ret
	.endif

	mov playState, STATE_PLAY ; ת��Ϊ����̬
	invoke mciExecute, ADDR cmd_resume
	ret
	;�޸�ͼ��
ResumeCurrentSong endp

PlayCurrentSong proc,
    hWin : dword
	; test
	invoke CheckPlayCurrentSong, hWin
	.if eax == 0
		ret
	.endif
	; end test

	.if playState != STATE_STOP
		invoke mciExecute, ADDR cmd_close
	.endif

	mov playState, STATE_PLAY ; ת��Ϊ����̬
	invoke wsprintf, ADDR mciCommand, ADDR cmd_open, ADDR currentPlaySingleSongPath
	invoke mciExecute, ADDR mciCommand
	invoke mciExecute, ADDR cmd_play
	invoke AlterVolume, hWin
	ret
	;�޸�ͼ��
PlayCurrentSong endp

PlayMusic proc,
    hWin : dword 
	; test
	invoke CheckPlayCurrentSong, hWin
	.if eax == 0
		ret
	.endif
	; end test

	.if playState == STATE_STOP ; ��ǰΪֹͣ״̬
		invoke SendDlgItemMessage, hWin, IDC_PLAY_BUTTON, BM_SETIMAGE, IMAGE_ICON, ico_Suspend_Blue
		invoke PlayCurrentSong, hWin
	.elseif playState == STATE_PLAY ; ��ǰΪ����̬
		invoke SendDlgItemMessage, hWin, IDC_PLAY_BUTTON, BM_SETIMAGE, IMAGE_ICON, ico_Play_Blue
		invoke PauseCurrentMusic
	.elseif playState == STATE_PAUSE ; ��ǰΪ��̬ͣ
		invoke SendDlgItemMessage, hWin, IDC_PLAY_BUTTON, BM_SETIMAGE, IMAGE_ICON, ico_Suspend_Blue
		invoke ResumeCurrentSong
	.endif
	ret 
PlayMusic endp

AlterVolume proc,
	hWin : dword
	invoke SendDlgItemMessage, hWin, IDC_SOUND, TBM_GETPOS, 0, 0	;��ȡ��ǰSliderλ��
	mov volume, eax

	;��static text����ʾ������ֵ
	mov edx, 0
	mov ebx, 10 
	div ebx ; eax = volume / 10
	invoke wsprintf, addr mciCommand, addr intFormat, eax
	invoke SendDlgItemMessage, hWin, IDC_SOUND_TEXT, WM_SETTEXT, 0, addr mciCommand
	.if playState != STATE_STOP ; û�����ֲ���ʱ�����ı�MCI�豸
		.if isMuted == 0 ;��ǰ�Ƿ���
			invoke wsprintf, addr mciCommand, addr cmd_setVol, volume
		.else
			invoke wsprintf, addr mciCommand, addr cmd_setVol, 0
		.endif
		invoke mciExecute, addr mciCommand ; ��MCI�иı�����
	.endif
	ret
AlterVolume endp

CollectSongName proc,
	songPath : dword,
	targetPath : dword ; ��songPath���Ƶ�targetPath���临�Ƶ������Ǹ���name��󳤶�-1
	
	mov	esi, songPath
	mov	edi, targetPath
	mov	ecx, MAX_SONG_NAME_LEN - 1
	cld
	mov ax, curTheme
	rep movsb
	ret
CollectSongName endp

CheckPlayCurrentSong proc,
	hWin : dword
	.if currentPlaySingleSongIndex == DEFAULT_PLAY_SONG
		invoke MessageBox, hWin, addr playSongNone, 0, MB_OK
		mov	eax, 0
		ret
	.endif
	
	invoke CheckFileExist, addr currentPlaySingleSongPath
	.if eax == FILE_NOT_EXIST
		invoke DeleteInvalidSongs, hWin
		invoke MessageBox, hWin, addr playSongInvalid, 0, MB_OK
		mov eax, 0
		ret
	.endif

	mov	eax, 1
	ret
CheckPlayCurrentSong endp
END WinMain