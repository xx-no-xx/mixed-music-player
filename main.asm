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

includelib masm32.lib
includelib user32.lib
includelib kernel32.lib
includelib comdlg32.lib

;---------------- control -------------
IDD_DIALOG 			equ	101 ; �����ŶԻ���
IDD_DIALOG_ADD_NEW_GROUP		equ 105 ; �����¸赥�ĶԻ���

IDC_FILE_SYSTEM 	equ	1001 ; ����赥�İ�ť
IDC_MAIN_GROUP				   equ  1017 ; չʾ��ǰѡ��赥�����и���
IDC_GROUPS						equ 1009 ; ѡ��ǰ�赥
IDC_ADD_NEW_GROUP				equ 1023; �����µĸ赥
IDC_NEW_GROUP_NAME				equ 1025 ; �����¸赥������
IDC_BUTTON_ADD_NEW_GROUP		equ 1026 ; ȷ�ϼ����µĸ赥
IDC_DELETE_CURRENT_GROUP		equ 1027 ; ɾ����ǰ�赥�İ�ť



;---------------- process -------------
DO_NOTHING			equ 0 ; �ض��ķ���ֵ��ʶ
DEFAULT_SONG_GROUP  equ 99824 ; Ĭ����𱻷��䵽�ı�� ; todo : change 99824 to 0

MAX_FILE_LEN equ 8000 ; ��ļ�����
MAX_GROUP_DETAIL_LEN equ 32 ; ����ŵ������
MAX_GROUP_NAME_LEN equ 20 ; �赥���Ƶ������
MAX_GROUP_SONG equ 50 ; �赥�ڸ����������
MAX_GROUP_NUM equ 10 ; ���ĸ赥����

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
	; TODO : �ƶ�����������һ���ڲ��ṹ��

song struct ; ������Ϣ�ṹ��
	path byte MAX_FILE_LEN dup(0)
;	songname byte 10 dup(0) ; TODO: ��������
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
; TODO
	
; TODO
; DeleteSongFromCurrentGroup proto, 
;	hWin : dword 

StartAddNewGroup proto ; ��ʼ�����¸赥�ĳ���

NewGroupMain proto, ; �����赥�ĶԻ���������
	hWin: dword,
	uMsg : dword,
	wParam : dword,
	lParam : dword

; +++++++++++++++++++ data +++++++++++++++++++++
.data

handler HANDLE ? ; �ļ����
divideLine byte 0ah ; ����divideLine

currentPlaySingleSong song <> ; Ŀǰ���ڲ��ŵĸ�����Ϣ

currentPlayGroup dword DEFAULT_SONG_GROUP ; Ŀǰ���ڲ��ŵĸ赥���
groupDetailStr byte MAX_GROUP_DETAIL_LEN dup("a") ; Ŀǰ���ڲ��ŵĸ赥��ŵ�str��ʽ�� ��Ҫ����GetGroupDetailInStr�Ը���

; �赥��Ϊ�Զ���赥��Ĭ�ϸ赥��Ĭ�ϸ赥����ȫ��������

numCurrentGroupSongs dword 0 ; ��ǰ���Ÿ赥�ĸ�������
currentGroupSongs song MAX_GROUP_SONG dup(<"#">) ; ��ǰ���Ÿ赥�����и�����Ϣ

maxGroupId dword 0

; ++++++++++++++ɾ�������������ʱ�洢����++++++++++++++
; ++++ �㲻Ӧ�ڳ���ɾ������֮��ĺ���������Щ���� +++++++
delAllGroups songgroup MAX_GROUP_NUM dup(<,>)

; ++++++++++++++�����ļ�OPpenFileName�ṹ++++++++++++++
ofn OPENFILENAME <>
ofnTitle BYTE '��������', 0	
ofnFilter byte "Media Files(*mp3, *wav)", 0, "*.mp3;*.wav", 0, 0

; ++++++++++++++Message Box ��ʾ��Ϣ++++++++++++++++++
deleteNone byte "��û��ѡ�и赥������ɾ����",0
addNone byte "��û��ѡ�и赥�����ܵ��������", 0


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
ofnInitialDir BYTE "C:\Users\gassq\Desktop", 0 ; default open C only for test
songData BYTE "C:\Users\gassq\Desktop\data.txt", 0 
testint byte "TEST INT: %d", 0ah, 0dh, 0
groupData byte "C:\Users\gassq\Desktop\groupdata.txt", 0

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
		push hWin
		pop hMainDialog
		invoke GetAllGroups, hWin
		invoke ShowMainDialogView, hWin
;		invoke SendDlgItemMessage, hWin, IDC_GROUPS, CB_SETCURSEL, 0, 0 
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
		.else
			; do something
		.endif
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

	invoke GetGroupDetailInStr, songGroup

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
	.if eax > maxGroupId
		mov maxGroupId, eax
	.endif
	.if eax == songGroup
		push esi
		invoke CollectSongPath, addr readFilePathStr, addr (song ptr [esi]).path
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
	add		esi, size song
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
	; todo : manage group id in a data structure 

	invoke ReadFile, handler, addr buffer, length divideLine,  addr BytesRead, NULL
	invoke ReadFile, handler, addr readGroupNameStr, MAX_GROUP_NAME_LEN, addr BytesRead, NULL

	invoke SendDlgItemMessage, hWin, IDC_GROUPS, CB_ADDSTRING, 0, addr readGroupNameStr

	jmp REPEAT_READ
END_READ:
	invoke SendDlgItemMessage, hWin, IDC_GROUPS, CB_SETCURSEL, 0, 0
	invoke CloseHandle, handler
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


END WinMain
