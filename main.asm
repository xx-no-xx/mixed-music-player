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
IDD_GROUP_MANAGE	equ 103 ; ����赥�Ի���
IDC_FILE_SYSTEM 	equ	1001 ; ����赥�İ�ť
IDC_MANAGE_CURRENT_GROUP       equ  1012 ; �������赥�Ի���İ�ť
IDC_ALL_GROUP_LIST             equ  1013 ; TODO
IDC_CURRENT_GROUP_LIST         equ  1015 ; TODO
IDC_MAIN_GROUP				   equ  1017 ; չʾ��ǰѡ��赥�����и���
IDC_GROUPS						equ 1009 ; ѡ��ǰ�赥
IDC_ADD_NEW_GROUP				equ 1023; �����µĸ赥


;---------------- process -------------
DO_NOTHING			equ 0 ; �ض��ķ���ֵ��ʶ
DEFAULT_SONG_GROUP  equ 99824 ; Ĭ����𱻷��䵽�ı��

MAX_FILE_LEN equ 8000 ; ��ļ�����
MAX_GROUP_DETAIL_LEN equ 64 ; ����ŵ������
MAX_GROUP_NAME_LEN equ 20 ; �赥���Ƶ������
MAX_GROUP_SONG equ 50 ; �赥�ڸ����������

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

StartGroupManage proto, ; TODO: ����ǰѡ��ĸ赥
	hWin : dword

GroupManageMain proto, ; TODO : ����ǰ�赥�����߼�
	hWin : dword,
	uMsg : dword,
	wParam : dword,
	lParam : dword

GetCurrentGroupSong proto ; TODO : ����currentGroupSongs�ĸ�����Ϣ

GetTargetGroupSong proto, ; TODO : ���songGroup�����и�����Ϣ
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
; TODO

GetAllGroups proto, ; ��ѯ���е�group
	hWin : dword
; TODO

AddNewGroup proto ; ����һ���µ�group
; TODO

DeleteOldGroup proto ; ɾ��һ��group�� ������ɾ�����еĸ���
; TODO
	
; TODO
; DeleteSongFromCurrentGroup proto, 
;	hWin : dword 

GetInputGroupName proto, ; ���û��������ȡreadGroupName
	readGroupName : dword 
; todo
	

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

; ++++++++++++++�����ļ�OPpenFileName�ṹ++++++++++++++
ofn OPENFILENAME <>
ofnTitle BYTE '��������', 0	

; +++++++++++++++�������貿�ִ��ڱ���+++++++++++++++
hInstance dword ?
hGroupManager dword ?

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

	.if	uMsg == WM_INITDIALOG
		invoke ShowMainDialogView, hWin
		; do something
	.elseif	uMsg == WM_COMMAND
		.if wParam == IDC_FILE_SYSTEM
			invoke ImportSingleFile, hWin
			invoke ShowMainDialogView, hWin
		.elseif wParam == IDC_MANAGE_CURRENT_GROUP
			invoke StartGroupManage, hWin
			invoke ShowMainDialogView, hWin
		.elseif wParam == IDC_GROUPS
			invoke SelectGroup, hWin ; TODO
		.elseif wParam == IDC_ADD_NEW_GROUP
			invoke AddNewGroup
			invoke ShowMainDialogView, hWin
		.endif
	.elseif	uMsg == WM_CLOSE
		invoke EndDialog,hWin,0
		.if hGroupManager != 0
			invoke EndDialog, hGroupManager, 0
		.endif
	.else
	.endif

	xor eax, eax ; eax = 0
	ret
DialogMain endp

ImportSingleFile proc,
	hWin : dword

	invoke  RtlZeroMemory, addr ofn, sizeof ofn ; fill with 0

	mov ofn.lStructSize, sizeof OPENFILENAME

	push hWin
	pop ofn.hwndOwner ; hwndOwner = hWin

	mov ofn.lpstrTitle, OFFSET ofnTitle
	mov ofn.lpstrInitialDir, OFFSET ofnInitialDir
	mov	ofn.nMaxFile, MAX_FILE_LEN
	mov	ofn.lpstrFile, OFFSET currentSongNameOFN

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

StartGroupManage proc,
	hWin : dword
	invoke DialogBoxParam, hInstance, IDD_GROUP_MANAGE, 0, addr GroupManageMain, 0
	ret
StartGroupManage endp

GroupManageMain proc,
	hWin : dword,
	uMsg : dword,
	wParam : dword,
	lParam : dword

	.if	uMsg == WM_INITDIALOG
		push hWin
		pop hGroupManager
		; do something
	.elseif	uMsg == WM_COMMAND
	.elseif	uMsg == WM_CLOSE
		mov hGroupManager, 0
		invoke EndDialog,hWin,0
	.else
	.endif

	xor eax, eax ; eax = 0
	ret
GroupManageMain endp

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

	invoke GetAllGroups, hWin
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
; TODO
	ret
SelectGroup endp

AddNewGroup proc
	local handler_saved : dword
	local BytesWritten : dword

    invoke  CreateFile,offset groupData,GENERIC_WRITE, 0, 0,OPEN_ALWAYS,FILE_ATTRIBUTE_NORMAL,0
	mov		handler, eax
	mov		handler_saved, eax

	invoke SetFilePointer, handler, 0, 0, FILE_END

	invoke RtlZeroMemory, addr readGroupNameStr, sizeof readGroupNameStr
	invoke GetInputGroupName, addr readGroupNameStr

;	users can modify add name
	invoke GetGroupDetailInStr, eax
; todo : add limit to id so that they are not equal

	invoke WriteFile, handler, addr divideLine, length divideLine,  addr BytesWritten, NULL
	invoke WriteFile, handler, addr groupDetailStr, MAX_GROUP_DETAIL_LEN, addr BytesWritten, NULL

	invoke WriteFile, handler, addr divideLine, length divideLine,  addr BytesWritten, NULL
	invoke WriteFile, handler, addr readGroupNameStr, MAX_GROUP_NAME_LEN, addr BytesWritten, NULL

	invoke CloseHandle, handler_saved
	ret
AddNewGroup endp

GetAllGroups proc,
	hWin : dword

	local BytesRead : dword
	local handler_saved : dword
	local lpstrLength : dword

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
	invoke CloseHandle, handler
	ret
GetAllGroups endp

GetInputGroupName proc,
	targetStr : dword
; todo
	mov esi, offset inputGroupNameStr
	mov	edi, targetStr
	mov	ecx, MAX_GROUP_NAME_LEN - 1
	cld
	rep	movsb
	ret
GetInputGroupName endp

END WinMain
