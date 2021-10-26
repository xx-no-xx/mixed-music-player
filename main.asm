.386
.model flat, stdcall
option casemap:none

include windows.inc
include user32.inc
include kernel32.inc
include masm32.inc
; include comctl32.inc
include comdlg32.inc ; �ļ�����
include winmm.inc

; irvine32.inc

includelib masm32.lib
includelib user32.lib
includelib kernel32.lib
includelib comdlg32.lib

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
IDC_BACKGROUND					equ 2001 ; ����ͼ��
;--------------- image & icon ----------------
IDB_BITMAP_START				equ 111
IDB_BACKGROUND_BLUE             equ 115
IDB_BACKGROUND_ORANGE           equ 116
;---------------- process --------------------
DO_NOTHING			equ 0 ; �ض��ķ���ֵ��ʶ
DEFAULT_SONG_GROUP  equ 99824 ; Ĭ����𱻷��䵽�ı�� ; todo : change 99824 to 0
DEFAULT_PLAY_SONG   equ 21474 ; Ĭ�ϵĵ�index�׸� ; todo : change 21474 to a larger num

FILE_DO_EXIST		equ 0 ; �ļ�����
FILE_NOT_EXIST		equ 1 ; �ļ�������

DELETE_ALL_SONGS_IN_GROUP	equ 0 ;ɾ��songGroup(dword)������и�
DELETE_CURRENT_PLAY_SONG	equ 1 ;ɾ��ѡ�е����׸裨current play song��
DELETE_INVALID				equ 2 ;ɾ�����в����ڵ�·����Ӧ�ĸ�

MAX_FILE_LEN equ 1000 ; ��ļ�����
MAX_GROUP_DETAIL_LEN equ 32 ; ����ŵ������
MAX_GROUP_NAME_LEN equ 20 ; �赥���Ƶ������
MAX_GROUP_SONG equ 30 ; �赥�ڸ����������
MAX_GROUP_NUM equ 10 ; ���ĸ赥����

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

GetCurrentGroupSong proto

GetTargetGroupSong proto,
	songGroup : dword,
	saveTo: dword

song struct ; ������Ϣ�ṹ��
	path byte MAX_FILE_LEN dup(0)
;	songname byte 10 dup(0) ; TODO: ��������
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

ShowMainDialogView proto,
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
;toodo

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

; ���沼��
InitUI proto, 
	hWin : dword, 
	wParam : dword,
	lParam : dword

Paint proto, 
	hWin :dword
; +++++++++++++++++++ data +++++++++++++++++++++
.data

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
bmp_Start				dword	?
bmp_Theme_Blue			dword	?	; ��ɫ���ⱳ��
bmp_Theme_Orange		dword	?	; ��ɫ���ⱳ��

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

	mov	eax, wParam
	mov	loword, ax
;	mov	hiword, 
	shrd eax, ebx, 16
	mov	hiword, ax

	.if	uMsg == WM_INITDIALOG
		invoke InitUI, hWin, wParam, lParam
		push hWin
		pop hMainDialog
		invoke GetAllGroups, hWin
		invoke ShowMainDialogView, hWin
		; do something
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
	.else
	.endif

	xor eax, eax ; eax = 0
	ret
DialogMain endp

ImportSingleFile proc,
	hWin : dword

	.if currentPlayGroup == DEFAULT_SONG_GROUP
		invoke MessageBox, hWin, addr addNone, 0, MB_OK
		ret
	.endif

	invoke  RtlZeroMemory, addr ofn, sizeof ofn ; fill with 0

	mov ofn.lStructSize, sizeof OPENFILENAME

	push hWin
	pop ofn.hwndOwner ; hwndOwner = hWin

	mov ofn.lpstrTitle, OFFSET ofnTitle
	mov ofn.lpstrInitialDir, OFFSET ofnInitialDir
	mov	ofn.nMaxFile, MAX_FILE_LEN
	mov	ofn.lpstrFile, OFFSET currentSongNameOFN
	mov	ofn.lpstrFilter, offset ofnFilter
	mov ofn.Flags, OFN_HIDEREADONLY

	invoke GetOpenFileName, addr ofn

	.if eax == DO_NOTHING
		jmp EXIT_IMPORT
	.endif

	invoke AddSingleSongOFN, currentPlayGroup

