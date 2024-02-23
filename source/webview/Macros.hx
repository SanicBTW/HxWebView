package webview;

import haxe.macro.Compiler;
import haxe.io.Path;
import sys.FileSystem;
import sys.io.File;
import haxe.macro.Expr;
import haxe.macro.Context;

using haxe.macro.PositionTools;

typedef WrongField =
{
    var name:String;
    var atPos:String;
    var ofType:String;
    var ?exc:Null<String>;
}

// Since I cannot import the webview package
typedef MBindFunc = (seq:String, req:String, arg:Dynamic)->Void;

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
                {
                    trace("Already exists");
                    return;
                }

                File.copy(dllsPath, targetPath);
            }
        });

        return Context.getBuildFields();
    }

    /*
        Sanco here;
        The way the macro works is that it takes the place where the build metadata was called
        and checks for the following:
            - A variable which includes the @:bindTarget metadata to indicate the macro where to add the bind (SHOULD BE A WEBVIEW)
            - The @:wBind or @:wSyncBind on functions, these methods can accept an argument inside the metadata which is the name that it will be assigned in the webview to access through window.<meta_name>
            - The function passed through @:wBind should have 2 arguments
                - One the RPC Sequence for the WebView Resolve function and another one for the Args passed from the WebView, Args will be null if nothing was passed from the WebView
            - The function passed through @:wSyncBind should have only 1 argument
                - Since this implementation is Synchronous, it resolves as soon as it gets called from the WebView
                - The only argument you should accept is the Args passed from the WebView, Args will be null if nothing was passed from the WebView, note that you may manipulate these but the RPC Sequence was already resolved
     */
    macro public static function bindables():Array<Field>
    {
        var _fields:Array<Field> = Context.getBuildFields();

        var target:Dynamic = null;

        for (field in _fields.copy())
        {
            switch (field.kind)
            {
                case FVar(t, e):
                    for (meta in field.meta)
                    {
                        switch (t)
                        {
                            case TPath(p):
                                if (p.name != "WebView")
                                {
                                    Context.error("WebView: Bind Target is not a WebView!", e.pos);
                                    break;
                                }

                            default:
                        }

                        if (meta.name == ":bindTarget")
                        {
                            try 
                            {
                                trace("got target");
                                target = e;
                                /*
                                switch (e.expr)
                                {
                                    case ENew(tp, params):
                                        switch (Context.resolveType(t, e.pos))
                                        {
                                            case TInst(cr, params):
                                                if (cr == null)
                                                {
                                                    Context.error("WebView: Failed to get the ClassType Ref", e.pos);
                                                    return _fields;
                                                }

                                                target = cr.get();

                                            default:
                                        }

                                    default:
                                }*/
                            }
                            catch(ex)
                            {
                                Context.error('WebView: ${ex.native}', e.pos);
                                break;
                            }
                        }
                    }

                case FFun(fun):
                    var bindID:String = field.name;
                    var bindName:String = "unknown";
                    var bindType:String = "unknown";

                    for (meta in field.meta)
                    {
                        if ([":wBind", ":wSyncBind"].contains(meta.name))
                        {
                            bindType = meta.name;

                            if (meta.params[0] == null)
                            {
                                bindName = bindID;
                                continue;
                            }

                            switch (meta.params[0].expr)
                            {
                                // Accept "name" and name (no ")
                                case EConst(CString(_i)) | EConst(CIdent(_i)):
                                    bindName = _i;

                                default:
                            }
                        }
                    }

                    if (bindID == "unknown" || bindType == "unknown")
                    {
                        // trace("WebView: Unknown Meta at " + Context.currentPos());
                        continue;
                    }

                    /*
                    var targetFields:Array<ClassField> = target.fields.get();
                    var bindCall = targetFields.filter((cf) ->
                    {
                        var ret:Bool = false;
                        switch (cf.kind)
                        {
                            case FMethod(k):
                                ret = (cf.name == "bind");

                            default:
                        }
                        return ret;
                    })[0];*/

                    var wrongFields:Array<WrongField> = getWrongFields(fun, bindType);
                    var outErr:String = "WebView: ";
                    for (wrong in wrongFields)
                    {
                        if (wrong.exc != null)
                            outErr += ' ${wrong.exc} on ${wrong.atPos} argument (${wrong.name}:${wrong.ofType}) |';
                        else 
                            outErr += ' Missing ${wrong.name}:${wrong.ofType} as ${wrong.atPos} argument |';
                    }

                    if (wrongFields.length > 0)
                    {
                        if (outErr.charCodeAt(outErr.length - 1) == "|".code)
                            outErr = outErr.substring(0, outErr.length - 1);

                        Context.error(outErr, fun.expr.pos);
                        break;
                    }

                    //trace(fun.expr);
                    //var func:BindFunc = (seq, req, arg) -> 
                    //{
                    //    w.resolve(seq, 0, "");
                    //}
                    //Reflect.callMethod(w, Reflect.field(w, "bind"), ["cock", func, null]);

                    Context.onAfterGenerate(() ->
                    {
                        macro switch (bindType)
                        {
                            case ":wBind":
                                trace("Binding asynchronously");
                                macro ${target}.bind($v{bindName}, (seq:String, req:String, args:Dynamic) ->
                                {
                                    ${fun.expr}(seq, req);
                                }, null);

                            case ":wSyncBind":
                                trace("Binding synchronously");
                                macro ${target}.bind($v{bindName}, (seq:String, req:String, args:Dynamic) ->
                                {
                                    ${fun.expr}(req);
                                    ${target}.resolve(seq, 0, "");
                                }, null);

                            case _:
                                Context.error("WebView: Bind Type matching failure", target.pos);
                                break;
                        }
                    });

                default:
            }
        }

        return _fields;
    }

    // smartass (not really)
    private static function getWrongFields(func:Function, bindType:String):Array<WrongField>
    {
        var fields:Array<WrongField> = [];

        switch (bindType)
        {
            case ":wBind":
                if (func.args.length <= 0)
                {
                    fields.push({
                        name: "seq",
                        atPos: "1st",
                        ofType: "String"
                    });

                    fields.push({
                        name: "args",
                        atPos: "2nd",
                        ofType: "String"
                    });
                    return fields;
                }

                if (func.args[0].name == "seq")
                {
                    fields.push({
                        name: "args",
                        atPos: "2nd",
                        ofType: "String"
                    });
                }

                if (func.args[0].name == "args")
                {
                    fields.push({
                        name: "seq",
                        atPos: "1st",
                        ofType: "String",
                        exc: "Argument should be seq"
                    });
                }

                if (func.args[1].name == "seq")
                {
                    fields.push({
                        name: "args",
                        atPos: "2nd",
                        ofType: "String",
                        exc: "Argument should be args"
                    });
                }

                if (func.args[0].name == "seq" && func.args[1].name == "args")
                    return [];

            case ":wSyncBind":
                if (func.args.length <= 0)
                {
                    fields.push({
                        name: "seq",
                        atPos: "1st",
                        ofType: "String"
                    });
                }
        }

        return fields;
    }
}