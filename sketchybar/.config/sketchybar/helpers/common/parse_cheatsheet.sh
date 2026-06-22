#!/bin/bash
# Outputs aerospace cheatsheet as plain text lines to stdout
python3 - "${HOME}/.aerospace.toml" <<'PYEOF'
import re, sys

with open(sys.argv[1]) as f:
    content = f.read()

def parse_section(content, section):
    in_section = False
    bindings = []
    for line in content.split('\n'):
        s = re.sub(r'\s*#.*$', '', line.strip()).strip()
        if s == f'[{section}]':
            in_section = True; continue
        if in_section and s.startswith('[') and s.endswith(']'): break
        if in_section and '=' in s and not s.startswith('#'):
            m = re.match(r"^(\S+)\s*=\s*'([^']+)'", s)
            if m: bindings.append((m.group(1), m.group(2))); continue
            m = re.match(r"^(\S+)\s*=\s*\[(.+)\]", s)
            if m:
                cmds = re.findall(r"'([^']+)'", m.group(2))
                meaningful = [c for c in cmds if not c.startswith('mode ')]
                bindings.append((m.group(1), ' + '.join(meaningful) if meaningful else cmds[0]))
    return bindings

def align(rows, sep='  ->  '):
    if not rows: return []
    w = max(len(k) for k, _ in rows)
    return [f'{k:<{w}}{sep}{v}' for k, v in rows]

def format_main(bindings):
    ws_num={};mv_num={};ws_let={};mv_let={};focus_k={};move_k={};others=[]
    for key, cmd in bindings:
        if re.match(r'^alt-\d$', key)          and cmd.startswith('workspace '):              ws_num[key[-1]]=cmd.split()[-1]; continue
        if re.match(r'^alt-shift-\d$', key)    and cmd.startswith('move-node-to-workspace '): mv_num[key[-1]]=cmd.split()[-1]; continue
        if re.match(r'^alt-[a-z]$', key)       and cmd.startswith('workspace '):              ws_let[key[-1]]=cmd.split()[-1]; continue
        if re.match(r'^alt-shift-[a-z]$', key) and cmd.startswith('move-node-to-workspace '): mv_let[key[-1]]=cmd.split()[-1]; continue
        kc = re.match(r'^alt-(shift-)?([hjkl]|left|down|up|right)$', key)
        if kc and cmd.startswith(('focus ','move ')):
            (move_k if kc.group(1) else focus_k)[kc.group(2)] = cmd.split()[-1]; continue
        others.append((key, cmd))

    sections = []

    nav = []
    if focus_k: nav.append(('alt-h/j/k/l', 'focus left/down/up/right'))
    if move_k:  nav.append(('alt-shift-h/j/k/l', 'move window left/down/up/right'))
    if nav: sections.append(('Navigation', nav))

    ws = []
    if ws_num or ws_let:
        d        = sorted(ws_num.keys()) if ws_num else []
        num_part = f'1-{d[-1]}' if d else ''
        let_part = 'a-z' if ws_let else ''
        ws.append((f'alt-[{num_part}{let_part}]', 'switch to workspace'))
    if mv_num or mv_let:
        d        = sorted(mv_num.keys()) if mv_num else []
        num_part = f'1-{d[-1]}' if d else ''
        let_part = 'a-z' if mv_let else ''
        ws.append((f'alt-shift-[{num_part}{let_part}]', 'send window to workspace'))
    ws.append(('alt-tab',       'last workspace'))
    ws.append(('alt-shift-tab', 'move workspace to next monitor'))
    if ws: sections.append(('Workspaces', ws))

    layout_labels = {
        'alt-slash': 'toggle tiling direction',
        'alt-comma': 'toggle accordion',
        'alt-minus': 'resize -50',
        'alt-equal': 'resize +50',
    }
    lay=[]; skip={'alt-tab','alt-shift-tab'}; seen=set()
    for key, cmd in others:
        if key in seen or key in skip or 'cheatsheet' in cmd: continue
        seen.add(key); lay.append((key, layout_labels.get(key, cmd)))
    if lay: sections.append(('Layout', lay))

    out = []
    for title, rows in sections:
        out.append(f'HEADER:{title}')
        for line in align(rows):
            out.append(f'LINE:{line}')
        out.append('LINE:')
    return out

def format_service(bindings):
    join_k={}; others=[]
    for key, cmd in bindings:
        kc = re.match(r'^(alt-shift-)?([hjkl]|left|down|up|right)$', key)
        if kc and 'join-with' in cmd: join_k[kc.group(2)]=cmd.replace('join-with ',''); continue
        others.append((key, cmd))
    rows = []
    if join_k: rows.append(('h/j/k/l', 'join window left/down/up/right'))
    for key, cmd in others: rows.append((key, cmd))
    result = []
    for line in align(rows):
        result.append(f'LINE:{line}')
    return result

lines = ['HEADER:AeroSpace  (main mode)']
lines += format_main(parse_section(content, 'mode.main.binding'))
lines += ['HEADER:Service mode  (alt-shift-;)']
lines += format_service(parse_section(content, 'mode.service.binding'))

for line in lines:
    print(line)
PYEOF