EXIT_IMPORT:
	xor eax, eax ; eax = 0
	ret
ImportSingleFile endp

AddSingleSongOFN proc,
	songGroup : dword

	LOCAL BytesWritten : dword
	LOCAL handler_saved : dword
	LOCAL lpstrLength : dword


	invoke GetGroupDetailInStr, songGroup

    INVOKE  CreateFile,offset songData,GENERIC_WRITE, 0, 0,OPEN_ALWAYS,FILE_ATTRIBUTE_NORMAL,0
	mov		handler, eax
	mov		handler_saved, eax

	invoke SetFilePointer, handler, 0, 0, FILE_END

	invoke lstrlen, ofn.lpstrFile
	mov	 lpstrLength, eax

	invoke WriteFile, handler, addr divideLine, length divideLine,  addr BytesWritten, NULL
	invoke WriteFile, handler, addr groupDetailStr, MAX_GROUP_DETAIL_LEN , addr BytesWritten, NULL

	invoke WriteFile, handler, addr divideLine, length divideLine,  addr BytesWritten, NULL
	invoke WriteFile, handler, ofn.lpstrFile, MAX_FILE_LEN, addr BytesWritten, NULL

	invoke CloseHandle, handler_saved

	ret
AddSingleSongOFN endp

GetGroupDetailInStr proc,
	songGroup : dword
	invoke  RtlZeroMemory, addr groupDetailStr, sizeof groupDetailStr
	invoke dw2a, songGroup, addr groupDetailStr
	ret
GetGroupDetailInStr endp

GetCurrentGroupSong proc
	invoke GetTargetGroupSong, currentPlayGroup, SAVE_TO_MAIN_DIALOG_GROUP
	ret
GetCurrentGroupSong endp

GetTargetGroupSong proc,
	songGroup : dword,
	saveTo : dword

	LOCAL BytesRead : dword
	LOCAL handler_saved : dword
	LOCAL lpstrLength : dword

	LOCAL counter : dword

    invoke  CreateFile,offset songData,GENERIC_READ, 0, 0,OPEN_ALWAYS,FILE_ATTRIBUTE_NORMAL,0
	mov		handler, eax

	.if saveTo == SAVE_TO_MAIN_DIALOG_GROUP
		mov	 esi, offset currentGroupSongs
	.endif

	mov	counter, 0
REPEAT_READ:
	invoke ReadFile, handler, addr buffer, length divideLine,  addr BytesRead, NULL
	.if BytesRead == 0
		jmp END_READ
	.endif
	invoke ReadFile, handler, addr readGroupDetailStr, MAX_GROUP_DETAIL_LEN , addr BytesRead, NULL

	invoke ReadFile, handler, addr buffer, length divideLine,  addr BytesRead, NULL
	invoke ReadFile, handler, addr readFilePathStr, MAX_FILE_LEN, addr BytesRead, NULL

	invoke atol, addr readGroupDetailStr
	.if eax > maxGroupId ; todo: may move to GetAllGroups
		mov maxGroupId, eax
	.endif
	.if eax == songGroup
		push esi
		invoke CollectSongPath, addr readFilePathStr, addr (song ptr [esi]).path
		push songGroup
		pop	(song ptr [esi]).groupid
		pop esi
		add	esi, SIZE song
		inc counter
	.endif
	

	jmp REPEAT_READ
END_READ:
	invoke CloseHandle, handler

	.if saveTo == SAVE_TO_MAIN_DIALOG_GROUP 
		push counter
		pop numCurrentGroupSongs
	.endif

	ret
GetTargetGroupSong endp

CollectSongPath proc,
	songPath : dword,
	targetPath : dword
	
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

;	invoke SendDlgItemMessage, hWin, IDC_GROUPS, CB_ADDSTRING, 0, addr simpleText

	invoke SendDlgItemMessage, hWin, IDC_MAIN_GROUP, LB_RESETCONTENT, 0, 0
	invoke GetCurrentGroupSong

	push numCurrentGroupSongs
	pop	 counter

	mov		esi, offset currentGroupSongs

