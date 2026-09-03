using System.Security.Cryptography;
using System.Text.Json;
using CUE4Parse.Compression;
using CUE4Parse.FileProvider;
using CUE4Parse.UE4.Pak.Objects;
using CUE4Parse.UE4.Versions;
using CUE4Parse.UE4.VirtualFileSystem;

static string? ArgValue(string[] args, string name)
{
    for (var i = 0; i + 1 < args.Length; i++)
        if (string.Equals(args[i], name, StringComparison.OrdinalIgnoreCase)) return args[i + 1];
    return null;
}

static string Sha256Hex(byte[] data) => Convert.ToHexString(SHA256.HashData(data)).ToLowerInvariant();

static string? FindDefaultStockPak()
{
    var candidates = new[]
    {
        @"C:\Program Files\GMZZLauncher\Game\C7\Content\Paks\pakchunk0-Windows.pak",
        @"C:\Program Files (x86)\GMZZLauncher\Game\C7\Content\Paks\pakchunk0-Windows.pak"
    };
    return candidates.FirstOrDefault(File.Exists);
}

var pakPath = ArgValue(args, "--pak") ?? FindDefaultStockPak();
if (string.IsNullOrWhiteSpace(pakPath) || !File.Exists(pakPath))
{
    Console.Error.WriteLine("PAK_NOT_FOUND. Pass --pak <path>.");
    return 2;
}

pakPath = Path.GetFullPath(pakPath);
var outDir = ArgValue(args, "--out") ?? Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.DesktopDirectory), "LoM-VI-Community-Route-Probe");
Directory.CreateDirectory(outDir);

var report = new Dictionary<string, object?>
{
    ["probe"] = "LoM-VI current-CUE4Parse GAME_LordOfMysteries direct PAK probe",
    ["cue4parse_commit"] = "52d7de4abec1368459d566e4a6ec4060e9626329",
    ["pak_path"] = pakPath,
    ["pak_size"] = new FileInfo(pakPath).Length,
    ["game"] = "GAME_LordOfMysteries",
    ["timestamp_utc"] = DateTimeOffset.UtcNow.ToString("O")
};

try
{
    var oodlePath = Path.Combine(AppContext.BaseDirectory, OodleHelper.OodleFileName);
    var zlibPath = Path.Combine(AppContext.BaseDirectory, ZlibHelper.DllName);
    report["oodle_path"] = oodlePath;
    report["zlib_path"] = zlibPath;
    OodleHelper.Initialize(oodlePath);
    ZlibHelper.Initialize(zlibPath);
    report["compression_init"] = "PASS";
}
catch (Exception ex)
{
    report["compression_init"] = "FAIL";
    report["compression_error"] = ex.ToString();
}

var emptyDir = Path.Combine(Path.GetTempPath(), "lomvi-cue4parse-empty-" + Guid.NewGuid().ToString("N"));
Directory.CreateDirectory(emptyDir);

