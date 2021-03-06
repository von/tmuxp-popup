# tmuxp-popup
Open a tmux popup attached to a tmuxp loaded session

Usage: `tmuxp-popup [<options>] <session>`

`<session>` is the name of the tmux session. It is also assumed to be be the name
of the tmuxp configuration to load. This can be overriden with `-c <config>`

Options:

`-c <conf>`

Specify the tmuxp configuration to use. `<conf>` will be passed to `tmuxp load`

`-d`

Turn on debugging.

`-h`

Display help and exit.

`-s <size>`

Specify the size of the popup window. Must be validate arguments to `tmux popup`

`-t`

If `session` is already the active session, detach from that session.
This allows for the creation of a key binding in tmux to toggle
a popup window. E.g. `bind -n C-Up run-shell "tmuxp-popup -t popup"`

`-V`

Display version and exit.

# Detach on destroy

If you want the popup to close if you destroy the session, then set `detact-on-destory`
to `on` for the session. E.g.

    session_name: popup
    options:
      detach-on-destroy: on

# Copying to system pastebuffer on Mac

While recent versions of tmux seem to copy to the OSX pastebuffer without help
(e.g. `reattach-to-user-namespace`) it seems that within a nested tmux session
`copy-selection` won't result in the selection being in the system pastebuffer.
To work around this, use something like the following:

    bind -T copy-mode-vi Enter send-keys -X copy-pipe-and-cancel "pbcopy"

# Homepage

https://github.com/von/tmuxp-popup
