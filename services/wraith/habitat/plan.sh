pkg_name=wraith
pkg_origin=franklinwebber
pkg_version="0.1.0"
pkg_deps=(core/rust-nightly core/postgresql core/mysql core/sqlite core/gcc core/file)

# Below is the default behavior for this callback. Anything you put in this
# callback will override this behavior. If you want to use default behavior
# delete this callback from your plan.
# @see https://www.habitat.sh/docs/reference/plan-syntax/#callbacks
# @see https://github.com/habitat-sh/habitat/blob/master/components/plan-build/bin/hab-plan-build.sh
do_build() {
  # rustup default nightly
  # rustup update && cargo update

  cargo update

  cargo install diesel_cli
  diesel setup
  diesel migration run

  cargo build
}