try
{
    var versions = new VersionContainer(EGame.GAME_LordOfMysteries);
    using var provider = new DefaultFileProvider(emptyDir, SearchOption.TopDirectoryOnly, versions, StringComparer.OrdinalIgnoreCase);
    provider.Initialize();
    provider.RegisterVfs(pakPath);

    report["registered_vfs"] = provider.UnloadedVfs.Select(v => new
    {
        v.Name,
        v.Path,
        v.FileCount,
        v.HasDirectoryIndex,
        Game = v.Game.ToString()
    }).ToArray();

    var mounted = provider.Mount();
    report["mount_return_count"] = mounted;
    report["mounted_vfs"] = provider.MountedVfs.Select(v => new
    {
        v.Name,
        v.Path,
        v.FileCount,
        v.HasDirectoryIndex,
        Game = v.Game.ToString()
    }).ToArray();
    report["unloaded_vfs_after_mount"] = provider.UnloadedVfs.Select(v => new
    {
        v.Name,
        v.Path,
        v.FileCount,
        v.HasDirectoryIndex,
        Game = v.Game.ToString()
    }).ToArray();
    report["required_key_count"] = provider.RequiredKeys.Count;
    report["provider_file_count"] = provider.Files.Count;

    var fontFiles = provider.Files.Values
        .Where(f => f.Path.Contains("/Font/", StringComparison.OrdinalIgnoreCase)
                    || f.Path.EndsWith(".ufont", StringComparison.OrdinalIgnoreCase)
                    || f.Name.Contains("Aleo", StringComparison.OrdinalIgnoreCase))
        .OrderBy(f => f.Path, StringComparer.OrdinalIgnoreCase)
        .ToArray();

    report["font_like_count"] = fontFiles.Length;
    report["font_like_files"] = fontFiles.Select(f => new
    {
        f.Path,
        f.Size,
        Compression = f.CompressionMethod.ToString(),
        f.IsEncrypted,
        RuntimeType = f.GetType().FullName,
        VfsName = f is VfsEntry ve ? ve.Vfs.Name : null
    }).ToArray();

    var target = fontFiles.FirstOrDefault(f => f.Name.Equals("Aleo_Regular.ufont", StringComparison.OrdinalIgnoreCase));
    if (target is null)
    {
        report["outcome"] = "ALEO_NOT_FOUND_IN_THIS_PAK";
    }
    else
    {
        var targetInfo = new Dictionary<string, object?>
        {
            ["path"] = target.Path,
            ["size"] = target.Size,
            ["compression"] = target.CompressionMethod.ToString(),
            ["encrypted"] = target.IsEncrypted,
            ["runtime_type"] = target.GetType().FullName,
            ["vfs_name"] = target is VfsEntry targetVfs ? targetVfs.Vfs.Name : null
        };

        if (target is FPakEntry pe)
        {
            targetInfo["entry_offset"] = pe.Offset;
            targetInfo["compressed_size"] = pe.CompressedSize;
            targetInfo["uncompressed_size"] = pe.UncompressedSize;
            targetInfo["compression_block_size"] = pe.CompressionBlockSize;
            targetInfo["compression_block_count"] = pe.CompressionBlocks.Length;
            targetInfo["struct_size"] = pe.StructSize;
            targetInfo["pak_version"] = pe.PakFileReader.Info.Version.ToString();
            targetInfo["pak_compression_methods"] = pe.PakFileReader.Info.CompressionMethods.Select(x => x.ToString()).ToArray();
        }

        try
        {
            var data = target.Read();
            var sha = Sha256Hex(data);
            targetInfo["read"] = "PASS";
            targetInfo["raw_size"] = data.Length;
            targetInfo["raw_sha256"] = sha;
            var extracted = Path.Combine(outDir, "Aleo_Regular.ufont");
            File.WriteAllBytes(extracted, data);
            targetInfo["extracted_path"] = extracted;
            report["outcome"] = sha == "bb439ea915f92ca387e28ad0b6c991b98b9a5903a25a5c76f5bb7aa1c48bd9ed"
                ? "ALEO_FOUND_EXACT_STOCK_RAW"
                : "ALEO_FOUND_NONSTOCK_RAW";
        }
        catch (Exception ex)
        {
            targetInfo["read"] = "FAIL";
            targetInfo["read_error"] = ex.ToString();
            report["outcome"] = "ALEO_FOUND_BUT_READ_FAILED";
        }

        report["aleo_regular"] = targetInfo;
    }
}
catch (Exception ex)
{
    report["outcome"] = "PROBE_EXCEPTION";
    report["exception"] = ex.ToString();
}
finally
{
    try { Directory.Delete(emptyDir, recursive: true); } catch { }
}

var reportPath = Path.Combine(outDir, "report.json");
File.WriteAllText(reportPath, JsonSerializer.Serialize(report, new JsonSerializerOptions { WriteIndented = true }));
Console.WriteLine(reportPath);
Console.WriteLine(report.TryGetValue("outcome", out var outcome) ? outcome : "NO_OUTCOME");
return 0;
