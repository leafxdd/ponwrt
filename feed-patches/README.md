# feed-patches

Patches for packages that stay in their feeds, for changes too small to
justify a copy in `package/`. `feed-patches/<feed>/*.patch` applies to
`feeds/<feed>` with `-p1`. The AN7581 QWRT release workflow runs
`./feed-patches/apply.sh` after `./scripts/feeds update -a`; run it there
in a local build too. A patch that is already applied is skipped, and one
that no longer applies stops the script.

## luci

`0001-luci-base-raise-the-request-field-limit-to-10-MB.patch` raises
`HTTP_MAX_CONTENT` in `modules/luci-base/ucode/http.uc` from 100 kB to
10 MB. LuCI rejects a form field larger than that, and OpenClash's config
file page carries the whole config in two text areas, so with a config over
100 kB every Apply on that page failed with "the value exceeds the maximum
allow size". The limit is the same in Lean's tree.
