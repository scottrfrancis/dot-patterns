#!/usr/bin/env python3
"""generate — corpus (SKILL.md) → per-tool artifacts + a retrieval INDEX.

SKILL.md-native tools (Claude Code, Codex, OpenCode, Droid) consume the corpus directly
via skills.sh / plugins. This generator emits the two formats that AREN'T Agent-Skills:
  - Cursor  .mdc rules   (description + optional globs; agent-requested by default)
  - Copilot .instructions.md (invocation: model) / .prompt.md (invocation: user)
plus INDEX.md — a flat retrieval index (name · trigger · category · invocation · path)
for humans, and as a kb-mcp search surface.

    generate.py                 # generate public corpus → dist/
    generate.py --visibility <handle>  # include overlays/<handle> (for that profile's release)
    generate.py --self-test

stdlib only; Python 3.11-compatible.
"""
import os
import re
import sys
import glob

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DIST = os.path.join(ROOT, "dist")


def parse_skill(path):
    text = open(path, errors="replace").read()
    m = re.match(r"^---\n(.*?)\n---\n(.*)$", text, re.S)
    if not m:
        return None
    fm_raw, body = m.group(1), m.group(2)
    fm = {}
    key = None
    for line in fm_raw.splitlines():
        if re.match(r"^\w[\w-]*:", line):
            key, _, val = line.partition(":")
            key = key.strip()
            val = val.strip()
            if val == ">" or val == "|":
                fm[key] = ""            # folded scalar; gather following indented lines
            else:
                fm[key] = val.strip('"')
        elif key and line.startswith((" ", "\t")) and isinstance(fm.get(key), str):
            fm[key] = (fm[key] + " " + line.strip()).strip()
    return {"fm": fm, "body": body.lstrip("\n"), "path": path}


def iter_skills(visibility):
    """All SKILL.md whose visibility is allowed (public always; +overlay if requested)."""
    allowed = {"public"}
    if visibility and visibility != "public":
        allowed.add(visibility)
    roots = [os.path.join(ROOT, "base")]
    if visibility and visibility != "public":
        roots.append(os.path.join(ROOT, "overlays", visibility))
    for r in roots:
        for path in sorted(glob.glob(os.path.join(r, "**", "SKILL.md"), recursive=True)):
            sk = parse_skill(path)
            if sk and sk["fm"].get("visibility", "public") in allowed:
                yield sk
    # gof INDEX.md (not a SKILL dir) also counts as a public entry
    gof = os.path.join(ROOT, "base", "patterns", "gof", "INDEX.md")
    if os.path.exists(gof):
        sk = parse_skill(gof)
        if sk:
            yield sk


def _write(path, content):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, "w") as f:
        f.write(content if content.endswith("\n") else content + "\n")


def gen_cursor(sk, out_dir):
    fm, body = sk["fm"], sk["body"]
    desc = fm.get("description", fm["name"])
    # model-invoked disciplines → agent-requested (.mdc description only); user → same
    mdc = f"---\ndescription: {desc}\n---\n\n{body}"
    _write(os.path.join(out_dir, "cursor", f"{fm['name']}.mdc"), mdc)


def gen_copilot(sk, out_dir):
    fm, body = sk["fm"], sk["body"]
    desc = fm.get("description", fm["name"])
    if fm.get("invocation") == "user":
        art = f'---\ndescription: "{desc}"\nmode: agent\n---\n\n{body}'
        _write(os.path.join(out_dir, "copilot", "prompts", f"{fm['name']}.prompt.md"), art)
    else:
        art = f'---\ndescription: "{desc}"\napplyTo: "**"\n---\n\n{body}'
        _write(os.path.join(out_dir, "copilot", "instructions",
                            f"{fm['name']}.instructions.md"), art)


def gen_index(skills, out_dir):
    lines = ["# Pattern index", "",
             "| pattern | category | invoke | source | trigger |",
             "|---|---|---|---|---|"]
    for sk in sorted(skills, key=lambda s: (s["fm"].get("category", ""), s["fm"]["name"])):
        fm = sk["fm"]
        trig = (fm.get("description", "")[:80] + "…") if fm.get("description") else ""
        lines.append(f"| `{fm['name']}` | {fm.get('category','')} "
                     f"| {fm.get('invocation','model')} | {fm.get('source','base')} "
                     f"| {trig} |")
    _write(os.path.join(out_dir, "INDEX.md"), "\n".join(lines))


def generate(visibility="public"):
    out_dir = os.path.join(DIST, visibility)
    skills = list(iter_skills(visibility))
    for sk in skills:
        if sk["fm"].get("name") == "gof-index":
            # index-style entry: emit copilot instruction + cursor rule, skip prompt split
            gen_cursor(sk, out_dir)
            gen_copilot(sk, out_dir)
            continue
        gen_cursor(sk, out_dir)
        gen_copilot(sk, out_dir)
    gen_index(skills, out_dir)
    return {"visibility": visibility, "entries": len(skills), "out": out_dir}


def _self_test():
    skills = list(iter_skills("public"))
    names = {s["fm"]["name"] for s in skills}
    assert "data-diode-list-control" in names, names
    assert "stand-up-the-instrument" in names, names
    assert "using-git-worktrees" in names, names       # accepted mixin
    assert "gof-index" in names, names
    # a suppressed mixin skill must NOT appear
    assert "test-driven-development" not in names, "suppressed mixin leaked into corpus"
    # frontmatter parse sanity
    dd = next(s for s in skills if s["fm"]["name"] == "data-diode-list-control")
    assert dd["fm"]["category"] == "security-egress", dd["fm"]
    assert "egress" in dd["fm"]["description"].lower(), dd["fm"]["description"]
    print(f"generate self-test: OK ({len(skills)} public entries)")
    return 0


def main(argv):
    if "--self-test" in argv:
        return _self_test()
    vis = argv[argv.index("--visibility") + 1] if "--visibility" in argv else "public"
    r = generate(vis)
    print(f"generated {r['entries']} entries ({r['visibility']}) → {r['out']}")
    print(f"  cursor/*.mdc, copilot/{{instructions,prompts}}/*, INDEX.md")
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
