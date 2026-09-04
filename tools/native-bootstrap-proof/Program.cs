using System;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Reflection;
using System.Security.Cryptography;
using System.Security.Principal;
using System.Windows.Forms;

namespace LoMVINativeBootstrapProof
{
    internal static class Program
    {
        private const long Offset = 427225161L;
        private const int RegionSize = 4660;
        private const string CleanPakSha = "abbadeeaec029807c6547d7faa9788f38da0099e8ea05ee20ff0167c0f5686d8";
        private const string PatchedPakSha = "1712e55db2b9b4b6c8ff86e5a11b7ac56b9602951a08cbdb8c5face2687c6bd1";
        private const string CleanRegionSha = "566e72d677fc974ab172eb71a34cdc6623f1e0dd19d978de812a76a1820b7fc7";
        private const string PatchedRegionSha = "c031726986e09358bb18ff8a2b8ee5f0b4e65ce8ae8331eed2d7575c80b7efa9";
        private const long ExpectedPakSize = 446910011L;

        [STAThread]
        private static void Main()
        {
            Application.EnableVisualStyles();
            Application.SetCompatibleTextRenderingDefault(false);

            try
            {
                if (!IsAdministrator())
                    throw new InvalidOperationException("Ứng dụng chưa chạy với quyền Administrator.");

                if (IsGameRunning())
                    throw new InvalidOperationException("Hãy đóng Lord of Mysteries trước khi chạy live proof. GMZZLauncher có thể để mở.");

                string c7 = ResolveC7();
                if (c7 == null)
                    throw new InvalidOperationException("Không tìm thấy thư mục C7 hợp lệ.");

                string pak = Path.Combine(c7, "Content", "Paks", "pakchunk0-Windows.pak");
                if (!File.Exists(pak))
                    throw new FileNotFoundException("Không tìm thấy pakchunk0-Windows.pak", pak);

                var fi = new FileInfo(pak);
                if (fi.Length != ExpectedPakSize)
                    throw new InvalidOperationException("PAK size không đúng build 2018737. Không thay đổi file.");

                string before = Sha256File(pak);
                if (Eq(before, PatchedPakSha))
                {
                    ShowPass("Native bootstrap đã có sẵn.\r\n\r\nPAK_SHA256=" + before.ToUpperInvariant() + "\r\nRESULT=ALREADY_NATIVE_PATCHED");
                    return;
                }

                if (!Eq(before, CleanPakSha))
                    throw new InvalidOperationException("PAK không khớp stock build 2018737 và cũng không khớp native-patched state đã biết. Fail closed; không thay đổi file.\r\n\r\nPAK_SHA256=" + before.ToUpperInvariant());

                byte[] bridge = ReadEmbeddedBridge();
                if (bridge.Length != RegionSize)
                    throw new InvalidOperationException("Embedded bridge size mismatch.");
                if (!Eq(Sha256Bytes(bridge), PatchedRegionSha))
                    throw new InvalidOperationException("Embedded bridge SHA mismatch.");

                byte[] original = ReadRegion(pak);
                string originalRegionSha = Sha256Bytes(original);
                if (!Eq(originalRegionSha, CleanRegionSha))
                    throw new InvalidOperationException("Stock PAK hash đúng nhưng native region không khớp clean contract. Fail closed; không thay đổi file.");

                try
                {
                    WriteRegion(pak, bridge);

                    string regionAfter = Sha256Bytes(ReadRegion(pak));
                    if (!Eq(regionAfter, PatchedRegionSha))
                        throw new InvalidOperationException("Native region verify failed after write.");

                    string after = Sha256File(pak);
                    if (!Eq(after, PatchedPakSha))
                        throw new InvalidOperationException("Whole PAK verify failed after native bootstrap write. SHA=" + after);

                    ShowPass(
                        "Native bootstrap đã được áp dụng và verify.\r\n\r\n" +
                        "BEFORE_SHA256=" + before.ToUpperInvariant() + "\r\n" +
                        "REGION_SHA256=" + regionAfter.ToUpperInvariant() + "\r\n" +
                        "AFTER_SHA256=" + after.ToUpperInvariant() + "\r\n" +
                        "RESULT=NATIVE_BOOTSTRAP_APPLIED\r\n\r\n" +
                        "Đóng cửa sổ này rồi mở game trực tiếp. Không chạy patcher lại trước lần test này."
                    );
                }
                catch
                {
                    try
                    {
                        WriteRegion(pak, original);
                        string rollback = Sha256File(pak);
                        if (!Eq(rollback, CleanPakSha))
                            throw new InvalidOperationException("Rollback SHA mismatch: " + rollback);
                    }
                    catch (Exception rollbackError)
                    {
                        throw new InvalidOperationException("Apply thất bại và rollback cũng thất bại. Không mở game; dùng GMZZLauncher Verify/Repair.\r\n" + rollbackError.Message);
                    }
                    throw;
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message, "LoM-VI Native Bootstrap Proof — FAIL", MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
        }

        private static bool IsAdministrator()
        {
            var id = WindowsIdentity.GetCurrent();
            var principal = new WindowsPrincipal(id);
            return principal.IsInRole(WindowsBuiltInRole.Administrator);
        }

        private static bool IsGameRunning()
        {
            try
            {
                return Process.GetProcesses().Any(p =>
                {
                    string n;
                    try { n = p.ProcessName ?? string.Empty; }
                    catch { return false; }
                    return n.Equals("C7", StringComparison.OrdinalIgnoreCase)
                        || n.IndexOf("C7-Win64", StringComparison.OrdinalIgnoreCase) >= 0
                        || n.IndexOf("Client-Win64-Shipping", StringComparison.OrdinalIgnoreCase) >= 0;
                });
            }
            catch { return false; }
        }

        private static string ResolveC7()
        {
            string[] defaults = new[]
            {
                @"C:\Program Files\GMZZLauncher\Game\C7",
                @"C:\Program Files (x86)\GMZZLauncher\Game\C7"
            };
            foreach (string d in defaults)
            {
                string r = ResolveCandidate(d);
                if (r != null) return r;
            }

            using (var dialog = new FolderBrowserDialog())
            {
                dialog.Description = "Chọn thư mục C7 hoặc một thư mục cha/con của C7";
                dialog.ShowNewFolderButton = false;
                if (dialog.ShowDialog() != DialogResult.OK) return null;
                return ResolveCandidate(dialog.SelectedPath);
            }
        }

        private static string ResolveCandidate(string input)
        {
            if (string.IsNullOrWhiteSpace(input)) return null;
            string p;
            try { p = Path.GetFullPath(input); }
            catch { return null; }

            for (int i = 0; i < 6; i++)
            {
                if (IsC7(p)) return p;
                var parent = Directory.GetParent(p);
                if (parent == null) break;
                p = parent.FullName;
            }

            string[] children = new[]
            {
                Path.Combine(input, "C7"),
                Path.Combine(input, "Game", "C7"),
                Path.Combine(input, "GMZZLauncher", "Game", "C7")
            };
            foreach (string c in children)
                if (IsC7(c)) return Path.GetFullPath(c);

            return null;
        }

        private static bool IsC7(string p)
        {
            try { return File.Exists(Path.Combine(p, "Content", "Paks", "pakchunk0-Windows.pak")); }
            catch { return false; }
        }

        private static byte[] ReadEmbeddedBridge()
        {
            var asm = Assembly.GetExecutingAssembly();
            using (Stream s = asm.GetManifestResourceStream("LoMVI.NativeBridge"))
            {
                if (s == null) throw new InvalidOperationException("Embedded native bridge missing.");
                byte[] b = new byte[s.Length];
                int read = 0;
                while (read < b.Length)
                {
                    int n = s.Read(b, read, b.Length - read);
                    if (n <= 0) break;
                    read += n;
                }
                if (read != b.Length) throw new EndOfStreamException("Embedded native bridge truncated.");
                return b;
            }
        }

        private static byte[] ReadRegion(string pak)
        {
            byte[] b = new byte[RegionSize];
            using (var fs = new FileStream(pak, FileMode.Open, FileAccess.Read, FileShare.ReadWrite))
            {
                fs.Position = Offset;
                int read = 0;
                while (read < b.Length)
                {
                    int n = fs.Read(b, read, b.Length - read);
                    if (n <= 0) break;
                    read += n;
                }
                if (read != b.Length) throw new EndOfStreamException("Native region truncated.");
            }
            return b;
        }

        private static void WriteRegion(string pak, byte[] data)
        {
            using (var fs = new FileStream(pak, FileMode.Open, FileAccess.ReadWrite, FileShare.Read))
            {
                fs.Position = Offset;
                fs.Write(data, 0, data.Length);
                fs.Flush(true);
            }
        }

        private static string Sha256File(string path)
        {
            using (var sha = SHA256.Create())
            using (var fs = new FileStream(path, FileMode.Open, FileAccess.Read, FileShare.ReadWrite, 1024 * 1024, FileOptions.SequentialScan))
                return Hex(sha.ComputeHash(fs));
        }

        private static string Sha256Bytes(byte[] data)
        {
            using (var sha = SHA256.Create()) return Hex(sha.ComputeHash(data));
        }

        private static string Hex(byte[] bytes)
        {
            return BitConverter.ToString(bytes).Replace("-", string.Empty).ToLowerInvariant();
        }

        private static bool Eq(string a, string b)
        {
            return string.Equals(a, b, StringComparison.OrdinalIgnoreCase);
        }

        private static void ShowPass(string text)
        {
            MessageBox.Show(text, "LoM-VI Native Bootstrap Proof — PASS", MessageBoxButtons.OK, MessageBoxIcon.Information);
        }
    }
}
