import process/supervisor/set_supervisor
import qr_push/mailbox

pub fn spawn_link() {
  set_supervisor.spawn_link(
    fn(args) {
      let tuple(target, pull_secret, push_secret) = args
      mailbox.spawn_link(target, pull_secret, push_secret)
    },
  )
}