PRINT_LIST:
	.if counter == 0
		jmp END_PRINT
	.endif

	push esi
	invoke SendDlgItemMessage, hWin, IDC_MAIN_GROUP, LB_ADDSTRING, 0, addr (song ptr [esi]).path 
	pop esi
	add	esi, size song
	dec counter
	jmp PRINT_LIST

END_PRINT:
	ret
ShowMainDialogView endp

SelectGroup proc,
	hWin : dword
	local indexToSet : dword
	local BytesRead : dword
	local handler_saved : dword
	local counter : dword

	invoke SendDlgItemMessage, hWin, IDC_GROUPS, CB_GETCURSEL, 0, 0
	mov	indexToSet, eax

	.if eax == CB_ERR
		mov currentPlayGroup, DEFAULT_SONG_GROUP
		invoke SelectSong, hWin
		ret
	.endif

    invoke  CreateFile,offset groupData,GENERIC_READ, 0, 0,OPEN_ALWAYS,FILE_ATTRIBUTE_NORMAL,0
	mov		handler, eax

	mov		esi, 0

REPEAT_READ:
	push esi
	invoke ReadFile, handler, addr buffer, length divideLine,  addr BytesRead, NULL
	.if BytesRead == 0
		jmp END_READ
	.endif
	invoke ReadFile, handler, addr readGroupDetailStr, MAX_GROUP_DETAIL_LEN , addr BytesRead, NULL

	invoke ReadFile, handler, addr buffer, length divideLine,  addr BytesRead, NULL
	invoke ReadFile, handler, addr readGroupNameStr, MAX_GROUP_NAME_LEN, addr BytesRead, NULL
	pop esi

	.if esi == indexToSet
		invoke atol, addr readGroupDetailStr
		mov currentPlayGroup, eax
		jmp END_READ
	.endif
	inc esi
	jmp REPEAT_READ
END_READ:
	invoke CloseHandle, handler
	
	invoke SelectSong, hWin
	xor eax, eax
	ret
SelectGroup endp

AddNewGroup proc,
	hWin : dword

	local handler_saved : dword
	local BytesWritten : dword

    invoke  CreateFile,offset groupData,GENERIC_WRITE, 0, 0,OPEN_ALWAYS,FILE_ATTRIBUTE_NORMAL,0
	mov		handler, eax
	mov		handler_saved, eax

	invoke SetFilePointer, handler, 0, 0, FILE_END

	invoke RtlZeroMemory, addr readGroupNameStr, sizeof readGroupNameStr
	mov	readGroupNameStr, MAX_GROUP_NAME_LEN - 1
	invoke SendDlgItemMessage, hWin, IDC_NEW_GROUP_NAME, EM_GETLINE, 0, addr readGroupNameStr

	add		maxGroupId, 1
	invoke GetGroupDetailInStr, maxGroupId

	invoke WriteFile, handler, addr divideLine, length divideLine,  addr BytesWritten, NULL
	invoke WriteFile, handler, addr groupDetailStr, MAX_GROUP_DETAIL_LEN, addr BytesWritten, NULL

	invoke WriteFile, handler, addr divideLine, length divideLine,  addr BytesWritten, NULL
	invoke WriteFile, handler, addr readGroupNameStr, MAX_GROUP_NAME_LEN, addr BytesWritten, NULL

	invoke CloseHandle, handler_saved

	invoke SendDlgItemMessage, hMainDialog, IDC_GROUPS, CB_ADDSTRING, 0, addr readGroupNameStr

	invoke SendDlgItemMessage, hMainDialog, IDC_GROUPS, CB_GETCOUNT, 0, 0
	dec eax
	invoke SendDlgItemMessage, hMainDialog, IDC_GROUPS, CB_SETCURSEL, eax, 0

	invoke SelectGroup, hMainDialog
	ret
AddNewGroup endp

GetAllGroups proc,
	hWin : dword

	local BytesRead : dword

    invoke  CreateFile,offset groupData,GENERIC_READ, 0, 0,OPEN_ALWAYS,FILE_ATTRIBUTE_NORMAL,0
	mov		handler, eax

	invoke SendDlgItemMessage, hWin, IDC_GROUPS, CB_RESETCONTENT, 0, 0
