import Lake
open Lake DSL

package Socket where
  precompileModules := true

@[default_target]
lean_lib Socket

def cDir   := "native"
def ffiSrc := "native.c"
def ffiLib := "ffi"

target ffi.o (pkg : NPackage __name__) : System.FilePath := do
  let oFile := pkg.buildDir / "ffi.o"
  let srcJob ← inputTextFile <| pkg.dir / cDir / ffiSrc
  buildFileAfterDep oFile srcJob fun srcFile => do
    let flags := #["-I", (← getLeanIncludeDir).toString, "-fPIC"]
    compileO oFile srcFile flags

extern_lib ffi (pkg : NPackage __name__) := do
  let name := nameToStaticLib ffiLib
  let ffiO ← fetch <| pkg.target ``ffi.o
  buildStaticLib (pkg.buildDir / "lib" / name) #[ffiO]
