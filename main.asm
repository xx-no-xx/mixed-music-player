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
IDC_MAIN_GROUP				   equ  1017 ; TODO


;---------------- process -------------
DO_NOTHING			equ 0 ; �ض��ķ���ֵ��ʶ
DEFAULT_SONG_GROUP  equ 99824 ; Ĭ����𱻷��䵽�ı��

MAX_FILE_LEN equ 8000 ; ��ļ�����
MAX_GROUP_DETAIL_LEN equ 64 ; ����ŵ������
MAX_GROUP_SONG equ 50 ; �赥�ڸ����������

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

GetCurrentGroupSong proto ; TODO : ����currentPlaySong�ĸ�����Ϣ

GetTargetGroupSong proto, ; TODO : ���songGroup�����и�����Ϣ
	songGroup : dword,
	saveTo: dword
	; TODO : �ƶ�����������һ���ڲ��ṹ��

song struct ; ������Ϣ�ṹ��
	path byte 1000 dup(0)
;	songname byte 10 dup(0) ; TODO: ��������
; TODO : ����������Ϣ
song ends

CollectSongPath proto, ; ��songPath���Ƶ���Ӧ��targetPath��ȥ
	songPath : dword,
	targetPath : dword


ShowMainDialog proto,
	hWin : dword




; +++++++++++++++++++ data +++++++++++++++++++++
.data

handler HANDLE ? ; �ļ����
divideLine byte 0ah ; ����divideLine

currentPlaySong song <> ; Ŀǰ���ڲ��ŵĸ�����Ϣ
currentPlayGroup dword DEFAULT_SONG_GROUP ; Ŀǰ���ڲ��ŵĸ赥���
groupDetailStr byte MAX_GROUP_DETAIL_LEN dup("a") ; Ŀǰ���ڲ��ŵĸ赥��ŵ�str��ʽ�� ��Ҫ����GetGroupDetailInStr�Ը���

; �赥��Ϊ�Զ���赥��Ĭ�ϸ赥��Ĭ�ϸ赥����ȫ��������

numCurrentGroupSongs dword 0 ; ��ǰ���Ÿ赥�ĸ�������
currentGroupSongs song MAX_GROUP_SONG dup(<>) ; ��ǰ���Ÿ赥�����и�����Ϣ

; ++++++++++++++�����ļ�OPpenFileName�ṹ++++++++++++++
ofn OPENFILENAME <>
ofnTitle BYTE '��������', 0	

; +++++++++++++++�������貿�ִ��ڱ���+++++++++++++++
hInstance dword ?
hGroupManager dword ?

; +++++++++++++++������Ϣ+++++++++++(��Ϊ���Զ�ע��)
;songData BYTE ".\data.txt", 0
;	ofnInitialDir BYTE "C:", 0 ; default open C

; +++++++++++++������������++++++++++++�����ܿ��Ա�local�����

readGroupDetailStr byte MAX_GROUP_DETAIL_LEN   dup(0)
currentSongNameOFN byte MAX_FILE_LEN dup(0)
readFilePathStr byte MAX_FILE_LEN  dup(0)
buffer byte 0

collectSongPath byte MAX_FILE_LEN dup(0)

; ++++++++++++++����ר��+++++++++++++ 
; ++++++++������Լ��Ļ���·���޸�+++++++++
; TODO-TODO-TODO-TODO-TODO-TODO-TODO
simpleText byte "somethingrighthere", 0ah, 0
ofnInitialDir BYTE "C:\Users\gassq\Desktop", 0 ; default open C only for test
songData BYTE "C:\Users\gassq\Desktop\data.txt", 0 
testint byte "TEST INT: %d", 0ah, 0dh, 0

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
		; ++++++++++ only for test ++++++++++
		invoke SendDlgItemMessage, hWin, IDC_MAIN_GROUP, LB_ADDSTRING, 0, addr simpleText
		invoke SendDlgItemMessage, hWin, IDC_MAIN_GROUP, LB_ADDSTRING, 0, addr simpleText
		invoke SendDlgItemMessage, hWin, IDC_MAIN_GROUP, LB_ADDSTRING, 0, addr simpleText
		invoke SendDlgItemMessage, hWin, IDC_MAIN_GROUP, LB_ADDSTRING, 0, addr simpleText
		invoke SendDlgItemMessage, hWin, IDC_MAIN_GROUP, LB_ADDSTRING, 0, addr simpleText
		; ++++++++++ only for test ++++++++++
		; do something
	.elseif	uMsg == WM_COMMAND
		.if wParam == IDC_FILE_SYSTEM
			invoke ImportSingleFile, hWin
		.elseif wParam == IDC_MANAGE_CURRENT_GROUP
			invoke StartGroupManage, hWin
		.endif
		invoke GetCurrentGroupSong
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

	.if saveTo == SAVE_TO_MAIN_DIALOG_GROUP
		mov	 esi, offset currentPlaySong
	.endif

    invoke  CreateFile,offset songData,GENERIC_READ, 0, 0,OPEN_ALWAYS,FILE_ATTRIBUTE_NORMAL,0
	mov		handler, eax

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
		pop	 esi
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
	mov	ecx, MAX_FILE_LEN 
	rep movsb


	ret
CollectSongPath endp

ShowMainDialogView proc,
	hWin : dword

ShowMainDialogView endp

END WinMain
