import gleam/binary.{Binary}
import gleam/option.{Some, None}
import process/process.{From, Milliseconds, Infinity}

pub type Message {
  Pull(from: From(String), pull_secret: Binary)
  Redirect(from: From(String), push_secret: Binary)
  Push(from: From(Nil), push_secret: Binary, message: String)
}

fn loop(receive, target, pull_check, push_check, follower, message) {
  case receive(Infinity) {
    Some(Pull(from, pull_secret)) -> {
      let True = pull_check == pull_secret
      case message {
        None -> loop(
          receive,
          target,
          pull_check,
          push_check,
          Some(from),
          message,
        )
      }
    }
    // Front end
    // Clean up registry notes
    // make public
    // suggestions of default release in template project
    Some(Redirect(from, push_secret)) -> {
      let True = push_check == push_secret
      process.reply(from, target)
      loop(receive, target, pull_check, push_check, follower, message)
    }
    Some(Push(from, push_secret, message)) -> {
      let True = push_check == push_secret
      process.reply(from, Nil)
      case follower {
        Some(waiting) -> {
          process.reply(waiting, message)
          loop(receive, target, pull_check, push_check, follower, Some(message))
        }
      }
    }
  }
}

pub fn spawn_link(target, pull_check, push_check) {
  process.spawn_link(loop(_, target, pull_check, push_check, None, None))
}

pub fn pull(pid, pull_secret, wait) {
  process.call(pid, Pull(_, pull_secret), Milliseconds(wait))
}

pub fn redirect(pid, push_secret, wait) {
  process.call(pid, Redirect(_, push_secret), Milliseconds(wait))
}

pub fn push(pid, push_secret, message, wait) {
  process.call(pid, Push(_, push_secret, message), Milliseconds(wait))
}