REPEAT_READ:
	invoke ReadFile, handler, addr buffer, length divideLine,  addr BytesRead, NULL
	.if BytesRead == 0
		jmp END_READ
	.endif
	invoke ReadFile, handler, addr readGroupDetailStr, MAX_GROUP_DETAIL_LEN , addr BytesRead, NULL

	invoke ReadFile, handler, addr buffer, length divideLine,  addr BytesRead, NULL
	invoke ReadFile, handler, addr readGroupNameStr, MAX_GROUP_NAME_LEN, addr BytesRead, NULL

	invoke SendDlgItemMessage, hWin, IDC_GROUPS, CB_ADDSTRING, 0, addr readGroupNameStr

	jmp REPEAT_READ
END_READ:
	invoke CloseHandle, handler

	invoke SendDlgItemMessage, hWin, IDC_GROUPS, CB_SETCURSEL, 0, 0
	invoke SelectGroup, hWin

	ret
GetAllGroups endp

StartAddNewGroup proc
	invoke DialogBoxParam, hInstance, IDD_DIALOG_ADD_NEW_GROUP, 0, addr NewGroupMain, 0
	ret
StartAddNewGroup endp

NewGroupMain proc,
	hWin : dword,
	uMsg : dword,
	wParam : dword,
	lParam : dword

	.if	uMsg == WM_INITDIALOG
		push hWin
		pop hNewGroup
		invoke SendDlgItemMessage, hWin, IDC_NEW_GROUP_NAME, EM_LIMITTEXT, MAX_GROUP_NAME_LEN - 1, 0
	.elseif	uMsg == WM_COMMAND
		.if wParam == IDC_BUTTON_ADD_NEW_GROUP
			invoke AddNewGroup, hWin
			invoke EndDialog, hWin, 0
		.endif
	.elseif	uMsg == WM_CLOSE
		mov hNewGroup, 0
		invoke EndDialog,hWin,0
	.else
	.endif

	xor eax, eax ; eax = 0
	ret
NewGroupMain endp

DeleteCurrentGroup proc,
	hWin : dword

	local BytesRead : dword
	local BytesWritten : dword
	local currentSelect : dword
	local counter : dword

	invoke SelectGroup, hWin ; get current select group
	.if currentPlayGroup == DEFAULT_SONG_GROUP
		invoke MessageBox, hWin, addr deleteNone, 0, MB_OK
		ret
	.endif

	invoke DeleteTargetSong, hWin, DELETE_ALL_SONGS_IN_GROUP, currentPlayGroup

    invoke  CreateFile,offset groupData,GENERIC_READ, 0, 0,OPEN_ALWAYS,FILE_ATTRIBUTE_NORMAL,0
	mov		handler, eax
	mov		esi, offset delAllGroups
	mov		counter, 0
REPEAT_READ:
	invoke ReadFile, handler, addr buffer, length divideLine,  addr BytesRead, NULL
	.if BytesRead == 0
		jmp END_READ
	.endif
	invoke ReadFile, handler, addr readGroupDetailStr, MAX_GROUP_DETAIL_LEN , addr BytesRead, NULL

	invoke atol, addr readGroupDetailStr
	mov (songgroup ptr [esi]).groupid, eax

	invoke ReadFile, handler, addr buffer, length divideLine,  addr BytesRead, NULL
	invoke ReadFile, handler, addr (songgroup ptr [esi]).groupname, MAX_GROUP_NAME_LEN, addr BytesRead, NULL

	add esi, size songgroup
	add counter, 1
	jmp REPEAT_READ
END_READ:
	invoke CloseHandle, handler

	mov		esi, offset delAllGroups

	invoke SendDlgItemMessage, hWin, IDC_GROUPS, CB_RESETCONTENT, 0, 0
    invoke  CreateFile,offset groupData,GENERIC_WRITE, 0, 0,CREATE_ALWAYS,FILE_ATTRIBUTE_NORMAL,0
	mov		handler, eax
	invoke SetFilePointer, handler, 0, 0, FILE_BEGIN

