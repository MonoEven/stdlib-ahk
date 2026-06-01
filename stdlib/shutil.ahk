#Requires AutoHotkey v2.0

#Include <stdlib\init>

class AhkStdlibShutil
{
    static Error := AhkStdlibShutilError
    static SameFileError := AhkStdlibShutilSameFileError

    static copyfile(src, dst)
    {
        return AhkStdlibShutilCopyfile(src, dst)
    }

    static copy(src, dst)
    {
        return AhkStdlibShutilCopy(src, dst)
    }

    static move(src, dst)
    {
        return AhkStdlibShutilMove(src, dst)
    }

    static rmtree(path)
    {
        return AhkStdlibShutilRmtree(path)
    }
}

class AhkStdlibShutilError extends Error
{
}

class AhkStdlibShutilSameFileError extends OSError
{
}

stdlib.shutil := AhkStdlibShutil

AhkStdlibShutilCopyfile(src, dst)
{
    sourcePath := AhkStdlibShutilPathString(src)
    targetPath := AhkStdlibShutilPathString(dst)

    if !FileExist(sourcePath)
        throw OSError("No such file or directory: '" sourcePath "'", -1)
    if DirExist(sourcePath)
        throw OSError("Permission denied: '" sourcePath "'", -1)

    sourceFull := AhkStdlibShutilFullPath(sourcePath)
    targetFull := AhkStdlibShutilFullPath(targetPath)
    if sourceFull = targetFull
        throw AhkStdlibShutilSameFileError("'" sourceFull "' and '" targetFull "' are the same file", -1)

    if DirExist(targetPath)
        throw OSError("Permission denied: '" targetPath "'", -1)

    parent := AhkStdlibShutilParent(targetPath)
    if parent != "" && !DirExist(parent)
        throw OSError("No such file or directory: '" parent "'", -1)

    if FileExist(targetPath) && !DirExist(targetPath)
        FileDelete targetPath

    FileCopy sourcePath, targetPath, 1
    return AhkStdlibShutilFullPath(targetPath)
}

AhkStdlibShutilCopy(src, dst)
{
    sourcePath := AhkStdlibShutilPathString(src)
    targetPath := AhkStdlibShutilPathString(dst)

    if DirExist(targetPath) {
        SplitPath sourcePath, &name
        targetPath := RTrim(targetPath, "\") "\" name
    }
    return AhkStdlibShutilCopyfile(sourcePath, targetPath)
}

AhkStdlibShutilMove(src, dst)
{
    sourcePath := AhkStdlibShutilPathString(src)
    targetPath := AhkStdlibShutilPathString(dst)

    if !FileExist(sourcePath)
        throw OSError("No such file or directory: '" sourcePath "'", -1)

    if DirExist(targetPath) {
        SplitPath sourcePath, &name
        targetPath := RTrim(targetPath, "\") "\" name
    }

    sourceFull := AhkStdlibShutilFullPath(sourcePath)
    targetFull := AhkStdlibShutilFullPath(targetPath)
    if sourceFull = targetFull
        return targetFull

    parent := AhkStdlibShutilParent(targetPath)
    if parent != "" && !DirExist(parent)
        throw OSError("No such file or directory: '" parent "'", -1)

    if DirExist(sourcePath)
        DirMove sourcePath, targetPath, 2
    else
        FileMove sourcePath, targetPath, 1

    return targetFull
}

AhkStdlibShutilRmtree(path)
{
    targetPath := AhkStdlibShutilPathString(path)
    if !DirExist(targetPath)
        throw OSError("No such file or directory: '" targetPath "'", -1)

    DirDelete targetPath, true
}

AhkStdlibShutilPathString(path)
{
    if IsObject(path) && HasProp(path, "Path")
        return path.Path
    if IsObject(path)
        return String(path)
    return path ""
}

AhkStdlibShutilFullPath(path)
{
    path := AhkStdlibShutilPathString(path)
    if RegExMatch(path, "i)^[a-z]:\\") || SubStr(path, 1, 2) = "\\"
        return path
    return A_WorkingDir "\" path
}

AhkStdlibShutilParent(path)
{
    path := AhkStdlibShutilPathString(path)
    SplitPath path, , &dir
    return dir
}
