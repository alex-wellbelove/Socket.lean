import Socket

open Socket

def sockPath : String := "/tmp/test-socket-lean.sock"

/-- Retry an IO action up to `n` times with a 50ms delay between attempts. -/
def retry (n : Nat) (action : IO α) : IO α := do
  match n with
  | 0 => action
  | n + 1 =>
    try action
    catch _ =>
      IO.sleep 50
      retry n action

def server : IO Unit := do
  -- Clean up any stale socket file
  try IO.FS.removeFile sockPath catch _ => pure ()
  let sock ← Socket.mk .unix .stream
  let addr ← SockAddr.mkUnix sockPath
  sock.bind addr
  sock.listen 1
  IO.println s!"Server listening on {sockPath}"
  -- Socket is non-blocking, so retry accept until a client connects
  let (clientAddr, clientSock) ← retry 100 (sock.accept)
  IO.println s!"Client connected: {clientAddr}"
  -- Also retry recv since the socket may not have data ready yet
  let data ← retry 100 do
    let d ← clientSock.recv 1024
    if d.size == 0 then throw (IO.Error.userError "no data yet")
    return d
  IO.println s!"Received {data.size} bytes"
  let _ ← clientSock.send data
  clientSock.close
  sock.close
  IO.FS.removeFile sockPath
  IO.println "Server done"

def client : IO Unit := do
  let sock ← Socket.mk .unix .stream
  let addr ← SockAddr.mkUnix sockPath
  -- Retry connect since server may not be ready yet
  retry 100 (sock.connect addr)
  let msg := "Hello from Unix socket!".toUTF8
  let _ ← sock.send msg
  let reply ← retry 100 do
    let d ← sock.recv 1024
    if d.size == 0 then throw (IO.Error.userError "no data yet")
    return d
  IO.println s!"Client got reply: {String.fromUTF8! reply}"
  sock.close

def main (args : List String) : IO Unit := do
  match args with
  | ["server"] => server
  | ["client"] => client
  | _ => IO.println "Usage: main [server|client]"