REPEAT_WRITE:
	mov	ebx, (songgroup ptr [esi]).groupid
	.if ebx != currentPlayGroup
		invoke WriteFile, handler, addr divideLine, length divideLine,  addr BytesWritten, NULL

		invoke GetGroupDetailInStr, (songgroup ptr [esi]).groupid
		invoke WriteFile, handler, addr groupDetailStr, MAX_GROUP_DETAIL_LEN, addr BytesWritten, NULL

		invoke WriteFile, handler, addr divideLine, length divideLine,  addr BytesWritten, NULL
		invoke WriteFile, handler, addr (songgroup ptr [esi]).groupname, MAX_GROUP_NAME_LEN, addr BytesWritten, NULL

		invoke SendDlgItemMessage, hWin, IDC_GROUPS, CB_ADDSTRING, 0, addr (songgroup ptr [esi]).groupname
	.endif

	sub counter, 1
	add	esi, size songgroup
	.if counter ==  0
		jmp END_WRITE
	.endif
	jmp REPEAT_WRITE
END_WRITE:
	invoke CloseHandle, handler

	invoke SendDlgItemMessage, hWin, IDC_GROUPS, CB_SETCURSEL, 0, 0
	invoke SelectGroup, hWin


	ret
DeleteCurrentGroup endp

SelectSong proc,
	hWin : dword

	local indexToPlay : dword

	invoke SendDlgItemMessage, hWin, IDC_MAIN_GROUP, LB_GETCURSEL, 0, 0
	.if eax == LB_ERR
		mov currentPlaySingleSongIndex, DEFAULT_PLAY_SONG
		ret
	.endif

	mov	currentPlaySingleSongIndex, eax

	mov	ebx, size song
	mul	ebx

	mov	esi, offset currentGroupSongs
	add	esi, eax

	invoke CollectSongPath, addr (song ptr [esi]).path, addr currentPlaySingleSongPath
	ret
SelectSong endp

DeleteTargetSong proc,
	hWin : dword,
	method : dword,
	songGroup : dword

	local counter : dword
	local BytesWrite : dword
;	index : dword

	.if method == DELETE_CURRENT_PLAY_SONG 
		.if currentPlaySingleSongIndex == DEFAULT_PLAY_SONG
			invoke MessageBox, hWin, addr deleteSongNone, 0, MB_OK
			ret
		.endif
	.endif

	.if method == DELETE_ALL_SONGS_IN_GROUP
		.if songGroup == DEFAULT_SONG_GROUP
			ret
		.endif
	.endif

	invoke GetAllSongInData
	mov		counter, eax

    invoke  CreateFile,offset songData,GENERIC_WRITE, 0, 0,CREATE_ALWAYS,FILE_ATTRIBUTE_NORMAL,0
	mov		handler, eax
	mov		esi, offset delAllSongs

	invoke SetFilePointer, handler, 0, 0, FILE_BEGIN
	mov		ecx, 0 ; ecx = indexcounter

REPEAT_WRITE:
	.if counter == 0
		jmp END_WRITE
	.endif
	dec counter

	mov edx, (song ptr [esi]).groupid
	
	.if edx == currentPlayGroup 
		.if method == DELETE_CURRENT_PLAY_SONG 
			.if ecx == currentPlaySingleSongIndex
				add	esi, size song
				inc ecx
				jmp REPEAT_WRITE
			.endif
			inc ecx
		.endif
	.endif

	.if edx == songGroup 
		.if method == DELETE_ALL_SONGS_IN_GROUP
			add esi, size song
			jmp REPEAT_WRITE
		.endif
	.endif

	push ecx
	.if method == DELETE_INVALID
		push eax
		invoke CheckFileExist, addr (song ptr [esi]).path
		.if eax == FILE_NOT_EXIST
			pop eax
			add esi, size song
			jmp REPEAT_WRITE
		.endif
		pop eax
	.endif

	invoke WriteFile, handler, addr buffer, length divideLine,  addr BytesWrite, NULL
	invoke GetGroupDetailInStr, (song ptr [esi]).groupid
	invoke WriteFile, handler, addr groupDetailStr, MAX_GROUP_DETAIL_LEN , addr BytesWrite, NULL

	invoke WriteFile, handler, addr buffer, length divideLine,  addr BytesWrite, NULL
	invoke WriteFile, handler, addr (song ptr [esi]).path, MAX_FILE_LEN, addr BytesWrite, NULL
	pop ecx

	add	esi, size song
	jmp REPEAT_WRITE
