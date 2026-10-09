// ---------------------------------------------------------------------------
// SafeHeapRun.cs - Start a program with the Windows debug heap, no debugger.
//
// Used by ucc_safeheap.ps1 (see there for why). The program is created
// suspended, NtGlobalFlag 0x70 (heap tail checking, free checking, parameter
// validation) is written into its PEB -- the value Windows sets for a process
// started under a debugger -- and it is resumed. Affects that one process only.
// ---------------------------------------------------------------------------
using System;
using System.ComponentModel;
using System.Runtime.InteropServices;

public static class SafeHeapRun
{
    [StructLayout(LayoutKind.Sequential, CharSet = CharSet.Unicode)]
    struct STARTUPINFO
    {
        public int cb; public string lpReserved, lpDesktop, lpTitle;
        public int dwX, dwY, dwXSize, dwYSize, dwXCountChars, dwYCountChars, dwFillAttribute, dwFlags;
        public short wShowWindow, cbReserved2; public IntPtr lpReserved2, hStdInput, hStdOutput, hStdError;
    }
    [StructLayout(LayoutKind.Sequential)]
    struct PROCESS_INFORMATION { public IntPtr hProcess, hThread; public int dwProcessId, dwThreadId; }
    [StructLayout(LayoutKind.Sequential)]
    struct PROCESS_BASIC_INFORMATION { public IntPtr ExitStatus, PebBaseAddress, AffinityMask, BasePriority, UniqueProcessId, InheritedFromUniqueProcessId; }

    [DllImport("kernel32.dll", SetLastError = true, CharSet = CharSet.Unicode)]
    static extern bool CreateProcess(string app, string cmd, IntPtr pa, IntPtr ta, bool inherit, uint flags,
        IntPtr env, string dir, ref STARTUPINFO si, out PROCESS_INFORMATION pi);
    [DllImport("ntdll.dll")]
    static extern int NtQueryInformationProcess(IntPtr process, int infoClass, ref PROCESS_BASIC_INFORMATION info, int size, out int returned);
    [DllImport("ntdll.dll")]
    static extern int NtQueryInformationProcess(IntPtr process, int infoClass, out IntPtr info, int size, out int returned);
    [DllImport("kernel32.dll", SetLastError = true)]
    static extern bool WriteProcessMemory(IntPtr process, IntPtr address, byte[] buffer, int size, out int written);
    [DllImport("kernel32.dll")] static extern uint ResumeThread(IntPtr thread);
    [DllImport("kernel32.dll")] static extern uint WaitForSingleObject(IntPtr handle, uint ms);
    [DllImport("kernel32.dll")] static extern bool GetExitCodeProcess(IntPtr process, out uint code);
    [DllImport("kernel32.dll")] static extern bool CloseHandle(IntPtr handle);

    const uint CREATE_SUSPENDED = 4;
    const int ProcessBasicInformation = 0, ProcessWow64Information = 26;
    const int FLG_HEAP_DEBUG = 0x70;   // ENABLE_TAIL_CHECK | ENABLE_FREE_CHECK | VALIDATE_PARAMETERS

    public static int Run(string commandLine, string workingDir)
    {
        var si = new STARTUPINFO();
        si.cb = Marshal.SizeOf(typeof(STARTUPINFO));
        PROCESS_INFORMATION pi;
        if (!CreateProcess(null, commandLine, IntPtr.Zero, IntPtr.Zero, true, CREATE_SUSPENDED,
                           IntPtr.Zero, workingDir, ref si, out pi))
            throw new Win32Exception();

        try
        {
            byte[] flag = BitConverter.GetBytes(FLG_HEAP_DEBUG);
            int returned, written;

            // the native PEB (NtGlobalFlag at 0xBC), which WOW64 copies into the 32-bit one
            var pbi = new PROCESS_BASIC_INFORMATION();
            if (NtQueryInformationProcess(pi.hProcess, ProcessBasicInformation, ref pbi, Marshal.SizeOf(pbi), out returned) == 0)
                WriteProcessMemory(pi.hProcess, pbi.PebBaseAddress + 0xBC, flag, 4, out written);

            // and the 32-bit PEB itself (NtGlobalFlag at 0x68), in case the copy is already made
            IntPtr peb32;
            if (NtQueryInformationProcess(pi.hProcess, ProcessWow64Information, out peb32, IntPtr.Size, out returned) == 0 && peb32 != IntPtr.Zero)
                WriteProcessMemory(pi.hProcess, peb32 + 0x68, flag, 4, out written);

            ResumeThread(pi.hThread);
            WaitForSingleObject(pi.hProcess, 0xFFFFFFFF);
            uint code;
            GetExitCodeProcess(pi.hProcess, out code);
            return (int)code;
        }
        finally
        {
            CloseHandle(pi.hThread);
            CloseHandle(pi.hProcess);
        }
    }
}
