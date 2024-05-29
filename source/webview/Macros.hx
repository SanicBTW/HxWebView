package webview;

import sys.io.File;
import haxe.io.Path;
import sys.FileSystem;
import haxe.macro.Expr;
import haxe.macro.Context;
import haxe.macro.Compiler;

using haxe.macro.PositionTools;

class Macros
{
    // This macro will only run on Windows targets to copy over the EmbeddedBrowserWebView DLL
    macro public static function copyDLLs():Array<Field>
    {
        var libDir:String = Path.directory(FileSystem.fullPath(Context.currentPos().getInfos().file)); // HxWebView/source/webview
        libDir = Path.directory(libDir); // HxWebView/source
        libDir = Path.directory(libDir); // HxWebView

        Context.onAfterGenerate(() ->
        {
            var arch:String = #if HXCPP_M64 "x64" #else "x86" #end;
            var dllsPath:String = Path.join([libDir, "internal", "windows", "EBWebView", arch]);
            if (FileSystem.exists(dllsPath))
            {
                dllsPath = Path.join([dllsPath, "EmbeddedBrowserWebView.dll"]);

                var outPath:String = Path.join([Sys.getCwd(), Compiler.getOutput()]);

                var ebFolder:String = Path.join([outPath, "EBWebView"]);
                if (!FileSystem.exists(ebFolder))
                    FileSystem.createDirectory(ebFolder);

                var archFolder:String = Path.join([ebFolder, arch]);
                if (!FileSystem.exists(archFolder))
                    FileSystem.createDirectory(archFolder);

                var targetPath:String = Path.join([archFolder, "EmbeddedBrowserWebView.dll"]);
                if (FileSystem.exists(targetPath))
                    return;

                File.copy(dllsPath, targetPath);
            }
        });

        return Context.getBuildFields();
    }
}