END_WRITE:
	invoke CloseHandle, handler
	ret
DeleteTargetSong endp

GetAllSongInData proc

	local BytesRead : dword
	local counter : dword

    invoke  CreateFile,offset songData,GENERIC_READ, 0, 0,OPEN_ALWAYS,FILE_ATTRIBUTE_NORMAL,0
	mov		handler, eax
	mov		esi, offset delAllSongs

	mov	counter, 0
REPEAT_READ:
	invoke ReadFile, handler, addr buffer, length divideLine,  addr BytesRead, NULL
	.if BytesRead == 0
		jmp END_READ
	.endif
	invoke ReadFile, handler, addr readGroupDetailStr, MAX_GROUP_DETAIL_LEN , addr BytesRead, NULL
	invoke atol, addr readGroupDetailStr
	mov	(song ptr [esi]).groupid, eax

	invoke ReadFile, handler, addr buffer, length divideLine,  addr BytesRead, NULL
	invoke ReadFile, handler, addr readFilePathStr, MAX_FILE_LEN, addr BytesRead, NULL

	push esi
	invoke CollectSongPath, addr readFilePathStr, addr (song ptr [esi]).path
	pop esi

	add	esi, size song
	inc counter
	jmp REPEAT_READ
END_READ:
	invoke CloseHandle, handler

	mov	eax, counter
	ret
GetAllSongInData endp

DeleteCurrentPlaySong proc,
	hWin : dword
	invoke DeleteTargetSong, hWin, DELETE_CURRENT_PLAY_SONG, 0
	ret
DeleteCurrentPlaySong endp

CheckFileExist proc,
	targetPath : dword

	invoke GetFileAttributes, targetPath
	.if eax == INVALID_FILE_ATTRIBUTES
		mov eax, FILE_NOT_EXIST
	.else
		mov eax, FILE_DO_EXIST
	.endif

	ret
CheckFileExist endp

DeleteInvalidSongs proc,
	hWin : dword
	invoke DeleteTargetSong, hWin, DELETE_INVALID, 0
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
	.if @mouseX > 1033 && @mouseX < 1063 && @mouseY > 32 && @mouseY < 55
		invoke EndDialog,hWin,0
		.if hNewGroup != 0
			invoke EndDialog, hNewGroup, 0
		.endif
	.elseif @mouseX > 989 && @mouseX < 1019 && @mouseY > 32 && @mouseY < 55
		invoke ChangeTheme, hWin
	.endif
	ret
LButtonDown endp
;// �����������¼�������
;void LButtonDown(HWND hWnd, WPARAM wParam, LPARAM lParam) {
; mouseX = LOWORD(lParam);
; mouseY = HIWORD(lParam);
; mouseDown = true;
; ���沼�ֺ���
InitUI proc, 
	hWin : dword, 
	wParam : dword, 
	lParam : dword
	; ���ز���ͼƬ
	invoke LoadBitmap, hInstance, IDB_BITMAP_START
	mov bmp_Start, eax
	; �������ⱳ��ͼƬ
	invoke LoadBitmap, hInstance, IDB_BACKGROUND_BLUE
	mov bmp_Theme_Blue, eax
	invoke LoadBitmap, hInstance, IDB_BACKGROUND_ORANGE
	mov bmp_Theme_Orange, eax

	; ����ͼƬ���õ�����Ԫ��
	invoke SendDlgItemMessage, hWin, IDC_BACKGROUND, STM_SETIMAGE, IMAGE_BITMAP, bmp_Theme_Blue
;	mov eax, IMG_START
;	invoke LoadImage, hInstance, eax,IMAGE_ICON,32,32,NULL
;	invoke SendDlgItemMessage,hWin,IDC_paly_btn, BM_SETIMAGE, IMAGE_ICON, eax
	ret
InitUI endp

; �������
ChangeTheme proc, 
	hWin : dword
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
	local @ps : dword ;PAINTSTRUCT <>
	ret
Paint endp

END WinMain