import Socket.Basic

namespace Socket
namespace SockAddr

/-- Create a [`SockAddr`](##Socket.SockAddr). -/
@[extern "lean_sockaddr_mk"]
opaque mk
  (host : @& String)
  (port : @& String)
  (family : AddressFamily := AddressFamily.unspecified)
  (type : SockType := SockType.unspecified)
  : IO SockAddr

/-- Create a [`SockAddr`](##Socket.SockAddr) for a Unix domain socket path. -/
@[extern "lean_sockaddr_mk_unix"]
opaque mkUnix (path : @& String) : IO SockAddr

/-- Get family of the [`SockAddr`](##Socket.SockAddr). -/
@[extern "lean_sockaddr_family"] opaque family (a : @& SockAddr) : Option AddressFamily

/-- Get family of the [`SockAddr`](##Socket.SockAddr). -/
@[extern "lean_sockaddr_port"] opaque port (a : @& SockAddr) : Option UInt16

/-- Get family of the [`SockAddr`](##Socket.SockAddr). -/
@[extern "lean_sockaddr_host"] opaque host (a : @& SockAddr) : Option String

end SockAddr

/-- Convert [`SockAddr`](##Socket.SockAddr) to `String`. -/
instance : ToString SockAddr where
  toString a :=
    let family := a.family.map (s!"{·}") |>.getD "none"
    match a.family with
    | some AddressFamily.unix =>
      let path := a.host.getD "none"
      s!"({path}, {family})"
    | _ =>
      let host := a.host.getD "none"
      let port := a.port.map (s!"{·}") |>.getD "none"
      s!"({host}, {port}, {family})"

end Socket
