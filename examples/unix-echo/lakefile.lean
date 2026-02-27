import Lake
open Lake DSL

package «unix-echo»

require Socket from ".."/".."

@[default_target]
lean_exe Main
