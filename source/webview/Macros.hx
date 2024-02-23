package webview;

import haxe.macro.Compiler;
import haxe.io.Path;
import sys.FileSystem;
import sys.io.File;
import haxe.macro.Expr;
import haxe.macro.Context;

using haxe.macro.PositionTools;

class Macros
{
    // This macro will only run on Windows targets to copy over the EmbeddedBrowserWebView DLL
    macro public static function copyDLLs():Array<Field>
    {
        Context.onAfterGenerate(() ->
        {
            var arch:String = #if HXCPP_M64 "x64" #else "x86" #end;
            var dllsPath:String = Path.join([Sys.getCwd(), "internal", "windows", "EBWebView", arch]);
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